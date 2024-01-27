# 1 docker简介

# 2 安装docker

## 2.1

## 2.2 二进制包安装

https://download.docker.com/linux/static/stable/x86_64/

```bash
[root@zabbix6 pkg]# cd /usr/local/
[root@zabbix6 local]# tar -xf /pkg/docker-20.10.1.tgz
[root@zabbix6 local]# chown -R root.root docker/
[root@zabbix6 local]# ls docker/
containerd  containerd-shim  containerd-shim-runc-v2  ctr  docker  dockerd  docker-init  docker-proxy  runc
[root@zabbix6 local]# cp docker/* /usr/bin/
[root@zabbix6 local]# vim /etc/sysctl.conf
#添加
vm.max_map_count=262144

[root@zabbix6 local]# sysctl -p
vm.max_map_count = 262144

[root@zabbix6 local]# groupadd docker
[root@zabbix6 system]# chmod a+x /etc/systemd/system/docker.service
[root@zabbix6 system]# chmod a+x /etc/systemd/system/docker.socket
[root@zabbix6 system]# systemctl daemon-reload
[root@zabbix6 ~]# systemctl start docker
[root@zabbix6 ~]# systemctl enable docker
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.servi         ce to /etc/systemd/system/docker.service.
[root@zabbix6 ~]# docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

# 3 docker常用命令

# 4 docker镜像

# 5 本地镜像发布到阿里云

# 6 本地镜像发布到私有云

# 7 docker容器数据卷

## 8 docker常规安装