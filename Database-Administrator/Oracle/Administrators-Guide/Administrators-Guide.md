**目录**

[toc]

# 说明

此文章包含三个部分，第一部分主要介绍Oracle的体系结构，章节为1到4章。第二部分主要介绍Oracle数据库的管理，章节为5到11章。第三部分主要介绍高可用，章节为12到19章。

# 1 Oracle体系结构概述

本章将介绍Oracle 12c的基础知识和后面章节的一些特性，以及使用Oracle通用安装程序（Oracle Universal Installer，OUI）和数据库配置助手（Database Configuration Assistant，DBCA）安装Oracle 12c的基本知识。

学习完本章节，你将会对Oracle数据库有一个整体性的了解。

## 1.1 数据库和实例概述

相信很多人不清楚数据库和实例的关系，更有甚者以为数据库和实例是同一个东西的。实际上，他们间存在很大区别，是完全不同的实体，但又紧密相关。

数据库和实例架构图如下所示：

![Alt text](image-1.png)

### 1.1.1 数据库

数据库是一组位于磁盘上用于存储数据的文件集。这些文件可以独立于数据库实例存在。如下图所示：

![Alt text](image.png)


数据库由各种物理和逻辑结构组成，而表则是数据库中最重要的逻辑结构。“表”由包含相关数据的行和列组成。数据库至少要有存储有用信息的表。

组成数据库的文件主要分为两类：数据库文件和非数据库文件。两者之间的区别在于存储何种数据。数据库文件包含数据和元数据，非数据库文件则包含初始参数和日志记录信息等。

### 1.1.2 实例

实例是管理数据库文件的内存结构集合。由一个称为系统全局区SGA的共享内存区和一些后台进程组成。这些后台进程在SGA和磁盘上的数据库文件之间交互。实例可以独立存在于数据库文件之外。如下图所示：

![Alt text](image-2.png)

Oracle实例架构分为单实例和RAC。

在单实例中，数据库和实例时一对一关系。

在Oracle RAC中，数据库和实例是一对多，一个数据可对应多个实例，即内存和后台进程每个实例独立，而数据库文件共享。

## 1.2 逻辑存储结构

Oracle数据库中的数据文件被分组到一个或多个表空间中。在每个表空间中，逻辑数据库结构（如表和索引）都是片段，被进一步细分为“盘区”（extent）和“块（block）”。这种存储的逻辑细分允许Oracle更有效地控制磁盘空间的利用率。如下图所示：

![Alt text](image-3.png)

下面介绍逻辑结构的组成部分。他们之间的关系以及和物理结构的关系如下图所示：

![Alt text](image-4.png)

**一、数据块（data block）**

数据块是Oracle数据库中最小的数据存储逻辑单元，即数据块是Oracle数据库可以使用或分配的最小存储单元。

块的大小是数据库内给定表空间中特定数量的存储字节，默认是8kb，通过初始参数DB_BLOCK _SIZE指定大小。数据库块大小需要是操作系统块大小的整数倍，有利于提升磁盘I/O的效率。

**二、区（extent）**

区是由一组逻辑连续的数据块组成，用于存储特定类型的信息。例如，一个24kb的区，默认由3个8kb的数据块组成。

**三、段（segment）**

段是为特定的数据库对象（例如表、索引等）分配的一组区的集合。每一个表、索引等数据库对象都是一个段。

段的分类：

1. 数据段：存储非集群表、表分区或表集群数据的段。如果表是分区表或集群表，则表会被分配多个段；
2. 索引段：存储非分区索引或分区索引数据的段；
3. 临时段：当一个SQL语句需要一个临时的数据库区域来完成执行时，Oracle数据库创建的一个段。例如，排序操作所需要的空间超过了PGA时，需要创建临时段完成排序；
4. 回滚段：在undo表空间中的段。

例如，employees表的数据存储在它自己的数据段中，而employees表的每一个索引存储在它自己的索引段中。

每一个需要存储的数据库对象由单个段组成。

**四、表空间（tablespace）**

表空间是包含一个或多个段的数据库存储单元。每一个段仅属于一个表空间，因此，一个段的所有区都存储在同一个表空间中。

在表空间内，一个段可以包含来自多个数据文件的区。例如，一个段的区有的存储在datafile1，也有的存储在datafile2。但是，一个区不能跨数据文件，只能存储于同一个数据文件中。根据以上特性，我们又可以知道，Oracle表空间(tablespace)由一个或多个数据文件组成，一个数据文件是且只能是一个表空间的一部分。

表空间的管理分为字典管理或本地管理。

## 1.3 逻辑数据库结构

## 1.3.1 表

表是Oracle数据库中的基本存储单位，表中的数据总是存储在行和列中。

下面介绍Oracle中不同类型的表。

**一、堆表★**

堆表（关系表）是数据库中最常见的表类型。关系表以“堆（heap）”的形式进行组织；换句话说，表中的行没按任何特定顺序存储。表的每一行包含一列或多列，每一列都有一种数据类型和长度。

**二、临时表★**

临时表仅保存在事务或会话期间存在的数据。临时表中的数据对会话是私有的，每个会话只能查看和修改自己的数据。

临时表分为全局临时表和私有临时表。他们的特点如下图所示：

![Alt text](image-5.png)


**三、索引组织表**

创建索引可以更有效地找到表中的特定行，但是，这也会带来一些额外的系统开销。因为数据库必须同时维护表的数据行和索引条目。

如果表包含的列并不多，而且对表的访问主要集中在某一列上，应怎么做？这种情况下，索引组织表（Index Organized Table，IOT）可能就是正确的解决方案。

索引组织表的数据按主键排序手段被存储在B-树索引中，除了存储主键列值外还存储非键列的值。普通索引只存储索引列，而索引组织表则存储表的所有列的值。IOT不存在主键的空间开销，因为索引就是数据，数据就是索引，二者已经合二为一。

IOT最明显的优点在于只需要维护一个存储结构，而非两个。例如，表中主键的值只在IOT中存储一次，而在普通表中则需要存储两次。

索引组织表一般适应于静态表，且查询多以主键列。当表的大部分列当作主键列时，且表相对静态，比较适合创建索引组织表。

IOT适用的场合有：
1. 完全由主键组成的表；
2. 代码查找表，维度表；
3. 如果你想保证数据存储在某个位置上，或者希望数据以某种特定的顺序物理存储。

**四、对象表**

对象表是一种特殊类型的表，其中每一行代表一个对象。

Oracle对象类型是用户自定义的类型，具有名称、属性和方法。对象类型可以将真实世界的实体(如客户和采购订单)建模为数据库中的对象。

对象类型定义逻辑结构，但不创建存储。例如：

```sql
CREATE TYPE department_typ AS OBJECT
   ( d_name     VARCHAR2(100),
     d_address  VARCHAR2(200) );
/
```

下面创建department_typ类型的表，并插入一行记录：

```sql
CREATE TABLE departments_obj_t OF department_typ;
INSERT INTO departments_obj_t VALUES ('hr', '10 Main St, Sometown, CA');
```

**五、外部表**

![Alt text](image-6.png)

外部表允许用户访问数据源，如文本文件，就如同该数据源是数据库中的表一样。表的元数据存储在Oracle数据字典中，但表的内容存储在外部。

当Oracle数据库应用程序必须访问非关系数据时，外部表非常有用。

但是，在外部表上不可以创建索引，也不可以对其执行插入、更新或删除操作。

创建外部表的例子：

要创建外部表的数据在两个文本文件empxt1.dat和empxt2.dat中。

empxt1.dat文件包含如下样例数据：
```dat
360,Jane,Janus,ST_CLERK,121,17-MAY-2001,3000,0,50,jjanus
361,Mark,Jasper,SA_REP,145,17-MAY-2001,8000,.1,80,mjasper
362,Brenda,Starr,AD_ASST,200,17-MAY-2001,5500,0,10,bstarr
363,Alex,Alda,AC_MGR,145,17-MAY-2001,9000,.15,80,aalda
```

empxt2.dat文件包含如下样例数据：

```dat
401,Jesse,Cromwell,HR_REP,203,17-MAY-2001,7000,0,40,jcromwel
402,Abby,Applegate,IT_PROG,103,17-MAY-2001,9000,.2,60,aapplega
403,Carol,Cousins,AD_VP,100,17-MAY-2001,27000,.3,90,ccousins
404,John,Richardson,AC_ACCOUNT,205,17-MAY-2001,5000,0,110,jrichard
```

在hr schema中创建名为admin_ext_employees的外部表： 
```sql
CONNECT  /  AS SYSDBA;
-- Set up directories and grant access to hr 
CREATE OR REPLACE DIRECTORY admin_dat_dir
    AS '/flatfiles/data'; 
CREATE OR REPLACE DIRECTORY admin_log_dir 
    AS '/flatfiles/log'; 
CREATE OR REPLACE DIRECTORY admin_bad_dir 
    AS '/flatfiles/bad'; 
GRANT READ ON DIRECTORY admin_dat_dir TO hr; 
GRANT WRITE ON DIRECTORY admin_log_dir TO hr; 
GRANT WRITE ON DIRECTORY admin_bad_dir TO hr;
-- hr connects. Provide the user password (hr) when prompted.
CONNECT hr
-- create the external table
CREATE TABLE admin_ext_employees
                   (employee_id       NUMBER(4), 
                    first_name        VARCHAR2(20),
                    last_name         VARCHAR2(25), 
                    job_id            VARCHAR2(10),
                    manager_id        NUMBER(4),
                    hire_date         DATE,
                    salary            NUMBER(8,2),
                    commission_pct    NUMBER(2,2),
                    department_id     NUMBER(4),
                    email             VARCHAR2(25) 
                   ) 
     ORGANIZATION EXTERNAL 
     ( 
       TYPE ORACLE_LOADER 
       DEFAULT DIRECTORY admin_dat_dir 
       ACCESS PARAMETERS 
       ( 
         records delimited by newline 
         badfile admin_bad_dir:'empxt%a_%p.bad' 
         logfile admin_log_dir:'empxt%a_%p.log' 
         fields terminated by ',' 
         missing field values are null 
         ( employee_id, first_name, last_name, job_id, manager_id, 
           hire_date char date_format date mask "dd-mon-yyyy", 
           salary, commission_pct, department_id, email 
         ) 
       ) 
       LOCATION ('empxt1.dat', 'empxt2.dat') 
     ) 
     PARALLEL 
     REJECT LIMIT UNLIMITED; 
-- enable parallel for loading (good if lots of data to load)
ALTER SESSION ENABLE PARALLEL DML;
-- load the data in hr employees table
INSERT INTO employees (employee_id, first_name, last_name, job_id, manager_id,
                       hire_date, salary, commission_pct, department_id, email) 
            SELECT * FROM admin_ext_employees;

```

**六、群集表**

如果经常同时访问两个或多个表（如一个订单表和一个行项明细表），则创建群集表（clustered table）可能是一种较好的方法，它可以改进引用这些表的查询的性能。在具有相关行项（line-item）明细表的订单表中，订单标题信息可与行项明细记录存储在同一个块中，从而减少检索订单和行项信息所需要的I/O数量。两个表共有的列也称为“群集键值”。

**七、散列群集**

作为特殊类型的群集表，散列群集（hash cluster）操作起来非常类似于普通的群集表，但是，它不使用群集索引，而使用散列函数来存储并检索表中的行。创建表时，将根据在创建群集期间指定的散列键的数量分配所需要的预估空间。

**八、排序的散列群集**

排序的散列群集是Oracle 10g中的新增内容。它们类似于普通的散列群集，通过使用散列函数来定位表中的行。然而，除此之外，排序的散列群集允许对表中的行根据表的一列或多列进行升序排列。如果遇到进行先进先出（First In First Out，FIFO）处理的应用程序，该方法就可以更快速地处理数据。

可以先创建群集本身，再创建排序的散列群集，但需要在群集中列定义的后面加上SORT位置参数。

**九、分区表★**

分区表对表进行分区或对索引进行分区（下一部分将介绍对索引进行分区）可帮助建立更便于管理的大型表。*Oracle公司建议，对于任何大于2GB的表，应尽量考虑对其进行分区。*

从DBA的观点看，进行分区有很多优点。如果表的一个分区位于已损坏的磁盘卷上，则在修复遭到破坏的卷时，用户仍可查询表的其他分区。与此类似，对分区的备份可以许多天进行一次，每次备份一个分区，而不需要一次性地对整个表进行备份。

分区大致有3种类型：范围分区、散列分区及列表分区。

**范围分区**，对于范围分区，它的分区键落在某一范围内。

**列表分区**，在列表分区中，分区键落在完全不同的值组中。

**散列分区**，散列分区根据散列函数将行赋给分区，只需要指定用于散列函数的一列或多列，不必将这些列显式赋予分区，而只需要指定有多少列可用。Oracle将行赋给分区，并确保每个分区中行的均匀分布。如果没有明确的列表分区或范围分区模式提供给表中的列类型，或者分区的相对大小经常改变，需要用户重复地手动调整分区模式，则散列分区就非常实用。

**组合分区**，使用组合分区可对分区进程进一步进行细分。例如，可先对表进行范围分区，然后在每个范围内，使用列表或散列进一步分区。

从Oracle 11g开始，也可以根据父／子关系进行分区，由应用程序控制分区，并可对基本分区类型进行很多组合，包括列表-散列、列表-列表、列表-范围和范围-范围等。分区表中的每一行能且只能存在于一个分区中。分区键为行指示正确的分区，它可以是组合键，最多可组合表中的16列。对可分区的表类型有一些次要的限制，例如，包含LONG或LONG RAW列的表不能进行分区。LONG限制极少会成为问题。LOB（包括字符大型对象CLOB和二进制大型对象BLOB）则灵活得多，包含LONG和LONG RAW数据类型的所有特性。

**十、分区索引★**

对表上的索引——或者符合索引表的分区模式（本地索引），或者独立于表的分区模式进行分区（全局索引）。删除分区时全局索引会失效，需要重建。

## 1.3.2 约束

Oracle约束（constraint）是一条或多条规则，它在表的一列或多列上定义，用于帮助实施业务规则。例如，约束可强制实现雇员起薪不得低于$25 000.00这样的业务规则。

共有6种数据完整性规则可应用于表列：非空、唯一性、主键、外键、检查和基于触发器的完整性。

可在创建时或将来的任意时间点启用或禁用约束；启用或禁用（使用关键字ENABLE或DISABLE）约束时，根据有效的业务规则，可能需要也可能不需要验证（使用关键字VALIDATE或NOVALIDATE）表中已有数据是否满足约束。

以下创建的表具有所有约束类型：
```sql
create table cust_order (
  order_number number(6) primary key,
  order_date date NOT null,
  delivery_date date,
  warehouse_number number default 12,
  customer_number number NOT null,
  order_line_item_qty number check (order_line_item_qty < 100),
  ups_tracking_number varchar2(50) unique,
  foreign key (customer_number) references customer(customer_number)
);
```

基于上表，下面将介绍每种约束:
1. **非空约束：**
   可防止将NULL值输入ORDER_DATE列或CUSTOMER_NUMBER列。从业务规则的角度看，这样做很有意义：每个订单都必须有订购日期，而只有在顾客下订单时，订单才有意义。

   注意，列中的NULL值并不意味着值为空或0；准确地讲，该值不存在。NULL值不等同于任何内容，甚至不等同于另一个NULL值。在对可能具有NULL值的列使用SQL查询时，这个概念非常重要。

2. **唯一性约束：**
   确保一列或一组列（通过组合约束）在整个表中是唯一的，UPS_TRACKING_NUMBER列将不包含重复值。为强制实施约束，Oracle将在UPS_TRACKING_NUMBER列上创建唯一索引。如果该列上已有一个有效的唯一索引，Oracle将使用该索引来实施约束。

   具有UNIQUE约束的列也可声明为NOT NULL。如果没有声明该列具有NOT NULL约束，则任意数量的行都可以具有NULL值，只要剩余的行在该列中具有唯一值。在允许一列或多列具有NULL值的组合唯一约束中，非NULL值的列用于确定是否满足约束。NULL列总满足约束，因为NULL值不等同于任何内容。

