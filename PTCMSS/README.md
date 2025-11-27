# 🚗 PTCMSS - Passenger Transport Company Management System

Hệ thống quản lý công ty vận tải hành khách toàn diện.

## 📚 Mục lục

- [Tính năng](#-tính-năng)
- [Công nghệ](#-công-nghệ)
- [Cài đặt nhanh](#-cài-đặt-nhanh)
- [Hướng dẫn chi tiết](#-hướng-dẫn-chi-tiết)
- [API Documentation](#-api-documentation)

## ✨ Tính năng

### Module 1: Quản lý người dùng & phân quyền
- Quản lý users, roles, employees
- Xác thực email
- Phân quyền theo vai trò (Admin, Manager, Consultant, Driver, Accountant)

### Module 2: Quản lý tài xế
- Quản lý thông tin tài xế
- Đăng ký nghỉ phép
- Đánh giá tài xế
- Theo dõi giờ lái xe

### Module 3: Quản lý xe
- Quản lý phương tiện
- Danh mục loại xe & giá
- Theo dõi bảo dưỡng
- Cảnh báo hết hạn đăng kiểm/bảo hiểm

### Module 4: Quản lý booking & khách hàng
- Tạo và quản lý booking
- Quản lý khách hàng
- Tính toán chi phí tự động
- Nhiều loại hình thuê xe

### Module 5: Điều phối chuyến đi
- Gán tài xế & xe cho chuyến đi
- Timeline chuyến đi
- Tối ưu lịch trình
- Theo dõi trạng thái realtime

### Module 6: Quản lý tài chính
- Hóa đơn thu/chi
- Quản lý công nợ
- Báo cáo doanh thu
- Quản lý tiền cọc

## 🛠️ Công nghệ

### Backend
- **Java 21** + **Spring Boot 3.4**
- **MySQL 8.0**
- **Spring Security** + JWT
- **Spring Data JPA** + Hibernate
- **Maven**

### Frontend
- **React 18** + **Vite**
- **TailwindCSS**
- **Lucide Icons**
- **React Router**

### DevOps
- **Docker** + **Docker Compose**
- Multi-stage builds
- Health checks

## 🗄️ Database Schema

Hệ thống sử dụng **29 tables chính** được tổ chức theo modules:

### Module 1: User Management & Authentication
| Table | Mô tả |
|-------|-------|
| `users` | Thông tin người dùng (login, email, phone) |
| `roles` | Vai trò hệ thống (Admin, Manager, Consultant, Driver, Accountant) |
| `employees` | Nhân viên (liên kết user với branch và role) |

### Module 2: Driver Management
| Table | Mô tả |
|-------|-------|
| `drivers` | Thông tin tài xế (license, rating, status) |
| `driver_day_off` | Đăng ký nghỉ phép của tài xế |
| `driver_ratings` | Đánh giá tài xế từ khách hàng |

### Module 3: Vehicle Management
| Table | Mô tả |
|-------|-------|
| `vehicles` | Thông tin xe (biển số, model, capacity) |
| `vehicle_category_pricing` | Danh mục loại xe & bảng giá |

### Module 4: Booking & Customer Management
| Table | Mô tả |
|-------|-------|
| `customers` | Thông tin khách hàng |
| `bookings` | Đơn đặt xe |
| `booking_vehicle_details` | Chi tiết xe trong booking (quantity) |
| `hire_types` | Loại hình thuê (1 chiều, 2 chiều, nhiều ngày, định kỳ) |

### Module 5: Trip Dispatch & Coordination
| Table | Mô tả |
|-------|-------|
| `trips` | Chuyến đi (route, distance, duration, status) |
| `trip_drivers` | Gán tài xế cho chuyến đi |
| `trip_vehicles` | Gán xe cho chuyến đi |
| `trip_assignment_history` | Lịch sử gán/hủy gán |
| `trip_incidents` | Sự cố trong chuyến đi |

### Module 6: Financial Management
| Table | Mô tả |
|-------|-------|
| `invoices` | Hóa đơn thu/chi |
| `invoice_items` | Chi tiết dòng hóa đơn |
| `payment_history` | Lịch sử thanh toán |
| `debt_reminder_history` | Lịch sử nhắc nợ |
| `expense_requests` | Yêu cầu chi phí |

### System & Common
| Table | Mô tả |
|-------|-------|
| `branches` | Chi nhánh công ty |
| `notifications` | Thông báo cho users |
| `system_alerts` | Cảnh báo hệ thống (xe hết hạn, tài xế cần nghỉ) |
| `system_settings` | Cấu hình hệ thống (VAT, hotline, etc.) |
| `approval_history` | Lịch sử phê duyệt (nghỉ phép, chi phí, giảm giá) |

### Views (Optional)
| View | Mô tả |
|------|-------|
| `v_drivermonthlyperformance` | Hiệu suất tài xế theo tháng |
| `v_tripdistanceanalytics` | Phân tích khoảng cách chuyến đi |
| `v_popularroutes` | Tuyến đường phổ biến |

**Tổng cộng**: 29 tables + 3 views

### Quan hệ chính

```
users (1) ─── (1) employees ─── (1) drivers
                    │
                    └─── (N) branches
                    
bookings (1) ─── (N) trips ─── (N) trip_drivers ─── (1) drivers
                    │
                    └─── (N) trip_vehicles ─── (1) vehicles
                    
bookings (1) ─── (N) invoices ─── (N) invoice_items
```

### Auto-generated Tables

Khi chạy lần đầu, Hibernate sẽ tự động tạo tất cả tables từ Entity classes. Dữ liệu khởi tạo (roles, admin user, hire types, vehicle categories) được insert tự động từ file `data.sql`.

## 🚀 Cài đặt nhanh

### Yêu cầu
- Docker >= 20.10
- Docker Compose >= 2.0
- 4GB RAM khả dụng

### Chạy với Docker (Khuyến nghị)

```bash
# 1. Clone repository
git clone <repository-url>
cd PTCMSS

# 2. Tạo file cấu hình
cp .env.example .env

# 3. Khởi động tất cả services
docker-compose up -d

# 4. Kiểm tra logs
docker-compose logs -f
```

**Hoặc sử dụng Makefile:**

```bash
make init    # Tạo file .env
make up      # Start services
make logs    # Xem logs
make status  # Kiểm tra trạng thái
```

### Truy cập ứng dụng

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html

**Tài khoản mặc định:**
- Username: `admin`
- Password: `123456`

## 📖 Hướng dẫn chi tiết

### Chạy không dùng Docker

#### Backend

```bash
cd ptcmss-backend

# Cài đặt dependencies
mvn clean install

# Chạy ứng dụng
mvn spring-boot:run
```

#### Frontend

```bash
cd ../PTCMSS_FRONTEND

# Cài đặt dependencies
npm install

# Chạy dev server
npm run dev
```

#### Database

```bash
# Tạo database
mysql -u root -p
CREATE DATABASE ptcmss_db;

# Import schema (optional)
mysql -u root -p ptcmss_db < db_scripts/db-tamthoi.sql
```

### Cấu hình

#### Backend Configuration

File: `ptcmss-backend/src/main/resources/application.yml`

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ptcmss_db
    username: root
    password: your_password
  mail:
    username: your_email@gmail.com
    password: your_app_password
```

#### Frontend Configuration

File: `PTCMSS_FRONTEND/.env`

```env
VITE_API_BASE=http://localhost:8080
```

## 📚 API Documentation

Sau khi khởi động backend, truy cập:

- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **OpenAPI JSON**: http://localhost:8080/v3/api-docs

## 🐳 Docker Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild
docker-compose up -d --build

# Reset everything
docker-compose down -v
docker-compose up -d --build

# Access containers
docker exec -it ptcmss-backend sh
docker exec -it ptcmss-frontend sh
docker exec -it ptcmss-mysql mysql -uroot -proot ptcmss_db
```

## 📁 Cấu trúc dự án

```
PTCMSS/
├── ptcmss-backend/          # Spring Boot backend
│   ├── src/
│   ├── Dockerfile
│   └── pom.xml
├── PTCMSS_FRONTEND/         # React frontend
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── db_scripts/              # Database scripts
├── docker-compose.yml       # Docker orchestration
├── .env.example            # Environment template
├── Makefile                # Quick commands
├── DOCKER_SETUP.md         # Docker guide
└── DATABASE_SETUP.md       # Database guide
```

## 🔧 Troubleshooting

### Port đã được sử dụng

Thay đổi ports trong `.env`:

```env
MYSQL_PORT=3307
BACKEND_PORT=8081
FRONTEND_PORT=3000
```

### Backend không kết nối MySQL

```bash
# Kiểm tra MySQL
docker-compose logs mysql

# Restart backend
docker-compose restart backend
```

### Reset database

```bash
docker-compose down -v
docker-compose up -d
```

## 📝 Tài liệu bổ sung

- [Docker Setup Guide](DOCKER_SETUP.md) - Hướng dẫn chi tiết về Docker
- [Database Setup Guide](DATABASE_SETUP.md) - Hướng dẫn setup database
- [Database Schema](DATABASE_SCHEMA.md) - Chi tiết cấu trúc 29 tables

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

