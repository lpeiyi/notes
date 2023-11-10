--无任何索引的情况，全表扫描
SCOTT@XE()> select object_id, owner, table_name, initial_extent, next_extent, last_analyzed
  2    from demo1 a
  3   where 65536 between initial_extent and next_extent
  4     and substr(a.owner,-3,3) = 'SYS'
  5   order by last_analyzed;
已选择887行。
执行计划
----------------------------------------------------------
Plan hash value: 3686347828
---------------------------------------------------------------------------
| Id  | Operation          | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |       |     1 |    44 |    21   (5)| 00:00:01 |
|   1 |  SORT ORDER BY     |       |     1 |    44 |    21   (5)| 00:00:01 |
|*  2 |   TABLE ACCESS FULL| DEMO1 |     1 |    44 |    20   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - filter("INITIAL_EXTENT"<=65536 AND
              SUBSTR("A"."OWNER",-3,3)='SYS' AND "NEXT_EXTENT">=65536)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
         70  consistent gets
          0  physical reads
          0  redo size
      36767  bytes sent via SQL*Net to client
       1172  bytes received via SQL*Net from client
         61  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
        887  rows processed

--区间检索的字段创建组合索引，一致性读增加，从IO看，这是妥妥的负优化
SCOTT@XE()> create index idx_demo1 on demo1(initial_extent,next_extent);
索引已创建。
SCOTT@XE()> analyze table demo1 estimate statistics;
表已分析。
SCOTT@XE()> select object_id, owner, table_name, initial_extent, next_extent, last_analyzed
  2    from demo1 a
  3   where 65536 between initial_extent and next_extent
  4     and substr(a.owner,-3,3) = 'SYS'
  5   order by last_analyzed;
已选择887行。
执行计划
----------------------------------------------------------
Plan hash value: 408429385
------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |     1 |    44 |    11  (10)| 00:00:01 |
|   1 |  SORT ORDER BY               |           |     1 |    44 |    11  (10)| 00:00:01 |
|*  2 |   TABLE ACCESS BY INDEX ROWID| DEMO1     |     1 |    44 |    10   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | IDX_DEMO1 |   132 |       |     2   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - filter(SUBSTR("A"."OWNER",-3,3)='SYS')
   3 - access("NEXT_EXTENT">=65536 AND "INITIAL_EXTENT"<=65536)
       filter("NEXT_EXTENT">=65536)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
         83  consistent gets
          0  physical reads
          0  redo size
      36725  bytes sent via SQL*Net to client
       1172  bytes received via SQL*Net from client
         61  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
        887  rows processed

SCOTT@XE()> drop index idx_demo1;
索引已删除。

--引导列owner使用了函数，被限制使用索引，IO消耗翻了4倍
SCOTT@XE()> create index idx_demo2 on demo1(owner,initial_extent,next_extent,last_analyzed);
索引已创建。
SCOTT@XE()> analyze table demo1 estimate statistics;
表已分析。
SCOTT@XE()> select object_id, owner, table_name, initial_extent, next_extent, last_analyzed
  2    from demo1 a
  3   where 65536 between initial_extent and next_extent
  4     and substr(a.owner,-3,3) = 'SYS'
  5   order by last_analyzed;
已选择887行。
执行计划
----------------------------------------------------------
Plan hash value: 4090542941
------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |     1 |    44 |    13   (8)| 00:00:01 |
|   1 |  SORT ORDER BY               |           |     1 |    44 |    13   (8)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEMO1     |     1 |    44 |    12   (0)| 00:00:01 |
|*  3 |    INDEX SKIP SCAN           | IDX_DEMO2 |     1 |       |    11   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   3 - access("NEXT_EXTENT">=65536 AND "INITIAL_EXTENT"<=65536)
       filter("INITIAL_EXTENT"<=65536 AND SUBSTR("A"."OWNER",-3,3)='SYS' AND
              "NEXT_EXTENT">=65536)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        318  consistent gets
          0  physical reads
          0  redo size
      36746  bytes sent via SQL*Net to client
       1172  bytes received via SQL*Net from client
         61  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
        887  rows processed
		
SCOTT@XE()> drop index idx_demo2;
索引已删除。

--性能比较好，IO不变，回表次数减少了，开销也减少了
SCOTT@XE()> create index idx_demo3 on demo1(substr(owner,-3,3),initial_extent,next_extent,last_analyzed);
索引已创建。
SCOTT@XE()> analyze table demo1 estimate statistics;
表已分析。
SCOTT@XE()> select object_id, owner, table_name, initial_extent, next_extent, last_analyzed
  2    from demo1 a
  3   where 65536 between initial_extent and next_extent
  4     and substr(a.owner,-3,3) = 'SYS'
  5   order by last_analyzed;
