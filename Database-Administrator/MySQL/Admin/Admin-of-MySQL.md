# 1 安装和升级MySQL数据库（社区版）

## 1.1 安装

学习一门数据库，肯定需要从安装开始学起，MySQL数据库常用的安装方式有：

- YUM源安装
- RPM包安装
- 二进制文件安装
- 源码安装

最常用的安装方式是RPM包安装和二进制文件安装。下面我基于`Red Hat Enterprise Linux`操作系统介绍这两种安装方法。

我个人认为MySQL数据库的安装十分友好，不像Oracle数据库那么困难，这点必须好评。很多同学在学习Oracle数据库时就被安装这个步骤反复折磨，有一部分同学便是因为一只安装不成功，从而放弃了学习Oracle数据库的想法。

### 1.1.1 RPM包安装

**一、官网下载RPM包**

RPM包的下载地址是：https://dev.mysql.com/downloads/mysql/

根据操作系统类型和版本版本选择需要下载的包，我实验的环境是：

```sql
[root@lu9up ~]# cat /etc/redhat-release
Red Hat Enterprise Linux Server release 7.9 (Maipo)
```

选择的RPM包如下，点击下载到本地：

![Alt text](image.png)

**二、上传到操作系统**

上传的位置看个人而定

```bash
[root@mysql001 ~]# ll | grep mysql
-rw-r--r--  1 root root 1031792640 Dec 15 23:57 mysql-8.0.34-1.el7.x86_64.rpm-bundle.tar
```

**三、检查是否安装MySQL或MariaDB**

centos和redhat上一般已经安装有mariadb-libs包和/my.cnf配置文件，安装MySQL数据库前一定要删除，以免和新安装的MySQL造成冲突。

检查默认配置文件是否存在：

```bash
[root@mysql001 ~]# ll /etc/my.cnf
-rw-r--r--. 1 root root 570 Oct  1  2020 /etc/my.cnf
```

再检查是否有MySQL或者MariaDB的安装包：

```bash
[root@mysql001 ~]# rpm -qa | grep -i mysql
[root@mysql001 ~]# rpm -qa | grep -i mariadb
mariadb-libs-5.5.68-1.el7.x86_64
```

删除这些文件：

```bash
[root@mysql001 ~]# rpm -e mariadb-libs
[root@mysql001 ~]# ll /etc/my.cnf
ls: cannot access /etc/my.cnf: No such file or directory
```

删除mariadb-libs后，/etc/my.cnf也会被一并删除。

注意：如果报依赖错误，使用下面的命令删除：

```bash
rpm -e --nodeps mariadb-libs-5.5.68-1.el7.x86_64
```

卸载mariadb-libs后，my.cnf也会被一并删除。

**四、创建MySQL用户和组**

```bash
groupadd -g 27 mysql
useradd -g mysql mysql
passwd mysql
```

mysql用户添加系统权限：

```sql
[root@mysql001 ~]# vim /etc/sudoers
```

添加：

```bash
mysql     ALL=(ALL)      NOPASSWD:ALL
```

NOPASSWD是无需输入密码（个人习惯），安全起见，建议改为ALL。

**五、解压安装包**

查看安装包里包含的rpm包：

```bash
[root@mysql001 ~]# tar -tvf mysql-8.0.34-1.el7.x86_64.rpm-bundle.tar
-rw-r--r-- bteam/common 16755300 2023-06-25 11:06 mysql-community-client-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common  3745824 2023-06-25 11:06 mysql-community-client-plugins-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common   681724 2023-06-25 11:06 mysql-community-common-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common 528347988 2023-06-25 11:07 mysql-community-debuginfo-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common   1947800 2023-06-25 11:07 mysql-community-devel-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common   4217912 2023-06-25 11:07 mysql-community-embedded-compat-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common   2344364 2023-06-25 11:07 mysql-community-icu-data-files-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common   1563264 2023-06-25 11:07 mysql-community-libs-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common    685312 2023-06-25 11:08 mysql-community-libs-compat-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common  67410132 2023-06-25 11:08 mysql-community-server-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common  25637968 2023-06-25 11:08 mysql-community-server-debug-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common 378442676 2023-06-25 11:10 mysql-community-test-8.0.34-1.el7.x86_64.rpm
```

