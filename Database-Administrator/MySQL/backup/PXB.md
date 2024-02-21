备份脚本：

```bash
vi /home/mysql/scripts/backup.sh

#!/bin/bash

echo ""
START_TIME=`date`
echo "############## backup start at $START_TIME ##############"
echo ""
###you need install xtrabackup!###
# Set env
source /home/mysql/.bash_profile
which xtrabackup
# Database Info
DB_USER="root"
DB_PASS="jeames@123"
CONF="/data/mysqldb/conf/mysql.conf"
SOCKET="/data/mysqldb/socket/mysql.sock"
BAK_BASE="/db_bak/mysql_bak/mysql"
DATE=`date +%F`
YESTERDAY=`date +%F -d "-1 days"`
WEEK_DAY=`date +%w`
BAK_DIR=$BAK_BASE/$DATE-$WEEK_DAY
# Create Directory and backup
if [ "$WEEK_DAY" == "6"  ]; then
  xtrabackup --defaults-file=$CONF --socket=$SOCKET --backup --user=$DB_USER --password=$DB_PASS --target-dir=$BAK_DIR --compress
elif [ "$WEEK_DAY" == "0"  ]; then
  INCRE_BASE=$BAK_BASE/$YESTERDAY-6
  xtrabackup --defaults-file=$CONF --socket=$SOCKET --backup --user=$DB_USER --password=$DB_PASS --target-dir=$BAK_DIR --incremental-basedir=$INCRE_BASE --compress
else
  INCRE_BASE=$BAK_BASE/$YESTERDAY-$[WEEK_DAY-1]
  xtrabackup --defaults-file=$CONF --socket=$SOCKET --backup --user=$DB_USER --password=$DB_PASS --target-dir=$BAK_DIR --incremental-basedir=$INCRE_BASE --compress
fi
echo ""
END_TIME=`date`
echo "############## backup end at $END_TIME ##############"
echo ""
```

备份清理脚本：

```bash
vi  /home/mysql/scripts/cleanup.sh
#!/bin/bash

echo ""
START_TIME=`date`
echo "############## clean up start at $START_TIME ##############"
echo ""

find /db_bak/mysql_bak/mysql -maxdepth 1 -type d -mtime +30
find /db_bak/mysql_bak/mysql -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;

echo ""
END_TIME=`date`
echo "############## clean up end at $END_TIME ##############"
echo ""
```

定时任务：

运行脚本
每天凌晨 4:10 分清理 30 天之前的备份，
每天 4:30 分使用 xtrabackup 进行备份，
注意只有周六是全备，其他时间均是增备。

```bash

#crontab -e
10 4 * * * /home/mysql/scripts/cleanup.sh >> /home/mysql/scripts/cleanup.log 2>&1
30 4 * * * /home/mysql/scripts/backup.sh >> /home/mysql/scripts/backup.log 2>&1
```