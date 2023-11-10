Connected to Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 
Connected as lu@192.168.131.200:1521/pdb1
SQL> --一定要看到最后，有干货
SQL> --创建测试表
SQL> create table demo
  2  (pk number primary key,
  3   id number,
  4   name varchar2(10)
  5  );
Table created

SQL> --插入值
SQL> insert into demo values(1,1,'a');
1 row inserted
SQL> insert into demo values(2,2,'b');
1 row inserted
SQL> insert into demo values(3,10,'a');
1 row inserted
SQL> commit;
Commit complete

SQL> --创建索引
SQL> create index idx_demo_id on demo(id);
Index created

SQL> --原始数据
SQL> select * from demo;
        PK         ID NAME
---------- ---------- ----------
         1          1 a
         2          2 b
         3         10 a
		 
SQL> --原update：**走全表扫描，性能低，语句执行时间长**
SQL> update demo set id = id + 10 where id = 1 or id >= 10 and name = 'a';
2 rows updated
Plan Hash Value  : 1805557832 
----------------------------------------------------------------------
| Id  | Operation            | Name | Rows | Bytes | Cost | Time     |
----------------------------------------------------------------------
|   0 | UPDATE STATEMENT     |      |    1 |     3 |    3 | 00:00:01 |
|   1 |   UPDATE             | DEMO |      |       |      |          |
| * 2 |    TABLE ACCESS FULL | DEMO |    1 |     3 |    3 | 00:00:01 |
----------------------------------------------------------------------
Predicate Information (identified by operation id):
------------------------------------------
* 2 - filter("ID"=1 OR "ID">=10 AND "NAME"='a')

SQL> commit;
Commit complete

SQL> --原update结果
SQL> select * from demo;
        PK         ID NAME
---------- ---------- ----------
         1         11 a
         2          2 b
         3         20 a

SQL> --原update拆分1，走索引
SQL> update demo set id = id + 10 where id = 1;
1 row updated
 Plan Hash Value  : 1513319009 
----------------------------------------------------------------------------
| Id  | Operation           | Name        | Rows | Bytes | Cost | Time     |
----------------------------------------------------------------------------
|   0 | UPDATE STATEMENT    |             |    1 |     2 |    1 | 00:00:01 |
|   1 |   UPDATE            | DEMO        |      |       |      |          |
| * 2 |    INDEX RANGE SCAN | IDX_DEMO_ID |    1 |     2 |    1 | 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
------------------------------------------
* 2 - access("ID"=1)

SQL> --原update拆分2，走索引
SQL> update demo set id = id + 10 where id >= 10 and name = 'a';
2 rows updated
 Plan Hash Value  : 1323511389 
-----------------------------------------------------------------------------------------------
| Id  | Operation                              | Name        | Rows | Bytes | Cost | Time     |
-----------------------------------------------------------------------------------------------
|   0 | UPDATE STATEMENT                       |             |    1 |     3 |    2 | 00:00:01 |
|   1 |   UPDATE                               | DEMO        |      |       |      |          |
| * 2 |    TABLE ACCESS BY INDEX ROWID BATCHED | DEMO        |    1 |     3 |    2 | 00:00:01 |
| * 3 |     INDEX RANGE SCAN                   | IDX_DEMO_ID |    1 |       |    1 | 00:00:01 |
-----------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
------------------------------------------
* 2 - filter("NAME"='a')
* 3 - access("ID">=10)

SQL> commit;
Commit complete

SQL> --拆分update和原update结果不同，拆分2把拆分1更新的值给更新了。虽然性能提升了，但是结果不同，这是不允许的。
SQL> select * from demo;
        PK         ID NAME
---------- ---------- ----------
         1         21 a
         2          2 b
         3         20 a
		 
--**************************************************************************************************************************
--*********************** 有效改写 *********************** 有效改写 *********************** 有效改写 ***********************
--**************************************************************************************************************************
SQL> --有效改写1：有主键的情况
SQL> merge into demo a using
  2  (select * from demo where id = 1
  3   union all
  4   select * from demo where lnnvl(id = 1) and id >= 10 and name = 'a') b
  5  on (a.pk = b.pk)
  6  when matched then
  7    update set id = id + 10;
2 rows merged
 Plan Hash Value  : 613810685 
-----------------------------------------------------------------------------------------------------
| Id   | Operation                                   | Name        | Rows | Bytes | Cost | Time     |
-----------------------------------------------------------------------------------------------------
|    0 | MERGE STATEMENT                             |             |    2 |    30 |    6 | 00:00:01 |
|    1 |   MERGE                                     | DEMO        |      |       |      |          |
|    2 |    VIEW                                     |             |      |       |      |          |
|    3 |     NESTED LOOPS                            |             |    2 |    88 |    6 | 00:00:01 |
|    4 |      NESTED LOOPS                           |             |    2 |    88 |    6 | 00:00:01 |
|    5 |       VIEW                                  |             |    2 |    66 |    4 | 00:00:01 |
|    6 |        UNION-ALL                            |             |      |       |      |          |
|    7 |         TABLE ACCESS BY INDEX ROWID BATCHED | DEMO        |    1 |     5 |    2 | 00:00:01 |
|  * 8 |          INDEX RANGE SCAN                   | IDX_DEMO_ID |    1 |       |    1 | 00:00:01 |
|  * 9 |         TABLE ACCESS BY INDEX ROWID BATCHED | DEMO        |    1 |     5 |    2 | 00:00:01 |
| * 10 |          INDEX RANGE SCAN                   | IDX_DEMO_ID |    1 |       |    1 | 00:00:01 |
| * 11 |       INDEX UNIQUE SCAN                     | SYS_C007654 |    1 |       |    0 | 00:00:01 |
|   12 |      TABLE ACCESS BY INDEX ROWID            | DEMO        |    1 |    11 |    1 | 00:00:01 |
-----------------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
------------------------------------------
* 8 - access("ID"=1)
* 9 - filter("NAME"='a')
* 10 - access("ID">=10)
* 10 - filter(LNNVL("ID"=1))
* 11 - access("A"."PK"="B"."PK")

