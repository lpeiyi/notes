# 目录

[TOC]

# 说明

这篇文章详细介绍了如何基于Vmware Workstation Pro搭建Oracle 19c RAC，官方参考文档《[Real Application Clusters Installation Guide for Linux and UNIX](https://docs.oracle.com/en/database/oracle/oracle-database/19/rilin/index.html#Oracle%C2%AE-Real-Application-Clusters)》，《[Grid Infrastructure Installation and Upgrade Guide for Linux](https://docs.oracle.com/en/database/oracle/oracle-database/19/cwlin/index.html#Oracle%C2%AE-Grid-Infrastructure)》。

本文包含以下章节：

1. 环境规划；
2. 准备工作；
3. 服务器基本配置；
4. 克隆节点1到节点2；
5. 搭建共享磁盘；
6. 安装grid软件；
7. 安装oracle软件；
8.  创建数据库。

**注意**：1至3章节只需在1节点进行，第4章节通过克隆节点1创建节点2，可以减少很多重复性工作。

# 1 环境规划

**节点和路径规划**：

| 配置项 |  节点1 |  节点2 |
|-|-|-|
| OS | Oracle Linux 7.9 | Oracle Linux 7.9 |
| 主机名 | lu9up01 | lu9up02 |
| Public IP | 192.168.131.101 | 192.168.131.102 |
| Private IP | 192.168.136.201 lu9up01-priv | 192.168.136.202 lu9up02-priv |
| Virtual IP |  192.168.131.103 lu9up01-vip | 192.168.131.104 lu9up02-vip |
| oracle用户ORACLE_HOME | /u01/app/oracle/product/19.0.0/db_1 | /u01/app/oracle/product/19.0.0/db_1 |
| oracle用户ORACLE_SID | racdb1 | racdb2 |
| grid用户ORACLE_HOME | /u01/app/19.0.0/grid | /u01/app/19.0.0/grid |
| grid用户ORACLE_SID | +ASM1 | +ASM2 |

**空间规划**：

| DiskGroup |  单盘容量 |  数量 | 冗余方式 | 最终可用 |
|-|-|-|-|-|
| DATA | 8 | 4 | External | 32 |
| FRA | 8 | 4 | External | 32 |


注意：以上配置按个人情况所需进行调整。

# 2 准备工作

**一、资源下载**

1. Oracle Linux 7.9 ISO
   
   https://yum.oracle.com/oracle-linux-isos.html

    ![](image/2.2.2.png)

2. Oracle Database 19c Grid Infrastructure (19.3) for Linux x86-64
   
   https://www.oracle.com/database/technologies/oracle19c-linux-downloads.html

   ![](image/2.2.3.png)

**二、安装Oracle Linux 7.9**

参考配置：

![Alt text](image/image-13.png)

# 3 服务器基本配置

## 3.1 系统要求

官方文档参考：[Operating System Checklist](https://docs.oracle.com/en/database/oracle/oracle-database/19/cwlin/operating-system-checklist-for-oracle-grid-infrastructure-and-oracle-rac.html)

![Alt text](image/image-8.png)

```bash
[root@lu9up01 ~]# cat /etc/redhat-release
Red Hat Enterprise Linux Server release 7.9 (Maipo)
[root@lu9up01 ~]# uname -a
Linux lu9up01 5.4.17-2102.201.3.el7uek.x86_64 #2 SMP Fri Apr 23 09:05:55 PDT 2021 x86_64 x86_64 x86_64 GNU/Linux
```

Linux 7的内核版本需要大于等于Red Hat Enterprise Linux 7.5: 3.10.0-862.11.6.el7.x86_64。

## 3.2 网卡

需要两张网卡，而且网卡要设置为静态IP地址。这里，我配置了Host-Only加NAT模式，参考文章《Linux网络配置》https://www.modb.pro/db/1719973817177694208

ip地址根据[1-环境规划](#1-环境规划)分配。

![Alt text](image/image-11.png)

![Alt text](image/image-12.png)

参考配置：

```bash
[root@lu9up01 ~]# cat /etc/sysconfig/network-scripts/ifcfg-ens33
#NAT
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="static"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33"
UUID="bd12aaca-b29c-4ef0-bb92-a82aa29672e9"
DEVICE="ens33"
ONBOOT="yes"
IPADDR=192.168.131.101
NETMASK=255.255.255.0
GATEWAY=192.168.131.2
DNS1=192.168.131.2
[root@lu9up01 ~]# cat /etc/sysconfig/network-scripts/ifcfg-ens36
#Host-Only
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="static"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens36"
#UUID="bd12aaca-b29c-4ef0-bb92-a82aa29672e9"
DEVICE="ens36"
ONBOOT="yes"
IPADDR=192.168.136.201
NETMASK=255.255.255.0
```

注意：Host-Only不需要配置网关和域名服务器。

## 3.3 修改host文件

一、在/etc/hosts文件追加以下配置：

```bash
# public IP
192.168.131.101 lu9up01
192.168.131.102 lu9up02
# private IP
192.168.136.201 lu9up01-priv
192.168.136.202 lu9up02-priv
# virtual IP
192.168.131.103 lu9up01-vip
192.168.131.104 lu9up02-vip
# scan
192.168.131.105 lu9up-scan
```

二、修改主机名，在/etc/hostname文件追加以下配置：

```bash
lu9up01
```
      
## 3.4 内存

官方文档参考：[Server Hardware Checklist](https://docs.oracle.com/en/database/oracle/oracle-database/19/cwlin/server-hardware-checklist-for-oracle-grid-infrastructure.html)

![](image/image-7.png)

Oracle Grid Infrastructure安装的至少8GB。

```bash
[root@lu9up01 ~]# free
              total        used        free      shared  buff/cache   available
Mem:        7856972      160192     7551408        8940      145372     7483348
Swap:       8388604           0     8388604
```

## 3.5 Swap空间 

官方文档参考：[Server Configuration Checklist](https://docs.oracle.com/en/database/oracle/oracle-database/19/cwlin/server-configuration-checklist-for-oracle-grid-infrastructure.html)

![Alt text](image/image-9.png)

内存在4 GB到16 GB之间：等于RAM
内存大于16 GB：16 GB

```bash
[root@lu9up01 ~]# free
              total        used        free      shared  buff/cache   available
Mem:        7856972      160172     7551408        8940      145392     7483356
Swap:       8388604           0     8388604
[root@lu9up01 ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sr0     11:0    1  4.5G  0 rom
sda      8:0    0   50G  0 disk
├─sda2   8:2    0    8G  0 part [SWAP]
├─sda3   8:3    0   41G  0 part /
└─sda1   8:1    0    1G  0 part /boot
```

## 3.6 共享内存段 /dev/shm/

共享内存段至少要大于MEMORY_MAX_TARGET and MEMORY_TARGET。如果sga 共享内存的大小超过了/dev/shm 的大小，启动数据库的时候，可能会出现`ORA-00845: MEMORY_TARGET not supported on this system`。解决方法有两个，一个是减少 sga 的大小，另外一个是增加/dev/shm 的大小。

```bash
[root@lu9up01 ~]# df -h /dev/shm/
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           3.8G     0  3.8G   0% /dev/shm
```

## 3.7 禁用透明大页

参考官方文档：[Disabling Transparent HugePages](https://docs.oracle.com/en/database/oracle/oracle-database/19/cwlin/disabling-transparent-hugepages.html#GUID-02E9147D-D565-4AF8-B12A-8E6E9F74BEEA)


一、查看透明大页状态：

```bash
[root@lu9up01 ~]# cat /sys/kernel/mm/transparent_hugepage/defrag
always defer defer+madvise [madvise] never
[root@lu9up01 ~]# cat /sys/kernel/mm/transparent_hugepage/enabled
[always] madvise never
```

[always] never 说明是启用的状态。

二、对于Oracle Linux 7及以上版本，以及Red Hat Enterprise Linux 7及以上版本，在/etc/default/grub文件中添加或修改transparent_hugepage=never参数:

```bash
[root@lu9up01 Nov-05-2023-04-38-18]# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet numa=off transparent_hugepage=never"
GRUB_DISABLE_RECOVERY="true"
```

三、执行grub2-mkconfig命令重新生成“grub.cfg”文件:

```bash
[root@lu9up01 rc.d]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-5.4.17-2102.201.3.el7uek.x86_64
Found initrd image: /boot/initramfs-5.4.17-2102.201.3.el7uek.x86_64.img
Found linux image: /boot/vmlinuz-3.10.0-1160.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-1160.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-8a434875a2db451e8e2942132ede331f
Found initrd image: /boot/initramfs-0-rescue-8a434875a2db451e8e2942132ede331f.img
done
```

四、重新启动系统以使更改永久生效。
```bash
[root@lu9up01 rc.d]# reboot

[root@lu9up01 ~]# cat /sys/kernel/mm/transparent_hugepage/defrag
always defer defer+madvise [madvise] never
[root@lu9up01 ~]# cat /sys/kernel/mm/transparent_hugepage/enabled
always madvise [never]
```

好像并没有用！！

五、修改/etc/rc.d/rc.local文件。

追加以下配置：

```bash
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
```

六、赋权/etc/rc.d/rc.local文件，重启服务器。

```bash
[root@lu9up01 rc.d]# chmod 775 /etc/rc.d/rc.local
[root@lu9up01 rc.d]# ll /etc/rc.d/rc.local
-rwxrwxr-x. 1 root root 714 Nov  5 16:19 /etc/rc.d/rc.local

[root@lu9up01 rc.d]# reboot
```

查看状态：

```bash
[root@lu9up01 rc.d]# reboot

[root@lu9up01 ~]# cat /sys/kernel/mm/transparent_hugepage/defrag
always defer defer+madvise madvise [never]
[root@lu9up01 ~]# cat /sys/kernel/mm/transparent_hugepage/enabled
always madvise [never]
```
always madvise [never] 说明是禁用的。

## 3.8 关闭防火墙

```bash
[root@lu9up01 ~]# systemctl stop firewalld
[root@lu9up01 ~]# systemctl disable firewalld
Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service.
Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
[root@lu9up01 ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)

Nov 05 02:52:59 lu9up01 systemd[1]: Starting firewalld - dynamic firewall daemon...
Nov 05 02:52:59 lu9up01 systemd[1]: Started firewalld - dynamic firewall daemon.
Nov 05 02:52:59 lu9up01 firewalld[697]: WARNING: AllowZoneDrifting is enabled. This is cons...ow.
Nov 05 02:55:59 lu9up01 systemd[1]: Stopping firewalld - dynamic firewall daemon...
Nov 05 02:55:59 lu9up01 systemd[1]: Stopped firewalld - dynamic firewall daemon.
Hint: Some lines were ellipsized, use -l to show in full.

```

## 3.9 配置网络yum或者网络yum(可不做，centos有默认官方源)

默认的yum源的速度可能很慢，使用本地光盘（iso文件）做yum源速度可以得到保证。

一、挂载本地yum

1. 上传iso文件
   ```bash
   [root@lu9up01 yum.repos.d]# mkdir -p /tmp/media/
   
   上传本地光盘到此路径。

   [root@lu9up01 media]# mv /tmp/media/OracleLinux-R7-U9-Server-x86_64-dvd.iso /tmp/media/ol7.9x86_64.iso
   [root@lu9up01 media]# ls /tmp/media/
   ol7.9x86_64.iso
   ```
2. 创建iso挂载路径
   ```bash
   [root@lu9up01 ~]# mkdir /mnt/cdrom
   ```
3. 挂载iso
   ```bash
   [root@lu9up01 ~]# mount /tmp/media/ol7.9x86_64.iso /mnt/cdrom
   mount: /dev/loop0 is write-protected, mounting read-only
   [root@lu9up01 media]# lsblk
   NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   sr0     11:0    1  4.5G  0 rom
   loop0    7:0    0  4.5G  0 loop /mnt/cdrom
   sda      8:0    0   60G  0 disk
   ├─sda2   8:2    0   12G  0 part [SWAP]
   ├─sda3   8:3    0   47G  0 part /
   └─sda1   8:1    0    1G  0 part /boot
   ```
4. 创建server.repo
   ```bash
   [root@lu9up01 ~]# cd /etc/yum.repos.d/
   [root@lu9up01 yum.repos.d]# ls
   oracle-linux-ol7.repo  uek-ol7.repo  virt-ol7.repo
   [root@lu9up01 yum.repos.d]# mkdir bak
   [root@lu9up01 yum.repos.d]# ll
   total 0
   drwxr-xr-x. 2 root root 76 Nov  5 04:27 bak
   [root@lu9up01 yum.repos.d]# vi server.repo
   [root@lu9up01 yum.repos.d]# cat server.repo
   [server]
   name=Red Hat Enterprise Linux
   baseurl=file:///mnt/cdrom
   enabled=1
   gpgcheck=0
   ```

二、挂载网络yum

创建server.repo
```bash
[root@lu9up01 yum.repos.d]# vi ol-base.repo
[root@lu9up01 yum.repos.d]# cat ol-base.repo
[base]
name= yum repo
baseurl=http://mirrors.aliyun.com/centos/7/os/$basearch/
enabled=1
gpgcheck=0
```
三、测试一下配置的yum

```bash
[root@lu9up01 yum.repos.d]# yum repolist
Loaded plugins: ulninfo
repo id                      repo name                                  status
base/x86_64                  yum repo                                   10,072
server                       Red Hat Enterprise Linux                    5,210
repolist: 15,282
```

四、安装oracle依赖包

```bash
[root@lu9up01 ~]# yum install -y compat-libcap1
[root@lu9up01 ~]# yum install -y readline*
[root@lu9up01 ~]# yum install -y autoconf automake
[root@lu9up01 ~]# yum install -y compat-libstdc++-33.i686 compat-libstdc++-33.x86_64
[root@lu9up01 ~]# yum install -y gcc gcc-c++ glibc.i686 glibc.x86_64 glibc-devel glibc-devel.i686 libaio libaio-devel libgcc.i686 libgcc.x86_64 libstdc++.i686 libstdc++.x86_64 libstdc++-devel dejavu-serif-fonts ksh make sysstat numactl numactl-devel motif motif-devel redhat-lsb redhat-lsb-core OpenSSL
```

## 3.10 安装原装包oracle-database-preinstall-19c

参考官方文档：[Automatically Configuring Oracle Linux with Oracle Database Preinstallation RPM](https://docs.oracle.com/en/database/oracle/oracle-database/19/cwlin/automatically-configuring-oracle-linux-with-oracle-preinstallation-rpm.html#GUID-22846194-58EF-4552-AAC3-6F6D0A1DF794)

Oracle数据库预安装RPM会执行以下操作：

![Alt text](image/image-10.png)

1. 下载并安装安装 Oracle Grid Infrastructure 和 Oracle Database所需的任何附加 RPM 软件包，并解决任何依赖关系；
2. 创建一个oracle用户，并为oracle用户创建oinstall和dba组；
3. 根据建议，设置sysctl.conf，系统启动参数和驱动程序参数；
4. 设置硬资源和软资源限制；
5. 根据用户的内核版本，设置其他推荐参数；
6. 在Linux x86_64和Linux aarch64机器的内核中设置numa=off。


一、安装：
```bash
[root@lu9up01 yum.repos.d]# yum search oracle-database-preinstall-19c
[root@lu9up01 yum.repos.d]# yum install oracle-database-preinstall-19c -y
```

二、查看安装日志：
```basg
[root@lu9up01 ~]# cat /var/log/oracle-database-preinstall-19c/backup/timestamp/orakernel.log
```

注意：修改`timestamp`为你安装的日期。

```bash
[root@lu9up01 ~]# id oracle
uid=54321(oracle) gid=54321(oinstall) groups=54321(oinstall),54322(dba),54323(oper),54324(backupdba),54325(dgdba),54326(kmdba),54330(racdba)
```
oracle用户和组已创建。

## 3.11 创建Grid和Oracle的用户和组

由于预安装包只创建了oracle用户，而RAC还需要grid用户。

```bash
groupadd -g 54327 asmdba
groupadd -g 54328 asmoper
groupadd -g 54329 asmadmin
groupadd -g 982 vboxsf
usermod -a -G asmdba,backupdba,dgdba,kmdba,racdba,oper,vboxsf oracle
useradd -u 54322 -g oinstall -G asmadmin,asmdba,asmoper,dba,racdba,vboxsf grid
passwd grid
passwd oracle
```

## 3.12 创建Grid和Oracle的安装目录

```bash
mkdir -p /u01/app/19.0.0/grid
mkdir -p /u01/app/grid
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oracle/product/19.0.0/db_1
chown -R grid:oinstall /u01
chown -R oracle:oinstall /u01/app/oracle
chmod -R 775 /u01/
```

## 3.13 创建环境变量

**注意：**  
1.切换到对应用户；
2.修改保存后执行`source ~/.bash_profile`生效。

一、grid用户：/home/grid/.bash_profile
```bash
export LANG=en_US
export ORACLE_SID=+ASM1
export ORACLE_TERM=xterm
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=/u01/app/19.0.0/grid
export NLS_DATE_FORMAT="yyyy-mm-dd HH24:MI:SS"
export PATH=.:$PATH:$HOME/bin:$ORACLE_HOME/bin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/jlib
```

二、oracle用户：/home/oracle/.bash_profile
```bash
export LANG=en_US
export ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
export ORACLE_HOME=$ORACLE_BASE/product/19.0.0/db_1
export ORACLE_SID=racdb1
export ORACLE_TERM=xterm
export NLS_DATE_FORMAT="yyyy-mm-dd HH24:MI:SS"
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export PATH=.:$PATH:$HOME/bin:$ORACLE_HOME/bin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/lib:$ORACLE_HOME/rdbms/jlib
```

三、root用户：/root/.bash_profile
```bash
export PATH=$PATH:/u01/app/19.0.0/grid/bin:$HOME/bin
```

## 3.14 关闭selinux

修改/etc/selinux/config文件，把SELINUX=enforcing改为SELINUX=disabled。

```bash
[root@lu9up01 ~]# getenforce
Enforcing

[root@lu9up01 ~]# vi /etc/selinux/config
 把 SELINUX=enforcing 改为 SELINUX=disabled

[root@lu9up01 ~]# setenforce 0
[root@lu9up01 ~]# getenforce
Permissive
```
      
## 3.15 设置时区

```bash
[root@lu9up01 ~]# timedatectl list-timezones | grep Shanghai
Asia/Shanghai
[root@lu9up01 ~]# timedatectl set-timezone Asia/Shanghai
[root@lu9up01 ~]# timedatectl
      Local time: Sun 2023-11-05 03:03:30 CST
  Universal time: Sat 2023-11-04 19:03:30 UTC
        RTC time: Sat 2023-11-04 19:03:30
       Time zone: Asia/Shanghai (CST, +0800)
     NTP enabled: n/a
NTP synchronized: no
 RTC in local TZ: no
      DST active: n/a
```

## 3.16 配置时间同步

禁用ntp服务，使用rac自带的Oracle集群时间同步服务。Oracle集群时间同步服务是为集群服务器无法访问NTP服务的组织而设计的。

禁用ntp服务的方法是删除配置文件：

```bash
[root@lu9up01 ~]# systemctl stop chronyd
[root@lu9up01 ~]# systemctl disable chronyd
[root@lu9up01 ~]# mv /etc/chrony.conf /etc/chrony.conf.bk
```
      
## 3.17 停止 avahi-daemon 服务

```bash
[root@lu9up01 ~]# systemctl disable avahi-daemon.socket
[root@lu9up01 ~]# systemctl disable avahi-daemon.service
```
      
## 3.18 修改20-nproc.conf

```bash
[root@lu9up01 ~]# vim /etc/security/limits.d/20-nproc.conf
 把 * soft nproc 4096 改为 * soft nproc 16384 。

[root@lu9up01 ~]# ulimit -u
16384
```

## 3.19 修改limits.conf

修改/etc/security/limits.conf，追加以下内容：

```bash
#ORACLE SETTING
grid soft nproc 16384
grid hard nproc 16384
grid soft nofile 1024
grid hard nofile 65536
grid soft stack 10240
grid hard stack 32768
oracle soft nproc 16384
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
oracle soft stack 10240
oracle hard stack 32768
oracle hard memlock 3145728
oracle soft memlock 3145728
```

# 4 克隆节点1到节点2

创建完整克隆，克隆后启动。

一、修改网络配置文件，把`IPADDR`改为02，把`UUID`注释掉。保存后重启网络。

二、修改主机名为02。

```bash
[root@lu9up01 oracle]# cat /etc/hostname
lu9up02
```

需要reboot重启虚拟机才生效。

三、把oracle和grid环境变量中的`ORACLE_SID`改成2。

```bash
[root@lu9up01 ~]# su - oracle
[oracle@lu9up01 ~]$ echo $ORACLE_SID
racdb2

[oracle@lu9up02 ~]$ su - grid
[grid@lu9up02 ~]$ echo $ORACLE_SID
+ASM2
```

修改环境变量后，执行 `source ~/.bash_profile`生效。

四、检查。

多检查几遍该改的地方有没有改。

千万不要遗漏了。

也不要改错了。

更不要弄混了，把第一台虚拟机当第二台去改。

# 5 搭建共享磁盘；

因为Oracle RAC集群强制使用ASM，所以我们要新增若干硬盘，并让两台服务器共同识别，硬盘规划如下：

| DiskGroup |  单盘容量 |  数量 | 冗余方式 | 最终可用 |
|-|-|-|-|-|
| DATA | 16 | 2 | External | 32 |
| FRA | 16 | 2 | External | 32 |

DATA是数据磁盘组，FRA是快速恢复区磁盘组。

---
**小插曲：**
```txt
我用vm搭建共享磁盘的时候遇到了不少坑，进群里问了大佬，知道我用vm搭建rac后，直接叫我别搞了。我哭了，难道真的要前功尽弃吗？

大佬的建议是，使用vxbox搭建rac，共享磁盘推荐使用openfiler搭建。

后来看到有大佬说刚用vm搭建了11g rac，感觉有希望，那就硬着头皮往下干吧。

各位老铁看到这里，要不要继续往下请自己做决定哈哈，现在回头还不晚。
```
---


## 5.1 虚拟机lu9up01创建ASM磁盘

创建磁盘需要关闭虚拟机。

**方法1：命令创建（比较方便快捷）**

一、进入VMware Workstation Pro的安装目录执行以下命令进行创建：

```bash
vmware-vdiskmanager.exe -c -s 16Gb -a lsilogic -t 2 "E:\Machine\Oracle-Linux\19c-rac\asmdisk\data01.vmdk"
vmware-vdiskmanager.exe -c -s 16Gb -a lsilogic -t 2 "E:\Machine\Oracle-Linux\19c-rac\asmdisk\data02.vmdk"
vmware-vdiskmanager.exe -c -s 16Gb -a lsilogic -t 2 "E:\Machine\Oracle-Linux\19c-rac\asmdisk\fra01.vmdk"
vmware-vdiskmanager.exe -c -s 16Gb -a lsilogic -t 2 "E:\Machine\Oracle-Linux\19c-rac\asmdisk\fra02.vmdk"
```

二、修改虚拟机配置文件

虚拟磁盘文件创建好后，还要把这些盘加到`两台虚拟机`里，通过编辑虚拟机的`.vmx`文件添加。

![Alt text](image/image-24.png)

打开后在文件末尾处添加以下内容并保存，每台都要添加：

```bash
scsi0.virtualDev = "lsilogic"
scsi0.present = "TRUE"

scsi0:4.fileName = "E:\Machine\Oracle-Linux\19c-rac\asmdisk\fra02.vmdk"
scsi0:1.fileName = "E:\Machine\Oracle-Linux\19c-rac\asmdisk\data01.vmdk"
scsi0:3.fileName = "E:\Machine\Oracle-Linux\19c-rac\asmdisk\fra01.vmdk"
scsi0:2.fileName = "E:\Machine\Oracle-Linux\19c-rac\asmdisk\data02.vmdk"
scsi0:1.mode = "independent-persistent"
scsi0:2.mode = "independent-persistent"
scsi0:3.mode = "independent-persistent"
scsi0:4.mode = "independent-persistent"
scsi0:4.present = "TRUE"
scsi0:1.present = "TRUE"
scsi0:3.present = "TRUE"
scsi0:2.present = "TRUE"
scsi0:3.redo = ""
scsi0:2.redo = ""
scsi0:1.redo = ""
scsi0:4.redo = ""

scsi0.sharedBus = "virtual"
disk.locking = "false"
diskLib.dataCacheMaxSize = "0"
diskLib.dataCacheMaxReadAheadSize = "0"
diskLib.dataCacheMinReadAheadSize = "0"
diskLib.dataCachePageSize = "4096"
diskLib.maxUnsyncedWrites = "0"
disk.EnableUUID = "TRUE"
```

重新打开VMware Workstation Pro客户端后，此时可以看到每台服务器都识别到了共享磁盘。


**方法2：VM客户端创建（可视化，鼠标点点，简单）**

一、节点1创建新的磁盘：

1 在虚拟机设置中选择添加：

![Alt text](image/image-14.png)

2 添加硬盘：

![Alt text](image/image-15.png)

3 磁盘类型选择scsi：

![Alt text](image/image-16.png)

4 创建新的磁盘：

![Alt text](image/image-19.png)

5 修改磁盘容量（个人喜欢只创建单个磁盘文件，看起来比较舒服。可以默认创建多个文件）：

![Alt text](image/image-17.png)

6 指定路径和磁盘文件名：

![Alt text](image/image-18.png)

以上步骤创建了data01磁盘，以同样的方式创建data02、fra01、fra02磁盘。

![Alt text](image/image-22.png)

二、节点2基于节点1创建的磁盘创建：

1、2、3都和上述节点1一样创建，第4步要改为`使用现有虚拟磁盘`。

1 - 3 略

4 使用现有虚拟磁盘：

![Alt text](image/image-20.png)

5 选择节点1刚刚创建的磁盘：

![Alt text](image/image-21.png)

data01创建完成，以同样的方式创建data02、fra01、fra02磁盘。

![Alt text](image/image-23.png)

三、修改虚拟机配置文件

![Alt text](image/image-24.png)

虚拟磁盘文件创建好后，还要把这些盘加到虚拟机里，两台虚拟机都要添加。

在上图的`.vmx`文件末追加：

```bash
scsi0:3.redo = ""
scsi0:2.redo = ""
scsi0:1.redo = ""
scsi0:4.redo = ""

scsi0.sharedBus = "virtual"
disk.locking = "false"
diskLib.dataCacheMaxSize = "0"
diskLib.dataCacheMaxReadAheadSize = "0"
diskLib.dataCacheMinReadAheadSize = "0"
diskLib.dataCachePageSize = "4096"
diskLib.maxUnsyncedWrites = "0"
disk.EnableUUID = "TRUE"
```

scsi[n]：n根据实际进行修改，一般为0或1。

## 5.2 磁盘分区

一、启动后检查安装后的磁盘情况：

节点1：

```bash
[root@lu9up01 dev]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sdd      8:48   0   16G  0 disk
sdb      8:16   0   16G  0 disk
sr0     11:0    1  4.5G  0 rom
sde      8:64   0   16G  0 disk
sdc      8:32   0   16G  0 disk
sda      8:0    0   50G  0 disk
├─sda2   8:2    0    8G  0 part [SWAP]
├─sda3   8:3    0   41G  0 part /
└─sda1   8:1    0    1G  0 part /boot
[root@lu9up01 dev]# ll /dev/sd*
brw-rw---- 1 root disk 8,  0 Nov  5 21:54 /dev/sda
brw-rw---- 1 root disk 8,  1 Nov  5 21:54 /dev/sda1
brw-rw---- 1 root disk 8,  2 Nov  5 21:54 /dev/sda2
brw-rw---- 1 root disk 8,  3 Nov  5 21:54 /dev/sda3
brw-rw---- 1 root disk 8, 16 Nov  5 21:54 /dev/sdb
brw-rw---- 1 root disk 8, 32 Nov  5 21:54 /dev/sdc
brw-rw---- 1 root disk 8, 48 Nov  5 21:54 /dev/sdd
brw-rw---- 1 root disk 8, 64 Nov  5 21:54 /dev/sde
[root@lu9up01 dev]# fdisk -l |grep "Disk /dev"
Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Disk /dev/sdb: 17.2 GB, 17179869184 bytes, 33554432 sectors
Disk /dev/sde: 17.2 GB, 17179869184 bytes, 33554432 sectors
Disk /dev/sdc: 17.2 GB, 17179869184 bytes, 33554432 sectors
Disk /dev/sdd: 17.2 GB, 17179869184 bytes, 33554432 sectors
```

节点2：

```bash
[root@lu9up02 ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sdd      8:48   0   16G  0 disk
sdb      8:16   0   16G  0 disk
sr0     11:0    1  4.5G  0 rom
sde      8:64   0   16G  0 disk
sdc      8:32   0   16G  0 disk
sda      8:0    0   50G  0 disk
├─sda2   8:2    0    8G  0 part [SWAP]
├─sda3   8:3    0   41G  0 part /
└─sda1   8:1    0    1G  0 part /boot
[root@lu9up02 ~]# ll /dev/sd*
brw-rw---- 1 root disk 8,  0 Nov  5 21:54 /dev/sda
brw-rw---- 1 root disk 8,  1 Nov  5 21:54 /dev/sda1
brw-rw---- 1 root disk 8,  2 Nov  5 21:54 /dev/sda2
brw-rw---- 1 root disk 8,  3 Nov  5 21:54 /dev/sda3
brw-rw---- 1 root disk 8, 16 Nov  5 21:54 /dev/sdb
brw-rw---- 1 root disk 8, 32 Nov  5 21:54 /dev/sdc
brw-rw---- 1 root disk 8, 48 Nov  5 21:54 /dev/sdd
brw-rw---- 1 root disk 8, 64 Nov  5 21:54 /dev/sde
[root@lu9up02 ~]# fdisk -l |grep "Disk /dev"
Disk /dev/sdc: 17.2 GB, 17179869184 bytes, 33554432 sectors
Disk /dev/sdb: 17.2 GB, 17179869184 bytes, 33554432 sectors
Disk /dev/sda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Disk /dev/sdd: 17.2 GB, 17179869184 bytes, 33554432 sectors
Disk /dev/sde: 17.2 GB, 17179869184 bytes, 33554432 sectors
```

新添加的磁盘为sdb、sdc、sdd、sde。

二、配置 udev：

*方法1：*

```bash
[root@lu9up02 ~]# echo -e "n\np\n1\n\n\nw" | fdisk /dev/sdb
[root@lu9up02 ~]# echo -e "n\np\n1\n\n\nw" | fdisk /dev/sdc
[root@lu9up02 ~]# echo -e "n\np\n1\n\n\nw" | fdisk /dev/sdd
[root@lu9up02 ~]# echo -e "n\np\n1\n\n\nw" | fdisk /dev/sde
```
注意：`\n`为回车。


*方法2：*

```bash
[root@lu9up01 ~]# fdisk /dev/sdc
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x1cde2f7f.

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-33554431, default 2048):
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-33554431, default 33554431):
Using default value 33554431
Partition 1 of type Linux and of size 16 GiB is set

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
```

注意：输入`m`可以查看帮助。


配置后查看：
```bash
[root@lu9up01 ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sdd      8:48   0   16G  0 disk
└─sdd1   8:49   0   16G  0 part
sdb      8:16   0   16G  0 disk
└─sdb1   8:17   0   16G  0 part
sr0     11:0    1  4.5G  0 rom
sde      8:64   0   16G  0 disk
└─sde1   8:65   0   16G  0 part
sdc      8:32   0   16G  0 disk
└─sdc1   8:33   0   16G  0 part
sda      8:0    0   50G  0 disk
├─sda2   8:2    0    8G  0 part [SWAP]
├─sda3   8:3    0   41G  0 part /
└─sda1   8:1    0    1G  0 part /boot
```


三、查询这些磁盘的 scsi id
```bash
for n in {b..e}
do
/usr/lib/udev/scsi_id -g -u -d /dev/sd$n
done

[root@lu9up01 ~]# for n in {b..e}
> do
> /usr/lib/udev/scsi_id -g -u -d /dev/sd$n
> done
36000c2922c7e6430cf0235bf34e01fa6
36000c29b0c5d635c59b2e781072844af
36000c29735ae8e4b4b2f3a7f9c84d928
36000c29ff75747fc8506df4458c07e15
```

四、编辑udev规则文件 /etc/udev/rules.d/99-oracle-asmdevices.rules
```bash
[root@lu9up01 ~]# vim /etc/udev/rules.d/99-oracle-asmdevices.rules
KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$parent", RESULT=="36000c2922c7e6430cf0235bf34e01fa6", SYMLINK+="asmdisks/data01", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$parent", RESULT=="36000c29b0c5d635c59b2e781072844af", SYMLINK+="asmdisks/data02", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$parent", RESULT=="36000c29735ae8e4b4b2f3a7f9c84d928", SYMLINK+="asmdisks/fra01", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$parent", RESULT=="36000c29ff75747fc8506df4458c07e15", SYMLINK+="asmdisks/fra02", OWNER="grid", GROUP="asmadmin", MODE="0660"
```

五、启动 udev
```bash
[root@lu9up01 ~]# /sbin/partprobe /dev/sdb
[root@lu9up01 ~]# /sbin/partprobe /dev/sdc
[root@lu9up01 ~]# /sbin/partprobe /dev/sdd
[root@lu9up01 ~]# /sbin/partprobe /dev/sde
[root@lu9up01 ~]# /sbin/udevadm trigger --type=devices --action=change
```

六、检查磁盘状态
```bash
[root@lu9up01 ~]# ll /dev/sd*1
brw-rw---- 1 root disk     8,  1 Nov  5 23:14 /dev/sda1
brw-rw---- 1 grid asmadmin 8, 17 Nov  5 23:14 /dev/sdb1
brw-rw---- 1 grid asmadmin 8, 33 Nov  5 23:14 /dev/sdc1
brw-rw---- 1 grid asmadmin 8, 49 Nov  5 23:14 /dev/sdd1
brw-rw---- 1 grid asmadmin 8, 65 Nov  5 23:14 /dev/sde1
[root@lu9up01 ~]# ll /dev/asmdisks/*
lrwxrwxrwx 1 root root 7 Nov  5 23:18 /dev/asmdisks/data01 -> ../sdb1
lrwxrwxrwx 1 root root 7 Nov  5 23:18 /dev/asmdisks/data02 -> ../sdc1
lrwxrwxrwx 1 root root 7 Nov  5 23:18 /dev/asmdisks/fra01 -> ../sdd1
lrwxrwxrwx 1 root root 7 Nov  5 23:18 /dev/asmdisks/fra02 -> ../sde1
```

**节点2也是同样的操作。**

# 6 安装Grid软件

一、登录到节点1的grid用户，把提前下载好的安装包上传至 /tmp/sofe

```bash
[grid@lu9up01 soft]$ ll
total 2821472
-rw-r--r-- 1 root root 2889184573 Nov  7 01:17 LINUX.X64_193000_grid_home.zip
```

进入ORACLE_HOME路径下解压：

```bash
[grid@lu9up01 soft]$ cd $ORACLE_HOME
[grid@lu9up01 grid]$ pwd
/u01/app/19.0.0/grid
[grid@lu9up01 grid]$ unzip -q /tmp/soft/LINUX.X64_193000_grid_home.zip
[grid@lu9up01 grid]$ ls
addnode     crs     deinstall    evm           install        jdk   network  ord   perl     racg      root.sh.old     slax      tomcat        wlm
assistants  css     demo         gpnp          instantclient  jlib  nls      ords  plsql    rdbms     root.sh.old.1   sqlpatch  ucp           wwg
bin         cv      diagnostics  gridSetup.sh  inventory      ldap  OPatch   oss   precomp  relnotes  rootupgrade.sh  sqlplus   usm           xag
cha         dbjava  dmu          has           javavm         lib   opmn     oui   QOpatch  rhp       runcluvfy.sh    srvm      utl           xdk
clone       dbs     env.ora      hs            jdbc           md    oracore  owm   qos      root.sh   sdk             suptools  welcome.html
```

二、启动安装

```bash
[grid@lu9up01 grid]$ ./gridSetup.sh
Launching Oracle Grid Infrastructure Setup Wizard...
```

三、创建新的集群

![Alt text](image/image-6.png)

![Alt text](image/image-25.png)

四、配置集群名称以及scan名称

注意scan name要和/etc/hosts文件的保持一致，不配置GNS。

![Alt text](image/image-26.png)

五、节点互信

点击add：

![Alt text](image/image-27.png)

输入节点2的public ip和vip的映射主机名：

![Alt text](image/image-28.png)

输入grid密码（两个节点的密码必须一致），先点击setup，后点击test：

![Alt text](image/image-29.png)

![Alt text](image/image-30.png)

六、公网、私网网段选择

网卡和ip网段对应上，19C心跳网段需要选ASM & Private，用于ASM实例的托管：

![Alt text](image/image-31.png)

七、选择ASM存储类型

![Alt text](image/image-32.png)

八、不安装GIMR

![Alt text](image/image-33.png)

九、创建ASM磁盘组

前面创建好ASM磁盘后，这里会自动识别路径。

![Alt text](image/image-35.png)

我这里暂时只添加了一块磁盘，冗余类型选择了外部冗余。如果你添加一块以上磁盘，可以选择常规冗余，并指定故障组。

![Alt text](image/image-34.png)

十、创建sys和asm密码

我喜欢设置为相同的密码。

![Alt text](image/image-36.png)

如果设置得太简单，会跳出警告，忽略，选择yes。

十一、默认选项，能不改别改了

故障隔离：

![Alt text](image/image-37.png)

EM也保持默认，比较费资源，不开：

![Alt text](image/image-38.png)

权限用户组：

![Alt text](image/image-39.png)

确认grid base目录，默认：

![Alt text](image/image-40.png)

库存目录：

![Alt text](image/image-41.png)

这里可以选择自动root执行脚本，不选，嫌麻烦可以选：

![Alt text](image/image-42.png)

十二、预安装检查

ASM和DNS有问题，点击修复：

![Alt text](image/image-43.png)

修复后DNS还有问题，由于我们只配了一个SCAN，所以关于DNS相关的都无视，选择ignore：

![Alt text](image/image-45.png)

注意，除了DNS可以忽略，如果还有其他问题一定要修复，例如swap交换区不足需要添加好后回来点击`Check 
Again`。添加swap参考文章《添加swap》https://www.modb.pro/db/1721605971427024896 。

十三、开始安装

![Alt text](image/image-44.png)

十四、root下执行脚本

![Alt text](image/image-46.png)

两节点顺序执行`orainstRoot.sh`和`root.sh`，先节点1执行完，再节点2执行，过程会有点久：

```bash
/u01/app/oraInventory/orainstRoot.sh
/u01/app/19.0.0/grid/root.sh
```

---

```bash
[root@lu9up01 ~]# /u01/app/oraInventory/orainstRoot.sh
Changing permissions of /u01/app/oraInventory.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.

Changing groupname of /u01/app/oraInventory to oinstall.
The execution of the script is complete.


[root@lu9up01 ~]# /u01/app/19.0.0/grid/root.sh
Performing root user operation.

The following environment variables are set as:
    ORACLE_OWNER= grid
    ORACLE_HOME=  /u01/app/19.0.0/grid

Enter the full pathname of the local bin directory: [/usr/local/bin]:
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...


Creating /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.
Relinking oracle with rac_on option
Using configuration parameter file: /u01/app/19.0.0/grid/crs/install/crsconfig_params
The log of current session can be found at:
  /u01/app/grid/crsdata/lu9up01/crsconfig/rootcrs_lu9up01_2023-11-07_03-38-14AM.log
2023/11/07 03:38:23 CLSRSC-594: Executing installation step 1 of 19: 'SetupTFA'.
2023/11/07 03:38:23 CLSRSC-594: Executing installation step 2 of 19: 'ValidateEnv'.
2023/11/07 03:38:23 CLSRSC-363: User ignored prerequisites during installation
2023/11/07 03:38:23 CLSRSC-594: Executing installation step 3 of 19: 'CheckFirstNode'.
2023/11/07 03:38:25 CLSRSC-594: Executing installation step 4 of 19: 'GenSiteGUIDs'.
2023/11/07 03:38:26 CLSRSC-594: Executing installation step 5 of 19: 'SetupOSD'.
2023/11/07 03:38:26 CLSRSC-594: Executing installation step 6 of 19: 'CheckCRSConfig'.
2023/11/07 03:38:26 CLSRSC-594: Executing installation step 7 of 19: 'SetupLocalGPNP'.
2023/11/07 03:38:57 CLSRSC-594: Executing installation step 8 of 19: 'CreateRootCert'.
2023/11/07 03:38:59 CLSRSC-4002: Successfully installed Oracle Trace File Analyzer (TFA) Collector.
2023/11/07 03:39:01 CLSRSC-594: Executing installation step 9 of 19: 'ConfigOLR'.
2023/11/07 03:39:11 CLSRSC-594: Executing installation step 10 of 19: 'ConfigCHMOS'.
2023/11/07 03:39:12 CLSRSC-594: Executing installation step 11 of 19: 'CreateOHASD'.
2023/11/07 03:39:17 CLSRSC-594: Executing installation step 12 of 19: 'ConfigOHASD'.
2023/11/07 03:39:17 CLSRSC-330: Adding Clusterware entries to file 'oracle-ohasd.service'
2023/11/07 03:39:42 CLSRSC-594: Executing installation step 13 of 19: 'InstallAFD'.
2023/11/07 03:39:48 CLSRSC-594: Executing installation step 14 of 19: 'InstallACFS'.
2023/11/07 03:39:54 CLSRSC-594: Executing installation step 15 of 19: 'InstallKA'.
2023/11/07 03:40:00 CLSRSC-594: Executing installation step 16 of 19: 'InitConfig'.

ASM has been created and started successfully.

[DBT-30001] Disk groups created successfully. Check /u01/app/grid/cfgtoollogs/asmca/asmca-231107AM034035.log for details.

2023/11/07 03:41:32 CLSRSC-482: Running command: '/u01/app/19.0.0/grid/bin/ocrconfig -upgrade grid oinstall'
CRS-4256: Updating the profile
Successful addition of voting disk 9211390f2ac74fe3bfc04c7999a0c1ef.
Successfully replaced voting disk group with +DATA.
CRS-4256: Updating the profile
CRS-4266: Voting file(s) successfully replaced
##  STATE    File Universal Id                File Name Disk group
--  -----    -----------------                --------- ---------
 1. ONLINE   9211390f2ac74fe3bfc04c7999a0c1ef (/dev/sdb1) [DATA]
Located 1 voting disk(s).
2023/11/07 03:42:58 CLSRSC-594: Executing installation step 17 of 19: 'StartCluster'.
2023/11/07 03:44:30 CLSRSC-343: Successfully started Oracle Clusterware stack
2023/11/07 03:44:30 CLSRSC-594: Executing installation step 18 of 19: 'ConfigNode'.
2023/11/07 03:45:49 CLSRSC-594: Executing installation step 19 of 19: 'PostConfig'.
2023/11/07 03:46:22 CLSRSC-325: Configure Oracle Grid Infrastructure for a Cluster ... succeeded
```

# 7 安装Oracle软件

# 8 创建数据库

# 9 安装失败重装

rac的安装可能不会一次成功，有时候需要折腾多次，最坏的情况就是要重装。重装前需要把安装的东西全部清理干净。

清除的内容如下，步骤先后没有关系：

```bash
rm -rf /etc/oracle
rm -rf /etc/.oracle
rm -rf /etc/ora*
rm -rf /etc/oraInst.loc
rm -rf /etc/oratab
rm -rf /etc/init.d/init.ohasd
rm -rf /etc/init.d/ohasd
rm -rf /tmp/*
rm -rf /tmp/.oracle
rm -rf /usr/local/bin/coraenv    
rm -rf /usr/local/bin/dbhome
rm -rf /usr/local/bin/oraenv
rm -rf /var/tmp/.oracle
rm -rf /crs/* 
rm -rf /u01/app/oracle/admin
rm -rf /u01/app/oracle/product/19.0.0/db_1/*
rm -rf /u01/app/19.0.0/grid/*
rm -rf /u01/app/19.0.0/grid/.patch_storage
rm -rf /u01/app/19.0.0/grid/.opatchauto_storage
rm -rf /u01/app/grid/*
rm -rf /u01/app/oraInventory/*
```

清理完后重启一下虚拟机。