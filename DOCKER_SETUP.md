# 🐳 Docker Setup Guide - PTCMSS

Hướng dẫn chạy toàn bộ dự án PTCMSS (MySQL + Backend + Frontend) bằng Docker.

## 📋 Yêu cầu

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **RAM**: Tối thiểu 4GB khả dụng
- **Disk**: Tối thiểu 5GB trống

## 🚀 Cách chạy nhanh

### 1. Clone dự án

```bash
git clone <repository-url>
cd PTCMSS
```

### 2. Tạo file cấu hình

```bash
# Copy file .env mẫu
cp .env.example .env

# Chỉnh sửa .env nếu cần (optional)
# nano .env
```

### 3. Khởi động tất cả services

```bash
docker-compose up -d
```

Lệnh này sẽ:
- ✅ Tải và khởi động MySQL 8.0
- ✅ Build và khởi động Backend (Spring Boot)
- ✅ Build và khởi động Frontend (React + Vite)
- ✅ Tự động tạo database và tables
- ✅ Insert dữ liệu khởi tạo (admin user, roles, etc.)

### 4. Kiểm tra trạng thái

```bash
# Xem logs của tất cả services
docker-compose logs -f

# Xem logs của từng service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mysql

# Kiểm tra trạng thái
docker-compose ps
```

### 5. Truy cập ứng dụng

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8080
- **API Docs**: http://localhost:8080/swagger-ui.html
- **MySQL**: localhost:3306

**Tài khoản mặc định:**
- Username: `admin`
- Password: `123456`

## 🛠️ Các lệnh hữu ích

### Dừng tất cả services

```bash
docker-compose down
```

### Dừng và xóa volumes (reset database)

```bash
docker-compose down -v
```

### Rebuild services

```bash
# Rebuild tất cả
docker-compose up -d --build

# Rebuild chỉ backend
docker-compose up -d --build backend

# Rebuild chỉ frontend
docker-compose up -d --build frontend
```

### Restart services

```bash
# Restart tất cả
docker-compose restart

# Restart từng service
docker-compose restart backend
docker-compose restart frontend
docker-compose restart mysql
```

### Xem logs

```bash
# Logs realtime
docker-compose logs -f

# Logs 100 dòng cuối
docker-compose logs --tail=100

# Logs của service cụ thể
docker-compose logs -f backend
```

### Truy cập vào container

```bash
# Vào backend container
docker exec -it ptcmss-backend sh

# Vào MySQL container
docker exec -it ptcmss-mysql mysql -uroot -proot ptcmss_db

# Vào frontend container
docker exec -it ptcmss-frontend sh
```

## 🔧 Cấu hình nâng cao

### Thay đổi ports

Chỉnh sửa file `.env`:

```env
MYSQL_PORT=3307        # Thay đổi MySQL port
BACKEND_PORT=8081      # Thay đổi Backend port
FRONTEND_PORT=3000     # Thay đổi Frontend port
```

### Cấu hình Email

Để sử dụng tính năng gửi email, cập nhật trong `.env`:

```env
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
```

**Lưu ý**: Với Gmail, bạn cần tạo App Password tại: https://myaccount.google.com/apppasswords

### Chạy với Production profile

```env
SPRING_PROFILES_ACTIVE=prod
```

## 📊 Kiểm tra health

```bash
# Backend health
curl http://localhost:8080/actuator/health

# Frontend health
curl http://localhost:5173

# MySQL health
docker exec ptcmss-mysql mysqladmin ping -h localhost -uroot -proot
```

## 🐛 Troubleshooting

### Lỗi: Port already in use

```bash
# Kiểm tra port đang được sử dụng
# Windows
netstat -ano | findstr :8080

# Linux/Mac
lsof -i :8080

# Giải pháp: Thay đổi port trong .env hoặc kill process
```

### Lỗi: Backend không kết nối được MySQL

```bash
# Kiểm tra MySQL đã sẵn sàng chưa
docker-compose logs mysql

# Restart backend sau khi MySQL ready
docker-compose restart backend
```

### Lỗi: Out of memory

```bash
# Tăng memory limit trong docker-compose.yml
# Hoặc tăng Docker Desktop memory limit
```

### Reset toàn bộ

```bash
# Dừng và xóa tất cả
docker-compose down -v

# Xóa images (optional)
docker-compose down --rmi all

# Khởi động lại
docker-compose up -d --build
```

## 📦 Build riêng lẻ

### Build Backend

```bash
cd ptcmss-backend
docker build -t ptcmss-backend .
docker run -p 8080:8080 ptcmss-backend
```

### Build Frontend

```bash
cd ../PTCMSS_FRONTEND
docker build -t ptcmss-frontend .
docker run -p 5173:80 ptcmss-frontend
```

## 🔒 Security Notes

**⚠️ QUAN TRỌNG cho Production:**

1. Thay đổi mật khẩu mặc định trong `.env`
2. Không commit file `.env` vào Git
3. Sử dụng secrets management (Docker Secrets, Kubernetes Secrets)
4. Enable SSL/TLS cho MySQL connection
5. Sử dụng reverse proxy (Nginx, Traefik) cho production

## 📝 Cấu trúc Docker

```
PTCMSS/
├── docker-compose.yml          # Orchestration file
├── .env                        # Environment variables (create from .env.example)
├── .env.example               # Environment template
├── ptcmss-backend/
│   └── Dockerfile             # Backend container
└── ../PTCMSS_FRONTEND/
    └── Dockerfile             # Frontend container
```

## 🎯 Production Deployment

Để deploy lên production server:

1. Copy toàn bộ project lên server
2. Tạo file `.env` với cấu hình production
3. Chạy: `docker-compose -f docker-compose.yml up -d`
4. Setup reverse proxy (Nginx/Traefik) cho SSL
5. Setup backup cho MySQL volume

## 📞 Support

Nếu gặp vấn đề, kiểm tra:
1. Docker logs: `docker-compose logs`
2. Container status: `docker-compose ps`
3. Network: `docker network inspect ptcmss_ptcmss-network`
4. Volumes: `docker volume ls`
