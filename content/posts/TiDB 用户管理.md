+++
title = 'TiDB 用户管理'
date = '2025-03-18 17:22:52'
categories = []
tags = ['TiDB']
draft = false
summary = ''
+++

## 创建新用户

```sql
CREATE USER 'user'@'%' IDENTIFIED BY 'password';
```

## 设置用户权限

```sql
-- 部分权限
GRANT SELECT,INSERT ON database.* TO 'user'@'%';
-- 所有权限
GRANT ALL PRIVILEGES ON database.* TO 'user'@'%';
```

## 修改用户密码

```sql
SET PASSWORD FOR 'root'@'%' = 'xxx';
```

## 刷新权限

```sql
FLUSH PRIVILEGES;
```

## 删除用户

```
DROP USER 'user'@'host';
```