3. **主键约束：**
   是数据库表中最常见的约束类型。一个表上最多只能存在一个主键约束，组成主键的列不能有NULL值。ORDER_NUMBER列是主键。系统将创建唯一索引以实施该约束，如果该列已存在可用的唯一索引，主键约束就使用该索引。

4. **外键约束：**
   比上述任何一种约束都更复杂，因为它依赖于另一个表来限制哪些值可以输入到具有引用完整性约束的列中。在CUSTOMER_NUMBER列上声明外键（FOREIGN KEY）；输入该列的值必须也存在于另一个表（在这种情况下是CUSTOMER表）的CUSTOMER_NUMBER列中。

   此外，FOREIGN KEY约束可以自引用。在主键为EMPLOYEE_NUMBE的EMPLOYEE表中，MANAGER_NUMBER列具有根据同一个表中的EMPLOYEE_NUMBER列声明的外键，这就允许在EMPLOYEE表自身中创建一个报告层次结构。

   应该总在外键（FOREIGN KEY）列上声明索引以改进性能，该规则的唯一例外出现在绝对不会更新或删除父表中的引用主键或唯一键时。
   
5. **检查约束：**
   通过使用CHECK约束，可在列级别实施更复杂的业务规则。在前面的示例中，ORDER_LINE_ITEM_QTY列不得超出99。
   
   CHECK约束可使用插入或更新的行中的其他列来评估约束。例如，STATE_CD列上的约束只有在COUNTRY_CD列的值不为USA时才允许NULL值。

   一列上允许有多个CHECK约束。只有在所有的CHECK约束都计算为TRUE时，才允许将值输入列中。
   
6. **基于触发器的完整性约束**
   如果业务规则过于复杂，使用唯一性约束很难实现，则可使用CREATE TRIGGER命令在表上创建一个数据库触发器，同时使用一个PL/SQL代码块实施这一业务规则。当引用的表存在于不同的数据库中时，需要使用触发器来实施引用完整性约束。触发器也可用于许多超出约束检查领域的情况（例如，对表的审核访问）。

### 1.3.3 索引

当检索表中少量的行时，使用Oracle索引能更快访问表中的这些行。索引存储了进行索引的列的值，同时存储包含索引值的行的物理ROWID，唯一的例外是索引组织表（Index-Organized Table，IOT），它使用主键作为逻辑ROWID。可在一列或多列上创建索引。索引条目存储在B-树结构中，因此遍历索引以找到行的键值只需要使用非常少的I/O操作。一旦在索引中找到匹配值，索引中的ROWID就会指向表行的确切位置：哪个文件、文件中的哪个块，以及块中的哪一行。

下面将介绍最常见的索引类型的重点内容和特性：
1. **唯一索引：**
   唯一索引是最常见的B-树索引形式。它常用于实施表的主键约束。唯一索引确保索引的一列或多列中不存在重复值。

   例如，可在EMPLOYEE表中Social Security Number（社会保障号）的对应列上创建唯一索引，因为该列中不应有任何重复值。然而，一些雇员可能没有Social Security Number，因此该列可以包含NULL值。

2. **非唯一索引：**
   非唯一索引帮助提高访问表的速度，而不会强制实施唯一性。例如，可在EMPLOYEE表的LAST_NAME列上创建非唯一索引，从而提高按姓查找的速度。但对于任何给定的姓，确实可以有许多重复的值。

3. **反向键索引：**
   反向键索引（reverse key index）是特殊类型的索引，在反向键索引中，反向每列的索引键值中的所有字节。一般用于OLTP（OnlineTransaction Processing，联机事务处理）环境中。

   在CREATE INDEX命令中，使用REVERSE关键字指定反向键索引。下面是创建反向键索引的一个示例：
   ```sql
   create index ie_line_item_order_number on line_item (order_number) reverse;
   ```

4. **基于函数的索引：**
   基于函数的索引类似于标准的B-树索引，不同之处在于它将被声明为表达式的列的变换形式存储在索引中，而非存储列自身。

   下面的示例在EMPLOYEE表的LAST_NAME列上创建基于函数的索引：
   ```sql
   create index up_name on employee(upper(last_name));
   ```

   因此，使用如下查询的搜索将使用前面创建的索引，而不是进行完整的表扫描：
   ```sql
   select employee_number, last_name, first_name, from employee where upper(last_name) = 'SMITH';
   ```

5. **位图索引：**
   在索引的叶节点上，位图索引（bitmap index）的结构与B-树索引相比存在着较大的区别。它只存储索引列每个可能值（基数）的一个位串，位串的长度与索引表中的行数相同。
   
   **在索引列具有较低基数或大量不同的值时，使用位图索引才最有效**。例如，PERS表中的GENDER列将有NULL、M或F值。GENDER列上的位图索引将只有3个位图存储在索引中。

   与传统索引相比，位图索引不仅可节省大量空间，还可大大缩短响应时间，因为在需要访问表自身之前，Oracle就可以从包含多个WHERE子句的查询中快速删除潜在的行。对于多个位图，可使用逻辑AND和OR操作来确定访问表中的哪些行。

   **注意**：位图索引只在Oracle 11g和12c的企业版中可用。由于在表上执行DML时，位图索引包含额外的锁定和块拆分开销，因此仅适用于极少更新的列。

### 1.3.4 视图

视图允许用户查看单独表或多个连接表中数据的自定义表示。视图也称为“存储查询”：用户无法看到视图底层隐藏的查询细节。普通视图不存储任何数据，只存储定义，在每次访问视图时都运行底层的查询。

普通视图的增强称为“物化视图（materialized view）”，允许同时存储查询的结果和查询的定义，从而加快处理速度。

对象视图类似于传统视图，可隐藏底层表连接的细节，并允许在数据库中进行面向对象的开发和处理，而底层的表仍然保持数据库关系表的格式。

下面将介绍创建并使用的基本视图类型的基础知识。

**一、普通视图**

普通视图，通常称为“视图”，不会占据任何存储空间，只有它的定义（查询）存储在数据字典中。视图底层查询的表称为“基表”，视图中的每个基表都可以进一步定义为视图。

视图有很多优点，它可以隐藏数据复杂性。高级分析人员可以定义包含EMPLOYEE、DEPARTMENT和SALARY表的视图，这样上层管理部门可以更容易地使用SELECT语句检索有关雇员薪水的信息，这种检索表面看来是使用表，但实际上是包含查询的视图，该查询连接EMPLOYEE、DEPARTMENT和SALARY表。

视图也可以用于实施安全性。EMPLOYEE表上的视图EMP_INFO包含除了SALARY（薪水）外的所有列，并且将该视图定义为只读，从而防止更新该表:
```sql
create view emp_info 
  as
    select  employee_number, last_name, first_name, middle_initial, surname
       from employee
  with read only;
```

如果没有READ ONLY子句，则可更新某行或向视图中添加行，甚至可在包含多个表的视图上执行这些操作。视图中有一些构造可防止对其进行更新，例如使用DISTINCT操作符、聚集函数或GROUP BY子句。

**二、物化视图**

物化视图与普通视图非常类似，视图的定义存储在数据字典中，并且该视图对用户隐藏底层基查询的细节。不同之处在于，物化视图也在数据库段中分配空间，用于保存执行基查询得到的结果集。

物化视图可用于将表的只读副本复制到另一个数据库，该副本具有和基表相同的列定义和数据。这是物化视图的最简单实现。为减少刷新物化视图时的响应时间，可创建物化视图日志以刷新物化视图。否则，在需要刷新时就必须进行完全的刷新：必须运行基查询的全部结果以刷新物化视图。物化视图日志为以增量方式更新物化视图提供了方便。

物化视图在很多方面与索引类似，它们都直接和表联系并且占用空间，在更新基表时必须刷新它们，它们的存在对用户而言实际上是透明的。通过使用可选的访问路径来返回查询结果，它们可以帮助优化查询。

**三、对象视图**

面向对象（OO）的应用程序开发环境日趋流行，Oracle 12c数据库完全支持数据库中本地化对象和方法的实现。然而，从纯粹的关系数据库环境向纯粹的OO数据库环境迁移并非易事，很少有组织愿意花费时间和资源从头开始构建新的系统，而Oracle 12c使用对象视图使这种迁移变得更为容易。

对象视图允许面向对象的应用程序查看作为对象集合的数据，这种对象集合具有属性和方法，而遗留系统仍可对INVENTORY表运行批处理作业。对象视图可以模仿抽象数据类型、对象标识符（OID）以及纯粹的OO数据库环境能够提供的引用。

### 1.3.5 用户和模式

有权访问数据库的数据库账户称为“用户”。用户可存在于数据库中，而不拥有任何对象。

如果用户在数据库中创建并拥有对象，这些对象就是与数据库用户同名的模式（schema）的一部分。模式可拥有数据库中任何类型的对象：表、索引、序列和视图等。模式拥有者或DBA可授权其他数据库用户访问这些对象。

用户总是拥有完整的权限，而且可以控制用户模式中的对象。

### 1.3.6 配置文件

数据库配置文件是可以赋给用户的限定资源的命名集。数据库资源不是无限的，因此DBA必须为所有数据库用户管理和分配资源。数据库资源的一些示例是CPU时间、并发会话、逻辑读和连接时间。

### 1.3.7 序列

Oracle序列用于分配有序数，并且保证其唯一性（除非重新创建或重新设置序列）。序列（sequence）可生成长达38位的数字，数字序列可按升序或降序排列，间隔可以是用户指定的任何值，并且Oracle可在内存中缓存序列中的数字块，从而获得更快的性能。

序列中的数字可保证唯一，但不一定有序。如果缓存数字块，并且重新启动实例，或者回滚使用序列中数字的事务，则下次调用从序列中检索数字不会与原序列中已引用但未使用的数字相同。

### 1.3.8 同义词

Oracle同义词（synonym）只是数据库对象的别名，用于简化对数据库对象的引用，并且隐藏数据库对象源的细节。同义词可以赋给表、视图、物化视图、序列、过程、函数和程序包。与视图类似，除了数据字典中的定义外，同义词不会在数据库中分配任何空间。创建公有同义词后，要确保同义词的用户拥有对该同义词引用的对象的正确权限。

### 1.3.9 PL/SQL

Oracle PL/SQL是Oracle对SQL的过程化语言扩展。

**一、过程和函数**

PL/SQL过程和函数是PL/SQL命名块的范例。PL/SQL块是PL/SQL语句序列，可将其视为用于执行功能的单位，它最多包含3个部分：变量声明部分、执行部分和异常部分。

过程和函数之间的区别在于：函数将单个值返回到调用程序，如SQL SELECT语句。相反，过程不返回值，只返回状态码。

过程和函数在数据库环境中有诸多优点。在数据字典中只需编译并存储过程一次，当多个用户调用过程时，该过程已经编译，并且只有一个副本存在于共享池中。此外，网络通信量会减少，即使没有使用PL/SQL的过程化特性也是如此。一次PL/SQL调用所使用的网络带宽远小于单独通过网络发送的SQL SELECT和INSERT语句。

**二、包**

包（package）将相关的函数和过程以及常见的变量和游标（cursor）组合在一起。程序包由两个部分组成：包头和包体。

在包头中，提供包的方法和属性，方法的实现以及任何私有方法和属性都隐藏在包体中。如果使用程序包而不是单独的过程或函数，则在改变内嵌的过程或函数时，任何引用程序包规范中元素的对象都不会失效，从而避免了重新编译引用程序包的对象。

**三、触发器**

触发器（trigger）是一种特殊类型的PL/SQL或Java代码块，在指定事件发生时执行或触发。事件类型可以是表或视图上的DML语句、DDL语句甚至是数据库事件（如启动和关闭）。可以改进指定的触发器，使其作为审核策略的一部分在特定用户的特定事件上执行。

### 1.3.10 外部文件访问

除了外部表外，Oracle还有大量其他的方法可用于访问外部文件：

- 在SQL*Plus中，访问包含要运行的其他SQL命令的外部脚本，或将SQL*Plus SPOOL命令的输出发送到操作系统的文件系统中的文件。
- 在PL/SQL过程中，使用UTL_FILE内置程序包读取或写入文本信息；类似地，PL/SQL过程中的DBMS_OUTPU调用可生成文本消息和诊断，另一个应用程序可以捕获这些消息和诊断，并保存在文本文件中。
- BFILE数据类型可引用外部数据。
- DBMS_PIPE可与Oracle支持的任何3GL语言通信并交换信息，如C++、Ada、Java或COBOL。
- UTL_MAIL是Oracle 10g中新增的程序包，它允许PL/SQL应用程序发送电子邮件，而不需要知道如何使用底层的SMTP协议栈。

### 1.3.11 数据库链接和远程数据库

数据库链接允许Oracle数据库引用存储在本地数据库之外的对象。命令CREATE DATABASE LINK创建到远程数据库的路径，从而允许访问远程数据库中的对象。数据库链接打包如下内容：远程数据库的名称、连接到远程数据库的方法、用于验证远程数据库连接的用户名／密码的组合。

为在分布式环境中的多个数据库之间建立链接，域中每个数据库的全局数据库名必须都不相同。因此，重要的是正确分配初始参数DB_NAME和DB_DOMAIN。

为便于使用数据库链接，可将同义词赋给数据库链接，使表访问更透明；用户并不知道同义词访问的是本地对象还是分布式数据库上的对象。

## 1.4 物理存储结构

Oracle数据库使用磁盘上的大量物理存储结构来保存和管理用户事务中的数据。

有些物理存储结构，如数据文件、重做日志文件和归档的重做日志文件，保存实际的用户数据。

其他结构，如控制文件，用于维护数据库对象的状态，而基于文本的警报和跟踪文件则包含数据库中例程事件和错误条件的日志信息。

物理结构与逻辑存储结构之间的关系如下图所示：

![Alt text](image-7.png)

### 1.4.1 数据文件

每个Oracle数据库必须至少包含一个数据文件（datafile）。一个表空间可由许多数据文件组成。当Oracle数据文件用完空间时，它可以自动扩展，只要DBA是使用AUTOEXTEND参数创建数据文件即可。通过使用MAXSIZE参数，DBA也可以限制给定数据文件的扩展量。在任何情况下，数据文件的大小最终都会受到它所驻留的磁盘卷的限制。

数据库中的所有数据最终都驻留在数据文件中。数据文件中频繁访问的块缓存在内存中。类似地，新的数据块不会立刻写出到数据文件，而是在数据库写入程序进程处于活动状态时再写到数据文件。然而，在用户的事务完成之前，事务的改变就会写入重做日志文件。

### 1.4.2 重做日志文件

无论何时在表、索引或其他Oracle对象中添加、删除或改变数据，都会将一个条目写入当前的重做日志文件（redo log file）。每个Oracle数据库必须至少有两个重做日志文件，因为Oracle以循环方式重用重做日志文件。

理想情况下，永远不会使用重做日志文件中的信息。然而，如果发生电源故障，或者一些其他服务器故障造成Oracle实例失败，数据库缓冲区缓存中新添加的或更新的数据块就可能尚未写入数据文件。重新启动Oracle实例时，通过前滚操作将重做日志文件中的条目应用于数据库数据文件，从而将数据库的状态还原到发生故障时间点的情况。

### 1.4.3 控制文件

每个Oracle数据库至少有一个控制文件，用于维护数据库的元数据（即有关数据库自身物理结构的数据）。控制文件包含数据库名称、创建数据库的时间以及所有数据文件和重做日志文件的名称和位置。此外，控制文件还维护恢复管理器（RMAN）所用的信息，如持久性RMAN设置和已在数据库上执行的备份类型。

