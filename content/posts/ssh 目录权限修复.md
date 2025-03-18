+++
title = 'ssh 目录权限修复'
date = '2024-05-09 17:19:20'
categories = []
tags = ['ssh']
draft = false
summary = ''
+++

```shell
sudo chmod 700 $HOME/.ssh
sudo chmod 600 $HOME/.ssh/authorized_keys
sudo chmod go-w $HOME/
```

