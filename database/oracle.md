# 一、DCL

## 1. GRANT

```SQL
1.权限赋予
GRANT 权限 TO 用户名

2.角色赋予
GRANT 角色 TO 用户名
```

## 2.REVOKE

REVOKE 语句 用于回收权限

```SQL
权限回收
REVOKE 权限 TO 用户名

角色回收
REVOKE 角色 TO 用户名
```

## 3.权限表

### 3.1 集群权限

| 群集权限           | 描述                               |
| ------------------ | ---------------------------------- |
| CREATE CLUSTER     | 在自己的方案中创建、更改或删除群集 |
| CREATE ANY CLUSTER | 在任何方案中创建群集               |
| ALTER ANY CLUSTER  | 在任何方案中改动群集               |
| DROP ANY CLUSTER   | 在任何方案中删除群集               |

### 3.2 数据库权限

| 数据库权限     | 描述                          |
| -------------- | ----------------------------- |
| ALTER DATABASE | 更改数据库配置                |
| ALTER SYSTEM   | 更改系统初始化参数            |
| AUDIT SYSTEM   | 审计 SQL， **NOAUDIT SYSTEM** |

### 3.3 索引权限

| 索引权限         | 描述                 |
| ---------------- | -------------------- |
| CREATE ANY INDEX | 在任何方案中创建索引 |
| ALTER ANY INDEX  | 在任何方案中改动索引 |
| DROP ANY INDEX   | 在任何方案中删除索引 |

### 4. 过程权限

| 过程权限              | 描述                                             |
| --------------------- | ------------------------------------------------ |
| CREATE PROCEDUER      | 在自己的方案中创建、改动或删除函数、过程或程序包 |
| CREATE ANY PROCEDUER  | 在任何方案中创建函数、过程或程序包               |
| ALTER ANY PROCEDUER   | 在任何方案中改动函数、过程或程序包               |
| DROP ANY PROCEDUER    | 在任何方案中删除函数、过程或程序包               |
| EXECUTE ANY PROCEDUER | 在任何方案中执行函数、过程或程序包               |

### 5. 概要文件权限

| 概要文件权限   | 描述                                 |
| -------------- | ------------------------------------ |
| CREATE PROFILE | 创建概要文件（如：资源 / 密码 配置） |
| ALTER PROFILE  | 改动概要文件（如：资源 / 密码 配置） |
| DROP PROFILE   | 删除概要文件（如：资源 / 密码 配置） |

### 6. 角色权限

| 角色权限       | 描述                         |
| -------------- | ---------------------------- |
| CREATE ROLE    | 创建角色                     |
| ALTER ANY ROLE | 改动角色                     |
| DROP ANY ROLE  | 删除角色                     |
| GRANT ANY ROLE | 向其他角色或用户授予任何角色 |

### 7. 回退段权限

| 回退段权限              | 描述       |
| ----------------------- | ---------- |
| CREATE ROLLBACK SEGMENT | 创建回退段 |
| ALTER ROLLBACK SEGMENT  | 改动回退段 |
| DROP ROLLBACK SEGMENT   | 删除回退段 |

### 8. 序列权限

| 序列权限            | 描述                                     |
| ------------------- | ---------------------------------------- |
| CREATE SEQUENCE     | 在自己的方案中创建、改动、删除或选择序列 |
| CREATE ANY SEQUENCE | 在任何方案中创建序列                     |
| ALTER ANY SEQUENCE  | 在任何方案中改动序列                     |
| DROP ANY SEQUENCE   | 在任何方案中删除序列                     |
| SELECT ANY SEQUENCE | 在任何方案中选择序列                     |

### 9. 会话权限

| 会话权限            | 描述                               |
| ------------------- | ---------------------------------- |
| CREATE SESSION      | 创建会话，连接到数据库             |
| ALTER SESSION       | 改动会话                           |
| ALTER RESOURSE COST | 改动概要文件中的计算资源消耗的方式 |
| RESTRICTED SESSION  | 在受限的会话模式下连接到数据库     |

### 10. 同义词权限

| 同义词权限            | 描述                           |
| --------------------- | ------------------------------ |
| CREATE SYNONYM        | 在自己的方案中创建、删除同义词 |
| CREATE ANY SYNONYM    | 在任何方案中创建同义词         |
| CREATE PUBLIC SYNONYM | 创建公用同义词                 |
| DEOP ANY SYNONYM      | 在任何方案中删除同义词         |
| DROP PUBLIC SYNONYM   | 删除公共同义词                 |

### 11. 表权限

| 表权限              | 描述                                |
| ------------------- | ----------------------------------- |
| CREATE TABLE        | 在自己的方案中创建、改动或删除表    |
| CREATE ANY TABLE    | 在任何方案中创建表                  |
| ALTER ANY TABLE     | 在任何方案中改动表                  |
| DROP ANY TABLE      | 在任何方案中删除表                  |
| COMMENT ANY TABLE   | 在任何方案中为任何表添加注释        |
| SELECT ANY TABLE    | 在任何方案中选择任何表记录          |
| INSERT ANY TABLE    | 在任何方案中向任何表插入新记录      |
| UPDATE ANY TABLE    | 在任何方案中改动任何表记录          |
| DELETE ANY TABLE    | 在任何方案中删除任何表记录          |
| LOCK ANY TABLE      | 在任何方案中锁定任何表              |
| FLASHBACK ANY TABLE | 允许使用 **AS OF** 对表进行闪回查询 |

**注意：**对应 ANY TABLE 改成 ON 表名 就是赋予对应表的权力

### 12. 表空间权限

| 表空间权限           | 描述                   |
| -------------------- | ---------------------- |
| CREATE TABLESPACE    | 创建表空间             |
| ALTER TABLESPACE     | 改动表空间             |
| DROP TABLESPACE      | 删除表空间             |
| MANAGE TABLESPACE    | 管理表空间             |
| UNLIMITED TABLESPACE | 不受配额限制使用表空间 |

### 13. 用户权限

| 用户权限    | 描述           |
| ----------- | -------------- |
| CREATE USER | 创建用户       |
| ALTER USER  | 改动用户       |
| BECOME USER | 成为另一个用户 |
| DEOP USER   | 删除用户       |

### 14. 视图权限

| 视图权限           | 描述                                |
| ------------------ | ----------------------------------- |
| CREATE VIEW        | 在自己的方案中创建、改动或删除视图  |
| CREATE ANY VIEW    | 在任何方案中创建视图                |
| ALTER ANY VIEW     | 在任何方案中改动视图                |
| DROP ANY VIEW      | 在任何方案中删除视图                |
| FLASHBACK ANY VIEW | 允许使用 **AS OF** 对表进行闪回查询 |