已选择887行。
执行计划
----------------------------------------------------------
Plan hash value: 3909865206
------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |    12 |   564 |     7  (15)| 00:00:01 |
|   1 |  SORT ORDER BY               |           |    12 |   564 |     7  (15)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEMO1     |    12 |   564 |     6   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | IDX_DEMO3 |    12 |       |     2   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   3 - access(SUBSTR("OWNER",-3,3)='SYS' AND "NEXT_EXTENT">=65536 AND
              "INITIAL_EXTENT"<=65536)
       filter("NEXT_EXTENT">=65536)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
         70  consistent gets
          0  physical reads
          0  redo size
      36767  bytes sent via SQL*Net to client
       1172  bytes received via SQL*Net from client
         61  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
        887  rows processed
		
SCOTT@XE()> drop index idx_demo3;
索引已删除。

--性能比较好，IO不变，回表次数减少了，开销也减少了
SCOTT@XE()> create index idx_demo4 on demo1(substr(owner,-3,3),next_extent,initial_extent,last_analyzed);
索引已创建。
SCOTT@XE()> analyze table demo1 estimate statistics;
表已分析。
SCOTT@XE()> select object_id, owner, table_name, initial_extent, next_extent, last_analyzed
  2    from demo1 a
  3   where 65536 between initial_extent and next_extent
  4     and substr(a.owner,-3,3) = 'SYS'
  5   order by last_analyzed;
已选择887行。
执行计划
----------------------------------------------------------
Plan hash value: 26126847
------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |    12 |   564 |     7  (15)| 00:00:01 |
|   1 |  SORT ORDER BY               |           |    12 |   564 |     7  (15)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEMO1     |    12 |   564 |     6   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | IDX_DEMO4 |    12 |       |     2   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   3 - access(SUBSTR("OWNER",-3,3)='SYS' AND "NEXT_EXTENT">=65536 AND
              "NEXT_EXTENT" IS NOT NULL)
       filter("INITIAL_EXTENT"<=65536)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
         70  consistent gets
          0  physical reads
          0  redo size
      36767  bytes sent via SQL*Net to client
       1172  bytes received via SQL*Net from client
         61  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
        887  rows processed
		
SCOTT@XE()> drop index idx_demo4;
索引已删除。

--排序字段为引导列，但是谓词条件没有这个字段，索引走索引全扫描，比索引范围扫描性能略低
SCOTT@XE()> create index idx_demo5 on demo1(last_analyzed,substr(owner,-3,3),next_extent,initial_extent);
索引已创建。
SCOTT@XE()> analyze table demo1 estimate statistics;
表已分析。
SCOTT@XE()> select object_id, owner, table_name, initial_extent, next_extent, last_analyzed
  2    from demo1 a
  3   where 65536 between initial_extent and next_extent
  4     and substr(a.owner,-3,3) = 'SYS'
  5   order by last_analyzed;
已选择887行。
执行计划
----------------------------------------------------------
Plan hash value: 2510936412
-----------------------------------------------------------------------------------------
| Id  | Operation                   | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |           |    12 |   564 |    15   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| DEMO1     |    12 |   564 |    15   (0)| 00:00:01 |
|*  2 |   INDEX FULL SCAN           | IDX_DEMO5 |    12 |       |    10   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - access(SUBSTR("OWNER",-3,3)='SYS' AND "NEXT_EXTENT">=65536 AND
              "INITIAL_EXTENT"<=65536)
       filter("INITIAL_EXTENT"<=65536 AND SUBSTR("OWNER",-3,3)='SYS' AND
              "NEXT_EXTENT">=65536)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
         70  consistent gets
          0  physical reads
          0  redo size
      36767  bytes sent via SQL*Net to client
       1172  bytes received via SQL*Net from client
         61  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
        887  rows processed

SCOTT@XE()> drop index idx_demo5;
索引已删除。

--性能比5好，回表做filter少了一点
SCOTT@XE()> create index idx_demo6 on demo1(substr(owner,-3,3),last_analyzed,next_extent,initial_extent);
索引已创建。
SCOTT@XE()> analyze table demo1 estimate statistics;
表已分析。
SCOTT@XE()> select object_id, owner, table_name, initial_extent, next_extent, last_analyzed
  2    from demo1 a
  3   where 65536 between initial_extent and next_extent
  4     and substr(a.owner,-3,3) = 'SYS'
  5   order by last_analyzed;
已选择887行。
执行计划
----------------------------------------------------------
Plan hash value: 4237677476
-----------------------------------------------------------------------------------------
| Id  | Operation                   | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |           |    12 |   564 |     7   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| DEMO1     |    12 |   564 |     7   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_DEMO6 |    12 |       |     2   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - access(SUBSTR("OWNER",-3,3)='SYS' AND "NEXT_EXTENT">=65536 AND
              "INITIAL_EXTENT"<=65536)
       filter("INITIAL_EXTENT"<=65536 AND "NEXT_EXTENT">=65536)

统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
         70  consistent gets
          0  physical reads
          0  redo size
      36767  bytes sent via SQL*Net to client
       1172  bytes received via SQL*Net from client
         61  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
        887  rows processed