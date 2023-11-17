```sql
LU9UP@XE()> --创建表
LU9UP@XE()> create table demo as select * from dba_objects;

表已创建。

LU9UP@XE()> --创建index
LU9UP@XE()> create index idx_demo_id on demo(object_id);

索引已创建。

LU9UP@XE()> --收集统计信息
LU9UP@XE()> exec dbms_stats.gather_table_stats('lu9up','demo',cascade=>true);

PL/SQL 过程已成功完成。

LU9UP@XE()> --查询，默认走index
LU9UP@XE()> select object_name from demo where object_id = 99;

执行计划
----------------------------------------------------------
Plan hash value: 952584116

-------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             |     1 |    25 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| DEMO        |     1 |    25 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_DEMO_ID |     1 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("OBJECT_ID"=99)

统计信息
----------------------------------------------------------
          1  recursive calls
          0  db block gets
          4  consistent gets
          0  physical reads
          0  redo size
        543  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed

LU9UP@XE()> --hint
LU9UP@XE()> select /*+ full(demo) */ object_name from demo where object_id = 99;

执行计划
----------------------------------------------------------
Plan hash value: 4000794843

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    25 |    74   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| DEMO |     1 |    25 |    74   (0)| 00:00:01 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("OBJECT_ID"=99)

统计信息
----------------------------------------------------------
          1  recursive calls
          0  db block gets
        257  consistent gets
          0  physical reads
          0  redo size
        543  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed

LU9UP@XE()> --查找hint对应的sql_id
LU9UP@XE()> select sql_id,sql_text from v$sql where sql_text like '%select /*+ full(demo) */ object_name from demo%'
;

执行计划
----------------------------------------------------------
Plan hash value: 903671040

--------------------------------------------------------------------------------------
| Id  | Operation        | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |                   |     1 |   523 |     0   (0)| 00:00:01 |
|*  1 |  FIXED TABLE FULL| X$KGLCURSOR_CHILD |     1 |   523 |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("KGLNAOBJ" IS NOT NULL AND "KGLNAOBJ" LIKE '%select /*+
              full(demo) */ object_name from demo%' AND "INST_ID"=USERENV('INSTANCE'))

统计信息
----------------------------------------------------------
        368  recursive calls
          0  db block gets
         75  consistent gets
          2  physical reads
          0  redo size
        986  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
         12  sorts (memory)
          0  sorts (disk)
          3  rows processed

LU9UP@XE()> set autotrace off;
LU9UP@XE()> --查找hint对应的sql_id
LU9UP@XE()> select sql_id,sql_text from v$sql where sql_text like '%select /*+ full(demo) */ object_name from demo where object_id = 99%';

SQL_ID
--------------------------
SQL_TEXT
------------------------------------------------------------------------------------------------------------------
1pv82jqjpsy3b
select /*+ full(demo) */ object_name from demo where object_id = 99

LU9UP@XE()> select * from table(dbms_xplan.display_cursor('1pv82jqjpsy3b',null,'outline'));

PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------
SQL_ID  1pv82jqjpsy3b, child number 0
-------------------------------------
select /*+ full(demo) */ object_name from demo where object_id = 99

Plan hash value: 4000794843

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |       |       |    74 (100)|          |
|*  1 |  TABLE ACCESS FULL| DEMO |     1 |    25 |    74   (0)| 00:00:01 |
--------------------------------------------------------------------------

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('11.2.0.2')
      DB_VERSION('11.2.0.2')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "DEMO"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("OBJECT_ID"=99)

已选择32行。

LU9UP@XE()> --创建SQL profile
LU9UP@XE()>
declare
  v_hints sys.sqlprof_attr;
begin
  v_hints := sys.sqlprof_attr('FULL(@"SEL$1" "DEMO"@"SEL$1")');
  dbms_sqltune.import_sql_profile('select object_name from demo where object_id = 99',
                                  v_hints,
                                  'SQLprofile_demo',
                                  force_match => true,
                                  replace => true);
end;
/

PL/SQL 过程已成功完成。


```