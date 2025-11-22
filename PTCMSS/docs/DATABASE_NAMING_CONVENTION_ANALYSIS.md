# Phân Tích Naming Convention Database - PTCMSS Project

## 📊 Tình Trạng Hiện Tại

Dự án hiện tại có **sự không nhất quán** về naming convention cho database tables:

### 1. **snake_case (underscore_case)** - 5 tables
- ✅ `approval_history`
- ✅ `expense_requests`
- ✅ `system_alerts`
- ✅ `trip_assignment_history`
- ✅ `trip_incidents`

### 2. **lowercase (không có underscore)** - 1 table
- ⚠️ `users`

### 3. **CamelCase** - 2 tables
- ⚠️ `SystemSettings`
- ⚠️ `DriverRatings`

### 4. **Không có @Table annotation** - ~20+ tables
JPA tự động tạo tên từ class name (ví dụ: `Branches` → `Branches`, `Drivers` → `Drivers`)
- `Branches`
- `Drivers`
- `Vehicles`
- `Customers`
- `Bookings`
- `Trips`
- `Employees`
- `Roles`
- `Notifications`
- `Invoices`
- `AccountsReceivable`
- `HireTypes`
- `VehicleCategoryPricing`
- `TripDrivers`
- `TripVehicles`
- `BookingVehicleDetails`
- `DriverDayOff`
- và nhiều tables khác...

## 🎯 Khuyến Nghị

### **Chọn snake_case (underscore_case) làm chuẩn**

**Lý do:**
1. ✅ **Đã có sẵn**: 5 tables đã dùng snake_case
2. ✅ **Chuẩn SQL**: snake_case là convention phổ biến nhất trong SQL databases
3. ✅ **Dễ đọc**: `approval_history` dễ đọc hơn `approvalHistory` hoặc `ApprovalHistory`
4. ✅ **Case-insensitive**: MySQL mặc định case-insensitive, snake_case tránh nhầm lẫn
5. ✅ **Tương thích**: Hầu hết ORM frameworks (Hibernate, JPA) hỗ trợ tốt snake_case

### **Kế Hoạch Thực Hiện**

#### **Bước 1: Thêm @Table annotation cho tất cả entities**

Thêm `@Table(name = "table_name")` với snake_case cho tất cả entities chưa có:

```java
// ❌ TRƯỚC
@Entity
public class Branches {
    ...
}

// ✅ SAU
@Entity
@Table(name = "branches")
public class Branches {
    ...
}
```

#### **Bước 2: Chuẩn hóa các tables đã có @Table**

```java
// ❌ TRƯỚC
@Table(name = "users")  // lowercase, không có underscore

// ✅ SAU
@Table(name = "users")  // Giữ nguyên (đã đúng snake_case cho 1 từ)
```

```java
// ❌ TRƯỚC
@Table(name = "SystemSettings")  // CamelCase
@Table(name = "DriverRatings")   // CamelCase

// ✅ SAU
@Table(name = "system_settings")  // snake_case
@Table(name = "driver_ratings")   // snake_case
```

#### **Bước 3: Migration Script**

Tạo migration script để đổi tên tables trong database:

```sql
-- Đổi tên tables từ CamelCase sang snake_case
RENAME TABLE `SystemSettings` TO `system_settings`;
RENAME TABLE `DriverRatings` TO `driver_ratings`;

-- Đổi tên các tables không có @Table (từ class name)
RENAME TABLE `Branches` TO `branches`;
RENAME TABLE `Drivers` TO `drivers`;
RENAME TABLE `Vehicles` TO `vehicles`;
RENAME TABLE `Customers` TO `customers`;
RENAME TABLE `Bookings` TO `bookings`;
RENAME TABLE `Trips` TO `trips`;
RENAME TABLE `Employees` TO `employees`;
RENAME TABLE `Roles` TO `roles`;
RENAME TABLE `Notifications` TO `notifications`;
RENAME TABLE `Invoices` TO `invoices`;
-- ... và các tables khác
```

