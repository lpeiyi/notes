**目录**

[toc]

# 1 锁、进程相关

## 1.1 show processlist大量进程显示：wait global read lock

用 xtrabackup 等备份工具做备份时会有全局锁，正常情况锁占用时间很短，但偶尔会遇到锁长时间占用导致系统写入阻塞，现象是 show processlist 看到众多会话显示 wait global read lock，那可能对业务影响会很大。而且 show processlist 是无法看到哪个会话持有了全局锁，如果直接杀掉备份进程有可能进程杀掉了，但锁依然没释放，数据库还是无法写入。这时我们需要有快速定位持有全局锁会话的方法，杀掉对应会话数据库就恢复正常了。

**方法1：利用 metadata_locks 视图**

此方法仅适用于 MySQL 5.7 以上版本，该版本 performance_schema 新增了 metadata_locks，如果上锁前启用了元数据锁的探针（默认是未启用的），可以比较容易的定位全局锁会话。

OBJECT_TYPE=GLOBAL  LOCK_TYPE=SHARED 表示全局锁

```sql
#开启元数据锁对应的探针

mysql> UPDATE performance_schema.setup_instruments SET ENABLED = 'YES' WHERE NAME = 'wait/lock/metadata/sql/mdl';

Query OK, 1 row affected (0.04 sec)

Rows matched: 1  Changed: 1  Warnings: 0



#模拟上锁

mysql> flush tables with read lock;

Query OK, 0 rows affected (0.06 sec)


mysql> select * from performance_schema.metadata_locks;

+-------------+--------------------+----------------+-----------------------+---------------------+---------------+-------------+-------------------+-----------------+----------------+

| OBJECT_TYPE | OBJECT_SCHEMA      | OBJECT_NAME    | OBJECT_INSTANCE_BEGIN | LOCK_TYPE           | LOCK_DURATION | LOCK_STATUS | SOURCE            | OWNER_THREAD_ID | OWNER_EVENT_ID |

+-------------+--------------------+----------------+-----------------------+---------------------+---------------+-------------+-------------------+-----------------+----------------+

| GLOBAL      | NULL               | NULL           |       140613033070288 | SHARED              | EXPLICIT      | GRANTED     | lock.cc:1110      |          268969 |             80 |

| COMMIT      | NULL               | NULL           |       140612979226448 | SHARED              | EXPLICIT      | GRANTED     | lock.cc:1194      |          268969 |             80 |

| GLOBAL      | NULL               | NULL           |       140612981185856 | INTENTION_EXCLUSIVE | STATEMENT     | PENDING     | sql_base.cc:3189  |          303901 |            665 |

| TABLE       | performance_schema | metadata_locks |       140612983552320 | SHARED_READ         | TRANSACTION   | GRANTED     | sql_parse.cc:6030 |          268969 |             81 |

+-------------+--------------------+----------------+-----------------------+---------------------+---------------+-------------+-------------------+-----------------+----------------+

4 rows in set (0.01 sec)

#OBJECT_TYPE=GLOBAL  LOCK_TYPE=SHARED 表示全局锁


mysql> select t.processlist_id from performance_schema.threads t join performance_schema.metadata_locks ml on ml.owner_thread_id = t.thread_id where ml.object_type='GLOBAL' and ml.lock_type='SHARED';

+----------------+
| processlist_id |
+----------------+
|         268944 |
+----------------+

1 row in set (0.00 sec)
```

定位到锁会话 ID 直接 kill 该会话即可。

**方法2：利用 events_statements_history 视图**

此方法适用于 MySQL 5.6 以上版本，启用 performance_schema.eventsstatements_history（5.6 默认未启用，5.7 默认启用），该表会 SQL 历史记录执行，如果请求太多，会自动清理早期的信息，有可能将上锁会话的信息清理掉。

