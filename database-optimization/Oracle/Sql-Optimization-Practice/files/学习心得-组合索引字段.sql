----------------------------------------------------------------------------
--------------------------------- 总结 -----------------------------------
----------------------------------------------------------------------------
0.在 Oracle 执行计划中，Predicate Information 是关于查询中使用的条件的详细信息。它通常包含两个关键部分：filter 和 access。
Filter(过滤器)：Filter 是指在存储访问方法(如表扫描或索引扫描)之后应用的条件。Filter 中的条件不会改变存储访问方法的选择，而是在数据被检索后，对结果进行过滤。例如，如果你在查询中有一个 WHERE 子句，那么 Filter 部分就会显示这个 WHERE 子句的条件。
Access(访问方法)：Access 是指用于检索数据的存储访问方法。它描述了如何访问和检索数据，如全表扫描(Full)、索引扫描(Index)、嵌套循环(Nested Loops)、哈希连接(Hash Join)等。Access 部分还显示了哪些索引或访问方法被使用来检索数据。
简单说，执行计划如果显示是access，就表示这个谓词条件的值将会影响数据的访问路径(表还是索引)，而filter表示谓词条件的值并不会影响数据访问路径，只起到过滤结果集的作用。
1.全部字段生效时，走索引范围扫描，组合索引字段不会做filter（第46行）；
2.当不是全部字段都生效时，使用什么索引扫描方式视引导列(组合索引的第一个字段)的情况而定：
 2.1 当引导列生效时，一般走索引范围扫描；
 2.2 当引导列不生效时，一般走索引全扫描或索引跳跃扫描。当引导列的值重复度较高，且引导列索引未生效，走索引跳跃扫描（第524行）。反之，走索引全扫描；
3.谓词条件不含索引列，欲用索引列order by排序，但未走索引:
 3.1 索引列要限定not null才生效，谓词条件添加任意索引列is not null或索引列加not null约束，普通索引也适用（第555行）；
 3.2 既然索引扫描返回的结果有顺，为什么还要用order by语句？因为索引可能会失效，为了保证结果是有序的，所以尽可能加上order by；
4.组合索引排序场景：
 4.1如果经过where条件过滤后返回的结果集比较小, 索引不包含order by字段, 做个排序也没关系; 
 4.2如果过滤条件都是等值条件,而且返回的结果集有点大, 为了避免排序, order by字段确实是放到最后; 
 4.3如果过滤条件含有非等值条件, 比如>,< , like , <> 等, 这个时候order by 字段就不是最后,而是非等值条件放到最后(减少回表) , 这种组合索引的创建原理叫ESR(equal,sort,range)理论;
 4.4如果返回列较少,可以再把返回列加上,成ESRR,那就是在组合索引的最后增加返回列，形成覆盖索引, 能进一步减少回表。   


----------------------------------------------------------------------------
--------------------------------- 表记录 -----------------------------------
--建表语句在最后
----------------------------------------------------------------------------
LU@pdb1(PDB1)> select * FROM lu.demo;
COL1 COL2 COL3
---- ---- ----
a    b    c
a    b    e
a    f    g
b    h    i
b    j    k
b    j    m

LU@pdb1(PDB1)> select * from demo1;
COL1 COL2 COL3
--   --   -- 
     c    d
x    b    c 
y    b    e 
y    f    g 
y    b    f 

----------------------------------------------------------------------------
--------------------------------- 索引字段 ---------------------------------
----------------------------------------------------------------------------
SCOTT@XE()> SELECT INDEX_NAME,
  2         LISTAGG(COLUMN_NAME, ', ') WITHIN GROUP(ORDER BY COLUMN_POSITION) COLUMN_NAME
  3    FROM DBA_IND_COLUMNS A
  4   WHERE A.TABLE_NAME in('DEMO','DEMO1')
  5     AND A.TABLE_OWNER = 'LU'
  6   GROUP BY INDEX_NAME;

INDEX_NAME      COLUMN_NAME
--------------  --------------------
PK_DEMO         COL1, COL2, COL3
PK_DEMO1        COL1, COL2, COL3

----------------------------------------------------------------------------
-------------------------------1)全部字段生效 ------------------------------
----------------------------------------------------------------------------
SELECT a.*
  FROM lu.demo1 a
 where col1 = 'a'
   and col2 = 'b'
   and col3 = 'c';