### 15. 触发器权限

| 触发器权限                  | 描述                               |
| --------------------------- | ---------------------------------- |
| CREATE TRIGGER              | 在自己方案中创建、改动或删除触发器 |
| CREATE ANY TRIGGER          | 在任何方案中创建触发器             |
| ALTER ANY TRIGGER           | 在任何方案中改动触发器             |
| DROP ANY TRIGGER            | 在任何方案中删除触发器             |
| ADMINISTER DATABASE TRIGGER | 允许创建 **ON DATABASE** 触发器    |

### 16. 管理权限

| 管理权限 | 描述           |
| -------- | -------------- |
| SYSDBA   | 系统管理员权限 |
| SYSOPER  | 系统操作员权限 |

### 17. 其他权限

| 其他权限                   | 描述                           |
| -------------------------- | ------------------------------ |
| ANALYZE ANY                | 对任何方案中的表、索引进行分析 |
| GRANT ANY OBJECT PRIVILEGE | 授予任何对象权限               |
| GRANT ANY PRIVILEGE        | 授予任何系统权限               |

# 二、DDL

## 2.1 ALTER

### 2.1.1 基础使用

用于修改对象

```SQL
1. 添加列
   ALTER TABLE 表名 ADD 列名 类型

2. 修改列
   ALTER TABLE 表名 MODIFY 列名 类型

3. 删除列
   ALTER TABLE 表名 DROP COLUMN 列名

4. 修改列名
   ALTER TABLE 表明 RENAME COLUMN 旧列名 TO 新列名

5. 添加约束
   ALTER TABLE 表名 ADD CONSTRAINT 约束名 约束关键字(列名)

6. 添加非空约束
   ALTER TABLE 表名 MODIFY 列名 NOT NULL

7. 删除约束
   ALTER TABLE 表名 DROP [NOVALIDATE] CONSTRAINT 约束名

8. 禁用约束
   ALTER TABLE 表名 DISABLE [VALIDATE] CONSTRAINT 约束名

9. 启用约束
   ALTER TABLE 表名 ENABLE 
```

### 2.1.2 注意

禁用和启动约束可选值：

1. 禁用约束：

   DISABLE (默认NOVALIDATE)：关闭约束,删除索引,可以对约束列的数据进行修改等操作 ；

   DISABLE VALIDATE：关闭约束,删除索引,不能对表进行 插入/更新/删除等操作。

2. 启动约束：

   ENABLE (默认VALIDATE)：启用约束,创建索引,对已有及新加入的数据执行约束 ENABLE ；

   NOVALIDATE：启用约束,创建索引,仅对新加入的数据强制执行约束,而不管表中的现有数据。

## 2.2 COMMENT

用于给表或字段加注释

```SQL
1. 表
COMMENT ON TABLE 表名 IS 注解

2. 字段
COMMENT ON COLUMN 表名.列名 IS 注解
```

## 2.3 CREATE

### 2.3.1 创建表空间

```SQL
CREATE TABLESPACE 表空间名
DATAFILE '存储路径'
SIZE 初始大小 单位：KB M G 等
AUTOEXTEND ON NEXT 自增长大小 单位：KB M G 等
MAXSIZE (UNLIMITED | 大小 单位：KB M G 等)
```

### 2.3.2 创建用户

```SQL
CREATE USER 用户名
IDENTIFIED BY 密码
[DEFAULT TABLESPACE 表空间名]
[TEMPORARY TABLESPACE 临时表空间名]
```

**注意：**创建用户后要赋权

```sql
grant Permissions to user;

```

### 2.3.3 创建角色

```SQL
CREATE ROLE 角色名
```

### 2.3.4 创建表

```SQL
CREATE [OR REPLACE] TABLE 表名 (
    列名 类型 约束
    CONSTRAINT 约束名 约束关键字(列名)
    .............
)
```

```SQL
-- 复制表结构
CREATE TABLE TABLE_NEW AS SELECT * FROM  TABLE_OLD WHERE 1=0;  	

-- 复制表结构和数据
CREATE TABLE TABLE_NEW AS SELECT * FROM TABLE_OLD 
```

### 2.3.5 创建序列

```SQL
CREATE SEQUENCE 序列名
INCREMENT BY 序列变化的步进，负值表示递减 (默认1)
START WITH 序列的初始值 (默认1)
MINVALUE 序列可生成的最小值 (默认不限制最小值，NOMINVALUE)
MAXVALUE 序列可生成的最大值 (默认不限制最大值，NOMAXVALUE)
CYCLE 用于定义当序列产生的值达到限制值后是否循环 (NOCYCLE:不循环，CYCLE:循环)
CACHE 表示缓存序列的个数，数据库异常终止可能会导致序列中断不连续的情况，如果不使用缓存可设置: NOCACHE (默认值为20)
```

### 2.3.6 创建索引

```SQL
6.1 单列索引
CREATE INDEX 索引名 ON 表名(列名)
6.2 复合索引
CREATE INDEX 索引名 ON 表名(列名1, 列名2, 列名3, .....)
```

### 2.3.7 创建视图

```SQL
CREATE [OR REPLACE] [FORCE | NOFORCE] VIEW 视图名[(ALIAS, [ALIAS, ...])]
AS (SELECT * FROM 表名 (一条完整的SQL查询语句))
[WITH CHECK OPTION] [WITH READ ONLY]
```

### 2.3.8 创建同义词

```SQL
CREATE SYNONYM 同义词名 FOR 对象名
```



## 2.4 DROP

### 2.4.1 基础使用

```SQL
1. 删除表
DROP TABLE 表名

2. 删除用户
DROP USER 用户名

3. 删除角色
DROP ROLE 角色名

4. 删除序列
DROP SEQUENCE 序列名

5. 删除索引
DROP INDEX 索引名

6. 删除视图
DROP VIEW 视图名
```

### 2.4.2 注意

1. 会隐式提交，所以，不能回滚，不会触发触发器
2. 删除表结构及所有数据，并将表所占用的空间全部释放
3. 将删除表的结构所依赖的约束，触发器，索引
4. 依赖于该表的存储过程/函数将保留, 但是变为 **INVALID** 状态

## 2.5 TRUNCATE

清空表数据，保留表结构

### 2.5.1 基础使用

```SQL
TRUNCATE TABLE 表名
```

### 2.5.2 注意

