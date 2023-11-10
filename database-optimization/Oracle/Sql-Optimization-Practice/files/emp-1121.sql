--------------------------------------------------------------------------
------------------------------ 创建用例表 --------------------------------
--命令窗口执行
--------------------------------------------------------------------------
prompt Dropping SCOTT.EMP1...
drop table SCOTT.EMP1 cascade constraints;
prompt Creating SCOTT.EMP1...
create table SCOTT.EMP1
(
  empno    NUMBER(4) not null,
  ename    VARCHAR2(10),
  job      VARCHAR2(9),
  mgr      NUMBER(4),
  hiredate DATE,
  sal      NUMBER(7,2),
  comm     NUMBER(7,2),
  deptno   NUMBER(2)
);

prompt Disabling triggers for SCOTT.EMP1...
alter table SCOTT.EMP1 disable all triggers;
prompt Loading SCOTT.EMP1...
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7369, 'SMITH', 'CLERK', 7902, to_date('17-12-1980', 'dd-mm-yyyy'), 800, null, 20);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7499, 'ALLEN', 'SALESMAN', 7698, to_date('20-02-1981', 'dd-mm-yyyy'), 1600, 300, 30);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7521, 'WARD', 'SALESMAN', 7698, to_date('22-02-1981', 'dd-mm-yyyy'), 1250, 500, 30);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7566, 'JONES', 'MANAGER', 7839, to_date('02-04-1981', 'dd-mm-yyyy'), 2975, null, 20);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7654, 'MARTIN', 'SALESMAN', 7698, to_date('28-09-1981', 'dd-mm-yyyy'), 1250, 1400, 30);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7698, 'BLAKE', 'MANAGER', 7839, to_date('01-05-1981', 'dd-mm-yyyy'), 2850, null, 30);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7782, 'CLARK', 'MANAGER', 7839, to_date('09-06-1981', 'dd-mm-yyyy'), 2450, null, 10);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7788, 'SCOTT', 'ANALYST', 7566, to_date('09-12-1982', 'dd-mm-yyyy'), 3000, null, 20);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7839, 'KING', 'PRESIDENT', null, to_date('17-11-1981', 'dd-mm-yyyy'), 5000, null, 10);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7844, 'TURNER', 'SALESMAN', 7698, to_date('08-09-1981', 'dd-mm-yyyy'), 1500, 0, 30);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7876, 'ADAMS', 'CLERK', 7788, to_date('12-01-1983', 'dd-mm-yyyy'), 1100, null, 20);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7900, 'JAMES', 'CLERK', 7698, to_date('03-12-1981', 'dd-mm-yyyy'), 950, null, 30);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7902, 'FORD', 'ANALYST', 7566, to_date('03-12-1981', 'dd-mm-yyyy'), 3000, null, 20);
insert into SCOTT.EMP1 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7934, 'MILLER', 'CLERK', 7782, to_date('23-01-1982', 'dd-mm-yyyy'), 1300, null, 10);
commit;
prompt 14 records loaded
prompt Enabling triggers for SCOTT.EMP1...
alter table SCOTT.EMP1 enable all triggers;

--------------------------------------------------------------------------
-------------------------------- 原SQL -----------------------------------
--全表扫描
--------------------------------------------------------------------------
SCOTT@XE()> SELECT ename,sal FROM scott.emp1 t1 where t1.empno = '7839';
ENAME                       SAL
-------------------- ----------
KING                       5000
执行计划
----------------------------------------------------------
Plan hash value: 2226897347

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    33 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP1 |     1 |    33 |     2   (0)| 00:00:01 |
--------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - filter("T1"."EMPNO"=7839)
Note
-----
   - dynamic sampling used for this statement (level=2)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          4  consistent gets
          0  physical reads
          0  redo size
        601  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
		  

--------------------------------------------------------------------------
-------------------------------- 优化1 -----------------------------------
--创建普通索引 I_EMP1_EMPNO
--------------------------------------------------------------------------
create index SCOTT.I_EMP1_EMPNO on SCOTT.EMP1 (EMPNO);

SCOTT@XE()> SELECT ename,sal FROM scott.emp1 t1 where t1.empno = '7839';

ENAME                       SAL
-------------------- ----------
KING                       5000

执行计划
----------------------------------------------------------
Plan hash value: 805446453
--------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |     1 |    33 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP1         |     1 |    33 |     1   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | I_EMP1_EMPNO |     1 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - access("T1"."EMPNO"=7839)
Note
-----
   - dynamic sampling used for this statement (level=2)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          3  consistent gets
          0  physical reads
          0  redo size
        601  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed


--------------------------------------------------------------------------
-------------------------------- 优化2 -----------------------------------
--创建组合索引 PK_EMP1
--------------------------------------------------------------------------
create index SCOTT.PK_EMP1 on SCOTT.EMP1 (EMPNO, ENAME, SAL);
SCOTT@XE()> SELECT ename,sal FROM scott.emp1 t1 where t1.empno = '7839';

ENAME                       SAL
-------------------- ----------
KING                       5000

执行计划
----------------------------------------------------------
Plan hash value: 4279547613
----------------------------------------------------------------------------
| Id  | Operation        | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT |         |     1 |    33 |     1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| PK_EMP1 |     1 |    33 |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - access("T1"."EMPNO"=7839)
Note
-----
   - dynamic sampling used for this statement (level=2)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          2  consistent gets
          0  physical reads
          0  redo size
        601  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
		  
		  
--------------------------------------------------------------------------
-------------------------------- 优化3 -----------------------------------
--添加谓词条件 rownum = 1
--------------------------------------------------------------------------
SCOTT@XE()> SELECT ename,sal FROM scott.emp1 t1 where t1.empno = '7839' and rownum = 1;

ENAME                       SAL
-------------------- ----------
KING                       5000

执行计划
----------------------------------------------------------
Plan hash value: 1918086206
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |     1 |    33 |     1   (0)| 00:00:01 |
|*  1 |  COUNT STOPKEY    |         |       |       |            |          |
|*  2 |   INDEX RANGE SCAN| PK_EMP1 |     1 |    33 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   1 - filter(ROWNUM=1)
   2 - access("T1"."EMPNO"=7839)
Note
-----
   - dynamic sampling used for this statement (level=2)
统计信息
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          1  consistent gets
          0  physical reads
          0  redo size
        601  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed