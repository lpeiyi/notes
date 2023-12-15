# 1 安装

```bash
[root@pg01 ~]# groupadd -g 1000 postgres
[root@pg01 ~]# useradd -u 1000 -g 1000 postgres
[root@pg01 ~]# passwd postgres

# 关闭 selinux：
vi /etc/selinux/config
把 SELINUX=enforcing 改为 SELINUX=disabled

setenforce 0

# 关闭防火墙：
systemctl status firewalld.service
systemctl stop firewalld.service
systemctl disable firewalld.service

# 关闭 NetworkManager：
systemctl stop NetworkManager
systemctl disable NetworkManager

# Install the repository RPM:
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm


# Install PostgreSQL:
sudo yum install -y postgresql14-server

# 修改环境变量：
sudo vim /etc/profile
export PATH=/usr/pgsql-14/bin/:$PATH
source /etc/profile

# Optionally initialize the database and enable automatic start:
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable postgresql-14
sudo systemctl start postgresql-14
```

初始化后生成的目录是 /var/lib/pgsql/14，参数文件在 /var/lib/pgsql/14/data/postgresql.conf