1. 会隐式提交，所以，不能回滚，不会触发触发器
2. 会删除表中所有记录，并且将重新设置高水线和所有的索引，缺省情况下将空间释放到MINEXTENTS个EXTENT，除非使用REUSE STORAGE，。不会记录日志，所以执行速度很快，但不能通过ROLLBACK撤消操作（如果一不小心把一个表TRUNCATE掉，也是可以恢复的，只是不能通过ROLLBACK来恢复）
3. 对于外键（FOREIGNKEY ）约束引用的表，不能使用 TRUNCATE TABLE，而应该使用不带 WHERE 子句的 DELETE 语句
4. TRUNCATE TABLE不能用于参与了索引视图的表

## 2.6 分区表

分区是将一个表或索引物理地分解为多个更小、更可管理的部分

### 2.6.1 范围分区（RANGE）

RANGE 分区是应用范围比较广的表分区方式，它是以列的值的范围来做为分区的划分条件，将记录放到列值 所对应的分区中

```SQL
CREATE TABLE PT_RANGE_TEST1(
  PID   NUMBER(10),
  PNAME VARCHAR2(30)
) PARTITION BY RANGE(PID) 
(
  PARTITION P1 VALUES LESS THAN(1000) TABLESPACE TETSTBS1,
  PARTITION P2 VALUES LESS THAN(2000) TABLESPACE TETSTBS2,
  PARTITION P3 VALUES LESS THAN(最大值) TABLESPACE TETSTBS3
) ENABLE ROW MOVEMENT;
```

>不必为最后一个分区指定最大值，MAXVALUE 关键字会告诉 ORACLE 使用这个分区来存储在前面几个分区中不能存储的数据

### 2.6.2 哈希分区 | 散列分区（HASH）

通过在分区键值上执行一个`散列函数`来决定数据的物理位置

```SQL
CREATE TABLE PT_HASH_TEST(
  PID   NUMBER(10),
  PNAME VARCHAR2(30)
) PARTITION BY HASH(PID) (
  PARTITION P1 TABLESPACE TETSTBS1,
  PARTITION P2 TABLESPACE TETSTBS2,
  PARTITION P3 TABLESPACE TETSTBS3,
  PARTITION P4 TABLESPACE TETSTBS4
);
```

> 连续的分区键值一般不存储在相同的分区中，散列分区把记录分布在比范围分区更多的分区上， 这降低了 I/O 争用的可能性
>
> 建议分区的数量采用2的N次方，这样可以使得各个分区间数据分布更加均匀

### 2.6.3 列表分区（LIST）

LIST 分区也需要指定列的值，其分区值必须明确指定，该分区列只能有一个

```SQL
CREATE TABLE PT_LIST_TEST(
  PID   NUMBER(10),
  PNAME VARCHAR2(30),
  SEX   VARCHAR2(10)
) PARTITION BY LIST(SEX) 
(
  PARTITION P1 VALUES ('MAN', '男') TABLESPACE TETSTBS1,
  PARTITION P2 VALUES ('WOMAN', '女') TABLESPACE TETSTBS2,
  PARTITION P3 VALUES (DEFAULT) TABLESPACE TETSTBS3
) ENABLE ROW MOVEMENT;
```

>在分区时必须确定分区列可能存在的值，一旦插入的列值不在分区范围内， 则插入/更新就会失败， 因此通常建议使用 LIST 分区时，要创建一个 DEFAULT 分区 存储那些不在指定范围内的记录，类似 RANGE 分区中的 MAXVALUE 分区

### 2.6.4 组合分区

如果某表按照某列分区之后，仍然较大，或者是一些其它的需求，还可以通 过分区内再建子分区的方式将分区再分区，即组合分区的方式

```SQL
-- 情况1：RANGE + LIST
CREATE TABLE PT_RANGE_LIST_TEST(
   PID         NUMBER(10),
   PNAME       VARCHAR2(30),
   SEX         VARCHAR2(10),
   CREATE_DATE DATE
) PARTITION BY RANGE(CREATE_DATE)
  SUBPARTITION BY LIST(SEX) (
    PARTITION P1 VALUES LESS THAN(TO_DATE('2020-01-01', 'YYYY-MM-DD')) TABLESPACE TETSTBS1(
      SUBPARTITION SUB1P1 VALUES('MAN') TABLESPACE TETSTBS1,
      SUBPARTITION SUB2P1 VALUES('WOMAN') TABLESPACE TETSTBS1,
      SUBPARTITION SUB3P1 VALUES(DEFAULT) TABLESPACE TETSTBS1
    ),
    PARTITION P2 VALUES LESS THAN(TO_DATE('2021-01-01', 'YYYY-MM-DD')) TABLESPACE TETSTBS2(
      SUBPARTITION SUB1P2 VALUES('MAN') TABLESPACE TETSTBS2,
      SUBPARTITION SUB2P2 VALUES('WOMAN') TABLESPACE TETSTBS2,
      SUBPARTITION SUB3P2 VALUES(DEFAULT) TABLESPACE TETSTBS2
    ),
    PARTITION P3 VALUES LESS THAN(MAXVALUE) TABLESPACE TETSTBS3(
      SUBPARTITION SUB1P3 VALUES('MAN') TABLESPACE TETSTBS3,
      SUBPARTITION SUB2P3 VALUES('WOMAN') TABLESPACE TETSTBS3,
      SUBPARTITION SUB3P3 VALUES(DEFAULT) TABLESPACE TETSTBS3
    )
  ) ENABLE ROW MOVEMENT;


-- 情况2：RANGE + HASH
  CREATE TABLE PT_RANGE_HASH_TEST(
   PID         NUMBER(10),
   PNAME       VARCHAR2(30),
   SEX         VARCHAR2(10),
   CREATE_DATE DATE
) PARTITION BY RANGE(CREATE_DATE)
  SUBPARTITION BY HASH(PID) SUBPARTITIONS 4 STORE IN (TETSTBS1, TETSTBS2, TETSTBS3, TETSTBS4)(
     PARTITION P1 VALUES LESS THAN(TO_DATE('2020-01-01', 'YYYY-MM-DD')) TABLESPACE TETSTBS1,
     PARTITION P2 VALUES LESS THAN(TO_DATE('2021-01-01', 'YYYY-MM-DD')) TABLESPACE TETSTBS2,
     PARTITION P3 VALUES LESS THAN(TO_DATE('2022-01-01', 'YYYY-MM-DD')) TABLESPACE TETSTBS3,
     PARTITION P4 VALUES LESS THAN(MAXVALUE) TABLESPACE TETSTBS4
  ) ENABLE ROW MOVEMENT;
```

## 2.7 序列

### 2.7.1 说明

