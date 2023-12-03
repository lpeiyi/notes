[toc]

# 1 数据库数据量

## 1.1 根据 datafile 进行统计

### 1.1.1 非 cdb 数据库

```sql
set linesize 200
set pagesize 200
col TABLESPACE_NAME form a30
col gb form 999999.99
select sum(bytes)/1024/1024/1024 GB from dba_data_files;
select tablespace_name,sum(bytes)/1024/1024/1024 GB from dba_data_files group by tablespace_name;
```

### 1.1.2 cdb 数据库

```sql
set linesize 200
set pagesize 200
col TABLESPACE_NAME form a30
col gb form 999999.99
select sum(bytes)/1024/1024/1024 GB from cdb_data_files;
select con_id,sum(bytes)/1024/1024/1024 GB from cdb_data_files group by con_id;
select con_id,tablespace_name,sum(bytes)/1024/1024/1024 GB from cdb_data_files group by con_id,tablespace_name order by con_Id,GB;
```

## 1.2 使用 segments 来统计数据量

从 segments 中统计的数据量通常比从 datafile 中统计的要小，因为 datafile中用空闲的 block。

### 1.2.1 非 cdb 数据库

```sql
col gb form a10
select round(sum(bytes) / 1024 / 1024 / 1024, 2) || 'G' gb from dba_segments;
```

### 1.2.2 cdb 数据库

```sql
col gb form a10
select round(sum(bytes) / 1024 / 1024 / 1024, 2) || 'G' gb from cdb_segments;
```


# 2 检查Oracle实例状态 

```sql
col instance_name form a20
col host_name form a15
col status form a15
col database_status form a20
select instance_name,host_name,startup_time,status,database_status from v$instance;
```

其中“STATUS”表示Oracle当前的实例状态，必须为“OPEN”；“DATABASE_STATUS”表示Oracle当前数据库的状态，必须为“ACTIVE”。

```sql
col name form a20
col log_mode form a15
col open_mode form a15
select name,log_mode,open_mode from v$database;
```

其中“LOG_MODE”表示Oracle当前的归档方式。“ARCHIVELOG”表示数据库运行在归档模式下，“NOARCHIVELOG”表示数据库运行在非归档模式下。通常数据库必须运行在归档方式下。



# 3 检查Oracle服务进程 

```bash
ps -ef|grep ora_|grep -v grep&&ps -ef|grep ora_|grep -v
```

在检查Oracle的进程命令输出后，输出显示至少应包括以下一些进程：

- Oracle写数据文件的进程，输出显示为：“ora_dbw0_实例名”
- Oracle写日志文件的进程，输出显示为：“ora_lgwr_ 实例名”
- Oracle监听实例状态的进程，输出显示为：“ora_smon_实例名”
- Oracle监听客户端连接进程状态的进程，输出显示为：“ora_pmon_实例名”
- Oracle进行归档的进程，输出显示为：“ora_arc0_实例名”
- Oracle进行检查点的进程，输出显示为：“ora_ckpt_实例名”
- Oracle进行恢复的进程，输出显示为：“ora_reco_实例名”

# 4 检查Oracle监听状态

```bash
lsnrctl status
```

"Services Summary"项表示Oracle的监听进程正在监听哪些数据库实例，输出显示中至少应该有实例名和服务名。

检查监听进程是否存在：

```bash
ps -ef|grep lsn|grep -v grep
```

可能存在多个监听。

# 5 检查系统和oracle日志文件

## 5.1 检查操作系统日志文件

```sql
sudo cat /var/log/messages | grep failed
```

查看是否有与Oracle用户相关的出错信息。

## 5.2 检查oracle日志文件

Oracle 在运行过程中，会在警告日志文件(alert_SID.log)中记录数据库的一些运行情况：

