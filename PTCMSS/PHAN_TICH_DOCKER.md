# 🐳 PHÂN TÍCH CẤU HÌNH DOCKER - PTCMSS PROJECT

## 📋 TỔNG QUAN

Dự án sử dụng **Docker** và **Docker Compose** để containerize hệ thống với 3 services:
- **MySQL 8.0** - Database
- **Spring Boot Backend** - API Server
- **React Frontend** - Web Application

---

## 🔍 PHÂN TÍCH CHI TIẾT

### 1. **Dockerfile (Backend)**

**Location**: `PTCMSS/ptcmss-backend/Dockerfile`

```dockerfile
# ---- Stage 1: Build ----
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# ---- Stage 2: Runtime ----
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

#### ✅ **Điểm mạnh:**

1. **Multi-stage build** ✅
   - Stage 1: Build với Maven (chứa JDK, Maven - nặng ~800MB)
   - Stage 2: Runtime chỉ với JRE (nhẹ ~200MB)
   - **Kết quả**: Image cuối cùng nhỏ hơn ~600MB

2. **Layer caching tối ưu** ✅
   - Copy `pom.xml` trước → Download dependencies
   - Copy `src` sau → Chỉ rebuild khi code thay đổi
   - **Lợi ích**: Build nhanh hơn khi chỉ sửa code

3. **Maven offline mode** ✅
   - `dependency:go-offline` tải tất cả dependencies vào local repo
   - Giảm thời gian build lần sau

4. **Skip tests trong build** ✅
   - `-DskipTests` - Phù hợp cho production build nhanh

#### ⚠️ **Vấn đề & Cải thiện:**

1. **Thiếu HEALTHCHECK** ❌
   ```dockerfile
   # Nên thêm:
   HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
     CMD curl -f http://localhost:8080/actuator/health || exit 1
   ```
   - **Lý do**: Docker/Orchestrator biết container có healthy không
   - **Lợi ích**: Auto-restart khi unhealthy

2. **Chạy với root user** ⚠️
   ```dockerfile
   # Nên thêm:
   RUN groupadd -r appuser && useradd -r -g appuser appuser
   RUN chown -R appuser:appuser /app
   USER appuser
   ```
   - **Lý do**: Security best practice
   - **Rủi ro**: Nếu container bị compromise, attacker có root access

3. **Thiếu .dockerignore** ⚠️
   - Copy cả `target/`, `.idea/`, `*.md` vào build context
   - **Lợi ích**: Giảm build context size, tăng tốc build

4. **Không có JVM options** ⚠️
   ```dockerfile
   # Nên thêm:
   ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
   ```
   - **Lý do**: Tối ưu memory cho container

---

### 2. **Docker Compose**

**Location**: `PTCMSS/docker-compose.yml`

#### **Phân tích từng service:**

#### **A. MySQL Service**

```yaml
mysql:
  image: mysql:8.0.43-debian
  container_name: ptcmss-mysql
  restart: always
  environment:
    MYSQL_ROOT_PASSWORD: root
    MYSQL_DATABASE: ptcmss_db
  ports:
    - "3307:3306"
  volumes:
    - mysql_data:/var/lib/mysql
  healthcheck:
    test: ["CMD", "mysqladmin", "ping", "-h", "127.0.0.1", "-uroot", "-proot"]
    interval: 5s
    timeout: 3s
    retries: 10
```

✅ **Điểm tốt:**
- Health check được cấu hình đúng
- Volume persistence (`mysql_data`) - data không mất khi container restart
- Port mapping 3307:3306 - tránh conflict với MySQL local
- `restart: always` - tự động restart khi crash

⚠️ **Vấn đề:**
- **Hardcoded password**: `root` - không an toàn
- **Nên dùng**: Environment variables hoặc Docker secrets

---

#### **B. Backend Service**

```yaml
backend:
  build:
    context: ./PTCMSS-Backend      # ⚠️ PATH CÓ THỂ SAI
    dockerfile: Dockerfile
  container_name: ptcmss-backend
  restart: always
  depends_on:
    mysql:
      condition: service_healthy
  environment:
    SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/ptcmss_db?...
    SPRING_DATASOURCE_USERNAME: root
    SPRING_DATASOURCE_PASSWORD: root
    SPRING_PROFILES_ACTIVE: prod
  ports:
    - "8080:8080"
```

✅ **Điểm tốt:**
- `depends_on` với `condition: service_healthy` - đợi MySQL sẵn sàng
- Environment variables override config
- Profile `prod` được kích hoạt

⚠️ **Vấn đề:**

1. **Path có thể sai** ⚠️
   - `context: ./PTCMSS-Backend` 
   - **Thư mục thực tế**: `ptcmss-backend` (chữ thường)
   - **Kiểm tra**: Nếu build lỗi "context not found", cần sửa path

2. **Thiếu health check** ❌
   ```yaml
   healthcheck:
     test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
     interval: 30s
     timeout: 10s
     retries: 3
     start_period: 40s
   ```

3. **Hardcoded passwords** ⚠️
   - Nên dùng `.env` file

4. **Thiếu resource limits** ⚠️
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '1'
         memory: 1G
       reservations:
         cpus: '0.5'
         memory: 512M
   ```

---

#### **C. Frontend Service**

```yaml
frontend:
  build:
    context: ./ptcmss-frontend
    dockerfile: Dockerfile
  container_name: ptcmss-frontend
  restart: always
  depends_on:
    - backend
  ports:
    - "5173:80"
```

⚠️ **Vấn đề:**
- **Thiếu health check**
- **Port mapping**: 5173:80 - Frontend build ra port 80 trong container
- **Cần kiểm tra**: Dockerfile của frontend có tồn tại không

---

### 3. **Application Production Config**

**Location**: `PTCMSS/ptcmss-backend/src/main/resources/application-prod.yml`

```yaml
spring:
  datasource:
    url: jdbc:mysql://mysql:3306/ptcmss_db?...
    username: root
    password: root
  jpa:
    hibernate:
      ddl-auto: update      # ⚠️ KHÔNG NÊN DÙNG TRONG PRODUCTION
    show-sql: true          # ⚠️ KHÔNG NÊN BẬT TRONG PRODUCTION
```

⚠️ **Vấn đề nghiêm trọng:**

1. **`ddl-auto: update`** ❌
   - **Rủi ro**: Tự động thay đổi schema có thể mất data
   - **Nên dùng**: `validate` hoặc `none` + Migration tool (Flyway/Liquibase)

2. **`show-sql: true`** ⚠️
   - **Vấn đề**: Log tất cả SQL queries → Performance impact
   - **Nên**: `false` trong production

3. **Hardcoded credentials** ⚠️
   - Nên dùng environment variables

---

## 📊 KIẾN TRÚC NETWORK

```
┌─────────────────────────────────────────────┐
│      Docker Network (default bridge)       │
│                                             │
│  ┌──────────────────┐                     │
│  │   Frontend       │  Port 5173:80        │
│  │   (React/Vite)   │                      │
│  └────────┬─────────┘                      │
│           │ HTTP                            │
│  ┌────────▼─────────┐                     │
│  │   Backend        │  Port 8080:8080      │
│  │   (Spring Boot)  │                      │
│  └────────┬─────────┘                      │
│           │ JDBC                            │
│  ┌────────▼─────────┐                     │
│  │   MySQL          │  Port 3307:3306      │
│  │   (Database)      │                      │
│  └──────────────────┘                      │
│                                             │
│  Volume: mysql_data (persistent storage)   │
└─────────────────────────────────────────────┘
```

**Giao tiếp:**
- Frontend → Backend: `http://backend:8080` (trong Docker network)
- Backend → MySQL: `jdbc:mysql://mysql:3306` (service name)
- External access: Port mapping (5173, 8080, 3307)

---

## 🔒 BẢO MẬT

### ⚠️ **Vấn đề bảo mật hiện tại:**

1. **Hardcoded passwords** trong docker-compose.yml
2. **Root user** trong containers
3. **No resource limits** - có thể bị DoS
4. **ddl-auto: update** - rủi ro mất data

### ✅ **Khuyến nghị:**

1. **Sử dụng .env file:**
   ```bash
   # .env
   MYSQL_ROOT_PASSWORD=secure_password_123
   SPRING_DATASOURCE_PASSWORD=secure_password_123
   ```

2. **Non-root user** trong Dockerfile

3. **Resource limits** trong docker-compose.yml

4. **Migration tool** thay vì ddl-auto

---

## 🚀 HƯỚNG DẪN SỬ DỤNG

### Build và chạy:

```bash
# Di chuyển vào thư mục PTCMSS
cd PTCMSS

# Build và start tất cả services
docker-compose up --build

# Chạy ở background
docker-compose up -d --build

# Xem logs
docker-compose logs -f

# Stop tất cả
docker-compose down

# Stop và xóa volumes (XÓA DATA!)
docker-compose down -v
```

### Kiểm tra services:

```bash
# List containers
docker-compose ps

# Health check
docker inspect ptcmss-backend | grep Health

# Logs
docker-compose logs backend
docker-compose logs mysql
```

### Truy cập:

- **Backend API**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **Frontend**: http://localhost:5173
- **MySQL**: localhost:3307

---

## 🐛 TROUBLESHOOTING

### Lỗi 1: "Build context not found"

**Nguyên nhân**: Path sai trong docker-compose.yml

**Giải pháp**:
```yaml
# Kiểm tra thư mục thực tế
# Nếu là ptcmss-backend (chữ thường):
context: ./ptcmss-backend

# Nếu là PTCMSS-Backend (chữ hoa):
context: ./PTCMSS-Backend
```

### Lỗi 2: "Cannot connect to MySQL"

**Nguyên nhân**: Backend khởi động trước MySQL

**Giải pháp**: 
- `depends_on` với `condition: service_healthy` đã có
- Kiểm tra MySQL health check: `docker inspect ptcmss-mysql`

### Lỗi 3: "Port already in use"

**Giải pháp**:
```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :8080
kill -9 <PID>
```

### Lỗi 4: "Out of memory"

**Giải pháp**: Tăng Docker memory limit trong Docker Desktop

---

## 📈 PERFORMANCE

### Tối ưu hiện tại:
- ✅ Multi-stage build (giảm image size)
- ✅ Layer caching
- ✅ Volume persistence

### Cần cải thiện:
- ⚠️ Thêm JVM options cho container
- ⚠️ Resource limits
- ⚠️ Connection pooling config

---

## ✅ CHECKLIST REVIEW

### Dockerfile:
- [x] Multi-stage build
- [x] Layer caching
- [ ] Health check
- [ ] Non-root user
- [ ] .dockerignore
- [ ] JVM options

### Docker Compose:
- [x] Health check cho MySQL
- [x] Service dependencies
- [x] Volume persistence
- [ ] Health check cho Backend
- [ ] Resource limits
- [ ] .env file cho secrets

### Application Config:
- [x] Profile separation (dev/prod)
- [ ] ddl-auto: validate/none
- [ ] show-sql: false (prod)
- [ ] Environment variables

---

## 🎯 KẾT LUẬN

### Điểm mạnh: ⭐⭐⭐⭐ (4/5)
- ✅ Multi-stage build tối ưu
- ✅ Health checks cho MySQL
- ✅ Service dependencies đúng
- ✅ Volume persistence

### Cần cải thiện: ⚠️
- ⚠️ Sửa path trong docker-compose.yml (nếu sai)
- ⚠️ Thêm health check cho backend
- ⚠️ Sử dụng .env file
- ⚠️ Non-root user
- ⚠️ Production config (ddl-auto, show-sql)
- ⚠️ Resource limits

### Đánh giá tổng thể: **7.5/10**

Dự án có nền tảng Docker tốt, nhưng cần cải thiện security và production readiness.

---

**Tài liệu được tạo**: 2024
**Version**: 1.0