SEQUENCE 是ORACLE提供的用于产生一系列唯一数字的数据库对象。由于ORACLE中没有设置自增列的方法（MYSQL 有主键自增长），所以我们在ORACLE数据库中主要用序列来实现主键自增的功能

### 2.7.2 创建索引

```SQL
CREATE SEQUENCE 序列名
[INCREMENT BY 序列变化值]
[START WITH 序列的初始值]
[NOMINVALUE|(MINVALUE 序列可生成的最小值)]
[NOMAXVALUE|(MAXVALUE 序列可生成的最大值)]
[NOCYCLE|CYCLE] 循环
[NOCACHE|(CACHE 缓存系列个数)]
```

| 关键字       | 描述                                                         |
| ------------ | ------------------------------------------------------------ |
| INCREMENT BY | 序列变化的步进，负值表示递减 (默认1)                         |
| START WITH   | 序列的初始值 (默认1)                                         |
| MINVALUE     | 序列可生成的最小值 (默认不限制最小值，NOMINVALUE)            |
| MAXVALUE     | 序列可生成的最大值 (默认不限制最大值，NOMAXVALUE)            |
| CYCLE        | 用于定义当序列产生的值达到限制值后是否循环 (NOCYCLE:不循环，CYCLE:循环) (默认不循环，NOCYCLE) |
| CACHE        | 表示缓存序列的个数，数据库异常终止可能会导致序列中断不连续的情况，如果不使用缓存可设置: NOCACHE (默认值为20) |

### 2.7.3 使用序列

1. **CURRVAL** ：返回当前序列值
2. **NEXTVAL** ：返回当前序列值，并且自动增加你设置的 **INCREMENT BY** 值

```
SELECT SEQ_XXX.CURRVAL FROM DUAL;

SELECT SEQ_XXX.NEXTVAL FROM DUAL;
```

### 2.7.4 删除序列

DROP SEQUENCE 序列名

### 2.7.5 注意

1. 序列第一次必须先调用 **NEXTVAL** 获取一个序列值才能使用 **CURRVAL** 查看当前值
2. 序列的起始值不能小于最小值
3. 创建一个循环序列,则必须要设定最大值
4. 如果创建带缓存的序列,缓存的值必须满足约束公式: 最大值-最小值>=(缓存值-1)*每次循环的值

## 2.8 索引

### 2.8.1 说明

1. 索引是数据库对象之一，用于加快数据的检索，类似于书籍的索引。在数据库中索引可以减少数据库程序查询结果时需要读取的数据量，类似于在书籍中我们利用索引可以不用翻阅整本书即可找到想要的信息
2. 索引是建立在表上的可选对象，索引的关键在于通过一组排序后的 **索引键** 来取代默认的全表扫描检索方式，从而提高检索效率
3. 索引在逻辑上和物理上都与相关的表和数据无关，当创建或者删除一个索引时，不会影响基本的表
4. 索引一旦建立，在表上进行 DML 操作时（例如在执行插入、修改或者删除相关操作时，ORACLE 会自动管理索引，索引删除，不会对表产生影响
5. 索引对用户是透明的，无论表上是否有索引，SQL 语句的用法不变
6. ORACLE 创建主键时会自动在该列上创建索引

#### 2.8.1.1 优势

1. 可以快速检索速度，减少 I/O 次数，加快检索速度
2. 根据索引分组和排序，可以加快分组和排序

#### 2.8.1.2 劣势

1. 索引本身也是表，因此会占用存储空间，一般来说，索引表占用的空间的数据表的 1.5 倍
2. 索引表的维护和创建需要时间成本，这个成本随着数据量增大而增大
3. 当对表中的数据进行 DML 操作时（例如：增加、删除和修改），索引也要动态的维护，这样就降低了数据的维护速度，因为在修改数据表的同时还需要修改索引表

#### 2.8.1.3 索引类型

1. 普通索引：是最基本的索引，它没有任何限制
2. 唯一索引：不允许其中任何两行具有相同索引值的索引
3. 主键索引：使用主键来创建索引，主键索引是一种聚簇索引
4. 分区索引：根据分区表创建索引
5. 候选索引：与主键索引一样要求字段值的唯一性，并决定了处理记录的顺序
6. 聚簇索引（聚集索引 | 聚类索引 | 簇集索引）：索引指向的就是数据本身，也就是说索引和数据存储在一块，**聚簇索引只是一种数据存储方式**
7. 非聚簇索引（辅助索引）：索引指向数据存放的物理地址，也就是说索引和数据是分开存储的，**非聚簇索引只是一种数据存储方式**
8. 复合索引（组合索引）：多个字段组合的索引，如果只用单列 只有最左边的列会进入索引

### 2.8.2 创建索引

```SQL
CREATE [UNIQUE|BITMAP] INDEX 索引名 ON 表名（列名[，列名 ...]） TABLESPACE 表空间名
```

| 关键字 | 描述                                   |
| ------ | -------------------------------------- |
| UNIQUE | 用于指定是否强制要求索引列为唯一性数据 |
| BITMAP | 创建位图索引                           |

### 2.8.3 修改索引

```SQL
1. 修改索引名
ALTER INDEX 索引名 RENAME TO 新索引名

2. 重建索引：
ALTER INDEX 索引名 REBUILD [ONLINE]
```

#### 2.8.3.1 ONLINE

1. **不加** ONLINE，REBUILD 会 **阻塞一切 DML 操作**
2. **不加** ONLINE，ORACLE 则直接 **读取原索引的数据**
3. **添加** ONLINE，ORACLE 是直接 **扫描表中的数据**

#### 2.8.3.2 REBUILD

1. ORACLE 在 REBUILD 时，在创建新索引过程中，并不会删除旧索引，直到新索引 REBUILD 成功
2. REBUILD 比删除索引然后重建索引的一个好处是不会影响原有的 SQL 查询
3. 用 REBUILD 方式建立索引需要相应 **表空间的空闲空间** 是删除重建方式的**2 倍**

### 2.8.4 删除索引

```SQL
DROP INDEX 索引名
```

### 2.8.5 功能性索引

1. 反向键索引：反向键索引反转索引列键值的每个字节，为了实现索引的均匀分配，避免B树不平衡。通常建立在值是连续增长的列上，使数据均匀地分布在整个索引上。

   ```SQL
   CREATE INDEX 索引名 ON 表名(列名) REVERSE
   ```

2. 函数索引：基于一个或多个列上的函数或表达式创建的索引，表达式中不能出现聚合函数，不能在 **LOB** 类型的列上创建，创建时必须具有 **QUERY REWRITE** 权限

   ```SQL
   -- 1.打开限制
   ALTER SYSTEM SET QUERY_REWRITE_ENABLED = TRUE
   
   -- 2.创建索引
   CREATE INDEX 索引名 ON 表名(函数(列名))
   ```

