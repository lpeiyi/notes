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
[root@lu9up ~]# ls
anaconda-ks.cfg  mysql-8.0.34-1.el7.x86_64.rpm-bundle.tar
```

**三、预安装**

Installation Prerequisites
The installation must be performed as an operating system root user, as the installation process involves creating a user, a group, directories, and assigning ownership and permissions. Installed MySQL binaries are owned by the operating system root user.

Note
Unless otherwise indicated, procedures in this guide are performed as the operating system root user.

MySQL has a dependency on the libaio library. Data directory initialization and subsequent server startup steps fail if this library is not installed locally. If necessary, install it using the appropriate package manager. For example, on Yum-based systems:

$> yum search libaio  # search for info
$> yum install libaio # install library
Oracle Linux 8 does not install the file /lib64/libtinfo.so.5 by default, which is required by the MySQL client bin/mysql for mysql-VERSION-linux-glibc2.12-x86_64.tar.xz packages. To work around this issue, install the ncurses-compat-libs package:

$> yum install ncurses-compat-libs

**四、Creating the mysql User and Group**

he mysql user owns the MySQL data directory. It is also used to run the mysqld server process, as defined in the systemd mysqld.service file (see Starting the Server using systemd). The mysql user has read and write access to anything in the MySQL data directory. It does not have the ability to log into MySQL. It only exists for ownership purposes.

The mysql group is the database administrator group. Users in this group have read and write access to anything in the MySQL data directory, and execute access on any packaged MySQL binary.

This command adds the mysql group.

```bash
[root@lu9up ~]# groupadd -g 27 mysql
[root@lu9up ~]# useradd -g mysql mysql
[root@lu9up mysql]# passwd mysql
```

**五、解压**

```bash
[root@lu9up ~]# tar -xvf mysql-8.0.34-1.el7.x86_64.rpm-bundle.tar -C /home/mysql/
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

六、

```sql
[mysql@lu9up ~]$ sudo yum install mysql-community-{server,client,client-plugins,icu-data-files,common,libs}-*
```

七、启动mysql服务

```bash
[mysql@lu9up ~]$ sudo systemctl start mysqld
```
八、查看临时密码

[mysql@lu9up ~]$ sudo grep 'temporary password' /var/log/mysqld.log
2023-12-10T17:32:22.685442Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: u*0>WAdj-<l-


九、登录并修改密码

[mysql@lu9up ~]$ mysql -uroot -p'u*0>WAdj-<l-'

mysql> set password = 'Lu9up123.';
Query OK, 0 rows affected (0.01 sec)

[mysql@lu9up ~]$ mysql -uroot -pLu9up123.


### 1.1.2 二进制文件安装

## 1.2 升级

## 1.3 