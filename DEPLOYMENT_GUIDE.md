# SaveAny 万能视频下载器 - 部署文档

## 一、项目信息

| 项目 | 值 |
|------|-----|
| 项目名称 | SaveAny - AI 万能视频下载总结器 |
| GitHub | https://github.com/kk51740/free-video-downloader |
| 技术栈 | Vue 3 + FastAPI + yt-dlp + DeepSeek + Docker |
| 支持平台 | 1800+ 视频网站（B站、YouTube、抖音等） |

## 二、服务器信息

| 项目 | 值 |
|------|-----|
| 服务器 IP | 192.168.68.100 |
| SSH 用户 | root |
| 项目目录 | /opt/video-downloader |
| 前端端口 | 80 |
| 后端端口 | 8000 |

## 三、访问地址

| 服务 | 地址 |
|------|------|
| 前端页面 | http://192.168.68.100:80 |
| 后端 API | http://192.168.68.100:8000 |
| API 文档 | http://192.168.68.100:8000/docs |
| 健康检查 | http://192.168.68.100:8000/api/health |

## 四、账号密码

### 4.1 管理员账号

| 项目 | 值 |
|------|-----|
| 邮箱 | admin@admin.com |
| 密码 | admin123 |
| VIP状态 | 永久VIP（无限制使用AI总结）|

### 4.2 API Keys（敏感信息，请查看服务器上的 .env 文件）

| 项目 | 说明 |
|------|-----|
| DeepSeek API Key | 用于AI视频总结功能 |
| GitHub Token | GitHub增强功能 |

> **注意**: API Keys 存储在服务器 `/opt/video-downloader/.env` 文件中，请勿提交到 GitHub。

### 4.3 SSH 登录

```bash
ssh root@192.168.68.100
```

## 五、一键启动

### 5.1 Linux/macOS

```bash
# 方式一：使用一键脚本
scp start.sh root@192.168.68.100:/opt/video-downloader/
ssh root@192.168.68.100
cd /opt/video-downloader
chmod +x start.sh
./start.sh

# 方式二：手动启动
cd /opt/video-downloader
docker-compose down
docker-compose up -d --build
```

### 5.2 Windows PowerShell

```powershell
# 本地执行
scp start.ps1 root@192.168.68.100:/opt/video-downloader/
ssh root@192.168.68.100
cd /opt/video-downloader
powershell -File start.ps1
```

### 5.3 远程一键部署（从本地执行）

```bash
# Linux/macOS
ssh root@192.168.68.100 "cd /opt/video-downloader && docker-compose down && docker-compose up -d --build"

# Windows PowerShell
ssh root@192.168.68.100 "cd /opt/video-downloader; docker-compose down; docker-compose up -d --build"
```

## 六、常用运维命令

### 6.1 服务管理

```bash
# 进入服务器
ssh root@192.168.68.100

# 进入项目目录
cd /opt/video-downloader

# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 重新构建并启动
docker-compose up -d --build

# 查看服务状态
docker-compose ps
```

### 6.2 日志查看

```bash
# 查看所有日志
docker-compose logs -f

# 查看后端日志
docker-compose logs -f backend

# 查看前端日志
docker-compose logs -f frontend

# 查看最近100行日志
docker-compose logs --tail=100
```

### 6.3 容器操作

```bash
# 进入后端容器
docker exec -it video-downloader-backend bash

# 进入数据库
docker exec -it video-downloader-backend python3 -c "
import sys
sys.path.insert(0, '/app')
from database import get_db
db = get_db()
for row in db.execute('SELECT * FROM users'):
    print(row)
"

# 查看容器内部文件
docker exec video-downloader-backend ls -la /app

# 重启容器
docker restart video-downloader-backend
docker restart video-downloader-frontend
```

## 七、环境变量

`.env` 文件位置: `/opt/video-downloader/.env`

```bash
# DeepSeek API Key（必需，用于 AI 视频总结）
DEEPSEEK_API_KEY=sk-your-deepseek-api-key

# GitHub Token（可选，用于增强功能）
GITHUB_TOKEN=
```

> **重要**: `.env` 文件包含敏感信息，已在 `.gitignore` 中忽略，请勿提交到 GitHub。

