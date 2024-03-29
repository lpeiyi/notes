**目录**

[toc]

# 1 安装和升级MySQL数据库（社区版）

## 1.1 安装

学习一门数据库，肯定需要从安装开始学起，MySQL数据库常用的安装方式有：

- YUM源安装
- RPM包安装
- 二进制文件安装
- 源码安装

最常用的安装方式是RPM包安装和二进制文件安装。下面我基于`Red Hat Enterprise Linux`操作系统介绍这两种安装方法。

我个人认为MySQL数据库的安装十分友好，不像Oracle数据库那么困难，这点必须好评。很多同学在学习Oracle数据库时就被安装这个步骤反复折磨，有一部分同学便是因为一只安装不成功，从而放弃了学习Oracle数据库的想法。

### 1.1.1 RPM包安装

**一、官网下载RPM包**

RPM包的下载地址是：https://dev.mysql.com/downloads/mysql/

根据操作系统类型和版本版本选择需要下载的包，我实验的环境是：

```sql
[root@lu9up ~]# cat /etc/redhat-release
Red Hat Enterprise Linux Server release 7.9 (Maipo)
```

选择的RPM包如下，点击下载到本地：

![Alt text](image.png)

**二、上传到操作系统**

上传的位置看个人而定

```bash
[root@mysql001 ~]# ll | grep mysql
-rw-r--r--  1 root root 1031792640 Dec 15 23:57 mysql-8.0.34-1.el7.x86_64.rpm-bundle.tar
```

**三、检查是否安装MySQL或MariaDB**

centos和redhat上一般已经安装有mariadb-libs包和/my.cnf配置文件，安装MySQL数据库前一定要删除，以免和新安装的MySQL造成冲突。

检查默认配置文件是否存在：

```bash
[root@mysql001 ~]# ll /etc/my.cnf
-rw-r--r--. 1 root root 570 Oct  1  2020 /etc/my.cnf
```

再检查是否有MySQL或者MariaDB的安装包：

```bash
[root@mysql001 ~]# rpm -qa | grep -i mysql
[root@mysql001 ~]# rpm -qa | grep -i mariadb
mariadb-libs-5.5.68-1.el7.x86_64
```

删除这些文件：

```bash
[root@mysql001 ~]# rpm -e mariadb-libs
[root@mysql001 ~]# ll /etc/my.cnf
ls: cannot access /etc/my.cnf: No such file or directory
```

删除mariadb-libs后，/etc/my.cnf也会被一并删除。

注意：如果报依赖错误，使用下面的命令删除：

```bash
rpm -e --nodeps mariadb-libs-5.5.68-1.el7.x86_64
```

卸载mariadb-libs后，my.cnf也会被一并删除。

**四、创建MySQL用户和组**

```bash
groupadd -g 27 mysql
useradd -g mysql mysql
passwd mysql
```

mysql用户添加系统权限：

```sql
[root@mysql001 ~]# vim /etc/sudoers
```

添加：

```bash
mysql     ALL=(ALL)      NOPASSWD:ALL
```

NOPASSWD是无需输入密码（个人习惯），安全起见，建议改为ALL。

**五、解压安装包**

查看安装包里包含的rpm包：

```bash
[root@mysql001 ~]# tar -tvf mysql-8.0.34-1.el7.x86_64.rpm-bundle.tar
-rw-r--r-- bteam/common 16755300 2023-06-25 11:06 mysql-community-client-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common  3745824 2023-06-25 11:06 mysql-community-client-plugins-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common   681724 2023-06-25 11:06 mysql-community-common-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common 528347988 2023-06-25 11:07 mysql-community-debuginfo-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common   1947800 2023-06-25 11:07 mysql-community-devel-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common   4217912 2023-06-25 11:07 mysql-community-embedded-compat-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common   2344364 2023-06-25 11:07 mysql-community-icu-data-files-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common   1563264 2023-06-25 11:07 mysql-community-libs-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common    685312 2023-06-25 11:08 mysql-community-libs-compat-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common  67410132 2023-06-25 11:08 mysql-community-server-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common  25637968 2023-06-25 11:08 mysql-community-server-debug-8.0.34-1.el7.x86_64.rpm
-rw-r--r-- bteam/common 378442676 2023-06-25 11:10 mysql-community-test-8.0.34-1.el7.x86_64.rpm
```

解压缩安装包：

```bash
[root@mysql001 ~]# tar -xvf mysql-8.0.34-1.el7.x86_64.rpm-bundle.tar -C /home/mysql/rpm/
mysql-community-client-8.0.34-1.el7.x86_64.rpm
mysql-community-client-plugins-8.0.34-1.el7.x86_64.rpm
mysql-community-common-8.0.34-1.el7.x86_64.rpm
mysql-community-debuginfo-8.0.34-1.el7.x86_64.rpm
mysql-community-devel-8.0.34-1.el7.x86_64.rpm
mysql-community-embedded-compat-8.0.34-1.el7.x86_64.rpm
mysql-community-icu-data-files-8.0.34-1.el7.x86_64.rpm
mysql-community-libs-8.0.34-1.el7.x86_64.rpm
mysql-community-libs-compat-8.0.34-1.el7.x86_64.rpm
mysql-community-server-8.0.34-1.el7.x86_64.rpm
mysql-community-server-debug-8.0.34-1.el7.x86_64.rpm
mysql-community-test-8.0.34-1.el7.x86_64.rpm
```

检查rpm包：

```bash
[mysql@mysql001 rpm]$ pwd
/home/mysql/rpm
[mysql@mysql001 rpm]$ ls
mysql-community-client-8.0.34-1.el7.x86_64.rpm           mysql-community-icu-data-files-8.0.34-1.el7.x86_64.rpm
mysql-community-client-plugins-8.0.34-1.el7.x86_64.rpm   mysql-community-libs-8.0.34-1.el7.x86_64.rpm
mysql-community-common-8.0.34-1.el7.x86_64.rpm           mysql-community-libs-compat-8.0.34-1.el7.x86_64.rpm
mysql-community-debuginfo-8.0.34-1.el7.x86_64.rpm        mysql-community-server-8.0.34-1.el7.x86_64.rpm
mysql-community-devel-8.0.34-1.el7.x86_64.rpm            mysql-community-server-debug-8.0.34-1.el7.x86_64.rpm
mysql-community-embedded-compat-8.0.34-1.el7.x86_64.rpm  mysql-community-test-8.0.34-1.el7.x86_64.rpm
```

**六、安装RPM包**

在大部分情况下，MySQL标准安装需要安装mysql-community-server, mysql-community-client, mysql-community-client-plugins, mysql-community-libs, mysql-community-icu-data-files, mysql-community-common, and mysql-community-libs-compat。

虽然使用如yum来安装包更好，但也可以直接用rpm -Uvh命令安装rpm包。但是，使用rpm -Uvh反而使安装过程更容易失败，因为安装过程可能会遇到潜在的依赖问题。

执行安装命令：

```sql
sudo yum -y install mysql-community-{server,client,client-plugins,icu-data-files,common,libs}-*
```

如果只安装客户端程序，可以不安装的mysql-community-server ：

```bash
sudo yum -y install mysql-community-{client,client-plugins,common,libs}-*
```

**七、初始化数据库**

安装好后，先不要启动数据库服务，因为第一次启动MySQL数据库服务时会自动初始化，可以根据自己的需求对系统参数进行修改，修改系统参数的方式为编辑默认配置文件：/etc/my.cnf。

1. datadir：是MySQL数据库系统的一个重要参数，它指定了MySQL数据库的数据文件存放的位置。这些数据文件包括了所有的数据库、表、索引等信息。默认为/var/lib/mysql，可以修改到合适的磁盘路径中，例如/disk1/data。
2. innodb_log_file_size：这个参数指定在一个日志组中，每个log的大小。innodb的logfile就是事务日志，用来在mysql crash后的恢复，所以设置合理的大小对于mysql的性能非常重要，直接影响数据库的写入速度，事务大小，异常重启后的恢复。
3. innodb_data_home_dir：用于指定InnoDB存储引擎的数据文件的基本路径。这个路径下的所有文件都是InnoDB存储引擎的数据文件，包括表空间文件、双写日志文件等。
4. innodb_log_group_home_dir：innodb_log_group_home_dir是MySQL数据库中的一个参数，用于指定InnoDB存储引擎的redo日志文件所在的目录。这些日志文件用于存储事务数据，直到这些数据被写入到表空间的磁盘文件中。默认情况下，innodb_log_group_home_dir的值通常被设置为与innodb_data_home_dir相同。innodb_data_home_dir用于指定InnoDB存储引擎的数据文件的基本路径。这个路径下的所有文件都是InnoDB存储引擎的数据文件，包括表空间文件、双写日志文件等。但是，为了获得最佳的性能，建议将innodb_data_home_dir和innodb_log_group_home_dir设置到不同的物理存储阵列上，这样可以避免IO资源的冲突，有利于服务器处理大量的高并发连接。

```bash
[mysql@mysql001 ~]$ cat /etc/my.cnf

datadir=/disk1/data
socket=/var/lib/mysql/mysql.sock

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

innodb_log_file_size=100M
```

这里，我只调整了datadir和innodb_log_file_size参数。

参数文件准备好后，接下来可以启动mysqld服务。

**八、启动mysql服务**

```bash
[mysql@mysql001 data]$ sudo systemctl status mysqld
● mysqld.service - MySQL Server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: inactive (dead) since Sat 2023-12-16 02:18:31 CST; 6s ago
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html
  Process: 6697 ExecStart=/usr/sbin/mysqld $MYSQLD_OPTS (code=exited, status=0/SUCCESS)
  Process: 6673 ExecStartPre=/usr/bin/mysqld_pre_systemd (code=exited, status=0/SUCCESS)
 Main PID: 6697 (code=exited, status=0/SUCCESS)
   Status: "Server shutdown complete"
[mysql@mysql001 ~]$ sudo systemctl start mysqld
[mysql@mysql001 ~]$ sudo systemctl status mysqld
● mysqld.service - MySQL Server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2023-12-16 00:48:43 CST; 20min ago
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html
  Process: 1031 ExecStartPre=/usr/bin/mysqld_pre_systemd (code=exited, status=0/SUCCESS)
 Main PID: 1631 (mysqld)
   Status: "Server is operational"
   CGroup: /system.slice/mysqld.service
           └─1631 /usr/sbin/mysqld

Dec 16 00:48:37 mysql001 systemd[1]: Starting MySQL Server...
Dec 16 00:48:43 mysql001 systemd[1]: Started MySQL Server.
```

禁止mysqld开机自启：

```bash
[mysql@mysql001 data]$ sudo systemctl disable mysqld
```


**九、查看临时密码**

```bash
[mysql@mysql001 ~]$ sudo grep 'temporary password' /var/log/mysqld.log
2023-12-15T16:48:40.499788Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: ;eYMs-0+Lovk
```

MySQL数据库root的密码为`;eYMs-0+Lovk`，第一次登录需使用这个密码，然后再修改自定义密码。

**十、登录并修改密码**

使用临时密码登录：

```bash
[mysql@mysql001 ~]$ mysql -uroot -p';eYMs-0+Lovk'
```

修改密码：

```sql
mysql> set password = 'Mysql123.';
Query OK, 0 rows affected (0.00 sec)
```

验证：

```bash
[mysql@lu9up ~]$ mysql -uroot -pMysql123.
```

### 1.1.2 二进制包安装

二进制包是经过源码编译后，解压即可用的安装包。相比于rpm包和源码包，官方更推荐在生产环境中使用二进制包安装，因为相对于rpm包安装路径可控，且比源码包安装过程简单，功能性、性能和安全都有优势。

**一、下载二进制包**

下载路径：https://downloads.mysql.com/archives/community/

安装指导：https://dev.mysql.com/doc/refman/8.0/en/binary-installation.html

![Alt text](image-3.png)

下下来上传到/tmp中。

**二、删除自带的配置文件**

centos和redhat上一般已经安装有mariadb-libs包和/my.cnf配置文件，安装MySQL数据库前一定要删除，以免和新安装的MySQL造成冲突。

检查默认配置文件是否存在：

```bash
[root@mysql ~]# ll /etc/my.cnf
-rw-r--r--. 1 root root 570 Oct  1  2020 /etc/my.cnf
```

再检查是否有MySQL或者MariaDB的安装包：

```bash
[root@mysql ~]# rpm -qa | grep -i mysql
[root@mysql ~]# rpm -qa | grep -i mariadb
mariadb-libs-5.5.68-1.el7.x86_64
```

删除这些文件：

```bash
[root@mysql001 ~]# rpm -e mariadb-libs
[root@mysql001 ~]# ll /etc/my.cnf
ls: cannot access /etc/my.cnf: No such file or directory
```

删除mariadb-libs后，/etc/my.cnf也会被一并删除。

注意：如果报依赖错误，使用下面的命令删除： 

```bash
[root@mysql ~]# rpm -e mariadb-libs
error: Failed dependencies:
        libmysqlclient.so.18()(64bit) is needed by (installed) postfix-2:2.10.1-9.el7.x86_64
        libmysqlclient.so.18(libmysqlclient_18)(64bit) is needed by (installed) postfix-2:2.10.1-9.el7.x86_64
[root@mysql ~]# rpm -e --nodeps mariadb-libs-5.5.68-1.el7.x86_64
[root@mysql ~]# rpm -qa | grep -i mariadb
```

卸载mariadb-libs后，my.cnf也会被一并删除。

**三、创建用户和组**

```bash
[root@mysql ~]# groupadd mysql
[root@mysql ~]# useradd -g mysql mysql
[root@mysql ~]# passwd mysql
```

**四、解压二进制包**

```bash
[root@mysql ~]# cd /usr/local
[root@mysql local]# tar xvf /tmp/mysql-8.0.25-linux-glibc2.12-x86_64.tar.xz
[root@mysql local]# ln -s mysql-8.0.25-linux-glibc2.12-x86_64 mysql
```

**五、编辑配置文件**

```bash
[root@mysql local]# vim /etc/my.cnf
```

添加以下基础的配置文件：

```bash
[mysqld]
basedir=/usr/local/mysql
datadir=/data/mysql/3306/data
user=mysql
port=3306
socket=/data/mysql/3306/data/mysql.sock
log_error=/data/mysql/3306/data/mysqld.err

[client]
socket=/data/mysql/3306/data/mysql.sock
```

**六、创建数据目录**

```bash
[root@mysql local]# mkdir -p /data/mysql/3306/data
[root@mysql data]# chown -R mysql.mysql /data
```

**七、添加环境变量**

```bash
[root@mysql mysql]# vim /etc/profile
```

在最后追加：

```bash
export MYSQL_HOME=/usr/local/mysql
export PATH=$PATH:$HOME/bin:$MYSQL_HOME/bin
```

生效：

```bash
[root@mysql mysql]# source /etc/profile
```

**八、初始化实例**

切换到mysql用户：

```bash
[root@mysql mysql]# su - mysql
```

执行初始化：

```bash
[mysql@mysql ~]$ mysqld --defaults-file=/etc/my.cnf  --initialize
```

如果没有跳出报错信息，说明初始化成功。此时，在数据目录可以看到已经生成了相应的文件。

**九、启动实例**

```bash
[mysql@mysql ~]$ mysql_ssl_rsa_setup
[mysql@mysql bin]$ mysqld_safe --user=mysql &
[1] 6989
[mysql@mysql bin]$ 2024-01-21T17:50:13.640819Z mysqld_safe Logging to '/data/mysql/3306/data/mysqld.err'.
2024-01-21T17:50:13.719308Z mysqld_safe Starting mysqld daemon with databases from /data/mysql/3306/data

[mysql@mysql bin]$
[mysql@mysql bin]$ ps -ef | grep mysqld
root      6831  5394  0 01:47 pts/1    00:00:00 tailf mysqld.err
mysql     6989  5070  0 01:50 pts/0    00:00:00 /bin/sh /usr/local/mysql/bin/mysqld_safe --user=mysql
mysql     7144  6989  1 01:50 pts/0    00:00:02 /usr/local/mysql/bin/mysqld --basedir=/usr/local/mysql --datadir=/data/mysql/3306/data --plugin-dir=/usr/local/mysql/lib/plugin --log-error=/data/mysql/3306/data/mysqld.err --pid-file=mysql.pid --socket=/data/mysql/3306/data/mysql.sock --port=3306
mysql     7303  5070  0 01:52 pts/0    00:00:00 grep --color=auto mysqld
```

**十、登录**

查看临时密码：

```bash
[mysql@mysql bin]$ grep "temporary password" /data/mysql/3306/data/mysqld.err
2024-01-21T17:45:29.080672Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: H#Nva+9w(&tp
```

登录，并修改密码：

```bash
[mysql@mysql bin]$ mysql -uroot -p'H#Nva+9w(&tp'
mysql> alter user user() identified by 'Mysql123.';
```

## 1.2 mysql服务管理

二进制包安装的时候需要配置。

### 1.2.1 /etc/init.d/mysqld

```bash
[mysql@mysql ~]$ cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
```

使用方法：