解压缩安装包：

```bash
[root@mysql001 ~]# tar -xvf mysql-8.0.34-1.el7.x86_64.rpm-bundle.tar -C /home/mysql/rpm/
mysql-community-client-8.0.34-1.el7.x86_64.rpm
mysql-community-client-plugins-8.0.34-1.el7.x86_64.rpm
mysql-community-common-8.0.34-1.el7.x86_64.rpm
mysql-community-debuginfo-8.0.34-1.el7.x86_64.rpm
mysql-community-devel-8.0.34-1.el7.x86_64.rpm
mysql-community-embedded-compat-8.0.34-1.el7.x86_64.rpm
mysql-community-icu-data-files-8.0.34-1.el7.x86_64.rpm
mysql-community-libs-8.0.34-1.el7.x86_64.rpm
mysql-community-libs-compat-8.0.34-1.el7.x86_64.rpm
mysql-community-server-8.0.34-1.el7.x86_64.rpm
mysql-community-server-debug-8.0.34-1.el7.x86_64.rpm
mysql-community-test-8.0.34-1.el7.x86_64.rpm
```

检查rpm包：

```bash
[mysql@mysql001 rpm]$ pwd
/home/mysql/rpm
[mysql@mysql001 rpm]$ ls
mysql-community-client-8.0.34-1.el7.x86_64.rpm           mysql-community-icu-data-files-8.0.34-1.el7.x86_64.rpm
mysql-community-client-plugins-8.0.34-1.el7.x86_64.rpm   mysql-community-libs-8.0.34-1.el7.x86_64.rpm
mysql-community-common-8.0.34-1.el7.x86_64.rpm           mysql-community-libs-compat-8.0.34-1.el7.x86_64.rpm
mysql-community-debuginfo-8.0.34-1.el7.x86_64.rpm        mysql-community-server-8.0.34-1.el7.x86_64.rpm
mysql-community-devel-8.0.34-1.el7.x86_64.rpm            mysql-community-server-debug-8.0.34-1.el7.x86_64.rpm
mysql-community-embedded-compat-8.0.34-1.el7.x86_64.rpm  mysql-community-test-8.0.34-1.el7.x86_64.rpm
```

**六、安装RPM包**

在大部分情况下，MySQL标准安装需要安装mysql-community-server, mysql-community-client, mysql-community-client-plugins, mysql-community-libs, mysql-community-icu-data-files, mysql-community-common, and mysql-community-libs-compat。

虽然使用如yum来安装包更好，但也可以直接用rpm -Uvh命令安装rpm包。但是，使用rpm -Uvh反而使安装过程更容易失败，因为安装过程可能会遇到潜在的依赖问题。

执行安装命令：

```sql
sudo yum install mysql-community-{server,client,client-plugins,icu-data-files,common,libs}-*
```

如果只安装客户端程序，可以不安装的mysql-community-server ：

```bash
sudo yum install mysql-community-{client,client-plugins,common,libs}-*
```

**七、初始化数据库**

安装好后，先不要启动数据库服务，因为第一次启动MySQL数据库服务时会自动初始化，可以根据自己的需求对系统参数进行修改，修改系统参数的方式为编辑默认配置文件：/etc/my.cnf。

1. datadir：是MySQL数据库系统的一个重要参数，它指定了MySQL数据库的数据文件存放的位置。这些数据文件包括了所有的数据库、表、索引等信息。默认为/var/lib/mysql，可以修改到合适的磁盘路径中，例如/disk1/data。
2. innodb_log_file_size：这个参数指定在一个日志组中，每个log的大小。innodb的logfile就是事务日志，用来在mysql crash后的恢复，所以设置合理的大小对于mysql的性能非常重要，直接影响数据库的写入速度，事务大小，异常重启后的恢复。
3. innodb_data_home_dir：用于指定InnoDB存储引擎的数据文件的基本路径。这个路径下的所有文件都是InnoDB存储引擎的数据文件，包括表空间文件、双写日志文件等。
4. innodb_log_group_home_dir：innodb_log_group_home_dir是MySQL数据库中的一个参数，用于指定InnoDB存储引擎的redo日志文件所在的目录。这些日志文件用于存储事务数据，直到这些数据被写入到表空间的磁盘文件中。默认情况下，innodb_log_group_home_dir的值通常被设置为与innodb_data_home_dir相同。innodb_data_home_dir用于指定InnoDB存储引擎的数据文件的基本路径。这个路径下的所有文件都是InnoDB存储引擎的数据文件，包括表空间文件、双写日志文件等。但是，为了获得最佳的性能，建议将innodb_data_home_dir和innodb_log_group_home_dir设置到不同的物理存储阵列上，这样可以避免IO资源的冲突，有利于服务器处理大量的高并发连接。

