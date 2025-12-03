+++
title = "Shell 重定向操作符：<, <<, <<<, < <() 的区别"
date = 2025-12-02T10:30:00+08:00
draft = false
tags = ["Shell", "Bash", "Linux", "重定向"]
categories = []
summary = "深入理解 Shell 中的四种输入重定向操作符，掌握它们的使用场景和最佳实践"
+++

在编写 Shell 脚本时，你可能经常看到 `<`、`<<`、`<<<` 和 `< <()` 这几个看起来相似的操作符。它们都与输入有关，但用途和行为却大不相同。本文将详细解析这些操作符的区别，帮助你在实际场景中做出正确的选择。

### 为什么需要这么多重定向操作符？

在 Unix 哲学中，一切皆文件。Shell 提供了多种重定向操作符来应对不同的输入场景：

- 从**文件**读取
- 嵌入**多行文本**
- 处理**单行字符串**
- 使用**命令输出**作为输入

让我们逐一深入探讨。

---

### 1. 输入重定向


> `<` 是最基础的输入重定向操作符，它将文件内容重定向到命令的标准输入（stdin）。

**语法**

```bash
command < file
```

**实际示例**

```bash
# 统计文件行数
wc -l < access.log

# 排序并去重
sort < names.txt | uniq

# 逐行读取文件
while IFS= read -r line; do
  echo "处理: $line"
done < data.txt
```

**使用场景**

- 读取配置文件
- 处理日志文件
- 批量数据处理
- 任何需要从文件读取的场景

**注意事项**

```bash
# 正确：从文件读取
while read line; do
  ((count++))
done < file.txt
echo $count  # 计数正确

# 错误：使用管道会创建子shell
cat file.txt | while read line; do
  ((count++))
done
echo $count  # 输出 0（变量丢失）
```

---

### 2. Here Document

**基本概念**

`<<` 用于创建 Here Document（此处文档），允许在脚本中嵌入多行文本，直到遇到指定的结束标记。

**语法**

```bash
command << DELIMITER
  多行内容
  可以包含变量 $VAR
DELIMITER
```

**实际示例**

生成配置文件
```bash
cat > /etc/nginx/sites-available/mysite << EOF
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
```

执行 SQL 脚本

```bash
mysql -u root -p$PASSWORD << SQL
USE mydb;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100)
);
INSERT INTO users (username, email) 
VALUES ('alice', 'alice@example.com');
SQL
```

生成 Python 脚本

```bash
python3 << 'PYTHON'
import sys
import json

data = {"name": "test", "value": 42}
print(json.dumps(data, indent=2))
PYTHON
```

变量展开控制

```bash
NAME="Alice"

# 不加引号：变量会展开
cat << EOF
Hello, $NAME!
EOF
# 输出: Hello, Alice!

# 加单引号：变量不展开
cat << 'EOF'
Hello, $NAME!
EOF
# 输出: Hello, $NAME!

# 加双引号：变量会展开（同不加引号）
cat << "EOF"
Hello, $NAME!
EOF
# 输出: Hello, Alice!
```

**变体 `<<-` 忽略前导制表符**

```bash
# 使用 <<- 可以缩进代码，提高可读性
if true; then
    cat <<- EOF
	这行前面有制表符
	会被自动去掉
	EOF
fi
```

**注意**：`<<-` 只能去除**制表符（Tab）**，不能去除空格！

**使用场景**

- 生成配置文件（nginx, apache, systemd）
- 编写安装脚本（嵌入 SQL、Python 等）
- 创建邮件模板
- 生成文档或 README
- 多行提示信息

---

### 3. Here String

**基本概念**

`<<<` 是 Bash 特有的 Here String 操作符，用于将单行字符串作为标准输入传递给命令。

**语法**

```bash
command <<< "string"
```

**实际示例**

快速测试
```bash
# 测试 grep
grep "world" <<< "hello world"

# 计算字符串长度
wc -c <<< "test string"

# Base64 编码
base64 <<< "encode this"

# 计算表达式
bc <<< "scale=2; 10/3"
```

读取字符串到变量

```bash
# 分割字符串
IFS=':' read -r user host port <<< "admin:192.168.1.1:22"
echo "User: $user, Host: $host, Port: $port"

# 读取多个值
read x y z <<< "1 2 3"
echo "x=$x, y=$y, z=$z"
```

处理变量内容

```bash
# 遍历空格分隔的值
PACKAGES="vim git curl"
while read package; do
  echo "Installing: $package"
done <<< "$PACKAGES"

# 检查变量内容
LOG="ERROR: Connection failed"
if grep -q "ERROR" <<< "$LOG"; then
  echo "发现错误"
fi
```

与 awk/sed 配合

```bash
# 提取字段
awk '{print $2}' <<< "field1 field2 field3"

# 文本替换
sed 's/foo/bar/' <<< "foo is here"
```

**使用场景**

- 快速测试命令
- 处理变量内容
- 避免创建临时文件
- 单行文本处理

**注意事项**

```bash
# 正确：变量加引号
<<< "$variable"

# 可能有问题：不加引号会导致分词和通配符展开
<<< $variable
```

---

### 4. 进程替换（Process Substitution）

**基本概念**

`< <(command)` 是 Bash 的进程替换功能，它将命令的输出作为"文件"传递给另一个命令，但**不创建子shell**。

**工作原理**

```bash
# 进程替换会创建类似 /dev/fd/63 的临时文件描述符
echo <(ls)
# 输出: /dev/fd/63
```

**实际示例**

避免子shell问题

```bash
# ❌ 使用管道：变量在子shell中，循环后丢失
total=0
seq 1 100 | while read num; do
  ((total += num))
done
echo $total  # 输出 0

# ✅ 使用进程替换：变量保留
total=0
while read num; do
  ((total += num))
done < <(seq 1 100)
echo $total  # 输出 5050
```