Execution Plan
----------------------------------------------------------
Plan hash value: 3293442503
----------------------------------------------------------------------------
| Id  | Operation	 	 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	  	   |	 1 |	 9 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| PK_DEMO |	 1 |	 9 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL1"='a' AND "COL2"='b' AND "COL3"='c')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	697  bytes sent via SQL*Net to client
	443  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

----------------------------------------------------------------------------
-------------------------------2)仅一个字段生效 ------------------------------
----------------------------------------------------------------------------
-------- 仅1字段生效
-------------------
SELECT a.*
  FROM lu.demo a
 where col1 = 'a';
Execution Plan
----------------------------------------------------------
Plan hash value: 3293442503
----------------------------------------------------------------------------
| Id  | Operation		 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	  	   |	 3 |	27 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| PK_DEMO |	 3 |	27 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL1"='a')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	763  bytes sent via SQL*Net to client
	407  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  3  rows processed
	  
SCOTT@XE()>
SELECT a.*
  FROM lu.demo a
 where col1 = 'a'
   and upper(col2) = 'B'
   and upper(col3) = 'C';
Execution Plan
----------------------------------------------------------
Plan hash value: 3293442503

----------------------------------------------------------------------------
| Id  | Operation		 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	  	   |	 1 |	 9 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| PK_DEMO |	 1 |	 9 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL1"='a')
       filter(UPPER("COL2")='B' AND UPPER("COL3")='C')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	697  bytes sent via SQL*Net to client
	457  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed
-------------------
-------- 仅2字段生效
-------------------
SELECT a.*
  FROM lu.demo a
 where col2 = 'b';
Execution Plan
----------------------------------------------------------
Plan hash value: 3116077841
----------------------------------------------------------------------------
| Id  | Operation	 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	   |	 2 |	18 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX FULL SCAN | PK_DEMO |	 2 |	18 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL2"='b')
       filter("COL2"='b')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	754  bytes sent via SQL*Net to client
	407  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  2  rows processed

SCOTT@XE()>
SELECT a.*
  FROM lu.demo a
 where upper(col1) = 'A'
   and col2 = 'b'
   and upper(col3) = 'C';
Execution Plan
----------------------------------------------------------
Plan hash value: 3116077841
----------------------------------------------------------------------------
| Id  | Operation		 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	 	   |	 1 |	 9 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX FULL SCAN | PK_DEMO |	 1 |	 9 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL2"='b')
       filter("COL2"='b' AND UPPER("COL1")='A' AND UPPER("COL3")='C')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	697  bytes sent via SQL*Net to client
	457  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed
-------------------
-------- 仅3字段生效
-------------------
SELECT a.*
  FROM lu.demo a
 where col3 = 'c';
Execution Plan
----------------------------------------------------------
Plan hash value: 3116077841
----------------------------------------------------------------------------
| Id  | Operation		 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	 	   |	 1 |	 9 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX FULL SCAN | PK_DEMO |	 1 |	 9 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL3"='c')
       filter("COL3"='c')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	697  bytes sent via SQL*Net to client
	407  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

SCOTT@XE()>
SELECT a.*
  FROM lu.demo a
 where upper(col1) = 'A'
   and upper(col2) = 'B'
   and col3 = 'c';
Execution Plan
----------------------------------------------------------
Plan hash value: 3116077841
----------------------------------------------------------------------------
| Id  | Operation	 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	   |	 1 |	 9 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX FULL SCAN | PK_DEMO |	 1 |	 9 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL3"='c')
       filter("COL3"='c' AND UPPER("COL1")='A' AND UPPER("COL2")='B')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	697  bytes sent via SQL*Net to client
	457  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

----------------------------------------------------------------------------
------------------------------3)两个字段生效 -------------------------------
----------------------------------------------------------------------------
------- 1,2字段生效
-------------------
SELECT a.*
  FROM lu.demo a
 where col1 = 'a'
   and col2 = 'b';
Execution Plan
----------------------------------------------------------
Plan hash value: 3293442503

----------------------------------------------------------------------------
| Id  | Operation		 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	  	   |	 2 |	18 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| PK_DEMO |	 2 |	18 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL1"='a' AND "COL2"='b')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	754  bytes sent via SQL*Net to client
	425  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  2  rows processed
		  