```bash
[mysql@mysql001 ~]$ cat /etc/my.cnf

datadir=/disk1/data
socket=/var/lib/mysql/mysql.sock

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

innodb_log_file_size=100M
```

这里，我只调整了datadir和innodb_log_file_size参数。

参数文件准备好后，接下来可以启动mysqld服务。

**八、启动mysql服务**

```bash
[mysql@mysql001 data]$ sudo systemctl status mysqld;
● mysqld.service - MySQL Server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: inactive (dead) since Sat 2023-12-16 02:18:31 CST; 6s ago
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html
  Process: 6697 ExecStart=/usr/sbin/mysqld $MYSQLD_OPTS (code=exited, status=0/SUCCESS)
  Process: 6673 ExecStartPre=/usr/bin/mysqld_pre_systemd (code=exited, status=0/SUCCESS)
 Main PID: 6697 (code=exited, status=0/SUCCESS)
   Status: "Server shutdown complete"
[mysql@mysql001 ~]$ sudo systemctl start mysqld
[mysql@mysql001 ~]$ sudo systemctl status mysqld
● mysqld.service - MySQL Server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2023-12-16 00:48:43 CST; 20min ago
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html
  Process: 1031 ExecStartPre=/usr/bin/mysqld_pre_systemd (code=exited, status=0/SUCCESS)
 Main PID: 1631 (mysqld)
   Status: "Server is operational"
   CGroup: /system.slice/mysqld.service
           └─1631 /usr/sbin/mysqld

Dec 16 00:48:37 mysql001 systemd[1]: Starting MySQL Server...
Dec 16 00:48:43 mysql001 systemd[1]: Started MySQL Server.
```
**九、查看临时密码**

```bash
[mysql@mysql001 ~]$ sudo grep 'temporary password' /var/log/mysqld.log
2023-12-15T16:48:40.499788Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: ;eYMs-0+Lovk
```

MySQL数据库root的密码为`;eYMs-0+Lovk`，第一次登录需使用这个密码，然后再修改自定义密码。

**十、登录并修改密码**

使用临时密码登录：

```bash
[mysql@mysql001 ~]$ mysql -uroot -p';eYMs-0+Lovk'
```

修改密码：

```sql
mysql> set password = 'Mysql123.';
Query OK, 0 rows affected (0.00 sec)
```

验证：

```bash
[mysql@lu9up ~]$ mysql -uroot -pMysql123.
```

### 1.1.2 二进制文件安装

## 1.2 升级

## 1.3 

# 2 账号和权限

# 3 日志

## 3.1 错误日志

### 3.1.1 系统参数log_error_services

```sql
mysql> show variables like 'log_error_services';
+--------------------+----------------------------------------+
| Variable_name      | Value                                  |
+--------------------+----------------------------------------+
| log_error_services | log_filter_internal; log_sink_internal |
+--------------------+----------------------------------------+
1 row in set (0.00 sec)
```

非内置写组件

```sql
mysql> install component 'file://component_log_sink_syseventlog';
Query OK, 0 rows affected (0.00 sec)

mysql> select component_id,component_urn from mysql.component where component_urn like '%syseventlog%';
+--------------+---------------------------------------+
| component_id | component_urn                         |
+--------------+---------------------------------------+
|            2 | file://component_log_sink_syseventlog |
+--------------+---------------------------------------+
1 row in set (0.00 sec)
```

log_sink_syseventlog配置错误日志写入Linux系统日志:

