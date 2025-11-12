# 🔐 PHÂN QUYỀN API - PTCMSS BACKEND

## 📋 TỔNG QUAN

Hệ thống sử dụng **Spring Security** với **JWT Authentication** và **Method-level Security** (`@PreAuthorize`) để phân quyền các API endpoints.

---

## 🔓 PUBLIC ENDPOINTS (Không cần authentication)

Các endpoint sau **KHÔNG CẦN** JWT token, ai cũng có thể truy cập:

| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/swagger-ui/**` | GET | Swagger UI documentation |
| `/v3/api-docs/**` | GET | OpenAPI JSON docs |
| `/api/auth/**` | POST | Login, refresh token, logout |
| `/verify` | GET | Xác thực email |
| `/set-password` | GET/POST | Đặt lại mật khẩu |

**Cấu hình trong**: `AppConfig.java` - `WHITELIST` array

---

## 🔐 AUTHENTICATION

### Cách xác thực:
1. **JWT Token** trong Header: `Authorization: Bearer <token>`
2. **Hoặc** Cookie: `access_token=<token>`

### Token Types:
- **Access Token**: Thời hạn 3600 phút (60 giờ)
- **Refresh Token**: Thời hạn 5 ngày

---

## 👥 ROLES TRONG HỆ THỐNG

| Role | Mô tả |
|------|-------|
| **ADMIN** | Quản trị viên hệ thống - Toàn quyền |
| **MANAGER** | Quản lý chi nhánh |
| **DRIVER** | Tài xế |
| **CONSULTANT** | Tư vấn viên / Điều hành |
| **ACCOUNTANT** | Kế toán |
| **COORDINATOR** | Điều phối viên |

---

## 📊 CHI TIẾT PHÂN QUYỀN THEO CONTROLLER

### 1. **AuthController** (`/api/auth`)

| Endpoint | Method | Phân quyền | Mô tả |
|----------|--------|------------|-------|
| `/api/auth/login` | POST | **PUBLIC** | Đăng nhập |
| `/api/auth/refresh-token` | POST | **PUBLIC** | Làm mới token |
| `/api/auth/logout` | POST | **PUBLIC** | Đăng xuất |

---

### 2. **UserController** (`/api/users`)

| Endpoint | Method | Phân quyền | Mô tả |
|----------|--------|------------|-------|
| `/api/users/register` | POST | **ADMIN** | Tạo người dùng mới |
| `/api/users` | GET | **ADMIN** | Danh sách người dùng |
| `/api/users/{id}` | GET | **ADMIN** hoặc **chính user đó** | Chi tiết người dùng |
| `/api/users/{id}` | PUT | **ADMIN** hoặc **chính user đó** | Cập nhật người dùng |
| `/api/users/{id}/toggle-status` | PATCH | **ADMIN** | Kích hoạt/Vô hiệu hóa |
| `/api/users/{id}/avatar` | POST | **ADMIN** hoặc **chính user đó** | Upload avatar |

**Annotation**: `@PreAuthorize("hasRole('ADMIN')")` hoặc `@PreAuthorize("hasRole('ADMIN') or #id == authentication.principal.id")`

---

### 3. **RoleController** (`/api/roles`)

| Endpoint | Method | Phân quyền | Mô tả |
|----------|--------|------------|-------|
| `/api/roles` | GET | **ADMIN** | Danh sách vai trò |
| `/api/roles` | POST | **ADMIN** | Tạo vai trò mới |
| `/api/roles/{id}` | GET | **ADMIN** | Chi tiết vai trò |
| `/api/roles/{id}` | PUT | **ADMIN** | Cập nhật vai trò |
| `/api/roles/{id}` | DELETE | **ADMIN** | Vô hiệu hóa vai trò |

**Annotation**: `@PreAuthorize("hasRole('ADMIN')")`

---

### 4. **BranchController** (`/api/branches`)

| Endpoint | Method | Phân quyền | Mô tả |
|----------|--------|------------|-------|
| `/api/branches` | GET | **ADMIN, MANAGER, ACCOUNTANT** | Danh sách chi nhánh |
| `/api/branches` | POST | **ADMIN** | Tạo chi nhánh mới |
| `/api/branches/{id}` | GET | **ADMIN, MANAGER, ACCOUNTANT** | Chi tiết chi nhánh |
| `/api/branches/{id}` | PUT | **ADMIN, MANAGER** | Cập nhật chi nhánh |
| `/api/branches/{id}` | DELETE | **ADMIN** | Vô hiệu hóa chi nhánh |

**Annotation**: 
- `@PreAuthorize("hasRole('ADMIN')")`
- `@PreAuthorize("hasAnyRole('ADMIN','MANAGER')")`
- `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

---

### 5. **EmployeeController** (`/api/employees`)

| Endpoint | Method | Phân quyền | Mô tả |
|----------|--------|------------|-------|
| `/api/employees` | GET | **ADMIN, MANAGER** | Danh sách nhân viên |
| `/api/employees/{id}` | GET | **ADMIN, MANAGER** | Chi tiết nhân viên |

**Annotation**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER')")`

---

### 6. **DriverController** (`/api/drivers`)

| Endpoint | Method | Phân quyền | Mô tả |
|----------|--------|------------|-------|
| `/api/drivers` | POST | **ADMIN, MANAGER** | Tạo tài xế mới |
| `/api/drivers/{driverId}/dashboard` | GET | **ADMIN, MANAGER, DRIVER** | Dashboard tài xế |
| `/api/drivers/{driverId}/schedule` | GET | **ADMIN, MANAGER, DRIVER** | Lịch làm việc |
| `/api/drivers/{driverId}/profile` | GET | **ADMIN, MANAGER, DRIVER** | Hồ sơ tài xế |
| `/api/drivers/by-user/{userId}/profile` | GET | **ADMIN, MANAGER, DRIVER** | Hồ sơ theo userId |
| `/api/drivers/{driverId}/profile` | PUT | **ADMIN, MANAGER, DRIVER** | Cập nhật hồ sơ |
| `/api/drivers/{driverId}/dayoff` | POST | **DRIVER** | Gửi yêu cầu nghỉ phép |
| `/api/drivers/{driverId}/trips/{tripId}/start` | POST | **DRIVER** | Bắt đầu chuyến đi |
| `/api/drivers/{driverId}/trips/{tripId}/complete` | POST | **DRIVER** | Hoàn thành chuyến đi |
| `/api/drivers/report-incident` | POST | **DRIVER** | Báo cáo sự cố |

**Annotation**: 
- `@PreAuthorize("hasRole('DRIVER')")`
- `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','DRIVER')")`
- `@PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")`

---

### 7. **VehicleController** (`/api/vehicles`) ⚠️

| Endpoint | Method | Phân quyền | Mô tả |
|----------|--------|------------|-------|
| `/api/vehicles` | GET | **AUTHENTICATED** | Danh sách phương tiện |
| `/api/vehicles` | POST | **AUTHENTICATED** | Tạo phương tiện |
| `/api/vehicles/{id}` | GET | **AUTHENTICATED** | Chi tiết phương tiện |
| `/api/vehicles/{id}` | PUT | **AUTHENTICATED** | Cập nhật phương tiện |
| `/api/vehicles/{id}` | DELETE | **AUTHENTICATED** | Xóa phương tiện |

**⚠️ LƯU Ý**: Controller này **CHƯA CÓ** `@PreAuthorize` annotation! Chỉ cần authentication (bất kỳ role nào đã đăng nhập).

**Khuyến nghị**: Nên thêm phân quyền:
- GET: `ADMIN, MANAGER, CONSULTANT, COORDINATOR`
- POST/PUT/DELETE: `ADMIN, MANAGER`

---

### 8. **VehicleCategoryController** (`/api/vehicle-categories`)

| Endpoint | Method | Phân quyền | Mô tả |
|----------|--------|------------|-------|
| `/api/vehicle-categories` | GET | **AUTHENTICATED** | Danh sách danh mục xe |
| `/api/vehicle-categories` | POST | **AUTHENTICATED** | Tạo danh mục xe |
| `/api/vehicle-categories/{id}` | GET | **AUTHENTICATED** | Chi tiết danh mục |
| `/api/vehicle-categories/{id}` | PUT | **AUTHENTICATED** | Cập nhật danh mục |
| `/api/vehicle-categories/{id}` | DELETE | **AUTHENTICATED** | Xóa danh mục |

**⚠️ LƯU Ý**: Controller này **CHƯA CÓ** `@PreAuthorize` annotation!

**Khuyến nghị**: Nên thêm phân quyền:
- GET: `ADMIN, MANAGER, CONSULTANT`
- POST/PUT/DELETE: `ADMIN, MANAGER`

---

### 9. **SystemSettingController** (`/api/system-settings`) ⚠️

| Endpoint | Method | Phân quyền | Mô tả |
|----------|--------|------------|-------|
| `/api/system-settings` | GET | **AUTHENTICATED** | Danh sách cài đặt |
| `/api/system-settings` | POST | **AUTHENTICATED** | Tạo cài đặt |
| `/api/system-settings/{id}` | GET | **AUTHENTICATED** | Chi tiết cài đặt |
| `/api/system-settings/{id}` | PUT | **AUTHENTICATED** | Cập nhật cài đặt |
| `/api/system-settings/{id}` | DELETE | **AUTHENTICATED** | Xóa cài đặt |

**⚠️ LƯU Ý**: Controller này **CHƯA CÓ** `@PreAuthorize` annotation!

**Khuyến nghị**: Nên thêm phân quyền:
- GET: `ADMIN, MANAGER`
- POST/PUT/DELETE: **ADMIN** only

---

## 🔍 CÁCH SỬ DỤNG TRONG SWAGGER

### Bước 1: Đăng nhập
1. Mở Swagger UI: http://localhost:8080/swagger-ui.html
2. Tìm endpoint `/api/auth/login`
3. Click **Try it out**
4. Nhập username/password (ví dụ: `admin` / password từ DB)
5. Click **Execute**
6. Copy `accessToken` từ response

### Bước 2: Authorize trong Swagger
1. Click nút **Authorize** 🔓 ở góc trên bên phải Swagger UI
2. Trong popup, nhập: `Bearer <accessToken>` (ví dụ: `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)
3. Click **Authorize**
4. Click **Close**

### Bước 3: Test các API có phân quyền
- Bây giờ bạn có thể test các API yêu cầu authentication
- Swagger sẽ tự động thêm header `Authorization: Bearer <token>` vào mọi request

---

## 📝 TÓM TẮT PHÂN QUYỀN THEO ROLE

### **ADMIN** (Toàn quyền)
- ✅ Tất cả các API
- ✅ Quản lý Users, Roles, Branches
- ✅ Quản lý System Settings
- ✅ Quản lý Vehicles, Vehicle Categories
- ✅ Xem tất cả thông tin

### **MANAGER** (Quản lý chi nhánh)
- ✅ Quản lý Branches (xem, sửa)
- ✅ Quản lý Employees (xem)
- ✅ Quản lý Drivers (xem, tạo)
- ✅ Xem Vehicles, Vehicle Categories
- ❌ Không thể quản lý Users, Roles
- ❌ Không thể quản lý System Settings

### **DRIVER** (Tài xế)
- ✅ Xem dashboard, lịch trình, hồ sơ của mình
- ✅ Gửi yêu cầu nghỉ phép
- ✅ Bắt đầu/Hoàn thành chuyến đi
- ✅ Báo cáo sự cố
- ❌ Không thể quản lý Users, Branches, Vehicles

### **CONSULTANT** (Tư vấn viên)
- ⚠️ Chưa có controller riêng
- Có thể cần quyền xem Bookings, Customers

### **ACCOUNTANT** (Kế toán)
- ✅ Xem danh sách Branches
- ⚠️ Có thể cần quyền quản lý Invoices, Accounts Receivable

### **COORDINATOR** (Điều phối)
- ⚠️ Chưa có controller riêng
- Có thể cần quyền quản lý Trips, gán Drivers/Vehicles

---

## ⚠️ VẤN ĐỀ & KHUYẾN NGHỊ

### 1. **Thiếu phân quyền**
Các controller sau **CHƯA CÓ** `@PreAuthorize`:
- ❌ `VehicleController` - Nên thêm phân quyền
- ❌ `VehicleCategoryController` - Nên thêm phân quyền
- ❌ `SystemSettingController` - Nên thêm phân quyền (chỉ ADMIN)

### 2. **Cải thiện**
- ✅ Thêm `@PreAuthorize` cho tất cả endpoints
- ✅ Tạo controller riêng cho CONSULTANT, ACCOUNTANT, COORDINATOR
- ✅ Thêm validation: Driver chỉ xem được thông tin của chính mình

### 3. **Best Practices**
- ✅ Sử dụng `hasRole()` cho single role
- ✅ Sử dụng `hasAnyRole()` cho multiple roles
- ✅ Sử dụng `#id == authentication.principal.id` cho self-access

---

## 🔗 TÀI LIỆU THAM KHẢO

- **Security Config**: `AppConfig.java`
- **JWT Filter**: `CustomizeRequestFilter.java`
- **Controllers**: `src/main/java/.../controller/`

---

*Tài liệu được tạo: 2025-11-11*
*Phiên bản: 1.0*

