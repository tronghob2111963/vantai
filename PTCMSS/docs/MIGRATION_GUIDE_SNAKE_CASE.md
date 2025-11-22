# Hướng Dẫn Migration Sang Snake_Case

## ⚠️ QUAN TRỌNG: Hibernate KHÔNG tự động đổi tên tables

### ❌ SAI: Nghĩ rằng `ddl-auto: update` sẽ đổi tên tables

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: update  # ❌ KHÔNG đổi tên tables đã tồn tại!
```

**`ddl-auto: update` CHỈ:**
- ✅ Tạo tables mới nếu chưa có
- ✅ Thêm columns mới nếu chưa có trong table
- ✅ Cập nhật column types
- ❌ **KHÔNG đổi tên tables đã tồn tại**
- ❌ **KHÔNG đổi tên columns đã tồn tại**
- ❌ **KHÔNG xóa columns**

### ✅ ĐÚNG: Cần migration script thủ công

## 📋 Kế Hoạch Migration

### **Bước 1: Backup Database** ⚠️ QUAN TRỌNG NHẤT

```bash
# Backup toàn bộ database
mysqldump -u root -p ptcmss_db > ptcmss_db_backup_$(date +%Y%m%d_%H%M%S).sql

# Hoặc backup chỉ schema
mysqldump -u root -p --no-data ptcmss_db > ptcmss_db_schema_backup.sql

# Backup chỉ data
mysqldump -u root -p --no-create-info ptcmss_db > ptcmss_db_data_backup.sql
```

### **Bước 2: Chạy Migration Script**

```bash
# Chạy script đổi tên tables
mysql -u root -p ptcmss_db < db_scripts/01_MIGRATE_TO_SNAKE_CASE.sql
```

Script này sẽ đổi tên:
- `accountsreceivable` → `accounts_receivable`
- `bookingvehicledetails` → `booking_vehicle_details`
- `driverdayoff` → `driver_day_off`
- `hiretypes` → `hire_types`
- `systemsettings` → `system_settings`
- `tripdrivers` → `trip_drivers`
- `triproutecache` → `trip_route_cache`
- `tripvehicles` → `trip_vehicles`
- `vehiclecategorypricing` → `vehicle_category_pricing`

### **Bước 3: Update Entities Java**

Thêm `@Table(name = "table_name")` với snake_case cho TẤT CẢ entities:

```java
// ❌ TRƯỚC
@Entity
public class AccountsReceivable {
    ...
}

// ✅ SAU
@Entity
@Table(name = "accounts_receivable")
public class AccountsReceivable {
    ...
}
```

### **Bước 4: Update Native Queries**

Tìm và sửa tất cả native queries:

```java
// ❌ TRƯỚC
@Query(value = "SELECT * FROM accountsreceivable WHERE ...", nativeQuery = true)

// ✅ SAU
@Query(value = "SELECT * FROM accounts_receivable WHERE ...", nativeQuery = true)
```

### **Bước 5: Test**

1. ✅ Test tất cả API endpoints
2. ✅ Test database queries
3. ✅ Test foreign key constraints
4. ✅ Test views

## 🔍 Cách Tìm Native Queries Cần Sửa

```bash
# Tìm tất cả native queries
grep -r "nativeQuery = true" PTCMSS/ptcmss-backend/src/

# Tìm queries có table names cũ
grep -r "FROM accountsreceivable" PTCMSS/ptcmss-backend/src/
grep -r "FROM bookingvehicledetails" PTCMSS/ptcmss-backend/src/
grep -r "FROM driverdayoff" PTCMSS/ptcmss-backend/src/
grep -r "FROM hiretypes" PTCMSS/ptcmss-backend/src/
grep -r "FROM systemsettings" PTCMSS/ptcmss-backend/src/
grep -r "FROM tripdrivers" PTCMSS/ptcmss-backend/src/
grep -r "FROM triproutecache" PTCMSS/ptcmss-backend/src/
grep -r "FROM tripvehicles" PTCMSS/ptcmss-backend/src/
grep -r "FROM vehiclecategorypricing" PTCMSS/ptcmss-backend/src/
```

## 📝 Danh Sách Entities Cần Thêm @Table

### **Entities cần thêm @Table với snake_case:**

1. `AccountsReceivable` → `@Table(name = "accounts_receivable")`
2. `BookingVehicleDetails` → `@Table(name = "booking_vehicle_details")`
3. `DriverDayOff` → `@Table(name = "driver_day_off")`
4. `HireTypes` → `@Table(name = "hire_types")`
5. `SystemSetting` → `@Table(name = "system_settings")` (đã có nhưng sai tên)
6. `TripDrivers` → `@Table(name = "trip_drivers")`
7. `TripRouteCache` → `@Table(name = "trip_route_cache")`
8. `TripVehicles` → `@Table(name = "trip_vehicles")`
9. `VehicleCategoryPricing` → `@Table(name = "vehicle_category_pricing")`

### **Entities cần sửa @Table name:**

1. `SystemSetting` → từ `SystemSettings` → `system_settings`
2. `DriverRatings` → từ `DriverRatings` → `driver_ratings` (nếu có trong DB)

### **Entities đã đúng (giữ nguyên):**

1. `Bookings` → `@Table(name = "bookings")` (1 từ, không cần underscore)
2. `Branches` → `@Table(name = "branches")`
3. `Customers` → `@Table(name = "customers")`
4. `Drivers` → `@Table(name = "drivers")`
5. `Employees` → `@Table(name = "employees")`
6. `Invoices` → `@Table(name = "invoices")`
7. `Notifications` → `@Table(name = "notifications")`
8. `Roles` → `@Table(name = "roles")`
9. `Trips` → `@Table(name = "trips")`
10. `Users` → `@Table(name = "users")`
11. `Vehicles` → `@Table(name = "vehicles")`

### **Entities đã có @Table đúng:**

1. ✅ `ApprovalHistory` → `@Table(name = "approval_history")`
2. ✅ `ExpenseRequests` → `@Table(name = "expense_requests")`
3. ✅ `SystemAlerts` → `@Table(name = "system_alerts")`
4. ✅ `TripAssignmentHistory` → `@Table(name = "trip_assignment_history")`
5. ✅ `TripIncidents` → `@Table(name = "trip_incidents")`

## 🚀 Thứ Tự Thực Hiện

1. **Backup database** (QUAN TRỌNG!)
2. **Chạy migration script** (`01_MIGRATE_TO_SNAKE_CASE.sql`)
3. **Update entities** - Thêm/sửa `@Table` annotation
4. **Update native queries** - Tìm và sửa tất cả
5. **Test** - Test kỹ tất cả chức năng
6. **Deploy** - Chỉ deploy khi đã test OK

## ⚠️ Lưu Ý

- **KHÔNG** set `ddl-auto: create` vì sẽ xóa toàn bộ data
- **KHÔNG** set `ddl-auto: create-drop` vì sẽ xóa data khi shutdown
- **NÊN** giữ `ddl-auto: update` hoặc `none` sau khi migration xong
- **NÊN** dùng Flyway hoặc Liquibase cho production (sau này)

## 📚 Tài Liệu Tham Khảo

- [Hibernate DDL Auto](https://docs.jboss.org/hibernate/orm/5.4/userguide/html_single/Hibernate_User_Guide.html#configurations-hbmddl)
- [MySQL RENAME TABLE](https://dev.mysql.com/doc/refman/8.0/en/rename-table.html)

---

**Ngày tạo**: 2025-11-22  
**Trạng thái**: Ready to execute

