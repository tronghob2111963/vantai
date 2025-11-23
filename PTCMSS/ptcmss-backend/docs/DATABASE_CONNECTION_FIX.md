# 🔧 FIX LỖI KẾT NỐI DATABASE

## ❌ LỖI HIỆN TẠI

```
Access denied for user 'root'@'localhost' (using password: YES)
```

## 🔍 NGUYÊN NHÂN

Lỗi này xảy ra khi:
1. **Password MySQL không đúng** - Password trong config không khớp với MySQL
2. **MySQL chưa chạy** - Service MySQL chưa được start
3. **Database chưa tồn tại** - Database `ptcmss_db` chưa được tạo
4. **User không có quyền** - User `root` không có quyền truy cập

---

## ✅ CÁCH FIX

### **Bước 1: Kiểm tra MySQL đã chạy chưa**

#### Windows:
```powershell
# Kiểm tra service MySQL
Get-Service -Name MySQL*

# Hoặc kiểm tra process
Get-Process -Name mysqld -ErrorAction SilentlyContinue
```

#### Nếu MySQL chưa chạy:
```powershell
# Start MySQL service
Start-Service MySQL80
# Hoặc
net start MySQL80
```

---

### **Bước 2: Kiểm tra password MySQL**

#### Cách 1: Thử kết nối bằng MySQL Command Line
```bash
mysql -u root -p
# Nhập password hiện tại của bạn
```

#### Cách 2: Reset password MySQL (nếu quên)

**Windows:**
1. Stop MySQL service:
   ```powershell
   Stop-Service MySQL80
   ```

2. Start MySQL với skip-grant-tables:
   ```powershell
   mysqld --skip-grant-tables --console
   ```

3. Mở terminal mới, kết nối MySQL:
   ```bash
   mysql -u root
   ```

4. Reset password:
   ```sql
   USE mysql;
   UPDATE user SET authentication_string=PASSWORD('123456') WHERE User='root';
   FLUSH PRIVILEGES;
   EXIT;
   ```

5. Stop MySQL và start lại bình thường:
   ```powershell
   Stop-Service MySQL80
   Start-Service MySQL80
   ```

---

### **Bước 3: Tạo Database (nếu chưa có)**

```sql
CREATE DATABASE IF NOT EXISTS ptcmss_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

---

### **Bước 4: Cập nhật cấu hình trong `application-dev.yml`**

File: `src/main/resources/application-dev.yml`

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ptcmss_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
    username: root
    password: YOUR_ACTUAL_PASSWORD  # ← Thay bằng password thực tế của bạn
```

**Hoặc dùng environment variable:**

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ptcmss_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:123456}  # ← Đọc từ environment variable
```

Sau đó set environment variable:
```powershell
# Windows PowerShell
$env:DB_PASSWORD="your_actual_password"
```

---

### **Bước 5: Kiểm tra kết nối**

#### Test bằng MySQL Command Line:
```bash
mysql -u root -p123456 -e "SHOW DATABASES;"
```

#### Test bằng JDBC URL:
```bash
# Nếu có mysql client
mysql -u root -p123456 -h localhost -P 3306 ptcmss_db
```

---

## 🔄 CÁC TÌNH HUỐNG KHÁC

### **Tình huống 1: MySQL chạy trên port khác**

Nếu MySQL chạy trên port khác (ví dụ: 3307), update URL:
```yaml
url: jdbc:mysql://localhost:3307/ptcmss_db?...
```

### **Tình huống 2: MySQL chạy trên remote server**

```yaml
url: jdbc:mysql://your-server-ip:3306/ptcmss_db?...
username: your_username
password: your_password
```

### **Tình huống 3: Dùng Docker MySQL**

Nếu dùng Docker:
```yaml
url: jdbc:mysql://localhost:3306/ptcmss_db?...
# Hoặc nếu expose port khác
url: jdbc:mysql://localhost:3307/ptcmss_db?...
```

---

## 🧪 TEST SAU KHI FIX

1. **Start lại Spring Boot application**
2. **Kiểm tra log:**
   ```
   HikariPool-1 - Starting...
   HikariPool-1 - Start completed.
   ```
3. **Không còn lỗi:**
   ```
   Access denied for user 'root'@'localhost'
   ```

---

## 📝 CHECKLIST

- [ ] MySQL service đã chạy
- [ ] Password trong config đúng với MySQL
- [ ] Database `ptcmss_db` đã tồn tại
- [ ] User `root` có quyền truy cập
- [ ] Port MySQL đúng (3306 hoặc port khác)
- [ ] Test kết nối thành công
- [ ] Spring Boot start không còn lỗi database

---

## 🆘 NẾU VẪN LỖI

1. **Kiểm tra MySQL logs:**
   - Windows: `C:\ProgramData\MySQL\MySQL Server 8.0\Data\*.err`
   - Linux: `/var/log/mysql/error.log`

2. **Kiểm tra firewall:**
   - Đảm bảo port 3306 không bị block

3. **Kiểm tra MySQL user privileges:**
   ```sql
   SELECT user, host FROM mysql.user WHERE user='root';
   SHOW GRANTS FOR 'root'@'localhost';
   ```

4. **Tạo user mới với quyền đầy đủ:**
   ```sql
   CREATE USER 'ptcmss_user'@'localhost' IDENTIFIED BY 'your_password';
   GRANT ALL PRIVILEGES ON ptcmss_db.* TO 'ptcmss_user'@'localhost';
   FLUSH PRIVILEGES;
   ```
   
   Sau đó update config:
   ```yaml
   username: ptcmss_user
   password: your_password
   ```

---

**Lưu ý:** Đảm bảo password MySQL trong config khớp với password thực tế của bạn!