- 数据库的启动、关闭；
- 启动时的非缺省参数；
- 数据库的重做日志切换情况，记录每次切换的时间，及如果因为检查点(checkpoint)操作没有执行完成造成不能切换，会记录不能切换的原因；
- 对数据库进行的某些操作，如创建或删除表空间、增加数据文件；
- 数据库发生的错误，如表空间不够、出现坏块、数据库内部错误(ORA－600)等。
- 
定期检查日志文件，根据日志中发现的问题及时进行处理：

| 问题 | 解决办法 |
| - | - |
| 启动参数不对 | 检查初始化参数文件 |
| 因为检查点操作或归档操作没有完成造成重做日志不能切换 | 如果经常发生这样的情况，可以考虑增加重做日志文件的大小和组的数量。采取措施提高检查点或归档操作的效率。 |
| 未经授权删除了表空间 | 检查数据库的安全问题，是否密码太简单；如有必要，撤消某些用户的系统权限。 |
| 出现坏块 | 检查是否是硬件问题(如磁盘本生有坏块)，如果不是，检查是那个数据库对象出现了坏块，对这个对象进行重建。 |
| 表空间不够 | 增加数据文件到相应的表空间 |
| ORA-600 | 根据日志文件的内容查看相应的TRC文件，如果是Oracle的bug，要及时打上相应的补丁。 |

获得日志文件的路径：

```sql
col inst_id form 999
col name form a15
col value form a50
select * from v$diag_info where name='Diag Trace';
```


操作数据库时，最好实时打印此文件：

```bash
tail -f alert_lucdb.log
```

查找错误日志：

```bash
cat alert_lucdb.log |grep ORA-
cat alert_lucdb.log |grep err
cat alert_lucdb.log |grep failed
```

# 6 检查Oracle核心转储目录

```sql
show parameter dump_
```

```bash
ls /u01/app/oracle/product/19.0.0/db_1/rdbms/log/*.trc | wc -l
ls /u01/app/oracle/diag/rdbms/lucdb/lucdb/cdump/*.trc | wc -l
```

如果上面命令的结果每天都在增长，则说明Oracle进程经常发生核心转储。这说明某些用户进程或者数据库后台进程由于无法处理的原因而异常退出。频繁的核心转储特别是数据库后台进程的核心转储会导致数据库异常终止。

# 7 检查Root用户和Oracle用户的email

```sql
sudo tail -n200 /var/mail/root
tail -n200 /var/mail/oracle
```

查看有无与Oracle用户相关的出错信息。

使用Oracle用户进行的备份作业也会在 mail 中记录信息。

# 8 检查Oracle对象状态

## 8.1 检查Oracle控制文件状态

```sql
select status,name from v$controlfile;
```

输出结果应该有 2 条以上（包含 2 条）的记录，“STATUS”应该为空。状态为空表示控制文件状态正常。

## 8.2 检查Oracle在线日志状态

```sql
col member form a50
select group#,status,type,member from v$logfile;
select SEQUENCE#,bytes/1024/1024 MB,members,status from v$log;
```

输出结果应该有 3 条以上（包含 3 条）记录。

v$logfile 中的“STATUS”应该为非“INVALID”，非“DELETED”。 注：“STATUS”显示为空表示正常。

注意日志文件的大小，早期默认是 50MB，可能太小。现在 200MB 通常够用。

## 8.3 检查归档日志

```sql
archive log list;
```

检查系统在 24 小时的归档频率：

