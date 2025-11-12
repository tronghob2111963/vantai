# 📊 PHÂN TÍCH DỰ ÁN PTCMSS - BÁO CÁO CHI TIẾT

## 🎯 TỔNG QUAN DỰ ÁN

**PTCMSS (Passenger Transport Company Management System)** là hệ thống quản lý vận tải hành khách toàn diện, được xây dựng với kiến trúc **Full-Stack** hiện đại.

### Thông tin cơ bản:
- **Tên dự án**: PTCMSS - Passenger Transport Company Management System
- **Loại**: Enterprise Management System
- **Kiến trúc**: Full-Stack (Backend + Frontend)
- **Trạng thái**: Đang phát triển (Development)

---

## 🏗️ KIẾN TRÚC TỔNG THỂ

### 1. **Stack Công nghệ**

#### Backend:
- **Framework**: Spring Boot 3.3.8
- **Java Version**: 21
- **Build Tool**: Maven
- **Database**: MySQL 8.0.43
- **ORM**: Spring Data JPA / Hibernate
- **Security**: Spring Security + JWT
- **API Documentation**: Swagger/OpenAPI 3.0 (springdoc-openapi 2.6.0)
- **Email**: Spring Mail (Gmail SMTP)
- **Template Engine**: Thymeleaf (cho email)

#### Frontend:
- **Framework**: React 19.1.1
- **Build Tool**: Vite 7.1.7
- **Routing**: React Router DOM 7.9.4
- **Styling**: Tailwind CSS 4.1.16
- **Icons**: Lucide React 0.546.0
- **Charts**: Recharts 3.3.0

#### Infrastructure:
- **Containerization**: Docker & Docker Compose
- **Database**: MySQL 8.0 (Docker)
- **Ports**:
  - Backend: 8080
  - Frontend: 5173
  - MySQL: 3307 (host) / 3306 (container)

---

## 📁 CẤU TRÚC DỰ ÁN

```
vantai/
├── PTCMSS/                          # Backend & Docker configs
│   ├── ptcmss-backend/              # Spring Boot Backend
│   │   ├── src/main/java/org/example/ptcmssbackend/
│   │   │   ├── common/              # Common utilities
│   │   │   ├── config/              # Configuration classes
│   │   │   ├── controller/          # REST Controllers (11 controllers)
│   │   │   ├── dto/                 # Data Transfer Objects
│   │   │   │   ├── request/         # Request DTOs
│   │   │   │   └── response/        # Response DTOs
│   │   │   ├── entity/              # JPA Entities (23 entities)
│   │   │   ├── enums/               # Enumerations (17 enums)
│   │   │   ├── exception/           # Custom Exceptions
│   │   │   ├── mapper/              # Entity-DTO Mappers
│   │   │   ├── repository/          # JPA Repositories (11 repositories)
│   │   │   └── service/             # Business Logic Services
│   │   │       └── impl/            # Service Implementations
│   │   ├── src/main/resources/
│   │   │   ├── application.yml      # Main configuration
│   │   │   ├── application-dev.yml  # Dev environment
│   │   │   ├── application-prod.yml # Prod environment
│   │   │   └── templates/           # Email templates (Thymeleaf)
│   │   ├── pom.xml                  # Maven dependencies
│   │   └── Dockerfile               # Docker build config
│   ├── docker-compose.yml           # Docker Compose config
│   └── docs/                        # Documentation
│
└── PTCMSS_FRONTEND/                 # React Frontend
    ├── src/
    │   ├── api/                     # API client functions
    │   ├── components/              # React components
    │   │   ├── module 1/            # System Administration
    │   │   ├── module 2/            # Driver Management
    │   │   ├── module 3/            # Vehicle Management
    │   │   ├── module 4/            # Booking Management
    │   │   ├── module 5/            # Dispatch Management
    │   │   ├── module 6/            # Accounting Management
    │   │   └── module 7/            # Reporting & Analytics
    │   ├── utils/                   # Utility functions
    │   ├── AppLayout.jsx            # Main layout & routing
    │   └── main.jsx                 # Entry point
    ├── package.json                 # NPM dependencies
    └── vite.config.js               # Vite configuration
```

---

## 🔐 BẢO MẬT & XÁC THỰC

### 1. **Spring Security Configuration**

