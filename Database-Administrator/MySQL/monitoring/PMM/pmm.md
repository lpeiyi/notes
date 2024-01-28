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

# 2 安装PMM Server

官方提供了多种安装方式，优缺点如下：

![Alt text](image-1.png)

最常用的方式是Docker。

**1）安装docker**

