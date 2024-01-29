# 1 PMM介绍

Percona Monitoring and Management（PMM）是一个开源的用于管理和监控**MySQL**、MongoDB和PostgreSQL性能的平台。它由Percona与托管数据库服务，支持和咨询领域的专家合作开发。PMM旨在为MySQL和MongoDB服务器提供全面的基于时间的分析，以确保数据尽可能高效地工作。

PMM平台基于简单的客户端-服务器模型，可实现高效的可扩展性。它包括以下模块：

- **PMM Client**：安装在每个要监视的数据库主机上。它收集服务器指标，一般系统指标和查询分析数据，以获得完整的性能概述。收集的数据发送到PMM服务器。
- **PMM Server**：PMM的核心部分，它聚合收集的数据，并以Web界面的表格，仪表板和图形的形式呈现。
PMM提供了对MyISAM、InnoDB、TokuDB和PXC/Glarera的监控，另外也提供了Query Analytics的功能，可以检视执行了哪些SQL指令，并对执行效能较差的语法进行优化。另外在新版本还支持了MySQL复制拓扑图结构构造。

PMM针对操作系统的部分也提供了硬盘、网络、CPU和RAM的监控，特别的是它提供了Context switches、Processes和interrupts的监控，Context Switches可以看到CPU上下切换文的状况，Processes可以方便了解系统有多少程序在等待I/O。

此外，PMM通过PMM客户端收集到的DB监控数据可以用第三方软件Grafana进行画图展示。

架构图如下：

![Alt text](image.png)

更详细的介绍请参考官方文档：https://docs.percona.com/percona-monitoring-and-management/index.html

# 2 PMM Server部署

官方提供了多种安装方式，优缺点如下：

![Alt text](image-1.png)

最常用的方式是Docker。

# 2.1 PMM Server安装

**1）安装docker**

