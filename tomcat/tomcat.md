**目录**

[toc]

# 1 简介

# 2 安装

## 2.1 安装java

tomcat是java开发的，所以要安装java。

**一、安装包下载**

https://www.oracle.com/java/technologies/downloads/

![alt text](image-1.png)

**二、解压**

```bash
[weblogic@zabbix6 install]$ tar -xvf jdk-8u401-linux-i586.tar.gz
```

**三、配置环境变量**

```bash
[root@zabbix6 ~]# vim /etc/profile
#添加
export JAVA_HOME=/servyou/install/jdk1.8.0_401
export PATH=$PATH:$JAVA_HOME/bin

[root@zabbix6 ~]# source /etc/profile
```

**四、检查**

```bash
[root@zabbix6 ~]# java -version
java version "1.8.0_401"
Java(TM) SE Runtime Environment (build 1.8.0_401-b10)
Java HotSpot(TM) Server VM (build 25.401-b10, mixed mode)
```

## 2.2 安装tomcat

**一、安装包下载**

https://tomcat.apache.org/download-80.cgi

![alt text](image.png)

**二、解压**

```bash
[weblogic@zabbix6 install]$ tar -xvf apache-tomcat-8.5.99.tar.gz
```

目录结构：

```bash
[weblogic@zabbix6 install]$ tree -L 1 apache-tomcat-8.5.99
.
├── bin
├── BUILDING.txt
├── conf
├── CONTRIBUTING.md
├── lib
├── LICENSE
├── logs
├── NOTICE
├── README.md
├── RELEASE-NOTES
├── RUNNING.txt
├── temp
├── webapps
└── work
```

**三、启动**

```bash
[weblogic@zabbix6 install]$ cd apache-tomcat-8.5.99/bin/
[weblogic@zabbix6 bin]$ ./startup.sh
Using CATALINA_BASE:   /servyou/install/apache-tomcat-8.5.99
Using CATALINA_HOME:   /servyou/install/apache-tomcat-8.5.99
Using CATALINA_TMPDIR: /servyou/install/apache-tomcat-8.5.99/temp
Using JRE_HOME:        /servyou/install/jdk1.8.0_401
Using CLASSPATH:       /servyou/install/apache-tomcat-8.5.99/bin/bootstrap.jar:/serv
Using CATALINA_OPTS:
Tomcat started.
```