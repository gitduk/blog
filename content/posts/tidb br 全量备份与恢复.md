+++
title = 'TiDB Br 全量备份与恢复'
date = '2025-09-17 16:57:06'
lastmodified = '2025-10-15 11:00:00'
categories = []
tags = []
draft = false
summary = '使用 tiup br 命令备份全库'
+++

#### 备份

```
tiup br backup full \
  --pd "127.0.0.1:2379" \
  --with-sys-table \
  --storage "local:///data/backup/br_full_$(date +%F)" \
  --ratelimit 120 \
  --log-file backup.log
```

#### 恢复

```
tiup br restore full \
  --pd "127.0.0.1:2379" \
  --storage "local:///path/to/br_full" \
  --ratelimit 120 \
  --log-file restore.log
```

- ratelimit 单位是 MB/s
- --with-sys-table恢复集群数据的同时恢复部分系统表的数据，包括恢复账号权限数据、SQL Binding 信息和统计信息数据，但暂不支持恢复统计信息表 (mysql.stat_*) 和系统参数 (mysql.tidb, mysql.global_variables) 等信息。