因为控制文件对数据库操作至关重要，所以也可对其进行多元复用。然而，不论控制文件的多少个副本与一个实例关联，系统也只会指定一个控制文件作为检索数据库元数据的主控制文件。

```sql
ALTER DATABASE BACKUP CONTROLFILE TO TRACE;
```

上述命令是一种备份控制文件的方式。它生成一个SQL脚本，如果由于灾难性故障而丢失控制文件的所有多元复用二进制版本，则可以用该脚本重新创建数据库控制文件。

### 1.4.4 归档的日志文件

Oracle数据库有两种操作模式：ARCHIVELOG和NOARCHIVELOG模式。当数据库处于NOARCHIVELOG模式时，重做日志文件（也称为“联机的重做日志文件”）的循环重用意味着重做条目（前面事务的内容）在出现磁盘驱动器故障或与其他介质相关的故障时不再可用。在NOARCHIVELOG模式中进行操作，可在发生实例故障或系统崩溃时保护数据库的完整性，因为已经提交但还没有写入数据文件的所有事务都可在联机重做日志文件中找到。

相反，ARCHIVELOG模式将填满的重做日志文件发送到一个或多个指定的目的地，并且可以在发生数据库介质故障事件后的任意给定时间点重新构造数据库。

对填满的重做日志文件使用多个归档日志的目标是Oracle高可用性的特性之一，即“Oracle Data Guard（数据卫士）”。

### 1.4.5 初始参数文件

当数据库实例启动时，为Oracle实例分配内存，并打开两种初始参数文件中的一种：基于文本的文件，名为init\<SID\>.ora（一般称为PFILE）；或者是服务器参数文件（称为SPFILE）。

实例启动时，首先在操作系统的默认位置（例如Unix上的$ORACLE_HOME/dbs）查找SPFILE：spfile<SID>.ora或spfile.ora。如果这些文件都不存在，实例查找名为init<SID>.ora的PFILE。作为一种选择方案，也可以使用STARTUP命令显式指定用于启动的PFILE。

SPFILE使DBA可以更简单有效地管理参数。如果将SPFILE用于运行的实例中，那么改变初始参数的任何ALTER SYSTEM命令都可以自动改变SPFILE中的初始参数，或者只改变运行实例的初始参数，或者两者都改动。此过程不需要编辑SPFILE，甚至可以不破坏SPFILE本身。虽然不能镜像参数文件或SPFILE自身，但可将SPFILE备份到init.ora文件，然后使用常规的操作系统命令或RMAN（在SPFILE的情况下）备份Oracle实例的init.ora和SPFILE。

### 1.4.6 警报和跟踪日志文件

当出错时，Oracle通常将相关消息写入警报日志（alert log），但在后台进程或用户会话的情况下，会将消息写入跟踪日志（trace log）文件。

警报日志文件位于由初始参数BACKGROUND_DUMP_DEST指定的目录中，它包含例程状态消息和错误条件。当以下情况发生时会产生新的记录：

1.  启动或关闭数据库时，在警报日志中记录一条消息，同时记录不同于默认值的初始参数列表。
2.  DBA提交的任何ALTER DATABASE或ALTER SYSTEM命令时。
3.  涉及表空间及其数据文件的操作，例如添加表空间、删除表空间以及将数据文件添加到表空间。
4.  错误条件，如空间不足的表空间、损坏的重做日志等。

后台进程的跟踪文件也通过BACKGROUND_DUMP_DEST定位。针对单独的用户会话或数据库连接也会创建跟踪文件。这些跟踪文件位于由初始参数USER_DUMP_DEST指定的目录中。

可在任何时间删除或重命名警报日志文件，下次生成警报日志消息时重新创建警报日志文件。DBA通常建立一个每天执行的批处理作业（通过操作系统机制或Oracle企业管理器的调度程序），用于逐日重命名和归档警报日志。

### 1.4.7 备份文件

备份文件有多个来源，如操作系统的复制命令或OracleRMAN（恢复管理器）。

操作系统的复制命令是“冷”备份，备份文件就只是数据文件、重做日志文件、控制文件和归档的重做日志文件等文件的操作系统副本。”冷“备份需要关闭数据库执行。

RMAN可以生成数据文件、控制文件、重做日志文件、归档的日志文件以及SPFILE的完整备份和增量备份，这些备份都采用特殊格式，称为“备份集”，只有RMAN可以读取。RMAN备份集的备份通常小于初始的数据文件，因为RMAN并不备份未使用过的块。

### 1.4.8 Oracle管理文件

Oracle 9i中引入Oracle管理文件（OMF，Oracle Managed Files），它通过自动创建和删除组成数据库中逻辑结构的数据文件，简化了DBA的工作。如果没有OMF，DBA可能删除表空间，而忘记删除底层的操作系统文件。这会造成磁盘资源利用率低下，并增加不必要的数据库不再需要的数据文件备份时间。

OMF非常适合于较小的数据库，这种数据库只有少量的用户和兼职DBA，并且不需要生产数据库的优化配置。即使数据库较小，Oracle也建议最好为构成数据库的所有数据文件使用ASM（Automatic Storage Management，自动存储管理），并且建议只使用两个磁盘组，一个用于表和索引段（如+DATA），另一个用于RMAN备份、控制文件的第二个副本、归档重做日志的副本（如+RECOV）。初始参数DB_FILE_CREATE_DEST指向+DATA磁盘组，DB_CREATE_ONLINE_DEST_1指向+DATA磁盘组，DB_CREATE_ONLINE_DEST_2指向+RECOV。联机日志文件目标LOG_ARCHIVE_DEST_n同样如此。

### 1.4.9 密码文件

Oracle密码文件（password file）是磁盘上的Oracle管理或软件目录结构中的文件，用于对Oracle系统管理员进行身份验证，以执行创建数据库或启动和关闭数据库等任务。通过该文件授予的是SYSDBA和SYSOPER权限。

如果密码文件不存在或者已经受损，可使用Oracle命令行实用程序orapwd创建密码文件。由于要通过该文件授予非常高的权限，因此应将该文件存储在安全的目录位置，只有DBA和操作系统管理员可以访问该位置。一旦创建这种密码文件，应将初始参数REMOTE_LOGIN_ PASSWORDFILE设置为EXCLUSIVE，允许SYS以外的用户使用密码文件。另外，密码文件必须位于$ORACLE_HOME/dbs目录中。

应创建至少一个非SYS或SYSTEM的用户，该用户具有执行每日管理任务的DBA权限。如果有多个DBA管理一个数据库，则每个DBA都应该有自己的、具有DBA权限的账户。

作为一种备选方案，也可以使用OS身份验证完成对SYSDBA和SYSOPER权限的验证，这种情况下不需要创建密码文件，并应将初始参数REMOTE_LOGIN_PASSWORDFILE设置为NONE。

## 1.5 多元复用数据库文件

为尽量降低丢失控制文件或重做日志文件的可能性，数据库文件的多元复用（multiplexing）可减少或消除由于介质故障而造成的数据丢失问题。

### 1.5.1 自动存储管理

使用ASM（Automatic Storage Management，自动存储管理）是一种多元复用解决方案，即将数据文件、控制文件和重做日志文件分布在所有可用的磁盘上，从而自动布局这些文件。将新的磁盘添加到ASM群集时，数据库文件将自动重新分布到所有的磁盘卷，以优化性能。ASM群集的多元复用特性可最小化数据丢失的可能性，并且比将关键文件和备份放在不同物理驱动器上的手动方案更有效。

### 1.5.2 手动的多元复用

即使没有RAID或ASM解决方案，也仍可为关键数据库文件提供一些保护措施。方法是设置一些初始参数，并为控制文件、重做日志文件和归档的重做日志文件提供另外的位置。

**一、控制文件**

可手动将控制文件复制到多个目的地。最多可以多元复用控制文件的8个副本。

如果希望添加另一个多元复用位置，则需编辑初始参数文件，将另一个位置添加到CONTROL_FILES参数。可使用如下命令来改变CONTROL_FILES参数：

```sql
alter system set control_files = '/u01/oracle/tmp/ctrlfile1.ctl, /u02/oracle/tmp/ctrlfile2.ctl, /u03/oracle/tmp/ctrlfile3.ctl' scope=spfile;
```

下一步关闭数据库。将控制文件复制到由CONTROL_FILES指定的新目的地，并且重新启动数据库。通过查看一个数据字典视图，始终可以验证控制文件的名称和位置：

```sql
select value from v$spparameter where name='control_files';
```

**二、重做日志文件**

将一组重做日志文件改变到重做日志文件组中，就可以多元复用重做日志文件。在默认的Oracle安装中，会创建3个重做日志文件。填满一个日志文件后，按顺序填充下一个日志文件。填满第3个日志文件后，重新使用第一个日志文件。

为将这3个重做日志文件改变到一个组中，可添加一个或多个相同的文件，以伴随每个已有的重做日志文件。创建组后，将重做日志条目同时写入重做日志文件组。填满重做日志文件组时，开始将重做日志条目写入下一个组。

下图显示了如何使用4个组来多元复用4个重做日志文件，每个组包含3个成员：

![Alt text](image-8.png)

将成员添加到重做日志组非常简单。在ALTER DATABASE命令中，指定新文件的名称以及将要添加到其中的组的名称即可。创建的新文件的大小与组中其他成员相同：

```sql
alter database add logfile member '/u05/oracle/dc2/log_3d.dbf' to group 3;
```

如果填满重做日志文件的速度快于归档它们的速度，则一种可行的解决方案是添加另一个重做日志组。下例将第5个重做日志组添加到上图中的重做日志组：

```sql
alter database add logfile group 5 ('/u02/oracle/dc2/log_3a.dbf',
                                    '/u03/oracle/dc2/log_3b.dbf',
                                    '/u04/oracle/dc2/log_3c.dbf') 
 size 250m;
```

重做日志组的所有成员必须大小相同。然而，不同组之间的日志文件大小可以不同。此外，重做日志组可以有不同的成员数量。在前前个示例中，首先有4个重做日志组，然后添加另外一个成员到重做日志组3（共4个成员），并添加了具有3个成员的第5个重做日志组。从Oracle 10g开始，可使用重做日志文件大小估计顾问（Redo Logfile Sizing Advisor）来帮助确定重做日志文件的最优尺寸，以避免过多的I/O活动或瓶颈。

**三、归档的重做日志文件**

如果数据库处于ARCHIVELOG模式，则在重做日志开关循环中可以重用重做日志文件之前，Oracle会将其复制到指定的位置。

## 1.6 内存结构

Oracle使用服务器的物理内存来保存Oracle实例的许多内容：Oracle的可执行代码自身、会话信息、与数据库关联的单独进程、进程之间共享的信息（如数据库对象上的锁）。此外，内存结构还包含用户和数据字典SQL语句，以及最终永久存储在磁盘上的缓存信息，如来自数据库段的数据块和数据库中已完成事务的相关信息。

分配给Oracle实例的数据区域称为系统全局区域（System Global Area，SGA），Oracle的可执行代码驻留在软件代码区域。。程序全局区域（Program Global Area，PGA），对于每个服务器和后台进程来说都是私有的，Oracle为每个进程分配一个PGA。

下图显示了这些Oracle内存结构之间的关系：

![Alt text](image-9.png)

### 1.6.1 SGA

系统全局区域是用于Oracle实例的一组共享内存结构，由数据库实例的用户共享。启动Oracle实例时，系统根据在初始参数文件中指定的值或在Oracle软件中硬编码的值，为SGA分配内存。控制SGA不同部分大小的许多参数都是动态的；然而，如果指定SGA_MAX_SIZE参数，则所有SGA区域的全部大小必须不能超出SGA_MAX_SIZE的值。如果没有指定SGA_MAX_SIZE，但指定了参数SGA_TARGET，Oracle就自动调整SGA各组成部分的大小，从而使分配的内存总量等同于SGA_TARGET。SGA_TARGET是动态参数，可在实例运行时改变。MEMORY_TARGET是Oracle 11g中新增的参数，用于在SGA和PGA（稍后讨论）之间平衡Oracle可用的所有内存，以优化性能。

SGA中的内存以“区组（granule）”为单位分配。区组的大小可为4MB或16MB，这取决于SGA的总体大小。如果SGA小于或等于128MB，区组就是4MB；否则，区组为16MB。

接下来将介绍Oracle如何使用SGA中每个部分的重点内容。

**一、缓冲区缓存**

数据库缓冲区缓存（buffer cache）保存来自磁盘的数据块，这些数据块有的满足最近执行的SELECT语句，有的是通过DML语句改变或添加的已修改块。从Oracle 9i开始，SGA中保存这些数据块的内存区域是动态的，可动态改变DB_CACHE_SIZE和DB_nK_CACHE_SIZE的值，而不需要重新启动实例。

**二、共享池**

共享池包含两个主要的子缓存：库缓存和数据字典缓存。共享池的大小由初始参数SHARED_POOL_SIZE确定。这也是一个动态参数，其大小可以调整，只要SGA的全部大小小于SGA_MAX_SIZE或SGA_TARGET即可。

库缓存，保存针对数据库运行的SQL和PL/SQL语句的有关信息。在库缓存中，因为由所有用户共享，所以许多不同的数据库用户可以潜在地共享相同的SQL语句。和SQL语句自身一起，SQL语句的执行计划和解析树也存储在库缓存中。第二次由同一用户或不同用户运行同一条SQL语句时，由于已经计算了执行计划和解析树，因此可以提高查询或DML语句的执行速度，这就是软解析。如果库缓存过小，则必须将执行计划和解析树转储到缓存外面，这就需要频繁地将SQL语句重新加载到库缓存中。

数据字典缓存，数据字典是数据库表的集合，由SYS和SYSTEM模式拥有，其中包含有关数据库、数据库结构以及数据库用户的权限和角色的元数据。数据字典缓存保存第一次读到缓冲区缓存之后的数据字典表的列的子集。数据字典中来自表的数据块常用于辅助处理用户查询和其他DML命令。如果数据字典缓存太小，对数据字典中信息的请求将造成额外的I/O。这些I/O绑定的数据字典请求称为“递归调用”，应该通过正确设置数据字典缓存的大小加以避免。

**三、重做日志缓冲区**

重做日志缓冲区保存对数据文件中的数据块所进行的最近的改动。当重做日志缓冲区的1/3已满或者每隔3秒时，Oracle将重做日志记录写入重做日志文件。从Oracle 10g开始，当重做日志缓冲区中存储了1MB重做信息时，LGWR进程就将重做日志记录写入重做日志文件

一旦将重做日志缓冲区中的条目写入重做日志文件，如果在将改动的数据块从缓冲区缓存写入数据文件之前实例崩溃，这些条目就对数据库恢复起着至关重要的作用。只有将重做日志条目成功写入重做日志文件后，才可以认为用户提交的事务完成。

**四、大型池**

大型池是SGA的可选区域，用于与多个数据库交互的事务、处理并行查询的消息缓冲区以及RMAN并行备份和还原操作。顾名思义，大型池可为需要一次分配大块内存的操作提供所需要的大块内存。初始参数LARGE_POOL_SIZE控制大型池的大小，这是从Oracle 9i版本2开始新增的一个动态参数。

**五、Java池**

Oracle的Java虚拟机（Java Virtual Machine，JVM）使用Java池来处理用户会话中的所有Java代码和数据。将Java代码和数据存储在Java池中类似于将SQL和PL/SQL代码缓存在共享池中。

**六、流池**

流池是Oracle 10g中新增的池，使用初始参数STREAMS_POOL_SIZE可以确定其大小。流池保存用于支持Oracle企业版中Oracle流特性的数据和控制结构。Oracle流管理分布式环境中数据和事件的共享。如果初始参数STREAMS_POOL_SIZE未初始化或者将其设置为0，则从共享池中分配用于流操作的内存，并且最多可以分配共享池10%的容量。