SQL> commit;
Commit complete

SQL> --有效改写2：无主键情况，使用rowid
SQL> merge into demo a using
  2  (select b1.*,rowid rid from demo b1 where id = 1
  3   union all
  4   select b2.*,rowid rid from demo b2 where lnnvl(id = 1) and id >= 10 and name = 'a') b
  5  on (a.rowid = b.rid)
  6  when matched then
  7    update set id = id + 10;
2 rows merged
 Plan Hash Value  : 125857689 
---------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name        | Rows | Bytes | Cost | Time     |
---------------------------------------------------------------------------------------------------
|   0 | MERGE STATEMENT                            |             |    1 |    15 |    6 | 00:00:01 |
|   1 |   MERGE                                    | DEMO        |      |       |      |          |
|   2 |    VIEW                                    |             |      |       |      |          |
|   3 |     NESTED LOOPS                           |             |    1 |    56 |    6 | 00:00:01 |
|   4 |      VIEW                                  |             |    2 |    90 |    4 | 00:00:01 |
|   5 |       UNION-ALL                            |             |      |       |      |          |
|   6 |        TABLE ACCESS BY INDEX ROWID BATCHED | DEMO        |    1 |    11 |    2 | 00:00:01 |
| * 7 |         INDEX RANGE SCAN                   | IDX_DEMO_ID |    1 |       |    1 | 00:00:01 |
| * 8 |        TABLE ACCESS BY INDEX ROWID BATCHED | DEMO        |    1 |    11 |    2 | 00:00:01 |
| * 9 |         INDEX RANGE SCAN                   | IDX_DEMO_ID |    1 |       |    1 | 00:00:01 |
|  10 |      TABLE ACCESS BY USER ROWID            | DEMO        |    1 |    11 |    1 | 00:00:01 |
---------------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
------------------------------------------
* 7 - access("ID"=1)
* 8 - filter("NAME"='a')
* 9 - access("ID">=10)
* 9 - filter(LNNVL("ID"=1))

SQL> commit;
Commit complete
		 
SQL> --有效改写3：12c及更高版本中,"OR-EXPAND"是一种查询优化操作，用于处理包含OR条件的查询。当查询中存在OR条件时，Oracle可以使用OR-EXPAND操作将其转换为UNION ALL操作，以便更好地利用索引和并行执行计划。
merge into demo a using 
(select /*+no_merge or_expand*/ b1.*,rowid rid from demo b1 where id = 1 or id >= 10 and name = 'a') b
on (a.rowid = b.rid)
when matched then
  update set id = id + 10;
 Plan Hash Value  : 2889872739 

---------------------------------------------------------------------------------------------------------
| Id   | Operation                                   | Name            | Rows | Bytes | Cost | Time     |
---------------------------------------------------------------------------------------------------------
|    0 | MERGE STATEMENT                             |                 |    1 |    15 |    6 | 00:00:01 |
|    1 |   MERGE                                     | DEMO            |      |       |      |          |
|    2 |    VIEW                                     |                 |      |       |      |          |
|    3 |     NESTED LOOPS                            |                 |    1 |    56 |    6 | 00:00:01 |
|    4 |      VIEW                                   |                 |    2 |    90 |    4 | 00:00:01 |
|    5 |       VIEW                                  | VW_ORE_274FC3AC |    2 |    90 |    4 | 00:00:01 |
|    6 |        UNION-ALL                            |                 |      |       |      |          |
|    7 |         TABLE ACCESS BY INDEX ROWID BATCHED | DEMO            |    1 |    11 |    2 | 00:00:01 |
|  * 8 |          INDEX RANGE SCAN                   | IDX_DEMO_ID     |    1 |       |    1 | 00:00:01 |
|  * 9 |         TABLE ACCESS BY INDEX ROWID BATCHED | DEMO            |    1 |    11 |    2 | 00:00:01 |
| * 10 |          INDEX RANGE SCAN                   | IDX_DEMO_ID     |    1 |       |    1 | 00:00:01 |
|   11 |      TABLE ACCESS BY USER ROWID             | DEMO            |    1 |    11 |    1 | 00:00:01 |
---------------------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
------------------------------------------
* 8 - access("ID"=1)
* 9 - filter("NAME"='a')
* 10 - access("ID">=10)
* 10 - filter(LNNVL("ID"=1))
  
SQL> commit;
Commit complete