```bash
[mysql@mysql ~]$ service mysqld status
[mysql@mysql ~]$ service mysqld start
[mysql@mysql ~]$ service mysqld stop
```

### 1.2.2 systemd

**1）创建systemd服务配置文件：**

```bash
[mysql@mysql ~]$ sudo vim /usr/lib/systemd/system/mysqld.service
```

添加：

```bash
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network-online.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql

Type=notify

# Disable service start and stop timeout logic of systemd for mysqld service.
TimeoutSec=0

# Start main service
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf $MYSQLD_OPTS

# Use this to switch malloc implementation
EnvironmentFile=-/etc/sysconfig/mysql

# Sets open_files_limit
LimitNOFILE = 65536

Restart=on-failure

RestartPreventExitStatus=1

# Set enviroment variable MYSQLD_PARENT_PID. This is required for restart.
Environment=MYSQLD_PARENT_PID=1

PrivateTmp=false
```

**2）配置生效**

```bash
[mysql@mysql ~]$ sudo systemctl daemon-reload
```

**3）使用systemd管理mysqld服务**

```bash
[mysql@mysql ~]$ sudo systemctl start mysqld
[mysql@mysql ~]$ sudo systemctl stop mysqld
[mysql@mysql ~]$ sudo systemctl status mysqld
```


## 1.3 升级

## 1.4 卸载

```bash
[mysql@mysql002 ~]$ rpm -qa |grep -i mysql
[mysql@mysql002 ~]$ sudo yum remove mysql-community-* -y
[mysql@mysql002 ~]$ sudo rm -rf /etc/my.cnf
```

# 2 账号和权限

# 3 日志

## 3.1 错误日志

### 3.1.1 系统参数log_error_services

```sql
mysql> show variables like 'log_error_services';
+--------------------+----------------------------------------+
| Variable_name      | Value                                  |
+--------------------+----------------------------------------+
| log_error_services | log_filter_internal; log_sink_internal |
+--------------------+----------------------------------------+
1 row in set (0.00 sec)
```

非内置写组件

```sql
mysql> install component 'file://component_log_sink_syseventlog';
Query OK, 0 rows affected (0.00 sec)

mysql> select component_id,component_urn from mysql.component where component_urn like '%syseventlog%';
+--------------+---------------------------------------+
| component_id | component_urn                         |
+--------------+---------------------------------------+
|            2 | file://component_log_sink_syseventlog |
+--------------+---------------------------------------+
1 row in set (0.00 sec)
```

log_sink_syseventlog配置错误日志写入Linux系统日志:

```sql
mysql> set global log_error_services='log_filter_internal; log_sink_internal; log_sink_syseventlog';
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'log_error_services';
+--------------------+--------------------------------------------------------------+
| Variable_name      | Value                                                        |
+--------------------+--------------------------------------------------------------+
| log_error_services | log_filter_internal; log_sink_internal; log_sink_syseventlog |
+--------------------+--------------------------------------------------------------+
1 row in set (0.01 sec)
```

### 3.1.2 log_filter_internal

**1）日志优先级**

```sql
mysql> show variables like 'log_error_verbosity';
+---------------------+-------+
| Variable_name       | Value |
+---------------------+-------+
| log_error_verbosity | 3     |
+---------------------+-------+
1 row in set (0.00 sec)
```

**2）屏蔽错误事件**

```bash

```

### 3.1.3 log_sink_internal

```sql
mysql> show variables like 'log_error';
+---------------+---------------------+
| Variable_name | Value               |
+---------------+---------------------+
| log_error     | /var/log/mysqld.log |
+---------------+---------------------+
1 row in set (0.00 sec)
```

### 3.1.4 log_filter_diagmet组件

### 3.1.5 log_sink_json组件

### 3.1.6 log_sink_syseventlog组件

```sql
mysql> show variables like '%syseventlog%';
+-------------------------+--------+
| Variable_name           | Value  |
+-------------------------+--------+
| syseventlog.facility    | daemon |
| syseventlog.include_pid | ON     |
| syseventlog.tag         |        |
+-------------------------+--------+
3 rows in set (0.01 sec)
```

### 3.1.7 系统参数 log_timestamps

```sql

```

### 3.1.8 备份错误日志

```bash
[mysql@mysql001 data]$ sudo mv error.log error.log.bak231220
[sudo] password for mysql:
[mysql@mysql001 data]$ mysqladmin -uroot -pMysql123. flush-logs
mysqladmin: [Warning] Using a password on the command line interface can be insecure.
```

### 3.1.9 错误日志记录到数据库中

```sql
mysql> show status like 'error_log%';
+---------------------------+------------------+
| Variable_name             | Value            |
+---------------------------+------------------+
| Error_log_buffered_bytes  | 74336            |
| Error_log_buffered_events | 608              |
| Error_log_expired_events  | 0                |
| Error_log_latest_write    | 1702991680174494 |
+---------------------------+------------------+
4 rows in set (0.00 sec)

mysql> select * from performance_schema.error_log limit 4\G
*************************** 1. row ***************************
    LOGGED: 2023-12-16 00:48:37.870328
 THREAD_ID: 0
      PRIO: System
ERROR_CODE: MY-013169
 SUBSYSTEM: Server
      DATA: /usr/sbin/mysqld (mysqld 8.0.34) initializing of server in progress as process 1120
```

## 3.2 通用查询日志

记录客户端操作日志，包括连接断开信息，发送的sql。

### 3.2.1 系统参数说明

**一、log_output**

```sql
mysql> set global log_output='table,file';
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'log_output';
+---------------+------------+
| Variable_name | Value      |
+---------------+------------+
| log_output    | FILE,TABLE |
+---------------+------------+
1 row in set (0.00 sec)
```

**二、general_log**

```sql
mysql> set global general_log=on;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'general_log';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| general_log   | ON    |
+---------------+-------+
1 row in set (0.00 sec)
```

**三、general_log_file**

```sql
mysql> show variables like 'general_log_file';
+------------------+--------------------------+
| Variable_name    | Value                    |
+------------------+--------------------------+
| general_log_file | /disk1/data/mysql001.log |
+------------------+--------------------------+
1 row in set (0.00 sec)
```

**四、sql_log_off**

### 3.2.2 通用查询日志记录的内容

**一、通用查询日志文件中的记录**

**二、通用查询日志表中的记录**

mysql.general_log的定义：

```sql
mysql> show create table mysql.general_log\G
*************************** 1. row ***************************
       Table: general_log
Create Table: CREATE TABLE `general_log` (
  `event_time` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `user_host` mediumtext NOT NULL,
  `thread_id` bigint unsigned NOT NULL,
  `server_id` int unsigned NOT NULL,
  `command_type` varchar(64) NOT NULL,
  `argument` mediumblob NOT NULL
) ENGINE=CSV DEFAULT CHARSET=utf8mb3 COMMENT='General log'
1 row in set (0.00 sec)
```

```sql
mysql> select event_time,user_host,thread_id,server_id,command_type,convert(argument using utf8mb4) argument
    ->   from mysql.general_log
    ->  where thread_id = 12 order by event_time desc\G
*************************** 1. row ***************************
  event_time: 2023-12-20 00:13:40.560415
   user_host: root[root] @ localhost []
   thread_id: 12
   server_id: 1
command_type: Query
    argument: select event_time,user_host,thread_id,server_id,command_type,convert(argument using utf8mb4) argument
  from mysql.general_log
 where thread_id = 12 order by event_time desc
*************************** 2. row ***************************
  event_time: 2023-12-20 00:13:07.265893
   user_host: root[root] @ localhost []
   thread_id: 12
   server_id: 1
command_type: Query
    argument: select event_time,user_host,thread_id,server_id,command_type,convert(argument using utf8mb4) argument
  from mysql.general_log
 where thread_id = 12 order by event_time desc
```

## 3.3 慢查询日志

慢速查询日志记录的是执行时间超过[long_query_time]()秒和检查的行数超过[min_examined_row_limit]()的SQL语句，这些语句通常是需要进行优化的。

官方参考文档：https://dev.mysql.com/doc/refman/8.0/en/slow-query-log.html

### 3.3.1 慢查询日志的配置参数

服务器使用以下顺序的控制参数来决定是否将查询语句写入慢查询日志：

1. 查询必须不是管理语句（如alter、optimize table等），或者必须启用log_slow_admin_statements参数记录管理类语句；
2. 查询必须至少花费了long_query_time秒，或者必须启用log_queries_not_using_indexes，并且查询的索引没有行限制（如全表扫描、索引全扫描等）；
3. 查询必须至少检索了min_examined_row_limit行；
4. 不被参数log_throttle_queries_not_using_indexes设置阈值限制写入慢sql日志。

下面介绍这些参数：

**一、long_query_time**

规定了查询时间超过此参数值被定义为慢SQL，状态变量Slow_queries记录了慢查询SQL的数量。long_query_time的单位为秒，可以设置成小数，精确到微妙。最小值为0，最大值为31536000，即365天，默认值为10。

查看当前设置：

```sql
mysql> show variables like 'long_query_time';
+-----------------+-----------+
| Variable_name   | Value     |
+-----------------+-----------+
| long_query_time | 10.000000 |
+-----------------+-----------+
1 row in set (0.01 sec)
```

查看慢sql数量：

```sql
mysql> show status like 'slow_queries';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Slow_queries  | 5     |
+---------------+-------+
1 row in set (0.01 sec)

```

将此参数设置为5：

```sql
mysql> set long_query_time=5;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'long_query_time';
+-----------------+----------+
| Variable_name   | Value    |
+-----------------+----------+
| long_query_time | 5.000000 |
+-----------------+----------+
1 row in set (0.00 sec)

```

**二、slow_query_log**

此参数决定是否激活慢sql日志，默认值是off，即关闭。

启用慢查询日志：

```sql
mysql> set global slow_query_log=on;
Query OK, 0 rows affected (0.00 sec)
```

**三、slow_query_log_file**

此参数指定慢sql日志的文件路径和文件名，默认位置在数据目录datadir中，默认文件名是hostname-slow.log。

```sql
mysql> show variables like 'slow_query_log_file';
+---------------------+-------------------------------+
| Variable_name       | Value                         |
+---------------------+-------------------------------+
| slow_query_log_file | /disk1/data/mysql001-slow.log |
+---------------------+-------------------------------+
1 row in set (0.00 sec)
```

查看慢sql日志文件：

```bash
[mysql@mysql001 log]$ tailf /disk1/data/mysql001-slow.log
/usr/sbin/mysqld, Version: 8.0.34 (MySQL Community Server - GPL). started with:
Tcp port: 3306  Unix socket: /var/lib/mysql/mysql.sock
Time                 Id Command    Argument
# Time: 2023-12-20T22:44:21.890879+08:00
# User@Host: root[root] @ localhost []  Id:     9
# Query_time: 0.009038  Lock_time: 0.000008 Rows_sent: 0  Rows_examined: 0 Thread_id: 9 Errno: 0 Killed: 0 Bytes_received: 286 Bytes_sent: 92 Read_first: 0 Read_last: 0 Read_key: 12 Read_next: 0 Read_prev: 0 Read_rnd: 0 Read_rnd_next: 1 Sort_merge_passes: 0 Sort_range_count: 0 Sort_rows: 0 Sort_scan_count: 1 Created_tmp_disk_tables: 0 Created_tmp_tables: 1 Start: 2023-12-20T22:44:21.881841+08:00 End: 2023-12-20T22:44:21.890879+08:00
SET timestamp=1703083461;
select f.title, count(*) as cnt
  from sakila.rental r
  join sakila.inventory i
    on r.inventory_id = i.inventory_id
  join sakila.film f
    on i.film_id = f.film_id
 where r.rental_date between '2005-03-01' and '2005-03-31'
 group by f.film_id
 order by cnt desc
 limit 10;
 ```

**四、log_queries_not_using_indexes**

启用该变量，会记录期望检索所有行的查询语句，也就是说做表全扫描。使用索引的查询也会被记录。例如，使用完整索引扫描的查询使用索引，但会记录日志，因为索引不会限制行数。默认值是false。


**五、min_examined_row_limit**

参数规定了只有当检索的行数超过了参数值的sql语句才会被记录到慢sql日志文件中，默认值是0，没有限制。可以和上一个参数`log_queries_not_using_indexes`搭配使用，可以避免记录一些访问小表的查询。


**六、log_throttle_queries_not_using_indexes**

该参数限制每分钟记录到慢查询日志中的查询语句数量，默认值是0，不限制。

**七、log_slow_extra**

参数log_slow_extra从MySQL 8.0.14开始可用，当启用时，将记录与慢sql相关的额外信息，如状态参数Handler_%。参数默认值为off，建议打开，将参数设置为on。

```sql
mysql> set global log_slow_extra=on;
Query OK, 0 rows affected (0.00 sec)
```

### 3.3.2 使用mysqldumpslow解释慢查询日志

MySQL慢速查询日志包含执行时间较长的查询信息，且包含的记录较多时，看起来比较困难。可以使用mysqldumpslow解析MySQL慢速查询日志文件，并总结日志内容。

**一、摘要分析**

mysqldumpslow会对查询进行摘要分析，8.0版本新添的两个分析摘要函数如下：

1. statement_digest_text()：返回摘要文本；
2. statement_digest()：返回摘要hashvalue。

用法如下：

```sql
mysql> select statement_digest_text("select user(),host from mysql.user where user = 'lu9up'");
+----------------------------------------------------------------------------------+
| statement_digest_text("select user(),host from mysql.user where user = 'lu9up'") |
+----------------------------------------------------------------------------------+
| SELECT SYSTEM_USER ( ) , HOST FROM `mysql` . `user` WHERE SYSTEM_USER = ?        |
+----------------------------------------------------------------------------------+
1 row in set (0.00 sec)

mysql> select statement_digest("select user(),host from mysql.user where user = 'lu9up'");
+-----------------------------------------------------------------------------+
| statement_digest("select user(),host from mysql.user where user = 'lu9up'") |
+-----------------------------------------------------------------------------+
| 12984e6ff7cbdbd28e2a377375af873fcd606891f82c670a74c04db83f7ac09c            |
+-----------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

**二、mysqldumpslow操作**

调用语法：

```bash
mysqldumpslow [options] [log_file ...]
```

options：

![Alt text](image-1.png)

`-s`指定排序方式，默认是at，根据平均时间排序，共有七种排序方式：

![Alt text](image-2.png)

**mysqldumpslow操作示例**：

使用mysqldumpslow对慢查询日志文件进行分析，输出平均执行时间最久的两条查询：

```bash
[mysql@mysql001 ~]$ mysqldumpslow -s at -t 2 /disk1/data/mysql001-slow.log

Reading mysql slow query log from /disk1/data/mysql001-slow.log
Count: 1  Time=0.01s (0s)  Lock=0.00s (0s)  Rows=0.0 (0), root[root]@localhost
  select f.title, count(*) as cnt
  from sakila.rental r
  join sakila.inventory i
  on r.inventory_id = i.inventory_id
  join sakila.film f
  on i.film_id = f.film_id
  where r.rental_date between 'S' and 'S'
  group by f.film_id
  order by cnt desc
  limit N

Count: 8  Time=0.00s (0s)  Lock=0.00s (0s)  Rows=4.9 (39), root[root]@localhost
  show variables like 'S'

