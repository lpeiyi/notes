# 1 docker介绍

Docker是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的镜像中，然后发布到任何流行的 Linux或Windows操作系统的机器上，也可以实现虚拟化。容器是完全使用沙箱机制，相互之间不会有任何接口。是一个强大的开源应用容器引擎，可以实现应用程序的快速部署和管理，并具有广泛的应用场景和优势。

Docker基于Go语言开发，并遵守Apache2.0协议开源。它是开发人员和系统管理员使用容器开发、部署和运行应用程序的平台。使用Linux容器来部署应用称为集装箱化，这使得Docker可以轻松部署应用程序。

Docker的优点包括隔离环境、沙箱机制、易移植、灵活封装和易扩展。隔离环境是指资源和环境是隔离的，容器不会影响到宿主机；沙箱机制是指不同的集装箱之间不会相互影响；易移植是指可以在本地构建，部署到云上并可以在任何地方运行；灵活封装是指即使是复杂的应用程序也可以封装；易扩展是指可以增加和自动分发容器副本。

Docker的应用场景广泛，包括Web应用、数据库应用、大数据应用和分布式应用等。此外，Docker还支持容器编排和容器云等技术，可以实现大规模的容器管理和调度。

# 2 安装docker

官方参考文档：https://docs.docker.com/engine/install/centos/

## 2.1 yum安装

**1）设置yum仓库**

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

**2）安装docker ce**

选择自己喜欢的版本安装。

```bash
yum list docker-ce --showduplicates | sort -r
sudo yum install docker-ce-20.10.6
```

ce是社区版。

**3）启动docker，并设置开机自启**

```bash
systemctl start docker
systemctl enable docker
```

**4）测试docker是否安装成功**

```
[root@zabbix6 ~]# docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

## 2.2 二进制包安装

Docker二进制包下载地址：https://download.docker.com/linux/static/stable/x86_64/

网盘下载链接：https://pan.baidu.com/s/1CauJFLZ2VIBAOjpkpeWu6w 提取码：lu9u 

**1）上传解压赋权并拷贝到/usr/bin目录下**

```bash
[root@zabbix6 pkg]# cd /usr/local/
[root@zabbix6 local]# tar -xf /pkg/docker-20.10.1.tgz
[root@zabbix6 local]# chown -R root.root docker/
[root@zabbix6 local]# ls docker/
containerd  containerd-shim  containerd-shim-runc-v2  ctr  docker  dockerd  docker-init  docker-proxy  runc
[root@zabbix6 local]# cp docker/* /usr/bin/
```

**2）修改最大内存映射数量**

必须修改系统参数`max_map_count`，否则 Elasticsearch 无法启动：

```bash
[root@zabbix6 local]# vim /etc/sysctl.conf
#添加
vm.max_map_count=262144

[root@zabbix6 local]# sysctl -p
vm.max_map_count = 262144
```

**3）添加组**

```bash
[root@zabbix6 local]# groupadd docker
```


**4）配置Docker在启动时使用systemd启动**

需要手动创建systemd单元文件，用于systemd管理docker服务。获取方式二选一：

1. github下载：https://github.com/moby/moby/tree/master/contrib/init/systemd 
2. 访问不了github的网盘下载：https://pan.baidu.com/s/1CauJFLZ2VIBAOjpkpeWu6w 提取码：lu9u 

上传Systemd单元文件到/etc/systemd/system目录下，赋权：

```bash
[root@zabbix6 system]# chmod a+x /etc/systemd/system/docker.service
[root@zabbix6 system]# chmod a+x /etc/systemd/system/docker.socket
[root@zabbix6 system]# systemctl daemon-reload
```

**5）启动docker并配置开机自启**

```bash
[root@zabbix6 ~]# systemctl start docker
[root@zabbix6 ~]# systemctl enable docker
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.servi         ce to /etc/systemd/system/docker.service.
```

**6）测试docker是否安装成功**

```
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