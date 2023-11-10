----------------------------------------------------------
------------------------ 一般优化 ------------------------
----------------------------------------------------------
select uuid from demo where end_id > 12345 and start_id <= 12345 and rownum = 1;
lpy@xe()> select uuid from demo where end_id > 12345 and start_id <= 12345 and rownum = 1;

未选定行


执行计划
----------------------------------------------------------
plan hash value: 1023413250
---------------------------------------------------------------------------------------------
| id  | operation                    | name         | rows  | bytes | cost (%cpu)| time     |
---------------------------------------------------------------------------------------------
|   0 | select statement             |              |     1 |    14 |     3   (0)| 00:00:01 |
|*  1 |  count stopkey               |              |       |       |            |          |
|   2 |   table access by index rowid| demo         |     1 |    14 |     3   (0)| 00:00:01 |
|*  3 |    index range scan          | idx_demo_id2 |       |       |     2   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
predicate information (identified by operation id):
---------------------------------------------------

   1 - filter(rownum=1)
   3 - access("end_id">12345 and "end_id" is not null)
       filter("start_id"<=12345)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        340  consistent gets
          0  physical reads
          0  redo size
        340  bytes sent via sql*net to client
        512  bytes received via sql*net from client
          1  sql*net roundtrids to/from client
          0  sorts (memory)
          0  sorts (disk)
          0  rows processed


----------------------------------------------------------
---------------------- 近乎完美的优化 ---------------------
----------------------------------------------------------
create or replace function get_id_area(v_id number) return number is 
  v_start_id number;
  v_uuid varchar2(30);
begin
  select uuid, start_id
    into v_uuid, v_start_id
    from (select uuid, start_id
            from demo
           where end_id >= v_id
           order by end_id)
   where rownum = 1;
  if v_start_id <= v_id then
    return v_uuid;
  else
    return null;
  end if;
exception
  when no_data_found then
    return null;
end get_id_area;
/

LPY@XE()> select get_id_area(12345) uuid from dual;

执行计划
----------------------------------------------------------
Plan hash value: 1388734953
-----------------------------------------------------------------
| Id  | Operation        | Name | Rows  | Cost (%CPU)| Time     |
-----------------------------------------------------------------
|   0 | SELECT STATEMENT |      |     1 |     2   (0)| 00:00:01 |
|   1 |  FAST DUAL       |      |     1 |     2   (0)| 00:00:01 |
-----------------------------------------------------------------
统计信息
----------------------------------------------------------
          1  recursive calls
          0  db block gets
          3  consistent gets
          0  physical reads
          0  redo size
        528  bytes sent via SQL*Net to client
        523  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed


----------------------------------------------------------
------------------------ 完美优化 ------------------------
--优化写法，原function的替代SQL代码(需要存在end_id 单字段上的索引)：
----------------------------------------------------------
LPY@XE()> select case
  2           when start_id <= 400000 then uuid
  3           else null
  4         end uuid
  5    from (select uuid, start_id, end_id
  6            from demo
  7           where end_id >= 400000
  8           order by end_id)
  9   where rownum = 1;

未选定行
执行计划
----------------------------------------------------------
Plan hash value: 876455446
----------------------------------------------------------------------------------------------
| Id  | Operation                     | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |              |     1 |    26 |     3   (0)| 00:00:01 |
|*  1 |  COUNT STOPKEY                |              |       |       |            |          |
|   2 |   VIEW                        |              |     1 |    26 |     3   (0)| 00:00:01 |
|   3 |    TABLE ACCESS BY INDEX ROWID| DEMO         |     1 |    14 |     3   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN          | IDX_DEMO_ID2 |     1 |       |     2   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - filter(ROWNUM=1)
   4 - access("END_ID">=400000 AND "END_ID" IS NOT NULL)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          2  consistent gets
          0  physical reads
          0  redo size
        340  bytes sent via SQL*Net to client
        512  bytes received via SQL*Net from client
          1  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          0  rows processed