```

### 3.3.3 使用pt-query-digest解析慢查询日志

pt-query-digest是Percona Toolkit的一个工具，用于分析MySQL的慢查询日志文件、通用查询日志文件和二进制日志文件中的查询，也可以分析SHOW PROCESSLIST命令输出的结果和tcpdump抓取的MySQL协议数据（如：网络流量包）。默认情况下，对所有分析的查询按摘要分组，分析结果按查询时间降序输出。

官方参考文档：https://docs.percona.com/percona-toolkit/pt-query-digest.html

#### 3.3.3.1 安装pt-query-digest

**一、下载Percona Toolkit：**

```bash
[mysql@mysql001 ~]$ wget percona.com/get/pt-query-digest
```

**二、赋权**

```bash
[mysql@mysql001 ~]$ chmod +775 pt-query-digest
```

完成赋权后就可以正常使用了。

#### 3.3.3.2 语法和选项

语法：

```bash
pt-query-digest [OPTIONS] [FILES] [DSN]
```

选项：

| optition name | comment |
| - | - |
| --ask-pass | 连接MySQL时提示输入密码。 |
| --continue-on-error | 即使出现错误，也要继续解析，默认值时yes。该工具不会永远继续:一旦任何进程导致100个错误，它就会停止。 |
| --create-review-table | 使用--review选项将分析结果输出到表中时，如果表不存在，创建它，默认值是yes。 |
| --create-history-table | 使用--history选项将分析结果输出到表中时，如果表不存在，创建它，默认值是yes。 |
| --defaults-file | 指定mysql的参数文件名，必须给出一个绝对路径名。 |
| --explain | 使用此DSN对示例查询运行EXPLAIN并打印结果。 |
| --filter | 该选项是一个Perl代码字符串或包含Perl代码的文件，使用此参数对要分析的文件进行过滤后再分析，将不符合Perl代码的时间全部忽略。 |
|  --review | 保存分析结果到表中，有重复的查询在表中时，不会再记录。只保存分析过的sql语句，不包含分析结果。 |
| --history | 保存分析结果到表中，有重复的查询在表中时，也会记录，但时间不一样。与review不同，不仅保存分析的sql语句，也包含分析结果。 |
| --limit | 将输出限制为给定的百分比或SQL语句数量。 |
|  --max-line-length | 把输出行的长度修剪到这个长度，0表示不裁剪。 |
|  --order-by | 按此属性和聚合函数对事件进行排序，默认为Query_time:sum。 |
|  --output | 指定分析结果的输出格式。 |
|  --since | 指定分析从什么时间开始的sql语句。 |
|  --until | 指定分析的sql语句的截至时间。 |
|  --type | 指定日志文件的类型，可以是genlog、binlog、slowlog、tcpdump、rawlog等。 |

选项的具体使用细则参考官方文档：https://docs.percona.com/percona-toolkit/pt-query-digest.html#options


#### 3.3.3.3 用法示例

1）直接分析慢查询文件

```bash
[mysql@mysql001 output]$ pt-query-digest /disk1/data/mysql001-slow.log > slow`date +"%Y%m%d"`.log
[mysql@mysql001 output]$ ll
total 20
-rw-rw-r-- 1 mysql mysql 17819 Dec 20 22:51 slow20231220.log
```

2）分析网络流量包

从3306端口抓取1000个流量包输出到文件mysql.tcp.txt：

```bash
tcpdump -s 65535 -x -nn -q -tttt -i any -c 1000 port 3306 > mysql.tcp.txt
```

分析抓取的网路流量包：

```bash
pt-query-digest --type tcpdump mysql.tcp.txt> slow_report9.log
```

3）分析pocesslist的输出

```bash
pt-query-digest --processlist h = host1
```

4）保存分析过的sql语句到表中

```bash
pt-query-digest --review h=192.168.131.99 --no-report mysql001-slow.log
```

默认保存的表是percona_schema.query_review。


5）保存分析结果到表中

```bash
pt-query-digest --history h=192.168.131.99 --no-report mysql001-slow.log
```

默认保存的表是percona_schema.query_history。


## 3.4 二进制日志

### 3.4.1 概述

记录数据库的变更（DDL, DML, DCL）。记录的单位是事件，一个会话可以包含多个事件。在MySQl8.0版本开始，默认是开启二进制日志的。

二进制日志文件十分重要，有以下两个用途：

- **复制**：主从复制，将主服务器的二进制日志发送到从服务器上，并将这些事件应用到从服务器上，实现主从服务器数据同步。
- **数据恢复**：在恢复全量备份后，在应用二进制日志中的事件使数据库前滚，是增量恢复或时间点恢复。

二进制日志文件的三种格式：

- **语句模式（STATEMENT）**：记录每条执行数据修改的sql语句，产生的日志文件较小。记录的非确定语句（now(),uuid()函数）在复制或恢复时有可能会出错。
- **行模式（ROW）**：默认模式，不记录sql语句，仅记录被修改的记录及其被如何修改的信息，日志文件可能会比较大。能避免语句模式记录的非确定语句（now(),uuid()函数）带来的不确定性错误。
- **混合模式（MIXED）**：默认采用语句模式，遇到非确定sql语句时采用行模式。

```sql
mysql> show variables like 'binlog_format';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| binlog_format | ROW   |
+---------------+-------+
1 row in set (0.00 sec)
```

### 3.4.2 系统参数

**一、log_bin**

```bash
[mysql@mysql001 data]$ sudo vim /etc/my.cnf
添加：
log_bin=/disk1/data/binlog/binlog

mysql> show variables like '%log_bin%';
+---------------------------------+---------------------------------+
| Variable_name                   | Value                           |
+---------------------------------+---------------------------------+
| log_bin                         | ON                              |
| log_bin_basename                | /disk1/data/binlog/binlog       |
| log_bin_index                   | /disk1/data/binlog/binlog.index |
| log_bin_trust_function_creators | OFF                             |
| log_bin_use_v1_row_events       | OFF                             |
| sql_log_bin                     | ON                              |
+---------------------------------+---------------------------------+
6 rows in set (0.00 sec)
```

查看binlog：

```sql
mysql> purge binary logs to 'binlog.000040';
Query OK, 0 rows affected (0.01 sec)

mysql> show binary logs;
+---------------+-----------+-----------+
| Log_name      | File_size | Encrypted |
+---------------+-----------+-----------+
| binlog.000040 |         0 | No        |
| binlog.000041 |         0 | No        |
| binlog.000042 |       157 | No        |
+---------------+-----------+-----------+
3 rows in set (0.00 sec)
```

# 4 安全

# 5 information_schema数据库

查看所有数据库容量大小:

```sql
select table_schema,count(*) tables,
	   sum(table_rows) as table_rows,
	   concat(sum(round(data_length/1024/1024, 2)),'m') as data,
	   concat(sum(round(index_length/1024/1024, 2)),'m') as idx,
	   concat(sum(round((data_length+index_length)/1024/1024, 2)),'m') as  total
  from information_schema.tables
 group by table_schema
 order by sum(data_length) desc, sum(index_length) desc;

+--------------------+--------+------------+-------+-------+-------+
| TABLE_SCHEMA       | tables | table_rows | data  | idx   | total |
+--------------------+--------+------------+-------+-------+-------+
| sakila             |     23 |      48099 | 4.20m | 2.31m | 6.49m |
| mysql              |     38 |       4276 | 2.47m | 0.36m | 2.75m |
| sys                |    101 |          6 | 0.02m | 0.00m | 0.02m |
| information_schema |     79 |          0 | 0.00m | 0.00m | 0.00m |
| performance_schema |    111 |    2962186 | 0.00m | 0.00m | 0.00m |
+--------------------+--------+------------+-------+-------+-------+
5 rows in set (0.01 sec)
```

查看某数据库下最大的十个表：

```sql
select table_schema,table_name,table_rows,
       concat(round(data_length/1024/1024, 2),'m') data_length,
       concat(round(index_length/1024/1024, 2),'m') index_length,
       concat(round((data_length+index_length)/1024/1024,2),'m') total
  from information_schema.tables
 where table_schema = 'sakila'
 order by (data_length+index_length) desc
 limit 10;
+--------------+---------------+------------+-------------+--------------+-------+
| TABLE_SCHEMA | TABLE_NAME    | TABLE_ROWS | data_length | index_length | total |
+--------------+---------------+------------+-------------+--------------+-------+
| sakila       | rental        |      16419 | 1.52m       | 1.14m        | 2.66m |
| sakila       | payment       |      16500 | 1.52m       | 0.61m        | 2.13m |
| sakila       | inventory     |       4581 | 0.17m       | 0.19m        | 0.36m |
| sakila       | film          |       1000 | 0.19m       | 0.08m        | 0.27m |
| sakila       | film_actor    |       5462 | 0.19m       | 0.08m        | 0.27m |
| sakila       | film_text     |       1000 | 0.17m       | 0.02m        | 0.19m |
| sakila       | customer      |        599 | 0.08m       | 0.05m        | 0.13m |
| sakila       | address       |        603 | 0.09m       | 0.02m        | 0.11m |
| sakila       | staff         |          2 | 0.06m       | 0.03m        | 0.09m |
| sakila       | film_category |       1000 | 0.06m       | 0.02m        | 0.08m |
+--------------+---------------+------------+-------------+--------------+-------+
10 rows in set (0.01 sec)
```

查看非InnoDB引擎的业务表：

```sql
select table_name,table_schema,engine 
  from information_schema.tables
 where engine!='innodb' 
   and table_schema not in('mysql','information_schema','performance_schema'); 
```

查看没有主键或唯一索引的表：

```sql
select t.table_schema,
       t.table_name
  from information_schema.tables t
 inner join information_schema.columns c 
	on t.table_schema = c.table_schema
   and t.table_name = c.table_name
 where t.table_schema not in('mysql','information_schema','performance_schema')
   and c.table_type = 'base table'
group by t.table_schema,t.table_name
having group_concat(colums_key) not regexp 'pri|uni';
```

# 6 performance_schema数据库

## 6.7 用例

### 6.7.1 监控sql语句的执行性能



```sql
select thread_id,event_name,source,sys.format_time(timer_wait),sys.format_time(lock_time),
	   sql_text,current_schema,message_text,rows_affected,rows_sent,rows_examined
  from performance_schema.events_statements_history
 where current_schema != 'performance_schema'
 order by timer_wait desc limit 3\G
 ```

# 7 mysql数据库

# 8 逻辑备份

## 8.1 逻辑备份和物理备份的区别

## 8.2 mysqldump

### 8.2.1 语法

### 8.2.2 options

### 8.2.3 常见用法

其中：

–single-transaction 参数会添加下面额外执行：
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ
START TRANSACTION /*!40100 WITH CONSISTENT SNAPSHOT */

–master-data=2和–flush-logs都会添加下面额外操作，注意锁表：
FLUSH /*!40101 LOCAL */ TABLES
FLUSH TABLES WITH READ LOCK

**一、全库备份**

```bash
mysqldump -uroot -p --all-databases --hex-blob --single-transaction --set-gtid-purged=OFF --master-data=2 --flush-logs --routines --triggers --events --extended-insert=TRUE --net-buffer-length=16777216 --max-allowed-packet=67108864 > /disk1/bak/mysqldump/full/mysql_full.sql
```

**二、备份指定库**

```bash
mysqldump -uroot -p test --hex-blob --single-transaction --set-gtid-purged=OFF --master-data=2 --flush-logs --routines --triggers --events --extended-insert=TRUE --net-buffer-length=16777216 --max-allowed-packet=67108864 > /disk1/bak/mysqldump/db/test.sql
```

**三、备份指定表**

```bash
mysqldump -uroot -p test t1 t2 –hex-blob --single-transaction --set-gtid-purged=OFF --master-data=2 --flush-logs --extended-insert=TRUE --net-buffer-length=16777216 --max-allowed-packet=67108864 > /disk1/bak/mysqldump/tab/test_t1_t2.sql
```

只备份表结构：

```bash
mysqldump -uroot -p test t3 –-no-data –hex-blob --single-transaction --set-gtid-purged=OFF --master-data=2 --flush-logs --extended-insert=TRUE --net-buffer-length=16777216 --max-allowed-packet=67108864 > /disk1/bak/mysqldump/tab/test_t3.sql
```

只备份表数据：

```bash
mysqldump -uroot -p test t3 –no-create-info –hex-blob --single-transaction --set-gtid-purged=OFF --master-data=2 --flush-logs --extended-insert=TRUE --net-buffer-length=16777216 --max-allowed-packet=67108864 >  /disk1/bak/mysqldump/tab/test_t3.sql
```

**四、压缩备份**

```bash
mysqldump -uroot -p –all-databases --hex-blob --single-transaction --set-gtid-purged=OFF --master-data=2 --flush-logs --routines --triggers --events --extended-insert=TRUE --net-buffer-length=16777216 --max-allowed-packet=67108864 | gzip > /disk1/bak/mysqldump/full/mysql_full.sql
```

通过管道符的方式使用gzip进行压缩。

**五、忽略指定表**

```bash
mysqldump -uroot -p --databases test --ignore-table=test.t1 --hex-blob --single-transaction --set-gtid-purged=OFF --master-data=2 --flush-logs --routines --triggers --events --extended-insert=TRUE --net-buffer-length=16777216 --max-allowed-packet=67108864 > /disk1/bak/mysqldump/db/test.sql
```

### 8.2.4 恢复

**一、以SQL格式备份**

```sql
[mysql@mysql001 bak]$ mysql sakila < sakila_actor.bak20240101.sql
```

**二、带分隔符文本备份**

```sql
[mysql@mysql001 mysql-files]$ cd /var/lib/mysql-files/
[mysql@mysql001 mysql-files]$ mysql sakila < actor.sql
[mysql@mysql001 mysql-files]$ mysqlimport sakila /var/lib/mysql-files/actor.txt
```


## 8.3 mysqlpump

### 8.3.1 并行备份

```sql
[mysql@mysql001 ~]$ mysqlpump --parallel-schemas=4:sakila > /disk1/bak/sakila1.bak20230101.sql
```

### 8.3.3 过滤选项

### 8.3.4 备份用户

```sql
[mysql@mysql001 ~]$ mysqlpump --exclude-databases=% --users > /disk1/bak/users.bak20230101.sql
[mysql@mysql001 ~]$ mysqlpump --exclude-databases=% --include-users=lu9up --users > /disk1/bak/lu9up.bak20230101.sql
[mysql@mysql001 ~]$ mysqlpump --exclude-databases=% --exclude-users=root --users > /disk1/bak/users_exclud_root.bak20230101.sql
```

## 8.4 mydumper

https://github.com/mydumper/mydumper

- Parallelism (hence, speed) and performance (avoids expensive character set conversion routines, efficient code overall)
- Easier to manage output (separate files for tables, dump metadata, etc, easy to view/parse data)
- Consistency - maintains snapshot across all threads, provides accurate master and slave log positions, etc
- Manageability - supports PCRE for specifying database and tables inclusions and exclusions

### 8.4.1 安装

**一、安装mydumper**

```bash
[mysql@mysql001 mydumper]$ release=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/mydumper/mydumper/releases/latest | cut -d'/' -f8)
[mysql@mysql001 mydumper]$ sudo yum install -y https://github.com/mydumper/mydumper/releases/download/${release}/mydumper-${release:1}.el7.x86_64.rpm
```

MyDumper is a MySQL Logical Backup Tool. It has 2 tools:

- mydumper which is responsible to export a consistent backup of MySQL databases
- myloader reads the backup from mydumper, connects the to destination database and imports the backup.

**二、安装依赖软件**

```bash
[mysql@mysql001 mydumper]$ sudo yum install -y cmake gcc gcc-c++ git make
[mysql@mysql001 mydumper]$ sudo yum install -y glib2-devel openssl-devel pcre-devel zlib-devel libzstd-devel
```

### 8.4.2 使用

**备份：**

```sql
[mysql@mysql001 sakila]$ mydumper -u root -p Mysql123. -P 3306 -h localhost -B sakila -o /disk1/bak/sakila/
[mysql@mysql001 sakila]$ ls
metadata                              sakila.film.00000.sql                              sakila.payment-schema.sql
sakila.actor.00000.sql                sakila.film_actor.00000.sql                        sakila.rental.00000.sql
sakila.actor_info-schema.sql          sakila.film_actor-schema.sql                       sakila.rental-schema.sql
sakila.actor_info-schema-view.sql     sakila.film_category.00000.sql                     sakila.sales_by_film_category-schema.sql
sakila.actor-schema.sql               sakila.film_category-schema.sql                    sakila.sales_by_film_category-schema-view.sql
sakila.address.00000.sql              sakila.film_list-schema.sql                        sakila.sales_by_store-schema.sql
sakila.address-schema.sql             sakila.film_list-schema-view.sql                   sakila.sales_by_store-schema-view.sql
sakila.category.00000.sql             sakila.film-schema.sql                             sakila-schema-create.sql
sakila.category-schema.sql            sakila.film_text.00000.sql                         sakila-schema-triggers.sql
sakila.city.00000.sql                 sakila.film_text-schema.sql                        sakila.staff.00000.sql
sakila.city-schema.sql                sakila.inventory.00000.sql                         sakila.staff_list-schema.sql
sakila.country.00000.sql              sakila.inventory-schema.sql                        sakila.staff_list-schema-view.sql
sakila.country-schema.sql             sakila.language.00000.sql                          sakila.staff-schema.sql
sakila.customer.00000.sql             sakila.language-schema.sql                         sakila.store.00000.sql
sakila.customer_list-schema.sql       sakila.nicer_but_slower_film_list-schema.sql       sakila.store-schema.sql
sakila.customer_list-schema-view.sql  sakila.nicer_but_slower_film_list-schema-view.sql
sakila.customer-schema.sql            sakila.payment.00000.sql
```

**恢复**

```sql
[mysql@mysql001 sakila]$ myloader -u root -p Mysql123. -P 3306 -h localhost  -B sakila -d /disk1/bak/sakila/
```

### 8.4.3 并行和一致性

```sql
[mysql@mysql001 ls_sakila]$ mydumper -u root -p Mysql123. -P 3306 -h localhost -B sakila -T sakila.actor -t 8 --rows=10000 --trx-consistency-only -o /disk1/bak/ls_sakila
[mysql@mysql001 ls_sakila]$ mydumper -u root -p Mysql123. -P 3306 -h localhost -B sakila -T sakila.actor -t 8 --chunk-filesize 4 --trx-consistency-only -o /disk1/bak/ls_sakila
```

### 8.4.4 How to exclude (or include) databases?

Once can use --regex functionality, for example not to dump mysql and test databases:

```sql
mydumper --regex '^(?!(mysql\.|test\.))'