### 1.6.2 PGA

程序全局区域（Program Global Area，PGA）是分配给一个进程并归该进程私有的内存区域。PGA的配置取决于Oracle数据库的连接配置：共享服务器或专用服务器。

在共享服务器配置中，多个用户共享一个数据库连接，从而最小化服务器上的内存使用率，但可能影响对用户请求的响应时间。在共享服务器环境中，由SGA而不是PGA来保存用户的会话信息。对于大量同时进行，伴有很少发生的请求或短期请求的数据库连接，共享服务器是理想的环境。

在专用服务器环境中，每个用户进程获得自己的数据库连接，PGA包含这种配置的会话内存。PGA也包括一个排序区域，当用户请求需要排序、位图合并或散列连接操作时，就会使用这种排序区域。

从Oracle 9i开始，通过PGA_AGGREGATE_TARGET参数和WORKAREA_SIZE_POLICY初始参数的结合，DBA可选择所有工作区域的全部大小，并让Oracle管理并分配所有用户进程之间的内存，从而简化系统管理。如前所述，MEMORY_TARGET参数作为一个整体管理PGA和SGA内存来优化性能。

### 1.6.3 软件代码区

软件代码区域存储作为Oracle实例的一部分运行的Oracle可执行文件。这些代码区域实际上是静态的，只有在安装软件的新版本时才会改变。一般来说，Oracle软件代码区域位于与其他用户程序隔离的权限内存区域。Oracle软件代码是严格只读的代码，可共享安装或非共享安装。当多个Oracle实例运行在同一服务器上和相同的软件版本级别时，按可共享方式安装Oracle软件代码可节省内存。

### 1.6.4 后台进程

当Oracle实例启动时，多个后台进程就会启动。后台进程是设计用于执行特定任务的可执行代码块。与SQL*Plus会话或Web浏览器等前台进程不同，用户无法看到后台进程的工作情况。SGA和后台进程结合起来组成了Oracle实例。

后台进程、数据库和Oracle SGA之间的关系如下图所示：

![Alt text](image-10.png)

**一、SMON**

SMON是系统监控器（System Monitor）进程。在系统崩溃或实例故障的情况下，由于停电或CPU故障，通过将联机重做日志文件中的条目应用于数据文件，SMON进程可执行崩溃恢复。此外，它在系统重新启动期间清除所有表空间中的临时段。SMON的一个常规任务是定期合并字典管理的表空间中的空闲空间。

**二、PMON**

如果删除用户连接，或者用户进程以其他方式失败，PMON（也称为“进程监控器”）就会进行清除工作。它清除数据库缓冲区缓存以及用户连接所使用的其他任何资源。

例如，用户会话可能正在更新表中的某些行，在一行或多行上放置锁。一场雷雨袭击了用户办公桌的电力设置，当工作站的电源关闭时，SQL*Plus会话消失。期间，PMON将检测到连接不再存在，并执行下面的任务：

1. 回滚到电源断开时正在处理的事务。
2. 在缓冲区缓存中标记可用的事务块。
3. 删除表中受影响的行上的锁。
4. 从活动进程列表中删除未连接进程的进程ID。

通过将实例状态的相关信息提供给传入的连接请求，PMON也和监听器交互。

**三、DBWn**

数据库写入程序（database writer）进程，在Oracle的旧版本中也称为DBWR，负责将缓冲区缓存中新增的或改动的数据块（称为“脏块”）写入数据文件。使用LRU算法，DBWn首先写入最早的、最小的活动块。因此，请求最多的块位于内存中，即使它们是脏块。

最多可启动20个DBWn进程，DBW0～DBW9，以及DBWa～DBWj。通过DB_WRITER_PROCESS参数可以控制DBWn进程的数量。

**四、LGWR**

LGWR，或称为“日志写入程序”进程，负责管理重做日志缓冲区。在具有大量DML活动的实例中，LGWR是最活跃的进程之一。直到LGWR成功地将重做信息（包括提交记录）写入重做日志文件，才能认为事务已经完成。此外，直到LGWR已经写入重做信息，才可以通过DBWn将缓冲区缓存中的脏缓冲区写入数据文件。

如果分组重做日志文件，并且组中一个多元复用的重做日志文件已经受损，LGWR将写入剩余的组成员，并在警报日志文件中记录错误。如果组中的所有成员都不可用，LGWR进程就会失败，并且整个实例挂起，直至问题得到纠正为止。

**五、ARCn**

如果数据库处于ARCHIVELOG模式，只要重做日志填满并且重做信息开始按顺序填充下一个重做日志，归档程序进程（ARCn）就将重做日志复制到一个或多个目的地目录、设备或网络位置。

最理想的情况下，归档进程应在下一次使用填满的重做日志之前完成。否则会产生严重的性能问题：将条目写入重做日志文件前用户无法完成他们的事务，而重做日志文件还没有准备好接受新条目，因为它仍在写入归档位置。对于该问题，至少有3种可能的解决方案：使重做日志文件更大一些，增加重做日志组的数量，增加ARCn进程的数量。针对每个实例最多可启动30个ARCn进程，其方法是增加LOG_ARCHIVE_MAX_ PROCESSES初始参数的值。

**六、CKPT**

检查点进程（checkpoint process），即CKPT，可帮助减少实例恢复所需要的时间。在检查点期间，CKPT更新控制文件和数据文件的标题，从而反映最近成功的系统变更号（System Change Number，SCN）。每次进行重做日志文件切换时，都自动生成一个检查点。DBWn进程按常规写入脏缓冲区，将检查点从实例恢复可以开始的位置提前，从而减少平均恢复时间（Mean Time to Recovery，MTTR）。

**七、RECO**

RECO即恢复器进程（recoverer process），用于处理分布式事务（即包括对多个数据库中的表进行改动的事务）的故障。如果同时改变CCTR数据库和WHSE数据库中的表，而在可以更新WHSE数据库中的表之前，两个数据库之间的网络连接失败了，RECO将回滚失败的事务。

## 1.7 备份和恢复概述

Oracle支持许多不同形式的备份和恢复。可在用户级别管理其中的一些备份和恢复，如导出和导入，而大多数备份和恢复严格以DBA为中心，如联机或脱机备份，以及使用操作系统命令或RMAN实用程序。

### 1.7.1 导出／导入

可使用Oracle的逻辑化Export和Import实用程序来备份和还原数据库对象。Export是逻辑备份，因为未记录表的底层存储特性，只记录表的元数据、用户权限和表数据。根据当前任务，以及是否拥有DBA权限，可导出一个数据库中的所有表、一个或多个用户的所有表，或者特定表集。相应的Import实用程序可酌情还原之前导出的对象。

Export和Import本质上是“时间点”备份，因此，如果数据是易变的，则Export和Import不是最健壮的备份和恢复解决方案。

之前的Oracle Database版本包含exp和imp命令，但这些在Oracle Database 12c中不再可用。从Oracle 10g开始，Oracle Data Pump（Oracle数据泵）替代了传统的导入和导出命令，将这些操作的性能提高到新的水平。导出到外部数据源最多可加快两倍，而导入操作最多可以加快45倍，因为Oracle Data Pump导入使用直接路径加载，这一点不同于传统的导入。此外，从源数据库的导出可同时导入目标数据库，而不需要中间的转储文件，从而节省时间和管理工作。使用带有expdb和impdb命令的DBMS_DATAPUMP程序包可以实现Oracle Data Pump，它包括大量其他可管理特性，如细粒度的对象选择。Oracle Data Pump也与Oracle 12c的所有新功能保持同步，如将整个可插入数据库（PDB）从一个容器数据库（CDB）移到另一个。

### 1.7.2 冷备份

建立数据库物理备份的一种方法是执行脱机备份（offline backup），习惯称“冷备份”。为执行脱机备份，需要关闭数据库，并且将所有与数据库相关的文件，包括数据文件、控制文件、SPFILE和密码文件等，复制到其他位置。一旦复制操作完成，就可以启动数据库实例。

脱机备份类似于导出备份，因为它们都是时间点备份，因此在需要最新的数据库恢复并且数据库不处于ARCHIVELOG模式时，这些备份的作用较小。脱机备份的另一个不足之处在于执行备份所需要的停机时间，任何需要24/7数据库访问的跨国公司通常不会经常进行脱机备份。

### 1.7.3 热备份

如果数据库处于ARCHIVELOG模式，则可能进行数据库的联机备份（online backup），习惯称“热备份”。可打开数据库，并且用户可以使用该数据库，即使当前正在进行备份。进行联机备份的过程非常简单，只要使用ALTER TABLESPACE USERS BEGIN BACKUP命令将表空间转入备份状态，使用操作系统命令备份表空间中的数据文件，然后使用ALTER TABLESPACE USERS END BACKUP命令将表空间转移出备份状态即可。

### 1.7.4 RMAN

备份工具“恢复管理器（Recovery Manager）”，更常见的叫法是RMAN，它从Oracle 8就开始出现了。RMAN提供了优于其他备份形式的许多优点。它可在完整的数据库备份之间只对改动的数据块进行增量式备份，同时数据库在整个备份期间保持联机。

RMAN通过以下两种方法跟踪备份：通过备份数据库的控制文件；通过存储在另一个数据库中的恢复目录。对于RMAN，使用目标数据库的控制文件比较简单，但对于健壮企业备份方法学，这并不是最佳解决方案。虽然恢复目录需要另一个数据库来存储目标数据库的元数据和所有备份的记录，但如果目标数据库中的所有控制文件由于灾难性故障而丢失，这时就值得采用恢复目录的方法。此外，恢复目录保留历史备份信息，如果将CONTROL_FILE_ RECORD_KEEP_TIME的值设置得太低，则可能在目标数据库的控制文件中重写这些备份信息。

## 1.8 安全功能

### 1.8.1 权限和角色

在Oracle数据库中，“权限（privilege）”用于控制用户对可执行的操作以及数据库中对象的访问。控制对数据库中操作的访问的权限称为“系统权限”，而控制对数据和其他对象的访问的权限称为“对象权限”。

为便于DBA分配和管理权限，数据库“角色（role）”将权限结合在一起。换言之，角色是指定的权限组。此外，角色自身可以赋予角色。

使用GRANT和REVOKE命令可授予以及取消权限和角色。用户组PUBLIC既不是用户也不是角色，也不可删除该用户组。然而，将权限授予PUBLIC时，它们会被授予现在和将来的每个数据库用户。

1. 系统权限
   
   系统权限授予在数据库中执行特定类型操作的权利，如创建用户、改变表空间或删除任意视图。
   
   例如，授予系统权限的示例：
   ```sql
   grant drop any table to scott with admin option;
   ```
   用户SCOTT可删除任意模式中任何一个人的表，WITH GRANT OPTION子句允许SCOTT将最近授予他的权限授予其他用户。

2. 对象权限
   在数据库中的特定对象上可授予对象权限。最常见的对象权限是用于表的SELECT、UPDATE、DELETE和INSERT，用于PL/SQL存储对象的EXECUTE，以及用于授予在表上创建索引权限的INDEX。
   
   例如，用户RJB可在HR模式的JOBS表上执行任意DML命令：
   ```sql
   grant select, update, insert, delete on hr.jobs to rjb;
   ```

### 1.8.2 审核

要审核用户对数据库对象的访问，可以通过使用AUDIT命令在指定对象或操作上建立审核跟踪（audit trail）。可审核SQL语句和对特定数据库对象的访问，操作的成功或失败（或者两者）可记录在审核跟踪表`SYS.AUD$`中，如果`AUDIT_TRAIL`初始参数的值为OS，则记录在O/S文件中。对于每个审核操作，Oracle都创建一条审核记录，其中包括用户名、执行的操作类型、涉及的对象以及时间戳。各种数据字典视图，如`DBA_AUDIT_TRAIL`和`DBA_FGA_AUDIT_TRAIL`，可以较容易地解释来自原始审核跟踪表SYS.AUD$的结果。

**需要注意的是，对数据库对象进行过度审核可能会对性能产生负面影响。应该先对关键的权限和对象进行基础审核，然后在基础审核表明潜在问题时再扩展审核。**

### 1.8.3 细粒度的审核

细粒度的审核功能是Oracle 9i的新增功能，在Oracle 10g、11g和Oracle 12c中得到了增强，并进一步地扩展了审核：在EMPLOYEE表上执行SELECT语句时，标准审核可以进行检测；细粒度的审核将生成一条包含EMPLOYEE表中特定访问列的审核记录，例如SALARY列。

使用DBMS_FGA程序包和数据字典视图DBA_FGA_AUDIT_TRAIL可实现细粒度的审核。数据字典视图DBA_COMMON_AUDIT_TRAIL将DBA_AUDIT_TRAIL中的标准审核记录和细粒度的审核记录结合在一起。


### 1.8.4 虚拟私有数据库

Oracle的虚拟私有数据库（Virtual Private Database）特性从Oracle 8i开始引入，它将细粒度的访问控制和安全应用程序上下文结合起来。安全策略附加到数据，而不是附加到应用程序，这就确保了安全规则的实施与数据访问方式无关。

例如，一个医疗应用程序上下文可能根据访问数据的病人标识号返回一个谓词，在WHERE子句中使用该谓词可确保从表中检索的数据只是与该病人相关的数据。

### 1.8.5 标号安全性

Oracle的标号安全性（Label Security）提供了“VPD Out-of-the-Box（预设值）”解决方案，VPD即Virtual Private Database（虚拟专用数据库）；根据请求访问的用户标号和表自身行上的标号，该解决方案可限制对任何表中行的访问。Oracle标号安全性管理员不需要任何特殊的编程技巧就可以将安全性策略标号赋给用户和表中的行。

例如，高粒度的数据安全性方法允许应用程序服务提供商（Application Service Provider，ASP）的DBA只创建账户可接收应用程序的一个实例，并且使用标号安全性来限制每个表中的行只包括单个公司的账户可接收信息。

## 1.9 RAC

数据库和实例是一对多的关系，即一个数据库对应多个实例。

Oracle的实时应用群集（Real Application Cluster，RAC）允许不同服务器上的多个实例访问相同的数据库文件。

无论是计划内的断电，还是意外断电，RAC装备都提供了相当高的可用性。可以使用新的初始参数重新启动一个实例，而另一个实例仍然服务于针对数据库的请求。如果一个硬件服务器由于某种故障而崩溃，则另一个服务器上的Oracle实例将继续处理事务，即使从连接到崩溃服务器的用户看来，这个过程也是透明的，且具有最短的停机时间。

然而，RAC并不是一种只针对软件的解决方案：实现RAC的硬件也必须满足特定要求。共享数据库应该在支持RAID的磁盘子系统上，从而确保存储系统的每个组件都是容错的。此外，RAC需要在群集中的节点之间具有高速互连或私有网络，从而使用缓存融合（Cache Fusion）机制支持一个实例到另一个实例的通信和块传输。

一个双节点的RAC如下图所示：

![Alt text](image-11.png)

## 1.10 流

作为Oracle企业版的一个组成部分，Oracle流是Oracle基础结构的高级组成部分，它是RAC的补充。Oracle流允许数据和事件在同一个数据库中或两个数据库之间平稳地流动和共享。它是Oracle众多高可用性解决方案的一个关键部分，用于配合并增强Oracle的消息队列、数据复制和事件管理功能。

## 1.11 企业管理器

Oracle企业管理器(Oracle Enterprise Manager，OEM)是一组重要工具，用于帮助对Oracle基础结构的所有组成部分进行综合性管理，包括Oracle数据库实例、Oracle应用服务器及Web服务器。如果第三方应用程序存在管理代理，则OEM可在任何与Oracle的提供目标相同的框架中管理第三方应用程序。

OEM通过IE、Firefox或Chrome完全支持Web，因此支持IE、Firefox或Chrome的任意操作系统平台都可以用于启动OEM控制台。

