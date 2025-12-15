# ⚡ Quick Start - Deploy lên Render

Hướng dẫn nhanh để deploy dự án PTCMSS lên Render trong 10 phút.

## 🎯 Bước 1: Chuẩn bị (2 phút)

1. ✅ Đảm bảo code đã push lên GitHub/GitLab
2. ✅ Đăng ký tài khoản tại [render.com](https://render.com)

## 🚀 Bước 2: Deploy với Blueprint (5 phút)

1. Vào [Render Dashboard](https://dashboard.render.com)
2. Click **"New +"** → **"Blueprint"**
3. Kết nối repository của bạn
4. Render sẽ tự động detect file `render.yaml`
5. Click **"Apply"** → Đợi deploy (5-10 phút)

## ⚙️ Bước 3: Cấu hình Environment Variables (3 phút)

### Backend (`ptcmss-backend`)

Vào **Dashboard** → **ptcmss-backend** → **Environment** → Thêm:

```
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-gmail-app-password
JWT_SECRET=<tạo chuỗi ngẫu nhiên 32+ ký tự>
JWT_EXPIRATION=86400000
```

### Frontend (`ptcmss-frontend`)

**Sau khi backend deploy xong**, lấy URL backend (ví dụ: `https://ptcmss-backend.onrender.com`)

Vào **Dashboard** → **ptcmss-frontend** → **Environment** → Thêm:

```
VITE_API_BASE=https://ptcmss-backend.onrender.com
```

**⚠️ QUAN TRỌNG**: Sau khi set `VITE_API_BASE`, vào **Manual Deploy** → **Deploy latest commit** để rebuild.

## ✅ Bước 4: Kiểm tra

- Frontend: `https://ptcmss-frontend.onrender.com`
- Backend: `https://ptcmss-backend.onrender.com/actuator/health`
- Swagger: `https://ptcmss-backend.onrender.com/swagger-ui.html`

## 🔑 Đăng nhập

- **Username**: `admin`
- **Password**: `123456`

---

## 📚 Hướng dẫn chi tiết

Xem file [HUONG_DAN_DEPLOY_RENDER.md](./HUONG_DAN_DEPLOY_RENDER.md) để biết thêm chi tiết và troubleshooting.

## ⚠️ Lưu ý

- **Free tier**: Services sẽ sleep sau 15 phút không có traffic
- **Cold start**: Mất 30-60 giây để wake up
- **Build time**: Có thể mất 5-10 phút cho lần đầu

---

**Chúc bạn deploy thành công! 🎉**