```

To dump only mysql and test databases:

```sql
mydumper --regex '^(mysql\.|test\.)'
```
To not dump all databases starting with test:

```sql
mydumper --regex '^(?!(test))'
```

To dump specify tables in different databases (Note: The name of tables should end with $. related issue):

```sql
mydumper --regex '^(db1\.table1$|db2\.table2$)'
```

If you want to dump a couple of databases but discard some tables, you can do:

```sql
mydumper --regex '^(?=(?:(db1\.|db2\.)))(?!(?:(db1\.table1$|db2\.table2$)))'
```

Which will dump all the tables in db1 and db2 but it will exclude db1.table1 and db2.table2
Of course, regex functionality can be used to describe pretty much any list of tables.

# 9 Percona XtraBackup

## 9.1 Percona XtraBackup介绍

Percona XtraBackup是一个开源的MySQL热备份实用工具，用于执行MySQL的InnoDB和XtraDB数据库的非阻塞备份。

无论是24x7高负载服务器还是低事务量环境，Percona XtraBackup都能高效地进行热备份，而不会影响业务可用性和占用过多的数据库资源以及服务器性能。

Percona XtraBackup有以下优势：

- 免费和开源；
- 备份效率高，十分安全可靠；
- 备份不会阻塞事务；
- 不会占用过多的磁盘空间和网络带宽（可压缩）；
- 自动备份验证；
- 恢复时间快
- 支持流、压缩和增量MySQL备份。

官方参考文档：[https://docs.percona.com/percona-xtrabackup/8.0/about-xtrabackup.html](https://docs.percona.com/percona-xtrabackup/8.0/about-xtrabackup.html)

## 9.2 安装Percona XtraBackup

**注意**：下载前先确认自己的服务器和数据库的版本信息，根据实际情况下载相应的版本。

手动下载地址：[https://www.percona.com/downloads](https://www.percona.com/downloads)

![image.png](https://oss-emcsprod-public.modb.pro/image/editor/20240104-d7a8dafe-3c39-4f64-bf37-4e3f16d7e6a2.png)

### 9.2.1 rpm包安装方式

**一、使用YUM下载方式，下载RPM包**：

```bash
[root@mysql001 xtrabackup]$ sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
```

**二、启用percona库**：

```bash
[mysql@mysql001 ~]$ sudo percona-release enable-only tools release
```

**三、依赖包下载**

```bash
[mysql@mysql001 ~]$ sudo yum install lz4 zstd
```

**三、安装**

```bash
[mysql@mysql001 ~]$ sudo yum install percona-xtrabackup-80
```

**四、检查**

```bash
[mysql@mysql001 ~]$ xtrabackup --version
xtrabackup: recognized server arguments: --datadir=/disk1/data --log_bin=/disk1/data/binlog/binlog --innodb_log_file_size=100M
xtrabackup version 8.0.22-15 based on MySQL server 8.0.22 Linux (x86_64) (revision id: fea8a0e)
```

**四、卸载**

如果版本不可用，需要卸载重装，卸载脚本如下：

```bash
[mysql@mysql001 ~]$ yum list | grep percona
[mysql@mysql001 ~]$ yum remove percona-xtrabackup-80.x86_64
```

### 9.2.2 tar包安装

tar包下载要选择的服务器版本是LINUX-GENERIC:

![image.png](https://oss-emcsprod-public.modb.pro/image/editor/20240105-b24cd07b-5bde-4524-b1c7-112adc89e895.png)

```bash
#解压：
[mysql@mysql001 xtrabackup]$ tar xvf percona-xtrabackup-8.0.34-29-Linux-x86_64.glibc2.17-minimal.tar.gz

#简化路径：
[mysql@mysql001 xtrabackup]$ mv percona-xtrabackup-8.0.34-29-Linux-x86_64.glibc2.17-minimal xtrabackup
[mysql@mysql001 xtrabackup]$ cd xtrabackup

#安装依赖包：
[mysql@mysql001 xtrabackup]$ sudo yum install -y perl-Digest-MD5 perl-DBD-MySQL libev

#bin目录，可执行文件
[mysql@mysql001 bin]$ cd /home/mysql/tools/xtrabackup/xtrabackup/bin/
[mysql@mysql001 bin]$ pwd
/home/mysql/tools/xtrabackup/xtrabackup/bin

#添加环境变量
[mysql@mysql001 bin]$ sudo vim /etc/profile
添加：
export XTRABACKUP_HOME=/home/mysql/tools/xtrabackup/xtrabackup
export PATH=$PATH:$HOME/bin:$XTRABACKUP_HOME/bin

#环境变量生效
[mysql@mysql001 bin]$ source /etc/profile

#检查，包含版本号、数据路径等信息
[mysql@mysql001 ~]$ xtrabackup --version
2024-01-04T01:31:22.623365+08:00 0 [Note] [MY-011825] [Xtrabackup] recognized server arguments: --datadir=/disk1/data --log_bin=/disk1/data/binlog/binlog --innodb_log_file_size=100M
xtrabackup version 8.0.34-29 based on MySQL server 8.0.34 Linux (x86_64) (revision id: 5ba706ee)
```

## 9.3 使用Percona XtraBackup

XtraBackup的备份恢复过程可以分为备份、准备（prepare）和恢复（restore）三个阶段。

在备份阶段，XtraBackup会复制InnoDB的数据文件，同时记录redo日志的变化。这个过程分为两个阶段，首先是备份redo日志文件，然后是复制InnoDB的数据文件。在备份数据文件时，XtraBackup会检测每个表空间中每个页的LSN（Log Sequence Number），如果LSN大于上次备份时的LSN，则备份该页。同时，XtraBackup还会记录当前检查点的LSN，以确保只备份自上次备份以来发生更改的数据页。

在准备阶段，XtraBackup的主要工作是通过回滚未提交的事务及同步已经提交的事务至数据文件来使数据文件达到一致性状态。这个过程类似于InnoDB的实例恢复。

在恢复阶段，XtraBackup会启动一个内嵌的InnoDB实例，然后回放xtrabackup日志（xtrabackup_log），将提交的事务信息变更应用到InnoDB数据/表空间，同时回滚未提交的事务。

### 9.3.1 备份

**全量备份**

```bash
[mysql@mysql001 full]$ xtrabackup --user=root --password=Mysql123. --backup --parallel=8 --target-dir=/disk1/bak/full

[mysql@mysql001 full]$ ls /disk1/bak/full/
backup-my.cnf  binlog.index    ibdata1  mysql.ibd           sakila  undo_001  xtrabackup_binlog_info  xtrabackup_info     xtrabackup_tablespaces
binlog.000045  ib_buffer_pool  mysql    performance_schema  sys     undo_002  xtrabackup_checkpoints  xtrabackup_logfile
```


**增量备份**

一、在上面"--target-dir=/disk1/bak/full"全量备份的基础上进行增量备份：

```bash
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --backup --parallel=8 --target-dir=/disk1/bak/inc --incremental-basedir=/disk1/bak/full

[mysql@mysql001 inc]$ ls /disk1/bak/inc/
backup-my.cnf  ib_buffer_pool  mysql            performance_schema  undo_001.delta  undo_002.meta           xtrabackup_info
binlog.000046  ibdata1.delta   mysql.ibd.delta  sakila              undo_001.meta   xtrabackup_binlog_info  xtrabackup_logfile
binlog.index   ibdata1.meta    mysql.ibd.meta   sys                 undo_002.delta  xtrabackup_checkpoints  xtrabackup_tablespaces
```

以delta结尾的文件，是记录原文件变化的数据。

二、在上面"--target-dir=/disk1/bak/inc --incremental-basedir=/disk1/bak/full"增量备份的基础上再进行增量备份：

```bash
[mysql@mysql001 inc1]$ xtrabackup --user=root --password=Mysql123. --backup --parallel=8 --target-dir=/disk1/bak/inc1 --incremental-basedir=/disk1/bak/inc

[mysql@mysql001 inc1]$ ls /disk1/bak/inc1
backup-my.cnf  ib_buffer_pool  mysql            performance_schema  test            undo_002.delta          xtrabackup_checkpoints  xtrabackup_tablespaces
binlog.000047  ibdata1.delta   mysql.ibd.delta  sakila              undo_001.delta  undo_002.meta           xtrabackup_info
binlog.index   ibdata1.meta    mysql.ibd.meta   sys                 undo_001.meta   xtrabackup_binlog_info  xtrabackup_logfile
```

**压缩备份**

```bash
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --backup --compress --compress-threads=4 --target-dir=/disk1/bak/compressed
```

**部分备份**

可以单独备份表或数据库。

如果只备份sakila数据库中的表，使用如下命令:

```bash
#备份sakila所有的表
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --backup --datadir=/disk1/data/ --target-dir=/disk1/bak/part/tab --tables="^sakila[.].*"

#只备份sakila的actor表
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --backup --datadir=/disk1/data/ --target-dir=/disk1/bak/part/tab --tables="^sakila[.]actor"
```

只备份某些个数据库：

```bash
#备份sakila performance_schema information_schema sys mysql
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --backup --target-dir=/disk1/bak/part/db --databases='sakila performance_schema information_schema sys mysql'
```

### 9.3.2 准备

**准备全量备份**

在全量备份的准备中，为了使数据库保持一致性，将进行以下操作：
- 根据数据文件从日志文件重放已提交的事务；
- 回滚未提交的事务。

```bash
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --prepare --target-dir=/disk1/bak/full
```

**准备增量备份**

准备增量备份和准备全量备份不一样，不会执行如全量备份操作时回滚未提交的事务，因为在增量备份时未提交的事务可能正在进行中，它们很可能会在下一个增量备份中提交了。

所以在准备增量备份时，必须跳过未提交事务的回滚，使用 --apply-log-only 选项来阻止回滚操作。

应用全量备份的第一个增量备份准备：

```bash
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --prepare --apply-log-only --target-dir=/disk1/bak/full