**Authentication Strategy**: JWT (JSON Web Token) - Stateless

**Components**:
- `AppConfig`: Security filter chain configuration
- `CustomizeRequestFilter`: JWT token extraction & validation
- `CustomUserDetailsService`: User authentication service
- `JwtService`: JWT token generation & validation

**Token Types**:
- `ACCESS_TOKEN`: Short-lived (3600 minutes = 60 hours)
- `REFRESH_TOKEN`: Long-lived (5 days)
- `EMAIL_VERIFY_TOKEN`: Email verification
- `PASSWORD_RESET_TOKEN`: Password reset

**Security Features**:
- ✅ BCrypt password encoding
- ✅ Stateless session management
- ✅ CORS configuration (localhost:5173, localhost:8080)
- ✅ Role-based authorization (`@PreAuthorize`)
- ✅ JWT token in Header (`Authorization: Bearer <token>`) or Cookie (`access_token`)

**Public Endpoints** (không cần authentication):
- `/swagger-ui/**`
- `/v3/api-docs/**`
- `/api/auth/**` (login, register, refresh)
- `/verify` (email verification)
- `/set-password` (password reset)

---

## 🗄️ DATABASE MODEL

### Core Entities (23 entities):

#### 1. **User Management**
- `Users`: Người dùng hệ thống (email, password, status)
- `Roles`: Vai trò (ADMIN, MANAGER, DRIVER, CONSULTANT, ACCOUNTANT, COORDINATOR)
- `Employees`: Thông tin nhân viên (liên kết với Users)
- `Branches`: Chi nhánh công ty

#### 2. **Driver Management**
- `Drivers`: Tài xế (One-to-One với Employees)
- `DriverDayOff`: Đơn nghỉ phép của tài xế
- `TripDrivers`: Gán tài xế cho chuyến đi

#### 3. **Vehicle Management**
- `Vehicles`: Phương tiện (licensePlate, brand, model, status)
- `VehicleCategoryPricing`: Danh mục và giá xe
- `TripVehicles`: Gán xe cho chuyến đi

#### 4. **Booking & Trip Management**
- `Customers`: Khách hàng
- `Bookings`: Đơn đặt chuyến
- `BookingVehicleDetails`: Chi tiết xe trong đơn
- `Trips`: Chuyến đi thực tế
- `TripIncidents`: Sự cố trong chuyến

#### 5. **Financial Management**
- `Invoices`: Hóa đơn
- `AccountsReceivable`: Công nợ
- `HireTypes`: Loại thuê xe

#### 6. **System**
- `SystemSetting`: Cài đặt hệ thống (Key-Value store)
- `Notifications`: Thông báo
- `Token`: Lưu JWT tokens (refresh tokens)

### Relationships chính:
- `Users` → `Roles` (Many-to-One)
- `Drivers` → `Employees` (One-to-One)
- `Drivers` → `Branches` (Many-to-One)
- `Vehicles` → `Branches`, `VehicleCategoryPricing` (Many-to-One)
- `Bookings` → `Customers`, `Branches`, `Employees` (Many-to-One)
- `Trips` → `Bookings` (Many-to-One)

---

## 🎨 API ARCHITECTURE

### Controllers (11 controllers):

#### 1. **AuthController** (`/api/auth`)
- `POST /login`: Đăng nhập (trả về access_token + refresh_token)
- `POST /refresh-token`: Làm mới access token
- `POST /logout`: Đăng xuất (revoke token)

#### 2. **UserController** (`/api/admin/users`)
- CRUD operations cho users
- Quản lý phân quyền

#### 3. **BranchController** (`/api/admin/branches`)
- Quản lý chi nhánh (CRUD)
- Lọc theo status, keyword

#### 4. **DriverController** (`/api/driver`)
- Dashboard tài xế
- Profile management
- Schedule viewing
- Leave requests
- Trip management
- Incident reporting

#### 5. **EmployeeController** (`/api/employees`)
- Quản lý nhân viên

#### 6. **RoleController** (`/api/admin/roles`)
- Quản lý vai trò hệ thống

#### 7. **SystemSettingController** (`/api/admin/settings`)
- Quản lý cài đặt hệ thống (Key-Value)

