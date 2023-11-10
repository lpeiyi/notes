SQL Monitor 的应用场景主要针对可能存在性能瓶颈的 SQL 进行监控和分析，调用 dbms_sqltune.report_sql_monitor 可以获得相应 SQL 的 HTML 报告。
当 SQL 的执行时间超过 5 秒，会被 SQL Monitor 自动列为监控对象，并会被记录在 v$sql_monitor 视图中。当表开启并行查询时，也会被 SQL Monitor 记录。
SQL Monitor 的报告功能很容易上手。使用时有两种形式，一种是指定 SID，另一种是指定存在问题的SQL_ID。我们可以通过查询 v$sql_monitor 视图，检查有哪些慢 SQL被SQL Monitor 列入监控。

--SQL Monitor 列入监控
col status for a15
col username for a10
col module for a12
col program for a12
col sql_id for a15
col sql_text for a50
set pagesize 0
set linesize 200
col sid for 999999
select status, username, module, program, sid, sql_id, sql_text from v$sql_monitor;

--对指定的 SQL_ID 进行分析：
set trimspool on
set arraysize 512
set trim on
set pagesize 0
set linesize 1000
set long 1000000
set longchunksize 1000000

spool active_sqlmon.html
select dbms_sqltune.report_sql_monitor(sql_id       => '1cg9h05uqz1sn',
                                       report_level => 'ALL',
                                       type         => 'ACTIVE')
  from dual;
spool off


select /*+ noparallel */
 dbms_sqltune.report_sql_monitor(session_id   => 8651,
                                 report_level => 'ALL',
                                 type         => 'HTML')
  from dual;