```sql
set linesize 300
set pagesize 300
col day form a12
select to_char(first_time,'YYYY-MON-DD') day,
	   to_char(sum(decode(to_char(first_time,'HH24'),'00',1,0)),'9999') "00",
	   to_char(sum(decode(to_char(first_time,'HH24'),'01',1,0)),'9999') "01",
	   to_char(sum(decode(to_char(first_time,'HH24'),'02',1,0)),'9999') "02",
	   to_char(sum(decode(to_char(first_time,'HH24'),'03',1,0)),'9999') "03",
	   to_char(sum(decode(to_char(first_time,'HH24'),'04',1,0)),'9999') "04",
	   to_char(sum(decode(to_char(first_time,'HH24'),'05',1,0)),'9999') "05",
	   to_char(sum(decode(to_char(first_time,'HH24'),'06',1,0)),'9999') "06",
	   to_char(sum(decode(to_char(first_time,'HH24'),'07',1,0)),'9999') "07",
	   to_char(sum(decode(to_char(first_time,'HH24'),'08',1,0)),'9999') "08",
	   to_char(sum(decode(to_char(first_time,'HH24'),'09',1,0)),'9999') "09",
	   to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)),'9999') "10",
	   to_char(sum(decode(to_char(first_time,'HH24'),'11',1,0)),'9999') "11",
	   to_char(sum(decode(to_char(first_time,'HH24'),'12',1,0)),'9999') "12",
	   to_char(sum(decode(to_char(first_time,'HH24'),'13',1,0)),'9999') "13",
	   to_char(sum(decode(to_char(first_time,'HH24'),'14',1,0)),'9999') "14",
	   to_char(sum(decode(to_char(first_time,'HH24'),'15',1,0)),'9999') "15",
	   to_char(sum(decode(to_char(first_time,'HH24'),'16',1,0)),'9999') "16",
	   to_char(sum(decode(to_char(first_time,'HH24'),'17',1,0)),'9999') "17",
	   to_char(sum(decode(to_char(first_time,'HH24'),'18',1,0)),'9999') "18",
	   to_char(sum(decode(to_char(first_time,'HH24'),'19',1,0)),'9999') "19",
	   to_char(sum(decode(to_char(first_time,'HH24'),'20',1,0)),'9999') "20",
	   to_char(sum(decode(to_char(first_time,'HH24'),'21',1,0)),'9999') "21",
	   to_char(sum(decode(to_char(first_time,'HH24'),'22',1,0)),'9999') "22",
	   to_char(sum(decode(to_char(first_time,'HH24'),'23',1,0)),'9999') "23"
  from v$log_history 
 where first_time>sysdate-7 group by to_char(first_time,'YYYY-MON-DD');
```

高峰期归档日志产生频率应为 15 分钟到 30 分钟一次。太大或者太小都不合适。

## 8.4 检查表空间的状态

```sql
select tablespace_name,status from cdb_tablespaces;
```

输出结果中 STATUS 应该都为 ONLINE。

## 8.5 检查Oracle所有数据文件状态

```sql
col name form a100
col file_name form a100
select name,status from v$datafile;
select file_name,status from cdb_data_files;
```

输出结果中“STATUS”应该都为“ONLINE”或者“AVAILABLE”。

## 8.6 检查无效对象

```sql
select owner,object_name,object_type from dba_objects where status!='VALID';
SELECT owner, object_name, object_type FROM dba_objects WHERE status= 'INVALID';
```

如果有记录返回，则说明存在无效对象。若这些对象与应用相关，那么需要重新编译生成这个对象。

## 8.7 检查所有回滚段状态

```sql
select segment_name,status from dba_rollback_segs;
```

输出结果中所有回滚段的“STATUS”应该为“ONLINE”。

# 9 检查Oracle相关资源的使用情况

## 9.1 检查Oracle初始化文件中相关参数值

```sql
col resource_name form a25
col initial_allocation form a10
col limit_value form a10
select resource_name,max_utilization,initial_allocation,limit_value from v$resource_limit;
```

若 LIMIT_VALU 减去 MAX_UTILIZATION 小于 6，则表明与RESOURCE_NAME相关的Oracle初始化参数需要调整。主要注意processes和sessions。

## 9.2 检查数据库连接情况

查看当前会话连接数，是否属于正常范围:

```sql
col machine form a15
col PROGRAM form a40
select count(*) from v$session;
select sid,serial#,username,program,machine,status from v$session;
```

注意：上例中 SID 为 1 到 10(USERNAME 列为空)的会话，是 Oracle 的后台进程，不要对这些会话进行任何操作。

其中：