### 2.8.6 索引的种类

1. **BTREE索引**（ORACLE）：一种多叉平衡查找树（相对于二叉，BTREE每个内结点有多个分支，即多叉）
   1. 树内的每个节点都存储数据
   2. 叶子节点之间无指针连接
2. **位图索引**（ORACLE）：是一种使用位图的特殊数据库索引，主要针对大量相同值的列而创建
3. **B+TREE索引**（MYSQL）：B+TREE是BTREE的一个变种，在BTREE基础上所有叶子节点均有一个链指向下一个叶子节点
   1. 数据只出现在叶子节点
   2. 所有叶子节点增加了一个链指针

### 2.8.7 注意

1. 索引不会包含有NULL值的列： 只要列中包含有NULL值都将不会被包含在索引中，复合索引中只要有一列含有 NULL值，那么这一列对于此复合索引就是无效的。所以我们在数据库设计时不要让字段的默认值为NULL

2. 使用短索引： 对串列进行索引，如果可能应该指定一个前缀长度。如果在前10个或20个字符内，多数值是惟一的，那么就不要对整个列进行索引。短索引不仅可以提高查询速度而且可以节省磁盘空间和I/O操作

3. 索引列排序：

   如果 WHERE子句中已经使用了索引的话，那么ORDER BY中的列是不会使用索引的。因此数据库默认排序可以符合要求的情况下不要使用排序操作。尽量不要包含多个列的排序，如果需要最好给这些列创建复合索引

4. LIKE语句操作： 一般情况下不鼓励使用LIKE操作，如果非使用不可，如何使用也是一个问题。LIKE “%AAA%” 不会使用索引而LIKE “AAA%”可以使用索引

5. 不要在列上进行运算：

   ```SQL
   SELECT * FROM USERS WHERE YEAR(ADDDATE)<2007
   将在每个行上进行运算，这将导致索引失效而进行全表扫描，因此我们可以改成
   SELECT * FROM USERS WHERE ADDDATE<‘2007-01-01’
   ```

6. 不使用 NOT IN 和 != 操作：

   会造成全表扫描

## 2.9 约束

### 2.9.1 主键约束（PRIMARY KEY）

1. 键列必须必须具有唯一性，且不能为空，其实主键约束 相当于 UNIQUE + NOT NULL
2. 一个表只允许有一个主键
3. 主键所在列必须具有索引（主键的唯一约束通过索引来实现），如果不存在，将会在索引添加的时候自动创建
4. 约束的添加可在建表时创建，也可如下所示在建表后添加，一般推荐建表后添加，灵活度更高一些，建表时添加某些约束会有限制

```SQL
-- 1.在建表是创建
CREATE TABLE 表名(
列名 类型
)
CONSTRAINT 约束名 PRIMARY KEY(列名);

-- 2.表创建后创建
ALTER TABLE 表名 ADD CONSTRAINT 主键名 PRIMARY KEY(列名)
```

### 2.9.2 唯一约束(UNIQUE)

1. 对于UNIQUE约束来讲，索引是必须的。如果不存在，就自动创建一个（UNIQUE的唯一性本质上是通过索引来保证的）
2. **UNIQUE** 允许 **NULL** 值，**UNIQUE** 约束的列可存在多个 **NULL** 。这是因为，**UNIQUE** 唯一性通过 **BTREE** 索引来实现，而 **BTREE** 索引中不包含 **NULL**。当然，这也造成了在 **WHERE** 语句中用 **NULL** 值进行过滤会造成全表扫描。

```SQL
-- 1.在建表是创建
CREATE TABLE 表名(
列名 类型
)
CONSTRAINT 约束名 UNIQUE(列名)

-- 2.表创建后创建
ALTER TABLE 表名 ADD CONSTRAINT 主键名 UNIQUE(列名)
```

### 2.9.3 非空约束 (NOT NULL)

强制键列中必须有值，当然建表时候若使用DEFAULT关键字指定了默认值，则可不输入

```SQL
-- 1.在建表是创建
CREATE TABLE 表名(
列名 类型 NOT NULL;
)

-- 2.表创建后创建
ALTER TABLE 表名 MODIFY 列名 类型 NOT NULL
```

### 2.9.4 外键约束 (FOREIGN KEY)

1. 外键约束的子表中的列和对应父表中的列数据类型必须相同，列名可以不同
2. 对应的父表列必须存在 主键约束（PRIMARY KEY）或 唯一约束（UNIQUE）
3. 外键约束列允许 **NULL** 值，对应的行就成了孤儿行

```SQL
-- 1.在建表是创建
CREATE TABLE 表名(
列名 类型;
)
CONSTRAINT 约束名 FOREIGN KEY(列名) REFERENCES 主表名(列名) [ON UPDATE | ON DELETE 关键词];

-- 2.表创建后创建
ALTER TABLE EMP ADD CONSTRAINT 约束名 FOREIGN KEY(列名) REFERENCES 主表名(列名);--添加外键约束
```

### 2.3.5 检查约束（CHECK）

检查约束可用来实施一些简单的规则，检查的规则必须是一个结果为 **TRUE** 或 **FALSE**

```SQL
CONSTRAINT 约束名 CHECK(条件表达式)

CONSTRAINT CK_EMP_SAL CHECK(SAL BETWEEN 800 AND 5000)
```

# 三、DML

## 3.1 DELETE

DELETE 语句用于删除表中的记录

```SQL
-- 删除某行
DELETE FROM EMP WHERE 筛选条件；

-- 删除所有行
DELETE FROM TABLE_NAME; 

-- 删除重复数据
-- 1 用ROWID删除
DELETE FROM SC1 WHERE ROWID NOT IN (SELECT MIN(ROWID) FROM  SC1  GROUP BY SNO); 

-- 2 有主键，通过唯一列最大或最小方式删除重复记录
DELETE FROM STUDENT
WHERE SNAME IN (SELECT SNAME FROM STUDENT GROUP BY SNAME HAVING COUNT(SNAME) > 1) AND 
SNO NOT IN(SELECT  MAX(SNO) FROM STUDENT GROUP BY SNAME HAVING COUNT(SNAME) > 1);

-- 3 无主键使用ROW_NUMBER()函数删除重复记录
DELETE FROM SC1
WHERE SNO IN (SELECT DISTINCT SNO FROM ((SELECT SNO,ROW_NUMBER()OVER(PARTITION BY SNO ORDER BY SCORE) RANKING FROM SC1))
WHERE RANKING > 1);
```

