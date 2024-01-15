# 1 备份

# 2 恢复

**一、数据库备份恢复过程中的报错：ERROR 3546 (HY000) at line 24: @@GLOBAL.GTID_PURGED cannot be changed: the added gtid set must not overlap with @@GLOBAL.GTID_EXECUTED**

```bash
重新dump数据库，使用 --set-gtid-purged=off的参数禁止导出gtid信息，再load进目标数据库。

mysqldump -uroot -p --set-gtid-purged=off slowtech t1 > slowtech.t1.sql
```

# 3 binlog

mysql磁盘空间满，导致挂库

可以先临时清理binlog释放空间，启动库，后续再挂新盘

没有主从，binlog可以随便删，删除完改一下index文件，然后在启动就好了 binlog只会影响主从和下游同步用，其他的并没有啥影响

删除binlog：

https://www.modb.pro/db/606883


![Alt text](fdba50eb6e13fe13e854485016fbc9b.png)