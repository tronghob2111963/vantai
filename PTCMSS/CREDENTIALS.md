# 🔐 Danh sách Credentials - PTCMSS

## 📋 Tổng quan
Tất cả users đều có **password: `123456`** và **status: `ACTIVE`**

---

## 👤 Admin Account

| Username | Password | Role | Mô tả |
|----------|----------|------|-------|
| `admin` | `123456` | Admin | Quản trị viên hệ thống |

---

## 👔 Manager Accounts (Quản lý chi nhánh)

| Username | Password | Role | Chi nhánh |
|----------|----------|------|-----------|
| `manager_hn` | `123456` | Manager | Hà Nội |
| `manager_dn` | `123456` | Manager | Đà Nẵng |
| `manager_hcm` | `123456` | Manager | TP. HCM |

---

## 📞 Consultant Accounts (Điều hành/Tư vấn)

| Username | Password | Role | Chi nhánh |
|----------|----------|------|-----------|
| `consultant_hn1` | `123456` | Consultant | Hà Nội |
| `consultant_hn2` | `123456` | Consultant | Hà Nội |

---

## 💰 Accountant Accounts (Kế toán)

| Username | Password | Role | Chi nhánh |
|----------|----------|------|-----------|
| `accountant_hn1` | `123456` | Accountant | Hà Nội |

---

## 🚗 Driver Accounts (Tài xế)

| Username | Password | Role | Chi nhánh |
|----------|----------|------|-----------|
| `driver_a` | `123456` | Driver | Hà Nội |
| `driver_b` | `123456` | Driver | Hà Nội |
| `driver_c` | `123456` | Driver | Đà Nẵng |
| `driver_d` | `123456` | Driver | TP. HCM |
| `driver_e` | `123456` | Driver | Hà Nội |
| `driver_f` | `123456` | Driver | Đà Nẵng |
| `driver_g` | `123456` | Driver | TP. HCM |

---

## 🔄 Cách update password

### Option 1: Update tất cả users (khuyến nghị)
Chạy script: `PTCMSS/db_scripts/UPDATE_ALL_PASSWORDS.sql`

### Option 2: Update từng user
Sử dụng endpoint test để generate hash mới:
```
GET http://localhost:8080/api/test/generate-hash?password=YOUR_PASSWORD
```

Sau đó update trong MySQL:
```sql
UPDATE Users 
SET passwordHash = 'HASH_MỚI_GENERATE',
    status = 'ACTIVE'
WHERE username = 'username_của_bạn';
```

---

## ⚠️ Lưu ý

1. **Password mặc định:** Tất cả users có password `123456` (chỉ dùng cho development)
2. **Status:** Phải là `ACTIVE` (chữ hoa) để login được
3. **Production:** Nên đổi password mạnh hơn trước khi deploy
4. **Security:** Không commit file này vào git nếu chứa password thật

---

## 🧪 Test Login

### Swagger UI
1. Mở: `http://localhost:8080/swagger-ui.html`
2. Endpoint: `POST /api/auth/login`
3. Body:
```json
{
  "username": "admin",
  "password": "123456"
}
```

### Test Endpoint
```
GET http://localhost:8080/api/test/test-password?username=admin&password=123456
```

---

## 📝 Ghi chú

- File này được tạo tự động từ database schema
- Cập nhật lần cuối: 2025-11-12
- Tất cả passwords đã được hash bằng BCrypt

