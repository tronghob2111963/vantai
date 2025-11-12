# 🚀 HƯỚNG DẪN CHẠY DỰ ÁN PTCMSS BACKEND TRONG INTELLIJ IDEA

## 📋 YÊU CẦU HỆ THỐNG

### Phần mềm cần cài đặt:
1. **IntelliJ IDEA** (Community hoặc Ultimate Edition)
   - Version: 2023.1 trở lên (khuyến nghị 2024.x)
   - Download: https://www.jetbrains.com/idea/download/

2. **JDK 21** (Java Development Kit)
   - Dự án sử dụng Java 21
   - Download: https://www.oracle.com/java/technologies/downloads/#java21
   - Hoặc sử dụng OpenJDK: https://adoptium.net/

3. **Maven** (thường đã có sẵn trong IntelliJ)
   - Version: 3.9+ (khuyến nghị)
   - IntelliJ thường bundle Maven, hoặc cài riêng: https://maven.apache.org/

4. **MySQL Server**
   - Version: 8.0 trở lên
   - Download: https://dev.mysql.com/downloads/mysql/
   - Hoặc sử dụng XAMPP/WAMP (bao gồm MySQL)

---

## 🔧 BƯỚC 1: CÀI ĐẶT VÀ CẤU HÌNH MYSQL

### 1.1. Cài đặt MySQL
- Tải và cài đặt MySQL Server
- Ghi nhớ **root password** khi cài đặt

### 1.2. Tạo Database
Mở MySQL Command Line hoặc MySQL Workbench và chạy:

```sql
-- Tạo database
CREATE DATABASE ptcmss_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Kiểm tra database đã tạo
SHOW DATABASES;
```

### 1.3. Kiểm tra thông tin kết nối
Theo file `application.yml`, cấu hình database:
- **Host**: localhost
- **Port**: 3306 (mặc định)
- **Database**: ptcmss_db
- **Username**: root
- **Password**: 123456 (hoặc password bạn đã đặt)

> ⚠️ **Lưu ý**: Nếu password MySQL của bạn khác, cần sửa trong `application.yml` hoặc `application-dev.yml`

---

## 📥 BƯỚC 2: IMPORT PROJECT VÀO INTELLIJ IDEA

### 2.1. Mở IntelliJ IDEA

### 2.2. Import Project
Có 2 cách:

#### **Cách 1: Open Project (Khuyến nghị)**
1. Click **File** → **Open** (hoặc **Open or Import**)
2. Chọn thư mục: `D:\Project\vantai\PTCMSS\ptcmss-backend`
3. IntelliJ sẽ tự động nhận diện đây là Maven project
4. Click **Trust Project** nếu được hỏi

#### **Cách 2: Import từ Maven**
1. Click **File** → **New** → **Project from Existing Sources**
2. Chọn thư mục `ptcmss-backend`
3. Chọn **Import project from external model** → **Maven**
4. Click **Next** → **Next** → **Finish**

### 2.3. Đợi IntelliJ Index và Download Dependencies
- IntelliJ sẽ tự động:
  - Đọc file `pom.xml`
  - Download tất cả dependencies từ Maven repositories
  - Index code
- Quá trình này có thể mất 2-5 phút tùy internet
- Xem tiến trình ở góc dưới bên phải: **"Indexing..."** hoặc **"Maven: Downloading..."**

---

## ⚙️ BƯỚC 3: CẤU HÌNH JDK VÀ MAVEN

### 3.1. Cấu hình JDK 21

1. Mở **File** → **Project Structure** (hoặc nhấn `Ctrl + Alt + Shift + S`)

2. Trong tab **Project**:
   - **SDK**: Chọn **JDK 21**
     - Nếu chưa có, click **Add SDK** → **Download JDK** → Chọn **Version 21**
   - **Language level**: Chọn **21 - Record patterns, pattern matching for switch**

3. Trong tab **Modules**:
   - Đảm bảo **Language level** là **21**

4. Click **OK**

### 3.2. Cấu hình Maven

1. Mở **File** → **Settings** (hoặc `Ctrl + Alt + S`)
   - Trên Mac: **IntelliJ IDEA** → **Preferences**

2. Điều hướng: **Build, Execution, Deployment** → **Build Tools** → **Maven**

3. Cấu hình:
   - **Maven home path**: Để mặc định (IntelliJ bundled Maven) hoặc chọn Maven đã cài
   - **User settings file**: Để mặc định
   - **Local repository**: Để mặc định (thường là `C:\Users\<username>\.m2\repository`)

4. Click **OK**

### 3.3. Reload Maven Project