SCOTT@XE()>
SELECT a.*
  FROM lu.demo a
 where col1 = 'a'
   and col2 = 'b'
   and upper(col3) = 'C';
Execution Plan
----------------------------------------------------------
Plan hash value: 3293442503
----------------------------------------------------------------------------
| Id  | Operation		 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	   	   |	 1 |	 9 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| PK_DEMO |	 1 |	 9 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL1"='a' AND "COL2"='b')
       filter(UPPER("COL3")='C')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	697  bytes sent via SQL*Net to client
	450  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

-------------------
------- 1,3字段生效
-------------------
SELECT a.*
  FROM lu.demo a
 where col1 = 'a'
   and col3 = 'c';
Execution Plan
----------------------------------------------------------
Plan hash value: 3293442503

----------------------------------------------------------------------------
| Id  | Operation	 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	   |	 1 |	 9 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| PK_DEMO |	 1 |	 9 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL1"='a' AND "COL3"='c')
       filter("COL3"='c')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	697  bytes sent via SQL*Net to client
	425  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

SCOTT@XE()>
SELECT a.*
  FROM lu.demo a
 where col1 = 'a'
   and upper(col2) = 'B'
   and col3 = 'c';
Execution Plan
----------------------------------------------------------
Plan hash value: 3293442503
----------------------------------------------------------------------------
| Id  | Operation	 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	   |	 1 |	 9 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| PK_DEMO |	 1 |	 9 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL1"='a' AND "COL3"='c')
       filter("COL3"='c' AND UPPER("COL2")='B')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	697  bytes sent via SQL*Net to client
	450  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

-------------------
------- 2,3字段生效
-------------------
SELECT a.*
  FROM lu.demo a
 where col2 = 'b'
   and col3 = 'c';
Execution Plan
----------------------------------------------------------
Plan hash value: 3116077841
----------------------------------------------------------------------------
| Id  | Operation		 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	 	   |	 1 |	 9 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX FULL SCAN | PK_DEMO |	 1 |	 9 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL2"='b' AND "COL3"='c')
       filter("COL2"='b' AND "COL3"='c')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	697  bytes sent via SQL*Net to client
	425  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

SCOTT@XE()>
SELECT a.*
  FROM lu.demo a
 where upper(col1) = 'A'
   and col2 = 'b'
   and col3 = 'c';
Execution Plan
----------------------------------------------------------
Plan hash value: 3116077841
----------------------------------------------------------------------------
| Id  | Operation	 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	   |	 1 |	 9 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX FULL SCAN | PK_DEMO |	 1 |	 9 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL2"='b' AND "COL3"='c')
       filter("COL2"='b' AND "COL3"='c' AND UPPER("COL1")='A')
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	697  bytes sent via SQL*Net to client
	450  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

----------------------------------------------------------------------------
------------------------------- 4)特殊情况 ---------------------------------
----------------------------------------------------------------------------	  
--1 索引跳跃扫描：引导列的值在表中的重复度较高，且谓词条件中引导列不生效
--------------------------------
U@pdb1(PDB1)> select * from demo1 where col2 = 'b';
Execution Plan
----------------------------------------------------------
Plan hash value: 490950505
-----------------------------------------------------------------------------
| Id  | Operation	 | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	    |	  2 |	  6 |	  1   (0)| 00:00:01 |
|*  1 |  INDEX SKIP SCAN | PK_DEMO1 |	  2 |	  6 |	  1   (0)| 00:00:01 |
-----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("COL2"='b')
       filter("COL2"='b')
Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
	  2  consistent gets
	  0  physical reads
	  0  redo size
	761  bytes sent via SQL*Net to client
	398  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  3  rows processed

--------------------
--2 用索引列（索引全扫描）排序，但未走索引。列要限定not null才生效，加is not null谓词条件或加not null约束，普通索引也适用
--------------------
--全表扫描
select * from demo order by col1;
Execution Plan
----------------------------------------------------------
Plan hash value: 903288357
---------------------------------------------------------------------------
| Id  | Operation	   | Name | Rows  | Bytes | Cost (%CPU)| Time	  |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |	  |	6 |    78 |	4  (25)| 00:00:01 |
|   1 |  SORT ORDER BY	   |	  |	6 |    78 |	4  (25)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| DEMO |	6 |    78 |	3   (0)| 00:00:01 |
---------------------------------------------------------------------------