[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --prepare --apply-log-only --target-dir=/disk1/bak/full --incremental-dir=/disk1/bak/inc
```

原理是，将增量文件应用于/disk1/bak/full中的文件，令它们向前滚到增量备份的时间，对结果应用重做日志。最终数据在/data/backups/base目录下，而不是增量目录下。



同理，应用全量备份的第二个增量备份准备：

```bash
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --prepare --parallel=8 --apply-log-only --target-dir=/disk1/bak/full --incremental-dir=/disk1/bak/inc1
```

第三个。。。

在做最后一个增量备份准备时，不需要再使用 --apply-log-only，因为此时需要将未提交的事务回滚。

**注意**：如果不使用 --apply-log-only 选项执行准备，那么增量备份将是无用的，不能使用此备份进行恢复。


**准备压缩备份**

```bash
#decompress
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --decompress --target-dir=/disk1/bak/compressed

#prepare
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --prepare --target-dir=/data/compressed/
```

**准备部分备份**

```bash
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --prepare --export --target-dir=/disk1/bak/part/db
```

### 9.3.3 恢复

要执行恢复备份，必须满足以下条件：

1. 备份集要完成**准备**。
2. 数据目录**datadir必须为空**。
3. 不能恢复到正在运行的mysqld实例的数据目录(除非导入部分备份)，在执行恢复之前需要**关闭MySQL服务器**。

完成以上步骤后，就可以对全量备份、增量备份和压缩备份进行恢复：

```bash
[mysql@mysql001 disk1]$ sudo systemctl stop mysqld
[mysql@mysql001 disk1]$ systemctl status mysqld
[mysql@mysql001 bak]$ xtrabackup --user=root --password=Mysql123. --copy-back --target-dir=/disk1/bak/full
```

### 9.3.4 报错处理

报错信息如下：

```bash
[ERROR] [MY-011825] [Xtrabackup] Failed to connect to MySQL server: Can't connect to local MySQL server through socket
```

原因是在localhost连接Mysql服务时，会优先使用sock文件进行连接，而不是使用IP端口进行连接。

所以当可执行文件xtrabackup尝试使用sock文件进行连接时，无法获取sock文件的位置。

解决办法是给XtraBackup命令指定socket路径：

```bash
#添加
[mysql@mysql001 ~]$ sudo vim /etc/my.cnf
添加：
[xtrabackup]
socket=/var/lib/mysql/mysql.sock

添加的这个路径和[mysqld]中的保持一致。

#重启
[mysql@mysql001 ~]$ sudo systemctl restart mysqld
```

# 10 数据救援

# 11 MySQL Shell

# 12 复制

## 12.1 复制搭建

**一、配置文件**

```sql
#主库
server_id=1
log_bin=/disk1/data/binlog/binlog

# 从库
server_id=2
```

**二、主库创建复制用户**

```sql
mysql> create user 'repl'@'192.168.131.100' identified by 'Repl123.';
mysql> grant replication slave on *.* to 'repl'@'192.168.131.100';
```

**三、获取主库全量备份**

```sql
[mysql@mysql001 full]$ mysqldump -uroot -pMysql123. --all-databases --single-transaction --master-data=2 --events --triggers --routines > full_backup.sql
#发送到从库，mysql8.0.26版本后建议将--master-data换为--source-data
[mysql@mysql001 full]$ scp full_backup.sql 192.168.131.100:/disk1/bak/full
```

**四、基于主库备份恢复从库**

```sql
[mysql@mysql002 full]$ mysql -uroot -pMysql123. < /disk1/bak/full/full_backup.sql
```

**五、建立主从复制（从库执行）**

查找binlog位置点信息：

```sql
[mysql@mysql002 full]$ grep -m1 "CHANGE MASTER TO" full_backup.sql
-- CHANGE MASTER TO MASTER_LOG_FILE='binlog.000058', MASTER_LOG_POS=680;

#5.2 执行CHANGE MASTER TO命令，get_master_public_key配置项只需要在MySQL8.0以后的版本添加
mysql> change master to 
              master_host='192.168.131.99',
              master_user='repl',
              master_password='Repl123.',
              master_log_file='binlog.000058',
              master_log_pos=680,
              get_master_public_key=1;
```

查看表mysql.slave_master_info：

```sql
mysql> select * from mysql.slave_master_info\G
*************************** 1. row ***************************
                Number_of_lines: 33
                Master_log_name: binlog.000058
                 Master_log_pos: 680
                           Host: 192.168.131.99
                      User_name: repl
                  User_password: Repl123.
                           Port: 3306
                  Connect_retry: 60
                    Enabled_ssl: 0
                         Ssl_ca:
                     Ssl_capath:
                       Ssl_cert:
                     Ssl_cipher:
                        Ssl_key:
         Ssl_verify_server_cert: 0
                      Heartbeat: 30
                           Bind:
             Ignored_server_ids: 0
                           Uuid: bd4b724b-ab29-11ee-826f-000c294bd026
                    Retry_count: 86400
                        Ssl_crl:
                    Ssl_crlpath:
          Enabled_auto_position: 0
                   Channel_name:
                    Tls_version:
                Public_key_path:
                 Get_public_key: 1
              Network_namespace:
   Master_compression_algorithm: uncompressed
  Master_zstd_compression_level: 3
               Tls_ciphersuites: NULL
Source_connection_auto_failover: 0
                      Gtid_only: 0
```

查看表mysql.slave_relay_log_info：

```sql
mysql> select * from mysql.slave_relay_log_info\G
*************************** 1. row ***************************
                             Number_of_lines: 14
                              Relay_log_name: ./mysql002-relay-bin.000002
                               Relay_log_pos: 201
                             Master_log_name: binlog.000058
                              Master_log_pos: 680
                                   Sql_delay: 0
                           Number_of_workers: 4
                                          Id: 1
                                Channel_name:
                   Privilege_checks_username: NULL
                   Privilege_checks_hostname: NULL
                          Require_row_format: 0
             Require_table_primary_key_check: STREAM
 Assign_gtids_to_anonymous_transactions_type: OFF
Assign_gtids_to_anonymous_transactions_value:
```

**六、开启主从复制，从库上执行**

```sql
mysql> start slave;
```

关闭是 stop slave

**七、查看复制状态**

从库执行：

```sql
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: 192.168.131.99
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: binlog.000059
          Read_Master_Log_Pos: 157
               Relay_Log_File: mysql002-relay-bin.000002
                Relay_Log_Pos: 367
        Relay_Master_Log_File: binlog.000059
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 157
              Relay_Log_Space: 580
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 1
                  Master_UUID: bd4b724b-ab29-11ee-826f-000c294bd026
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set:
                Auto_Position: 1
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:
       Master_public_key_path:
        Get_master_public_key: 1
            Network_Namespace:
```

主库执行：

```sql
mysql> show processlist\G
*************************** 3. row ***************************
     Id: 29
   User: system user
   Host: connecting host
     db: NULL
Command: Connect
   Time: 663
  State: Waiting for source to send event
   Info: NULL
*************************** 4. row ***************************
     Id: 30
   User: system user
   Host:
     db: NULL
Command: Query
   Time: 663
  State: Replica has read all relay log; waiting for more updates
   Info: NULL

#主库执行
mysql> show processlist\G
*************************** 2. row ***************************
     Id: 15
   User: repl
   Host: mysql002:19268
     db: NULL
Command: Binlog Dump
   Time: 486
  State: Source has sent all binlog to replica; waiting for more updates
   Info: NULL
```

## 12.2 GTID复制

### 12.2.1 GTID搭建

**一、参数配置**

在传统复制上，主从节点都需要加入以下参数

```bash
gtid_mode=on
enforce_gtid_consistency=on
#在MySQL5.6中，还需要添加
log_bin=/disk1/data/binlog/binlog
log_slave_updates=1
```

**二、change master to命令**

不用指定master_log_file和master_log_pos，只需要添加master_auto_position=1

```sql
change replication source to 
	   master_host='192.168.131.99',
	   master_user='repl',
	   master_password='Repl123.',
	   master_auto_position=1;
```

### 12.2.2 GTID原理

## 12.3 半同步复制

### 12.3.1事务的两阶段提交协议

### 12.3.2 半同步复制原理

### 12.3.3 半同步复制的安装

**一、安装插件**

主库：

```sql
mysql> install plugin rpl_semi_sync_master soname 'semisync_master.so';
```

从库：

```sql
mysql> install plugin rpl_semi_sync_slave soname 'semisync_slave.so';;
```

**二、启动**

主库：

```sql
mysql> set global rpl_semi_sync_master_enabled=1;
```

从库：

```sql
mysql> set global rpl_semi_sync_slave_enabled=1;
```

或者：

在配置文件添加，重启后自动开启：

```bash
plugin_load="rpl_semi_sync_master=semisync_master.so;rpl_semi_sync_slave=semisync_slave.so"
rpl_semi_sync_master_enabled=1
rpl_semi_sync_slave_enabled=1
```

**三、重启从库的I/O线程**

从库执行：

```sql
mysql> stop slave io_thread;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> start slave io_thread;
Query OK, 0 rows affected, 1 warning (0.01 sec)

mysql> show status like 'Rpl_semi_sync_slave_status';
+----------------------------+-------+
| Variable_name              | Value |
+----------------------------+-------+
| Rpl_semi_sync_slave_status | ON    |
+----------------------------+-------+
1 row in set (0.00 sec)
```

主库执行：

```sql
mysql> show status like 'Rpl_semi_sync_master_status';
+-----------------------------+-------+
| Variable_name               | Value |
+-----------------------------+-------+
| Rpl_semi_sync_master_status | ON    |
+-----------------------------+-------+
1 row in set (0.00 sec)
```

## 12.4 并行复制

从库：

```bash
slave_parallel_type=logical_clock
slave_parallel_workers=16
slave_preserve_commit_order=on
```

从库重启后生效，此时是lock_based方案的并行复制模式。

如果想开启writeset模式，在mysql5.7.22和mysql8.0开始，可在主库配置以下参数：

```bash
binlog_transaction_dependency_tracking=writeset_session
binlog_transaction_dependency_history_size=25000
transaction_write_set_extraction=xxhash64
binlog_format=row
```

问题：

1. 在从库恢复的表，导入主库时，从库表已经存在，对从库有什么影响？对复制有什么影响？
2. 恢复主库时，需要关闭复制吗？
3. 如何导入主库？
4. 将从库恢复到主库前，如何将从库更新到主库最新状态？


# 13 复制管理

## 13.1 常见操作

### 13.1.1 查看主库状态

```sql
mysql> show master status\G
```

### 13.1.2查看从库状态

```sql
mysql> show slave status\G
```

### 13.1.3 搭建复制

```sql
CHANGE MASTER TO option [, option] ... [ channel_option ]

option: {
    MASTER_BIND = 'interface_name'
  | MASTER_HOST = 'host_name'
  | MASTER_USER = 'user_name'
  | MASTER_PASSWORD = 'password'
  | MASTER_PORT = port_num
  | PRIVILEGE_CHECKS_USER = {'account' | NULL}
  | REQUIRE_ROW_FORMAT = {0|1}
  | REQUIRE_TABLE_PRIMARY_KEY_CHECK = {STREAM | ON | OFF}
  | ASSIGN_GTIDS_TO_ANONYMOUS_TRANSACTIONS = {OFF | LOCAL | uuid}
  | MASTER_LOG_FILE = 'source_log_name'
  | MASTER_LOG_POS = source_log_pos
  | MASTER_AUTO_POSITION = {0|1}
  | RELAY_LOG_FILE = 'relay_log_name'
  | RELAY_LOG_POS = relay_log_pos
  | MASTER_HEARTBEAT_PERIOD = interval
  | MASTER_CONNECT_RETRY = interval
  | MASTER_RETRY_COUNT = count
  | SOURCE_CONNECTION_AUTO_FAILOVER = {0|1}
  | MASTER_DELAY = interval
  | MASTER_COMPRESSION_ALGORITHMS = 'algorithm[,algorithm][,algorithm]'
  | MASTER_ZSTD_COMPRESSION_LEVEL = level
  | MASTER_SSL = {0|1}
  | MASTER_SSL_CA = 'ca_file_name'
  | MASTER_SSL_CAPATH = 'ca_directory_name'
  | MASTER_SSL_CERT = 'cert_file_name'
  | MASTER_SSL_CRL = 'crl_file_name'
  | MASTER_SSL_CRLPATH = 'crl_directory_name'
  | MASTER_SSL_KEY = 'key_file_name'
  | MASTER_SSL_CIPHER = 'cipher_list'
  | MASTER_SSL_VERIFY_SERVER_CERT = {0|1}
  | MASTER_TLS_VERSION = 'protocol_list'
  | MASTER_TLS_CIPHERSUITES = 'ciphersuite_list'
  | MASTER_PUBLIC_KEY_PATH = 'key_file_name'
  | GET_MASTER_PUBLIC_KEY = {0|1}
  | NETWORK_NAMESPACE = 'namespace'
  | IGNORE_SERVER_IDS = (server_id_list),
  | GTID_ONLY = {0|1}
}

channel_option:
    FOR CHANNEL channel

server_id_list:
    [server_id [, server_id] ... ]
```

### 13.1.4 开启复制

```sql
START REPLICA [thread_types] [until_option] [connection_options] [channel_option]

thread_types:
    [thread_type [, thread_type] ... ]

thread_type:
    IO_THREAD | SQL_THREAD

until_option:
    UNTIL {   {SQL_BEFORE_GTIDS | SQL_AFTER_GTIDS} = gtid_set
          |   MASTER_LOG_FILE = 'log_name', MASTER_LOG_POS = log_pos
          |   SOURCE_LOG_FILE = 'log_name', SOURCE_LOG_POS = log_pos
          |   RELAY_LOG_FILE = 'log_name', RELAY_LOG_POS = log_pos
          |   SQL_AFTER_MTS_GAPS  }

connection_options:
    [USER='user_name'] [PASSWORD='user_pass'] [DEFAULT_AUTH='plugin_name'] [PLUGIN_DIR='plugin_dir']


channel_option:
    FOR CHANNEL channel
```

### 13.1.5 停止复制

```sql
STOP {SLAVE | REPLICA} [thread_types] [channel_option]

thread_types:
    [thread_type [, thread_type] ... ]

thread_type: IO_THREAD | SQL_THREAD

channel_option:
    FOR CHANNEL channel
```

### 13.1.6 在主库查看从库ip和端口

```sql
show processlist;
show slave hosts;
show replicas;
```

### 13.1.7 查看binlog

```sql
show master logs;
```

### 13.1.8 删除binlog

```sql
PURGE { BINARY | MASTER } LOGS {
    TO 'log_name'
  | BEFORE datetime_expr
}
```

### 13.1.9 查看binlog内容

```sql
SHOW BINLOG EVENTS
   [IN 'log_name']
   [FROM pos]
   [LIMIT [offset,] row_count]
```

### 13.1.10 reset master、reset slave和reset slave all

```sql

```

### 13.1.11 跳过指定事务

```sql
#基于位置点复制
stop slave;
set global sql_slave_skip_counter=1;
start slave;

#基于GTID复制，本质是注入空事务
stop slave;
set session gtid_next='xxx';#根据show slave status的executed_gtid_set的最大值+1
begin;
commit;
set session gtid_nex='automatic';
start slave;
```

### 13.1.12 操作不写入binlog

```sql
set session sql_log_bin=0;
```

### 13.1.13 判断主库的某个操作是否已经在从库执行

```sql
#位置点复制
select master_pos_wait('binlog.000060','720');

#gtid复制
select wait_for_executed_gtid_set('bd4b724b-ab29-11ee-826f-000c294bd026:15');
```

### 13.1.14 在线设置复制的规则

```sql
CHANGE REPLICATION FILTER filter[, filter]
	[, ...] [FOR CHANNEL channel]

filter: {
    REPLICATE_DO_DB = (db_list)
  | REPLICATE_IGNORE_DB = (db_list)
  | REPLICATE_DO_TABLE = (tbl_list)
  | REPLICATE_IGNORE_TABLE = (tbl_list)
  | REPLICATE_WILD_DO_TABLE = (wild_tbl_list)
  | REPLICATE_WILD_IGNORE_TABLE = (wild_tbl_list)
  | REPLICATE_REWRITE_DB = (db_pair_list)
}

db_list:
    db_name[, db_name][, ...]

tbl_list:
    db_name.table_name[, db_name.table_name][, ...]
wild_tbl_list:
    'db_pattern.table_pattern'[, 'db_pattern.table_pattern'][, ...]

db_pair_list:
    (db_pair)[, (db_pair)][, ...]

db_pair:
    from_db, to_db
```

修改完后要想重启生效，需要将对应的参数添加到配置文件中。

## 13.2 复制的监控

主要是根据performance_schema性能视图观察。

```sql
mysql> 
select TABLE_SCHEMA,TABLE_NAME,TABLE_ROWS
from information_schema.TABLES
where TABLE_SCHEMA='performance_schema' and table_name like 'replication_%';

+--------------------+------------------------------------------------------+------------+
| TABLE_SCHEMA       | TABLE_NAME                                           | TABLE_ROWS |
+--------------------+------------------------------------------------------+------------+
| performance_schema | replication_applier_configuration                    |        256 |
| performance_schema | replication_applier_filters                          |          0 |
| performance_schema | replication_applier_global_filters                   |          0 |
| performance_schema | replication_applier_status                           |        256 |
| performance_schema | replication_applier_status_by_coordinator            |        256 |
| performance_schema | replication_applier_status_by_worker                 |       8192 |
| performance_schema | replication_asynchronous_connection_failover         |          0 |
| performance_schema | replication_asynchronous_connection_failover_managed |          0 |
| performance_schema | replication_connection_configuration                 |        256 |
| performance_schema | replication_connection_status                        |        256 |
| performance_schema | replication_group_member_stats                       |          0 |
| performance_schema | replication_group_members                            |          0 |
+--------------------+------------------------------------------------------+------------+
```

### 13.2.1 连接信息

**一、replication_connection_configuration**

记录了复制的信息，包含了change master to的选项。

```sql
mysql> select * from replication_connection_configuration\G
*************************** 1. row ***************************
                   CHANNEL_NAME:
                           HOST: 192.168.131.99
                           PORT: 3306
                           USER: repl
              NETWORK_INTERFACE:
                  AUTO_POSITION: 1
                    SSL_ALLOWED: NO
                    SSL_CA_FILE:
                    SSL_CA_PATH:
                SSL_CERTIFICATE:
                     SSL_CIPHER:
                        SSL_KEY:
  SSL_VERIFY_SERVER_CERTIFICATE: NO
                   SSL_CRL_FILE:
                   SSL_CRL_PATH:
      CONNECTION_RETRY_INTERVAL: 60
         CONNECTION_RETRY_COUNT: 86400
             HEARTBEAT_INTERVAL: 30.000
                    TLS_VERSION:
                PUBLIC_KEY_PATH:
                 GET_PUBLIC_KEY: YES
              NETWORK_NAMESPACE:
          COMPRESSION_ALGORITHM: uncompressed
         ZSTD_COMPRESSION_LEVEL: 3
               TLS_CIPHERSUITES: NULL
SOURCE_CONNECTION_AUTO_FAILOVER: 0
                      GTID_ONLY: 0
```

**二、replication_connection_status**

记录了I/O线程的状态信息。

```sql
mysql> select * from replication_connection_status\G
*************************** 1. row ***************************
                                      CHANNEL_NAME:
                                        GROUP_NAME:
                                       SOURCE_UUID: bd4b724b-ab29-11ee-826f-000c294bd026
                                         THREAD_ID: 148
                                     SERVICE_STATE: ON
                         COUNT_RECEIVED_HEARTBEATS: 1198
                          LAST_HEARTBEAT_TIMESTAMP: 2024-01-19 00:38:48.460091
                          RECEIVED_TRANSACTION_SET: bd4b724b-ab29-11ee-826f-000c294bd026:14-16
                                 LAST_ERROR_NUMBER: 0
                                LAST_ERROR_MESSAGE:
                              LAST_ERROR_TIMESTAMP: 0000-00-00 00:00:00.000000
                           LAST_QUEUED_TRANSACTION: bd4b724b-ab29-11ee-826f-000c294bd026:16
 LAST_QUEUED_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP: 2024-01-19 00:15:18.242682
LAST_QUEUED_TRANSACTION_IMMEDIATE_COMMIT_TIMESTAMP: 2024-01-19 00:15:18.242682
     LAST_QUEUED_TRANSACTION_START_QUEUE_TIMESTAMP: 2024-01-19 00:15:18.317217
       LAST_QUEUED_TRANSACTION_END_QUEUE_TIMESTAMP: 2024-01-19 00:15:18.317241
                              QUEUEING_TRANSACTION:
    QUEUEING_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP: 0000-00-00 00:00:00.000000
   QUEUEING_TRANSACTION_IMMEDIATE_COMMIT_TIMESTAMP: 0000-00-00 00:00:00.000000
        QUEUEING_TRANSACTION_START_QUEUE_TIMESTAMP: 0000-00-00 00:00:00.000000
```
### 13.2.2 事务重放

**一、replication_applier_configuration**

复制中会影响从库重放事务的配置信息。基本是change master to的选项。

```sql
mysql> select * from replication_applier_configuration\G
*************************** 1. row ***************************
                                CHANNEL_NAME:
                               DESIRED_DELAY: 0
                       PRIVILEGE_CHECKS_USER: NULL
                          REQUIRE_ROW_FORMAT: NO
             REQUIRE_TABLE_PRIMARY_KEY_CHECK: STREAM
 ASSIGN_GTIDS_TO_ANONYMOUS_TRANSACTIONS_TYPE: OFF
ASSIGN_GTIDS_TO_ANONYMOUS_TRANSACTIONS_VALUE: NULL
```

**二、replication_applier_status**

从库应用线程的总体状态信息，不针对具体线程。

```sql
mysql> select * from replication_applier_status;
+--------------+---------------+-----------------+----------------------------+
| CHANNEL_NAME | SERVICE_STATE | REMAINING_DELAY | COUNT_TRANSACTIONS_RETRIES |
+--------------+---------------+-----------------+----------------------------+
|              | ON            |            NULL |                          0 |
+--------------+---------------+-----------------+----------------------------+
```

### 13.2.3 多线程复制

**一、replication_applier_status_by_coordinator**

coordinator线程的状态信息，只有开启多线程复制才会有信息。

```sql
mysql> select * from replication_applier_status_by_coordinator\G
*************************** 1. row ***************************
                                         CHANNEL_NAME:
                                            THREAD_ID: 149
                                        SERVICE_STATE: ON
                                    LAST_ERROR_NUMBER: 0
                                   LAST_ERROR_MESSAGE:
                                 LAST_ERROR_TIMESTAMP: 0000-00-00 00:00:00.000000
                           LAST_PROCESSED_TRANSACTION: bd4b724b-ab29-11ee-826f-000c294bd026:16
 LAST_PROCESSED_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP: 2024-01-19 00:15:18.242682
LAST_PROCESSED_TRANSACTION_IMMEDIATE_COMMIT_TIMESTAMP: 2024-01-19 00:15:18.242682
    LAST_PROCESSED_TRANSACTION_START_BUFFER_TIMESTAMP: 2024-01-19 00:15:18.317327
      LAST_PROCESSED_TRANSACTION_END_BUFFER_TIMESTAMP: 2024-01-19 00:15:18.317355
                               PROCESSING_TRANSACTION:
     PROCESSING_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP: 0000-00-00 00:00:00.000000
    PROCESSING_TRANSACTION_IMMEDIATE_COMMIT_TIMESTAMP: 0000-00-00 00:00:00.000000
        PROCESSING_TRANSACTION_START_BUFFER_TIMESTAMP: 0000-00-00 00:00:00.000000
```

**二、replication_applier_status_by_worker**

worker线程的状态信息。

```sql
mysql> select * from replication_applier_status_by_worker limit 1\G
*************************** 1. row ***************************
                                           CHANNEL_NAME:
                                              WORKER_ID: 1
                                              THREAD_ID: 150
                                          SERVICE_STATE: ON
                                      LAST_ERROR_NUMBER: 0
                                     LAST_ERROR_MESSAGE:
                                   LAST_ERROR_TIMESTAMP: 0000-00-00 00:00:00.000000
                               LAST_APPLIED_TRANSACTION: bd4b724b-ab29-11ee-826f-000c294bd026:16
     LAST_APPLIED_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP: 2024-01-19 00:15:18.242682
    LAST_APPLIED_TRANSACTION_IMMEDIATE_COMMIT_TIMESTAMP: 2024-01-19 00:15:18.242682
         LAST_APPLIED_TRANSACTION_START_APPLY_TIMESTAMP: 2024-01-19 00:15:18.317369
           LAST_APPLIED_TRANSACTION_END_APPLY_TIMESTAMP: 2024-01-19 00:15:18.325375
                                   APPLYING_TRANSACTION:
         APPLYING_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP: 0000-00-00 00:00:00.000000
        APPLYING_TRANSACTION_IMMEDIATE_COMMIT_TIMESTAMP: 0000-00-00 00:00:00.000000
             APPLYING_TRANSACTION_START_APPLY_TIMESTAMP: 0000-00-00 00:00:00.000000
                 LAST_APPLIED_TRANSACTION_RETRIES_COUNT: 0
   LAST_APPLIED_TRANSACTION_LAST_TRANSIENT_ERROR_NUMBER: 0
  LAST_APPLIED_TRANSACTION_LAST_TRANSIENT_ERROR_MESSAGE:
LAST_APPLIED_TRANSACTION_LAST_TRANSIENT_ERROR_TIMESTAMP: 0000-00-00 00:00:00.000000
                     APPLYING_TRANSACTION_RETRIES_COUNT: 0
       APPLYING_TRANSACTION_LAST_TRANSIENT_ERROR_NUMBER: 0
      APPLYING_TRANSACTION_LAST_TRANSIENT_ERROR_MESSAGE:
    APPLYING_TRANSACTION_LAST_TRANSIENT_ERROR_TIMESTAMP: 0000-00-00 00:00:00.000000
1 row in set (0.00 sec)
```

### 13.2.4 过滤规则

**一、replication_applier_filters**

记录了复制中channel级别的过滤规则。

```sql
mysql> select * from replication_applier_filters;
```

**二、replication_applier_global_filters**

全局级别的过滤规则，对所有channel都生效。

```sql
mysql> select * from replication_applier_global_filters;
```

### 13.2.5 组复制

```sql
mysql> select * from replication_group_members\G
```

```sql
mysql> select * from replication_group_member_stats\G
```
## 13.3 主从延迟

### 13.3.1 主从延迟分析

**一、从库服务器的负载情况**

对于主从延迟，一般关注CPU和I/O；

**1）CPU**

分析CPU是否达到瓶颈，常用的命令是top。

```bash
%Cpu(s):  0.0 us,  0.2 sy,  0.0 ni, 99.7 id,  0.0 wa,  0.2 hi,  0.0 si,  0.0 st
```

一般来说，当CPU的空闲时间占比小于10%时，需要重点关注。一般来说，对于数据库，CPU很少时瓶颈，除非有大量的慢SQL。

**2）I/O**

查看磁盘I/O的负载情况，常用的命令是iostas。

```bash
[mysql@mysql002 ~]$ iostat -xm
Linux 5.4.17-2102.201.3.el7uek.x86_64 (mysql002)        01/20/2024      _x86_64_        (2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.02    0.00    0.55    0.00    0.00   99.43

Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sdb               0.00     0.00    0.01    0.03     0.00     0.00    66.02     0.00    0.36    0.44    0.35   0.45   0.00
sda               0.00     0.02    0.04    0.11     0.00     0.00    26.94     0.00    0.59    0.36    0.68   0.78   0.01
scd0              0.00     0.00    0.00    0.00     0.00     0.00   114.22     0.00    1.17    1.17    0.00   1.33   0.00
```

**二、主从复制状态**

**1）主库**
主库使用show master status查看复制状态。

```sql
mysql> show master status\G
             File: binlog.000060
         Position: 1000
```

需要关注的指标是File、Position。

(File,Position)记录了主库 binlog 的位置。

**2）从库**

从库用show slave status命令查看复制状态。

```sql
mysql> show slave status\G
              Master_Log_File: binlog.000060
          Read_Master_Log_Pos: 1000
        Relay_Master_Log_File: binlog.000060
          Exec_Master_Log_Pos: 1000
```

需要关注的指标是Master_Log_File、Read_Master_Log_Pos、Relay_Master_Log_File和Exec_Master_Log_Pos。

(Master_Log_File,Read_Master_Log_Pos)记录了IO线程当前正在接收的二进制日志事件在主库 binlog 中的位置。

(Relay_Master_Log_File,Exec_Master_Log_Pos)记录了SQL线程当前正在重放的二进制日志事件在主库 binlog 的位置。

**3）出现主从延迟的情况**

- 如果 (File,Position)大于(Master_Log_File,Read_Master_Log_Pos) 则意味着**IO线程**存在延迟。
- 如果(Relay_Master_Log_File,Exec_Master_Log_Pos)小于(Master_Log_File, Read_Master_Log_Pos ) ，则意味着**SQL线程**存在延迟。

**三、主库binlog的写入量**

关注主库的binlog的生成速度。

### 13.3.2 主从延迟的常见原因及解决办法

**一、I/O线程存在延迟**

一般情况下I/O很少存在延迟。

**1）网络延迟**

可开启slave_compressed_protocol参数，启用binlog压缩传输。

**2）磁盘I/O存在瓶颈**

可调整从库的双一设置或关闭binlog。

**3）网卡存在问题**

**二、SQL线程存在延迟**

**1）主库写入量过大，SQL线程单线程重放**

可升级到5.7以上，开启并行复制。

**2）statement模式下的慢sql**

表现为Relay_Master_Log_File和Exec_Master_Log_Pos在一段时间内没有变化。

解决办法是优化sql。

**3）row格式下，表上没索引**

表现为Relay_Master_Log_File和Exec_Master_Log_Pos在一段时间内没有变化。

解决办法是：

- 从库临时创建一个索引，加快从放速度。
- 将参数slave_rows_search_algorithms设置为INDEX_SCAN,HASH_SCAN。

**4）大事务**

row格式下，操作涉及的记录数比较多。

解决办法是，索引已经创建的情况下，将大事务拆分为小事务，每次小批量执行。

**5）从库上有查询操作**

**6）从库上有备份**

**7）磁盘I/O存在瓶颈**

### 13.3.3 解读Seconds_Behind_Master

**一、Seconds_Behind_Master的局限性**

**二、监控主从延迟**

**1）MySql8.0之前，使用pt-heartbeat**

安装：

```bash
wget percona.com/get/pt-heartbeat
chmod +x pt-heartbeat

#添加环境变量
sudo vim /etc/profile
source /etc/profile
```

**1）主库**

```bash
[mysql@mysql002 ~]$ pt-heartbeat -u root -p Mysql123. -h mysql001 -D percona --update --daemonize
```
第一次执行加上--create-table。

**2）从库**

```bash
[mysql@mysql002 ~]$ pt-heartbeat -u root -p Mysql123. -h mysql002 -D percona --monitor
```

**2）MySql8.0原生的解决方案**

```sql
select case
        when min_commit_timestamp is null then 0
        else unix_timestamp(now(6)) - unix_timestamp(min_commit_timestamp)
    end as seconds_behind_master
from (
     select min(APPLYING_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP) as min_commit_timestamp
       from performance_schema.replication_applier_status_by_worker
      where applying_transaction <> ''
	 ) t;

+-----------------------+
| seconds_behind_master |
+-----------------------+
|                     0 |
+-----------------------+
```

# 14 组复制

## 14.1 组复制的原理介绍

MySQL Group Replication（MGR）是MySQL数据库的一种高可用性解决方案，它提供了一个用于MySQL服务器的多主复制插件。它允许一组MySQL服务器一起工作，形成一个单一的、高可用性的、容错的复制组。组中的每个服务器都可以充当主服务器和从服务器，实现了分布式、多主复制。

MySQL Group Replication背后的设计和实现基于Paxos算法。Paxos是一种分布式一致性算法，用于确保在分布式系统中的节点之间达成一致的共识。在MySQL Group Replication中，Paxos算法的思想被用来协调和保持组中成员之间的一致性状态。

关于MySQL Group Replication的一些关键点如下：

1. **同步复制：** Group Replication的一个显著特点是支持同步复制。当在一个服务器上提交事务时，它会立即被复制到组中的所有其他服务器。这确保了在任何给定时间点，所有成员都具有相同的数据集。

2. **自动组成员管理：** Group Replication自动管理组的成员资格。当向组中添加新服务器时，它会自动与现有成员同步。如果服务器失败或离开组，剩余的服务器会自动调整以适应变化，确保持续运行。

3. **多主复制：** Group Replication组中的每个服务器都可以接受读和写事务。这允许分布式工作负载，并提供了改进的读可伸缩性。

4. **一致性：** Group Replication通过使用分布式认证过程确保所有成员的一致性。这意味着在提交事务之前，它会由组中大多数成员认证，确保数据保持一致。

5. **容错性：** 该组设计为容错。如果一个或多个服务器失败，剩余的服务器可以继续提供读和写请求。当故障的服务器恢复时，它会自动重新与组同步。

6. **冲突解决：** 在存在冲突事务的情况下，Group Replication使用投票机制来确定冲突事务的顺序。这有助于保持组内的一致状态。

7. **与复制的兼容性：** Group Replication与传统的MySQL异步复制兼容。这意味着您可以在同一环境中使用一些使用传统复制的服务器，而另一些使用Group Replication。

要实施Group Replication，通常需要配置MySQL实例，设置必要的安全凭据，并启动组。对于对高可用性、容错性和一致性要求至关重要的场景，它是一个强大的解决方案。

官方参考文档：[https://dev.mysql.com/doc/refman/8.0/en/group-replication.html](https://dev.mysql.com/doc/refman/8.0/en/group-replication.html)

### 14.1.1 复制技术

#### 14.1.1.1 异步复制

**1）异步复制的原理图如下：**

![alt text](image-4.png)

**2）异步复制的大致过程：**

1. 主库执行SQL语句：存储引擎执行SQL操作；
2. 主库写binlog：主库记录执行的所有数据库变更操作，将这些操作以二进制格式保存在binlog中；
3. 主库传送binlog事件：主库写binlog后，把 binlog 里面的内容传给从库的中继日志（relay log）中；
4. 主库事务返回客户端：主库写binlog后，可直接在引擎层提交事务，将事务返回客户端。

步骤3和步骤4实是同步进行的。

**3）异步复制的隐患：**

由于步骤3和步骤4实是同步进行的，也就是说主库写binlog后，直接提交事务的同时，向从库发送binlog事件。当主库出现故障，复制中断，原来主库上可能有一部分已经完成提交的事务还没来得及发送到从库，当从库切换为主库后，就会发现主库之前写入的数据丢失了，无法保证主从数据一致性。

#### 14.1.1.2 半同步复制

**1）半同步复制的原理图如下：**

![alt text](image-5.png)

**2）半同步复制的大致过程：**

1. 主库执行SQL语句：存储引擎执行SQL操作；
2. 主库写binlog：主库记录执行的所有数据库变更操作，将这些操作以二进制格式保存在binlog中；
3. 主库传送binlog事件：主库写binlog后，把 binlog 里面的内容传给从库的中继日志（relay log）中；
4. 从库发送 ACK：从库收到binlog后，发送给主库一个 ACK，表示收到了；
5. 主库事务返回客户端：主库收到从库的ACK信号后，在引擎层提交事务，将事务返回客户端。

跟异步复制相比，半同步复制保证了事务在返回客户端后，对应的binlog事件从库确认收到了，已经写入到relay log中。

**3）半同步复制的隐患：**

当事务在写入binlog之后，写入relay log之前，主库宕机了，主从切换后，从库看到的数据有可能跟写入binlog的会话数据不一致。并且，当主库恢复后，由于宕机前，事务已经写入binlog，在实例恢复过程中会从新将这部分事务提交，这就导致了主从数据不一致。

#### 14.1.1.3 组复制

**1）组复制的原理图如下：**

![alt text](image-6.png)

**2）组复制与传统复制的区别：**

组复制引入了两个新的机制，Consensus和Certify，这两个机制共同确保了 Group Replication 中的数据一致性和高可用性。 Consensus 用于在组内达成一致的决策，而 Certify 用于确保提交的事务得到足够多的认证。

**Consensus（共识）**，在组复制中，Consensus 指的是通过 Paxos 算法，确保组内成员就状态协商、Primary 节点选举、事务提交等关键决策达成一致的过程。Consensus 机制用于确保组内的所有成员就某个问题或决策达成一致意见。确保消息的全局有序和消息被半数以上的成员确认接受。

**Certify（认证）**，是组复制的一种机制，用于确保事务在提交时，组内的大多数成员都已经接收并执行了这个事务。在提交事务时，Primary 节点会等待至少大多数成员的确认，确保事务得到了足够多的认证。简单来说，就是确保所有成员对于同一个事务要么都认证，要么全都认证失败，事务得到了足够多的认证后才会提交。

**3）组复制的工作机制：**

组复制由多个成员组成，组中每个成员可以独立执行事务（多主模式）。但是，所有读写事务只有在获得组批准后才会提交（只读事务可以不通过组内协调就能提交）。

Primary节点负责接收事务提交，并将这些事务广播给组内的其他成员，组中的所有成员要么接收事务，要么都不接收。并且都以相同的顺序接收同一组事务，并为事务建立一个全局总顺序。

在组复制中，并发执行的事务的冲突检测和解决与死锁处理类似，确保对同一行数据的并发更新不会导致数据不一致或冲突。如果在不同节点上的两个并发事务更新了相同的行，系统会根据一致性协议进行解决。通过 Paxos 算法确保对同一行数据的并发更新不会导致数据不一致。排序靠前的提交，排序靠后的事务可能需要回滚。

### 14.1.2 组复制使用场景

MySQL组复制提供了一个高可用性、高弹性、可靠的MySQL服务。通过将系统状态复制到一组服务器，组复制使您能够创建具有冗余的容错系统，组内的成员之间可以同时进行读写操作，并保持数据的一致性。即使一些组成员出现故障，只要不是全部或大多数，系统仍然可用。根据故障成员的数量，组的性能或可伸缩性可能会下降，但它仍然可用，**保证了数据库服务的持续可用性**。

以下是一些MySQL Group Replication的使用场景：

1. **高可用性：** Group Replication提供了高可用性的数据库解决方案。由于组内的每个成员都可以成为Primary节点，当某个节点发生故障时，系统可以通过重新选举来选择新的Primary节点，保证数据库服务的持续可用性。
   ！！！需要注意的是，尽管数据库服务是可用的，但在组成员意外退出的情况下，必须将连接到它的那些客户端重定向到故障转移到另一个组成员。

2. **读写分离：** 组内的每个成员都可以接收读和写操作，这使得可以在不同节点上进行读写操作，从而分担数据库负载，提高整体系统的读写性能。

3. **弹性伸缩：** 支持在运行时动态添加或移除节点，以适应业务负载的变化。这种弹性伸缩的能力使得数据库系统更加灵活和可调整。

4. **故障转移：** 在发生故障时，Group Replication可以自动进行故障转移。系统会重新选举新的Primary节点，确保写入操作的连续性。

5. **实时数据分析：** 在需要进行实时数据分析的场景中，可以利用Group Replication在多个节点上执行读操作，提高数据分析的性能。

6. **维护和升级：** 在维护数据库或进行升级时，可以在组内的一个节点上执行维护操作，而其他节点仍然可以提供服务。维护完成后，再将节点重新加入组。

### 14.1.3 单主模式和多主模式的区别

组复制有两种运行模式，一种是单主模式，一种是多主模式。这个模式是在整个组中设置的，由 `group_replication_single_primary_mode` 这个系统变量指定，而且在所有成员上必须保持一致。ON 表示单主模式，这也是默认的模式；OFF 表示多主模式。需要注意的是，不能在同一个组的成员中同时使用不同的模式，比如：一个成员配置在多主模式，而另一个成员在单一主模式下。

当组复制正在运行时，不能手动更改 `group_replication_single_primary_mode` 的值。

在MySQL 8.0.13之前的版本中，如果要更改组的模式，必须停止组复制并在所有成员上更改 `group_replication_single_primary_mode` 的值。然后进行一次完整的组重启（由 `group_replication_bootstrap_group=ON` 的服务器引导），以实施对新操作配置的更改。注意：不需要重新启动mysqld服务，只需要将组复制重新引导即可。

从MySQL 8.0.13开始，支持**在线**对组复制模式进行变更。使用 `group_replication_switch_to_single_primary_mode()` 和 `group_replication_switch_to_multi_primary_mode()` 这两个函数在组复制仍在运行时将组从一种模式切换到另一种模式。这两个函数会管理切换组模式的过程，并确保数据的安全性和一致性。

#### 14.1.3.1 单主模式

在单主模式下（group_replication_single_primary_mode=ON），组内有一个primary节点，该节点被设置为读写模式，组中的所有其他成员（secondary节点）都被自动设置为只读模式（使用super_read_only=ON）。通常情况下，primary节点通常是引导该组的第一个节点，加入该复制组的所有其他secondary节点均需要从读写节点同步数据，并自动设置为只读模式。

在单一主模式下，组复制会强制只有一个节点作为可读写节点，其他节点均为只读，因此与多主模式相比，一致性检查可能不那么严格，DDL语句不需要额外小心处理。选项 `group_replication_enforce_update_everywhere_checks` 用于启用或禁用组的严格一致性检查。在部署单一主模式或将组更改为单一主模式时，必须将此系统变量设置为OFF。

被指定为primary节点的成员可能通过以下方式进行角色的更改：

- 有primary节点主动或意外离开组，将自动选举新的primary节点。
- 使用 `group_replication_set_as_primary()` 函数指定某个成员为新的primary节点。
- 使用 `group_replication_switch_to_single_primary_mode()` 函数将组复制模式从多主模式更改为单主模式，会自动选举新的primary节点。也可以您可以使用此函数指定新的primary节点。

上述介绍的两个非自动并更primary节点的函数，只支持所有复制组成员在MySQL8.0.13或更高版本时使用。当自动选举或手动指定新的primary节点时，它会自动设置为读写，其他组成员仍然保持为secondary节点，因此仍为只读，原理图如下：

![alt text](image-7.png)

当组中一个节点被选为新的primary节点时，可能存在已应用于旧primary节点但尚未应用于新primary节点已经变更了的**数据积压**。在消化了这部分积压的数据之前，会存在以下情况：

- 在新primary节点上的写事务可能会和之前的旧数据导致冲突，会造成回滚；
- 新primary节点上的只读事务可能导致读取到旧的数据。

MySQL提供了一种可以减小快速和慢速成员之间的差异，从而减少这种情况发生的可能性的方法，就是启用并适当调整组复制的流控制机制。

从MySQL8.0.14版本开始，可以使用 `group_replication_consistency` 系统变量来配置组的事务d的一致性级别，以防止上述由于事务积压导致的情况发生。设置为 `BEFORE_ON_PRIMARY_FAILOVER`（或任何更高的一致性级别），在新选举的primary节点上保留新事务，直到将积压的事务全都应用完成后，才会接着应用在primary主节点上发起的事务。

如果组没有使用流控制和事务一致性保证，最好在重新将应用程序切换到新primary节点之前，应等待新primary节点应用其与复制相关的中继日志（已经通过冲突认证检测，但在relay log中还未来得及回放的日志）。

#### 14.1.3.2 多主模式

在多主模式下（group_replication_single_primary_mode=OFF），所有成员都是primary节点。新节点加入组时都被设置为读写模式，并且可以处理写事务，即使它们是并发执行的。

如果一个成员停止接受写事务，例如组中的某个成员意外宕机了，连接到它的客户端可以被重定向或故障切换到任何其他处于读写模式的健康成员。下图说明了多主模式下故障转移的大致过程：

![alt text](image-8.png)

组复制是一种最终一致性的系统，就是说当传入的流量减缓或停止，所有组成员都具有相同的数据内容。在流量流动时，事务可能会在某些成员上外部化（客户端接收到新数据），而在其他成员上则可能较慢，特别是如果某些成员的写入吞吐量较低，从而可能导致性能差的节点上读取到旧数据。在多主模式下，较慢的成员还可能累积过多的待认证和应用的事务，增加了冲突和认证失败的风险。为了限制这些问题，可以激活并调整流控制机制，以最小化快速和慢速成员之间的差异。

从MySQL8.0.14开始，可以使用`group_replication_consistency`系统变量来实现对组中的每个事务都有一致性保证。可以选择适合组工作负载和数据读写优先级的设置。同时，考虑到提高一致性对组复制性能的影响，还可以为单个会话设置该系统变量，用于保护特别是对并发敏感的事务。

**事务检查：**

当一个组以多主模式部署时，会对事务进行检查，以确保其与多主模式兼容。相关的严格一致性检查如下：

- 不允许将事务的隔离级别设置为SERIALIZABLE隔离级，否则在其与组同步时，将提交失败；
- 不支持外键约束，否则也将提交失败。

这些检查由 `group_replication_enforce_update_everywhere_checks` 系统变量控制。在多主模式下，此变量通常应设置为ON，但可以通过设置为OFF来选择性地取消激活这些检查。在部署单主模式时，此变量必须设置为OFF。

**多主模式下DDL语句的注意点：**

在多主模式的Group Replication拓扑结构中，执行数据定义语句（通常称为数据定义语言DDL）时需要特别注意。

MySQL8.0引入了对原子数据定义语言（DDL）语句的支持，其中完整的DDL语句作为单个原子事务被提交或回滚。DDL语句会隐式结束当前会话中活动的任何事务，相当于执行了COMMIT一样。这意味着DDL语句不能在另一个事务内执行，不能在事务控制语句（比如START TRANSACTION ... COMMIT）内执行，也不能在同一事务内与其他语句组合执行。

在多主模式下复制DDL语句时需要更加小心。如果对同一对象进行模式更改（使用DDL）和该对象包含的数据的更改（使用DML），需要通过同一节点处理这些更改。否则，可能导致在操作被中断或仅部分完成时数据不一致。如果组部署在单一主模式下，则不会发生此问题，因为所有更改都是通过同一服务器（主服务器）执行的。

**版本兼容性：**

为了获得最佳的兼容性和性能，组中的所有成员应该运行在相同版本的MySQL Server，相同版本的组复制。在多主模式下，这更为重要，因为所有成员通常都会以读写模式加入组，如果一个组包含运行不同MySQL Server版本的成员，就有可能导致一些成员与其他成员不兼容，因为它们支持其他成员没有的功能，或者缺少其他成员拥有的功能。为了防范这种情况，在新成员加入组时（包括升级并重新启动的以前的成员），该成员会进行与组的其余部分的兼容性检查。

这些兼容性检查的一个重要结果在多主模式下尤为重要。如果加入组的成员运行的MySQL Server版本高于现有组成员运行的最低版本，它将加入组但仍保持为只读模式。（在单一主模式下运行的组中，新添加的成员在任何情况下默认为只读模式。）运行MySQL 8.0.17或更高版本的成员在检查兼容性时会考虑发布的补丁版本。运行MySQL 8.0.16或更低版本，或者MySQL 5.7的成员只考虑主版本。

在一个运行在多主模式下且成员使用不同MySQL Server版本的组中，组复制会自动管理运行MySQL 8.0.17或更高版本的成员的读写和只读状态。如果一个成员离开组，那么运行现在最低版本的版本的成员会被自动设置为读写模式。当使用 `group_replication_switch_to_multi_primary_mode()` 函数将运行在单主模式下的组切换到多主模式时，会自动设置成员的正确模式。如果成员运行的MySQL Server版本高于组中存在的最低版本，则它们会被自动放置在只读模式，而运行最低版本的成员会被放置在读写模式。


## 14.2 MySQL单主模式部署组复制

### 14.2.1 部署规划

| 主机名 | ip地址 | 角色 | 版本号 | 服务器版本 |
| - | - | - | - | - |
| node1 | 192.168.131.10 | primary | MySQL8.0.27 | RHEL7.9 |
| node2 | 192.168.131.20 | secondary | MySQL8.0.27 | RHEL7.9 |
| node3 | 192.168.131.30 | secondary | MySQL8.0.27 | RHEL7.9 |

### 14.2.2 准备安装环境

准备安装环境环节三个节点node1、node2和node3都需要执行。

**1）关闭防火墙**

```bash
[root@node1 ~]# systemctl stop firewalld
[root@node1 ~]# systemctl disable firewalld
#或者
[root@node1 ~]# iptables -F
```

**2）关闭selinux**

```bash
[root@node1 ~]# setenforce 0
setenforce: SELinux is disabled
[root@node1 ~]# vim /etc/sysconfig/selinux
SELINUX=disabled
```

### 14.2.3 配置组复制实例

配置组复制实例环节三个节点node1、node2和node3都需要执行。

#### 14.2.3.1 解压二进制包并创建软连接

```bash
[root@node1 local]# tar -xvf mysql-8.0.27-linux-glibc2.12-x86_64.tar.xz
[root@node1 local]# ln -s mysql-8.0.27-linux-glibc2.12-x86_64 mysql
```

#### 14.2.3.2 编辑 node1 配置文件

```bash
[root@node1 local]# vim /etc/my.cnf
```

添加如下配置：

```bash
[mysqld]
#Server Settings

basedir=/usr/local/mysql
datadir=/data/mysql/3306/data
user=mysql
port=3306
socket=/data/mysql/3306/data/mysql.sock
log_error=/data/mysql/3306/data/mysqld.err
log_timestamps=system
skip_name_resolve=TRUE
report_host="192.168.131.10"
disabled_storage_engines="MyISAM,BLACKHOLE,FEDERATED,ARCHIVE,MEMORY"
sql_require_primary_key=ON

#Replication Framework

server_id=1
gtid_mode=ON
enforce_gtid_consistency=ON
log_bin=binlog
log_slave_updates=ON
binlog_format=ROW
master_info_repository=TABLE
relay_log_info_repository=TABLE
transaction_write_set_extraction=XXHASH64
super_read_only=ON
binlog_transaction_dependency_tracking=WRITESET

#Group Replication Settings

plugin_load_add='group_replication.so'
loose_group_replication_group_name="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
loose_group_replication_start_on_boot=off
loose_group_replication_local_address= "192.168.131.10:33061"
loose_group_replication_group_seeds= "192.168.131.10:33061,192.168.131.20:33061,192.168.131.30:33061"
loose_group_replication_bootstrap_group=off
loose_group_replication_recovery_get_public_key=ON

#Multi-Source Replication Settings

replica_parallel_workers=4
replica_parallel_type=LOGICAL_CLOCK
slave_preserve_commit_order=1

[client]
socket=/data/mysql/3306/data/mysql.sock
```

**注意，** 需要手动将下面三个系统变量修改为自己实际环境中的配置：`report_host`、`loose_group_replication_local_address`、`loose_group_replication_group_seeds`。

系统变量`loose_group_replication_group_name`为集群名称，必须为一个唯一值，可以通过select uuid()生成。

#### 14.2.3.3 编辑 node2 配置文件

除了修改下面三个系统变量，其他和node1配置保持一致：

```bash
report_host="192.168.131.20"
server_id=2
loose_group_replication_local_address= "192.168.131.20:33061"
```

#### 14.2.3.4 编辑 node3 的配置文件

除了修改下面三个系统变量，其他和node1配置保持一致：

```bash
report_host="192.168.131.30"
server_id=3
loose_group_replication_local_address= "192.168.131.30:33061"
```

#### 14.2.3.5 创建数据目录

```bash
[root@node1 local]# mkdir -p /data/mysql/3306/data
```

#### 14.2.3.6 添加环境变量

```bash
[root@node1 ~]# vim /etc/profile
#添加
export MYSQL_HOME=/usr/local/mysql
export PATH=$PATH:$MYSQL_HOME/bin

[root@node1 ~]# source /etc/profile
```

#### 14.2.3.7 添加mysql用户和组

```bash
[root@node1 ~]# cd /usr/local/
[root@node1 local]# groupadd mysql
[root@node1 local]# useradd -g mysql mysql
[root@node1 local]# passwd mysql
Changing password for user mysql.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.
```

#### 14.2.3.8 初始化实例

```bash
[root@node1 local]# /usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf --initialize-insecure
```

#### 14.2.3.9 配置systemd系统管理mysql service

**1）创建systemd服务配置文件**

```bash
[root@node1 ~]# vim /usr/lib/systemd/system/mysqld.service
```

添加:

```bash
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network-online.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql

Type=notify

# Disable service start and stop timeout logic of systemd for mysqld service.
TimeoutSec=0

# Start main service
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf $MYSQLD_OPTS

# Use this to switch malloc implementation
EnvironmentFile=-/etc/sysconfig/mysql

# Sets open_files_limit
LimitNOFILE = 65536

Restart=on-failure

RestartPreventExitStatus=1

# Set enviroment variable MYSQLD_PARENT_PID. This is required for restart.
Environment=MYSQLD_PARENT_PID=1

PrivateTmp=false
```

**2）配置生效**

```bash
[root@node1 ~]# systemctl daemon-reload
[root@node1 bin]# systemctl start mysqld
```

### 14.2.4 启动组复制

主要在node1上执行。

#### 14.2.4.1 查看插件是否加载成功

3个节点都确认一下组复制插件 `group_replication.so` 是否安装成功：

```bash
mysql> select * from information_schema.plugins where plugin_name = 'group_replication'\G
*************************** 1. row ***************************
           PLUGIN_NAME: group_replication
        PLUGIN_VERSION: 1.1
         PLUGIN_STATUS: ACTIVE
           PLUGIN_TYPE: GROUP REPLICATION
   PLUGIN_TYPE_VERSION: 1.4
        PLUGIN_LIBRARY: group_replication.so
PLUGIN_LIBRARY_VERSION: 1.10
         PLUGIN_AUTHOR: Oracle Corporation
    PLUGIN_DESCRIPTION: Group Replication (1.1.0)
        PLUGIN_LICENSE: GPL
           LOAD_OPTION: ON
1 row in set (0.00 sec)
```

#### 14.2.4.2 在node1上执行初始化组复制

首次启动一个组复制的过程称为引导（bootstrapping），使用 `group_replication_bootstrap_group` 系统变量来引导一个组复制。

**需要注意的是，引导应该只由其中一个节点完成，且仅执行一次。**

这就是为什么此变量没直接写死在配置文件中的原因。如果它保存在配置文件中，那么MySQl Service在重新启动时，服务器将自动引导具有相同名称的第二个组复制。这将导致两个具有相同名称的不同组。

因此，为了安全地引导组复制，需要在启动组复制后再次关闭此系统变量：

```bash
mysql> set global group_replication_bootstrap_group=on;
mysql> start group_replication;
mysql> set global group_replication_bootstrap_group=off;
```

组启动成功后，通过视图 `performance_schema.replication_group_members`，查看组复制成员信息。此时可以看到组已经创建，并且有一个成员：

```bash
mysql> select * from performance_schema.replication_group_members;
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST    | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | f40395ea-c132-11ee-9249-000c29c00092 | 192.168.131.10 |        3306 | ONLINE       | PRIMARY     | 8.0.27         | XCom                       |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
```

#### 14.2.4.3 在引导成员node1上创建复制用户并赋权

创建的用户主要用于下一步配置恢复通道。

```sql
mysql>
create user rpl_user@'%' identified by 'rpl_123';
grant replication slave on *.* to rpl_user@'%';
grant connection_admin on *.* to rpl_user@'%';
grant backup_admin on *.* to rpl_user@'%';
grant group_replication_stream on *.* to rpl_user@'%';
```

**注意：** 千万别在从节点上执行`flush privileges`，执行后会写入从节点的binlog，造成与组复制的事务不一致，导致添加节点失败，报错信息如下：

```bash
2024-02-03T00:33:18.335943+08:00 0 [ERROR] [MY-011526] [Repl] Plugin group_replication reported: 'This member has more executed transactions than those present in the group. Local transactions: 13fc049e-c133-11ee-a377-000c29df1f85:1 > Group transactions: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:1-10'
2024-02-03T00:33:18.336062+08:00 0 [ERROR] [MY-011522] [Repl] Plugin group_replication reported: 'The member contains transactions not present in the group. The member will now exit the group.'
```

解决办法有两个：

1. 最保险的办法是重建这个从库；
2. 也可以在**主库**上插入空会话，直到组复制事务大于从库的事务，最后再重新添加节点。
  ```sql
  SET GTID_NEXT='13fc049e-c133-11ee-a377-000c29df1f85:1';
  BEGIN; COMMIT;
  SET GTID_NEXT=AUTOMATIC;
  ```

#### 14.2.4.4 配置node1的恢复通道

```bash
mysql> change master to master_user='rpl_user', master_password='rpl_123' for channel 'group_replication_recovery';
```

创建测试数据：

```sql
mysql> 
create database mgrtest;
create table mgrtest.demo(id int primary key,c1 varchar(10));
insert into mgrtest.demo values(1,'a'),(2,'b');
```

### 14.2.5 添加节点node2和node3

**在 node2 和 node3 上执行**

**1）配置恢复通道**

```bash
mysql> change master to master_user='rpl_user', master_password='rpl_123' for channel 'group_replication_recovery';
```

**2）启动组复制**

```
mysql> start group_replication;
```

**3）查看集群节点信息**

```sql
mysql> select * from performance_schema.replication_group_members;
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST    | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 13fc049e-c133-11ee-a377-000c29df1f85 | 192.168.131.20 |        3306 | ONLINE       | SECONDARY   | 8.0.27         | XCom                       |
| group_replication_applier | 248563ac-c133-11ee-a387-000c29551477 | 192.168.131.30 |        3306 | ONLINE       | SECONDARY   | 8.0.27         | XCom                       |
| group_replication_applier | f40395ea-c132-11ee-9249-000c29c00092 | 192.168.131.10 |        3306 | ONLINE       | PRIMARY     | 8.0.27         | XCom                       |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
```

**4）验证测试数据**

```sql
mysql> select * from mgrtest.demo;
+----+------+
| id | c1   |
+----+------+
|  1 | a    |
|  2 | b    |
+----+------+
```

## 14.3 单主模式和多主模式切换

### 14.3.1 注意点

组复制有两种运行模式，一种是单主模式，一种是多主模式。这个模式是在整个组中设置的，由 `group_replication_single_primary_mode` 这个系统变量指定，而且在所有成员上必须保持一致。ON 表示单主模式，这也是默认的模式；OFF 表示多主模式。需要注意的是，不能在同一个组的成员中同时使用不同的模式，比如：一个成员配置在多主模式，而另一个成员在单一主模式下。

当组复制正在运行时，不能手动更改 `group_replication_single_primary_mode` 的值。

在MySQL 8.0.13之前的版本中，如果要更改组的模式，必须停止组复制并在所有成员上更改 `group_replication_single_primary_mode` 的值。然后进行一次完整的组重启（由 `group_replication_bootstrap_group=ON` 的服务器引导），以实施对新操作配置的更改。注意：不需要重新启动mysqld服务，只需要将组复制重新引导即可。

从MySQL 8.0.13开始，支持**在线**对组复制模式进行变更。使用 `group_replication_switch_to_single_primary_mode()` 和 `group_replication_switch_to_multi_primary_mode()` 这两个函数在组复制仍在运行时将组从一种模式切换到另一种模式。这两个函数会管理切换组模式的过程，并确保数据的安全性和一致性。

### 14.3.2 MySQL8.0.13版本前切换方法

在MySQL8.0.13版本之前的版本，不支持在线切换组复制的模式，切换模式需要重启整个组复制。

**一、单主模式切换为多主模式**

1.查看集群状态和模式

```sql
mysql> select * from performance_schema.replication_group_members;
mysql> show status like 'group_replication_primary_member';
```

判断单主模式的方法是，系统状态变量`group_replication_primary_member`不为空，会显示主节点的成员号。

2.在所有节点上停止组复制

```sql
mysql> stop group_replication;
```

3.修改主库的配置并重启

```sql
mysql> 
set global group_replication_single_primary_mode=off;
set global group_replication_enforce_update_everywhere_checks=on;
set global group_replication_bootstrap_group=on;
start group_replication;
set global group_replication_bootstrap_group=OFF;
```

参数说明：

- group_replication_single_primary_mode：单主模式；
- group_replication_enforce_update_everywhere_checks：冲突检测，严格的一致性检查；
- group_replication_bootstrap_group：组复制初始化。

4.修改从库的配置并重启

```sql
mysql> 
set global group_replication_single_primary_mode=off;
set global group_replication_enforce_update_everywhere_checks=on;
start group_replication;
```

**二、多主模式切换为单主模式**

1.在所有节点上停止组复制

```sql
mysql> stop group_replication;
```

2.修改主库的配置并重启

```sql
mysql> 
set global group_replication_enforce_update_everywhere_checks=off;
set global group_replication_single_primary_mode=on;
set global group_replication_bootstrap_group=on;
start group_replication;
set global group_replication_bootstrap_group=OFF;
```

4.修改从库的配置并重启

```sql
mysql> 
set global group_replication_enforce_update_everywhere_checks=off;
set global group_replication_single_primary_mode=on;
start group_replication;
```

**三、问题探究**

我们知道，单主模式和多主模式的一个很本质的区别是单主模式只有主库支持读写，从库只读。

将集群从单主模式切换为多主模式，就要求单主模式的从库要从只读设置为可读可写。设置只读的参数为`read_only`和`super_read_only`。

不知道各位是否有疑问，当组复制模式转换时，是否需要手动设置上面这两个参数？

比如，当单主模式切换为多主模式时，`read_only`和`super_read_only`MySQL是否会自动设置为OFF？

实验过程如下：

![alt text](image-9.png)

实验结果是，不需要手动设置只读参数。

### 14.3.3 MySQL8.0.13及以后版本切换方法

在MySQL8.0.13版本开始，支持在线切换组复制模式，不需要重启，只需要执行两个内置的函数即可快速完成切换。

**一、单主模式切换为多主模式**

使用group_replication_switch_to_single_primary_mode()函数将单主模式切换为多主模式。

在任意节点执行如下命令:

```sql
mysql> select group_replication_switch_to_multi_primary_mode();
+--------------------------------------------------+
| group_replication_switch_to_multi_primary_mode() |
+--------------------------------------------------+
| Mode switched to multi-primary successfully.     |
+--------------------------------------------------+
1 row in set (1.01 sec)
```

查看成员状态：

```sql
mysql> select * from performance_schema.replication_group_members;
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST    | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 13fc049e-c133-11ee-a377-000c29df1f85 | 192.168.131.20 |        3306 | ONLINE       | PRIMARY     | 8.0.27         | XCom                       |
| group_replication_applier | 248563ac-c133-11ee-a387-000c29551477 | 192.168.131.30 |        3306 | ONLINE       | PRIMARY     | 8.0.27         | XCom                       |
| group_replication_applier | f40395ea-c132-11ee-9249-000c29c00092 | 192.168.131.10 |        3306 | ONLINE       | PRIMARY     | 8.0.27         | XCom                       |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
3 rows in set (0.00 sec)
```

切换后MEMBER_ROLE的值都为PRIMARY。

**二、多主模式切换为单主模式**

查看集群模式和成员号：

```sql
mysql> select * from performance_schema.replication_group_members;
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST    | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 13fc049e-c133-11ee-a377-000c29df1f85 | 192.168.131.20 |        3306 | ONLINE       | PRIMARY     | 8.0.27         | XCom                       |
| group_replication_applier | 248563ac-c133-11ee-a387-000c29551477 | 192.168.131.30 |        3306 | ONLINE       | PRIMARY     | 8.0.27         | XCom                       |
| group_replication_applier | f40395ea-c132-11ee-9249-000c29c00092 | 192.168.131.10 |        3306 | ONLINE       | PRIMARY     | 8.0.27         | XCom                       |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
3 rows in set (0.00 sec)
```

指定成员号切换模式：

```sql
mysql> SELECT group_replication_switch_to_single_primary_mode('f40395ea-c132-11ee-9249-000c29c00092');
+-----------------------------------------------------------------------------------------+
| group_replication_switch_to_single_primary_mode('f40395ea-c132-11ee-9249-000c29c00092') |
+-----------------------------------------------------------------------------------------+
| Mode switched to single-primary successfully.                                           |
+-----------------------------------------------------------------------------------------+
1 row in set (0.03 sec)

mysql> select * from performance_schema.replication_group_members;
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST    | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 13fc049e-c133-11ee-a377-000c29df1f85 | 192.168.131.20 |        3306 | ONLINE       | SECONDARY   | 8.0.27         | XCom                       |
| group_replication_applier | 248563ac-c133-11ee-a387-000c29551477 | 192.168.131.30 |        3306 | ONLINE       | SECONDARY   | 8.0.27         | XCom                       |
| group_replication_applier | f40395ea-c132-11ee-9249-000c29c00092 | 192.168.131.10 |        3306 | ONLINE       | PRIMARY     | 8.0.27         | XCom                       |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
3 rows in set (0.00 sec)
```

## 14.4 监控组复制

使用MySQL performance_schema数据库相关性能表监控组复制，这些性能表显示特定于组复制的信息。

常用的表有：

- replication_group_members
- replication_group_member_stats

下面详细介绍这三个表。

### 14.4.1 replication_group_members

该表显示了复制组成员的网络和状态信息，所示的网络地址是用于将客户端连接到组的地址。

```sql
mysql> select * from performance_schema.replication_group_members;
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST    | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 13fc049e-c133-11ee-a377-000c29df1f85 | 192.168.131.20 |        3306 | ONLINE       | SECONDARY   | 8.0.27         | XCom                       |
| group_replication_applier | 248563ac-c133-11ee-a387-000c29551477 | 192.168.131.30 |        3306 | ONLINE       | SECONDARY   | 8.0.27         | XCom                       |
| group_replication_applier | f40395ea-c132-11ee-9249-000c29c00092 | 192.168.131.10 |        3306 | ONLINE       | PRIMARY     | 8.0.27         | XCom                       |
+---------------------------+--------------------------------------+----------------+-------------+--------------+-------------+----------------+----------------------------+
3 rows in set (0.00 sec)
```

字段说明：

- **CHANNEL_NAME**：组复制区域通道名称；
- **MEMBER_ID**：成员服务器UUID。对于组中的每个成员都有不同的值。这也可以作为键，因为它对每个成员都是唯一的；
- **MEMBER_HOST**：该成员的网络地址（主机名或IP地址）。从成员的主机名变量中检索。这是客户端连接到的地址，与用于内部组通信的group_replication_local_address不同；
- **MEMBER_PORT**：服务器正在侦听的端口；
- **MEMBER_STATE**：该成员的现状，可以是以下任何一种:
   - ONLINE：成员处于功能完备的状态；
   - RECOVERING：服务器已加入正在从中检索数据的组；
   - OFFLINE：已安装组复制插件，但尚未启动；
   - ERROR：成员在应用事务期间或在恢复阶段遇到错误，并且没有参与组的事务；
   - UNREACHABLE：故障检测进程怀疑无法联系此成员，因为组消息已超时；
- **MEMBER_ROLE**：组中成员的角色，可以是PRIMARY或SECONDARY；
- **MEMBER_VERSION**：成员的MySQL版本；
- **MEMBER_COMMUNICATION_STACK**：用于组的通信栈，XCOM通信栈或MYSQL通信栈。这列是在MySQL 8.0.27中添加的。

### 14.4.2 replication_group_member_stats

此表提供了与认证过程相关的组级信息，以及复制组的每个成员接收和发起的事务的统计信息

```sql
mysql> select * from performance_schema.replication_group_member_stats\G
*************************** 1. row ***************************
                              CHANNEL_NAME: group_replication_applier
                                   VIEW_ID: 17082578864394446:3
                                 MEMBER_ID: 13fc049e-c133-11ee-a377-000c29df1f85
               COUNT_TRANSACTIONS_IN_QUEUE: 0
                COUNT_TRANSACTIONS_CHECKED: 0
                  COUNT_CONFLICTS_DETECTED: 0
        COUNT_TRANSACTIONS_ROWS_VALIDATING: 0
        TRANSACTIONS_COMMITTED_ALL_MEMBERS: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:1-24
            LAST_CONFLICT_FREE_TRANSACTION:
COUNT_TRANSACTIONS_REMOTE_IN_APPLIER_QUEUE: 1
         COUNT_TRANSACTIONS_REMOTE_APPLIED: 1
         COUNT_TRANSACTIONS_LOCAL_PROPOSED: 0
         COUNT_TRANSACTIONS_LOCAL_ROLLBACK: 0
*************************** 2. row ***************************
                              CHANNEL_NAME: group_replication_applier
                                   VIEW_ID: 17082578864394446:3
                                 MEMBER_ID: 248563ac-c133-11ee-a387-000c29551477
               COUNT_TRANSACTIONS_IN_QUEUE: 0
                COUNT_TRANSACTIONS_CHECKED: 0
                  COUNT_CONFLICTS_DETECTED: 0
        COUNT_TRANSACTIONS_ROWS_VALIDATING: 0
        TRANSACTIONS_COMMITTED_ALL_MEMBERS: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:1-24
            LAST_CONFLICT_FREE_TRANSACTION:
COUNT_TRANSACTIONS_REMOTE_IN_APPLIER_QUEUE: 1
         COUNT_TRANSACTIONS_REMOTE_APPLIED: 0
         COUNT_TRANSACTIONS_LOCAL_PROPOSED: 0
         COUNT_TRANSACTIONS_LOCAL_ROLLBACK: 0
*************************** 3. row ***************************
                              CHANNEL_NAME: group_replication_applier
                                   VIEW_ID: 17082578864394446:3
                                 MEMBER_ID: f40395ea-c132-11ee-9249-000c29c00092
               COUNT_TRANSACTIONS_IN_QUEUE: 0
                COUNT_TRANSACTIONS_CHECKED: 0
                  COUNT_CONFLICTS_DETECTED: 0
        COUNT_TRANSACTIONS_ROWS_VALIDATING: 0
        TRANSACTIONS_COMMITTED_ALL_MEMBERS: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:1-24
            LAST_CONFLICT_FREE_TRANSACTION:
COUNT_TRANSACTIONS_REMOTE_IN_APPLIER_QUEUE: 0
         COUNT_TRANSACTIONS_REMOTE_APPLIED: 3
         COUNT_TRANSACTIONS_LOCAL_PROPOSED: 0
         COUNT_TRANSACTIONS_LOCAL_ROLLBACK: 0
3 rows in set (0.01 sec)
```

字段说明：

- **CHANNEL_NAME**：channel名；
- **VIEW_ID**：组视图id；
- **MEMBER_ID**：成员uuid；
- **COUNT_TRANSACTIONS_IN_QUEUE**：等待冲突检测检查的队列中的事务数；
- **COUNT_TRANSACTIONS_CHECKED**：已检查冲突的事务数；
- **COUNT_CONFLICTS_DETECTED**：未通过冲突检测检查的事务数；
- **COUNT_TRANSACTIONS_ROWS_VALIDATING**：冲突检测数据库当前的记录数；
- **TRANSACTIONS_COMMITTED_ALL_MEMBERS**：在组复制的所有成员上成功提交的事务，显示为GTID集。这是以固定60s的时间间隔更新的；
- **LAST_CONFLICT_FREE_TRANSACTION**：最后一次检查的无冲突事务的GTID；
- **COUNT_TRANSACTIONS_REMOTE_IN_APPLIER_QUEUE**：成员从复制组接收到等待应用的事务数；
- **COUNT_TRANSACTIONS_REMOTE_APPLIED**：成员从复制组接收到已经应用的事务数；
- **COUNT_TRANSACTIONS_LOCAL_PROPOSED**：由该成员发起，并发送到组的事务数；
- **COUNT_TRANSACTIONS_LOCAL_ROLLBACK**：由该成员发起，，并由组回滚的事务数。

# 15 InnoDB Cluster

# 16 监控

## 16.1 PMP

[PMP](/zabbix/percona-zabbix-templates.md)

## 16.2 PMM

[PMM](/Database-Administrator/MySQL/monitoring/PMM/pmm.md)

## 16.3 MySQL常用监控指标

# 17 MySQL优化

# 18 基准测试工具

## 18.1 mysqlslap

**1）创建mytest数据库和mytest表，测试数据是向表中插入一条记录并进行一次查询，并发50个客户端，重复执行200次。** 

```bash
[mysql@mysql001 ~]$ mysqlslap -uroot -pMysql123. --create-schema=mytest --delimiter=";" --create="create table mytest(id int not null auto_increment primary key,c1 varchar(255))" --query="insert into mytest(c1) values(md5(rand()));select c1 from mytest;" --concurrency=50 --iterations=200;

Benchmark
        Average number of seconds to run all queries: 0.050 seconds
        Minimum number of seconds to run all queries: 0.017 seconds
        Maximum number of seconds to run all queries: 0.409 seconds
        Number of clients running queries: 50
        Average number of queries per client: 2
```

**2）两次读写并发，第一次100，第二次200，自动生成SQL脚本，测试表包含20个init字段，30个char字段，每次执行2000查询请求。测试引擎分别是myisam，innodb。**

```bash
[mysql@mysql001 binlog]$ mysqlslap -uroot -pMysql123. --concurrency=100,200 --iterations=1 --number-int-cols=20 --number-char-cols=30 --auto-generate-sql --auto-generate-sql-add-autoincrement --auto-generate-sql-load-type=mixed --engine=innodb --number-of-queries=2000 --verbose;
mysqlslap: [Warning] Using a password on the command line interface can be insecure.
Benchmark
        Running for engine innodb
        Average number of seconds to run all queries: 0.721 seconds
        Minimum number of seconds to run all queries: 0.721 seconds
        Maximum number of seconds to run all queries: 0.721 seconds
        Number of clients running queries: 100
        Average number of queries per client: 20

Benchmark
        Running for engine innodb
        Average number of seconds to run all queries: 0.804 seconds
        Minimum number of seconds to run all queries: 0.804 seconds
        Maximum number of seconds to run all queries: 0.804 seconds
        Number of clients running queries: 200
        Average number of queries per client: 10
```

# 19 数据迁移

迁移步骤：

1. 迁移前检查，数据库对象检查，包括表、视图、存储过程、事件、函数、用户、触发器等；
2. 停系统相关服务；
3. 确保业务系统无法连接老数据库，做法可以是删除vip，修改连接配置或者再加上修改连接用户密码。
4. 中断原来系统的业务连接；
5. 备份老库，小库用逻辑备份mysqldump，大库可以用物理备份PXB；
6. 将备份文件传到新库；
7. 删除新库的测试数据；
8. 将数据恢复到新库，如果有从库，从库也要同步恢复；
9. 数据校验，比对新老库的对象、表数据量、用户权限是否一致；
10. 如果是集群，需要恢复主从同步；
11. 主从数据对比；
12. 应用服务配置新库连接地址；
13. 启动应用；
14. 验证业务。

如果出现问题，无法在短时间内解决，可以考虑回退：终止变更。

回退风险：如果新库已经有新数据产生，此时需要回退，无法单方面通过数据层进行回退。

## 19.1 离线



## 19.2 在线