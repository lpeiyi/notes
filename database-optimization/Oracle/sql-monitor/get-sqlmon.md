**目录**

[toc]

# 1 SQL Monitor介绍

SQL Monitor 的应用场景主要针对可能存在性能瓶颈的 SQL 进行监控和分析，调用`dbms_sqltune.report_sql_monitor`可以获得相应 SQL 的 HTML 报告。

当 SQL 的执行时间超过5秒，会被 SQL Monitor 自动列为监控对象，并会被记录在 v$sql_monitor 视图中。当表开启并行查询时，也会被 SQL Monitor 记录。SQL Monitor 的报告功能很容易上手。

使用时有两种形式，一种是指定 SID，另一种是指定存在问题的 SQL_ID。我们可以通过查询 v$sql_monitor 视图，检查有哪些慢 SQL 被 SQL Monitor 列入监控。

**参考官方文档：**[SQL Monitor Reports](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/monitoring-database-operations.html#GUID-4048D00E-2635-42C8-A37D-71EFAC619062)

# 2 获取SQL Monitor Reports

## 方法1

```sql
select /*+monitor*/* from t a where object_name like 'WD%' and  1=2  and exists (select 1 from t b where a.object_id=b.object_id)

select sql_id,sql_text from v$sql where sql_text like '%monitor%';

SELECT dbms_sqltune.report_sql_monitor(sql_id=>'agvpq597x4u2w',TYPE=>'HTML') FROM DUAL;  --也支持TEXT、XML、ACTIVE等模式
```

## 方法2

1. 调整窗口
    ```sql
    col status for a15 
    col username for a10 
    col module for a12 
    col program for a12 
    col sql_id for a15 
    col sql_text for a50 
    set pagesize 0 
    set linesize 200 
    col sid for 999999
    ```
2. 查询被SQL Monitor列入监控的慢SQL 
    ```sql
    select status,username, module,program, sid, sql_id, sql_text from v$sql_monitor;  
    ```

3. 调整窗口
    ```sql
    set trimspool on 
    set arraysize 512 
    set trim on 
    set pagesize 0 
    set linesize 1000 
    set long 1000000 
    set longchunksize 1000000 
    ```
4. 生成SQLMON-HTML报告
    ```sql
    spool active_sqlmon.html
    select dbms_sqltune.report_sql_monitor(sql_id       => '1cg9h05uqz1sn',
                                          report_level => 'ALL',
                                          type         => 'ACTIVE')
      from dual;
    spool off 
    ```

参考report：[long_sql.htm](long_sql.htm)