- SID 会话(session)的 ID 号；
- SERIAL# 会话的序列号，和 SID 一起用来唯一标识一个会话；
- USERNAME 建立该会话的用户名；
- PROGRAM 这个会话是用什么工具连接到数据库的；
- MACHINE 是客户端的 hostname
- STATUS 当前这个会话的状态，ACTIVE 表示会话正在执行某些任务，INACTIVE 表示当前会话没有执行任何操作。
  
如果建立了过多的连接，会消耗数据库的资源，同时，对一些“挂死”的连接可能需要手工进行清理。

手工断开某个会话，则执行：

```sql
alter system kill session 'SID,SERIAL#';
```

## 9.3 检查系统磁盘空间

如果文件系统的剩余空间过小或增长较快，需对其进行确认并删除不用的文件以释放空间。

```bash
df -h
```

## 9.4 检查表空间使用情况

```sql
select a.con_id,
       f.tablespace_name,
	   a.total,
	   f.free,
	   round((f.free/a.total)*100) "% Free"
 from (select tablespace_name,con_id,
	  		  sum(bytes/(1024*1024)) total 
	     from cdb_data_files 
	    group by tablespace_name,con_id) a,
	  (select tablespace_name,con_id,
			  round(sum(bytes/(1024*1024))) free
	     from cdb_free_space 
	    group by tablespace_name,con_id) f
WHERE a.tablespace_name = f.tablespace_name(+)
  and a.con_id = f.con_id(+)
order by "% Free";
```

## 9.5 检查一些扩展异常的对象

```sql
select Segment_Name, Segment_Type, TableSpace_Name,
	   (Extents / Max_extents) * 100 Percent
  From cdb_Segments
 Where Max_Extents != 0 
   and (Extents / Max_extents) * 100 >= 95 
 order By Percent;
```

如果有记录返回，则这些对象的扩展已经快达到它定义时的最大扩展值。对于这些对象要修改它的存储结构参数。

## 9.6 检查 system 表空间内的内容

```sql
select distinct(owner) 
  from cdb_tables
 where tablespace_name = 'SYSTEM' 
   and owner != 'SYS' 
   and owner != 'SYSTEM'
union
select distinct(owner) 
  from cdb_indexes
 where tablespace_name = 'SYSTEM' 
   and owner != 'SYS' 
   and owner != 'SYSTEM';
```

如果记录返回，则表明 system 表空间内存在一些非 system 和 sys 用户的对象。应该进一步检查这些对象是否与我们应用相关。如果相关请把这些对象移到非 System 表空间。

然后把owner带入：

```sql
col size_mb form 9999.99
select owner,table_name,'table' o_type
  from cdb_tables
 where tablespace_name = 'SYSTEM' 
   and owner = '&owner'
union
select owner,index_name,'index'
  from cdb_indexes
 where tablespace_name = 'SYSTEM' 
   and owner = '&owner';
```

## 9.7 检查对象的下一扩展与表空间的最大扩展值

```sql
SELECT a.table_name,
       a.next_extent,
       a.tablespace_name
  FROM all_tables a, 
       (SELECT tablespace_name, max(bytes) AS big_chunk
          FROM dba_free_space 
		 group by tablespace_name) f
 WHERE f.tablespace_name = a.tablespace_name
   AND a.next_extent > f.big_chunk
union 
SELECT a.index_name, a.next_extent, a.tablespace_name
  FROM all_indexes a, 
       (SELECT tablespace_name, max(bytes) AS big_chunk
		  FROM dba_free_space
		 group by tablespace_name) f
 WHERE f.tablespace_name = a.tablespace_name
   AND a.next_extent > f.big_chunk;
```

如果有记录返回，则表明这些对象的下一个扩展大于该对象所属表空间的最大扩展值，需调整相应表空间的存储参数。

## 9.8 无法分配额外盘区的段

```sql
select s.tablespace_name, s.segment_name, s.segment_type, s.owner
  from dba_segments s
 where s.next_extent >=
       (select max(f.BYTES)
          from dba_free_space f
         where f.TABLESPACE_NAME = s.tablespace_name)
    or s.extents = s.max_extents
 order by tablespace_name, segment_name;
```