使用具有Oracle网格控制(Grid Control)的OEM时，需要做的一个关键决定是选择管理仓库(management repository)的存储位置。OEM管理仓库存储在与管理或监控的节点或服务分离的数据库中。它将来自节点和服务的元数据集中起来，为管理这些节点提供了方便。因此，应该经常备份对仓库数据库的管理，并将该备份与被管理的数据库隔离。OEM的安装提供了大量的“预设”值。当OEM安装完成时，已经准备好建立电子邮件通知，用于向SYSMAN或其他任何符合关键条件的电子邮件账户发送消息，并且自动完成初始目标的发现。

## 1.12 初始化参数

Oracle数据库使用初始参数来配置内存设置和磁盘位置等。有两种方法可用于存储初始参数：使用可编辑的文本文件和使用服务器端的二进制文件。不管采用什么方法来存储初始参数，都存在一组已定义的基本初始参数（从Oracle 10g开始），**每个DBA在创建新的数据库时都应该熟悉这些初始参数**。

从Oracle 10g开始，初始参数主要分为两类：基本初始参数和高级初始参数。因为Oracle越来越自动化管理，所以DBA每天必须熟悉和调整的参数数量正逐渐减少。

### 1.12.1 基本初始参数

下表列出了Oracle 12c的基本初始参数，并进行了简要描述。随后会对这些参数做进一步的解释，并对应该如何设置其中的一些参数给出建议，这取决于硬件和软件环境、应用程序类型以及数据库中的用户数量。

参考官方文档：[Basic Initialization Parameters](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/basic-initialization-parameters.html#GUID-D75F1A77-47E2-4F35-B145-44B3A10ED85C)

| 初始化参数 | 说明 |
| - | - |
| CLUSTER_DATABASE | 启用该节点作为群集的一个成员 |
| COMPATIBLE | 允许安装新的数据库版本，同时确保与该参数指定的版本兼容 |
| CONTROL_FILES | 指定该实例的控制文件的位置 |
| DB_BLOCK_SIZE | 指定Oracle块的大小。这种块大小用于创建数据库时的SYSTEM、SYSAUX 和临时表空间 |
| DB_CREATE_FILE_DEST | OMF数据文件的默认位置。如果没有设置DB_CREATE_ONLINE_LOG_DEST_n，该参数也用于指定控制文件和重做日志文件的位置 |
| DB_CREATE_ONLINE_LOG_DEST_n | OMF 控制文件和联机重做日志文件的默认位置 |
| DB_DOMAIN | 数据库驻留在分布式数据库系统中的逻辑域名（如us.oracle.com） |
| DB_NAME | 最多8个字符的数据库标识符。放置在DBDOMAIN值的前面，形成完全限定的名称（如marketing。us.oracle.com） |
| DB_RECOVERY_FILE_DEST | 恢复区域的默认位置。必须和DB_RECOVERY_FILE_DEST_SIZE一起设置 |
| DB_RECOVERY_FILE_DEST_SIZE | 以字节为单位的文件最大尺寸，该文件用于在恢复区域位置的恢复 |
| DB_UNIQUE_NAME | 数据库的全局唯一名称，它可将同一DB_DOMAIN中具有相司DBNAME的数据库区分开 |
| INSTANCE_NUMBER | 在RAC安装中，群集中该节点的实例数量 |
| LDAP_DIRECTORY_SYSAUTH | 为具有SYSDBA和SYSOPER角色的用户启用或禁用基于目录的授权 |
| LOG_ARCHIVE_DEST_n | 对于ARCHIVELOG模式，最多有31个位置用于发送归档的日志文件 |
| LOG_ARCHIVE_DEST_STATE_n | 设置对应的LOGARCHIVEDESTn地点的可用性 |
| NLS_LANGUAGE | 指定数据库的默认语言，包括消息、日和月的名称，以及排序规则（如AMERICAN) |
| NLS_DATE_LANGUAGE | NLS_TERRITORY的派生，指定用于拼写由TO_DATE和TO_CHAR返回的日、月名称和日期缩写（a.m.、p.m.、AD、BC）的语言功能 |
| NLS_TERRITORY | 用于日和星期编号的地域名称（如SWEDEN、TURKEY或AMERICA） |
| OPEN_CURSORS | 每个会话最多可以打开的游标数量 |
| PGA_AGGREGATE_TARGET | 分配给实例中所有服务器进程的全部内存 |
| PROCESSES | 可同时连接到Oracle的最大操作系统进程数量，SESSIONS和TRANSACTIONS从这个值派生 |
| REMOTE_LISTENER | 网络名称，分析该名称可了解Oracle Net 远程监听器 |
| REMOTE_LOGIN_PASSWORDFILE | 指定Oracle 如何使用密码文件，RAC中必须使用该参数 |
| SESSIONS | 最大会话数量，也可表示实例中同时具有的用户数量。默认值为1.1*PROCESSES+5。Oracle 建议，除非在极特殊情况下否则应使用该参数的默认值 |
| SGA_TARGET | 指定所有SGA 组成部分的全部大小，该参数自动确定DB_CACHE_SIZE、SHARED POOL_SIZE、LARGE_POOLSIZE、STREAMS_POOL_SIZE和JAVA_POOL_SIZE |
| SHARED_SERVERS | 启动实例时分配的共享服务器进程数量 |
| STAR_TRANSFORMATION_ENABLED | 开始执行查询时控制查询优化 |
| UNDO_TABLESPACE | 将UNDOMANAGEMENT设置为AUTO时使用的表空间 |

下面列出为每个新数据库设置的一些参数：

1. **COMPATIBLE**

   COMPATIBLE参数允许安装较新版本的Oracle，同时限制新版本的特性集，就像安装了旧的Oracle版本一样。该方法可以很好地用于数据库升级，同时保留与那些在新版本软件下运行可能会失败的应用程序的兼容性。当重做或重写应用程序，使其在新版本的数据库中工作时，可以重新设置COMPATIBLE参数。
   
   使用该参数的缺点在于，没有任何新的数据库应用程序可以利用新的特性，除非将COMPATIBLE参数设置为与当前版本相同的值。

2. **DB_NAMEDB_NAME**
   
   指定数据库名称的本地部分。该参数最多可为8个字符，并且必须以字母或数字字符开头。一旦设置该参数，就只能用Oracle DBNEWID实用程序（nid）改变该参数。DB_NAME在数据库的每个数据文件、重做日志文件和控制文件中记录。在数据库启动时，该参数的值必须匹配控制文件中记录的DB_NAME的值。

3. **DB_DOMAIN**

   DB_DOMAIN指定驻留数据库的网络域的名称。在分布式数据库系统中，DB_NAME和DB_DOMAIN结合起来的值必须唯一。

4. **DB_RECOVERY_FILE_DEST 和 DB_RECOVERY_FILE_DEST_SIZE**
   
   当由于实例故障或介质故障而进行数据库恢复操作时，可方便地使用闪回恢复区（flash recovery area）来存储和管理与恢复或备份操作相关的文件。从Oracle 10g开始，参数DB_RECOVERY_FILE_DEST可以是本地服务器上的目录位置、网络目录位置或ASM磁盘区域。参数DB_RECOVERY_FILE_DEST_SIZE限制了允许将多少空间分配给恢复或备份文件。
   
   这些参数都是可选的，但如果指定了这些参数，RMAN就可以自动管理备份和恢复操作需要的文件。这种恢复区域的尺寸应该足够大，从而可以保存所有数据文件、递增的RMAN备份、联机重做日志、尚未备份到磁带的归档日志文件、SPFILE和控制文件的两个副本。

5. **CONTROL_FILES**
   
   创建数据库时，CONTROL_FILES参数并不是必需的。如果未指定该参数，Oracle将在默认位置创建控制文件。或者，如果配置了OMF，则在由DB_CREATE_FILE_DEST或DB_CREATE_ONLINE_LOG_DEST_n指定的位置和由DB_RECOVERY_FILE_DEST指定的次级位置创建控制文件。一旦创建了数据库，如果正在使用SPFILE，则CONTROL_FILES参数反映控制文件位置的名称；如果正在使用文本初始参数文件，则必须以手动方式将位置添加到此文件。

   然而，本书**强烈推荐在单独的物理卷上创建控制文件的多个副本。控制文件对于数据库完整性至关重要，并且非常小，应该在单独的物理磁盘上创建至少3个多元复用的控制文件副本**。此外，应该执行ALTER DATABASE BACKUP CONTROLFILE TO TRACE命令，用于在发生大灾难时创建文本格式的控制文件副本。

   指定3个用于控制文件副本的位置：
   ```sql
   control_files = (/u01/oracle19c/ctl/control01.ctl,
                     /u03/oracle19c/ctl/control02.ctl,
                     /u07/oracle19c/ctl/control03.ctl)
   ```

6. **DB_BLOCK_SIZE**

   参数DB_BLOCK_SIZE指定数据库中默认Oracle块的大小。在创建数据库时，使用该块大小创建SYSTEM、TEMP和SYSAUX表空间。理想情况下，该参数应等于操作系统块大小或是操作系统块大小的倍数，从而提高I/O效率。

   在Oracle 9i之前，可为OLTP系统指定较小的块大小（4KB或8KB），并为DSS（Decision Support System，决策支持系统）数据库指定较大的块大小（最大为32KB）。然而，现在的表空间最多可以有5种块大小共存于同一数据库中，DB_BLOCK_SIZE采用较小的值比较好。然而，一般倾向于使用8KB作为所有数据库的最小值，除非已经在目标环境中严格证明4KB的块大小不会造成性能问题。Oracle建议，除非有特殊原因（例如许多表的行宽超过8KB），在Oracle Database 12c中，对于每个数据库而言，8KB都是理想的块大小。

7. **SGA_TARGET**

   Oracle 12c还可通过另一种方式为“设置它然后忘记它”数据库提供方便，就是能够指定所有SGA组成部分的内存总数。如果指定SGA_TARGET，参数DB_CACHE_SIZE、SHARED_POOL_SIZE、LARGE_POOL_SIZE、STREAMS_POOL_SIZE和JAVA_POOL_SIZE将由ASMM（Automatic Shared Memory Management，自动共享内存管理）自动确定其大小。如果设置SGA_TARGET时手动指定了这4个参数中任何一个参数的大小，那么ASMM将使用手动方式指定大小参数作为最小值。

   一旦实例启动，自动确定大小的参数就可以动态递增或递减，只要没有超出参数SGA_MAX_SIZE指定的值即可。参数SGA_MAX_SIZE指定整个SGA的硬上限，不可以超出或改变这个值，除非重新启动实例。

   不论如何指定SGA的大小，都需要确保服务器中有足够可用的空闲物理内存来保存SGA的组成部分和所有后台进程，否则将会产生过多分页，从而影响性能。

8. **MEMORY_TARGET**
   
   按照Oracle文档的说法，MEMORY_TARGET并不是一个“基本”参数，但是它可以极大地简化实例内存管理。此参数指定Oracle系统范围内的可用内存，然后Oracle在SGA和PGA之间重新分配内存，以优化性能。该参数在一些硬件和OS组合上不可用。例如，如果在Linux操作系统上定义了大页面，就无法使用MEMORY_TARGET。

9. **DB_CACHE_SIZE 和 DB_nK_CACHE_SIZE**

   参数DB_CACHE_SIZE指定SGA中用于保存默认大小的块的区域大小，这些块包括来自于SYSTEM、TEMP和SYSAUX表空间的块。如果一些表空间的块大小不同于SYSTEM和SYSAUX表空间的块大小，那么最多可以定义4个其他的缓存。n的值可以是2、4、8、16和32，如果n的值与默认块大小相同，则对应的DB_nK_CACHE_SIZE参数为非法。虽然这个参数不是基本初始参数，但在从具有不同于DB_BLOCK_SIZE的块大小的另一个数据库中传送表空间时，该参数就成为非常基本的初始参数。

   包括多个块大小的数据库具有非常明显的优点。处理OLTP应用程序的表空间可以有较小的块大小，而具有数据仓库表的表空间则可以有较大的块大小。除非行异常大，需要使用较大的块大小来避免单行跨越块边界，8KB块几乎总是最合理的块大小。然而，在为多个缓存大小分配内存时需要注意，不要将过多的内存分配给一个缓存大小，因为这会影响到分配给另一个缓存大小的内存。如果必须使用多个块大小，则使用Oracle的Buffer Cache Advisory特性，在视图V$DB_CACHE_ADVICE中监控每个缓存大小的缓存利用率，从而帮助指定这些内存区域的大小。

10. **SHARED_POOL_SIZE、LARGE_POOL_SIZE、STREAMS_POOL_SIZE 和 JAVA_POOL_SIZE**
    
    参数SHARED_POOL_SIZE、LARGE_POOL_SIZE、STREAMS_POOL_SIZE及JAVA_ POOL_SIZE分别用于确定共享池、大型池、流池和Java池的大小，如果指定了SGA_TARGET初始参数，则Oracle自动设置这些参数。

11. **PROCESSES**

   PROCESSES初始参数的值表示可同时连接到数据库的进程总数，包括后台进程和用户进程。PROCESSES参数的良好起点可以是后台进程数50加上期望的最大并发用户数，对于较小的数据库来说，150是良好的起点，因为将PROCESSES参数设置过大几乎不会带来多少额外的系统开销。一个小型部门级数据库的值可能是256。我习惯设置为2000。

12. **UNDO_MANAGEMENT 和 UNDO_TABLESPCAE**
    
    Oracle 9i中引入了AUM（Automatic Undo Management，自动撤消管理），当试图分配正确数量和大小的回滚段以便处理事务的撤消信息时，AUM能消除（或至少大大减少）麻烦。相反，它为所有撤消操作（除了SYSTEM回滚段）指定了一个撤消表空间，在将UNDO_MANAGEMENT参数设置为AUTO时，系统自动处理所有撤消管理。

### 1.12.2 高级初始参数

高级初始参数包括没有列在此处的其他初始参数，在Oracle Database 12c的版本1中共有368个初始参数。设置基本初始参数时，Oracle实例可自动设置并调整大多数高级初始参数。


# 2 安装和升级Oracle Database 19c

## 2.1 升级到19c

如果你已经安装了Oracle数据库服务器较早的版本，则可以将数据库升级到Oracle Database 12c。有多种升级方式可以选择，正确的选择将取决于当前的Oracle软件版本和数据库大小等因素。

当从以前的版本升级时，先安装可以提供Oracle升级前信息的工具（Oracle Pre-Upgrade Information Tool），对已有数据库使用该工具可以对升级到Oracle Database 12c时潜在的兼容问题发出警报。

只有在当前数据库使用如下Oracle版本之一时，才支持将数据库直接升级到版本19c：11.2.0、12.1.0.2、12.2.0.1、18。

要升级数据库，有4种选择：

- **使用数据库升级助手（Database Upgrade Assistant，DBUA）来指导并在适当的位置执行升级**。在升级期间，旧数据库将成为Oracle 12c数据库。DBUA支持Oracle RAC（实时应用群集）和ASM（自动存储管理）。既可以在安装时启动DBUA，也可将DBUA作为安装后的一个独立工具。Oracle强烈建议对Oracle Database主要版本或补丁版本升级使用DBUA。

- **执行数据库的手动升级**。在这个过程中，旧数据库将成为Oracle 12c数据库。即使非常谨慎地控制该过程的每个步骤，但如果漏掉一个步骤或忘记某个必要的步骤，这种方法也容易产生错误。

- **使用Oracle Data Pump（Oracle数据泵）实用程序将数据从较早的Oracle版本移动到Oracle 12c数据库**。将使用两个单独的数据库：旧数据库作为导出源，而新数据库作为导入的目标。如果是从Oracle Database 11g升级，则使用Oracle Data Pump将数据从旧数据库移动到新数据库。尽管Oracle Data Pump是推荐使用的迁移方法，但也可以使用原来的导入／导出方式（imp和exp）从Oracle Database 10g和更早版本中导出数据，然后导入Oracle Database 12c。