```sql
mysql> set global log_error_services='log_filter_internal; log_sink_internal; log_sink_syseventlog';
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'log_error_services';
+--------------------+--------------------------------------------------------------+
| Variable_name      | Value                                                        |
+--------------------+--------------------------------------------------------------+
| log_error_services | log_filter_internal; log_sink_internal; log_sink_syseventlog |
+--------------------+--------------------------------------------------------------+
1 row in set (0.01 sec)
```

### 3.1.2 log_filter_internal

```sql
mysql> show variables like 'log_error_verbosity';
+---------------------+-------+
| Variable_name       | Value |
+---------------------+-------+
| log_error_verbosity | 3     |
+---------------------+-------+
1 row in set (0.00 sec)
```

### 3.1.3 log_sink_internal

```sql
mysql> show variables like 'log_error';
+---------------+---------------------+
| Variable_name | Value               |
+---------------+---------------------+
| log_error     | /var/log/mysqld.log |
+---------------+---------------------+
1 row in set (0.00 sec)
```

### 3.1.4 log_filter_diagmet组件

### 3.1.5 log_sink_json组件

### 3.1.6 log_sink_syseventlog组件

```sql
mysql> show variables like '%syseventlog%';
+-------------------------+--------+
| Variable_name           | Value  |
+-------------------------+--------+
| syseventlog.facility    | daemon |
| syseventlog.include_pid | ON     |
| syseventlog.tag         |        |
+-------------------------+--------+
3 rows in set (0.01 sec)
```

### 3.1.7 系统参数 log_timestamps

```sql

```

### 3.1.8 备份错误日志

```bash
[mysql@mysql001 data]$ sudo mv error.log error.log.bak231220
[sudo] password for mysql:
[mysql@mysql001 data]$ mysqladmin -uroot -pMysql123. flush-logs
mysqladmin: [Warning] Using a password on the command line interface can be insecure.
```

### 3.1.9 错误日志记录到数据库中

```sql
mysql> show status like 'error_log%';
+---------------------------+------------------+
| Variable_name             | Value            |
+---------------------------+------------------+
| Error_log_buffered_bytes  | 74336            |
| Error_log_buffered_events | 608              |
| Error_log_expired_events  | 0                |
| Error_log_latest_write    | 1702991680174494 |
+---------------------------+------------------+
4 rows in set (0.00 sec)

mysql> select * from performance_schema.error_log limit 4\G
*************************** 1. row ***************************
    LOGGED: 2023-12-16 00:48:37.870328
 THREAD_ID: 0
      PRIO: System
ERROR_CODE: MY-013169
 SUBSYSTEM: Server
      DATA: /usr/sbin/mysqld (mysqld 8.0.34) initializing of server in progress as process 1120
```

## 3.2 通用查询日志

记录客户端操作日志，包括连接断开信息，发送的sql。

### 3.2.1 系统参数说明

**一、log_output**

```sql
mysql> set global log_output='table,file';
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'log_output';
+---------------+------------+
| Variable_name | Value      |
+---------------+------------+
| log_output    | FILE,TABLE |
+---------------+------------+
1 row in set (0.00 sec)
```

**二、general_log**

```sql
mysql> set global general_log=on;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'general_log';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| general_log   | ON    |
+---------------+-------+
1 row in set (0.00 sec)
```

**三、general_log_file**

```sql
mysql> show variables like 'general_log_file';
+------------------+--------------------------+
| Variable_name    | Value                    |
+------------------+--------------------------+
| general_log_file | /disk1/data/mysql001.log |
+------------------+--------------------------+
1 row in set (0.00 sec)
```

**四、sql_log_off**

### 3.2.2 通用查询日志记录的内容

**一、通用查询日志文件中的记录**

**二、通用查询日志表中的记录**

mysql.general_log的定义：

```sql
mysql> show create table mysql.general_log\G
*************************** 1. row ***************************
       Table: general_log
Create Table: CREATE TABLE `general_log` (
  `event_time` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `user_host` mediumtext NOT NULL,
  `thread_id` bigint unsigned NOT NULL,
  `server_id` int unsigned NOT NULL,
  `command_type` varchar(64) NOT NULL,
  `argument` mediumblob NOT NULL
) ENGINE=CSV DEFAULT CHARSET=utf8mb3 COMMENT='General log'
1 row in set (0.00 sec)
```

