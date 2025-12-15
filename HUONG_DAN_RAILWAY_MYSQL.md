# 🚂 Hướng dẫn Deploy MySQL Docker trên Railway

Railway hỗ trợ Docker và MySQL container tốt hơn Render! Đây là cách deploy MySQL trên Railway và kết nối với Render.

## 🎯 Tại sao chọn Railway cho MySQL?

- ✅ **Free tier** có sẵn MySQL
- ✅ Hỗ trợ Docker và docker-compose tốt
- ✅ Dễ cấu hình và quản lý
- ✅ Có thể dùng MySQL 8.0 trực tiếp
- ✅ Internal và External connection đều được

---

## 🚀 Bước 1: Tạo MySQL Service trên Railway

### Cách 1: Deploy MySQL từ Docker Image (Khuyến nghị)

1. **Đăng ký Railway**:
   - Truy cập [railway.app](https://railway.app)
   - Đăng nhập bằng GitHub

2. **Tạo Project mới**:
   - Click **"New Project"**
   - Chọn **"Deploy from GitHub repo"** hoặc **"Empty Project"**

3. **Thêm MySQL Service**:
   - Click **"+ New"** → **"Database"** → **"Add MySQL"**
   - Railway sẽ tự động tạo MySQL container
   - Lưu lại **Connection URL** và **Credentials**

### Cách 2: Deploy MySQL từ Dockerfile

1. **Tạo file `railway-mysql/Dockerfile`**:
   ```dockerfile
   FROM mysql:8.0.43-debian
   
   ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-root}
   ENV MYSQL_DATABASE=${MYSQL_DATABASE:-ptcmss_db}
   ENV MYSQL_USER=${MYSQL_USER:-ptcmss_user}
   ENV MYSQL_PASSWORD=${MYSQL_PASSWORD:-ptcmss_password}
   
   EXPOSE 3306
   
   CMD ["mysqld"]
   ```

2. **Tạo file `railway-mysql/railway.json`** (optional):
   ```json
   {
     "$schema": "https://railway.app/railway.schema.json",
     "build": {
       "builder": "DOCKERFILE",
       "dockerfilePath": "Dockerfile"
     },
     "deploy": {
       "startCommand": "mysqld",
       "restartPolicyType": "ON_FAILURE",
       "restartPolicyMaxRetries": 10
     }
   }
   ```

3. **Deploy trên Railway**:
   - Click **"+ New"** → **"GitHub Repo"**
   - Chọn repo và folder `railway-mysql`
   - Railway sẽ tự động build và deploy

---

## 🔗 Bước 2: Lấy Connection String từ Railway

Sau khi MySQL deploy xong:

1. Vào **MySQL service** trên Railway Dashboard
2. Click tab **"Variables"** hoặc **"Connect"**
3. Lấy các thông tin:
   - **MYSQLHOST**: Hostname (ví dụ: `containers-us-west-xxx.railway.app`)
   - **MYSQLPORT**: Port (thường là `3306`)
   - **MYSQLDATABASE**: Database name
   - **MYSQLUSER**: Username
   - **MYSQLPASSWORD**: Password

4. **Connection String format**:
   ```
   jdbc:mysql://MYSQLHOST:MYSQLPORT/MYSQLDATABASE?useSSL=true&allowPublicKeyRetrieval=true&serverTimezone=UTC
   ```

   Ví dụ:
   ```
   jdbc:mysql://containers-us-west-123.railway.app:3306/railway?useSSL=true&allowPublicKeyRetrieval=true&serverTimezone=UTC
   ```

---

## ⚙️ Bước 3: Cấu hình Render Backend để kết nối Railway MySQL

### Cách 1: Sửa render.yaml

Cập nhật `render.yaml` để dùng external MySQL:

```yaml
services:
  - type: web
    name: ptcmss-backend
    env: docker
    dockerfilePath: ./PTCMSS/ptcmss-backend/Dockerfile
    dockerContext: ./PTCMSS/ptcmss-backend
    plan: starter
    region: singapore
    envVars:
      - key: SPRING_PROFILES_ACTIVE
        value: production
      # Kết nối đến MySQL trên Railway
      - key: SPRING_DATASOURCE_URL
        sync: false
        # Set trong Render Dashboard với connection string từ Railway
        # Format: jdbc:mysql://host:port/database?useSSL=true&...
      - key: SPRING_DATASOURCE_USERNAME
        sync: false
        # Set username từ Railway
      - key: SPRING_DATASOURCE_PASSWORD
        sync: false
        # Set password từ Railway
      - key: SPRING_JPA_HIBERNATE_DDL_AUTO
        value: update
      - key: SPRING_JPA_SHOW_SQL
        value: "false"
      - key: JWT_SECRET
        generateValue: true
      - key: JWT_EXPIRATION
        value: 86400000
      - key: MAIL_HOST
        sync: false
      - key: MAIL_PORT
        value: "587"
      - key: MAIL_USERNAME
        sync: false
      - key: MAIL_PASSWORD
        sync: false
    healthCheckPath: /actuator/health
```

### Cách 2: Set trong Render Dashboard

1. Vào **Render Dashboard** → **ptcmss-backend** → **Environment**
2. Thêm các biến:
   ```
   SPRING_DATASOURCE_URL=jdbc:mysql://containers-us-west-123.railway.app:3306/railway?useSSL=true&allowPublicKeyRetrieval=true&serverTimezone=UTC
   SPRING_DATASOURCE_USERNAME=root
   SPRING_DATASOURCE_PASSWORD=your-railway-password
   ```
3. **Redeploy** backend service

---

## 🔒 Bước 4: Cấu hình Railway MySQL Security

### Cho phép External Connection

1. Vào **Railway MySQL service** → **Settings**
2. Đảm bảo **"Public Networking"** được bật (nếu cần external access)
3. Hoặc dùng **Private Networking** nếu cả 2 services đều trên Railway

### Firewall Rules (nếu cần)

Railway tự động xử lý, nhưng nếu có vấn đề:
- Kiểm tra **Port** có đúng không (3306)
- Kiểm tra **SSL** connection có được enable không

---

## ✅ Bước 5: Test Connection

### Test từ Local

```bash
mysql -h containers-us-west-123.railway.app -P 3306 -u root -p
```

### Test từ Backend

Sau khi deploy, check logs:
```bash
# Render Dashboard → ptcmss-backend → Logs
# Tìm dòng: "Started PtcmssBackendApplication"
```

Nếu có lỗi connection:
- Kiểm tra connection string
- Kiểm tra username/password
- Kiểm tra firewall/network settings

---

## 📊 So sánh Railway vs Render cho MySQL

| Tính năng | Railway MySQL | Render PostgreSQL |
|-----------|---------------|-------------------|
| **Free tier** | ✅ Có | ✅ Có |
| **MySQL support** | ✅ Native | ❌ Chỉ PostgreSQL |
| **Docker support** | ✅ Tốt | ✅ Tốt |
| **Backup** | ✅ Tự động | ✅ Tự động |
| **Connection** | Dễ | Dễ |
| **Migration** | Không cần | Cần migrate schema |

---

## 🎯 Kết luận

**Workflow đề xuất:**
1. ✅ Deploy **MySQL trên Railway** (free, dễ setup)
2. ✅ Deploy **Backend + Frontend trên Render** (dùng Docker)
3. ✅ Kết nối Render Backend → Railway MySQL

**Ưu điểm:**
- ✅ Giữ nguyên MySQL (không cần migrate)
- ✅ Free tier cho cả 2 platforms
- ✅ Backend và Frontend vẫn dùng Docker trên Render
- ✅ Database riêng biệt, dễ quản lý

---

## 🔧 Troubleshooting

### Lỗi: Connection refused

**Giải pháp:**
- Kiểm tra Railway MySQL có đang chạy không
- Kiểm tra Public Networking có được bật không
- Thử dùng Internal URL nếu cả 2 services trên Railway

### Lỗi: Access denied

**Giải pháp:**
- Kiểm tra username/password
- Kiểm tra database name có đúng không
- Reset password trên Railway nếu cần

### Lỗi: SSL required

**Giải pháp:**
- Thêm `?useSSL=true` vào connection string
- Hoặc `?useSSL=false&allowPublicKeyRetrieval=true` (không khuyến nghị cho production)

---

## 📝 Checklist

- [ ] Tạo MySQL service trên Railway
- [ ] Lấy connection string và credentials
- [ ] Set environment variables trong Render Dashboard
- [ ] Redeploy backend service
- [ ] Test connection từ backend logs
- [ ] Verify database connection thành công

---

**Chúc bạn deploy thành công! 🚀**

