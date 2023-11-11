-- create table
create table demo
(
  uuid 	   number,
  start_id number,
  end_id   number
);
--造数start_id,end_id
declare
  all_num      number;
  tartet_num   number := &tartet_num;
  insert_id    number;
  start_delete number;
  end_delete   number;
  return_num   number;
  row_id       varchar2(40);
  commit_flag  number := 0;
begin
  select nvl(max(start_id), 0) into insert_id from demo;
  start_delete := insert_id;

  select count(1) into all_num from demo;

  while all_num < tartet_num loop
    insert_id := insert_id + 1;
  
    --插入数据
    insert into demo(start_id,end_id) values (insert_id, insert_id + 2);
  
    --提交
    commit_flag := commit_flag + 1;
    if commit_flag = 10000 then
      commit;
      commit_flag := 0;
    end if;
  
    select count(1) into all_num from demo;
  
    --删除不符合业务的重复数据
    if all_num >= tartet_num then
      select max(start_id) into end_delete from demo;
    
      for i in start_delete .. end_delete loop
        select count(1)
          into return_num
          from demo
         where start_id <= i
           and end_id >= i;
      
        if return_num <= 1 then
          null;
        else
          delete from demo
           where rowid not in (select min(rowid)
                                 from demo
                                where start_id <= i
                                  and end_id >= i)
             and start_id <= i
             and end_id >= i;
             
          --提交
          commit_flag := commit_flag + 1;
          if commit_flag = 10000 then
            commit;
            commit_flag := 0;
          end if;
        end if;
      
      end loop;
    
      commit;
      start_delete := end_delete;
      select count(1) into all_num from demo;
    end if;
  end loop;

  commit;
end;
/
--造数uuid，start_id不规则，按start_id升序更新uuid按1递增
declare
  commit_flag number := 0;
begin
  for i in (select rowid, rownum, a.* from demo a order by start_id) loop
    update demo t1 set uuid = i.rownum where rowid = i.rowid;
    commit_flag := commit_flag + 1;
    if commit_flag = 10000 then
      commit;
      commit_flag := 0;
    end if;
  end loop;
end;
/
--创建索引
create index lpy.idx_demo_id on lpy.demo(start_id,end_id);

LPY@XE()> select uuid from demo where start_id <= 123456 and end_id >= 123456;

      UUID
----------
     41136


---------------------------------------------------------------------------------
------------------------------------- 说明 --------------------------------------
---------------------------------------------------------------------------------
1.主要关注的性能指标是统计信息中的逻辑读 consistent gets
2.越往下，优化效果越好

---------------------------------------------------------------------------------
------------------------------------ 原sql --------------------------------------
--走全表扫描，而且执行计划的rows与实际相差较大
---------------------------------------------------------------------------------
LPY@XE()> set autotrace traceonly;
LPY@XE()> select uuid from demo where start_id <= 123456 and end_id >= 123456;
执行计划
----------------------------------------------------------
Plan hash value: 4000794843
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 27034 |   369K|    96   (2)| 00:00:02 |
|*  1 |  TABLE ACCESS FULL| DEMO | 27034 |   369K|    96   (2)| 00:00:02 |
--------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - filter("START_ID"<=123456 AND "END_ID">=123456)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        334  consistent gets
          0  physical reads
          0  redo size
        532  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
		  

---------------------------------------------------------------------------------
------------------------------------ 优化0 --------------------------------------
--使用HINT：index, 强制走索引
---------------------------------------------------------------------------------  
LPY@XE()> select /*+index(d idx_demo_id)*/ uuid from demo d where start_id <= 123456 and end_id >= 123456;
执行计划
----------------------------------------------------------
Plan hash value: 952584116
-------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             | 27035 |   369K|   196   (0)| 00:00:03 |
|   1 |  TABLE ACCESS BY INDEX ROWID| DEMO        | 27035 |   369K|   196   (0)| 00:00:03 |
|*  2 |   INDEX RANGE SCAN          | IDX_DEMO_ID | 27035 |       |   121   (0)| 00:00:02 |
-------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("END_ID">=123456 AND "START_ID"<=123456)
       filter("END_ID">=123456)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        123  consistent gets
          0  physical reads
          0  redo size
        546  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed


---------------------------------------------------------------------------------
------------------------------------ 优化1 --------------------------------------
--添加谓词条件 rownum = 1，不用加HINT索引也会被用上
---------------------------------------------------------------------------------
LPY@XE()> select uuid from demo where start_id <= 123456 and end_id >= 123456 and rownum = 1;
执行计划
----------------------------------------------------------
Plan hash value: 1846472235
--------------------------------------------------------------------------------------------
| Id  | Operation                    | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |             |     1 |    14 |     3   (0)| 00:00:01 |
|*  1 |  COUNT STOPKEY               |             |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEMO        |     1 |    14 |     3   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | IDX_DEMO_ID |       |       |     2   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - filter(ROWNUM=1)
   3 - access("END_ID">=123456 AND "START_ID"<=123456)
       filter("END_ID">=123456)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        122  consistent gets
          0  physical reads
          0  redo size
        546  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
		  

---------------------------------------------------------------------------------
------------------------------------ 优化2 --------------------------------------
----添加HINT：INDEX_RS_DESC,IDX_DEMO_ID索引降序扫描
---------------------------------------------------------------------------------
--demo表上的索引，两个都有效
LPY@XE()> SELECT distinct a.index_name,listagg(b.COLUMN_NAME, ', ') within group(order by b.COLUMN_POSITION) over(partition by b.INDEX_NAME) idx_columns,a.status,b.DESCEND FROM dba_indexes a, dba_ind_columns b where a.owner = b.INDEX_OWNER and a.index_name = b.INDEX_NAME and a.table_owner = 'LPY' and a.table_name = 'DEMO';

INDEX_NAME           IDX_COLUMNS          STATUS           DESCEND
-------------------- -------------------- ---------------- --------
IDX_DEMO_ID2         END_ID, START_ID     UNUSABLE         ASC
IDX_DEMO_ID          START_ID, END_ID     UNUSABLE         ASC

--添加HINT,IDX_DEMO_ID索引降序扫描
LPY@XE()> select /*+ INDEX_RS_DESC(d IDX_DEMO_ID) */ uuid from demo d where start_id <= 123456 and end_id >= 123456 and rownum = 1;
执行计划
----------------------------------------------------------
Plan hash value: 1937616009
---------------------------------------------------------------------------------------------
| Id  | Operation                     | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |             |     1 |    14 |     3   (0)| 00:00:01 |
|*  1 |  COUNT STOPKEY                |             |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID | DEMO        |     1 |    14 |     3   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN DESCENDING| IDX_DEMO_ID | 27035 |       |     2   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - filter(ROWNUM=1)
   3 - access("END_ID">=123456 AND "START_ID"<=123456)
       filter("END_ID">=123456)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          3  consistent gets
          0  physical reads
          0  redo size
        546  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
		  

---------------------------------------------------------------------------------
------------------------------------ 优化3 --------------------------------------
--改变组合索引的顺序,不需要HINT也能达到<优化2>的效果。
---------------------------------------------------------------------------------
--禁用IDX_DEMO_ID索引，
LPY@XE()> alter index idx_demo_id unusable;

索引已更改。

--demo表上的索引，只有IDX_DEMO_ID2有效
LPY@XE()> SELECT distinct a.index_name,listagg(b.COLUMN_NAME, ', ') within group(order by b.COLUMN_POSITION) over(partition by b.INDEX_NAME) idx_columns,a.status,b.DESCEND FROM dba_indexes a, dba_ind_columns b where a.owner = b.INDEX_OWNER and a.index_name = b.INDEX_NAME and a.table_owner = 'LPY' and a.table_name = 'DEMO';

INDEX_NAME           IDX_COLUMNS          STATUS           DESCEND
-------------------- -------------------- ---------------- --------
IDX_DEMO_ID2         END_ID, START_ID     VALID            ASC
IDX_DEMO_ID          START_ID, END_ID     UNUSABLE         ASC


--不需要HINT也能达到<优化2>的效果。
LPY@XE()> select uuid from demo where start_id <= 123456 and end_id >= 123456 and rownum = 1;
执行计划
----------------------------------------------------------
Plan hash value: 1023413250
---------------------------------------------------------------------------------------------
| Id  | Operation                    | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |              |     1 |    14 |     3   (0)| 00:00:01 |
|*  1 |  COUNT STOPKEY               |              |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEMO         |     1 |    14 |     3   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | IDX_DEMO_ID2 |       |       |     2   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - filter(ROWNUM=1)
   3 - access("END_ID">=123456 AND "END_ID" IS NOT NULL)
       filter("START_ID"<=123456)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          3  consistent gets
          0  physical reads
          0  redo size
        546  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed