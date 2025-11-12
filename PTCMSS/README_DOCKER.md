# 🐳 HƯỚNG DẪN DOCKER - PTCMSS PROJECT

## 📋 MỤC LỤC

1. [Tổng quan](#tổng-quan)
2. [Cấu trúc](#cấu-trúc)
3. [Cách sử dụng](#cách-sử-dụng)
4. [Cải thiện](#cải-thiện)
5. [Troubleshooting](#troubleshooting)

---

## 📖 TỔNG QUAN

Dự án sử dụng Docker Compose để chạy 3 services:
- **MySQL 8.0** - Database server
- **Spring Boot Backend** - REST API
- **React Frontend** - Web application

---

## 📁 CẤU TRÚC

```
PTCMSS/
├── docker-compose.yml              # Cấu hình chính
├── docker-compose.improved.yml     # Phiên bản cải tiến (tham khảo)
├── .env.example                     # Template cho environment variables
├── ptcmss-backend/
│   ├── Dockerfile                    # Dockerfile hiện tại
│   ├── Dockerfile.improved         # Dockerfile cải tiến (tham khảo)
│   └── .dockerignore               # Loại bỏ files không cần thiết
└── PHAN_TICH_DOCKER.md             # Phân tích chi tiết
```

---

## 🚀 CÁCH SỬ DỤNG

### Bước 1: Chuẩn bị

```bash
# Di chuyển vào thư mục PTCMSS
cd PTCMSS

# (Tùy chọn) Tạo .env file từ .env.example
cp .env.example .env
# Sửa passwords trong .env
```

### Bước 2: Build và chạy

```bash
# Build và start tất cả services
docker-compose up --build

# Hoặc chạy ở background
docker-compose up -d --build
```

### Bước 3: Kiểm tra

- **Backend**: http://localhost:8080
- **Swagger**: http://localhost:8080/swagger-ui.html
- **Frontend**: http://localhost:5173
- **MySQL**: localhost:3307

### Các lệnh thường dùng

```bash
# Xem logs
docker-compose logs -f

# Xem logs một service
docker-compose logs -f backend

# Stop tất cả
docker-compose down

# Stop và xóa data (CẨN THẬN!)
docker-compose down -v

# Rebuild một service
docker-compose build backend
docker-compose up backend

# Xem status
docker-compose ps

# Execute command trong container
docker-compose exec backend sh
docker-compose exec mysql mysql -uroot -proot
```

---

## 🔧 CẢI THIỆN

### 1. Sử dụng .env file

Tạo file `.env` trong thư mục `PTCMSS/`:

```env
# MySQL
MYSQL_ROOT_PASSWORD=your_secure_password
MYSQL_DATABASE=ptcmss_db
MYSQL_PORT=3307

# Backend
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=your_secure_password
SPRING_PROFILES_ACTIVE=prod
BACKEND_PORT=8080

# Frontend
FRONTEND_PORT=5173
```

Sau đó sử dụng `docker-compose.improved.yml` hoặc cập nhật `docker-compose.yml` để đọc từ `.env`.

### 2. Sử dụng Dockerfile cải tiến

Copy `Dockerfile.improved` thành `Dockerfile` hoặc sử dụng:

```bash
# Build với Dockerfile cải tiến
docker build -f Dockerfile.improved -t ptcmss-backend:improved .
```

### 3. Thêm .dockerignore

Copy `.dockerignore.example` thành `.dockerignore` trong `ptcmss-backend/`:

```bash
cp .dockerignore.example ptcmss-backend/.dockerignore
```

---

## 🐛 TROUBLESHOOTING

### Lỗi: "Build context not found"

**Nguyên nhân**: Path sai trong docker-compose.yml

**Giải pháp**: Kiểm tra path trong `docker-compose.yml`:
```yaml
backend:
  build:
    context: ./ptcmss-backend  # Đảm bảo path đúng
```

### Lỗi: "Cannot connect to MySQL"

**Nguyên nhân**: Backend khởi động trước MySQL

**Giải pháp**: 
- `depends_on` đã được cấu hình
- Kiểm tra MySQL health: `docker inspect ptcmss-mysql`

### Lỗi: "Port already in use"

**Giải pháp**:
```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :8080
kill -9 <PID>
```

### Lỗi: "Out of memory"

**Giải pháp**: Tăng Docker memory limit trong Docker Desktop settings

---

## 📚 TÀI LIỆU THAM KHẢO

- **Phân tích chi tiết**: `PHAN_TICH_DOCKER.md`
- **Dockerfile cải tiến**: `ptcmss-backend/Dockerfile.improved`
- **Docker Compose cải tiến**: `docker-compose.improved.yml`

---

## ✅ CHECKLIST

Trước khi deploy production:

- [ ] Đã tạo `.env` file với passwords an toàn
- [ ] Đã thêm `.dockerignore`
- [ ] Đã test build thành công
- [ ] Đã test kết nối giữa các services
- [ ] Đã kiểm tra health checks
- [ ] Đã review security (non-root user, resource limits)
- [ ] Đã cấu hình production (ddl-auto: validate, show-sql: false)

---

**Chúc bạn sử dụng Docker thành công! 🎉**