1. Mở **Maven** tool window:
   - Click tab **Maven** ở góc dưới bên phải
   - Hoặc **View** → **Tool Windows** → **Maven**

2. Click icon **Reload All Maven Projects** (🔄) ở thanh toolbar Maven

---

## 🔨 BƯỚC 4: CẤU HÌNH RUN CONFIGURATION

### 4.1. Tạo Run Configuration

1. Mở file: `src/main/java/org/example/ptcmssbackend/PtcmssBackendApplication.java`

2. Click chuột phải vào class `PtcmssBackendApplication`

3. Chọn **Run 'PtcmssBackendApplication.main()'**
   - Hoặc nhấn `Shift + F10`
   - Hoặc click icon ▶️ bên cạnh method `main()`

4. IntelliJ sẽ tự động tạo Run Configuration

### 4.2. Tùy chỉnh Run Configuration (Tùy chọn)

1. Click vào dropdown **Run Configuration** (góc trên bên phải)

2. Chọn **Edit Configurations...**

3. Cấu hình:
   - **Name**: `PTCMSS Backend` (tùy chọn)
   - **Main class**: `org.example.ptcmssbackend.PtcmssBackendApplication`
   - **VM options**: (Để trống hoặc thêm nếu cần)
     ```
     -Dspring.profiles.active=dev
     ```
   - **Working directory**: `$MODULE_DIR$`
   - **Use classpath of module**: `ptcmss-backend`

4. Click **OK**

---

## 🏃 BƯỚC 5: CHẠY DỰ ÁN

### 5.1. Chạy Application

1. Đảm bảo MySQL đang chạy:
   - Kiểm tra MySQL Service đang hoạt động
   - Hoặc mở MySQL Workbench và kết nối thành công

2. Chạy ứng dụng:
   - Click nút **Run** (▶️) ở toolbar
   - Hoặc nhấn `Shift + F10`
   - Hoặc chạy từ Maven: `mvn spring-boot:run` trong terminal

3. Xem log trong **Run** tool window (tab ở dưới)

### 5.2. Kiểm tra kết quả

Khi chạy thành công, bạn sẽ thấy log tương tự:

```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.3.8)

2024-XX-XX ... Started PtcmssBackendApplication in X.XXX seconds
```

### 5.3. Truy cập ứng dụng

1. **API Base URL**: http://localhost:8080

2. **Swagger UI** (API Documentation):
   - URL: http://localhost:8080/swagger-ui.html
   - Hoặc: http://localhost:8080/swagger-ui/index.html

3. **API Docs (JSON)**:
   - URL: http://localhost:8080/v3/api-docs

4. **Health Check**:
   - URL: http://localhost:8080/actuator/health

---

## ✅ BƯỚC 6: KIỂM TRA HOẠT ĐỘNG

### 6.1. Test API đơn giản

Mở trình duyệt hoặc Postman và thử:

```bash
# Health check
GET http://localhost:8080/actuator/health

# Swagger UI
GET http://localhost:8080/swagger-ui.html
```

### 6.2. Test Login API

Sử dụng Swagger UI hoặc Postman:

**Endpoint**: `POST /api/auth/login`

**Request Body**:
```json
{
  "username": "admin",
  "password": "password123"
}
```

> ⚠️ **Lưu ý**: Cần có user trong database. Nếu chưa có, cần chạy `SampleDataConfig` hoặc tạo user thủ công.

---

## 🐛 TROUBLESHOOTING (XỬ LÝ LỖI)

### ❌ Lỗi 1: "JDK not found" hoặc "Java version mismatch"

**Nguyên nhân**: IntelliJ chưa cấu hình JDK 21

**Giải pháp**:
1. **File** → **Project Structure** → **Project**
2. Chọn **SDK**: **JDK 21**
3. Nếu chưa có, click **Add SDK** → **Download JDK** → Chọn **Version 21**

---

### ❌ Lỗi 2: "Cannot resolve symbol" hoặc dependencies không tải được

**Nguyên nhân**: Maven chưa download dependencies

**Giải pháp**:
1. Mở **Maven** tool window
2. Click **Reload All Maven Projects** (🔄)
3. Hoặc chạy trong terminal:
   ```bash
   mvn clean install
   ```
4. Đợi download xong (có thể mất vài phút)

---

### ❌ Lỗi 3: "Connection refused" hoặc "Access denied" khi kết nối MySQL

**Nguyên nhân**: 
- MySQL chưa chạy
- Sai username/password
- Database chưa được tạo

**Giải pháp**:
1. Kiểm tra MySQL Service đang chạy:
   - Windows: Mở **Services** → Tìm **MySQL80** → **Start**
   - Hoặc mở MySQL Workbench và kết nối thành công

