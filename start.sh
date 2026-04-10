#!/bin/bash
# ==========================================
# SaveAny 万能视频下载器 - 一键启动脚本
# 部署位置: /opt/video-downloader
# ==========================================

set -e

APP_DIR="/opt/video-downloader"

echo "=========================================="
echo "SaveAny 万能视频下载器 - 一键启动"
echo "=========================================="

# 进入应用目录
cd $APP_DIR

# 停止旧服务（如果存在）
echo "[1/5] 停止旧服务..."
docker-compose down 2>/dev/null || true

# 杀掉占用端口的进程（80和8000）
echo "[2/5] 清理端口..."
kill_port_80() {
    pid=$(lsof -ti:80 2>/dev/null || ss -tlnp | grep ':80 ' | awk '{print $NF}' | grep -oP 'pid=\K[0-9]+')
    [ -n "$pid" ] && kill $pid && echo "  已停止占用80端口的进程 (PID: $pid)"
}
kill_port_80

kill_port_8000() {
    pid=$(lsof -ti:8000 2>/dev/null || ss -tlnp | grep ':8000 ' | awk '{print $NF}' | grep -oP 'pid=\K[0-9]+')
    [ -n "$pid" ] && kill $pid && echo "  已停止占用8000端口的进程 (PID: $pid)"
}
kill_port_8000

# 清理旧容器
echo "[3/5] 清理旧容器..."
docker container prune -f 2>/dev/null || true

# 重新构建并启动
echo "[4/5] 构建并启动服务..."
docker-compose up -d --build

# 等待服务启动
echo "[5/5] 等待服务就绪..."
sleep 5

# 检查服务状态
echo ""
echo "=========================================="
echo "服务状态:"
echo "=========================================="
docker-compose ps

echo ""
echo "=========================================="
echo "访问地址:"
echo "=========================================="
echo "  前端页面: http://$(hostname -I | awk '{print $1}'):80"
echo "  后端 API: http://$(hostname -I | awk '{print $1}'):8000"
echo "  API 文档: http://$(hostname -I | awk '{print $1}'):8000/docs"
echo ""
echo "管理员账号: admin@admin.com / admin123"
echo "=========================================="

# 健康检查
echo ""
echo "健康检查..."
if curl -s http://localhost:8000/api/health | grep -q "ok"; then
    echo "✅ 后端服务正常"
else
    echo "⚠️ 后端服务可能未就绪，请查看日志: docker-compose logs -f"
fi
