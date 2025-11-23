# ⚡ QUICK FIX: LỖI KẾT NỐI DATABASE

## 🔴 LỖI
```
Access denied for user 'root'@'localhost' (using password: YES)
```

## ✅ GIẢI PHÁP NHANH

### **Cách 1: Update password trong config (Nhanh nhất)**

Mở file: `src/main/resources/application-dev.yml`

Thay đổi dòng:
```yaml
password: 123456
```

Thành password MySQL thực tế của bạn:
```yaml
password: your_actual_mysql_password
```

### **Cách 2: Dùng Environment Variable (Khuyến nghị)**

File config đã được update để đọc từ environment variable.

**Windows PowerShell:**
```powershell
# Set password trước khi chạy app
$env:DB_PASSWORD="your_actual_mysql_password"

# Hoặc set cho cả session
[System.Environment]::SetEnvironmentVariable('DB_PASSWORD', 'your_actual_mysql_password', 'User')
```

**Windows CMD:**
```cmd
set DB_PASSWORD=your_actual_mysql_password
```

**Linux/Mac:**
```bash
export DB_PASSWORD=your_actual_mysql_password
```

### **Cách 3: Kiểm tra và Fix MySQL**

#### 1. Kiểm tra MySQL đã chạy:
```powershell
# Windows
Get-Service MySQL*

# Nếu chưa chạy:
Start-Service MySQL80
```

#### 2. Test kết nối:
```bash
mysql -u root -p
# Nhập password của bạn
```

#### 3. Nếu quên password, reset:
```sql
-- Kết nối MySQL (skip grant tables)
-- Sau đó chạy:
ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
FLUSH PRIVILEGES;
```

#### 4. Tạo database nếu chưa có:
```sql
CREATE DATABASE IF NOT EXISTS ptcmss_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

---

## 🧪 TEST SAU KHI FIX

1. **Start lại Spring Boot**
2. **Kiểm tra log không còn lỗi:**
   ```
   HikariPool-1 - Start completed.
   ```
3. **Nếu vẫn lỗi, kiểm tra:**
   - MySQL service đã chạy chưa?
   - Password có đúng không?
   - Database `ptcmss_db` đã tồn tại chưa?

---

## 📝 LƯU Ý

- **Không commit password vào Git!**
- Nên dùng environment variable cho production
- File `.env` đã được ignore trong `.gitignore`

---

**Xem chi tiết:** `docs/DATABASE_CONNECTION_FIX.md`
