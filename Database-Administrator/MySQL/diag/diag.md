mysql磁盘空间满，导致挂库

可以先临时清理binlog释放空间，启动库，后续再挂新盘

没有主从，binlog可以随便删，删除完改一下index文件，然后在启动就好了 binlog只会影响主从和下游同步用，其他的并没有啥影响

删除binlog：

https://www.modb.pro/db/606883


![Alt text](fdba50eb6e13fe13e854485016fbc9b.png)