## 3.2 INSERT

INSERT  语句用于向表格中插入新的记录

```SQL
-- 1 用列名和值一一对应的方式进行插入
INSERT INTO 表名称 (列1, 列2,...) VALUES(值1, 值2,....);

-- 2 使用值按照表列顺序进行插入
INSERT INTO 表名称 VALUES(值1, 值2,....);

-- 3 通过SELECT语句生成一个结果集进行值插入
INSERT INTO 表名1 (列名1，列名2，列名3) SELECT * FROM 表名2 WHERE ..;
```

**注意：**

1. **INSERT后一定要写COMMIT**，否则可能会导致锁表
2. 在值中如果需要空值，可以在 VALUES 中输入 NULL
3. 如果输入的字符串时，需要用 单引号 `' '` 进行包裹
4. 如果字符串中出现了单引号 则输入两个单引号，双引号不受影响
5. 如果从其它表中拷贝数据，不必书写 VALUES 子句

## 3.3 UPDATE

UPDATE 语句 用于给表更新数据

```SQL
1. 用列名和值一一对应的方式进行更新：
UPDATE 表名 SET 列名 = 'VALUES', 列名 = 'VALUES' WHERE 筛选条件

2. 修改值按照表结果集更新：
UPDATE 表名 SET 列名 = (SELECT * FROM 表名) WHERE 筛选条件

3. 多条件多结果更新：
UPDATE 表名 SET 列名 = (
    CASE WHEN 判断条件 THEN 执行语句
        WHEN 判断条件 THEN 执行语句
        ......
        WHEN 判断条件 THEN 执行语句
        ELSE 执行语句
    END
)  WHERE 筛选条件
```

**注意:**

1. 如果修改值使用表的结果集，结果集只能只有一个值
2. 如果 **UPDATE** 不写 **WHERE** 条件，必须 **CASE WHEN** 内 必须写 **ELSE** 否则会出现 **NULL** 值

## 3.4 MERGE

MERGE 语句 用于通过根据与源表联接的结果，该语句可以实现对目标表执行插入、更新或删除操作

```SQL
MERGE INTO 目标表 A

USING 源表|SQL语句结果集 B

ON (两表关联条件 AND 两表关联条件2)

WHEN MATCHED THEN
[UPDATE SET 列 = 值]
[DELETE WHERE 判断条件]

WHEN NOT MATCHED THEN
[INSERT VALUES(值) ]
```

**注意：**

1. MERGE **MYSQL** 不支持
2. DELELE 只能跟UPDATE 一起使用，同时WHERE只能出现一次，如果UPDATE 使用了 WHERE，DELETE后面的WHERE就无效了
3. 使用MERGE关键字只能更新一个表，源表中不能有重复的记录

# 四、DQL

# 五、TCL

# 六、PL/SQL

## 6.1 PL/SQL基础

### 6.1.1 PL/SQL 介绍

1. PLSQL 是 Oracle 对 SQL99 的一种扩展，基本每一种数据库都会对 SQL 进行扩展，Oracle 对 SQL 的扩展就叫做 PLSQL

   SQL99：

   （1）**是操作所有关系型数据库的规则**

   （2）是第四代语言

   （3）**是一种结构化查询语言**

   （4）只需发出合法合理的命令，就有对应的结果显示

2. 专用于 Oracle 服务器，在 SQL 基础之上，添加了一些过程化控制语句，叫 PLSQL 过程化包括有：类型定义，判断，循环，游标，异常或例外处理...

3. 因为 SQL 是第四代命令式语言，无法显示处理过程化的业务，所以得用一个过程化程序设计语言来弥补 SQL 的不足之处

4. SQL 和 PLSQL 不是替代关系，是弥补关系

### 6.1.2 PL/SQL 基础使用

```sql
[declare]
    变量声明(v_name varchar2(50));
begin
    执行语句（代码主体部分，进行业务实现）;
[exception]
    异常错误（捕获异常，执行对应代码）;
end;
```

### 6.1.3 PL/SQL 变量

变量来源于数学，是计算机语言中能储存计算结果或能表示值的抽象概念，变量可以通过变量名访问，在一些语言中，变量可能被明确为是能表示可变状态、具有存储空间的抽象

#### 6.1.3.1 变量类型

| 类型           | 子类                                                    | 说 明                                                        | 范 围                                                        | ORACLE 限制 |
| -------------- | ------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ----------- |
| char           | character string rowid nchar raw clob blob              | **定长**字符串   民族语言字符集                              | 0 -> 32767 可选,确省=1                                       | 2000        |
| varchar2       | varchar, string nvarchar2                               | **可变**字符串 民族语言字符集                                | 0 -> 32767 4000                                              | 4000        |
| binary_integer |                                                         | 带符号整数, 为整数计算优化性能                               |                                                              |             |
| number(p,s)    | dec double precision integer int numeric real small int | 小数, number 的子类型 高精度实数 整数, number 的子类型 与 number 等价 与 number 等价 整数, number 的子类型  整数, 比 integer 小 |                                                              |             |
| long           |                                                         | 变长字符串 0 -> 2147483647                                   | 32,767 字节                                                  |             |
| date           | year month day hour minute second                       | 日期型                                                       | **公元前 4712 年 1 月 1 日** 至 **公元后 4712 年 12 月 31 日** |             |
| boolean        |                                                         | 布尔型                                                       | true, false, null                                            | 不使用      |
| rowid          |                                                         | 存放数据库行号                                               |                                                              |             |
| urowid         |                                                         | 通用行标识符，字符类型                                       |                                                              |             |

```sql
变量名 类型

常量名称 constant 数据类型 := 值; (常量只能初始化)
```

#### 6.1.3.2 特殊类型

1. **记录类型**：

   记录类型是把逻辑相关的数据作为一个单元存储起来，称作 PL/SQL RECORD 的域(FIELD)，其作用是存放互不相同但逻辑相关的信息

   ```sql
   1. 定义记录类型
   type 记录类型名 is record (
       变量名 类型 [not null] [:= 默认值]，
       .....
   )
   
   2. 创建记录类型实例
   实例名 记录类型名
   ```

2. **%type**：

   定义一个变量，其数据类型与已经定义的某个数据变量的类型相同，或者与数据库表的某个列的数据类型相同，这时可以使用%type

   使用%type 特性的优点在于：

   1. 所引用的数据库列的数据类型可以不必知道
   2. 所引用的数据库列的数据类型可以实时改变

   ```sql
   变量名 表名.列名%type
   ```