--添加谓词条件
LU@pdb1(PDB1)>
select * from demo where col1 is not null order by col1;
Execution Plan
----------------------------------------------------------
Plan hash value: 3116077841
----------------------------------------------------------------------------
| Id  | Operation	 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	   |	 6 |	78 |	 1   (0)| 00:00:01 |
|*  1 |  INDEX FULL SCAN | PK_DEMO |	 6 |	78 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------

--添加约束
LU@pdb1(PDB1)> alter table demo modify col1 not null;
Table altered.
LU@pdb1(PDB1)> select * from demo order by col1;
6 rows selected.
Execution Plan
----------------------------------------------------------
Plan hash value: 3116077841
----------------------------------------------------------------------------
| Id  | Operation	 | Name    | Rows  | Bytes | Cost (%CPU)| Time	   |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |	   |	 6 |	78 |	 1   (0)| 00:00:01 |
|   1 |  INDEX FULL SCAN | PK_DEMO |	 6 |	78 |	 1   (0)| 00:00:01 |
----------------------------------------------------------------------------

--------------------
--3 order by 组合索引字段选择性能比较
--------------------
SCOTT@XE()> select * from demo where col1 is not null order by col1;
执行计划
----------------------------------------------------------
Plan hash value: 3116077841
----------------------------------------------------------------------------
| Id  | Operation        | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |         |     5 |    15 |     1   (0)| 00:00:01 |
|*  1 |  INDEX FULL SCAN | PK_DEMO |     5 |    15 |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - filter("COL1" IS NOT NULL)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          2  consistent gets
          0  physical reads
          0  redo size
        749  bytes sent via SQL*Net to client
        523  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          5  rows processed
		  
SCOTT@XE()> select * from demo where col1 is not null order by col3;
执行计划
----------------------------------------------------------
Plan hash value: 2902563701
----------------------------------------------------------------------------
| Id  | Operation        | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |         |     5 |    15 |     2  (50)| 00:00:01 |
|   1 |  SORT ORDER BY   |         |     5 |    15 |     2  (50)| 00:00:01 |
|*  2 |   INDEX FULL SCAN| PK_DEMO |     5 |    15 |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - filter("COL1" IS NOT NULL)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          1  consistent gets
          0  physical reads
          0  redo size
        749  bytes sent via SQL*Net to client
        523  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
          5  rows processed



----------------------------------------------------------
----------------------- 建表语句 -------------------------
----------------------------------------------------------
create table LU.DEMO
(
  col1 VARCHAR2(2),
  col2 VARCHAR2(2),
  col3 VARCHAR2(2)
);
insert into LU.DEMO (col1, col2, col3)
values ('a', 'b', 'c');
insert into LU.DEMO (col1, col2, col3)
values ('a', 'b', 'e');
insert into LU.DEMO (col1, col2, col3)
values ('a', 'f', 'g');
insert into LU.DEMO (col1, col2, col3)
values ('b', 'h', 'i');
insert into LU.DEMO (col1, col2, col3)
values ('b', 'j', 'k');
insert into LU.DEMO (col1, col2, col3)
values ('b', 'j', 'm');
commit;
create index LU.PK_DEMO on LU.DEMO (COL1, COL2, COL3);
analyze table lu.demo estimate statistics; 

create table LU.DEMO1
(
  col1 VARCHAR2(2),
  col2 VARCHAR2(2),
  col3 VARCHAR2(2)
);
insert into LU.DEMO1 (col1, col2, col3)
values ('', 'c', 'd');
insert into LU.DEMO1 (col1, col2, col3)
values ('x', 'b', 'c');
insert into LU.DEMO1 (col1, col2, col3)
values ('y', 'b', 'e');
insert into LU.DEMO1 (col1, col2, col3)
values ('y', 'f', 'g');
insert into LU.DEMO1 (col1, col2, col3)
values ('y', 'b', 'f');
commit;
create index LU.PK_DEMO1 on LU.DEMO1 (COL1, COL2, COL3);
analyze table lu.demo1 estimate statistics; 