参考文章：[http://t.csdnimg.cn/N752u](http://t.csdnimg.cn/N752u)

如果你的机器可以连接外网的，用yum安装比较方便快捷。但是工作中的机器一般是内网环境，无法连互联网，所以只能通过二进制包安装。

**2）下载PMM Server镜像**

docker hub地址：[https://hub.docker.com/r/percona/pmm-server](https://hub.docker.com/r/percona/pmm-server)

```bash
[root@zabbix6 ~]# docker pull percona/pmm-server:2
```

这里下载的是pmm-server2.x的最新版本。如果要下载最新版本可以改为执行：

```bash
docker pull percona/pmm-server:latest
```

**3）创建持久数据卷容器**

单独建数据卷容器的好处主要包括以下几点：

- 数据持久性：容器数据卷允许容器中的数据在容器被删除或重启后仍然存在，这可以确保数据在容器生命周期内得到保护和持久化存储。
- 数据共享：容器数据卷允许多个容器共享同一个数据卷，这可以方便地共享应用程序和数据。
- 数据安全性：使用容器数据卷将宿主机的目录或文件挂载到容器中，可以避免在容器中存储敏感数据，提高数据安全性和保密性。
- 容器可移植性：使用容器数据卷使容器代码和数据分离，这使得容器的迁移变得更加简单和便捷。
- 数据备份：使用容器数据卷可以简化数据备份过程，可以轻松地备份和还原数据。

就算有人误删了你的PMM-Server容器，有数据也可以进行恢复，不至于**从删容器到跑路**。

**1.创建容器数据卷：**

```bash
[root@zabbix6 srv]# 
docker create --volume /srv \
--name pmm-data \
percona/pmm-server:2 /bin/true
```
PMM Server指定的数据卷为/srv，使用其他卷将导致升级时数据丢失。

command介绍：

- docker create：创建一个新容器;
- --volume：绑定挂载卷/srv；
- --name：为容器指定一个名称pmm-data；
- pmm-data percona/pmm-server:2：镜像名；
- /bin/true：设置退出码为0，在Linux底下，每一个程序执行完毕都会返回一个退出码，通常状况下0表示成功。

以上命令介绍可以通过执行`docker --help`查看。

**2.检查服务器和数据容器挂载点:**

```bash
[root@zabbix6 srv]# docker inspect pmm-data | egrep "Destination|Source"
                "Source": "/var/lib/docker/volumes/c08c5a4898c3a2340edc40ae531a6400e4e292d1b9a754fc66622475356a0413/_data",
                "Destination": "/srv",
```

参数介绍：
- Destination：容器内目录；
- Source：对应宿主机目录。

检查下宿主机目录：

```bash
[root@zabbix6 _data]# ls /var/lib/docker/volumes/
alerting  alertmanager  backup  clickhouse  grafana  logs  nginx  pmm-distribution  postgres14  prometheus  victoriametrics
```

**4）创建并启动PMM Server容器**

```bash
[root@zabbix6 _data]# 
docker run --privileged --detach --restart always \
--publish 443:443 \
--volumes-from pmm-data \
--name pmm-server \
percona/pmm-server:2
```

command介绍：

- docker run: 用于启动一个或多个容器。
- --detach: 容器将在后台运行并返回容器ID。
- --restart always: 指定重启策略，当容器退出时，该参数确保容器始终自动重新启动。
- --publish 443:443: 端口映射，冒号前是宿主机的端口，冒号后是容器内部的端口。任何访问宿主机的443端口的请求都会被转发到容器的相应端口。
- --volumes-from pmm-data: 引用pmm-data容器中的数据卷。
- --name pmm-server: 新创建的容器的名称pmm-server。
- percona/pmm-server:2: 要运行的Docker镜像的名称。

**5）查看容器运行情况**

```bash
[root@zabbix6 ~]# docker ps
CONTAINER ID   IMAGE                  COMMAND                CREATED          STATUS                    PORTS                          NAMES
c99a87c5718b   percona/pmm-server:2   "/opt/entrypoint.sh"   18 minutes ago   Up 18 minutes (healthy)   80/tcp, 0.0.0.0:443->443/tcp   pmm-server
```

**6）在web浏览器中查看PMM用户界面**

访问 https://ip:443 在web浏览器中查看PMM用户界面，ip为PMM Server的地址。

![Alt text](image-4.png)

默认的用户名和密码都是admin，第一次登录会提示修改密码。

首页如下：

![Alt text](image-5.png)

# 2.2 PMM Server安装问题

**1）列出当前运行的 Docker 容器**

docker run启动pmm-server容器后查看：

![Alt text](image-2.png)

状态显示`unhealthy`，正常来说应该是`healthy`，这显然有问题。

**2）查看pmm-server容器日志**

```bash
[root@zabbix6 ~]# docker logs 7044dd8d6aca > docker.log
```

异常信息如下：

```bash
[root@zabbix6 ~]# vim docker.log
2024-01-28 17:04:26,213 INFO spawned: 'clickhouse' with pid 283
2024-01-28 17:04:26,383 INFO exited: clickhouse (exit status 232; not expected)
2024-01-28 17:04:32,683 INFO spawned: 'grafana' with pid 300
2024-01-28 17:04:32,684 INFO spawned: 'qan-api2' with pid 301
2024-01-28 17:04:32,690 INFO exited: grafana (exit status 2; not expected)
2024-01-28 17:04:32,691 INFO exited: qan-api2 (exit status 1; not expected)
```

根据提示，大概的意思是clickhouse、grafana、qan-api2进程退出。

**3）查看pmm-server容器进程**

```bash
[root@zabbix6 bin]# docker exec -it 7044dd8d6aca /bin/bash
[root@7044dd8d6aca opt] # supervisorctl
alertmanager                     RUNNING   pid 25, uptime 0:06:00
clickhouse                       FATAL     Exited too quickly (process log may have details)
dbaas-controller                 STOPPED   Not started
grafana                          FATAL     Exited too quickly (process log may have details)
nginx                            RUNNING   pid 22, uptime 0:06:00
pmm-agent                        RUNNING   pid 114, uptime 0:05:57
pmm-managed                      RUNNING   pid 37, uptime 0:06:00
pmm-update-perform               STOPPED   Not started
pmm-update-perform-init          FATAL     Exited too quickly (process log may have details)
postgresql                       RUNNING   pid 13, uptime 0:06:00
prometheus                       STOPPED   Not started
qan-api2                         BACKOFF   Exited too quickly (process log may have details)
victoriametrics                  RUNNING   pid 23, uptime 0:06:00
vmalert                          RUNNING   pid 24, uptime 0:06:00
vmproxy                          RUNNING   pid 32, uptime 0:06:00
```

印证了刚刚的推论，一大堆进程都没有运行，看起来问题很多啊。

**4）查看具体进程日志**

优先看看这几个进程clickhouse、grafana、qan-api2日志。

**clickhouse:**

```bash
supervisor> tail clickhouse
. main @ 0x0000000007111f8f in /usr/bin/clickhouse
1.  ? @ 0x00007f5ed0cd1eb0 in ?
2.  ? @ 0x00007f5ed0cd1f60 in ?
3.  _start @ 0x000000000634716e in /usr/bin/clickhouse
 (version 23.8.2.7 (official build))
Processing configuration file '/etc/clickhouse-server/config.xml'.
Logging information to /srv/logs/clickhouse-server.log
Poco::Exception. Code: 1000, e.code() = 0, Exception: Could not determine local time zone: filesystem error: in canonical: Operation not permitted ["/usr/share/zoneinfo/"] [""], Stack trace (when copying this message, always include the lines below):

1. DateLUT::DateLUT() @ 0x000000000c5f13d8 in /usr/bin/clickhouse
2. OwnPatternFormatter::OwnPatternFormatter(bool) @ 0x000000000c8e224e in /usr/bin/clickhouse
3. Loggers::buildLoggers(Poco::Util::AbstractConfiguration&, Poco::Logger&, String const&) @ 0x000000000c8d846d in /usr/bin/clickhouse
4. BaseDaemon::initialize(Poco::Util::Application&) @ 0x000000000c8b6082 in /usr/bin/clickhouse
5. DB::Server::initialize(Poco::Util::Application&) @ 0x000000000c68bef8 in /usr/bin/clickhouse
6. Poco::Util::Application::run() @ 0x0000000015b1e6fa in /usr/bin/clickhouse
7. DB::Server::run() @ 0x000000000c68bcbe in /usr/bin/clickhouse
8. Poco::Util::ServerApplication::run(int, char**) @ 0x0000000015b2d819 in /usr/bin/clickhouse
9. mainEntryClickHouseServer(int, char**) @ 0x000000000c688a8a in /usr/bin/clickhouse
10. main @ 0x0000000007111f8f in /usr/bin/clickhouse
11. ? @ 0x00007f85da433eb0 in ?
12. ? @ 0x00007f85da433f60 in ?
13. _start @ 0x000000000634716e in /usr/bin/clickhouse
 (version 23.8.2.7 (official build))
```

**grafana:**

```bash
supervisor> tail grafana
000
0x00007ffdba484180:  0x0000000000000001  0xc1999515713efe00
0x00007ffdba484190:  0x00007ffdba4843a0  0x00000000004324db <runtime.(*pageAlloc).allocRange+0x000000000000021b>
0x00007ffdba4841a0:  0x0000000005d202e8  0x0000000002030000 <github.com/grafana/grafana/pkg/services/libraryelements.(*LibraryElementService).getLibraryElementByUid+0x0000000000000240>
0x00007ffdba4841b0:  0x0000000000000004  0x0000000000000000
0x00007ffdba4841c0:  0x0000000000000002  0xc1999515713efe00
0x00007ffdba4841d0:  0x00007efd709d6740  0x0000000000000006
0x00007ffdba4841e0:  0x0000000000000001  0x00007ffdba484510
0x00007ffdba4841f0:  0x0000000005cf3920  0x00007efd70a2dd06
0x00007ffdba484200:  0x00007efd70bd4e90  0x00007efd70a017f3
0x00007ffdba484210:  0x0000000000000020  0x0000000000000000
0x00007ffdba484220:  0x000000000361013e  0x0000000000000006
0x00007ffdba484230:  0x0000000005eb988a  0x0000000000000000

goroutine 1 [running]:
runtime.systemstack_switch()
        /usr/local/go/src/runtime/asm_amd64.s:474 +0x8 fp=0xc000072740 sp=0xc000072730 pc=0x4737c8
runtime.main()
        /usr/local/go/src/runtime/proc.go:169 +0x6d fp=0xc0000727e0 sp=0xc000072740 pc=0x441aed
runtime.goexit()
        /usr/local/go/src/runtime/asm_amd64.s:1650 +0x1 fp=0xc0000727e8 sp=0xc0000727e0 pc=0x4757a1

rax    0x0
rbx    0x7efd709d6740
rcx    0x7efd70a7a58c
rdx    0x6
rdi    0x187
rsi    0x187
rbp    0x187
rsp    0x7ffdba484140
r8     0x7ffdba484210
r9     0x7efd70b8a4e0
r10    0x8
r11    0x246
r12    0x6
r13    0x7ffdba484510
r14    0x5cf3920
r15    0x6
rip    0x7efd70a7a58c
rflags 0x246
cs     0x33
fs     0x0
gs     0x0
```

**qan-api2:**

```bash
supervisor> tail qan-api2
: connect: connection refused
stdlog: qan-api2 v2.41.0.
time="2024-01-28T17:52:00.514+00:00" level=info msg="Log level: info."
time="2024-01-28T17:52:00.514+00:00" level=info msg="DSN: clickhouse://127.0.0.1:9000?database=pmm&block_size=10000&pool_size=2" component=main
stdlog: Connection: dial tcp 127.0.0.1:9000: connect: connection refused
stdlog: qan-api2 v2.41.0.
time="2024-01-28T17:52:25.252+00:00" level=info msg="Log level: info."
time="2024-01-28T17:52:25.252+00:00" level=info msg="DSN: clickhouse://127.0.0.1:9000?database=pmm&block_size=10000&pool_size=2" component=main
stdlog: Connection: dial tcp 127.0.0.1:9000: connect: connection refused
stdlog: qan-api2 v2.41.0.
time="2024-01-28T17:52:50.486+00:00" level=info msg="Log level: info."
time="2024-01-28T17:52:50.486+00:00" level=info msg="DSN: clickhouse://127.0.0.1:9000?database=pmm&block_size=10000&pool_size=2" component=main
stdlog: Connection: dial tcp 127.0.0.1:9000: connect: connection refused
stdlog: qan-api2 v2.41.0.
time="2024-01-28T17:53:17.248+00:00" level=info msg="Log level: info."
time="2024-01-28T17:53:17.248+00:00" level=info msg="DSN: clickhouse://127.0.0.1:9000?database=pmm&block_size=10000&pool_size=2" component=main
stdlog: Connection: dial tcp 127.0.0.1:9000: connect: connection refused
stdlog: qan-api2 v2.41.0.
time="2024-01-28T17:53:45.089+00:00" level=info msg="Log level: info."
time="2024-01-28T17:53:45.089+00:00" level=info msg="DSN: clickhouse://127.0.0.1:9000?database=pmm&block_size=10000&pool_size=2" component=main
stdlog: Connection: dial tcp 127.0.0.1:9000: connect: connection refused
```

上面三个进程的日志重要信息如下：

- 权限不足：filesystem error: in canonical: Operation not permitted ["/usr/share/zoneinfo/"]

- 连接失败：stdlog: Connection: dial tcp 127.0.0.1:9000: connect: connection refused

**5）解决办法**

先看看第一个权限不足的问题，看到一篇文章遇到了类似问题，文章地址为[https://github.com/ClickHouse/ClickHouse/issues/48296](https://github.com/ClickHouse/ClickHouse/issues/48296)

解决办法是：

![Alt text](image-3.png)

这个问题可能是因为版本的限制，一开始安装使用的`docker run`命令没有加--privileged参数。

**删除容器，重新创建：**

```bash
[root@zabbix6 _data]# docker stop 7044dd8d6aca
[root@zabbix6 _data]# docker rm 7044dd8d6aca
[root@zabbix6 _data]# 
docker run --privileged --detach --restart always \
--publish 443:443 \
--volumes-from pmm-data \
--name pmm-server \
percona/pmm-server:2

[root@zabbix6 ~]# docker ps
CONTAINER ID   IMAGE                  COMMAND                CREATED          STATUS                    PORTS                          NAMES
c99a87c5718b   percona/pmm-server:2   "/opt/entrypoint.sh"   18 minutes ago   Up 18 minutes (healthy)   80/tcp, 0.0.0.0:443->443/tcp   pmm-server
```

解决！！

# 3 PMM Client

PMM Client安装在每个要监视的数据库主机上。它收集服务器指标，一般系统指标和查询分析数据，以获得完整的性能概述。收集的数据发送到PMM服务器。

## 3.1 PMM Client安装

**1）下载安装包**

PMM Client安装的方法有两种：

- Docker：将PMM Client作为Docker容器运行；
- 安装包：下载安装包手动安装。

最常用的是使用二进制包进行安装，安装包在percona的首页下载：

![Alt text](image-6.png)

下载哪个版本看个人喜好，推荐下载最新版本。[https://www.percona.com/downloads](https://www.percona.com/downloads)

如果服务器能联网，也可以直接下载到服务器上：

```bash
wget https://downloads.percona.com/downloads/pmm2/2.41.0/binary/tarball/pmm2-client-2.41.0.tar.gz
```

**2）解包并重命名**

```bash
[root@mysql001 local]# cd /usr/local/
[root@mysql001 local]# tar -xvf pmm2-client-2.41.0.tar.gz
```

**3）编译安装**

```bash
[root@mysql001 local]# cd pmm2-client-2.41.0
[root@mysql001 pmm2-client-2.41.0]# export PMM_DIR=/usr/local/percona/pmm2
[root@mysql001 pmm2-client-2.41.0]# echo $PMM_DIR
/usr/local/percona/pmm2
[root@mysql001 pmm2-client-2.41.0]# ./install_tarball
Installing into /usr/local/percona/pmm2...
```

PMM Client的安装路径在/usr/local/percona/pmm2，目录结构如下：

```bash
[root@mysql001 pmm2]# cd /usr/local/percona/pmm2
[root@mysql001 pmm2]# ls
bin  collectors  config  exporters  tools
```

**4）添加环境变量**

```bash
[root@mysql001 pmm2]# vim /etc/profile
#添加
export PMM_DIR=/usr/local/percona/pmm2
export PATH=$PATH:$PMM_DIR/bin

[root@mysql001 pmm2]# source /etc/profile
```

至此，PMM Client安装完毕。

完成PMM Client安装后，需要做的事情有：

1. 向PMM服务器注册节点;
2. 根据类型配置和添加业务。

## 3.2 向PMM服务器注册节点

**1）注册pmm-agent**

```bash
[root@mysql001 ~]# pmm-agent setup --config-file=/usr/local/percona/pmm2/config/pmm-agent.yaml --server-address=192.168.131.60 --server-insecure-tls --server-username=admin --server-password=pmm123.

INFO[2024-01-29T19:10:55.365+08:00] Loading configuration file /usr/local/percona/pmm2/config/pmm-agent.yaml.  component=setup
INFO[2024-01-29T19:10:55.365+08:00] Temporary directory is not configured and will be set to /usr/local/percona/pmm2/tmp  component=setup
INFO[2024-01-29T19:10:55.365+08:00] Using /usr/local/percona/pmm2/exporters/node_exporter  component=setup
INFO[2024-01-29T19:10:55.365+08:00] Using /usr/local/percona/pmm2/exporters/mysqld_exporter  component=setup
INFO[2024-01-29T19:10:55.365+08:00] Using /usr/local/percona/pmm2/exporters/mongodb_exporter  component=setup
INFO[2024-01-29T19:10:55.365+08:00] Using /usr/local/percona/pmm2/exporters/postgres_exporter  component=setup
INFO[2024-01-29T19:10:55.365+08:00] Using /usr/local/percona/pmm2/exporters/proxysql_exporter  component=setup
INFO[2024-01-29T19:10:55.365+08:00] Using /usr/local/percona/pmm2/exporters/rds_exporter  component=setup
INFO[2024-01-29T19:10:55.365+08:00] Using /usr/local/percona/pmm2/exporters/azure_exporter  component=setup
INFO[2024-01-29T19:10:55.365+08:00] Using /usr/local/percona/pmm2/exporters/vmagent  component=setup
INFO[2024-01-29T19:10:55.365+08:00] Updating PMM Server address from "192.168.131.60" to "192.168.131.60:443".  component=setup
Checking local pmm-agent status...
pmm-agent is not running.
Registering pmm-agent on PMM Server...
Registered.
Configuration file /usr/local/percona/pmm2/config/pmm-agent.yaml updated.
Please start pmm-agent: `pmm-agent --config-file=/usr/local/percona/pmm2/config/pmm-agent.yaml`.
```

看到有`Registered`字眼说明祖册成功。

pmm-agent setup参数说明：

- setup: 用来启动PMM agent的setup 脚本，用于设置和启动 PMM agent。
- --config-file：指定PMM agent的配置文件的位置。
- --server-address: 这个参数指定了 PMM server 的地址。
- --server-insecure-tls: 这个参数指示 PMM agent 在与 PMM server 进行 TLS 通信时忽略证书验证。
- --server-username: 这个参数指定了用于连接到 PMM server 的用户名。
- --server-password: 这个参数指定了用于连接到 PMM server 的密码。

**2）配置pmm-agent日志**

默认情况下，pmm-agent将消息发送到stderr和系统日志(Linux上的syslogd或journald)。要配置单独的日志文件，需要编辑pmm-agent启动脚本。

pmm-agent启动脚本使用systemd系统来管理，配置日志文件需要注意：

- 脚本文件:/usr/lib/systemd/system/pmm-agent.service
- 参数:StandardError
- 默认值:“/var/log/pmm-agent.log”

```bash
[root@mysql001 config]# vim /usr/local/pmm2-client-2.41.0/config/pmm-agent.service
```

根据自己的环境修改`ExecStart`，添加`StandardError`。

修改后的内容如下：

```bash
[Unit]
Description=pmm-agent
After=time-sync.target network.target

[Service]
Type=simple
ExecStart=/usr/local/percona/pmm2/bin/pmm-agent --config-file=/usr/local/percona/pmm2/config/pmm-agent.yaml
Restart=always
RestartSec=2s
StandardError=file:/var/log/pmm-agent.log

[Install]
WantedBy=multi-user.target
```

重新加载systemd管理器配置：

```bash
[root@mysql001 config]# cp /usr/local/pmm2-client-2.41.0/config/pmm-agent.service /usr/lib/systemd/system/
[root@mysql001 config]# systemctl daemon-reload
```

**3）启动pmmagent**

```bash
[root@mysql001 config]# systemctl start pmm-agent
[root@mysql001 config]# systemctl status pmm-agent
● pmm-agent.service - pmm-agent
   Loaded: loaded (/usr/lib/systemd/system/pmm-agent.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2024-01-29 20:27:53 CST; 1s ago
 Main PID: 16665 (pmm-agent)
   CGroup: /system.slice/pmm-agent.service
           ├─16665 /usr/local/percona/pmm2/bin/pmm-agent --config-file=/usr/local/percona/pmm2/config/pmm-agent.yaml
           ├─16676 /usr/local/percona/pmm2/exporters/node_exporter --collector.bonding --collector.buddyinfo --collector.cpu --colle...
           └─16682 /usr/local/percona/pmm2/exporters/vmagent -envflag.enable=true -envflag.prefix=VMAGENT_ -httpListenAddr=127.0.0.1...

Jan 29 20:27:54 mysql001 pmm-agent[16665]: time="2024-01-29T20:27:54.208+08:00" level=info msg="ts=2024-01-29T12:27:54.208Z c...xporter
Jan 29 20:27:54 mysql001 pmm-agent[16665]: time="2024-01-29T20:27:54.215+08:00" level=info msg="2024-01-29T12:27:54.209Z\tinfo\tVict...
Jan 29 20:27:54 mysql001 pmm-agent[16665]: time="2024-01-29T20:27:54.222+08:00" level=info msg="2024-01-29T12:27:54.222Z\tinfo\tVict...
Jan 29 20:27:54 mysql001 pmm-agent[16665]: time="2024-01-29T20:27:54.238+08:00" level=info msg="2024-01-29T12:27:54.238Z\tinf...m_agent
Jan 29 20:27:54 mysql001 pmm-agent[16665]: time="2024-01-29T20:27:54.238+08:00" level=info msg="2024-01-29T12:27:54.238Z\tinf...m_agent
Jan 29 20:27:54 mysql001 pmm-agent[16665]: time="2024-01-29T20:27:54.238+08:00" level=info msg="2024-01-29T12:27:54.238Z\tinf...m_agent
Jan 29 20:27:54 mysql001 pmm-agent[16665]: time="2024-01-29T20:27:54.238+08:00" level=info msg="2024-01-29T12:27:54.238Z\tinf...m_agent
Jan 29 20:27:54 mysql001 pmm-agent[16665]: time="2024-01-29T20:27:54.239+08:00" level=info msg="2024-01-29T12:27:54.238Z\tinfo\tVict...
Jan 29 20:27:54 mysql001 pmm-agent[16665]: time="2024-01-29T20:27:54.239+08:00" level=info msg="2024-01-29T12:27:54.239Z\tinf...m_agent
Jan 29 20:27:54 mysql001 pmm-agent[16665]: time="2024-01-29T20:27:54.239+08:00" level=info msg="2024-01-29T12:27:54.239Z\tinf...m_agent
Hint: Some lines were ellipsized, use -l to show in full.
```

**4）设置开机自启**

```bash
[root@mysql001 config]# systemctl enable pmm-agent
Created symlink from /etc/systemd/system/multi-user.target.wants/pmm-agent.service to /usr/lib/systemd/system/pmm-agent.service.
```

## 3.3 查看pmm-agent监控

**1）检查pmm-agent状态**

```bash
[root@mysql001 config]# pmm-admin status
Agent ID : /agent_id/4de14939-751a-46b6-812b-3ad4cd0f970f
Node ID  : /node_id/2d9b4c14-c4c5-4432-9a2d-fce35a0633ac
Node name: mysql001

PMM Server:
        URL    : https://192.168.131.60:443/
        Version: 2.41.0

PMM Client:
        Connected        : true
        Time drift       : -53.076956ms
        Latency          : 403.674µs
        Connection uptime: 100
        pmm-admin version: 2.41.0
        pmm-agent version: 2.41.0
Agents:
        /agent_id/2d3b82ae-94be-43e5-b372-049a99a18b68 node_exporter Running 42000
        /agent_id/53f78922-dc94-412e-abbc-f5bda5e368b5 vmagent Running 42001
```

**2）查看监控数据**

![Alt text](image-7.png)

Node Names为主机名hostname。

如果想观察操作系统的详细监控数据，在以下面板查看：

![Alt text](image-8.png)

# 4 设置PMM来监视MySQ

## 4.1 服务添加介绍

PMM来监视MySQ的实现方式是PMM Client从MySQL数据库收集指标。

PMM添加MySQL服务的步骤如下：

1. 创建PMM帐户并设置权限。
2. 选择一个数据源:
   - 慢速查询日志；
   - 或者，性能模式。
3. 配置:
   - 查询响应时间;
   - 表统计；
   - 用户数据。
4. 添加服务。
5. 检查服务。

PMM还支持从PostgreSQL、MariaDB、Percona服务器和Percona XtraDB集群收集指标。详见官方文档：[https://docs.percona.com/percona-monitoring-and-management/setting-up/client/mysql.html](https://docs.percona.com/percona-monitoring-and-management/setting-up/client/mysql.html)

## 4.2 依赖检查

添加前确保已经完成如下事项：

- PMM服务器已经安装并运行，并且可以从客户机节点访问一个已知的IP地址。
- 已安装PMM Client，节点已在PMM Server上注册。
- 在PMM Client主机上拥有超级用户(root)访问权限。

## 4.3 添加MySQL服务

**1）创建PMM数据库用户**

On MySQL 8.0：

```sql
mysql>
CREATE USER 'pmm'@'192.168.131.99' IDENTIFIED BY 'Pmm123123.' WITH MAX_USER_CONNECTIONS 10;
GRANT SELECT, PROCESS, REPLICATION CLIENT, RELOAD, BACKUP_ADMIN ON *.* TO 'pmm'@'192.168.131.99';
```

On MySQL 5.7：

```sql
mysql>
CREATE USER 'pmm'@'192.168.131.99' IDENTIFIED BY 'Pmm123123.' WITH MAX_USER_CONNECTIONS 10;
GRANT SELECT, PROCESS, REPLICATION CLIENT, RELOAD ON *.* TO 'pmm'@'192.168.131.99';
```

查看用户：

```sql
mysql> select user,host from mysql.user where user = 'pmm';
+------+-----------+
| user | host      |
+------+-----------+
| pmm  | 192.168.131.99 |
+------+-----------+
mysql> show grants for pmm@192.168.131.99;
+-------------------------------------------------------------------------------+
| Grants for pmm@192.168.131.99                                                      |
+-------------------------------------------------------------------------------+
| GRANT SELECT, RELOAD, PROCESS, REPLICATION CLIENT ON *.* TO `pmm`@`192.168.131.99` |
| GRANT BACKUP_ADMIN ON *.* TO `pmm`@`192.168.131.99`                                |
+-------------------------------------------------------------------------------+
```

**2）选择并配置一个源**

指标源两种：慢查询日志和Performance_Schema。

慢速查询日志和Performance_Schema指标源各自的优缺点，如下：

![Alt text](image-9.png)

数据库不同版本的数据源建议：

![Alt text](image-10.png)


**1.慢查询日志源的设置方法**

设置慢查询日志的相关参数，动态设置：

```sql
mysql> 
SET GLOBAL slow_query_log = 1;
SET GLOBAL log_output = 'FILE';
SET GLOBAL long_query_time = 1;
SET GLOBAL log_slow_admin_statements = 1;
SET GLOBAL log_slow_slave_statements = 1;
```

或者，在配置文件my.cnf中添加这些参数：

```bash
slow_query_log=ON
log_output=FILE
long_query_time=1
log_slow_admin_statements=ON
log_slow_slave_statements=ON
```

下次重启后生效。

**注意**：动态设置好之后，也建议将这些参数固化到配置文件中，要不然下次重启之后会失效。

**2.Performance_Schema源的设置方法**

设置Performance_Schema的相关参数，动态设置：

```sql
mysql>
UPDATE performance_schema.setup_instruments SET ENABLED = 'YES', TIMED = 'YES' WHERE NAME LIKE 'statement/%';
UPDATE performance_schema.setup_consumers SET ENABLED = 'YES' WHERE NAME LIKE '%statements%';
```

或者，在配置文件my.cnf中添加这些参数：

```bash
performance_schema=ON
performance-schema-instrument='statement/%=ON'
performance-schema-consumer-events-statements-current=ON
performance-schema-consumer-events-statements-history=ON
performance-schema-consumer-events-statements-history-long=ON
performance-schema-consumer-statements-digest=ON
innodb_monitor_enable=all
```

events_transactions_current

下次重启后生效。

**注意**：动态设置好之后，也建议将这些参数固化到配置文件中，要不然下次重启之后会失效。

**3）添加服务**

```bash
[root@mysql001 config]# pmm-admin add mysql --username=pmm --password=Pmm123123. --query-source=slowlog mysql001-mysql 192.168.131.99:3306
MySQL Service added.
Service ID  : /service_id/60b91fd3-065f-41a9-892e-1eea8ca00d43
Service name: mysql001-mysql

Table statistics collection enabled (the limit is 1000, the actual table count is 365).
```

参数说明：

- pmm-admin add mysql：添加一个新的MySQL PMM服务。
- --username=pmm：MySQL用户名。
- --password=Pmm123123：MySQL用户名密码。
- --query-source=slowlog：指标源是慢查询日志。
- mysql001-mysql：服务名，默认是{hostname}-mysql。
- 192.168.131.99:3306：这是MySQL实例的地址和端口。

**4）检查服务状态**

PMM用户界面查看，依次点击`⚙`→`Configuration`→`Inventory`：

![Alt text](image-11.png)


也可在命令行检查：

```
[root@mysql001 config]# pmm-admin inventory list services --service-type=mysql
Services list.

Service type           Service name         Address and Port  Service ID
MySQL                  mysql001-mysql       192.168.131.99:3306 /service_id/60b91fd3-065f-41a9-892e-1eea8ca00d43
```

**5）查看MySQL实例监控页面**

![Alt text](image-12.png)

# 5 QAN

QAN全称Query Analytics，此仪表板显示查询是如何执行的，以及它们在哪里花费时间。可以帮助我们分析一段时间内的数据库查询，可用于优化数据库性能，快速找到并解决问题的根源。

在工作中可能看得最多的就是这块面板了，因为影响数据库性能百分之九十的原因是查询问题，也就是慢SQL。有时候一个慢SQL就能拖垮整个库，进而影响业务系统的正常运转。

因此，应该好好利用Query Analytics这个功能。

Query Analytics面板如下：

![Alt text](image-13.png)

**1）过滤**

左边栏的Filters可以按不同维度进行查询过滤，例如数据库、节点名、服务名等：

![Alt text](image-14.png)

**2）sql详情**

点击total列表里的sql，右下栏显示sql的详情，包括记录数、查询时间、锁表时间等指标：

![Alt text](image-15.png)

