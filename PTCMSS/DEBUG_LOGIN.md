# 🐛 DEBUG LOGIN - Hướng dẫn sửa lỗi 403

## 🔍 BƯỚC 1: Test Password Hash

Sau khi restart backend, mở trình duyệt và test:

### Test 1: Generate Hash mới
```
http://localhost:8080/api/test/generate-hash?password=123456
```

Kết quả sẽ trả về hash mới. Copy hash này.

### Test 2: Test password với user trong DB
```
http://localhost:8080/api/test/test-password?username=admin&password=123456
```

Kết quả sẽ cho biết:
- `matches`: true/false (hash có đúng không)
- `status`: ACTIVE/INACTIVE
- `isEnabled`: true/false
- Nếu `matches = false`, sẽ có `newHash` và `sqlUpdate` để copy

---

## 🔧 BƯỚC 2: Update Password trong Database

### Nếu `matches = false`:

1. Copy SQL từ kết quả test (field `sqlUpdate`)
2. Chạy SQL đó trong MySQL Workbench
3. **RESTART BACKEND** (quan trọng!)
4. Test lại login

### Hoặc chạy script SQL:

```sql
USE ptcmss_db;

-- Lấy hash mới từ endpoint test
-- Sau đó update:
UPDATE Users 
SET passwordHash = '<hash_mới_từ_test>',
    status = 'ACTIVE'
WHERE username = 'admin';
```

---

## 🔍 BƯỚC 3: Kiểm tra Logs trong IntelliJ

Khi login, xem logs trong IntelliJ console:

### Logs bình thường (thành công):
```
[LOGIN] Request login for username: admin
[UserDetailsService] Loading user by username: admin
[UserDetailsService] User loaded successfully: admin (Role: Admin)
[AUTHENTICATION_SERVICE] Authenticating user: admin
[LOGIN] Login successful for username: admin
```

### Logs lỗi (cần kiểm tra):
```
[UserDetailsService] Loading user by username: admin
⚠️ [UserDetailsService] User not found with username: admin
→ Username sai hoặc không tồn tại

[AUTHENTICATION_SERVICE] Authenticating user: admin
Error authenticating user: Bad credentials
→ Password hash không đúng

[AUTHENTICATION_SERVICE] Authenticating user: admin
Error authenticating user: User is disabled
→ User status = INACTIVE
```

---

## ✅ CHECKLIST

- [ ] Đã chạy script `UPDATE_PASSWORDS.sql` với `status = 'ACTIVE'`
- [ ] Đã test password hash bằng endpoint `/api/test/test-password`
- [ ] Nếu `matches = false`, đã update hash mới
- [ ] Đã **RESTART BACKEND** sau khi update database
- [ ] Đã kiểm tra logs trong IntelliJ
- [ ] Username và password đúng: `admin` / `123456`

---

## 🚨 NẾU VẪN LỖI

### Kiểm tra trong Database:

```sql
USE ptcmss_db;

-- Kiểm tra user
SELECT userId, username, status, LEFT(passwordHash, 30) as hash_preview
FROM Users 
WHERE username = 'admin';

-- Phải thấy:
-- username: admin
-- status: ACTIVE (chữ hoa)
-- hash_preview: $2a$10$... (bắt đầu bằng $2a$10$)
```

### Kiểm tra Role:

```sql
-- Kiểm tra user có role không
SELECT u.username, u.status, r.roleName
FROM Users u
LEFT JOIN Roles r ON u.roleId = r.roleId
WHERE u.username = 'admin';

-- Phải thấy roleName: Admin
```

---

## 📝 LƯU Ý QUAN TRỌNG

1. **Status phải là 'ACTIVE'** (chữ hoa) - không phải 'Active'
2. **Phải restart backend** sau mỗi lần update database
3. **Hash BCrypt** mỗi lần generate khác nhau, nhưng đều match với cùng password
4. **Kiểm tra logs** để biết lỗi cụ thể

---

*Tài liệu được tạo: 2025-11-11*

