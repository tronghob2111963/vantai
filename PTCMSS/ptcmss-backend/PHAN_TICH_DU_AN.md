# 📊 PHÂN TÍCH DỰ ÁN PTCMSS BACKEND

## 🎯 TỔNG QUAN DỰ ÁN

**PTCMSS (Passenger Transport Company Management System)** là hệ thống quản lý vận tải hành khách, được xây dựng bằng **Spring Boot 3.3.8** với **Java 21**.

### Thông tin cơ bản:
- **Framework**: Spring Boot 3.3.8
- **Java Version**: 21
- **Database**: MySQL (ptcmss_db)
- **Build Tool**: Maven
- **Port**: 8080
- **API Documentation**: Swagger/OpenAPI 3.0

---

## 🏗️ KIẾN TRÚC HỆ THỐNG

### 1. **Kiến trúc tổng thể**
```
┌─────────────────────────────────────────┐
│         Frontend (React/Vite)           │
│      (http://localhost:5173)           │
└──────────────┬──────────────────────────┘
               │ HTTP/REST API
               │ JWT Authentication
┌──────────────▼──────────────────────────┐
│     Spring Boot Backend (Port 8080)     │
│  ┌──────────────────────────────────┐   │
│  │  Controllers (REST API)          │   │
│  ├──────────────────────────────────┤   │
│  │  Services (Business Logic)        │   │
│  ├──────────────────────────────────┤   │
│  │  Repositories (Data Access)       │   │
│  ├──────────────────────────────────┤   │
│  │  Entities (Domain Model)          │   │
│  └──────────────────────────────────┘   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         MySQL Database                  │
│      (ptcmss_db)                        │
└─────────────────────────────────────────┘
```

### 2. **Cấu trúc thư mục**
```
ptcmss-backend/
├── src/main/java/org/example/ptcmssbackend/
│   ├── common/              # Các class dùng chung (TokenType)
│   ├── config/              # Cấu hình (Security, CORS, OpenAPI)
│   ├── controller/          # REST Controllers (8 controllers)
│   ├── dto/                 # Data Transfer Objects
│   │   ├── request/         # Request DTOs
│   │   └── response/        # Response DTOs
│   ├── entity/              # JPA Entities (23 entities)
│   ├── enums/               # Enumerations (17 enums)
│   ├── exception/           # Custom Exceptions
│   ├── mapper/              # Entity-DTO Mappers
│   ├── repository/          # JPA Repositories (11 repositories)
│   └── service/             # Business Logic Services
│       └── impl/            # Service Implementations
└── src/main/resources/
    ├── application.yml       # Cấu hình chính
    ├── application-dev.yml   # Cấu hình môi trường dev
    └── templates/           # Email templates (Thymeleaf)
```

---

## 🔐 BẢO MẬT & XÁC THỰC

### 1. **Spring Security Configuration**
- **Authentication**: JWT (JSON Web Token)
- **Password Encoding**: BCrypt
- **Session Management**: Stateless (JWT-based)
- **CORS**: Cho phép `http://localhost:5173` và `http://localhost:8080`

### 2. **JWT Implementation**
- **Library**: `jjwt` (version 0.11.5)
- **Token Types**:
  - `ACCESS_TOKEN`: Token ngắn hạn (3600 phút = 60 giờ)
  - `REFRESH_TOKEN`: Token dài hạn (5 ngày)
  - `EMAIL_VERIFY_TOKEN`: Token xác thực email
  - `PASSWORD_RESET_TOKEN`: Token đặt lại mật khẩu

### 3. **Security Filter Chain**
- **Custom Filter**: `CustomizeRequestFilter` - Xử lý JWT từ:
  - Header: `Authorization: Bearer <token>`
  - Cookie: `access_token`
- **Public Endpoints** (không cần authentication):
  - `/swagger-ui/**`
  - `/v3/api-docs/**`
  - `/api/auth/**`
  - `/verify`
  - `/set-password`

### 4. **User Details Service**
- `CustomUserDetailsService`: Load user từ database
- `Users` entity implement `UserDetails` interface
- Role-based authorization với `@EnableGlobalMethodSecurity`

---

## 📦 DEPENDENCIES CHÍNH

### Core Dependencies:
- **spring-boot-starter-web**: REST API
- **spring-boot-starter-data-jpa**: Database access
- **spring-boot-starter-security**: Security
- **spring-boot-starter-validation**: Input validation
- **spring-boot-starter-mail**: Email service (Gmail SMTP)
- **spring-boot-starter-thymeleaf**: Email templates
- **spring-boot-starter-actuator**: Health monitoring

