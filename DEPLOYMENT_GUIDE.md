# SaveAny 万能视频下载器 - Docker 部署指南

## 一、项目信息

| 项目 | 值 |
|------|-----|
| 项目名称 | SaveAny - AI 万能视频下载总结器 |
| GitHub | https://github.com/liyupi/free-video-downloader |
| 技术栈 | Vue 3 + FastAPI + yt-dlp + DeepSeek + Docker |
| 支持平台 | 1800+ 视频网站（B站、YouTube、抖音等） |

## 二、快速部署

### 方式一：Docker Compose 一键部署

```bash
# 克隆项目
git clone https://github.com/liyupi/free-video-downloader.git
cd free-video-downloader

# 配置环境变量
cp .env.example .env
# 编辑 .env 填入 DEEPSEEK_API_KEY

# 启动服务
docker-compose up -d
```

### 方式二：分开构建启动

```bash
# 1. 启动后端
cd backend
docker build -t video-downloader-backend .
docker run -d -p 8000:8000 --name video-backend \
  --env-file ../.env \
  video-downloader-backend

# 2. 启动前端
cd ../frontend
docker build -t video-downloader-frontend .
docker run -d -p 80:80 --name video-frontend \
  video-downloader-frontend
```

## 三、服务访问

| 服务 | 地址 |
|------|------|
| 前端页面 | http://localhost:80 |
| 后端 API | http://localhost:8000 |
| API 文档 | http://localhost:8000/docs |
| 健康检查 | http://localhost:8000/api/health |

### 默认管理员账号

| 项目 | 值 |
|------|-----|
| 邮箱 | `admin@admin.com` |
| 密码 | `admin123` |
| VIP状态 | 永久VIP（无限制使用AI总结）|

## 四、环境变量

创建 `.env` 文件：

```bash
# DeepSeek API Key（必需，用于 AI 视频总结）
DEEPSEEK_API_KEY=sk-your-api-key-here

# GitHub Token（可选，用于增强功能）
GITHUB_TOKEN=
```

获取 DeepSeek API Key：https://platform.deepseek.com/api_keys

## 五、Docker 配置说明

### 后端配置 (backend/Dockerfile)

```dockerfile
FROM python:3.11-slim
# 包含 ffmpeg 支持音视频处理
# 安装 fastapi, uvicorn, yt-dlp 等依赖
```

### 前端配置 (frontend/Dockerfile)

```dockerfile
# 构建阶段：node:20-alpine 构建 Vue 项目
# 生产阶段：nginx:alpine 运行静态页面
# 自动代理 /api/* 请求到后端
```

### docker-compose.yml

```yaml
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
    volumes:
      - ./backend:/app
      - downloads:/app/downloads

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend
```

## 六、常用命令

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f
docker-compose logs -f backend    # 仅后端
docker-compose logs -f frontend   # 仅前端

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 重新构建
docker-compose up -d --build

# 进入容器
docker exec -it video-backend bash
```

## 七、故障排查

### 检查服务状态
```bash
docker ps
curl http://localhost:8000/api/health
```

### 查看后端日志
```bash
docker logs video-backend --tail=100
```

### 前端 API 跨域问题
前端已配置直连后端 IP，部署时如遇 CORS 问题，请检查：
1. 后端 CORS 配置（main.py）
2. 前端 API_BASE 地址配置

### 登录报错 500
检查 VIP 到期时间是否正确：
```python
# 进入容器检查
docker exec -it video-backend bash
python3 -c "import sys; sys.path.insert(0, '/app'); from database import get_user_by_email; u = get_user_by_email('admin@admin.com'); print(u)"
```

## 八、管理员账号

### 创建管理员账号

部署后需要手动创建管理员账号：

```bash
# 创建脚本
cat > /tmp/create_admin.py << 'EOF'
import sys
sys.path.insert(0, '/app')
from database import create_user, init_db
import bcrypt

init_db()
password = "admin123"
hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
user = create_user("admin@admin.com", hashed)
print(f"管理员已创建: admin@admin.com / {password}")
EOF

# 执行
docker cp /tmp/create_admin.py video-backend:/app/create_admin.py
docker exec video-backend python3 /app/create_admin.py
rm /tmp/create_admin.py
```

### 设置永久VIP

```bash
cat > /tmp/set_vip.py << 'EOF'
import sys
sys.path.insert(0, '/app')
from database import get_db, get_user_by_email

with get_db() as db:
    db.execute("UPDATE users SET is_vip = 1, vip_expire_at = NULL WHERE email = 'admin@admin.com'")

u = get_user_by_email('admin@admin.com')
print(f"VIP状态: {u['is_vip']}, 到期: {u['vip_expire_at']}")
print("✅ 已设置为永久VIP！")
EOF

docker cp /tmp/set_vip.py video-backend:/app/set_vip.py
docker exec video-backend python3 /app/set_vip.py
rm /tmp/set_vip.py
```

## 九、数据持久化

- **数据库**: SQLite，位于容器内 `/app/data/app.db`
- **下载目录**: 挂载卷 `downloads`，映射到 `/app/downloads`

## 十、版本信息

- 部署时间: 2026-04-10
- Docker 镜像版本: Python 3.11-slim, nginx:alpine
- 前端构建: Node 20, Vite 7.x

## 十一、注意事项

1. **API Key 安全**: 不要将 `.env` 文件提交到 GitHub
2. **ffmpeg**: Docker 镜像已内置，无需单独安装
3. **端口占用**: 确保 80 和 8000 端口未被占用
4. **防火墙**: 生产环境请开放必要端口
5. **管理员账号**: 部署后需手动创建（见第八节）

---

有问题请提交 Issue: https://github.com/liyupi/free-video-downloader/issues