# 10 检查 Oracle 数据库性能

## 10.1 检查数据库的等待事件

```sql
col event for a60
select sid,event,p1,p2,p3,WAIT_TIME,SECONDS_IN_WAIT from v$session_wait where event not like 'SQL%' and event not like 'rdbms%';
```

如果数据库长时间持续出现大量像 latch free，enqueue，buffer busy waits，db file sequential read，db file scattered read 等等待事件时，需要对其进行分析，可能存在有问题的语句。

## 10.2 Disk Read 最高的 SQL 语句的获取

```sql
SELECT ROWNUM rn,SQL_TEXT FROM (SELECT * FROM V$SQLAREA ORDER BY DISK_READS desc) WHERE ROWNUM<=5;
```

## 10.3 查找前 9 条性能差的

```sql
SELECT ROWNUM,t.* 
  FROM (SELECT PARSING_USER_ID,EXECUTIONS,SORTS,COMMAND_TYPE,DISK_READS,SQL_TEXT 
          FROM V$SQLAREA 
         ORDER BY DISK_READS DESC) t
 WHERE ROWNUM < 10 ;
```

## 10.4 等待时间最多的 5 个系统等待事件的获取

```sql
col wait_class form a10
col event form a20
SELECT * FROM (SELECT * FROM V$SYSTEM_EVENT WHERE EVENT NOT LIKE 'SQL%' ORDER BY TOTAL_WAITS DESC) WHERE ROWNUM<=5;
```

## 10.5 检查运行时间长的

```sql
COLUMN USERNAME FORMAT A12
COLUMN OPNAME FORMAT A16
COLUMN PROGRESS FORMAT A8
SELECT USERNAME,SID,OPNAME,ROUND(SOFAR*100 / TOTALWORK,0) || '%' AS PROGRESS,TIME_REMAINING,SQL_TEXT 
  FROM V$SESSION_LONGOPS , V$SQL 
 WHERE TIME_REMAINING <> 0 
   AND SQL_ADDRESS = ADDRESS 
   AND SQL_HASH_VALUE = HASH_VALUE;
```

## 10.6 检查消耗 CPU 最高的进程

```sql
SET VERIFY OFF
COLUMN SID FORMAT 999
COLUMN PID FORMAT 999
COLUMN S_# FORMAT 999
COLUMN USERNAME FORMAT A9 HEADING "ORA USER"
COLUMN PROGRAM FORMAT A29
COLUMN SQL FORMAT A60
COLUMN OSNAME FORMAT A9 HEADING "OS USER"
SELECT P.PID PID,S.SID SID,P.SPID SPID,S.USERNAME USERNAME,S.OSUSER OSNAME,
       P.SERIAL# S_#,P.TERMINAL,P.PROGRAM PROGRAM,P.BACKGROUND,S.STATUS,
       RTRIM(SUBSTR(A.SQL_TEXT, 1, 80)) SQL 
  FROM V$PROCESS P, V$SESSION S,V$SQLAREA A 
 WHERE P.ADDR = S.PADDR 
   AND S.SQL_ADDRESS = A.ADDRESS (+) 
   AND P.SPID LIKE '%&1%';
```

## 10.7 检查碎片程度高的表

```sql
SELECT segment_name table_name,COUNT(*) extents 
  FROM dba_segments 
 WHERE owner NOT IN ('SYS', 'SYSTEM') 
 GROUP BY segment_name 
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM dba_segments GROUP BY segment_name);
```

## 10.8 检查表空间的 I/O 比例

```sql
col file form a30
col name form a20
SELECT DF.TABLESPACE_NAME NAME,DF.FILE_NAME "FILE",F.PHYRDS PYR,
       F.PHYBLKRD PBR,F.PHYWRTS PYW, F.PHYBLKWRT PBW 
  FROM V$FILESTAT F, DBA_DATA_FILES DF 
 WHERE F.FILE# = DF.FILE_ID
 ORDER BY DF.TABLESPACE_NAME;
```

