+++
title = 'TiDB Br 全量备份与恢复'
date = '2025-09-17 16:57:06'
lastmodified = ''
categories = []
tags = []
draft = false
summary = '使用 tiup br 命令备份全库'
+++

#### 备份

```
tiup br backup full \
  --pd "127.0.0.1:2379" \
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

