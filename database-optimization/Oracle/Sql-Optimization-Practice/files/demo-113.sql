----------------------------------------------------------------------------------------------------
--------------------------------------------- 创建测试表 -------------------------------------------
----------------------------------------------------------------------------------------------------
create table demo as select * from dba_objects;

----------------------------------------------------------------------------------------------------
--------------------------------------------- 常规写法 ---------------------------------------------
----------------------------------------------------------------------------------------------------
select a.owner, a.object_name, a.object_id
  from demo a,
       (select owner, max(object_id) object_id from demo group by owner) b
 where a.owner = b.owner
   and a.object_id = b.object_id;
   
26 rows selected.
Execution Plan
----------------------------------------------------------
Plan hash value: 2353854835
-----------------------------------------------------------------------------
| Id  | Operation	   		 | Name | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   	 |	    |	 26 |  3224 |	787   (1)| 00:00:01 |
|*  1 |  HASH JOIN	    	 |	    |	 26 |  3224 |	787   (1)| 00:00:01 |
|   2 |   VIEW		    	 |	    |	 26 |  2054 |	395   (2)| 00:00:01 |
|   3 |    HASH GROUP BY     |	    |	 26 |	260 |	395   (2)| 00:00:01 |
|   4 |     TABLE ACCESS FULL| DEMO | 72401 |	707K|	392   (1)| 00:00:01 |
|   5 |   TABLE ACCESS FULL  | DEMO | 72401 |  3181K|	392   (1)| 00:00:01 |
-----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("A"."OWNER"="B"."OWNER" AND
	      "A"."OBJECT_ID"="B"."OBJECT_ID")
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
   2824  consistent gets
	  0  physical reads
	  0  redo size
   1804  bytes sent via SQL*Net to client
	563  bytes received via SQL*Net from client
	  3  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	 26  rows processed
	 
----------------------------------------------------------------------------------------------------
--------------------------------------------- 优化1 ------------------------------------------------
--写法不变，创建联合索引
----------------------------------------------------------------------------------------------------
create index idx_demo_combined on demo(owner,object_id) nologging;

select a.owner, a.object_name, a.object_id
  from demo a,
       (select owner, max(object_id) object_id from demo group by owner) b
 where a.owner = b.owner
   and a.object_id = b.object_id;

26 rows selected.
Execution Plan
----------------------------------------------------------
Plan hash value: 1457667109
--------------------------------------------------------------------------------------------------
| Id  | Operation		    	 | Name				 | Rows  | Bytes | Cost (%CPU)| Time	 |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	     |					 |    15 |  1830 |   425   (1)| 00:00:01 |
|   1 |  NESTED LOOPS		     |					 |    15 |  1830 |   425   (1)| 00:00:01 |
|   2 |   NESTED LOOPS		     |					 |    15 |  1830 |   425   (1)| 00:00:01 |
|   3 |    VIEW 		   		 |					 |    15 |  1185 |   395   (2)| 00:00:01 |
|   4 |     HASH GROUP BY	     |					 |    15 |   120 |   395   (2)| 00:00:01 |
|   5 |      TABLE ACCESS FULL	 | DEMO				 | 73989 |   578K|   392   (1)| 00:00:01 |
|*  6 |    INDEX RANGE SCAN	     | IDX_DEMO_COMBINED |     1 |		 |     1   (0)| 00:00:01 |
|   7 |   TABLE ACCESS BY INDEX ROWID| DEMO			 |     1 |    43 |     2   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   6 - access("A"."OWNER"="B"."OWNER" AND "A"."OBJECT_ID"="B"."OBJECT_ID")
Note
-----
   - this is an adaptive plan
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
   1466  consistent gets
	  0  physical reads
	  0  redo size
   1804  bytes sent via SQL*Net to client
	563  bytes received via SQL*Net from client
	  3  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	 26  rows processed

	 
----------------------------------------------------------------------------------------------------
--------------------------------------------- 优化2 ------------------------------------------------
--改写SQL，使用分析函数，不需要创建索引（建议写法）
----------------------------------------------------------------------------------------------------
select t.owner, t.object_name, t.object_id
  from (select owner,
               object_name,
               object_id,
               row_number() over(partition by owner order by object_id desc) rk
          from demo) t
 where t.rk = 1;

26 rows selected.
Execution Plan
----------------------------------------------------------
Plan hash value: 1766530486
-----------------------------------------------------------------------------------------
| Id  | Operation				 | Name | Rows	| Bytes |TempSpc| Cost (%CPU)| Time	|
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT		 |		| 73989 |    11M|		|  1207   (1)| 00:00:01 |
|*  1 |  VIEW					 |		| 73989 |    11M|		|  1207   (1)| 00:00:01 |
|*  2 |   WINDOW SORT PUSHED RANK|		| 73989 |  3106K|  4096K|  1207   (1)| 00:00:01 |
|   3 |    TABLE ACCESS FULL	 | DEMO | 73989 |  3106K|		|   392   (1)| 00:00:01 |
-----------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - filter("T"."RK"=1)
   2 - filter(ROW_NUMBER() OVER ( PARTITION BY "OWNER" ORDER BY
	      INTERNAL_FUNCTION("OBJECT_ID") DESC )<=1)

Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
   1412  consistent gets
	  0  physical reads
	  0  redo size
   1779  bytes sent via SQL*Net to client
	610  bytes received via SQL*Net from client
	  3  SQL*Net roundtrips to/from client
	  1  sorts (memory)
	  0  sorts (disk)
	 26  rows processed