```sql
#开启events_statements_history
mysql> update performance_schema.setup_consumers set enabled = 'YES' where NAME = 'events_statements_history'

Query OK, 0 rows affected (0.00 sec)

Rows matched: 1  Changed: 0  Warnings: 0


#模拟上锁
mysql> flush tables with read lock;

Query OK, 0 rows affected (0.00 sec)


mysql> select * from performance_schema.events_statements_history where sql_text like 'flush tables%'\G

*************************** 1. row ***************************

              THREAD_ID: 39

               EVENT_ID: 21

           END_EVENT_ID: 21

             EVENT_NAME: statement/sql/flush

                 SOURCE: socket_connection.cc:95

            TIMER_START: 94449505549959000

              TIMER_END: 94449505807116000

             TIMER_WAIT: 257157000

              LOCK_TIME: 0

               SQL_TEXT: flush tables with read lock

                 DIGEST: 03682cc3e0eaed3d95d665c976628d02

            DIGEST_TEXT: FLUSH TABLES WITH READ LOCK
...

    NESTING_EVENT_LEVEL: 0

1 row in set (0.00 sec)

#查看对应进程
mysql> select t.processlist_id from performance_schema.threads t join performance_schema.events_statements_history h on h.thread_id = t.thread_id where h.digest_text like 'FLUSH TABLES%';

+----------------+

| processlist_id |

+----------------+

|             12 |

+----------------+

1 row in set (0.01 sec)
```

**方法3：show processlist**

```sql
如果备份程序使用的特定用户执行备份，如果是 root 用户备份，那 time 值越大的是持锁会话的概率越大，如果业务也用 root 访问，重点是 state 和 info 为空的，这里有个小技巧可以快速筛选，筛选后尝试 kill 对应 ID，再观察是否还有 wait global read lock 状态的会话。
```

**方法4：重启**

如果所有方法都不奏效，重启试试。

## 1.2 cpu过高

**一、产生原因**

数据库系统通常情况下CPU不会成为瓶颈，导致服务器cpu飙升的原因一般是存在执行慢sql。

通常情况有两种：

1. 一般由于**某个慢SQL或者某一类性能不好的SQL大量执行**，导致的CPU暴增。通过脚本查看当前活动事务SQL，按照时间排序，可以很明显的找到源头。

2. 由**多个问题SQL高并发执行**，且与正常SQL间杂在一起。这种情况，SQL执行很快，无法有效判断到底哪一类SQL出的问题，我会通过开启slowlog临时收集，再通过pt-query-digest分析开销最大的SQL优化处理。

**二、解决过程**

**1）找到CPU高的线程**

```bash
top -H
```

**2）查看线程信息**

```sql
select * from performance_schema.threads where thread_os_id = '';
```

**3）查看线程详细信息**

将步骤2的thread_id代入：

```sql
select * from performance_schema.events_statements_current where thread = '';
```

**4）杀进程**

确认SQL有问题后，直接将**THREAD_OS_ID**进程kill掉。

kill完后，检查cpu使用率是否下降。

# 2 I/O、磁盘、文件、存储相关

## 2.1 磁盘空间满，导致挂库

可以先临时清理binlog释放空间，启动库，后续再挂新盘

没有主从，binlog可以随便删，删除完改一下index文件，然后在启动就好了 binlog只会影响主从和下游同步用，其他的并没有啥影响

删除binlog：

https://www.modb.pro/db/606883


![Alt text](fdba50eb6e13fe13e854485016fbc9b.png)

# 3 集群相关

## 3.1 MY-011526

**一、错误日志**

2024-02-03T00:33:18.335943+08:00 0 [ERROR] [MY-011526] [Repl] Plugin group_replication reported: 'This member has more executed transactions than those present in the group. Local transactions: 13fc049e-c133-11ee-a377-000c29df1f85:1 > Group transactions: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:1-10'
2024-02-03T00:33:18.336062+08:00 0 [ERROR] [MY-011522] [Repl] Plugin group_replication reported: 'The member contains transactions not present in the group. The member will now exit the group.'

**二、错误说明**

这个错误信息表明MySQL Group Replication中的某个成员与组中的其他成员之间存在事务不一致的情况，以及成员将退出组。具体来说，该成员执行的事务数目比组中存在的事务数目多。这可能是由于同步问题或者复制流程中的某些异常情况引起的。


**三、引发问题的原因**

- 从库执行了flush privileges，任何FLUSH语句都被记录到binlog中。
- 从库可写，从库的super_read_only未设置为ON。

**四、解决办法**

参考文章：

