# 1 Percona Toolkit

# 2 Installing Percona Toolkit

**1）上传tar包到指定目录，并解压**

```bash
[mysql@mysql001 percona-toolkit]$ ll
-rw-r--r-- 1 root  root  5581172 Jan 21 15:57 percona-toolkit-3.0.1.tar.gz

[mysql@mysql001 percona-toolkit]$ tar -xf percona-toolkit-3.0.1.tar.gz
[mysql@mysql001 percona-toolkit]$ ll
total 5456
drwxrwxr-x 5 mysql mysql    4096 Feb 19  2017 percona-toolkit-3.0.1
-rw-r--r-- 1 root  root  5581172 Jan 21 15:57 percona-toolkit-3.0.1.tar.gz
```

**2）配置环境变量**

执行文件都在bin目录下：

```bash
[mysql@mysql001 percona-toolkit-3.0.1]$ cd bin/
[mysql@mysql001 bin]$ pwd
/home/mysql/tools/percona-toolkit/percona-toolkit-3.0.1/bin
[mysql@mysql001 bin]$ ls
pt-align            pt-duplicate-key-checker  pt-heartbeat    pt-mongodb-query-digest  pt-query-digest  pt-slave-restart   pt-table-usage
pt-archiver         pt-fifo-split             pt-index-usage  pt-mongodb-summary       pt-show-grants   pt-stalk           pt-upgrade
pt-config-diff      pt-find                   pt-ioprofile    pt-mysql-summary         pt-sift          pt-summary         pt-variable-advisor
pt-deadlock-logger  pt-fingerprint            pt-kill         pt-online-schema-change  pt-slave-delay   pt-table-checksum  pt-visual-explain
pt-diskstats        pt-fk-error-logger        pt-mext         pt-pmp                   pt-slave-find    pt-table-sync
```

```bash
[mysql@mysql001 bin]$ sudo vim /etc/profile
#添加
export PERCONA_TOOLKIT_HOME=/home/mysql/tools/percona-toolkit/percona-toolkit-3.0.1
export PATH=$PATH:$PERCONA_TOOLKIT_HOME/bin

[mysql@mysql001 bin]$ sudo source /etc/profile
```

**3）创建数据库和用户**

```sql
create database percona;
create user percona@localhost identified by Percona123.
GRANT SELECT, PROCESS, SUPER ON *.* TO percona@localhost
GRANT SYSTEM_VARIABLES_ADMIN ON *.* TO percona@localhost
GRANT ALL PRIVILEGES ON percona.* TO percona@localhost
```

# 3 pt-table-checksum

## 3.1 实现原理

## 3.2 常见用法

**1）检查整个实例**

```bash
[mysql@mysql001 bin]$ pt-table-checksum h=localhost,P=3306,u=percona,p=Percona123. --no-check-binlog-format
```

**2）检查指定库**

```basg
[mysql@mysql001 bin]$ pt-table-checksum h=localhost,P=3306,u=percona,p=Percona123. --no-check-binlog-format --databases sakila,test
```

**3）检查指定表**

```bash
[mysql@mysql001 bin]$ pt-table-checksum h=localhost,P=3306,u=percona,p=Percona123. --no-check-binlog-format --tables sakila.actor,test.demo
```