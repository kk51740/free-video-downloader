FROM python:3.11-slim

WORKDIR /app

# 安装系统依赖（ffmpeg等）
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件并安装
COPY requirements_docker.txt .
RUN pip install --no-cache-dir -r requirements_docker.txt

# 复制应用代码
COPY . .

ENV PYTHONUNBUFFERED=1

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