- **将数据从较早的Oracle版本复制到Oracle 12c数据库**。将使用两个单独的数据库：旧数据库作为复制源，新数据库作为复制目标。这种方法最直截了当，因为数据的转移主要是由引用旧数据库和新数据库的CREATE TABLE AS SELECT SQL语句组成的。但是，除非数据库只有很少的表，且不涉及已有的SQL调整集和统计信息等，否则Oracle不建议对生产数据库采用这种方法。一个例外是迁移到Oracle Exadata，此时，该方法允许利用诸如HCC（Hybrid Columnar Compression）和分区的Exadata特性，权衡一下，其优点超出了使用该方法的缺点。

总的来说，通过数据库升级助手或手动升级方式，在适当的位置升级数据库，这称为“直接升级”。因为直接升级不涉及为升级数据库创建第二个数据库，所以相对于间接升级，它可以更快完成，需要的磁盘空间也较少。

## 2.2 新安装19c

参见：[rac-installation-guide-linux.md](../19C-RAC-Install/rac-installation-guide-linux.md)

# 3 表空间管理

# 4 物理数据库布局和存储管理
## 4.1 传统磁盘空间存储
## 4.2 自动存储管理

### 4.2. 准备 ASM 磁盘

一、关闭虚拟机后，进入虚拟机目录创建将要用于 asm 的磁盘（一般为偶数个，且大小一样）。

![添加磁盘](./image/Snipaste_2023-10-15_17-44-53.png)

二、启动后检查安装后的磁盘情况：
```bash
[root@19c-Grid grid]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sdf      8:80   0    1G  0 disk
`-sdf1   8:81   0 1023M  0 part
sdd      8:48   0    1G  0 disk
`-sdd1   8:49   0 1023M  0 part
sdb      8:16   0    1G  0 disk
`-sdb1   8:17   0 1023M  0 part
sdk      8:160  0    2G  0 disk
sdi      8:128  0    1G  0 disk
`-sdi1   8:129  0 1023M  0 part
sr0     11:0    1  4.5G  0 rom
sdg      8:96   0    1G  0 disk
`-sdg1   8:97   0 1023M  0 part
sde      8:64   0    1G  0 disk
`-sde1   8:65   0 1023M  0 part
sdc      8:32   0    1G  0 disk
`-sdc1   8:33   0 1023M  0 part
sda      8:0    0   80G  0 disk
|-sda2   8:2    0    8G  0 part [SWAP]
|-sda3   8:3    0   71G  0 part /
`-sda1   8:1    0    1G  0 part /boot
sdj      8:144  0    2G  0 disk
sdh      8:112  0    1G  0 disk
`-sdh1   8:113  0 1023M  0 part


[root@19c-Grid dev]# ll /dev/sdj /dev/sdk
brw-rw---- 1 root disk 8, 144 Oct 15 17:53 /dev/sdj
brw-rw---- 1 root disk 8, 160 Oct 15 17:40 /dev/sdk
```

新添加的磁盘为sdj和sdk。

三、配置 udev：

方法1：
```bash
[root@19c-Grid dev]# fdisk /dev/sdj
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x8257eb7d.

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-4194303, default 2048):
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-4194303, default 4194303):
Using default value 4194303
Partition 1 of type Linux and of size 2 GiB is set

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.


[root@19c-Grid dev]# lsblk | grep sdj
sdj      8:144  0    2G  0 disk
`-sdj1   8:145  0    2G  0 part
```


方法2：
```bash
[root@19c-Grid dev]# echo -e "n\np\n1\n\n\nw" | fdisk /dev/sdk
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x3ae728d3.

Command (m for help): Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): Partition number (1-4, default 1): First sector (2048-4194303, default 2048): Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-4194303, default 4194303): Using default value 4194303
Partition 1 of type Linux and of size 2 GiB is set

Command (m for help): The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

```
ps：`\n`为回车。

四、查询这些磁盘的 scsi id
```bash
[root@19c-Grid dev]# /usr/lib/udev/scsi_id -g -u -d /dev/sdj1
36000c29abe0877e28fe0ca0aeac43783
[root@19c-Grid dev]# /usr/lib/udev/scsi_id -g -u -d /dev/sdk1
36000c29f94e948b7aecb0c16450997bd
```

五、编辑udev规则文件 /etc/udev/rules.d/99-oracle-asmdevices.rules
```bash
[root@19c-Grid rules.d]# vim 99-oracle-asmdevices.rules
KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$parent", RESULT=="36000c29abe0877e28fe0ca0aeac43783", SYMLINK+="asmdisks/asmdisk09", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$parent", RESULT=="36000c29f94e948b7aecb0c16450997bd", SYMLINK+="asmdisks/asmdisk10", OWNER="grid", GROUP="asmadmin", MODE="0660"
```

六、启动 udev
```bash
[root@19c-Grid rules.d]# /sbin/partprobe /dev/sdj1
[root@19c-Grid rules.d]# /sbin/partprobe /dev/sdk1
[root@19c-Grid rules.d]# /sbin/udevadm trigger --type=devices --action=change
```

七、检查磁盘状态
```bash
[root@19c-Grid dev]# ll /dev/sdj1  /dev/sdk1
brw-rw---- 1 grid asmadmin 8, 145 Oct 15 18:16 /dev/sdj1
brw-rw---- 1 grid asmadmin 8, 161 Oct 15 18:14 /dev/sdk1


[root@19c-Grid dev]# ll /dev/asmdisks/asmdisk09 /dev/asmdisks/asmdisk10
lrwxrwxrwx 1 root root 7 Oct 15 18:16 /dev/asmdisks/asmdisk09 -> ../sdj1
lrwxrwxrwx 1 root root 7 Oct 15 18:14 /dev/asmdisks/asmdisk10 -> ../sdk1
```

**ASM磁盘添加完毕！！**

# 5 开发和实现应用程序
# 6 监控空间利用率
# 7 使用和撤销表空间管理事务
# 8 数据库调整
# 9 In-Memory概述
# 10 数据库安全性和审核

