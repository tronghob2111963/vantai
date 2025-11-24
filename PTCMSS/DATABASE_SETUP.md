# Database Setup Guide

## Tự động tạo Database khi chạy dự án

Dự án đã được cấu hình để **tự động tạo database** khi khởi động lần đầu.

### Yêu cầu

1. **MySQL Server** đang chạy (port 3306)
2. **MySQL User** có quyền tạo database (mặc định: `root`)

### Cách hoạt động

1. **Tự động tạo database**: 
   - URL connection có tham số `createDatabaseIfNotExist=true`
   - Spring Boot sẽ tự động tạo database `ptcmss_db` nếu chưa tồn tại

2. **Tự động tạo tables**:
   - Hibernate với `ddl-auto: update` sẽ tự động tạo/cập nhật tables từ các Entity classes
   - Không cần chạy script SQL thủ công

3. **Tự động insert dữ liệu khởi tạo**:
   - File `data.sql` sẽ tự động chạy khi khởi động
   - Insert các dữ liệu cần thiết: roles, admin user, hire types, vehicle categories, system settings

### Cấu hình Database

Mở file `application.yml` và cập nhật thông tin kết nối:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ptcmss_db?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
    username: root      # Thay đổi username của bạn
    password: 1001      # Thay đổi password của bạn
```

### Khởi động dự án

```bash
cd PTCMSS/ptcmss-backend
mvn spring-boot:run
```

Hoặc chạy từ IDE (IntelliJ IDEA, Eclipse):
- Run `PtcmssBackendApplication.java`

### Tài khoản mặc định

Sau khi khởi động thành công, bạn có thể đăng nhập với:

- **Username**: `admin`
- **Password**: `123456`
- **Email**: `admin@ptcmss.com`

### Import dữ liệu mẫu (Optional)

Nếu muốn import toàn bộ dữ liệu mẫu từ file backup:

```bash
mysql -u root -p ptcmss_db < db_scripts/db-tamthoi.sql
```

### Troubleshooting

**Lỗi: Access denied for user**
- Kiểm tra username/password trong `application.yml`
- Đảm bảo MySQL user có quyền CREATE DATABASE

**Lỗi: Communications link failure**
- Kiểm tra MySQL Server đang chạy
- Kiểm tra port 3306 không bị chặn

**Lỗi: Table already exists**
- Xóa database cũ: `DROP DATABASE ptcmss_db;`
- Chạy lại ứng dụng

### Reset Database

Để reset database về trạng thái ban đầu:

```sql
DROP DATABASE IF EXISTS ptcmss_db;
```

Sau đó chạy lại ứng dụng, database sẽ được tạo lại tự động.

### Production Setup

Với môi trường production, nên:

1. Thay đổi `ddl-auto: validate` (không tự động sửa schema)
2. Sử dụng migration tools như Flyway hoặc Liquibase
3. Tắt `sql.init.mode` hoặc đặt thành `never`

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: validate  # Production: không tự động sửa schema
  sql:
    init:
      mode: never  # Production: không chạy data.sql
```