比较两个命令输出

```bash
# 比较两个目录的文件列表
diff <(ls /dir1) <(ls /dir2)

# 比较排序后的内容
diff <(sort file1.txt) <(sort file2.txt)

# 比较 Git 分支
diff <(git show main:file.txt) <(git show develop:file.txt)
```

合并多个输入源

```bash
# paste 命令按列合并
paste <(seq 1 5) <(seq 10 14) <(seq 20 24)
# 输出:
# 1    10    20
# 2    11    21
# 3    12    22
# 4    13    23
# 5    14    24

# 合并处理结果
paste <(cut -f1 data.csv) <(cut -f3 data.csv)
```

复杂数据处理

```bash
# 统计所有 .txt 文件的总行数
total=0
while read lines filename; do
  ((total += lines))
  echo "$filename: $lines 行"
done < <(wc -l *.txt)
echo "总计: $total 行"

# 实时监控日志并计数
error_count=0
while read line; do
  if [[ "$line" =~ ERROR ]]; then
    ((error_count++))
  fi
done < <(tail -f /var/log/app.log)
```

**使用场景**

- 需要在循环中保留变量
- 比较多个命令输出
- 动态生成输入数据
- 避免创建临时文件
- 需要多个输入源的场景

**进阶：多重进程替换**

```bash
# 三向比较
diff3 <(sort file1) <(sort file2) <(sort file3)

# 使用 comm 比较
comm <(sort a.txt) <(sort b.txt)

# 复杂的数据管道
join <(sort users.txt) <(sort emails.txt) > merged.txt
```

---

### 实战案例：配置文件同步脚本

让我们看一个真实的例子，展示何时使用哪种重定向操作符：

```bash
#!/usr/bin/env bash

CONFIG_FILE="$HOME/.sync.cfg"
SUCCESS_COUNT=0
FAIL_COUNT=0

# 使用 << 生成帮助文档
show_help() {
  cat << 'HELP'
配置文件同步工具
用法: sync.sh <remote_host>

配置文件格式:
  ~/.zshrc
  ~/.vimrc
  ~/.tmux.conf
HELP
}

# 使用 < 读取配置文件（避免子shell）
while IFS= read -r line; do
  # 跳过注释和空行
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
  
  # 使用 <<< 快速测试
  if grep -q "^~" <<< "$line"; then
    line="${line/#\~/$HOME}"
  fi
  
  # 使用 < <() 处理通配符展开并保留变量
  while IFS= read -r -d '' file; do
    scp "$file" "$REMOTE_HOST:" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
  done < <(find "$(dirname "$line")" -maxdepth 1 -name "$(basename "$line")" -print0)
  
done < "$CONFIG_FILE"

# 使用 << 生成报告
cat << EOF
========================================
同步完成
成功: $SUCCESS_COUNT
失败: $FAIL_COUNT
========================================
EOF
```

**为什么这样设计？**

1. `<< 'HELP'` - 生成多行帮助文档，单引号防止变量展开
2. `done < "$CONFIG_FILE"` - 避免管道创建子shell，保留计数器
3. `<<< "$line"` - 快速测试字符串是否匹配模式
4. `< <(find ...)` - 处理通配符同时保留变量
5. `<< EOF` - 生成格式化的报告

---

### 快速参考表

| 操作符 | 名称 | 输入来源 | 行数 | Bash 专有 | 子Shell | 典型场景 |
|--------|------|----------|------|-----------|---------|----------|
| `<` | 输入重定向 | 文件 | 多行 | ❌ | ❌ | 读取文件 |
| `<<` | Here Document | 脚本内嵌 | 多行 | ❌ | ❌ | 生成配置/文档 |
| `<<<` | Here String | 字符串 | 单行 | ✅ | ❌ | 快速测试 |
| `< <()` | 进程替换 | 命令输出 | 多行 | ✅ | ❌ | 动态输入+保留变量 |

---

### 常见陷阱与最佳实践

1. Here Document 的结束标记必须顶格

```bash
# ❌ 错误：结束标记前有空格
cat << EOF
  content
  EOF

# ✅ 正确
cat << EOF
  content
EOF

# ✅ 或使用 <<- 并用 Tab 缩进
cat <<- EOF
	content
	EOF
```

2. Here String 需要注意分词

```bash
VAR="word1 word2 word3"

# ❌ 不加引号可能导致问题
read x <<< $VAR  # 只读取第一个词

# ✅ 加引号
read x <<< "$VAR"  # 读取完整字符串
```

3. 进程替换不支持 POSIX sh

```bash
# ❌ 在 #!/bin/sh 中不可用
#!/bin/sh
while read line; do
  echo $line
done < <(ls)

# ✅ 需要使用 bash
#!/bin/bash
while read line; do
  echo $line
done < <(ls)
```

4. 避免不必要的 cat

```bash
# ❌ 多余的 cat
cat file.txt | while read line; do
  echo $line
done

# ✅ 直接重定向
while read line; do
  echo $line
done < file.txt
```

---

### 总结

选择正确的重定向操作符，关键在于理解**输入来源**和**是否需要保留变量**：

- **读取文件** → `< file`
- **嵌入多行文本** → `<< EOF`
- **处理单行字符串** → `<<< "string"`
- **动态输入 + 保留变量** → `< <(command)`

掌握这些操作符，能让你的 Shell 脚本更加简洁、高效且可维护。

---

### 参考资料

- [Bash Reference Manual - Redirections](https://www.gnu.org/software/bash/manual/html_node/Redirections.html)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Process Substitution in Bash](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html)