#### 8. **VehicleController** (`/api/vehicles`) ⭐ **MỚI (nhánh md3)**
- CRUD phương tiện
- Tìm kiếm theo biển số
- Lọc theo category, branch, status

#### 9. **VehicleCategoryController** (`/api/vehicle-categories`) ⭐ **MỚI (nhánh md3)**
- Quản lý danh mục xe và giá

#### 10. **VerificationController** (`/verify`)
- Xác thực email (render HTML)

#### 11. **PasswordController** (`/set-password`)
- Đặt lại mật khẩu (render HTML)

### API Design Patterns:
- ✅ **RESTful**: Sử dụng HTTP methods chuẩn
- ✅ **DTO Pattern**: Tách biệt Entity và API response
- ✅ **Service Layer**: Business logic trong service layer
- ✅ **Repository Pattern**: Data access abstraction
- ✅ **Response Wrapper**: `ApiResponse<T>` cho tất cả responses

---

## 📦 DEPENDENCIES CHÍNH

### Backend Dependencies:

#### Core Spring:
- `spring-boot-starter-web`: REST API
- `spring-boot-starter-data-jpa`: Database access
- `spring-boot-starter-security`: Security framework
- `spring-boot-starter-validation`: Input validation
- `spring-boot-starter-mail`: Email service
- `spring-boot-starter-thymeleaf`: Email templates
- `spring-boot-starter-actuator`: Health monitoring

#### Database:
- `mysql-connector-j`: MySQL driver

#### Security & Authentication:
- `jjwt-api`, `jjwt-impl`, `jjwt-jackson` (0.11.5): JWT handling

#### Documentation:
- `springdoc-openapi-starter-webmvc-ui` (2.6.0): Swagger UI

#### Utilities:
- `lombok`: Code generation (getters, setters, builders)
- `spring-boot-configuration-processor`: Configuration metadata

### Frontend Dependencies:

#### Core:
- `react` (19.1.1): UI library
- `react-dom` (19.1.1): React DOM renderer
- `react-router-dom` (7.9.4): Routing

#### UI & Styling:
- `tailwindcss` (4.1.16): Utility-first CSS
- `lucide-react` (0.546.0): Icon library

#### Data Visualization:
- `recharts` (3.3.0): Chart library

#### Build Tools:
- `vite` (7.1.7): Build tool & dev server
- `@vitejs/plugin-react`: React plugin for Vite

---

## 🎯 MODULES & FEATURES

Dự án được chia thành **7 modules chính** (theo frontend components):

### **Module 1: System Administration** (Quản trị hệ thống)
**Vai trò**: Admin

**Features**:
- Quản lý thiết lập hệ thống (System Settings)
- Quản lý chi nhánh (Branches)
- Quản lý người dùng & phân quyền (Users & Roles)
- Xác thực & hồ sơ cá nhân

**Components**:
- `SystemSettingsPage`
- `AdminBranchesPage`, `CreateBranchPage`, `AdminBranchDetailPage`
- `AdminUsersPage`, `AdminCreateUserPage`, `UserDetailPage`
- `AdminManagersPage`
- `LoginPage`, `UpdateProfilePage`

### **Module 2: Driver Management** (Quản lý tài xế)
**Vai trò**: Driver

**Features**:
- Dashboard tài xế
- Thông báo
- Hồ sơ cá nhân
- Lịch trình chuyến đi
- Quản lý nghỉ phép
- Báo cáo sự cố
- Chi tiết chuyến đi & chi phí

**Components**:
- `DriverDashboard`
- `DriverNotificationsPage`
- `DriverProfilePage`
- `DriverSchedulePage`
- `DriverLeaveRequestPage`
- `DriverReportIncidentPage`
- `DriverTripDetailPage`
- `TripExpenseModal`

### **Module 3: Vehicle Management** (Quản lý phương tiện) ⭐ **MỚI**
**Vai trò**: Admin, Manager

**Features**:
- Quản lý danh mục xe (Vehicle Categories)
- Quản lý phương tiện (CRUD)
- Tìm kiếm & lọc xe
- Chi tiết phương tiện

**Components**:
- `VehicleCategoryPage`, `VehicleCategoryManagePage`
- `VehicleListPage`, `VehicleCreatePage`, `VehicleDetailPage`

**Backend APIs** (mới trong nhánh md3):
- `VehicleController`: CRUD + search + filter
- `VehicleCategoryController`: Quản lý danh mục

