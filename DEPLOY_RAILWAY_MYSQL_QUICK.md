# ⚡ Quick Start - Deploy MySQL trên Railway

Hướng dẫn nhanh để deploy MySQL Docker trên Railway và kết nối với Render.

## 🚀 5 phút setup

### Bước 1: Tạo MySQL trên Railway (2 phút)

1. Đăng nhập [railway.app](https://railway.app)
2. **New Project** → **Empty Project**
3. **+ New** → **Database** → **Add MySQL**
4. Railway tự động tạo MySQL container
5. Click vào MySQL service → Tab **"Variables"**
6. Lưu lại:
   - `MYSQLHOST` (ví dụ: `containers-us-west-123.railway.app`)
   - `MYSQLPORT` (thường là `3306`)
   - `MYSQLDATABASE` (tên database)
   - `MYSQLUSER` (username)
   - `MYSQLPASSWORD` (password)

### Bước 2: Cấu hình Render Backend (2 phút)

1. Vào **Render Dashboard** → **ptcmss-backend** → **Environment**
2. Thêm/sửa các biến:

```
SPRING_DATASOURCE_URL=jdbc:mysql://MYSQLHOST:MYSQLPORT/MYSQLDATABASE?useSSL=true&allowPublicKeyRetrieval=true&serverTimezone=UTC
SPRING_DATASOURCE_USERNAME=MYSQLUSER
SPRING_DATASOURCE_PASSWORD=MYSQLPASSWORD
```

**Ví dụ:**
```
SPRING_DATASOURCE_URL=jdbc:mysql://containers-us-west-123.railway.app:3306/railway?useSSL=true&allowPublicKeyRetrieval=true&serverTimezone=UTC
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=abc123xyz
```

### Bước 3: Redeploy (1 phút)

1. Render Dashboard → **ptcmss-backend** → **Manual Deploy** → **Deploy latest commit**
2. Đợi deploy xong
3. Check logs để verify connection

## ✅ Done!

Backend sẽ kết nối đến MySQL trên Railway.

## 📚 Chi tiết

Xem file [HUONG_DAN_RAILWAY_MYSQL.md](./HUONG_DAN_RAILWAY_MYSQL.md) để biết thêm.

