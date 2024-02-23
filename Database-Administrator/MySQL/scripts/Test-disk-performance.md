# 测试磁盘写入速度

dd命令一次性向硬盘写入1GB数据，测试test.img所在磁盘的写入速度。

```bash
dd if=/dev/zero of=test.img bs=1G count=1 conv=fdatasync
```

**注意**：避免使用 dd 直接写入块设备（例如：/dev/sda），因为它可能会擦除数据。

参数说明：

- /dev/zero: 提供空字符的输入文件。

- test.img: 输出文件。

- bs=1G: 块大小。

- count=1: 块数。

- conv=fdatasync: 跳过缓存，直接写磁盘，相当于选项 “oflag=dsync”。

# 测试磁盘的读取速度