### **Module 4: Booking Management** (Quản lý đơn hàng)
**Vai trò**: Consultant

**Features**:
- Dashboard tư vấn viên
- Tạo đơn hàng mới
- Danh sách đơn hàng
- Chi tiết & chỉnh sửa đơn hàng

**Components**:
- `ConsultantDashboardPage`
- `CreateOrderPage`
- `ConsultantOrderListPage`
- `OrderDetailPage`
- `EditOrderPage`

### **Module 5: Dispatch Management** (Điều phối)
**Vai trò**: Coordinator

**Features**:
- Dashboard điều phối
- Timeline chuyến đi
- Gán tài xế/xe cho chuyến
- Phê duyệt chi phí chung
- Thông báo

**Components**:
- `CoordinatorTimelinePro`
- `AssignDriverDialog`
- `ExpenseRequestForm`
- `NotificationsWidget`

### **Module 6: Accounting Management** (Kế toán)
**Vai trò**: Accountant

**Features**:
- Dashboard kế toán
- Quản lý hóa đơn
- Quản lý công nợ
- Báo cáo chi phí
- Báo cáo doanh thu

**Components**:
- `AccountantDashboard`
- `InvoiceManagement`
- `DepositModal`
- `ExpenseReportPage`
- `ReportRevenuePage`

### **Module 7: Reporting & Analytics** (Báo cáo)
**Vai trò**: Admin, Manager

**Features**:
- Dashboard Admin
- Dashboard Manager
- Báo cáo hiệu suất
- Phân tích dữ liệu

**Components**:
- `AdminDashboard`
- `ManagerDashboard`

---

## 📧 EMAIL SERVICE

### Configuration:
- **SMTP Server**: Gmail (smtp.gmail.com:587)
- **Authentication**: OAuth2 App Password
- **Template Engine**: Thymeleaf

### Email Templates:
1. `verify-email.html`: Email xác thực tài khoản
2. `verify-result.html`: Kết quả xác thực
3. `set-password.html`: Form đặt mật khẩu
4. `password-success.html`: Thành công đặt mật khẩu

### Email Service:
- `EmailService`: Service gửi email
- `VerificationService`: Xử lý xác thực email
- `PasswordService`: Xử lý reset password

---

## 🐳 DOCKER & DEPLOYMENT

### Docker Compose Services:

1. **MySQL**:
   - Image: `mysql:8.0.43-debian`
   - Port: `3307:3306`
   - Database: `ptcmss_db`
   - Volume: `mysql_data`

2. **Backend**:
   - Build: `./ptcmss-backend`
   - Port: `8080:8080`
   - Depends on: MySQL
   - Environment: Database connection, Spring profile

3. **Frontend**:
   - Build: `./ptcmss-frontend`
   - Port: `5173:80`
   - Depends on: Backend

### Docker Commands:
```bash
# Build và chạy tất cả services
docker-compose up --build

# Chạy ở background
docker-compose up -d --build

# Xem logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop và xóa data
docker-compose down -v
```

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

#### Profiles:
- `dev`: Development environment
- `prod`: Production environment

#### Swagger/OpenAPI:
- **Path**: `/swagger-ui.html`
- **API Docs**: `/v3/api-docs`
- **Title**: Transport Application
- **Version**: 1.0.0

---

## 📊 THỐNG KÊ DỰ ÁN

### Backend:
- **Total Java Files**: ~140 files
- **Entities**: 23
- **Controllers**: 11
- **Services**: 12+ (với implementations)
- **Repositories**: 11
- **Enums**: 17
- **DTOs**: 25+ (request + response)
- **Exceptions**: 3 custom exceptions

### Frontend:
- **Total Components**: 40+ React components
- **Modules**: 7 modules
- **API Clients**: 9 API client files
- **Routes**: 40+ routes

---

## ⚠️ VẤN ĐỀ & CẢI THIỆN

### 1. **Security Concerns** 🔴
- ⚠️ **Hardcoded credentials** trong `application.yml`:
  - Database password: `123456`
  - Email password: Exposed in config
  - JWT secrets: Hardcoded
  - **Khuyến nghị**: Sử dụng environment variables hoặc Spring Cloud Config

