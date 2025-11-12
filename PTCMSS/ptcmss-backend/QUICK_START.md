# ⚡ QUICK START - CHẠY DỰ ÁN NHANH

## 🚀 5 BƯỚC CHẠY DỰ ÁN

### Bước 1: Cài đặt MySQL và tạo database
```sql
CREATE DATABASE ptcmss_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Bước 2: Mở IntelliJ IDEA
- **File** → **Open** → Chọn folder `ptcmss-backend`
- Click **Trust Project**

### Bước 3: Cấu hình JDK 21
- **File** → **Project Structure** (`Ctrl + Alt + Shift + S`)
- **Project** → **SDK**: Chọn **JDK 21** (hoặc Download nếu chưa có)

### Bước 4: Reload Maven
- Mở **Maven** tool window (góc dưới bên phải)
- Click icon **Reload All Maven Projects** (🔄)

### Bước 5: Chạy ứng dụng
- Mở file: `PtcmssBackendApplication.java`
- Click chuột phải → **Run 'PtcmssBackendApplication.main()'**
- Hoặc nhấn `Shift + F10`

---

## ✅ KIỂM TRA

Sau khi chạy, mở trình duyệt:

- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **Health Check**: http://localhost:8080/actuator/health

---

## ⚠️ LƯU Ý QUAN TRỌNG

1. **MySQL phải đang chạy** trước khi start ứng dụng
2. **Password MySQL** trong `application-dev.yml` phải đúng
3. Nếu port 8080 bị chiếm, đổi port trong `application.yml`

---

## 🐛 LỖI THƯỜNG GẶP

| Lỗi | Giải pháp |
|-----|-----------|
| JDK not found | Cài JDK 21 và cấu hình trong Project Structure |
| Connection refused | Kiểm tra MySQL đang chạy |
| Port 8080 in use | Đổi port hoặc tắt ứng dụng khác |
| Dependencies không tải | Reload Maven projects |

---

📖 **Xem hướng dẫn chi tiết**: `HUONG_DAN_CHAY_DU_AN.md`

