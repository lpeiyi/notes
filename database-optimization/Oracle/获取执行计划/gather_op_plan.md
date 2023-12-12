## 1(10g版本也适用):

sqlplus appuser/passwd@xxx

SQL>alter session set statistics_level=all;

SQL>执行你的业务sql

说明:

如果sql使用了绑定变量,最好是先定义绑定变量,再赋值执行,如:

SQL>var b1 number

SQL>exec :b1:=100

SQL>select count(*) from t1 where object_id=:b1;

或者用一组常量直接替换绑定变量;

SQL>select count(*) from t1 where object_id=100;

注意:

sqlplus里面不能使用:1 , :2 这样的绑定变量

sqlplus里面不能使用date/timestamp等绑定变量类型

遇到这种情况,可以到pl/sql developer里面执行,详见下文

如果返回的结果集比较大,建议在sql外面再套一层,对其中某几个字段做sum或count

如果是dml语句, 执行完后再rollback;

SQL>set linesize 200 pagesize 300

SQL>spool plan.log

SQL>select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));

SQL>spool off

生成了plan.log 文件, 包含了sql执行过程中的真实信息.

## 2 sql monitor

需要11g及以上版本(active格式需要11gR2及以上版本)

业务sql增加monitor的hint, 生成sql monitor文件:

SQL> select *+ monitor tag001 */ count(*) from t1;

如果sql执行时间不长, 可以等sql结束后,用下面代码保存sql monitor文件(不需要sqlid信息,默认采集刚刚执行过的sqlid):

set linesize 10000 pages 6000

set longchunksize 20000000 long 20000000

set trimout on trims on head off

spool sqlmon.html

select

DBMS_SQLTUNE.REPORT_SQL_MONITOR(

report_level=>'ALL',

type=>'active') as report

from dual;

spool off

执行完后,就在当前目录下生成了sqlmon.html 文件,即为所需sql monitor文件.

其中active可以改成text, 可以不借助浏览器查看; 复杂sql推荐使用active.

如果你有本人的ora私家工具, 可以用ora monlist 获取sql的sqlid,再用ora monsave sql_id保存sql monitor文件.

如果sql执行时间很长, 可以不需要等待sql执行结束,在sql执行一段时间后即可保存sql monitor文件:

需要先查到业务sql对应的sqlid信息(业务sql的hint里面加tag001的意义就是为了方便查找sqlid):

select sql_id , to_char(substr(sql_text,1,200)) as sql_text

from gv$sqlarea

where upper(SQL_TEXT) like upper('%tag001%')

and SQL_TEXT not like '%SQL_TEXT%';

得到sqlid后,就可以用下面脚本保存sql monitor文件了:

set linesize 10000 pages 6000

set longchunksize 20000000 long 20000000

set trimout on trims on head off

spool sqlmon.html

select

DBMS_SQLTUNE.REPORT_SQL_MONITOR(

sql_id=>'&sql_id',

report_level=>'ALL',

type=>'active') as report

from dual;

--先copy上面代码,根据提示输入sqlid,再执行:

spool off

也可以把上面代码保存成getmon.sql

SQL>@getmon

然后根据提示输入sqlid,同样能保存sql monitor文件

## 3 plsql代码块获取

使用pl/sql developer 得到与前面方法1和方法2一样sql真实执行计划及详细信息:

在sql window下执行(其中b1对应的是绑定变量)

declare

b1 date;

begin

execute immediate 'alter session set statistics_level = ALL';

b1:=sysdate-1;

for test in

(

-- 用你的业务sql替换下面的示例sql,后面不要加 ";"):

select /*+ monitor tag001 */count(*) from t1 where created>b1

)

loop

null;

end loop;

for x in (

select p.plan_table_output

from table(dbms_xplan.display_cursor(null,null,' allstats last')) p

)

loop

dbms_output.put_line(x.plan_table_output);

end loop;

rollback;

end;

/

然后可以在"output"页面得到所需真实执行计划信息.