### Third-party Libraries:
- **mysql-connector-j**: MySQL driver
- **lombok**: Code generation
- **springdoc-openapi**: Swagger UI
- **jjwt**: JWT handling

---

## 🗄️ DATABASE MODEL

### Core Entities (23 entities):

#### 1. **User Management**
- `Users`: Người dùng hệ thống
- `Roles`: Vai trò (Admin, Manager, Driver, Consultant, Accountant, Coordinator)
- `Employees`: Nhân viên
- `Branches`: Chi nhánh

#### 2. **Driver Management**
- `Drivers`: Tài xế (liên kết với Employees)
- `DriverDayOff`: Đơn nghỉ phép của tài xế

#### 3. **Vehicle Management**
- `Vehicles`: Phương tiện
- `VehicleCategoryPricing`: Danh mục và giá xe

#### 4. **Booking & Trip Management**
- `Customers`: Khách hàng
- `Bookings`: Đơn đặt chuyến
- `BookingVehicleDetails`: Chi tiết xe trong đơn
- `Trips`: Chuyến đi
- `TripDrivers`: Gán tài xế cho chuyến
- `TripVehicles`: Gán xe cho chuyến
- `TripIncidents`: Sự cố trong chuyến

#### 5. **Financial Management**
- `Invoices`: Hóa đơn
- `AccountsReceivable`: Công nợ
- `HireTypes`: Loại thuê xe

#### 6. **System**
- `SystemSetting`: Cài đặt hệ thống (Key-Value)
- `Notifications`: Thông báo
- `Token`: Lưu JWT tokens

### Relationships:
- `Users` → `Roles` (Many-to-One)
- `Drivers` → `Employees` (One-to-One)
- `Drivers` → `Branches` (Many-to-One)
- `Bookings` → `Customers`, `Branches`, `Employees` (Many-to-One)
- `Trips` → `Bookings` (Many-to-One)
- `Vehicles` → `Branches`, `VehicleCategoryPricing` (Many-to-One)

---

## 🎨 API ARCHITECTURE

### Controllers (8 controllers):

1. **AuthController** (`/api/auth`)
   - `POST /login`: Đăng nhập
   - `POST /refresh-token`: Làm mới token
   - `POST /logout`: Đăng xuất
   - `GET /verify`: Xác thực email

2. **UserController** (`/api/admin/users`)
   - CRUD operations cho users

3. **BranchController** (`/api/admin/branches`)
   - Quản lý chi nhánh

4. **DriverController** (`/api/driver`)
   - Dashboard, profile, schedule, leave requests, trips

5. **EmployeeController** (`/api/employees`)
   - Quản lý nhân viên

6. **RoleController** (`/api/admin/roles`)
   - Quản lý vai trò

7. **SystemSettingController** (`/api/admin/settings`)
   - Quản lý cài đặt hệ thống

8. **PasswordController** (`/set-password`)
   - Đặt lại mật khẩu

### API Design Patterns:
- **RESTful**: Sử dụng HTTP methods (GET, POST, PUT, DELETE)
- **DTO Pattern**: Tách biệt Entity và API response
- **Service Layer**: Business logic trong service layer
- **Repository Pattern**: Data access abstraction

---

## 📧 EMAIL SERVICE

### Configuration:
- **SMTP Server**: Gmail (smtp.gmail.com:587)
- **Username**: trongho.373664@gmail.com
- **Authentication**: OAuth2 App Password

### Email Templates (Thymeleaf):
- `verify-email.html`: Xác thực email
- `verify-result.html`: Kết quả xác thực
- `set-password.html`: Đặt mật khẩu
- `password-success.html`: Thành công đặt mật khẩu

---

## 🔧 CONFIGURATION

### Application Properties:

#### Database:
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ptcmss_db
    username: root
    password: 123456
  jpa:
    hibernate:
      ddl-auto: update  # Tự động tạo/cập nhật schema
    show-sql: true      # Hiển thị SQL queries
```

#### JWT:
```yaml
jwt:
  expriMinutes: 3600    # Access token: 60 giờ
  expireDate: 5         # Refresh token: 5 ngày
  accesskey: <secret>
  refreshkey: <secret>
```

#### Swagger:
- **Path**: `/swagger-ui.html`
- **API Docs**: `/v3/api-docs`
- **Title**: Transport Application
- **Version**: 1.0.0

---

## 🚀 DEPLOYMENT

### Docker Support:
- **Dockerfile**: Multi-stage build
  - Stage 1: Maven build (Java 21)
  - Stage 2: Runtime (JRE 21)
- **Port**: 8080 exposed

### Build Commands:
```bash
# Build
mvn clean package

# Run
java -jar target/ptcmss-backend-0.0.1-SNAPSHOT.jar

# Docker
docker build -t ptcmss-backend .
docker run -p 8080:8080 ptcmss-backend
```

---

## 📋 MODULES & FEATURES

Dựa trên file `requirements.md`, hệ thống có **8 modules**:

### Module 1: System Administration
- Quản lý thiết lập hệ thống
- Quản lý chi nhánh
- Quản lý người dùng & phân quyền
- Quản lý vai trò
- Xác thực & hồ sơ cá nhân

### Module 2: Driver Management (Web)
- Dashboard & thông báo
- Hồ sơ & lịch trình
- Quản lý nghỉ phép
- Quản lý chuyến đi & chi phí

### Module 3: Vehicle Management
- Quản lý danh mục xe
- Quản lý phương tiện

### Module 4: Booking Management
- Dashboard tư vấn viên
- Quản lý đơn hàng (CRUD)

### Module 5: Dispatch Management
- Dashboard điều phối
- Gán tài xế/xe cho chuyến
- Phê duyệt & chi phí chung

### Module 6: Accounting Management
- Dashboard kế toán
- Quản lý hóa đơn & công nợ
- Quản lý thanh toán
- Báo cáo tài chính

### Module 7: Reporting & Analytics
- Dashboard Admin/Manager
- Báo cáo hiệu suất

### Module 8: Driver Mobile App
- API cho ứng dụng mobile của tài xế

---

## ⚠️ VẤN ĐỀ & CẢI THIỆN

### 1. **Security Concerns**
- ⚠️ **Hardcoded credentials** trong `application.yml`:
  - Database password: `123456`
  - Email password: Exposed in config
  - JWT secrets: Hardcoded
  - **Khuyến nghị**: Sử dụng environment variables hoặc Spring Cloud Config

### 2. **Code Quality**
- ✅ Sử dụng Lombok (giảm boilerplate)
- ✅ Validation với Jakarta Validation
- ⚠️ **Duplicate dependencies** trong `pom.xml`:
  - `spring-boot-starter-validation` (2 lần)
  - `spring-security-core` (2 lần với version khác nhau)
  - **Khuyến nghị**: Loại bỏ duplicates

### 3. **Database**
- ⚠️ `ddl-auto: update` - Không nên dùng trong production
- **Khuyến nghị**: Sử dụng Flyway hoặc Liquibase cho migration

### 4. **Error Handling**
- ✅ Custom exceptions (`ForBiddenException`, `InvalidDataException`, `ResourceNotFoundException`)
- ⚠️ **Khuyến nghị**: Thêm Global Exception Handler (@ControllerAdvice)

### 5. **Testing**
- ⚠️ Chưa thấy test files (chỉ có 1 file test)
- **Khuyến nghị**: Thêm unit tests và integration tests

### 6. **Documentation**
- ✅ Swagger/OpenAPI đã được cấu hình
- ✅ Có file `requirements.md` chi tiết
- **Khuyến nghị**: Thêm JavaDoc cho các methods quan trọng

### 7. **Performance**
- ✅ Sử dụng JPA với lazy loading
- ⚠️ **Khuyến nghị**: 
  - Thêm pagination cho tất cả list endpoints
  - Cache cho dữ liệu ít thay đổi (SystemSettings, Roles)
  - Connection pooling configuration

---

## 📊 THỐNG KÊ DỰ ÁN

- **Total Java Files**: ~127 files
- **Entities**: 23
- **Controllers**: 8
- **Services**: 11+ (với implementations)
- **Repositories**: 11
- **Enums**: 17
- **DTOs**: 20+ (request + response)

---

## 🎯 KẾT LUẬN

### Điểm mạnh:
1. ✅ Kiến trúc rõ ràng, tuân thủ best practices
2. ✅ Security được implement đầy đủ (JWT, Spring Security)
3. ✅ API documentation với Swagger
4. ✅ Email service với templates
5. ✅ Docker support
6. ✅ Domain model phong phú, đáp ứng yêu cầu nghiệp vụ

### Cần cải thiện:
1. ⚠️ Security: Di chuyển sensitive data ra environment variables
2. ⚠️ Code quality: Loại bỏ duplicate dependencies
3. ⚠️ Testing: Thêm test coverage
4. ⚠️ Database: Migration strategy cho production
5. ⚠️ Error handling: Global exception handler

### Đánh giá tổng thể:
**8/10** - Dự án có nền tảng tốt, cần hoàn thiện một số phần để sẵn sàng production.

---

*Phân tích được tạo vào: $(date)*
*Phiên bản: 1.0*