## 10.9 检查数据文件的 I/O 比例

```sql
SELECT SUBSTR(A.FILE#,1,2) "#", SUBSTR(A.NAME,1,30) "NAME",
       A.STATUS,A.BYTES,B.PHYRDS,B.PHYWRTS 
  FROM V$DATAFILE A,V$FILESTAT B 
 WHERE A.FILE# = B.FILE#;
```

## 10.10 检查死锁及处理

```sql
col sid for 999999
col username for a10
col schemaname for a10
col osuser for a16
col machine for a16
col terminal for a20
col owner for a10
col object_name for a30
col object_type for a10
select s.sid,s.serial#,p.spid,s.username,SCHEMANAME,osuser,
       MACHINE,s.terminal,s.PROGRAM,owner,object_name,
       object_type,o.object_id
  from dba_objects o,v$locked_object l,v$session s,v$process p
 where o.object_id=l.object_id 
   and s.sid=l.session_id
   and s.paddr = p.addr;
```

oracle 级 kill 掉该 session：

```sql
alter system kill session '&sid,&serial#';
```

操作系统级 kill 掉 session：
```bash
kill -9 spid
```

## 10.11 检查数据库 cpu、I/O、内存性能

记录数据库的 cpu 使用、IO、内存等使用情况，使用 vmstat,iostat,sar,top 等命令进行信息收集并检查这些信息，判断资源使用情况。

CPU 使用情况：

```bash
top
```

内存使用情况：

```bash
free -h
```

系统 I/O 情况：

```bash
iostat -k 1 3
```

系统负载情况：

```bash
uptime
```

## 10.12 检查行链接/迁移

```sql
select table_name,num_rows,chain_cnt From cdb_tables Where chain_cnt <> 0;
```

注：含有 long raw 列的表有行链接是正常的。

## 10.13 定期做统计分析

要定期对数据对象的统计信息进行采集更新，使优化器可以根据准备的信息作出正确的 explain plan。在以下情况更需要进行统计信息的更新。

查看表或索引的统计信息是否需更新，如：

```sql
Select table_name,num_rows,last_analyzed From dba_tables where owner || '.' || table_name ='';
select count(*) from TABLE_A;
```

如果行数相差很多,则该表需要更新统计信息如：

```sql
exec dbms_stats.gather_table_stats('owner','table');
```

一般来说优先根据count(*)和num_rows来判断统计信息是否准确，也可以根据最后一次收集的时间距离现在的长短来决定是否需要收集。

## 10.14 检查缓冲区命中率

```sql
SELECT a.VALUE + b.VALUE logical_reads, c.VALUE phys_reads,
       round(100*(1-c.value/(a.value+b.value)),4) hit_ratio
  FROM v$sysstat a,v$sysstat b,v$sysstat c
 WHERE a.NAME='db block gets'
   AND b.NAME='consistent gets'
   AND c.NAME='physical reads';
```

如果 OLTP 命中率低于 90% 则需加大数据库参数 db_cache_size。

## 10.15 检查共享池命中率

```sql
select sum(pinhits)/sum(pins) * 100 "% persents" from v$librarycache;
```

如低于 95%，则需要调整应用程序使用绑定变量，或者调整数据库参数shared pool 的大小。

## 10.16 检查排序区

```sql
select name,value from v$sysstat where name like '%sort%';
```

如果 disk/(memory+row)的比例过高，则需要调整 sort_area_size 或 pga_aggregate_target。

## 10.16 检查日志缓冲区

```sql
select name,value from v$sysstat where name in ('redo entries','redo buffer allocation retries');
```

如果 redo buffer allocation retries/redo entries 超过 1% ，则需要增大log_buffer。

# 11 备份检查

## 11.1 检查 rman 的配置

```sql
show all;
```
需要注意 retention policy 和 ARCHIVELOG DELETION POLICY。

## 11.2 检查备份集

