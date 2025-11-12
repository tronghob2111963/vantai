# 🔧 HƯỚNG DẪN FIX LỖI LOGIN 403 FORBIDDEN

## ❌ VẤN ĐỀ

Khi login với `accountant_hn1` / `123456`, nhận được **403 Forbidden**.

---

## 🔍 NGUYÊN NHÂN CÓ THỂ

1. **Status không đúng:** Database có `status = 'Active'` nhưng Java enum cần `'ACTIVE'` (chữ hoa)
2. **Password hash không đúng:** Hash trong DB không match với password "123456"
3. **User không enabled:** `isEnabled()` trả về `false` vì status không phải `ACTIVE`

---

## ✅ GIẢI PHÁP

### Bước 1: Chạy script SQL để fix

```sql
-- Chạy file này trong MySQL Workbench
PTCMSS/db_scripts/FINAL_FIX_ALL_USERS.sql
```

Script này sẽ:
- ✅ Update password hash cho tất cả users
- ✅ Set status = 'ACTIVE' (chữ hoa)
- ✅ Verify kết quả

### Bước 2: Test password hash qua API

Sau khi chạy script, test qua API:

```bash
# Test password hash
GET http://localhost:8080/api/test/test-password?username=accountant_hn1&password=123456
```

**Kết quả mong đợi:**
```json
{
  "username": "accountant_hn1",
  "password": "123456",
  "matches": true,  // ✅ Phải là true
  "status": "ACTIVE",  // ✅ Phải là ACTIVE
  "isEnabled": true  // ✅ Phải là true
}
```

### Bước 3: Thử login lại

```bash
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
  "username": "accountant_hn1",
  "password": "123456"
}
```

---

## 🐛 DEBUG NẾU VẪN LỖI

### 1. Kiểm tra logs backend

Xem logs khi login để tìm lỗi cụ thể:
```
[LOGIN] Request login for username: accountant_hn1
[UserDetailsService] Loading user by username: accountant_hn1
Error authenticating user: ...
```

### 2. Kiểm tra database trực tiếp

```sql
USE ptcmss_db;

SELECT 
    username,
    status,
    LEFT(passwordHash, 30) as hash_preview,
    CASE 
        WHEN status = 'ACTIVE' THEN '✅'
        ELSE '❌'
    END as check
FROM Users
WHERE username = 'accountant_hn1';
```

**Phải thấy:**
- `status = 'ACTIVE'` (chữ hoa)
- `hash_preview = '$2a$10$P2Hh.Eos8YK/MxXUXSqOj'`

### 3. Test với user khác

Thử login với user khác để xem có phải vấn đề chung không:
- `admin` / `123456`
- `manager_hn` / `123456`

### 4. Kiểm tra Spring Security logs

Bật debug logs trong `application.yml`:
```yaml
logging:
  level:
    org.springframework.security: DEBUG
    org.example.ptcmssbackend: DEBUG
```

---

## 📋 CHECKLIST

- [ ] Đã chạy `FINAL_FIX_ALL_USERS.sql`
- [ ] Status = 'ACTIVE' (chữ hoa) trong database
- [ ] Password hash đúng (test qua `/api/test/test-password`)
- [ ] `isEnabled()` trả về `true` (test qua API)
- [ ] Đã restart backend sau khi update database
- [ ] Đã thử login lại

---

## ⚠️ LƯU Ý QUAN TRỌNG

1. **Status phải là 'ACTIVE' (chữ hoa)** - không phải 'Active' hay 'active'
2. **Password hash phải match** - test qua `/api/test/test-password`
3. **Restart backend** sau khi update database
4. **Kiểm tra logs** để xem lỗi cụ thể

---

## 🔗 CÁC ENDPOINT HỮU ÍCH

- `GET /api/test/test-password?username=accountant_hn1&password=123456` - Test password
- `GET /api/test/generate-hash?password=123456` - Generate hash mới
- `GET /api/test/auth-info` - Xem thông tin authentication (cần token)

---

## ✅ SAU KHI FIX

Nếu vẫn không được, hãy:
1. Copy logs backend khi login
2. Copy kết quả của `/api/test/test-password`
3. Copy kết quả SQL query status

