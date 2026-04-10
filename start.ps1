# ==========================================
# SaveAny 万能视频下载器 - 一键启动脚本 (Windows PowerShell)
# 部署位置: /opt/video-downloader
# 使用方式: .\start.ps1
# ==========================================

$APP_DIR = "/opt/video-downloader"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "SaveAny 万能视频下载器 - 一键启动" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 进入应用目录
Set-Location $APP_DIR

# 停止旧服务
Write-Host "[1/5] 停止旧服务..." -ForegroundColor Yellow
docker-compose down 2>$null

# 获取服务器IP
$ServerIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.InterfaceAlias -notlike "*Docker*" } | Select-Object -First 1).IPAddress
if (-not $ServerIP) {
    $ServerIP = "localhost"
}

# 重新构建并启动
Write-Host "[2/5] 构建并启动服务..." -ForegroundColor Yellow
docker-compose up -d --build

# 等待服务启动
Write-Host "[3/5] 等待服务就绪..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# 检查服务状态
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "服务状态:" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
docker-compose ps

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "访问地址:" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  前端页面: http://$ServerIP`:80"
Write-Host "  后端 API: http://$ServerIP`:8000"
Write-Host "  API 文档: http://$ServerIP`:8000/docs"
Write-Host ""
Write-Host "管理员账号: admin@admin.com / admin123" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Green

# 健康检查
Write-Host ""
Write-Host "健康检查..." -ForegroundColor Yellow
$health = Invoke-WebRequest -Uri "http://localhost:8000/api/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
if ($health.StatusCode -eq 200) {
    Write-Host "✅ 后端服务正常" -ForegroundColor Green
} else {
    Write-Host "⚠️ 后端服务可能未就绪，请查看日志: docker-compose logs -f" -ForegroundColor Yellow
}