```sql
set linesize 200
COL STATUS FORMAT a9
COL hrs FORMAT 999.99
SELECT SESSION_KEY, INPUT_TYPE, STATUS,
       TO_CHAR(START_TIME,'mm/dd/yy hh24:mi') start_time,
       TO_CHAR(END_TIME,'mm/dd/yy hh24:mi') end_time,
       ELAPSED_SECONDS/3600 hrs
  FROM V$RMAN_BACKUP_JOB_DETAILS
 ORDER BY SESSION_KEY;
```

## 11.3 检查坏块

```sql
select * from v$database_block_corruption;
```

## 11.4 检查需要备份的数据文件

```sql
RMAN> report need backup recovery window of 3 days;
RMAN> report need backup redundancy = 1;
```

## 11.5 检查 incarnation

```sql
RMAN> list incarnation;
```

Resetlogs命令表示一个数据库逻辑生存期的结束和另一个数据库逻辑生存期的开始，Oracle把这个数据库逻辑生存期称为incarnation；每次使用resetlogs打开数据库，就会使incarnation + 1，也就是产生一个新的incarnation；如果想要恢复到之前incarnation的scn/time，就需要先恢复到之前的incarnation。

## 11.6 检查无效备份

```sql
RMAN> crosscheck backup;
RMAN> list expired backup summary;
RMAN> list expired archivelog all;
```

## 11.7 检查过期的备份

```sql
RMAN> report obsolete;
```

# 12 检查系统安全日志信息

系统安全日志文件的目录在/var/log 下，主要检查登录成功或失败的用户日志信息。

检查登录成功的日志：

```bash
sudo grep -i accepted /var/log/secure
```

检查登录失败的日志：

```bash
sudo grep -i inval /var/log/secure && sudo grep -i failed /var/log/secure
```

# 13 其他检查

## 13.1 检查当前 crontab 任务是否正常

```bash
crontab -l
```

## 13.2 检查oracle job有无失败

```sql
select job,what,last_date,next_date,failures,broken from dba_jobs;
```

## 13.3 监控数据量的增长情况

```sql
col tablespace_name form a30
select A.con_id,A.tablespace_name,(1-(A.total)/B.total)*100 used_percent
  from (select con_id,tablespace_name,sum(bytes) total
 		  from cdb_free_space 
 	     group by con_id,tablespace_name) A,
	   (select con_id,tablespace_name,sum(bytes) total
		  from cdb_data_files
	     group by con_id,tablespace_name) B
 where A.tablespace_name=B.tablespace_name 
   and a.con_id=b.con_id 
 order by con_id;
 ```

根据本周内每天的检查情况找到空间扩展很快的数据库对象,并采取相应的措施：

- 删除历史数据，移动规定数据库中至少保留 6 个月的历史数据，所以以前的历史数据可以考虑备份然后进行清除以便释放其所占的资源空间。

- 扩表空间，添加数据文件。

注意：在数据库结构发生变化时，如增加了表空间，增加了数据文件或重做日志文件这些操作，都会造成 Oracle 数据库控制文件的变化，DBA 应及进行控制文件备份。

## 13.4 检查失效的索引

```sql
select owner,index_name,table_name,tablespace_name,status 
  From dba_indexes 
 Where status <> 'VALID'
   and status <> 'N/A';
```

注：分区表上的索引 status 为 N/A 是正常的，如有失效索引则对该索引做rebuild，如：

## 13.5 检查不起作用的约束

```sql
SELECT owner, constraint_name, table_name, constraint_type,
status FROM dba_constraints
 WHERE status ='DISABLE' and constraint_type='P';
```

如有失效约束则启用，如：

```sql
alter Table TABLE_NAME Enable Constraints CONSTRAINT_NAME;
```

## 13.6 检查无效的trigger

```sql
SELECT owner, trigger_name, table_name, status FROM cdb_triggers WHERE status = 'DISABLED';
```

如有失效触发器则启用，如：

```sql
alter Trigger TRIGGER_NAME Enable;
```

注：系统用户的触发器失效可能是版本升级造成的。