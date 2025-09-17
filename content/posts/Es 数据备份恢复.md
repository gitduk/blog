+++
title = 'Es 数据备份恢复'
date = '2025-09-17 14:29:35'
lastmodified = ''
categories = []
tags = ['Es']
draft = false
summary = '使用 es 内置的 snapshot 功能备份和恢复索引记录'

+++

## snapshot 备份

创建 snapshot 仓库 - snapshot_repo

```
PUT /_snapshot/snapshot_repo
{
  "type": "fs",
  "settings": {
    "location": "/path/to/repo",
    "compress": true
  }
}
```

查看 snapshot 仓库

```
GET /_snapshot?pretty
```

创建 snapshot

```
PUT /_snapshot/snapshot_repo/snapshot_name
{
  "indices": "indices_1,indices_2,indices_3",
  "ignore_unavailable": true,
  "include_global_state": false
}
```

## 从 snapshot 恢复索引

查看 snapshot repo 状态

```
GET /_snapshot/snapshot_repo/snapshot_name/_all?pretty
```

恢复索引

```
POST https://127.0.0.1:9200/_snapshot/es_snapshot/similar_search/_restore
{
  "indices": "indices_1,indices_2,indices_3"
}
```