# 11 性能优化
## 11.1 swingbench 工具
用于Oracle压力测试
安装
[](https://github.com/domgiles/swingbench-public)
需要java 11环境和Oracle客户端

1.首先下载java11
yum search java-11-openjdk

1.1 选择相应版本（本人是x86_64）
arch 或者 uname -a

1.2 进行下载
yum install java-11-openjdk.x86_64 -y

java -version

2.查看java11下载位置
```sql
ls -rl $(which java)
```


# 13 备份和恢复选项
## 13.1 备份功能

可采用3种标准方法备份Oracle数据库：导出、脱机备份和联机备份。

导出是数据库的逻辑备份，其他两种备份方法是物理文件备份。下面将描述每种选项。用于物理备份的优先考虑的标准工具是Oracle的恢复管理器（Recovery Manager，RMAN）实用程序，有关RMAN的实现和用法的详细信息，请参阅下一章。

健壮的备份策略应包括物理备份和逻辑备份。一般而言，产品数据库将物理备份作为它们的主要备份方法，而将逻辑备份作为次要备份方法。对于开发数据库和某些小型的数据移动处理，逻辑备份是一种可行的解决方案。你应该理解物理和逻辑两种备份方法的内涵和用法，以便开发最合适的应用程序解决方案。

## 13.2 逻辑备份

对一个数据库进行逻辑备份包括读取一组数据库记录并将它们写入一个文件中，这些记录的读取与它们的物理位置无关。在Oracle中，Data Pump Export实用程序执行此类数据库备份。为恢复使用由Data Pump Export实用程序生成的文件，应使用Data Pump Import。

逻辑备份允许DBA或用户获取单个数据库对象在某个特定时间点时的内容，当完整的数据库还原操作对数据库的其余部分影响过大时，逻辑备份提供了一种可替换的恢复选项。

## 13.3 物理备份

物理备份要复制构成数据库的文件，这些备份也称作“文件系统备份”，因为它们涉及使用操作系统文件备份命令。Oracle支持两种不同类型的物理文件备份：脱机备份和联机备份，也分别称为“冷备份”和“热备份”。

数据库的物理备份可确保不会丢失已提交的事务，并且我们可将数据库从任何以前的备份恢复到当前的时间点或者中间的任何时间点。

可使用RMAN实用程序来执行所有的物理备份。可酌情编写你自己的脚本程序来执行物理备份，但这样做无法利用RMAN方法带来的诸多好处。

## 13.4 使用Data Pump Export和Data Pump Import（数据泵）

Oracle Database 10g引入的Data Pump提供了一种基于服务器的数据提取和数据导入实用程序。Data Pump的特点是在体系结构和功能上显著增强了原有的Import和Export实用程序。Data Pump允许停止和重启作业，查看运行作业的状态，以及限制导出和导入的数据。

数据泵是常有的逻辑备份和恢复的工具，也可以用于数据迁移，不能用于介质恢复。

expdp 导出  
impdp 导入

### 13.4.1 创建目录
Data Pump要求为将要创建和读取的数据文件和日志文件创建目录。使用CREATE DIRECTORY命令在Oracle内创建目录指针，指向将使用的外部目录。将要访问Data Pump文件的用户必须拥有该目录的READ和WRITE权限。在开始操作前，要验证外部目录是否存在，而且发出CREATE DIRECTORY命令的用户需要拥有CREATE ANY DIRECTORY系统权限。

注意：在Oracle Database 19c默认安装中，创建了一个称为DATA_PUMP_DIR的目录对象，在多租户环境中，该对象指向目录$ORACLE_BASE/admin/database_name/dpdump。

```sql
[oracle@19c-Grid dpdump]$ cat /u01/app/oracle/admin/lucdb/dpdump/dp.log
Data Pump default directory object created:
directory object name: DATA_PUMP_DIR
Path: /u01/app/oracle/admin/lucdb/dpdump/
creation date: 06-OCT-2023 02:29
```

下例在Oracle实例lucdb中创建了一个名为`DUMP_DIR`的目录对象：
```sql
[oracle@19c-Grid dpdump]$ mkdir -p /home/oracle/tmp

SYS@lucdb(CDB$ROOT)> create directory dump_dir as '/home/oracle/tmp';

col directory_name form a30
col directory_path form a60
SYS@lucdb(CDB$ROOT)> select directory_name,directory_path from dba_directories;

DIRECTORY_NAME                 DIRECTORY_PATH
------------------------------ ------------------------------------------------------------
DUMP_DIR                       /home/oracle/tmp
```

### 13.4.2 expdp 导出

#### 13.4.2.1 expdp 参数

查看导出帮助：
```bash
expdp help=y | more
```

下面列出一些常用的参数：
```bash
The available keywords and their descriptions follow. Default values are listed within square brackets.

ATTACH
Attach to an existing job.
For example, ATTACH=job_name.

CONTENT
Specifies data to unload.
Valid keyword values are: [ALL], DATA_ONLY and METADATA_ONLY.

DIRECTORY
Directory object to be used for dump and log files.

DUMPFILE
Specify list of destination dump file names [expdat.dmp].
For example, DUMPFILE=scott1.dmp, scott2.dmp, dmpdir:scott3.dmp.

ESTIMATE_ONLY
Calculate job estimates without performing the export [NO].

INCLUDE
Include specific object types.
For example, INCLUDE=TABLE_DATA.

EXCLUDE
Exclude specific object types.
For example, EXCLUDE=SCHEMA:"='HR'".

FILESIZE
Specify the size of each dump file in units of bytes.

FLASHBACK_TIME
Time used to find the closest corresponding SCN value.

FLASHBACK_SCN
SCN used to reset session snapshot.

FULL
Export entire database [NO].

HELP
Display Help messages [NO].

JOB_NAME
Name of export job to create.

LOGFILE
Specify log file name [export.log].

NOLOGFILE
Do not write log file [NO].

NETWORK_LINK
Name of remote database link to the source system.

PARALLEL
Change the number of active workers for current job.

PARFILE
Specify parameter file name.

QUERY
Predicate clause used to export a subset of a table.
For example, QUERY=employees:"WHERE department_id > 10".

SCHEMAS
List of schemas to export [login schema].

STATUS
Frequency (secs) job status is to be monitored where
the default [0] will show new status when available.

TABLES
Identifies a list of tables to export.
For example, TABLES=HR.EMPLOYEES,SH.SALES:SALES_1995.

TABLESPACES
Identifies a list of tablespaces to export.

TRANSPORT_FULL_CHECK
Verify storage segments of all tables [NO].

TRANSPORT_TABLESPACES
List of tablespaces from which metadata will be unloaded.


------------------------------------------------------------------------------
The following commands are valid while in interactive mode.
Note: abbreviations are allowed.

ADD_FILE
Add dumpfile to dumpfile set.

CONTINUE_CLIENT
Return to logging mode. Job will be restarted if idle.

EXIT_CLIENT
Quit client session and leave job running.

FILESIZE
Default filesize (bytes) for subsequent ADD_FILE commands.

HELP
Summarize interactive commands.

KILL_JOB
Detach and delete job.

PARALLEL
Change the number of active workers for current job.

REUSE_DUMPFILES
Overwrite destination dump file if it exists [NO].

START_JOB
Start or resume current job.
Valid keyword values are: SKIP_CURRENT.

STATUS
Frequency (secs) job status is to be monitored where
the default [0] will show new status when available.

STOP_JOB
Orderly shutdown of job execution and exits the client.
Valid keyword values are: IMMEDIATE.

STOP_WORKER
Stops a hung or stuck worker.

TRACE
Set trace/debug flags for the current job.
```

#### 13.4.2.2 expdp导出示例

```bash
-- 全库导出 full=y
expdp \'sys/sys@localhost:1321/pdb1 as sysdba\' full=y dumpfile=pdb1_full_20231012.dmp directory=dump_dir;
pwd
/home/oracle/tmp
ll
total 3936
-rw-r--r-- 1 oracle asmadmin   10789 Oct 12 01:31 export.log
-rw-r----- 1 oracle asmadmin 4018176 Oct 12 01:31 pdb1_full_20231012.dmp

-- schemas 按用户导出
expdp \'sys/sys@localhost:1321/pdb1 as sysdba\' schemas=hr dumpfile=expdp_hr.dmp directory=dump_dir logfile=expdp_hr.log;

--普通用户执行
grant create any directory to hr;
expdp \'hr/hr@localhost:1321/pdb1\' schemas=hr dumpfile=expdp_hr.dmp directory=dump_dir;

--按表空间导出
expdp \'sys/sys@pdb1 as sysdba\' tablespaces=users dumpfile=expdp_ts_users.dmp directory=dump_dir

--导出两张表
expdp \'hr/hr@pdb1\' tables=employees,dept dumpfile=expdp_tab_ed.dmp directory=dump_dir logfile=expdp_tab_ed.log

--按查询条件导出
expdp \'hr/hr@pdb1\' tables=employees QUERY=employees:"WHERE department_id > 10" dumpfile=expdp_tab_emp1.dmp directory=dump_dir

--估算导出的数据量
[oracle@19c-Grid tmp]$ expdp \'sys/sys@localhost:1321/pdb1 as sysdba\' full=y estimate_only=y

Estimate in progress using BLOCKS method...
...
Total estimation using BLOCKS method: 3.859 MB
```

### 13.4.3 impdp 导入
#### 13.4.3.1 impdp 参数

查看导入帮助：
```bash
impdp help=y | more
```

常用参数和expdp差不多。

#### 13.4.3.1 impdp导入示例

```bash
--1 查询表
SYS@lucdb(CDB$ROOT)> select object_id,object_name from hr.demo;
 OBJECT_ID OBJECT_NAME
---------- ---------------
         9 I_FILE#_BLOCK#
        38 I_OBJ3
2 rows selected.

--2 导出表
[oracle@19c-Grid tmp]$ expdp \'hr/hr@pdb1\' tables=demo dumpfile=expdp_tab_demo.dmp directory=dump_dir logfile=expdp_tab_demo.log

--3 删除表
SYS@lucdb(CDB$ROOT)> drop table hr.demo;
Table dropped.

--4 导入表
[oracle@19c-Grid tmp]$ impdp \'hr/hr@pdb1\' tables=demo dumpfile=expdp_tab_demo.dmp directory=dump_dir;

--5 删除的表导入后存在
SYS@lucdb(CDB$ROOT)> select object_id,object_name from hr.demo;
 OBJECT_ID OBJECT_NAME
---------- ---------------
         9 I_FILE#_BLOCK#
        38 I_OBJ3
2 rows selected.
```


### 13.4.4 交互模式

导入导出过程中用`ctrl+c`进行交互模式

在交互模式下使用`help`查看帮助，可以查看参数等信息。

示例：
```bash
[oracle@19c-Grid tmp]$ expdp \'sys/sys@localhost:1321/pdb1 as sysdba\' full=y dumpfile=pdb1_full_20231012.dmp directory=dump_dir;

Export: Release 19.0.0.0.0 - Production on Fri Oct 13 00:19:10 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Starting "SYS"."SYS_EXPORT_FULL_01":  "sys/********@localhost:1321/pdb1 AS SYSDBA" full=y dumpfile=pdb1_full_20231012.dmp directory=dump_dir
Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
^C
Export> status

Job: SYS_EXPORT_FULL_01
  Operation: EXPORT
  Mode: FULL
  State: EXECUTING
  Bytes Processed: 0
  Current Parallelism: 1
  Job Error Count: 0
  Job heartbeat: 1
  Dump File: /home/oracle/tmp/pdb1_full_20231012.dmp
    bytes written: 4,096

Worker 1 Status:
  Instance ID: 1
  Instance name: lucdb
  Host name: 19c-Grid
  Object start time: Friday, 13 October, 2023 0:19:28
  Object status at: Friday, 13 October, 2023 0:19:31
  Process Name: DW00
  State: EXECUTING

Export>

Export> parallel=2

Export> status

Job: SYS_EXPORT_FULL_01
  Operation: EXPORT
  Mode: FULL
  State: EXECUTING
  Bytes Processed: 0
  Current Parallelism: 2
  Job Error Count: 0
  Job heartbeat: 3
  Dump File: /home/oracle/tmp/pdb1_full_20231012.dmp
    bytes written: 114,688

Worker 1 Status:
  Instance ID: 1
  Instance name: lucdb
  Host name: 19c-Grid
  Object start time: Friday, 13 October, 2023 0:20:54
  Object status at: Friday, 13 October, 2023 0:21:03
  Process Name: DW00
  State: EXECUTING

Export> continue_client
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA

...

Master table "SYS"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
******************************************************************************
Dump file set for SYS.SYS_EXPORT_FULL_01 is:
  /home/oracle/tmp/pdb1_full_20231012.dmp
Job "SYS"."SYS_EXPORT_FULL_01" successfully completed at Fri Oct 13 00:23:42 2023 elapsed 0 00:04:31

```


### 13.4.5 exp 和 imp
exp 和 imp 是 ORACLE 幸存的最古老的两个命令行工具，可以把它作为小型
数据库的物理备份后的一个逻辑辅助备份。对于越来越大的数据库，EXP/IMP
越来越力不从心。

```bash
--查看帮助
exp help=y

--完全模式
exp sys/sys@pdb1 buffer=64000 file=/home/oracle/tmp/full.dmp full=y

--用户模式,这样用户hr的所有对象被输出到文件中
exp hr/hr buffer=64000 file=/home/oracle/tmp/hr.dmp owner=hr
EXP-00056: ORACLE error 1017 encountered
ORA-01017: invalid username/password; logon denied
Username: hr@pdb1
Password:

--表模式：
exp hr/hr@pdb1 tables=emp file=/home/oracle/tmp/dept.dmp
```

### 13.4.5 exp/imp 与 expdp/impdp 的区别
1、exp 和 imp 是客户端工具程序，它们既可以在客户端使用，也可以在服务端使用。

2、expdp 和 impdp 是服务端的工具程序，他们只能在 Oracle 服务端使用，不能在客户端使用。

3、imp 只适用于 exp 导出的文件，不适用于 expdp 导出文件；impdp 只适用于 expdp 导出的文件，而不适用于 exp 导出文件。

4、对于 10g 以上的服务器，使用 exp 通常不能导出 0 行数据的空表，而此时必须使用 expdp 导出。

## 13.5 实现脱机备份（冷备份）

冷备份是指关闭数据库的备份，又称脱机备份或一致性备份，在冷备份开始前数据库必须彻底关闭。脱机备份是指在通过SHUTDOWN NORMAL、SHUTDOWN IMMEDIATE或SHUTDOWN TRANSACTIONAL命令关闭数据库后对数据库文件所执行的物理备份。当关闭数据库时，将备份数据库正在使用的每个文件。这些文件为该数据库提供了一个在关闭它时存在期间的完整映像。

冷备份通常适用于业务具有阶段性的企业，比如白天运行、夜间可以停机维护的企业，冷备份操作简单，但是需要关闭数据库，对于需要24×7提供服务的企业是不适用的。

在冷备份过程中应备份以下文件：
1. 所有数据文件
2. 所有控制文件
3. 所有归档的重做日志文件
4. 初始化参数文件或服务器参数文件（SPFILE）
5. 密码文件

在恢复期间，脱机备份可将数据库恢复到它关闭时的状态。脱机备份一般用于灾难恢复计划中，因为它们是自包含的，并且在灾难恢复服务器上它们比其他类型的备份更容易还原。如果数据库正运行在ARCHIVELOG模式下，则可将最近归档的重做日志应用于还原的脱机备份，以便将数据库恢复到发生介质故障或数据库完全丢失时的时间点。

贯穿全书一直强调的一点是，如果使用RMAN，则消除或最小化了冷备份的需要。你的数据库可能从来不需要关机进行冷备份（除非遇到灾难——在此情况下也要确保创建RAC数据库）。

### 13.5.1 冷备份操作

以下几个查询在备份之前应当执行，以确认数据库文件及存储路径：
```sql
SQL> select name from v$datafile;

SQL> select member from v$logfile;

SQL> select name from v$controlfile;
```

冷备份的通常步骤是：

1. 正常关闭数据库；
2. 备份所有**重要**的文件到备份目录；
3. 完成备份后启动数据库。

为了恢复方便，冷备份应该包含所有的数据文件、控制文件和日志文件，这样当需要采用冷备份进行恢复时，只需要将所有文件恢复到原有位置，就可以启动数据库了。

```bash
--正常关闭数据库
SYS@lucdb(CDB$ROOT)> shutdown immediate;

--跳转到oracle用户
su - oracle 

--1 复制控制文件到指定目录
cp /u01/app/oracle/oradata/YUAN/control01.ctl /home/oracle/tmp/ctl

--2 复制数据文件到指定的目录
cp /u01/app/oracle/oradata/YUAN/*.dbf /home/oracle/tmp/dbf

--3 复制redo日志文件到指定目录
cp /oradata/orcl/redo*.log /home/oracle/tmp/redo

--4 复制参数文件到指定目
cp /u01/app/oracle/product/19.0.0/db_1/dbs/*.ora /home/oracle/tmp/dbs

--5 口令文件
cp /u01/app/oracle/product/19.0.0/db_1/dbs/orapwlucdb /home/oracle/tmp/dbs
```


### 13.5.2 用冷备份恢复

启动失败时恢复：

```bash
--1 控制文件恢复：
--当有多个控制文件的时候，丢失一个控制文件，可以拷贝其他的控制文件拷贝生成
host cp /u01/app/oracle/oradata/YUAN/control02.ctl /u01/app/oracle/oradata/YUAN/control01.ctl
--也可以使用备份的文件生成
host cp /home/oracle/tmp/control01.ctl /u01/app/oracle/oradata/YUAN/control01.ctl

--2 数据文件：
host cp /home/oracle/tmp/?.dbf /u01/app/oracle/oradata/YUAN/

--3 重做日志文件
host cp /home/oracle/tmp/redo /oradata/orcl/

--4 参数文件
host cp /home/oracle/tmp/dbs/*.ora /u01/app/oracle/product/19.0.0/db_1/dbs/

--5 口令文件
host cp /home/oracle/tmp/dbs/orapwlucdb /u01/app/oracle/product/19.0.0/db_1/dbs/
```

## 13.6 实现联机备份 （热备份）
由于冷备份需要关闭数据库，所以已经很少有企业能够采用这种方式进行备份了。然而，当数据库运行在**归档模式**下时，Oracle也允许用户对数据库进行物理备份，这样的备份称为“联机备份”，习惯叫”热备份“。

Oracle采用循环方式将日志写入联机重做日志文件中：写满第一个日志文件后，它开始将日志写入第二个文件直到写满该文件，然后开始将日志写入第三个文件。一旦写满最后一个联机重做日志文件，日志写入器（Log Writer，LGWR）后台进程开始重写第一个重做日志文件的内容。

当Oracle在ARCHIVELOG模式下运行时，在LGWR进程完成写入到重做日志文件后，archiver后台进程（ARC0~ARC9和ARCa~ARCt）将制作每个重做日志文件的副本。通常将这些归档的重做日志文件写入磁盘设备，也可以将它们直接写入到磁带设备中，但是这种方法往往需要操作员耗费非常大的精力。

---

热备份又可以简单的分为两种：用户管理的热备份（user-managed backup and recovery,）和Oracle管理的热备份（Recovery Manager-RMAN）：

1. 用户管理的热备份是指用户通过将表空间置于热备份模式下，然后通过操作系统工具对文件进行复制备份，备份完成后再结束表空间的备份模式；
2. Oracle管理的热备份通常指通过RMAN对数据库进行联机热备份，RMAN执行的热备份不需要将表空间置于热备模式，从而可以减少对于数据库的影响获得性能提升。另外RMAN的备份信息可以通过控制文件或者额外的目录数据库进行管理，功能强大但是相对复杂（详细在第14章介绍）。

### 13.6.1 热备份前提

为利用ARCHIVELOG功能，必须首先将数据库置于ARCHIVELOG模式下。在启动处于ARCHIVELOG模式的数据库前，要确保正在使用下列配置之一，这些配置是按照它们的推荐使用顺序而排列的，第一种配置最好：

1. 启用只归档到快速恢复区，对包含快速恢复区的磁盘使用磁盘镜像。DB_RECOVERY_FILE_DEST参数指定文件系统的位置或包含快速恢复区的ASM磁盘组。Oracle建议最好在镜像的ASM磁盘组（与主磁盘组分离）创建快速恢复区。
2. 启用归档到快速恢复区，并至少将一个LOG_ARCHIVE_DEST_n参数设置为快速恢复区外部的另一个位置。
3. 启用归档到快速恢复区，并至少将一个LOG_ARCHIVE_DEST_n参数设置为快速恢复区外部的另一个位置。

归档日志路径的三个参数：
```sql
DB_RECOVERY_FILE_DEST：指定闪回恢复区路径。（在无DG的情况下）

LOG_ARCHIVE_DEST：指定归档文件存放的路径，该路径只能是本地磁盘，默认为空。

LOG_ARCHIVE_DEST_n：默认值为空。Oracle最多支持把日志文件归档到10个地方，n从1到10。归档地址可以为本地磁盘，或者网络设备。
```

三者的关系：
1. 如果设置了DB_RECOVERY_FILE_DEST，就不能设置LOG_ARCHIVE_DEST，默认的归档日志存放于DB_RECOVERY_FILE_DEST指定的闪回恢复区中。  
   可以设置LOG_ARCHIVE_DEST_n，如果这样，那么归档日志不再存放于DB_RECOVERY_FILE_DEST中，而是存放于LOG_ARCHIVE_DEST_n设置的目录中。如果想要归档日志继续存放在DB_RECOVERY_FILE_DEST中，可以通过如下命令：  
   alter system set log_archive_dest_1='location=USE_DB_RECOVERY_FILE_DEST';
2. 如果设置了LOG_ARCHIVE_DEST，就不能设置LOG_ARCHIVE_DEST_n和DB_RECOVERY_FILE_DEST。如果设置了LOG_ARCHIVE_DEST_n，就不能设置LOG_ARCHIVE_DEST。也就是说，LOG_ARCHIVE_DEST参数和DB_RECOVERY_FILE_DEST、LOG_ARCHIVE_DEST_n都不共存。而DB_RECOVERY_FILE_DEST和LOG_ARCHIVE_DEST_n可以共存。
3. LOG_ARCHIVE_DEST只能与LOG_ARCHIVE_DUPLEX_DEST共存。这样可以设置两个归档路径。LOG_ARCHIVE_DEST设置一个主归档路径，LOG_ARCHIVE_DUPLEX_DEST设置一个从归档路径。所有归档路径必须是本地的。
4. 如果LOG_ARCHIVE_DEST_n设置的路径不正确，那么Oracle会在设置的上一级目录归档。比如设置LOG_ARCHIVE_DEST_1='location=+FRA/LUCDB/ONLINELOG/ARCHIVE1'，而OS中并没有ARCHIVE1这个目录，那么Oracle会在+FRA/LUCDB/ONLINELOG路径归档。


注意：如果指定了初始化参数DB_RECOVERY_FILE DEST而没有指定LOG_ARCHIVE_ DEST_n参数，则隐式地将LOG_ARCHIVE_DEST_10参数设置为快速恢复区。



一、查看归档日志路径配置
```sql
SYS@lucdb(CDB$ROOT)> show parameter DB_RECOVERY_FILE_DEST

NAME                                 TYPE                   VALUE
------------------------------------ ---------------------- ------------------------------
db_recovery_file_dest                string                 +FRA
db_recovery_file_dest_size           big integer            1273M


SYS@lucdb(CDB$ROOT)> show parameter LOG_ARCHIVE_DEST_

NAME                                 TYPE                   VALUE
------------------------------------ ---------------------- ------------------------------
log_archive_dest_1                   string
log_archive_dest_10                  string
```

已选择了最佳配置，即单一被镜像的快速恢复区。

下面的程序清单给出了将一个数据库置于ARCHIVELOG模式所需的步骤。

二、将数据库设置为ARCHIVELOG模式：

```sql
SYS@lucdb(CDB$ROOT)> shutdown immediate;

SYS@lucdb(CDB$ROOT)> startup mount;

SYS@lucdb(CDB$ROOT)> alter database archivelog;

SYS@lucdb(CDB$ROOT)> alter database open;
```

三、查看归档配置：

```sql
SYS@lucdb(CDB$ROOT)> SELECT LOG_MODE FROM V$DATABASE;

LOG_MODE
------------------------
ARCHIVELOG


SYS@lucdb(CDB$ROOT)> archive log list;
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     17
Next log sequence to archive   19
Current log sequence           19
```

数据库运行在归档模式。


注意：  
为查看当前活动的联机重做日志及其序列号，可查询V$LOG动态视图。

如果启用了归档，但未指定任何归档位置，则归档的日志文件驻留在一个默认的、与平台相关的位置。在Unix和Linux平台上，默认位置是$ORACLE_HOME/dbs。

每个归档的重做日志文件包含来自一个单独的联机重做日志的数据。这些日志文件按它们创建的顺序依次编号。归档的重做日志文件的大小可变化，但是不能超过联机重做日志文件的大小。

如果归档的重做日志文件的目标目录的空间已经不足，那么ARCn进程将停止处理联机重做日志数据，并且数据库自身也将停止。可通过向归档的重做日志文件的目标磁盘添加更多空间，或通过备份归档的重做日志文件然后将它们从该目录中清除的方法来处理这种情况。如果正为归档的重做日志文件使用快速恢复区，则当快速恢复区的可用空间小于15%时，数据库会发出警告性报警，而当可用空间小于3%时，会发出严重报警。假设没有失控的进程消耗快速恢复区中的空间，则在可用空间为15%时采取措施（例如，增加大小或改变快速恢复区的位置）很可能会避免任何服务中断。

初始化参数`DB_RECOVERY_FILE_DEST_SIZE`也可协助管理快速恢复区的大小。尽管此参数的主要作用是限制指定磁盘组或文件系统目录上的快速恢复区所使用的磁盘空间量，但一旦收到报警，也可临时增加这一参数的值，以便为DBA提供额外时间来为磁盘组分配更多磁盘空间或重新定位快速恢复区。

DB_RECOVERY_FILE_DEST_SIZE不仅有助于管理数据库中的空间，还有助于管理使用同一ASM磁盘组的所有数据库的空间。每个数据库都有各自的DB_RECOVERY_FILE_ DEST_SIZE设置。

只要没有收到警告性报警或严重报警，就可以较主动地监控快速恢复区的大小，可通过动态性能视图`V$RECOVERY_FILE_DEST`查看目标文件系统上已使用的和可回收的空间总量。此外，可使用动态性能视图`V$FLASH_RECOVERY_AREA_USAGE`按文件类型查看利用率明细情况：

```sql
SYS@lucdb(CDB$ROOT)> select * from V$RECOVERY_FILE_DEST;

NAME                           SPACE_LIMIT SPACE_USED SPACE_RECLAIMABLE NUMBER_OF_FILES     CON_ID
------------------------------ ----------- ---------- ----------------- --------------- ----------
+FRA                            2147483648 1315962880                 0              12          0

SYS@lucdb(CDB$ROOT)> select * from V$FLASH_RECOVERY_AREA_USAGE;

FILE_TYPE                                      PERCENT_SPACE_USED PERCENT_SPACE_RECLAIMABLE NUMBER_OF_FILES     CON_ID
---------------------------------------------- ------------------ ------------------------- --------------- ----------
CONTROL FILE                                                  .88                         0               1          0
REDO LOG                                                    29.44                         0               3          0
ARCHIVED LOG                                                30.86                         0               8          0
BACKUP PIECE                                                    0                         0               0          0
IMAGE COPY                                                      0                         0               0          0
FLASHBACK LOG                                                   0                         0               0          0
FOREIGN ARCHIVED LOG                                            0                         0               0          0
AUXILIARY DATAFILE COPY                                         0                         0               0          0

8 rows selected.

SYS@lucdb(CDB$ROOT)> select sum(PERCENT_SPACE_USED) || '%' PERCENT_SPACE_USED  from V$FLASH_RECOVERY_AREA_USAGE;

PERCENT_SPACE_USED
----------------------------------------------------------------------------------
61.18%
```

在此例中，快速恢复区只使用了61.18%的空间，这是由于没有使用RMAN备份。


### 13.6.2 执行热备份（用户管理的）

一旦数据库运行在ARCHIVELOG模式下，就可在数据库处于打开状态并且用户可使用它时对其进行备份。利用这种功能，可获得全天候的数据库可用性，同时仍保证数据库的可恢复性。

尽管可在正常工作时间执行联机备份，但考虑到以下多种原因，**应在用户活动最少的时候安排实施联机备份**。

首先，联机备份会使用操作系统命令来备份物理文件，并且这些命令会使用系统中可用的I/O资源（影响交互式用户使用系统的性能）。

其次，当备份表空间时，将事务写入归档重做日志文件的方式会改变。将表空间置于“联机备份”模式时，DBWR进程将缓冲存储器（buffer cache）中属于表空间一部分的任何文件的所有数据块回写到磁盘上。当数据块读回内存并随后改变时，在数据块首次改变时会被复制到日志缓冲区中。只要数据块停留在缓冲存储器中，则不会将它们再复制到联机重做日志文件。这种操作将在归档重做日志文件的目标目录中使用多得多的空间。

注意：  
可创建一个命令文件来执行联机备份，但考虑到多种原因，更倾向于使用RMAN：RMAN维护一个备份的目录（表），允许管理备份库，并允许对数据库进行增量式备份。

---
要执行联机数据库备份或单个表空间备份，应遵循以下这些步骤：

1. 将数据库设置为备份状态（在Oracle 10g之前，唯一的选择是逐个表空间启用备份）。具体做法是或对每个表空间使用ALTER TABLESPACE . . . BEGIN BACKUP命令，或对所有表空间使用ALTER DATABASE BEGIN BACKUP命令，将所有表空间置于联机备份模式。
2. 使用操作系统命令备份数据文件。
3. 通过对数据库中的每个表空间发出ALTER TABLESPACE . . . END BACKUP命令或对所有表空间发出ALTER DATABASE END BACKUP命令，将数据库设置回它的正常状态。
4. 备份未归档的重做日志文件，以便发出ALTER SYSTEM ARCHIVE LOG CURRENT命令后可使用恢复表空间备份需要的重做日志。
5. 备份归档重做日志文件。如有必要，压缩或删除备份的归档重做日志文件来释放磁盘上的空间。
6. 备份控制文件。
---

常见的备份过程如下，这里以一个表空间的备份为例：
```sql
alter tablespace system begin backup;
host cp /u01/app/oracle/oradata/orcl/system.dbf
/home/oracle/tmp/
alter tablespace system end backup;
```

对应的恢复为：
```sql
host rm /u01/app/oracle/oradata/ORCL/system.dbf
startup force;
host cp /home/oracle/tmp/system.dbf /u01/app/oracle/oradata/ORCL/system.dbf
SQL> alter database open;
alter database open
*
ERROR at line 1:
ORA-01113: file 5 needs media recovery
ORA-01110: data file 5:
'/u01/app/oracle/oradata/ORCL/system.dbf'
SQL> recover datafile 5;
Media recovery complete.
SQL> alter database open;
Database altered.
```

对于非系统表空间的数据文件还可以 offline 后打开数据库再恢复：
```sql
SQL> startup force;
ORACLE instance started.
Total System Global Area 595589848 bytes
Fixed Size 8899288 bytes
Variable Size 239075328 bytes
Database Buffers 343932928 bytes
Redo Buffers 3682304 bytes
Database mounted.
ORA-01157: cannot identify/lock data file 5 - see DBWR trace file
ORA-01110: data file 5:'/u01/app/oracle/oradata/ORCL/users01.dbf'
SQL> alter database datafile 5 offline;
Database altered.
SQL> alter database open;
Database altered.
host cp /home/oracle/tmp/users01.dbf
/u01/app/oracle/oradata/ORCL/users01.dbf
SQL> recover datafile 5;
Media recovery complete.
SQL> alter database datafile 5 online;
Database altered.
```

注意：   
如果遗忘了end backup命令将会导致数据库问题，所以使用这种方式备份时需要确认备份正确完成。

## 13.7 集成备份过程

由于可使用多种方法来备份Oracle数据库，因此在采用的备份策略中可避免单点故障。根据数据库的特征，应选择一种备份方法，并使用至少一种其他方法作为主备份方法的备用方法。

注意：   
在进行物理备份时，也应考虑评估使用RMAN来执行增量式物理备份。

下面将介绍如何为数据库选择主备份方法，如何集成逻辑备份和物理备份，以及如何集成数据库备份和文件系统备份。有关RMAN的详情，请参见第14章。


### 13.7.1 集成逻辑备份和物理备份

究竟哪种备份方法更适合用作数据库的主备份方法呢？在做决定时，应考虑每种备份方法的特点：

| 方法 | 类型 | 恢复特点 |
| - | - | - |
| 数据泵 | 逻辑备份 | 能将任何数据库对象恢复到导出时的状态 |
| 冷备份 | 物理备份 | 能将数据库恢复到关闭它时的状态。如果数据库运行在归档模式下，可以将数据库恢复到它在任何时间点的状态 |
| 热备份 | 物理备份 | 能将数据库恢复到它在任何时间点的状态 |

如果数据库运行在NOARCHIVELOG模式下，那么冷备份是一种备份数据库灵活性最差的方法。冷备份是数据库的一个时间点的快照。而且，由于冷备份是物理备份，DBA不能从中有选择地恢复逻辑对象（如表）。尽管有时采用冷备份是合适的（如用于灾难恢复），但冷备份通常应该用作在主备份方法失败时的一种备用手段。如果数据库正运行在ARCHIVELOG模式下（强烈建议数据库运行在这一模式下），可使用冷备份作为介质恢复的基础，但是联机备份通常更适合这种情况。

在其余两种方法中，哪种方法更合适呢？对于产品环境而言，答案几乎总是选用热备份。当数据库运行在ARCHIVELOG模式时，联机备份允许将数据库恢复到系统即将出现故障或用户即将产生错误前的时间点的状态。使用基于数据泵的策略将限制你只能把数据回溯到它最后一次导出时的状态。

要考虑数据库的大小以及很可能要恢复的对象。考虑一种标准恢复情况——例如磁盘丢失——那么恢复数据将花费多长时间呢？如果丢失一个文件，最快的恢复该文件的方法通常是通过一种物理备份，此时再次显示了联机备份相对于数据导出的优势。数据泵一般不会只导出一个逻辑对象，一般习惯导出整个表空间或整个schema的对象，因此不好指定恢复某个逻辑对象。

如果数据库很小、事务量很低并且数据库的可用性不是所关注的问题，那么冷备份可以满足你的要求。如果仅仅关心一两张表，则可使用数据泵导出来有选择地备份这些表。但是，如果数据库很大，数据泵导出导入方法所需的恢复时间就可能是不可接受的。在事务很大而事务量不多的环境中，冷备份可能更合适。

无论选择什么样的主备份方法，最终的实现应该包括一种物理备份和某种逻辑备份，或者通过数据泵导出，或者通过复制。这种冗余是必要的，因为这些方法将检验数据库的不同方面：Data Pump Export验证数据在逻辑上是完好的，而物理备份验证数据是物理可靠的。一种好的数据库备份策略应该集成逻辑备份和物理备份。执行备份的频率和类型因数据库的使用特点而异。

其他一些数据库活动可能要求特别的备份方法。这类特殊备份可能包括在执行**数据库升级前的冷备份**以及应用程序在数据库之间**迁移过程中的导出操作**。


### 13.7.2 集成数据库备份和操作系统备份

通常可通过将磁盘驱动器专门用作物理文件备份的目标位置来实现产品控制流程的集中化。不将文件备份到磁带驱动装置上，而将备份写入同一服务器的其他磁盘上。系统管理人员的常规文件系统备份应将这些磁盘作为备份目标。DBA不必运行一个独立的磁带备份作业，但理员需要证实正确地执行并成功完成了系统管理组的备份过程。

如果数据库环境包括位于数据库之外的文件（例如用于外部表的数据文件或由BFILE数据类型访问的文件），那么必须决定打算以怎样一种方法来备份这些文件，以便可在恢复数据时提供数据的一致性。这些平面文件的备份应与数据库备份相协调，也应集成到任何灾难恢复计划中。

# 14 恢复管理器（RMAN）

Recovery Manager，Oracle的RMAN将备份和恢复提升到一种新的保护级别，并且使用方便。自从在Oracle版本8中推出RMAN以来，已进行了许多重大的改进和增强，RMAN也利用了Oracle Database 12c中引入的多租户体系结构特性，使得RMAN成为可用于几乎所有数据库环境的优质解决方案。在Oracle 12c中除改进了RMAN命令行界面外，还将所有RMAN功能都包含在基于Web的Enterprise Manager Cloud Control 12c（EM Cloud Control）界面中，从而可在只能使用Web浏览器连接时允许DBA监视和执行备份操作。

Oracle Database 12c甚至为RMAN环境引入了更多功能。为便于从命令行管理数据库，过去在SQL>提示符下运行的几乎所有命令现在都可用于RMAN>提示符，而且不必使用RMAN sql命令。现在，可在表级别执行还原和恢复操作——通常使用Data Pump执行表对象的逻辑导出和导入，但这赋予另一个使用最新RMAN备份来检索单个表或少量表的选项。最后，DUPLICATE命令通过利用辅助实例上的更高并行度以及更优秀的压缩算法，在网络连接上更快地执行备份；这极大地提高了创建数据库备份的速度。

由于存在大量各种各样的磁带备份管理系统，讨论任何特定的硬件配置均不在本书的讲解范围之内。相反，本章将重点说明有关快速恢复区（Fast Recovery Area）的用法，这是一个在磁盘上分配的专用区域，用来存储RMAN可以备份的所有类型的对象的基于磁盘的副本。快速恢复区（过去称为闪回恢复区）是Oracle Database 10g新引入的功能。

我们将采用一个配合RMAN使用的恢复目录。尽管只有通过使用目标数据库的控制文件才能利用RMAN的大部分功能，却可得到能存储RMAN脚本以及具有额外的恢复功能等诸多好处，这些好处远远超过在不同数据库中维护RMAN用户账户所花费的较低代价。

## 14.1 RMAN的特性和组件

RMAN并不仅是一个可通过Web界面使用的客户端可执行程序。它由大量其他组件组成，这些组件包括将要备份的数据库（目标数据库）、一个可选的恢复目录、一个可选的快速恢复区和一个用于支持磁带备份系统的介质管理软件。

### 14.1.1 RMAN组件

RMAN环境中首要的最基本组件是可执行的RMAN程序。该程序和其他Oracle实用程序都位于$ORACLE_HOME/bin目录中，默认情况下标准版和企业版的Oracle Database 12c都会安装该程序。可从命令行提示符调用带有或者不带有命令行参数的RMAN。

下例将使用操作系统身份验证来启动RMAN，而不需要连接到一个恢复目录。

```bash
[oracle@19c-Grid ~]$ rman target /

Recovery Manager: Release 19.0.0.0.0 - Production on Tue Oct 17 02:02:22 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to target database: LUCDB (DBID=71583637)
```

我们不会经常使用RMAN，除非需要备份数据库。可在恢复目录中对一个或多个目标数据库进行编目，此外，正在备份的数据库的控制文件包含有关RMAN所执行的备份的信息。从RMAN客户程序中，还可为那些使用RMAN自带的命令不能执行的操作发出SQL命令。

无论是使用目标数据库控制文件还是分离的数据库中的专用存储库，RMAN恢复目录均包含恢复数据的位置、它自己的配置设置和目标数据库模式。目标数据库控制文件至少要包含这类数据。为能存储脚本并维护目标数据库控制文件的一个副本，我们极力推荐采用恢复目录。在本章中，所有例子都将使用恢复目录。

从Oracle 10g开始，通过在磁盘上定义用来存放所有RMAN备份的位置，快速恢复区简化了基于磁盘的备份和恢复。除指定存放位置外，DBA还可指定快速恢复区中使用的磁盘空间大小的上限。一旦在RMAN中指定了保留策略，RMAN将通过从磁盘和磁带上删除过时的备份来自动管理备份文件。

为访问所有不基于磁盘的存储介质，例如磁带和BD-ROM，RMAN利用第三方介质管理软件在这些离线和近线（near-line）设备之间来回转移备份文件，自动请求加载和卸载适当的介质来支持备份和还原操作。大多数主要介质管理软件和硬件供应商提供直接支持RMAN的设备驱动程序。

### 14.1.2 RMAN对比传统备份方法



使用rman命令建立数据库物理全备份：

```sql
run
{
 allocate channel c0 device type disk;
 allocate channel c1 device type disk;
 CONFIGURE CONTROLFILE AUTOBACKUP ON;
 CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/u01/app/oracle/rman/%F';
 backup  database format '/u01/app/oracle/rman/ora19C_full_db_%d_%T_%u.bak';
 BACKUP ARCHIVELOG ALL FORMAT '/u01/app/oracle/rman/ora19C_arc_%s_%p_%t.bak';
}
```

主从恢复命令：
```sql
duplicate target database for standby nofilenamecheck;
```

# 15 Oracle Data Guard
# 16 其他高可用特性
# 17 Oracle Net
# 18 管理大型数据库
# 19 管理分布式数据库