2. Kiểm tra database đã tạo:
   ```sql
   SHOW DATABASES;
   ```
   Nếu chưa có `ptcmss_db`, tạo:
   ```sql
   CREATE DATABASE ptcmss_db;
   ```

3. Kiểm tra username/password trong `application-dev.yml`:
   ```yaml
   spring:
     datasource:
       username: root
       password: YOUR_MYSQL_PASSWORD  # Sửa nếu khác
   ```

---

### ❌ Lỗi 4: "Port 8080 already in use"

**Nguyên nhân**: Port 8080 đang được sử dụng bởi ứng dụng khác

**Giải pháp**:
1. **Cách 1**: Tắt ứng dụng đang dùng port 8080
   ```bash
   # Windows
   netstat -ano | findstr :8080
   taskkill /PID <PID> /F
   ```

2. **Cách 2**: Đổi port trong `application.yml`:
   ```yaml
   server:
     port: 8081  # Đổi sang port khác
   ```

---

### ❌ Lỗi 5: "ClassNotFoundException" hoặc "NoClassDefFoundError"

**Nguyên nhân**: Dependencies chưa được compile vào classpath

**Giải pháp**:
1. **File** → **Invalidate Caches / Restart**
2. Chọn **Invalidate and Restart**
3. Sau khi restart, chạy lại:
   ```bash
   mvn clean compile
   ```

---

### ❌ Lỗi 6: "Lombok annotations không hoạt động"

**Nguyên nhân**: IntelliJ chưa enable Lombok plugin

**Giải pháp**:
1. **File** → **Settings** → **Plugins**
2. Tìm **Lombok** → **Install** (nếu chưa có)
3. **File** → **Settings** → **Build, Execution, Deployment** → **Compiler** → **Annotation Processors**
4. Tick **Enable annotation processing**
5. Click **OK** và restart IntelliJ

---

### ❌ Lỗi 7: "Email sending failed"

**Nguyên nhân**: Cấu hình email không đúng hoặc Gmail App Password không hợp lệ

**Giải pháp**:
1. Kiểm tra Gmail App Password trong `application-dev.yml`
2. Nếu cần tạo App Password mới:
   - Vào Google Account → Security → 2-Step Verification → App passwords
   - Tạo password mới và cập nhật vào config

---

## 📝 CÁC LỆNH MAVEN HỮU ÍCH

Chạy trong terminal của IntelliJ (View → Tool Windows → Terminal):

```bash
# Clean và compile
mvn clean compile

# Chạy tests
mvn test

# Build JAR file
mvn clean package

# Chạy ứng dụng
mvn spring-boot:run

# Skip tests khi build
mvn clean package -DskipTests
```

---

## 🎯 TIPS & BEST PRACTICES

### 1. Sử dụng Live Reload (Spring DevTools)
Thêm vào `pom.xml` (nếu chưa có):
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <scope>runtime</scope>
    <optional>true</optional>
</dependency>
```

### 2. Enable Auto-Import
Khi IntelliJ hỏi "Auto-import Maven projects?", chọn **Enable Auto-Import**

### 3. Sử dụng Database Tool
IntelliJ có Database tool tích hợp:
- **View** → **Tool Windows** → **Database**
- Thêm MySQL connection để xem dữ liệu trực tiếp

### 4. Debug Mode
- Đặt breakpoint (click bên trái số dòng)
- Chạy ở **Debug mode** (🐛 icon) thay vì Run
- Sử dụng `F8` (Step Over), `F7` (Step Into), `F9` (Resume)

---

## 📚 TÀI LIỆU THAM KHẢO

- Spring Boot Documentation: https://spring.io/projects/spring-boot
- IntelliJ IDEA Help: https://www.jetbrains.com/help/idea/
- Maven Guide: https://maven.apache.org/guides/

---

## ✅ CHECKLIST TRƯỚC KHI CHẠY

- [ ] Đã cài đặt JDK 21
- [ ] Đã cài đặt MySQL và tạo database `ptcmss_db`
- [ ] Đã import project vào IntelliJ
- [ ] Đã cấu hình JDK 21 trong Project Structure
- [ ] Đã reload Maven projects
- [ ] Đã kiểm tra MySQL đang chạy
- [ ] Đã cập nhật password MySQL trong config (nếu cần)
- [ ] Đã tạo Run Configuration
- [ ] Đã chạy ứng dụng thành công
- [ ] Đã truy cập được Swagger UI

---

**Chúc bạn chạy dự án thành công! 🎉**

Nếu gặp lỗi không có trong danh sách, vui lòng:
1. Copy toàn bộ error message
2. Kiểm tra log trong Run tool window
3. Tìm kiếm trên Google với error message

