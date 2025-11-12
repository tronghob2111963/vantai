# 🔐 HƯỚNG DẪN ĐĂNG NHẬP - PTCMSS

## ⚠️ VẤN ĐỀ THƯỜNG GẶP KHI LOGIN

### 1. **Lỗi 403 Forbidden**

**Nguyên nhân:**
- ❌ Password hash không đúng
- ❌ User status = 'Inactive' (phải là 'Active')
- ❌ Username không tồn tại

**Giải pháp:**
1. Chạy script `UPDATE_PASSWORDS.sql` để cập nhật password và status
2. Đảm bảo user có `status = 'Active'` trong database

---

## 📋 THÔNG TIN ĐĂNG NHẬP MẶC ĐỊNH

Sau khi chạy script `UPDATE_PASSWORDS.sql`, tất cả user đều dùng:

**Password: `123456`**

### Danh sách Username:

| Username | Role | Password |
|----------|------|----------|
| `admin` | Admin | `123456` |
| `manager_hn` | Manager (Hà Nội) | `123456` |
| `manager_dn` | Manager (Đà Nẵng) | `123456` |
| `manager_hcm` | Manager (HCM) | `123456` |
| `consultant_hn1` | Consultant | `123456` |
| `consultant_hn2` | Consultant | `123456` |
| `accountant_hn1` | Accountant | `123456` |
| `driver_a` | Driver | `123456` |
| `driver_b` | Driver | `123456` |
| `driver_c` | Driver | `123456` |
| `driver_d` | Driver | `123456` |
| `driver_e` | Driver | `123456` |
| `driver_f` | Driver | `123456` |
| `driver_g` | Driver | `123456` |

---

## 🔧 CÁCH KIỂM TRA VÀ FIX

### Bước 1: Kiểm tra User trong Database

```sql
USE ptcmss_db;

-- Kiểm tra user có tồn tại không
SELECT userId, username, status, passwordHash 
FROM Users 
WHERE username = 'manager_hn';

-- Kiểm tra status phải là 'Active'
SELECT username, status 
FROM Users 
WHERE status != 'Active';
```

### Bước 2: Cập nhật Password và Status

Chạy file: `PTCMSS/db_scripts/UPDATE_PASSWORDS.sql`

Script này sẽ:
- ✅ Cập nhật password hash đúng cho tất cả user
- ✅ Đảm bảo `status = 'Active'` để có thể login

### Bước 3: Test Login trong Swagger

1. Mở Swagger UI: http://localhost:8080/swagger-ui.html
2. Tìm endpoint: `POST /api/auth/login`
3. Click **Try it out**
4. Nhập:
   ```json
   {
     "username": "admin",
     "password": "123456"
   }
   ```
5. Click **Execute**
6. Nếu thành công, bạn sẽ nhận được `accessToken`

---

## 🐛 DEBUG NẾU VẪN LỖI

### Kiểm tra Logs trong IntelliJ

Khi login, xem logs trong IntelliJ console:

```
[UserDetailsService] Loading user by username: admin
[UserDetailsService] User loaded successfully: admin (Role: Admin)
[AUTHENTICATION_SERVICE] Authenticating user: admin
```

Nếu thấy lỗi:
- `User not found` → Username sai hoặc không tồn tại
- `Invalid username or password` → Password hash không đúng
- `403 Forbidden` → User status = 'Inactive'

### Kiểm tra BCrypt Hash

Nếu muốn tạo hash mới, dùng script Java:

```java
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
String hash = encoder.encode("123456");
System.out.println(hash);
```

---

## ✅ CHECKLIST TRƯỚC KHI LOGIN

- [ ] Đã chạy script `00_full_setup.sql` để tạo database
- [ ] Đã chạy script `UPDATE_PASSWORDS.sql` để cập nhật password
- [ ] User có `status = 'Active'` trong database
- [ ] Backend đang chạy (port 8080)
- [ ] Đang dùng đúng username và password: `123456`

---

## 📝 LƯU Ý

1. **BCrypt Hash**: Mỗi lần generate hash sẽ khác nhau (do salt), nhưng đều match với cùng một password
2. **User Status**: Phải là `'Active'` mới login được (kiểm tra trong `Users` table)
3. **Password**: Tất cả user mặc định dùng `123456` (có thể đổi sau khi login)

---

*Tài liệu được tạo: 2025-11-11*