### 2. **Code Quality** 🟡
- ✅ Sử dụng Lombok (giảm boilerplate)
- ✅ Validation với Jakarta Validation
- ⚠️ **Duplicate dependencies** trong `pom.xml`:
  - `spring-boot-starter-validation` (2 lần)
  - `spring-security-core` (2 lần với version khác nhau)
  - **Khuyến nghị**: Loại bỏ duplicates

### 3. **Database** 🟡
- ⚠️ `ddl-auto: update` - Không nên dùng trong production
- **Khuyến nghị**: Sử dụng Flyway hoặc Liquibase cho migration

### 4. **Error Handling** 🟡
- ✅ Custom exceptions (`ForBiddenException`, `InvalidDataException`, `ResourceNotFoundException`)
- ⚠️ **Khuyến nghị**: Thêm Global Exception Handler (`@ControllerAdvice`)

### 5. **Testing** 🔴
- ⚠️ Chưa thấy test files (chỉ có 1 file test)
- **Khuyến nghị**: Thêm unit tests và integration tests

### 6. **Documentation** 🟢
- ✅ Swagger/OpenAPI đã được cấu hình
- ✅ Có file `requirements.md` chi tiết
- ✅ Có các file hướng dẫn (QUICK_START, HUONG_DAN_CHAY_DU_AN)
- **Khuyến nghị**: Thêm JavaDoc cho các methods quan trọng

### 7. **Performance** 🟡
- ✅ Sử dụng JPA với lazy loading
- ⚠️ **Khuyến nghị**: 
  - Thêm pagination cho tất cả list endpoints
  - Cache cho dữ liệu ít thay đổi (SystemSettings, Roles)
  - Connection pooling configuration

### 8. **Frontend** 🟡
- ⚠️ `main.jsx` có nhiều code bị comment (demo code)
- **Khuyến nghị**: Clean up và tổ chức lại code

---

## 🎯 ĐIỂM MẠNH

1. ✅ **Kiến trúc rõ ràng**: Tuân thủ best practices (Layered Architecture)
2. ✅ **Security**: JWT authentication, Spring Security, BCrypt
3. ✅ **API Documentation**: Swagger/OpenAPI đầy đủ
4. ✅ **Email Service**: Templates với Thymeleaf
5. ✅ **Docker Support**: Dễ deploy và test
6. ✅ **Domain Model**: Phong phú, đáp ứng yêu cầu nghiệp vụ
7. ✅ **Frontend**: Modern stack (React 19, Vite, Tailwind)
8. ✅ **Modular Design**: Code được tổ chức theo modules rõ ràng

---

## 🚀 KHUYẾN NGHỊ CẢI THIỆN

### Priority 1 (High):
1. 🔴 **Security**: Di chuyển sensitive data ra environment variables
2. 🔴 **Testing**: Thêm test coverage (unit + integration)
3. 🔴 **Database Migration**: Sử dụng Flyway/Liquibase

### Priority 2 (Medium):
4. 🟡 **Error Handling**: Global exception handler
5. 🟡 **Code Quality**: Loại bỏ duplicate dependencies
6. 🟡 **Performance**: Pagination, caching

### Priority 3 (Low):
7. 🟢 **Documentation**: JavaDoc cho methods
8. 🟢 **Frontend Cleanup**: Remove commented code

---

## 📈 ĐÁNH GIÁ TỔNG THỂ

### Điểm số: **8/10**

**Lý do**:
- ✅ Nền tảng tốt, kiến trúc rõ ràng
- ✅ Security được implement đầy đủ
- ✅ API documentation tốt
- ⚠️ Cần hoàn thiện testing và security best practices
- ⚠️ Cần cải thiện error handling và performance

**Kết luận**: Dự án có nền tảng vững chắc, sẵn sàng cho giai đoạn phát triển tiếp theo. Cần hoàn thiện một số phần để sẵn sàng production.

---

## 📝 GHI CHÚ

- **Nhánh hiện tại**: `md3` (có thêm Vehicle Management APIs)
- **Nhánh main**: Cơ bản hơn, chưa có Vehicle APIs
- **Documentation**: Có nhiều file hướng dẫn chi tiết trong thư mục `PTCMSS/`

---

*Phân tích được tạo vào: $(date)*
*Phiên bản: 1.0*
*Người phân tích: AI Assistant*