3. %rowtype：

   返回一个 **记录类型**, 其数据类型和数据库表的数据结构相一致

   使用%ROWTYPE 特性的优点在于：

   1. 所引用的数据库中列的个数和数据类型可以不必知道
   2. 所引用的数据库中列的个数和数据类型可以实时改变

   ```sql
   变量名 表名%rowtype
   
   select * into 变量名
   
   使用：变量名.列名
   ```

4. is table of

   指定是一个集合的表的数组类型,简单的来说就是一个可以存储一列多行的数据类型。简单的理解就是定义一个数组类型

   ```sql
   
   ```

   

#### 3. 声明变量常用类型和方式

1. 变量常用类型：
   1. number
   2. varchar2
   3. %type
   4. %rowtype

### 6.1.4 常用表达式

```sql
1. select ... into ... 将查询结果赋给 into 后的变量 一一对应

2. dbms_output.put_line() 打印结果 包含换行符

3. dbms_output.put() 打印结果 不包含换行符

4. &输入描述 手动输入 pl/sql
```

## 6.2 函数

### 6.2.1 函数的创建

```sql
create or replace function [所有者.]函数名称(参数[, 参数, ...])
return 返回数据类型
[authid define|current_user]
--指定过程是使用用户权限还是创建者权限运行
[DETERMINISTIC]--优化器提示，复制一个保留值
[PARALLEL_ENABLE...]--优化器提示，并行处理
[PIPELINED]--函数结果是否应该通过pipe row多次返回
[RESULT_CACHE...]--输入和返回值是否保留在新的函数结果缓存中。
is
声明部分
begin
执行语句
return 返回内容
exception
异常处理
end [过程名称];
```

### 6.2.2 函数的使用

>**注意：**
>
>不能使用 exec 或 call 调用函数，必须依赖现成的存储过程或者一段完整 plsql 代码

## 6.3 动态sql

### 6.3.1 描述

所谓的动态SQL就是自己拼接 SQL字符串，在用 Oracle 内方法执行 SQL字符串

### 6.3.2 execute immediate

立即执行sql语句，常用于执行ddl例如：create，truncate

```sql
execute immediate sql字符串 [into(只有在执行查询时使用) 变量[, 变量 ...]]
[using 参数[, 参数 ...]];
```

### 6.3.3 dbms_sql包

1. 先将要执行的SQL语句或一个语句块放到一个字符串变量中
2. 使用DBMS_SQL包的parse过程来分析该字符串
3. 使用DBMS_SQL包的bind_variable过程来绑定变量
4. 使用DBMS_SQL包的execute函数来执行语句。

## 6.4 包

模块化的思想，用于分类管理过程（procedure）和函数（function）

可以把存储过程分门别类，而且不同的package的存储过程可以重名。用package不仅能把存储过程分门别类，而且在package里可以定义公共的变量/类型，既方便了编程，又减少了服务器的编译开销。

**注意：**

1. 数据库中所有的过程（procedure）和函数（function）都要用 package 进行封装，便于管理；
2. 单个的过程（procedure）和函数（function）建议不超过 3000 行； 
3. 每个 package 在 create 时都要带上 '属主'（避免所处位置错误）。

### 6.4.1 包头

```sql
create or replace package 包名
is
    --类型变量的声名
    type 类型 ... ;--类型的定义
    变量名 数据类型; --变量的声名
    --常量的声名
    常量名 constant 数据类型:=常量值; --常量的声名
    procedure 存储过程名[(形参 in|out|in out 数据类型,...)]; --存储过程的声名
    function 函数名(形参　数据类型) return 返回值类型;  --函数的声名
end [包名];
```

```sql
drop package 包名;
```

示例：

```sql
CREATE OR REPLACE PACKAGE it_pack is
  --自定义类型
  type student is record(s_id number,s_name varchar2(100));
  --存过
  procedure pselect_st(stid in number, sname out varchar2);
  --函数
  function fselect_st(stid in number) return varchar2;  
end it_pack;

```

### 6.4.2 包体

```sql
create or replace package body 包名
is
    --私有类型变量的声名
    type 类型 ... ;
    变量名 数据类型;
    --私有常量的声名
    常量名 constant 数据类型:=常量值; --常量的声名  
    --私有的存储过程和函数实现
    --存储过程的实现
    procedure 存储过程名[(形参 in|out|in out 数据类型,...)]
    is
    begin
     实现代码;
    end;
end;
```

```sql
drop package body 包名;
```

示例：

```sql
CREATE OR REPLACE PACKAGE body it_pack is
  --存过
  procedure pselect_st(stid in number, sname out varchar2) 
  as
  begin
    select h.pname into sname from hb_product h where h.pid = stid;
  end pselect_st;
  --函数
  function fselect_st(stid in number) return varchar2 
  as st student;
  begin
    select h.pid,h.pname into st.s_id,st.s_name from hb_product h where h.pid = stid;
    return st.s_name;
  end fselect_st;
end it_pack;
```

### 6.4.3 使用

```sql
--存过
declare
  sname varchar2(20);
begin
  it_pack.pselect_st(7, sname);
  dbms_output.put_line(sname);
end;

--函数
select it_pack.fselect_st(7) from dual;
```

## 6.5 存储过程

所谓存储过程，就是一段存储在数据库中执行某块业务功能的程序模块。 它是由一段或者多段的PL/SQL代码块或者SQL语句组成的一系列代码块。

### 6.5.1 创建

```sql
create or replace procedure [拥有者.]过程名(参数[, 参数, ...]) 
[authid define|current_user]
--指定过程是使用用户权限还是创建者权限运行
is
声明部分
begin
执行语句
exception
异常处理
end [过程名称];
```

### 6.5.2 调用

```sql
1. exec 过程名();

2. call 过程名();

3.
declare
begin
    过程名();
end;
```

**注意：**

1. exec：是 plsql 语言，执行会捕获并输出某些异常，**在程序窗口中执行**
2. call：是 sql 语言，会忽略某些异常

### 6.5.3 参数

1. in：将值传入进去
2. out：关联存储地址，可以对传入的变量赋值，并且传入时赋值null
3. in out：关联存储地址，可以对传入的变量赋值

## 6.6 异常处理

异常情况处理(**exception**)是用来处理正常执行过程中未预料的事件，程序块的异常处理预定义的错误和自定义错误,由于 PLSQL 程序块一旦产生异常而没有指出如何处理时，程序就会自动终止整个程序运行。

### 6.6.1 预定义错误

ORACLE 预定义的异常情况大约有 24 个。对这种异常情况的处理，无需在程序中定义，由 ORACLE 自动将其引发