### 修改环境变量

```bash
# 编辑 .env 文件
vi /opt/video-downloader/.env

# 重启服务使配置生效
cd /opt/video-downloader
docker-compose down
docker-compose up -d
```

### 查看服务器上的 Keys

```bash
ssh root@192.168.68.100 "cat /opt/video-downloader/.env"
```

## 八、Docker 配置

### 8.1 docker-compose.yml

```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: video-downloader-backend
    ports:
      - "8000:8000"
    environment:
      - DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY:-sk-your-api-key}
      - GITHUB_TOKEN=${GITHUB_TOKEN:-}
    volumes:
      - ./backend:/app
      - downloads:/app/downloads
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: video-downloader-frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  downloads:
```

### 8.2 数据目录

| 位置 | 说明 |
|------|------|
| /opt/video-downloader/backend | 后端代码目录 |
| /opt/video-downloader/frontend | 前端代码目录 |
| /opt/video-downloader/backend/data/app.db | SQLite 数据库 |
| /opt/video-downloader/backend/downloads | 下载文件目录 |

## 九、故障排查

### 9.1 检查服务状态

```bash
# 查看容器状态
docker-compose ps

# 健康检查
curl http://localhost:8000/api/health

# 预期输出: {"status":"ok","message":"万能视频下载器服务运行中"}
```

### 9.2 端口占用问题

如果启动时报 "端口已被占用"：

```bash
# 查看端口占用
netstat -tlnp | grep ':80 '
netstat -tlnp | grep ':8000 '

# 杀掉占用进程
kill <PID>
```

### 9.3 登录报错 500

检查 VIP 到期时间是否正确：

```bash
docker exec -it video-downloader-backend python3 -c "
import sys
sys.path.insert(0, '/app')
from database import get_user_by_email
u = get_user_by_email('admin@admin.com')
print('is_vip:', u['is_vip'])
print('vip_expire_at:', u['vip_expire_at'])
"
```

### 9.4 清理重建

```bash
cd /opt/video-downloader
docker-compose down -v  # -v 会删除数据卷
docker system prune -f
docker-compose up -d --build
```

## 十、版本信息

| 项目 | 值 |
|------|-----|
| 部署时间 | 2026-04-10 |
| Docker 镜像 | Python 3.11-slim, nginx:alpine |
| 前端构建 | Node 20, Vite |
| 后端框架 | FastAPI + Uvicorn |
| 数据库 | SQLite |

## 十一、快速参考卡

```
┌─────────────────────────────────────────────────────────────┐
│                    SaveAny 快速参考                          │
├─────────────────────────────────────────────────────────────┤
│ 服务器IP:    192.168.68.100                                  │
│ 前端地址:    http://192.168.68.100:80                        │
│ 后端地址:    http://192.168.68.100:8000                     │
│                                                              │
│ 管理员:      admin@admin.com                                  │
│ 密码:        admin123                                        │
│ VIP:        永久VIP                                          │
│                                                              │
│ SSH:        ssh root@192.168.68.100                          │
│ 项目目录:    /opt/video-downloader                           │
│                                                              │
│ 启动命令:    cd /opt/video-downloader && docker-compose up -d│
│ 日志:       docker-compose logs -f                          │
│ 状态:       docker-compose ps                                │
└─────────────────────────────────────────────────────────────┘
```

## 十二、备份与恢复

### 12.1 备份数据

```bash
# 备份数据库
ssh root@192.168.68.100 "cp /opt/video-downloader/backend/data/app.db /opt/video-downloader/backend/data/app.db.backup-$(date +%Y%m%d)"

# 打包整个项目
ssh root@192.168.68.100 "cd /opt && tar -czvf video-downloader-backup.tar.gz video-downloader"
```

### 12.2 恢复数据

```bash
# 恢复数据库
ssh root@192.168.68.100 "cp /opt/video-downloader/backend/data/app.db.backup-20260410 /opt/video-downloader/backend/data/app.db"

# 解压备份
ssh root@192.168.68.100 "cd /opt && tar -xzvf video-downloader-backup.tar.gz"
```

---

有问题请提交 Issue: https://github.com/kk51740/free-video-downloader/issues
