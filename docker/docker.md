# 1 docker简介



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