| 错误号        | 异常错误信息名称                                             | 说明                                                         | 解决办法                                                     |
| ------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ORA-00001     | unique constraint violated                                   | 试图破坏一个唯一性限制                                       | 源数据去重；目标表字段去掉唯一约束                           |
| ORA-00051     | timeout occurred while waiting for a resource                | 在等待资源时发生超时                                         | 检查任何已死的、未恢复的实例并恢复它们                       |
| ORA-00061     | another instance has a different DML_LOCKS setting           | 由于发生死锁事务被撤消                                       | 确保所有实例的初始化。ORA 文件将DML_LOCKS参数指定为 0 或全部指定为非零 |
| ORA-01001     | invalid cursor                                               | 无效的游标                                                   | 游标没有打开                                                 |
| ORA-01012     | not logged on                                                | 未完全关闭数据库                                             | 先kill，再重启                                               |
| ORA-01017     | invalid username/password                                    | 无效的用户名/口令                                            | 确认用户名和密码                                             |
| ORA-01403     | no data found                                                | SELECT INTO 没有找到数据                                     | 未找到数据默认给零 NVL(列名,0)                               |
| ORA-01422     | exact fetch returns more than requested                      | SELECT INTO 返回多行                                         | 检查过滤条件；使用游标                                       |
| ORA-01476     | divisor is equal to zero                                     | 除数为零                                                     | 修改代码逻辑                                                 |
| ORA-01722     | invalid number                                               | 无效数字                                                     | 数据类型错误                                                 |
| ORA-06500     | STORAGE_ERROR                                                | 内存不够引发的内部错误，由于plsql运行时内存溢出，导致内部plsql发生错误 |                                                              |
| ORA-06501     | PROGRAM_ERROR                                                | 内部错误                                                     | 表示存在PL/SQL内部问题，用户此时可能需要重新安装数据字典和PL/SQL系统包 |
| ORA-06502     | numeric or value errorstring                                 | 由于过程性语句出现转换、截断、算术错误而产生的异常；当执行赋值操作时，如果变量长度不足以容纳实际数据，会触发此异常 | 改变数据的类型，或长度                                       |
| ORA-06504     | Return types of Result Set variables                         | 结果集变量或查询的返回类型不匹配                             | 当执行赋值操作时，如果宿主游标变量和PL/SQL游标变量的返回类型不兼容，会触发此异常 |
| ORA-06511     | cursor already open                                          | 试图打开一个已打开的游标                                     | for 循环不需要open                                           |
| ORA-06530     | Reference to uninitialized composite                         | 试图对一个NULL对象的属性赋值                                 | 变量初始化                                                   |
| ORA-06531     | Reference to uninitialized collection                        | 对未初始化复合的引用                                         | 集合数据类型（is table of）赋值前必须初始化，否则报此错误    |
| **ORA-64203** | Destinationbuffertoo small to hold CLOB data after character set conversion | 目标缓冲区太小,无法容纳字符集转换之后的 CLOB 数据            | 应该是某clob字段，插入目标字段对应的长度太小了，调整目标字段类型 |
| **ORA-01400** | cannot insert NULL in （）                                   | 无法将 NULL 插入 ()                                          | 字段有非空限制                                               |
| **ORA-08103** |                                                              |                                                              | 有两种可能，步骤SQL中所用到的表发生了表结构变化或者被truncate了，引起事务报错。作业存在慢SQL，长时间运行不出来，被ORACLE系统杀掉了。如果是后者，则尝试优化分析，并将原因反馈给上级运维 |
| **ORA-12899** |                                                              |                                                              | SQL中查询的某字段数据长度大于了目标表中字符允许长度          |
| **ORA-01438** | **value larger than specified precision allowed for**        | 精度                                                         | SQL中查询的某字段数据精度大于了目标表中数字允许精度          |
| **ORA-00904** |                                                              |                                                              | 字段不存在，检查目标表和SQL，到底哪个字段不存在              |
| **ORA-00054** |                                                              |                                                              | 可能发生了锁表，具体查询锁表情况，并解决                     |



# 七、数据字典

# 八、常用脚本

## 8.1 表结构

删表

建表

主键

索引

视图

## 8.2 存储过程

删

建

## 8.3 运维脚本

### 8.3.1 锁表操作

**1.查看目标表有没有被锁**

```sql
SELECT A.OBJECT_NAME,
            C.SID,
            C.SERIAL#,
            C.PROGRAM,
            C.USERNAME,
            C.COMMAND,
            C.MACHINE,
            C.LOCKWAIT,
            'ALTER SYSTEM KILL SESSION ''' || C.SID || ',' || C.SERIAL# || ''';' KILL_SQL
FROM ALL_OBJECTS A,V$LOCKED_OBJECT B,V$SESSION C
WHERE A.OBJECT_ID = B.OBJECT_ID
   AND B.SESSION_ID = C.SID
 --AND A.OBJECT_NAME = '';--表名
```

**2.杀掉锁表会话**

```sql
alter system kill session 'SID,SERIAL#';
```

**杀掉后再次执行步骤1查看是否还存在相关会话。**

### 8.3.2 查看剩余表空间

```sql
SELECT A.TABLESPACE_NAME "表空间名",
       TOTAL "表空间大小",
       FREE "表空间剩余大小",
       (TOTAL - FREE) "表空间使用大小",
       TOTAL / (1024 * 1024) "表空间大小(MB)",
       FREE / (1024 * 1024) "表空间剩余大小(MB)",
       (TOTAL - FREE) / (1024 * 1024) "表空间使用大小(MB)",
       ROUND((TOTAL - FREE) / TOTAL, 4) * 100 "使用率 %"
  FROM (SELECT TABLESPACE_NAME, SUM(BYTES) FREE
          FROM DBA_FREE_SPACE
         GROUP BY TABLESPACE_NAME) A,
       (SELECT TABLESPACE_NAME, SUM(BYTES) TOTAL
          FROM DBA_DATA_FILES
         GROUP BY TABLESPACE_NAME) B
 WHERE A.TABLESPACE_NAME = B.TABLESPACE_NAME;
```

### 8.3.3 Oracle误删除表从回收站恢复

```sql
select object_name, original_name, partition_name, type, ts_name, createtime,droptime
from recyclebin; 

flashback table TRANS_DM_ZSXM to before drop ; 
```

### 8.3.4 查看包含某个字段的表

```SQL
select column_name,
       table_name,
       data_type,
       data_length,
       data_precision,
       data_scale
  from DBA_TAB_COLUMNS
 where column_name = 'COL1';
```
