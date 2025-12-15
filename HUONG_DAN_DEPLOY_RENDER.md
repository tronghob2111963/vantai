# 🚀 Hướng dẫn Deploy Dự án PTCMSS lên Render

Hướng dẫn chi tiết để deploy dự án PTCMSS (Passenger Transport Company Management System) lên Render.com.

## 📋 Mục lục

1. [Chuẩn bị](#chuẩn-bị)
2. [Cách 1: Deploy tự động với Render Blueprint](#cách-1-deploy-tự-động-với-render-blueprint)
3. [Cách 2: Deploy thủ công từng service](#cách-2-deploy-thủ-công-từng-service)
4. [Cấu hình Environment Variables](#cấu-hình-environment-variables)
5. [Kiểm tra và Troubleshooting](#kiểm-tra-và-troubleshooting)

---

## 🎯 Chuẩn bị

### Yêu cầu

1. **Tài khoản Render**: Đăng ký tại [render.com](https://render.com) (miễn phí)
2. **Repository GitHub/GitLab**: Code của bạn phải được push lên Git repository
3. **Kiến thức cơ bản**: Hiểu về Docker, environment variables

### Cấu trúc dự án

```
vantai/
├── PTCMSS/
│   └── ptcmss-backend/      # Spring Boot Backend
│       └── Dockerfile
├── PTCMSS_FRONTEND/          # React + Vite Frontend
│   └── Dockerfile
└── render.yaml               # Render Blueprint (tự động deploy)
```

---

## 🚀 Cách 1: Deploy tự động với Render Blueprint (Khuyến nghị)

Đây là cách đơn giản nhất, Render sẽ tự động tạo tất cả services từ file `render.yaml`.

### Bước 1: Push code lên GitHub/GitLab

```bash
# Đảm bảo code đã được commit và push
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

### Bước 2: Tạo Blueprint trên Render

1. Đăng nhập vào [Render Dashboard](https://dashboard.render.com)
2. Click **"New +"** → **"Blueprint"**
3. Kết nối repository GitHub/GitLab của bạn
4. Render sẽ tự động phát hiện file `render.yaml`
5. Click **"Apply"** để bắt đầu deploy

### Bước 3: Cấu hình Environment Variables

Sau khi Blueprint được tạo, bạn cần cấu hình các biến môi trường:

#### Backend Service (`ptcmss-backend`)

Vào **Dashboard** → **ptcmss-backend** → **Environment** → Thêm các biến sau:

```
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
JWT_SECRET=your-secret-key-here (tạo một chuỗi ngẫu nhiên dài)
JWT_EXPIRATION=86400000
```

**Lưu ý**: 
- `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD` sẽ được tự động lấy từ database service
- Để lấy App Password cho Gmail: [Google App Passwords](https://myaccount.google.com/apppasswords)

#### Frontend Service (`ptcmss-frontend`)

Sau khi backend deploy xong, lấy URL của backend (ví dụ: `https://ptcmss-backend.onrender.com`)

Vào **Dashboard** → **ptcmss-frontend** → **Environment** → Thêm:

```
VITE_API_BASE=https://ptcmss-backend.onrender.com
```

**Quan trọng**: Cần rebuild frontend sau khi set biến này vì Vite build-time variables.

### Bước 4: Rebuild Services

1. Vào **ptcmss-frontend** → **Manual Deploy** → **Deploy latest commit**
2. Đợi deploy hoàn tất (5-10 phút)

### Bước 5: Kiểm tra

- **Backend**: `https://ptcmss-backend.onrender.com/actuator/health`
- **Frontend**: `https://ptcmss-frontend.onrender.com`
- **Swagger**: `https://ptcmss-backend.onrender.com/swagger-ui.html`

---

## 🔧 Cách 2: Deploy thủ công từng service

Nếu bạn muốn kiểm soát chi tiết hơn, có thể deploy từng service một.

### Bước 1: Tạo Database

1. **Dashboard** → **New +** → **PostgreSQL** (hoặc MySQL nếu có)
2. Đặt tên: `ptcmss-database`
3. Chọn plan: **Starter** (Free tier)
4. Region: **Singapore** (gần Việt Nam nhất)
5. Click **Create Database**
6. Lưu lại **Internal Database URL** và **External Database URL**

### Bước 2: Deploy Backend

1. **Dashboard** → **New +** → **Web Service**
2. Kết nối repository
3. Cấu hình:
   - **Name**: `ptcmss-backend`
   - **Environment**: **Docker**
   - **Dockerfile Path**: `PTCMSS/ptcmss-backend/Dockerfile`
   - **Docker Context**: `PTCMSS/ptcmss-backend`
   - **Plan**: **Starter** (Free)
   - **Region**: **Singapore**

4. **Environment Variables**:
   ```
   SPRING_PROFILES_ACTIVE=production
   SPRING_DATASOURCE_URL=<Internal Database URL từ bước 1>
   # Nếu dùng PostgreSQL, format: jdbc:postgresql://host:port/database
   # Nếu dùng MySQL external, format: jdbc:mysql://host:port/database?useSSL=true&...
   SPRING_DATASOURCE_USERNAME=<Database username>
   SPRING_DATASOURCE_PASSWORD=<Database password>
   SPRING_JPA_HIBERNATE_DDL_AUTO=update
   SPRING_JPA_SHOW_SQL=false
   JWT_SECRET=<tạo chuỗi ngẫu nhiên>
   JWT_EXPIRATION=86400000
   MAIL_HOST=smtp.gmail.com
   MAIL_PORT=587
   MAIL_USERNAME=your-email@gmail.com
   MAIL_PASSWORD=your-app-password
   ```
   
   **Lưu ý**: Nếu dùng PostgreSQL, cần đảm bảo Spring Boot config hỗ trợ PostgreSQL driver.

5. **Health Check Path**: `/actuator/health`

6. Click **Create Web Service**

### Bước 3: Deploy Frontend

1. **Dashboard** → **New +** → **Web Service**
2. Kết nối repository
3. Cấu hình:
   - **Name**: `ptcmss-frontend`
   - **Environment**: **Docker**
   - **Dockerfile Path**: `PTCMSS_FRONTEND/Dockerfile`
   - **Docker Context**: `PTCMSS_FRONTEND`
   - **Plan**: **Starter** (Free)
   - **Region**: **Singapore**

4. **Environment Variables**:
   ```
   VITE_API_BASE=https://ptcmss-backend.onrender.com
   ```
   ⚠️ **Lưu ý**: Thay `ptcmss-backend` bằng tên service backend thực tế của bạn

5. Click **Create Web Service**

### Bước 4: Rebuild Frontend với Build Args

Vì `VITE_API_BASE` là build-time variable, bạn cần rebuild với build args.

**Cách 1: Sửa Dockerfile để nhận build arg**

File `PTCMSS_FRONTEND/Dockerfile` đã có sẵn build arg, nhưng cần đảm bảo Render truyền vào.

**Cách 2: Sử dụng Render Build Command** (Khuyến nghị)

Trong Render Dashboard → **ptcmss-frontend** → **Settings** → **Build Command**:

```bash
docker build --build-arg VITE_API_BASE=$VITE_API_BASE -t render-build .
```

Tuy nhiên, Render tự động build Dockerfile nên cách tốt nhất là đảm bảo biến môi trường được set trước khi build.

---

## ⚙️ Cấu hình Environment Variables

### Backend Variables

| Biến | Mô tả | Ví dụ |
|------|-------|-------|
| `SPRING_PROFILES_ACTIVE` | Spring profile | `production` |
| `SPRING_DATASOURCE_URL` | Database connection string | Tự động từ Render DB |
| `SPRING_DATASOURCE_USERNAME` | DB username | Tự động từ Render DB |
| `SPRING_DATASOURCE_PASSWORD` | DB password | Tự động từ Render DB |
| `JWT_SECRET` | Secret key cho JWT | Tạo chuỗi ngẫu nhiên 32+ ký tự |
| `JWT_EXPIRATION` | JWT expiration (ms) | `86400000` (24h) |
| `MAIL_HOST` | SMTP server | `smtp.gmail.com` |
| `MAIL_PORT` | SMTP port | `587` |
| `MAIL_USERNAME` | Email gửi | `your-email@gmail.com` |
| `MAIL_PASSWORD` | App password | Google App Password |

### Frontend Variables

| Biến | Mô tả | Ví dụ |
|------|-------|-------|
| `VITE_API_BASE` | Backend API URL | `https://ptcmss-backend.onrender.com` |

**⚠️ Quan trọng**: `VITE_API_BASE` phải được set **TRƯỚC KHI BUILD**. Nếu thay đổi sau khi build, cần rebuild lại service.

---

## 🔍 Kiểm tra và Troubleshooting

### Kiểm tra Backend

1. **Health Check**:
   ```bash
   curl https://ptcmss-backend.onrender.com/actuator/health
   ```
   Kết quả mong đợi: `{"status":"UP"}`

2. **Swagger UI**:
   Truy cập: `https://ptcmss-backend.onrender.com/swagger-ui.html`

3. **API Test**:
   ```bash
   curl https://ptcmss-backend.onrender.com/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"admin","password":"123456"}'
   ```

### Kiểm tra Frontend

1. Truy cập URL frontend
2. Mở Developer Tools (F12) → Console
3. Kiểm tra có lỗi kết nối API không

### Troubleshooting

#### ❌ Backend không start được

**Lỗi**: Database connection failed

**Giải pháp**:
- Kiểm tra `SPRING_DATASOURCE_URL` có đúng không
- Đảm bảo dùng **Internal Database URL** (không phải External)
- Format: `jdbc:mysql://host:port/database?useSSL=true&...`

**Lỗi**: Port binding failed

**Giải pháp**:
- Render tự động map port, không cần config
- Đảm bảo app chạy trên port mặc định (8080 cho Spring Boot)

#### ❌ Frontend không kết nối được Backend

**Lỗi**: CORS error hoặc Network error

**Giải pháp**:
1. Kiểm tra `VITE_API_BASE` có đúng URL backend không
2. Đảm bảo backend đã deploy xong và running
3. Rebuild frontend sau khi set `VITE_API_BASE`
4. Kiểm tra CORS config trong backend (cho phép domain frontend)

#### ❌ Build failed

**Lỗi**: npm install failed

**Giải pháp**:
- Kiểm tra `package.json` có đúng không
- Đảm bảo Node version phù hợp (20.x)

**Lỗi**: Maven build failed

**Giải pháp**:
- Kiểm tra `pom.xml`
- Đảm bảo Java 21 được sử dụng

#### ❌ Service bị sleep (Free tier)

**Vấn đề**: Render free tier sẽ sleep sau 15 phút không có traffic

**Giải pháp**:
1. Upgrade lên paid plan ($7/tháng)
2. Sử dụng service như [UptimeRobot](https://uptimerobot.com) để ping service mỗi 5 phút
3. Chấp nhận delay khi wake up (30-60 giây)

---

## 📝 Lưu ý quan trọng

### Database - MySQL vs PostgreSQL

⚠️ **VẤN ĐỀ**: Dự án hiện tại dùng **MySQL**, nhưng Render free tier chỉ hỗ trợ **PostgreSQL**.

**Giải pháp**:

1. **Option 1: Thêm PostgreSQL support** (Khuyến nghị)
   - Thêm dependency vào `pom.xml`:
     ```xml
     <dependency>
         <groupId>org.postgresql</groupId>
         <artifactId>postgresql</artifactId>
         <scope>runtime</scope>
     </dependency>
     ```
   - Update `application-prod.yml` để tự động detect database type
   - Hibernate sẽ tự động tạo schema với `ddl-auto=update`

2. **Option 2: Dùng External MySQL Service**
   - [PlanetScale](https://planetscale.com) - Free tier, MySQL compatible
   - [Railway](https://railway.app) - Free tier, hỗ trợ MySQL
   - [Aiven](https://aiven.io) - Free trial
   - Set `SPRING_DATASOURCE_URL` trong Render Dashboard với external MySQL URL

3. **Option 3: Upgrade Render Plan**
   - Render paid plans hỗ trợ MySQL, nhưng tốn phí ($20+/tháng)

### Free Tier Limitations

- **Sleep**: Services sẽ sleep sau 15 phút không có traffic
- **Build time**: Giới hạn 45 phút
- **Bandwidth**: Giới hạn 100GB/tháng
- **Database**: PostgreSQL free tier có giới hạn 90 ngày

### Security

- **JWT_SECRET**: Tạo một chuỗi ngẫu nhiên mạnh, không commit vào Git
- **Database password**: Render tự tạo, không cần set thủ công
- **Mail password**: Sử dụng App Password, không dùng mật khẩu chính

### Performance

- **Cold start**: Free tier có thể mất 30-60 giây để wake up
- **Database**: Sử dụng Internal URL để tối ưu tốc độ
- **CDN**: Render tự động cung cấp CDN cho static assets

---

## 🎉 Hoàn thành!

Sau khi deploy thành công:

1. ✅ Backend chạy tại: `https://ptcmss-backend.onrender.com`
2. ✅ Frontend chạy tại: `https://ptcmss-frontend.onrender.com`
3. ✅ Database được tạo và kết nối tự động
4. ✅ Có thể truy cập ứng dụng từ bất kỳ đâu

### Tài khoản mặc định

- **Username**: `admin`
- **Password**: `123456`

⚠️ **Nhớ đổi mật khẩu sau lần đăng nhập đầu tiên!**

---

## 📞 Hỗ trợ

Nếu gặp vấn đề:

1. Kiểm tra logs trong Render Dashboard
2. Xem [Render Documentation](https://render.com/docs)
3. Kiểm tra [Render Status](https://status.render.com)

**Chúc bạn deploy thành công! 🚀**

