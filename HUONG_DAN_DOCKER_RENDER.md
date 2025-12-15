# 🐳 Hướng dẫn Deploy bằng Docker trên Render

## 📌 Tình hình hiện tại

**Render đã hỗ trợ Docker!** File `render.yaml` hiện tại đã cấu hình để deploy **backend và frontend bằng Docker**.

### ✅ Đã dùng Docker:
- ✅ **Backend**: Deploy bằng Dockerfile (`PTCMSS/ptcmss-backend/Dockerfile`)
- ✅ **Frontend**: Deploy bằng Dockerfile (`PTCMSS_FRONTEND/Dockerfile`)

### ⚠️ Về Database:
- Render **không hỗ trợ docker-compose** trực tiếp
- Database trên Render là **managed service** (PostgreSQL free tier)
- MySQL container có thể deploy nhưng **tốn phí và phức tạp hơn**

---

## 🎯 Cách 1: Deploy với Docker (Backend + Frontend) + Managed Database (KHUYẾN NGHỊ)

Đây là cách **tốt nhất và miễn phí**:

### Cấu trúc:
```
✅ Backend Container (Docker) → render.yaml đã cấu hình
✅ Frontend Container (Docker) → render.yaml đã cấu hình  
✅ Database (Managed PostgreSQL) → render.yaml đã cấu hình
```

### Các bước:
1. Sử dụng file `render.yaml` hiện tại (đã có sẵn)
2. Deploy như hướng dẫn trong `HUONG_DAN_DEPLOY_RENDER.md`
3. Backend và Frontend sẽ chạy trong Docker containers
4. Database là managed service (tự động backup, scaling)

**Ưu điểm:**
- ✅ Miễn phí (free tier)
- ✅ Tự động backup database
- ✅ Dễ quản lý
- ✅ Backend và Frontend vẫn dùng Docker như bạn muốn

---

## 🐳 Cách 2: Deploy cả 3 Containers (MySQL + Backend + Frontend)

Nếu bạn **thực sự muốn** chạy MySQL container trên Render:

### ⚠️ Lưu ý quan trọng:
1. **Render không hỗ trợ docker-compose** - phải deploy từng container riêng
2. **MySQL container tốn phí** - không có free tier cho MySQL container
3. **Services không thể giao tiếp trực tiếp** - phải dùng external URL
4. **Free tier chỉ có 750 giờ/tháng** - 3 services = hết quota nhanh

### Cách deploy MySQL container:

#### Option A: Dùng MySQL như một Web Service (Không khuyến nghị)

1. **Tạo MySQL Service**:
   - Dashboard → New + → Web Service
   - Environment: **Docker**
   - Dockerfile: Tạo file mới hoặc dùng image trực tiếp

2. **Tạo Dockerfile cho MySQL**:
   ```dockerfile
   FROM mysql:8.0.43-debian
   
   ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
   ENV MYSQL_DATABASE=${MYSQL_DATABASE}
   
   EXPOSE 3306
   ```

3. **Cấu hình Environment Variables**:
   ```
   MYSQL_ROOT_PASSWORD=your-secure-password
   MYSQL_DATABASE=ptcmss_db
   ```

4. **Lấy External URL**: `https://ptcmss-mysql.onrender.com:3306`

5. **Cấu hình Backend** để kết nối:
   ```
   SPRING_DATASOURCE_URL=jdbc:mysql://ptcmss-mysql.onrender.com:3306/ptcmss_db?useSSL=true&...
   ```

#### Option B: Dùng External MySQL Service (KHUYẾN NGHỊ hơn)

Thay vì chạy MySQL container trên Render, dùng external service:

1. **PlanetScale** (Free tier, MySQL compatible):
   - Đăng ký tại [planetscale.com](https://planetscale.com)
   - Tạo database
   - Lấy connection string
   - Set vào `SPRING_DATASOURCE_URL` trong Render

2. **Railway** (Free tier, MySQL):
   - Đăng ký tại [railway.app](https://railway.app)
   - Tạo MySQL service
   - Lấy connection string

3. **Aiven** (Free trial):
   - Đăng ký tại [aiven.io](https://aiven.io)
   - Tạo MySQL service

---

## 🚀 Cách 3: Deploy Local với Docker Compose (Development)

Nếu bạn muốn test local trước:

```bash
cd PTCMSS
docker-compose up -d
```

Sau đó deploy lên Render với cách 1 (Backend + Frontend Docker + Managed DB).

---

## 📊 So sánh các cách

| Cách | Backend | Frontend | Database | Chi phí | Độ khó |
|------|---------|----------|----------|--------|--------|
| **Cách 1** (Khuyến nghị) | ✅ Docker | ✅ Docker | Managed PostgreSQL | Free | Dễ |
| **Cách 2A** | ✅ Docker | ✅ Docker | MySQL Container | $7+/tháng | Khó |
| **Cách 2B** | ✅ Docker | ✅ Docker | External MySQL | Free | Trung bình |
| **Local** | ✅ Docker | ✅ Docker | MySQL Container | Free | Dễ |

---

## ✅ Kết luận

**File `render.yaml` hiện tại đã đúng!**

- ✅ Backend deploy bằng **Docker** (`env: docker`)
- ✅ Frontend deploy bằng **Docker** (`env: docker`)
- ✅ Database dùng **managed service** (tốt hơn container)

**Bạn không cần thay đổi gì!** Chỉ cần:
1. Push code lên GitHub
2. Tạo Blueprint trên Render với file `render.yaml`
3. Set environment variables
4. Deploy!

---

## 🔧 Nếu muốn dùng MySQL thay vì PostgreSQL

### Option 1: External MySQL (Dễ nhất)
1. Tạo MySQL trên PlanetScale/Railway
2. Lấy connection string
3. Set vào `SPRING_DATASOURCE_URL` trong Render Dashboard
4. Thêm MySQL driver vào `pom.xml` (đã có sẵn)

### Option 2: Thêm PostgreSQL support
1. Thêm dependency vào `pom.xml`:
   ```xml
   <dependency>
       <groupId>org.postgresql</groupId>
       <artifactId>postgresql</artifactId>
       <scope>runtime</scope>
   </dependency>
   ```
2. Update `application-prod.yml` để tự động detect database type
3. Hibernate sẽ tự động tạo schema

---

## 📝 Tóm tắt

**Câu trả lời ngắn gọn:**
- ✅ **Backend**: Đã dùng Docker (trong `render.yaml`)
- ✅ **Frontend**: Đã dùng Docker (trong `render.yaml`)
- ⚠️ **Database**: Dùng managed service (tốt hơn container)

**Bạn có thể deploy ngay với file `render.yaml` hiện tại!** 🚀