```sql
mysql> select event_time,user_host,thread_id,server_id,command_type,convert(argument using utf8mb4) argument
    ->   from mysql.general_log
    ->  where thread_id = 12 order by event_time desc\G
*************************** 1. row ***************************
  event_time: 2023-12-20 00:13:40.560415
   user_host: root[root] @ localhost []
   thread_id: 12
   server_id: 1
command_type: Query
    argument: select event_time,user_host,thread_id,server_id,command_type,convert(argument using utf8mb4) argument
  from mysql.general_log
 where thread_id = 12 order by event_time desc
*************************** 2. row ***************************
  event_time: 2023-12-20 00:13:07.265893
   user_host: root[root] @ localhost []
   thread_id: 12
   server_id: 1
command_type: Query
    argument: select event_time,user_host,thread_id,server_id,command_type,convert(argument using utf8mb4) argument
  from mysql.general_log
 where thread_id = 12 order by event_time desc
```

## 3.3 慢查询日志

### 3.3.1 慢查询配置参数

**一、long_query_time**

**二、slow_query_log**

启用慢查询日志：

```sql
mysql> set global slow_query_log=on;
Query OK, 0 rows affected (0.00 sec)
```

**三、slow_query_log_file**

```sql
mysql> show variables like 'slow_query_log_file';
+---------------------+-------------------------------+
| Variable_name       | Value                         |
+---------------------+-------------------------------+
| slow_query_log_file | /disk1/data/mysql001-slow.log |
+---------------------+-------------------------------+
1 row in set (0.00 sec)


[mysql@mysql001 log]$ tailf /disk1/data/mysql001-slow.log
/usr/sbin/mysqld, Version: 8.0.34 (MySQL Community Server - GPL). started with:
Tcp port: 3306  Unix socket: /var/lib/mysql/mysql.sock
Time                 Id Command    Argument
```

**四、log_slow_extra**

```sql
mysql> set global log_slow_extra=on;
Query OK, 0 rows affected (0.00 sec)
```

### 3.3.2 statement_digest_text解析慢sql

```sql
mysql> select statement_digest_text("select user(),host from mysql.user where user = 'lu9up'");
+----------------------------------------------------------------------------------+
| statement_digest_text("select user(),host from mysql.user where user = 'lu9up'") |
+----------------------------------------------------------------------------------+
| SELECT SYSTEM_USER ( ) , HOST FROM `mysql` . `user` WHERE SYSTEM_USER = ?        |
+----------------------------------------------------------------------------------+
1 row in set (0.01 sec)
```


```bash
[mysql@mysql001 data]$ mysqldumpslow -s c  -t 2 /disk1/data/mysql001-slow.log
```


### 3.3.3 使用pt-query-digest解析慢查询日志

#### 3.3.3.1 安装pt-query-digest

下载Percona Toolkit：

https://www.percona.com/downloads


#### 3.3.3.2 语法和选项

https://docs.percona.com/percona-toolkit/pt-query-digest.html

语法：

```bash
pt-query-digest [OPTIONS] [FILES] [DSN]
```

选项：

1. --ask-pass
2. --continue-on-error
3. --create-review-table
4. --create-history-table
5. --defaults-file
6. --explain
7. --filter
8. --history
9. --limit
10. --max-line-length
11. --order0by
12. --output
13. --review
14. --since
15. --type
16. --until

#### 3.3.3.3 用法示例

1）直接分析慢查询文件

```bash
pt-query-digest  slow.log > mysql001-slow.log
```

2）分析网络流量包

从3306端口抓取1000个流量包输出到文件mysql.tcp.txt：

```bash
tcpdump -s 65535 -x -nn -q -tttt -i any -c 1000 port 3306 > mysql.tcp.txt
```

分析抓取的网路流量包：

```bash
pt-query-digest --type tcpdump mysql.tcp.txt> slow_report9.log
```

3）分析pocesslist的输出

```bash
pt-query-digest --processlist h = host1
```

4）保存分析过的sql语句到表中

```bash
pt-query-digest --review h=192.168.131.99 --no-report mysql001-slow.log
```

默认保存的表是percona_schema.query_review。


5）保存分析结果到表中

```bash
pt-query-digest --history h=192.168.131.99 --no-report mysql001-slow.log
```

默认保存的表是percona_schema.query_history。