[https://forums.percona.com/t/replication-5-7-37-to-8-0-28-failing-because-of-replication-privilege-check/14954/3](https://forums.percona.com/t/replication-5-7-37-to-8-0-28-failing-because-of-replication-privilege-check/14954/3)

[https://forums.percona.com/t/mysql-group-replication/19721/2](https://forums.percona.com/t/mysql-group-replication/19721/2)

**方法1：最保险的办法是重建节点**

**方法2：可以在主库跳过从库这个事务**

```sql
SET GTID_NEXT='13fc049e-c133-11ee-a377-000c29df1f85:1';
BEGIN; COMMIT;
SET GTID_NEXT=AUTOMATIC;
```

## 3.2 sql线程错误，跳过指定事务

**一、查看复制状态**

```sql
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: 192.168.131.99
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: binlog.000068
          Read_Master_Log_Pos: 586
               Relay_Log_File: mysql002-relay-bin.000010
                Relay_Log_Pos: 672
        Relay_Master_Log_File: binlog.000061
             Slave_IO_Running: Yes
            Slave_SQL_Running: No
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 1410
                   Last_Error: Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 1 failed                       executing transaction 'bd4b724b-ab29-11ee-826f-000c294bd026:424255' at source log binlog.000061, end_log_pos 2765. See error log and/or perfor                      mance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 1766
              Relay_Log_Space: 9989536
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: NULL
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 1410
               Last_SQL_Error: Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 1 failed                       executing transaction 'bd4b724b-ab29-11ee-826f-000c294bd026:424255' at source log binlog.000061, end_log_pos 2765. See error log and/or perfor                      mance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 1
                  Master_UUID: bd4b724b-ab29-11ee-826f-000c294bd026
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State:
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp: 240302 23:30:53
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set: bd4b724b-ab29-11ee-826f-000c294bd026:424253-426568
            Executed_Gtid_Set: 2218063c-aef7-11ee-9e40-000c29f059d3:1-6,
bd4b724b-ab29-11ee-826f-000c294bd026:1-424254
                Auto_Position: 1
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:
       Master_public_key_path:
        Get_master_public_key: 1
            Network_Namespace:
1 row in set, 1 warning (0.00 sec)
```

**二、错误分析**

根据复制状态，可以看到 Slave_SQL_Running: No，此时sql线程已经停止，错误信息为：

```sql
Last_SQL_Error: Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 1 failed executing transaction'bd4b724b-ab29-11ee-826f-000c294bd026:424255' at source log binlog.000061, end_log_pos 2765. See error log and/or perfor mance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.
```

提示 Worker 1 有执行错误的事务，根据提示查看性能视图：

```sql
mysql> select * from performance_schema.replication_applier_status_by_worker where LAST_ERROR_MESSAGE <> ''\G
*************************** 1. row ***************************
                                           CHANNEL_NAME:
                                              WORKER_ID: 1
                                              THREAD_ID: NULL
                                          SERVICE_STATE: OFF
                                      LAST_ERROR_NUMBER: 1410
                                     LAST_ERROR_MESSAGE: Worker 1 failed executing transaction 'bd4b724b-ab29-11ee-826f-000c294bd026:424255' at source log binlog.000061, end_log_pos 2765; Error 'You are not allowed to create a user with GRANT' on query. Default database: ''. Query: 'GRANT SELECT, RELOAD, PROCESS, REPLICATION CLIENT, BACKUP_ADMIN ON *.* TO 'pmm'@'192.168.131.99''
                                   LAST_ERROR_TIMESTAMP: 2024-03-02 23:30:53.719870
                               LAST_APPLIED_TRANSACTION: bd4b724b-ab29-11ee-826f-000c294bd026:424254
     LAST_APPLIED_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP: 2024-01-29 23:25:54.899869
    LAST_APPLIED_TRANSACTION_IMMEDIATE_COMMIT_TIMESTAMP: 2024-01-29 23:25:54.899869
         LAST_APPLIED_TRANSACTION_START_APPLY_TIMESTAMP: 2024-03-02 23:30:53.712714
           LAST_APPLIED_TRANSACTION_END_APPLY_TIMESTAMP: 2024-03-02 23:30:53.717294
                                   APPLYING_TRANSACTION: bd4b724b-ab29-11ee-826f-000c294bd026:424255
         APPLYING_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP: 2024-01-29 23:26:22.316756
        APPLYING_TRANSACTION_IMMEDIATE_COMMIT_TIMESTAMP: 2024-01-29 23:26:22.316756
             APPLYING_TRANSACTION_START_APPLY_TIMESTAMP: 2024-03-02 23:30:53.717343
                 LAST_APPLIED_TRANSACTION_RETRIES_COUNT: 0
   LAST_APPLIED_TRANSACTION_LAST_TRANSIENT_ERROR_NUMBER: 0
  LAST_APPLIED_TRANSACTION_LAST_TRANSIENT_ERROR_MESSAGE:
LAST_APPLIED_TRANSACTION_LAST_TRANSIENT_ERROR_TIMESTAMP: 0000-00-00 00:00:00.000000
                     APPLYING_TRANSACTION_RETRIES_COUNT: 0
       APPLYING_TRANSACTION_LAST_TRANSIENT_ERROR_NUMBER: 0
      APPLYING_TRANSACTION_LAST_TRANSIENT_ERROR_MESSAGE:
    APPLYING_TRANSACTION_LAST_TRANSIENT_ERROR_TIMESTAMP: 0000-00-00 00:00:00.000000
1 row in set (0.00 sec)
```

关键信息为：Error 'You are not allowed to create a user with GRANT'，可知执行失败的语句是赋权相关的。

从库执行错误的sql为：

```sql
GRANT SELECT, RELOAD, PROCESS, REPLICATION CLIENT, BACKUP_ADMIN ON *.* TO 'pmm'@'192.168.131.99'
```

查看从库'pmm'@'192.168.131.99'用户的权限：

```sql
mysql> show grants for 'pmm'@'192.168.131.99';
+------------------------------------------------------------------------------------+
| Grants for pmm@192.168.131.99                                                      |
+------------------------------------------------------------------------------------+
| GRANT SELECT, RELOAD, PROCESS, REPLICATION CLIENT ON *.* TO `pmm`@`192.168.131.99` |
+------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

查看主库'pmm'@'192.168.131.99'用户的权限：

```sql
mysql> show grants for 'pmm'@'192.168.131.99';
+------------------------------------------------------------------------------------+
| Grants for pmm@192.168.131.99                                                      |
+------------------------------------------------------------------------------------+
| GRANT SELECT, RELOAD, PROCESS, REPLICATION CLIENT ON *.* TO `pmm`@`192.168.131.99` |
| GRANT BACKUP_ADMIN ON *.* TO `pmm`@`192.168.131.99`                                |
+------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)
```

可知报错的sql语句从库已经应用成功。

**三、错误处理方法**

根据前面搜集到的信息可知，从库sql进程错误执行的事务为一个赋权语句，且从库已经应用。所以此事务直接**跳过**即可。

步骤如下：

**1）关闭复制**

```sql
mysql> stop slave;
Query OK, 0 rows affected, 1 warning (0.00 sec)
```

确认是否关闭：

```sql
mysql> show slave status\G
*************************** 1. row ***************************
...
             Slave_IO_Running: No
            Slave_SQL_Running: No
...
```

**2）确定跳过的事务**

跳过的事务为`Executed_Gtid_Set`的最大值加1。

```sql
mysql> show slave status\G
*************************** 1. row ***************************
...
           Retrieved_Gtid_Set: bd4b724b-ab29-11ee-826f-000c294bd026:424253-426568
            Executed_Gtid_Set: 2218063c-aef7-11ee-9e40-000c29f059d3:1-6,
bd4b724b-ab29-11ee-826f-000c294bd026:1-424254
...
```

跳过的事务为：bd4b724b-ab29-11ee-826f-000c294bd026:424255


**3）跳过事务**

跳过事务的本质是插入一个空的事务，关键步骤是 set session gtid_next。

跳过事务后，需要将gtid_next设置回automatic。

```sql
mysql> set session gtid_next='bd4b724b-ab29-11ee-826f-000c294bd026:424255';
Query OK, 0 rows affected (0.00 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> commit;
Query OK, 0 rows affected (0.00 sec)

mysql> set session gtid_next='automatic';
Query OK, 0 rows affected (0.00 sec)
```

**4）重启复制**

```sql
mysql> start slave;
Query OK, 0 rows affected, 1 warning (0.05 sec)

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: 192.168.131.99
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: binlog.000068
          Read_Master_Log_Pos: 586
               Relay_Log_File: mysql002-relay-bin.000022
                Relay_Log_Pos: 451
        Relay_Master_Log_File: binlog.000068
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 586
              Relay_Log_Space: 1303
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 1
                  Master_UUID: bd4b724b-ab29-11ee-826f-000c294bd026
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set: bd4b724b-ab29-11ee-826f-000c294bd026:424253-426568
            Executed_Gtid_Set: 2218063c-aef7-11ee-9e40-000c29f059d3:1-6,
bd4b724b-ab29-11ee-826f-000c294bd026:1-426568
                Auto_Position: 1
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:
       Master_public_key_path:
        Get_master_public_key: 1
            Network_Namespace:
1 row in set, 1 warning (0.00 sec)
```

双YES，说明复制已经恢复正常。

**四、验证主从是否一致**

查看从库数据：

```sql
mysql> show grants for 'pmm'@'192.168.131.99';
+------------------------------------------------------------------------------------+
| Grants for pmm@192.168.131.99                                                      |
+------------------------------------------------------------------------------------+
| GRANT SELECT, RELOAD, PROCESS, REPLICATION CLIENT ON *.* TO `pmm`@`192.168.131.99` |
+------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

查看主库数据：

```sql
mysql> show grants for 'pmm'@'192.168.131.99';
+------------------------------------------------------------------------------------+
| Grants for pmm@192.168.131.99                                                      |
+------------------------------------------------------------------------------------+
| GRANT SELECT, RELOAD, PROCESS, REPLICATION CLIENT ON *.* TO `pmm`@`192.168.131.99` |
| GRANT BACKUP_ADMIN ON *.* TO `pmm`@`192.168.131.99`                                |
+------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)
```

发现从库`pmm`@`192.168.131.99`用户少了BACKUP_ADMIN权限。

把这个缺失的权限补齐：

```sql
#主库执行：
mysql> GRANT BACKUP_ADMIN ON *.* TO `pmm`@`192.168.131.99`;
Query OK, 0 rows affected (0.00 sec)
```

# 4 连接相关

## 4.1 忘记root码

首先，需要确认是“root@localhost”还是“root@%”密码丢失，因为这是2个不同的用户，若其中一个丢失，那么可以使用另一个用户登录，然后修改密码。

```bash
vim /etc/my.cnf
#添加
skip-grant-tables

systemctl restart mysqld

mysql -uroot

# < mysql5.7
update mysql.user set password=password('Root123.') where user='root';
select user,host,grant_priv,super_priv,password,authentication_string from mysql.user;

# > mysql5,7
flush privileges;
alter user root@'localhost' identified by 'test';
alter user root@'%' identified by 'test';
select user,host,grant_priv,super_priv,authentication_string,password_last_changed from mysql.user;
```

# 5 备份恢复相关

## 5.1 ERROR 3546 (HY000)
**一、数据库备份恢复过程中的报错：ERROR 3546 (HY000) at line 24: @@GLOBAL.GTID_PURGED cannot be changed: the added gtid set must not overlap with @@GLOBAL.GTID_EXECUTED**

**解决方案：**

```bash
重新dump数据库，使用 --set-gtid-purged=off的参数禁止导出gtid信息，再load进目标数据库。

mysqldump -uroot -p --set-gtid-purged=off slowtech t1 > slowtech.t1.sql
```

## 5.2 从库表误删除恢复

https://www.modb.pro/course/article/192

**报错信息：**

```sql
Slave_SQL_Running: No
Last_Error: Error executing row event: ‘Table ‘cjc.t2’ doesn’t exist’
Last_SQL_Errno: 1146
Last_SQL_Error: Error executing row event: ‘Table ‘cjc.t2’ doesn’t exist’
```

**解决方案：**

```sql
1.从库上忽略该表的同步：关闭sql线程，忽略，开启sql线程

2.恢复从库t2表数据：关闭复制，主库加锁，主库备份表，导入从库，

3.从库忽略过滤：从库检查表数据，忽略过滤，

4.启动同步

5.主、从：验证数据量是否一致

6.主库：解锁表
```

## 5.3 MySQL恢复指定表结构

### 5.3.1 从测试库拉取建表语句

**备份表结构：**

```bash
mysqldump -u[username] -p --no-data [database_name] [table_name] > [table_name]_structure.sql
```

**导入**

```bash
mysql -u[username] -p [database_name] < [table_name]_structure.sql
```

### 5.3.2 从备份文件拉取表结构

全备数据量很小时，直接通过vi进行查找

数据量大时，通过脚本过滤出来

```bash
grep -A100 "CREATE TABLE `demo`" /mysq

sed -e’/./{H;$!d;}’ -e ‘x;/CREATE TABLE t2/!d;q’ /mysqldata/bak/mysql_bak1.sql
```

## 5.4 恢复表数据

### 5.4.1 单库

找到binlog和pos

恢复：

```bash
mysqlbinlog --start-position=xxx --stop-position=xxx --database xxx binlog.xxx
```

### 5.4.1 主备



使用xtrabackup，做一个全库备份

模拟一些update操作，然后drop table

找一台服务器，新建一个实例

恢复全量备份

新实例与原主库配置同步关系

设置复制过滤只复制出错的表（可以快速应用日志）-->这步我没做，忘记了。。

利用 start slave sql_thread until sql_before_gtids='xxxxx:n' 恢复数据到drop操作之前。

再利用表空间传输或是单表逻辑备份，导入生产库中

完成恢复


## 5.5 恢复误删的库

此方法的一个前提条件是数据库打开了binlog，在生产环境中强烈建议打开binlog。这相当于数据库的归档，虽然占用了一定的存储资源，但是他带来的收益是巨大的。当数据库被误操作删除了之后，全量备份只能恢复到备份前的时间点，备份之后新增的数据是没办法回复的，要想恢复这部分数据，那就要借助binlog。

事件的时间节点：

1. 数据库创建、更新（历史数据）；
2. 全量备份：
2. 数据库更新（增量数据）；
3. 误操作删库；

恢复流程大概是：

1. 利用全量备份恢复历史数据；
2. 利用从全备开始到误操作前binlog恢复增量数据；


**一、历史数据**

这里我们以demo表数据作为恢复的参考指标。历史数据如下：

```sql
mysql> select * from test.demo;
+----+------+
| id | c1   |
+----+------+
|  1 | a    |
|  2 | b    |
|  3 | c    |
|  5 | e    |
+----+------+
4 rows in set (0.00 sec)
```

**二、备份数据库**

指定test数据库做备份：

```bash
[root@mysql001 full]# mysqldump -uroot -p test --single-transaction --set-gtid-purged=off --master-data=2 --flush-logs --routines --triggers --events --extended-insert=true > ../db/test.sql
WARNING: --master-data is deprecated and will be removed in a future version. Use --source-data instead.
Enter password:

[root@mysql001 db]# ls
test.sql
```

**三、插入和更新test数据库中的表**

插入和修改增量数据：

```sql
mysql> insert into test.demo values(6,'f');
Query OK, 1 row affected (0.00 sec)

mysql> insert into test.demo values(7,'g');
Query OK, 1 row affected (0.00 sec)

mysql> update test.demo set c1 = 'd' where id = 3;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from demo;
+----+------+
| id | c1   |
+----+------+
|  1 | a    |
|  2 | b    |
|  3 | d    |
|  5 | e    |
|  6 | f    |
|  7 | g    |
+----+------+
6 rows in set (0.00 sec)
```

**四、模拟误操作删库**

删库跑路：

```sql
mysql> drop database test;
Query OK, 1 row affected (0.02 sec)

mysql> select * from test.demo;
ERROR 1049 (42000): Unknown database 'test'
```

**五、查看当前binlog**

当前binlog为binlog.000076。

```sql
mysql> show master status\G
*************************** 1. row ***************************
             File: binlog.000076
         Position: 972
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set: 2218063c-aef7-11ee-9e40-000c29f059d3:1-6,
bd4b724b-ab29-11ee-826f-000c294bd026:1-426884
1 row in set (0.00 sec)

mysql> show binlog events in 'binlog.000076';
+---------------+-----+----------------+-----------+-------------+------------------------------------------------------------------------+
| Log_name      | Pos | Event_type     | Server_id | End_log_pos | Info                                                                   |
+---------------+-----+----------------+-----------+-------------+------------------------------------------------------------------------+
| binlog.000076 |   4 | Format_desc    |         1 |         126 | Server ver: 8.0.34, Binlog ver: 4                                      |
| binlog.000076 | 126 | Previous_gtids |         1 |         197 | bd4b724b-ab29-11ee-826f-000c294bd026:14-426881                         |
| binlog.000076 | 197 | Gtid           |         1 |         276 | SET @@SESSION.GTID_NEXT= 'bd4b724b-ab29-11ee-826f-000c294bd026:426882' |
| binlog.000076 | 276 | Query          |         1 |         351 | BEGIN                                                                  |
| binlog.000076 | 351 | Table_map      |         1 |         409 | table_id: 658 (test.demo)                                              |
| binlog.000076 | 409 | Write_rows     |         1 |         458 | table_id: 658 flags: STMT_END_F                                        |
| binlog.000076 | 458 | Xid            |         1 |         489 | COMMIT /* xid=5452 */                                                  |
| binlog.000076 | 489 | Gtid           |         1 |         568 | SET @@SESSION.GTID_NEXT= 'bd4b724b-ab29-11ee-826f-000c294bd026:426883' |
| binlog.000076 | 568 | Query          |         1 |         652 | BEGIN                                                                  |
| binlog.000076 | 652 | Table_map      |         1 |         710 | table_id: 658 (test.demo)                                              |
| binlog.000076 | 710 | Update_rows    |         1 |         760 | table_id: 658 flags: STMT_END_F                                        |
| binlog.000076 | 760 | Xid            |         1 |         791 | COMMIT /* xid=5454 */                                                  |
| binlog.000076 | 791 | Gtid           |         1 |         868 | SET @@SESSION.GTID_NEXT= 'bd4b724b-ab29-11ee-826f-000c294bd026:426884' |
| binlog.000076 | 868 | Query          |         1 |         972 | drop database test /* xid=5456 */                                      |
+---------------+-----+----------------+-----------+-------------+------------------------------------------------------------------------+
```

可以看到，增量数据的修改和删库的事件全部都记录到了binlog.000076中。

**六、解析binlog**

将binlog.000076文件复制到临时目录中，目的是为了方便和安全操作，避免又产生误操作。

**注意**：这里千万不要将cp写成mv，否则数据库会报错binlog文件不存在。

```bash
[root@mysql001 db]# cp /disk1/data/binlog/binlog.000076 /disk1/bak/tmp/
```

查看全备的binlog的位置：

```bash
[root@mysql001 db]# grep "CHANGE MASTER TO MASTER_LOG_FILE" /disk1/bak/mysqldump/db/test.sql
-- CHANGE MASTER TO MASTER_LOG_FILE='binlog.000076', MASTER_LOG_POS=197;
```

MASTER_LOG_FILE='binlog.000076'和MASTER_LOG_POS=197，说明全量备份前的binlog文件为binlog.000076，位置点为197。因此，全备文件包含了binlog.000076文件197位置点前所有的数据。

所以，增量数据要从binlog.000076文件197位置点开始恢复，mysqlbinlog解析时加上`--start-position=197`，命令如下:

```bash
[root@mysql001 tmp]# mysqlbinlog -uroot -p --database=test --start-position=197 binlog.000076 > 0076bin_197_test.sql
Enter password:
[root@mysql001 tmp]# ls
0076bin_197_test.sql  binlog.000076
```

此外，一个重要的点就是，需要注释binlog中误操作命令，否则恢复无效：

```bash
[root@mysql001 tmp]# vim 0076bin_197_test.sql
#注释
/*drop database test*/
```

**七、将回复脚本传到备库（用来做恢复的实例）**

恢复操作最好放到非生产库中进行，原因是数据恢复其实是高危操作，不可控因素较多，恢复过程中难免还会出现错误。

因此，我们把恢复脚本发送到某个空闲的备库中操作，数据库版本号最好是一致的，否则可能会出现兼容问题。

```bash
[root@mysql001 tmp]# scp /disk1/bak/mysqldump/db/test.sql 192.168.131.61:/data/recover/
root@192.168.131.61's password:
test.sql                                                                                                                           100% 2121     1.6MB/s   00:00
[root@mysql001 tmp]# scp /disk1/bak/tmp/* 192.168.131.61:/data/recover/
root@192.168.131.61's password:
0076bin_197_test.sql                                                                                                               100% 5163     3.3MB/s   00:00
binlog.000076                                                                                                                      100%  972   955.1KB/s   00:00
```

备库中查看：

```bash
[root@recover8 recover]# ls
0076bin_197_test.sql  binlog.000076  test.sql
```

**八、执行恢复操作**

**1）数据库创建**

因为备份文件test.sql只是备份了test数据库的数据，并不包含数据库的创建语句，所以要手动创建数据库。

常用的几种创建方式：

- 直接创建一个；
- 从全备脚本中拉脚本；
- 在测试库/开发库中导出建库脚本。

我这里图方便，就直接创建了：

```sql
mysql> create database test;
Query OK, 1 row affected (0.01 sec)
```

**2）恢复全备数据**

执行全备脚本导入：

```bash
[root@recover8 recover]# mysql -uroot -p test  < test.sql
Enter password:
```

查看原始数据是否恢复：

```sql
mysql> select * from test.demo;
+----+------+
| id | c1   |
+----+------+
|  1 | a    |
|  2 | b    |
|  3 | c    |
|  5 | e    |
+----+------+
4 rows in set (0.00 sec)
```

**3）增量数据恢复**

导入增量数据文件：

```bash
[root@recover8 recover]# mysql -uroot -p test  < 0076bin_197_test.sql
Enter password:
ERROR 1781 (HY000) at line 22: @@SESSION.GTID_NEXT cannot be set to UUID:NUMBER when @@GLOBAL.GTID_MODE = OFF.
```

报错，脚本中包含@@SESSION.GTID_NEXT，不能应用。

重新解析binlog.000076，跳过gtid：

```bash
[root@recover8 recover]# mysqlbinlog -uroot -p --database=test --start-position=197 --skip-gtids binlog.000076 > 0076bin_197_test1.sql
Enter password:
[root@recover8 recover]# ls
0076bin_197_test1.sql  0076bin_197_test.sql  binlog.000076  test.sql
[root@recover8 recover]# vim 0076bin_197_test1.sql
#注释
/*drop database test*/
```

重新导入增量数据：

```bash
[root@recover8 recover]# mysql -uroot -p test  < 0076bin_197_test1.sql
Enter password:
```

**4）查看增量数据是否恢复**

```sql
mysql> select * from test.demo;
+----+------+
| id | c1   |
+----+------+
|  1 | a    |
|  2 | b    |
|  3 | d    |
|  5 | e    |
|  6 | f    |
|  7 | g    |
+----+------+
6 rows in set (0.00 sec)
```

数据已经完成恢复，实验成功。

**九、恢复到生产库**

最后把备库中的数据库备份，重新导入生产库就算完成恢复了。

## 5.6 The table may not be created in the reserved tablespace 'mysql'.

ERROR 3723 (HY000) at line 524: The table 'replication_asynchronous_connection_failover' may not be created in the reserved tablespace 'mysql'.


## 6 重建从库

```bash
[root@mysql002 full]# mysqldump -uroot -p --all-databases --hex-blob --single-transaction --set-gtid-purged=off --maste                                                            r-data=2 --flush-logs --routines --triggers --events --extended-insert=true --net-buffer-length=1677716 --max-allowed-p                                                            acket=67108864 > full.sql
WARNING: --master-data is deprecated and will be removed in a future version. Use --source-data instead.
Enter password:
[root@mysql002 full]# ll
total 4628
-rw-r--r-- 1 root root 4736692 Mar  5 00:19 full.sql
[root@mysql002 full]# systemctl stop mysqld
```