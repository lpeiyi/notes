# 0 mysql备份最佳实践

- 使用xtrabackup进行物理备份
- 使用mydumper进行逻辑备份（支持并行逻辑备份恢复）
- 备份文件存储本地 或则 介质为NFS
- 使用binlog2sql进行闪回恢复.
- 对于重要系统，可以使用延迟从库进行备份恢复


# 1 mysqldump

## 1.1 全量备份

**一、创建备份文件目录**

```bash
su - mysql
cd /home/mysql;mkdir bak;cd bak;mkdir full;touch full.log;
```

**二、全量备份脚本**

```bash
vim mysql_fullbak.sh
```
```bash
#!/bin/bash
#mysqldump to fully backup mysql data per week.

#parameters
source /etc/profile
bakdir=/home/mysql/bak/full
logfile=/home/mysql/bak/full.log
date=`date '+%Y%m%d'`
dumpfile=full${date}.sql
gzdumpfile=${dumpfile}.tar.gz
user=root
pwd=xxx

echo -e "\n***************************** `date '+%F %T'` *****************************" >> $logfile
echo -e "user=${user} \nbakdir=${bakdir} \nlogfile=${logfile} \ngzdumpfile=${gzdumpfile}" >> $logfile

#backup
cd $bakdir
echo -e "[`date '+%F %T'`] begin fully backup" >> $logfile

echo -e "[`date '+%F %T'`] mysqldump -u$user -p --all_databases --quick --events --flush-logs --delete-master-logs --single-transaction > $dumpfile" >> $logfile
mysqldump -u$user -p$pwd --all_databases --quick --events --flush-logs --delete-master-logs --single-transaction > $dumpfile

echo -e "[`date '+%F %T'`] complete fully backup" >> $logfile

#compressed dumpfile
echo -e "[`date '+%F %T'`] tar -zcvf ${gzdumpfile} ${dumpfile}" >> $logfile
tar -zcvf ${gzdumpfile} ${dumpfile}
echo -e "[`date '+%F %T'`] rm ${dumpfile}" >> logfile
rm $dumpfile

#delete expired file
epdate=`date -d '7 days ago' '+%Y%m%d'`
epfile=${epdate}.sql.tar.gz
if [ -f "${epfile}" ];then
    echo -e "[`date '+%F %T'`] rm ${epfile}" >> $logfile
    rm $epfile
else
    echo -e "[`date '+%F %T'`] '${epfile} was not deleted because it did not exist'" >> $logfile
fi

echo -e "**********************************************************\n" >> $logfile
```





## 1.2 增量备份

**一、创建备份文件目录**

```bash
cd /home/mysql/bak;mkdir inc;touch inc.log;
```

## 1.3 定时任务

## 1.4 恢复方法