## 📝 Danh Sách Tables Cần Sửa

### **Tables cần thêm @Table annotation:**

1. `Branches` → `@Table(name = "branches")`
2. `Drivers` → `@Table(name = "drivers")`
3. `Vehicles` → `@Table(name = "vehicles")`
4. `Customers` → `@Table(name = "customers")`
5. `Bookings` → `@Table(name = "bookings")`
6. `Trips` → `@Table(name = "trips")`
7. `Employees` → `@Table(name = "employees")`
8. `Roles` → `@Table(name = "roles")`
9. `Notifications` → `@Table(name = "notifications")`
10. `Invoices` → `@Table(name = "invoices")`
11. `AccountsReceivable` → `@Table(name = "accounts_receivable")`
12. `HireTypes` → `@Table(name = "hire_types")`
13. `VehicleCategoryPricing` → `@Table(name = "vehicle_category_pricing")`
14. `TripDrivers` → `@Table(name = "trip_drivers")`
15. `TripVehicles` → `@Table(name = "trip_vehicles")`
16. `BookingVehicleDetails` → `@Table(name = "booking_vehicle_details")`
17. `DriverDayOff` → `@Table(name = "driver_day_off")`
18. `TripIncidents` → `@Table(name = "trip_incidents")` (đã có, cần kiểm tra)
19. Và các tables khác...

### **Tables cần sửa @Table name:**

1. `SystemSettings` → `system_settings`
2. `DriverRatings` → `driver_ratings`

### **Tables đã đúng (giữ nguyên):**

1. ✅ `users` (lowercase, 1 từ nên không cần underscore)
2. ✅ `approval_history`
3. ✅ `expense_requests`
4. ✅ `system_alerts`
5. ✅ `trip_assignment_history`
6. ✅ `trip_incidents`

## ⚠️ Lưu Ý Quan Trọng

### **1. Backup Database trước khi migration**
```sql
-- Backup toàn bộ database
mysqldump -u root -p ptcmss_db > ptcmss_db_backup_$(date +%Y%m%d_%H%M%S).sql
```

### **2. Update Native Queries**
Tìm và cập nhật tất cả native SQL queries trong code:
```java
// ❌ TRƯỚC
@Query(value = "SELECT * FROM Branches WHERE ...", nativeQuery = true)

// ✅ SAU
@Query(value = "SELECT * FROM branches WHERE ...", nativeQuery = true)
```

### **3. Update Repository Methods**
Kiểm tra các repository methods có reference đến table names:
```java
// Tìm trong codebase
grep -r "FROM Branches" .
grep -r "FROM Drivers" .
grep -r "FROM SystemSettings" .
```

### **4. Test Thoroughly**
- ✅ Test tất cả API endpoints
- ✅ Test database queries
- ✅ Test foreign key constraints
- ✅ Test indexes

## 🚀 Thứ Tự Thực Hiện

1. **Phase 1**: Thêm `@Table` annotation cho tất cả entities (không đổi DB)
2. **Phase 2**: Tạo migration script và test trên dev environment
3. **Phase 3**: Update native queries trong code
4. **Phase 4**: Deploy migration script lên production
5. **Phase 5**: Verify và monitor

## 📚 Tài Liệu Tham Khảo

- [MySQL Naming Conventions](https://dev.mysql.com/doc/refman/8.0/en/identifier-names.html)
- [Hibernate Naming Strategy](https://docs.jboss.org/hibernate/orm/5.4/userguide/html_single/Hibernate_User_Guide.html#naming)
- [JPA @Table Annotation](https://docs.oracle.com/javaee/7/api/javax/persistence/Table.html)

---

**Ngày tạo**: 2025-11-22  
**Người phân tích**: AI Assistant  
**Trạng thái**: Đề xuất chờ phê duyệt

