+++
title = 'Nginx 代理 openai api'
date = 2023-07-04T15:45:13+08:00
draft = false
summary = 'Ng 反代 openai api'
+++

## 安装 Nginx

ubuntu: `sudo apt install nginx`

## 配置 Openai 反向代理

在目录 `/etc/nginx/conf.d` 下创建文件 `openai.conf`

/etc/nginx/conf.d/openai.conf

```
server {
    listen 8000;

    location /v1/ {
        proxy_pass <https://api.openai.com/v1/>; 	# OpenAI API URL
        proxy_ssl_server_name on; 				# 避免出现反代https域名出现502错误
        proxy_buffering off; 					# 关闭缓存实现打字机效果
    }
}
```

重启 nginx 服务： `sudo systemctl reload nginx`

## 使用 Openai Api 接口

```python
import requests

# 设置 requests 会话
requests.adapters.DEFAULT_RETRIES = 5
session = requests.session()
session.keep_alive = False

API_KEY = "sk-xxxxxxx"

# 设置 OpenAI API 密钥
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {API_KEY}"
}

def send_request(data):
    """
    发送请求到 OpenAI API 并返回响应。
    """

    try:
        response = session.post(
            "http://[your nginx server ip address]:8000/v1/chat/completions",
            headers=headers,
            data=json.dumps(data),
            timeout=30
        )
    except Exception as e:
        raise
    else:
        return response
```

