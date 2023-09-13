# 一、数据类型

 支持的数据类型有：Bigint、Double、String、Datetime、Boolean、Decimal，Float

| 类型     | 描述                                                         | 取值范围                                                     |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Bigint   | 8字节有符号[整型](https://so.csdn.net/so/search?q=整型&spm=1001.2101.3001.7020)。请不要使用整型的最小值 (-9223372036854775808)，这是系统保留值。 | -9223372036854775807 ~ 9223372036854775807                   |
| String   | [字符串](https://so.csdn.net/so/search?q=字符串&spm=1001.2101.3001.7020)，支持UTF-8编码。其他编码的字符行为未定义。 | 单个String列最长允许8MB。                                    |
| Boolean  | 布尔型。                                                     | True/False                                                   |
| Double   | 8字节双精度浮点数。                                          | -1.0 *10308 ~ 1.0* 10308                                     |
| Datetime | 日期类型。使用东八区时间作为系统标准时间。                   | 0001-01-01 00:00:00 ~ 9999-12-31 23:59:59                    |
| decimal  | decimal类型支持null值，小数点前36位有效数字，小数点后18位有效数字。 正负无穷, 不支持，如果计算结果为正负无穷，或超出decimal的值域时抛异常，绝对值小于最小可表达范围时，置0。 | -999999999999999999999999999999999999.999999999999999999 ~ 999999999999999999999999999999999999.999999999999999999 select '1',cast("999999999999999999999999999999999999.999999999999999999" as decimal) from dual; |

## 1.1 数据类型转换

MaxCompute SQL允许数据类型之间的转换，类型转换方式包括显式类型转换和隐式类型转换。

### 1.1.1 显式类型转换

显式类型转换是通过**CAST(col_name as type)**函数将一种数据类型的值转换为另一种类型的值，在MaxCompute SQL中支持的显式类型转换，如下表所示。 关于CAST的介绍请参见[CAST](https://help.aliyun.com/document_detail/48976.htm#section-bpc-dy1-wdb)。

| From/To  | BIGINT | DOUBLE | STRING | DATETIME | BOOLEAN | DECIMAL | FLOAT  |
| :------- | :----- | :----- | :----- | :------- | :------ | :------ | :----- |
| BIGINT   | 不涉及 | Y      | Y      | N        | Y       | Y       | Y      |
| DOUBLE   | Y      | 不涉及 | Y      | N        | Y       | Y       | Y      |
| STRING   | Y      | Y      | 不涉及 | Y        | Y       | Y       | Y      |
| DATETIME | N      | N      | Y      | 不涉及   | N       | N       | N      |
| BOOLEAN  | Y      | Y      | Y      | N        | 不涉及  | Y       | Y      |
| DECIMAL  | Y      | Y      | Y      | N        | Y       | 不涉及  | Y      |
| FLOAT    | Y      | Y      | Y      | N        | Y       | Y       | 不涉及 |

**其中：**Y表示可以转换，N表示不可以转换，不涉及表示不需要转换。不支持的显式类型转换会失败并报错退出。

**示例**

```sql
SELECT CAST(user_id AS DOUBLE) AS new_id;
SELECT CAST('2015-10-01 00:00:00' AS DATETIME) AS new_date;
SELECT CAST(ARRAY(1,2,3) AS ARRAY<STRING>);
SELECT CONCAT_WS(',', CAST(ARRAY(1, 2) AS ARRAY<STRING>));
```

**使用说明和限制**

- 将DOUBLE类型转为BIGINT类型时，小数部分会被截断，例如`CAST(1.6 AS BIGINT) = 1`。
- 满足DOUBLE格式的STRING类型转换为BIGINT时，会先将STRING转换为DOUBLE，再将DOUBLE转换为BIGINT，因此，小数部分会被截断，例如`CAST(“1.6” AS BIGINT) = 1`。
- 满足BIGINT格式的STRING类型可以被转换为DOUBLE类型，小数点后保留一位，例如`CAST(“1” AS DOUBLE) = 1.0`。
- 日期类型转换时采用默认格式`yyyy-mm-dd hh:mi:ss`。
- 部分类型之间不可以通过显式的类型转换，但可以通过SQL内建函数进行转换，例如从BOOLEAN类型转换到STRING类型，可使用函数`TO_CHAR`，详情请参见[TO_CHAR](https://help.aliyun.com/document_detail/48973.htm#section-mdh-lbk-ggy)。而`TO_DATE`函数同样支持从STRING类型到DATETIME类型的转换，详情请参见[TO_DATE](https://help.aliyun.com/document_detail/48974.htm#section-b3z-1fm-vdb)。
- DECIMAL超出值域，`CAST STRING TO DECIMAL`可能会出现最高位溢出报错、最低位溢出截断等情况。
- DECIMAL类型显示转换为DOUBLE、FLOAT等类型会产生精度损失，对于精度有要求的场景，例如计算金额、费率等，建议使用DECIMAL类型。
- MaxCompute支持复杂类型的类型转换功能。其中复杂类型的隐式类型转换要求子类型能够隐式转换，而显示转换要求子类型能够显示转换。STRUCT类型转换不要求字段名称一致，但是要求字段的数量一致，且对应的字段能够隐式或显示转换。例如：
  - `ARRAY<BIGINT>`能隐式转换或显示转换为`ARRAY<STRING>`。
  - `ARRAY<BIGINT>`能显示转换为`ARRAY<INT>`，但是不能隐式转换。
  - `ARRAY<BIGINT>`不能隐式转换或显示转换为`ARRAY<DATETIME>`。
  - `STRUCT<a:BIGINT,b:INT>`能隐式转换为`STRUCT<col1:STRING,col2:BIGINT>`，但是不能隐式或显示转换为`STRUCT<a:STRING>`。

### 1.1.2 隐式类型转换



## 1.2 oracle与ODPS的数据类型映射表

| ORACLE                                                       | Description                                                  | ODPS                                                  | 转换到ODPS Desc                                              |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ----------------------------------------------------- | ------------------------------------------------------------ |
| VARCHAR2(*size* [BYTE \| CHAR])                              | VARCHAR2(1-4000)                                             | string                                                | 单个String列最长允许8MB。Oralce12c最长的varchar(30000)约为30Kb，可以存储。但是如果文本不是需要分析的列，最好还是放在OSS中。 |
| NVARCHAR2(*size*)                                            | NVARCHAR2(1-4000)                                            | string                                                | 单个String列最长允许8MB。                                    |
| NUMBER [ (*p* [, *s*]) ]                                     | 无小数位 19位以下：NUMBER(19, 0) 36位以下：NUMBER(36, 0) 有小数位p and s 小于等于17,例如NUMBER(17,2) p-s小于等于36，s小于等于18，例如NUMBER(38,2) 其他 | 无小数位bigint decimal 有小数位 double decimal string | 考虑精度丢失情况，数值1.1在oracle存储和在ODPS存储必须完全相等。所以，这里的相等就是看到的数字全一致。无法对应的数据类型，只能存储为varchar。 |
| FLOAT [(p)]                                                  | float(8) 其他                                                | double 参考number                                     | Float中的p指的是二进制的长度，最大可以到126。等同于NUMBER（38）。占22字节。所以，如果数据与NUMBER相同，请参考NUMBER对应关系。 |
| LONG                                                         | 最长可以到达2Gb长度的字符类型。                              | 无                                                    | 建议数据存储在OSS                                            |
| DATE                                                         | 日期                                                         | datetime                                              | 因为当前ADS日期类型函数支持不够丰富，统一转为unixtime格式，存储为bigint类型。如果同步到ADS也要存储为日期，转为datetime类型。(oracle 年的范围 -4713 到 +9999) |
| BINARY_FLOAT                                                 | 32-bit floating point number. This data type requires 4 bytes. | double                                                | 等同于oracle的float(4)，number(7)                            |
| BINARY_DOUBLE                                                | 64-bit floating point number. This data type requires 8 bytes. | double                                                | 等同于oracle的float(8), number(17)                           |
| TIMESTAMP[(*fractional_seconds_precision*)]                  | 时间戳                                                       | datetime                                              | 因为当前ADS日期类型函数支持不够丰富，统一转为unixtime格式，存储为bigint类型。如果同步到ADS也要存储为日期，转为datetime类型。 |
| TIMESTAMP[(*fractional_seconds_precision*)] WITHTIME ZONE    | 时间戳，带时区                                               | datetime                                              | 因为当前ADS日期类型函数支持不够丰富，统一转为unixtime格式，存储为bigint类型。TIME ZONE 特征丢失。 |
| TIMESTAMP[(*fractional_seconds_precision*)] WITHLOCAL TIME ZONE | 时间戳，带时区                                               | datetime                                              | 因为当前ADS日期类型函数支持不够丰富，统一转为unixtime格式，存储为bigint类型。TIME ZONE 特征丢失。 |
| INTERVAL YEAR [(*year_precision*)] TOMONTH                   |                                                              | bigint                                                | 时间间隔无对应数据类型，建议转为秒                           |
| INTERVAL DAY [(*day_precision*)] TO SECOND[(*fractional_seconds_precision*)] |                                                              | bigint                                                | 时间间隔无对应数据类型，建议转为秒                           |
| RAW(*size*)                                                  | RAW，类似于CHAR，声明方式RAW(L)，L为长度，以字节为单位，作为数据库列最大2000，作为变量最大32767字节。 | string                                                | string Oracle中RAW和Varchar2常用的两个转换函数   1. UTL_RAW.CAST_TO_RAW  该函数按照缺省字符集，将VARCHAR2字符串转换为RAW。 insert into cmpp_submit (dest_terminal_id,msg_content) values('13001081371',UTL_RAW.CAST_TO_RAW('您好！')); 2. UTL_RAW.CAST_TO_VARCHAR2 该函数按照缺省字符集合，将RAW转换为VARCHAR2。 select UTL_RAW.CAST_TO_VARCHAR2(msg_content) from cmpp_deliver; |
| LONG RAW                                                     | LONG RAW，类似于LONG，作为数据库列最大存储2G字节的数据，作为变量最大32760字节 |                                                       | 建议数据存储在OSS                                            |
| ROWID                                                        | 行唯一识别字符串                                             | string                                                | 物理ROWID(Physical Rowid)可以让我们快速的访问某些特定的行。只要行存在，它的物理ROWID就不会改变。高效稳定的物理ROWID在查询行集合、操作整个集合和更新子集是很有用的。例如，我们可以在UPDATE或DELETE语句的WHERE子句中比较UROWID变量和ROWID伪列来找出最近一次从游标中取出的行数据。 |
| UROWID [(*size*)]                                            | 行唯一识别字符串的base-64编码                                | string                                                | 扩展ROWID使用检索出来的每一行记录的物理地址的base-64编码。ROWIDTOCHAR()，ROWIDTOCHAR() |
| CHAR [(*size* [BYTE \| CHAR])]                               | 定长字符串                                                   | string                                                | string                                                       |
| NCHAR[(*size*)]                                              | 定长字符串                                                   | string                                                | string                                                       |
| CLOB                                                         | 字符型大字段数据类型                                         | 无                                                    | 建议数据存储在OSS                                            |
| NCLOB                                                        | 字符型大字段数据类型                                         | 无                                                    | 建议数据存储在OSS                                            |
| BLOB                                                         | 二进制型大字段数据类型                                       | 无                                                    | 建议数据存储在OSS                                            |
| BFILE                                                        | 二进制文件,存储在数据库外的操作系统文件，只读的。把此文件当二进制处理。 | 无                                                    | 建议数据存储在OSS                                            |



