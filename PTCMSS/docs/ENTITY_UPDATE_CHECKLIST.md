# Checklist: Update @Table Annotation cho Tất Cả Entities

## ✅ Migration Database: HOÀN THÀNH
- [x] Chạy migration script SQL
- [x] Verify migration thành công
- [x] Tất cả tables đã đổi sang snake_case

## 📝 Bước Tiếp Theo: Update Entities Java

### **Entities Cần Thêm @Table (chưa có):**

1. [ ] `AccountsReceivable.java`
   ```java
   @Entity
   @Table(name = "accounts_receivable")  // ← THÊM DÒNG NÀY
   public class AccountsReceivable {
   ```

2. [ ] `BookingVehicleDetails.java`
   ```java
   @Entity
   @Table(name = "booking_vehicle_details")
   public class BookingVehicleDetails {
   ```

3. [ ] `DriverDayOff.java`
   ```java
   @Entity
   @Table(name = "driver_day_off")
   public class DriverDayOff {
   ```

4. [ ] `HireTypes.java`
   ```java
   @Entity
   @Table(name = "hire_types")
   public class HireTypes {
   ```

5. [ ] `TripDrivers.java`
   ```java
   @Entity
   @Table(name = "trip_drivers")
   public class TripDrivers {
   ```

6. [ ] `TripRouteCache.java`
   ```java
   @Entity
   @Table(name = "trip_route_cache")
   public class TripRouteCache {
   ```

7. [ ] `TripVehicles.java`
   ```java
   @Entity
   @Table(name = "trip_vehicles")
   public class TripVehicles {
   ```

8. [ ] `VehicleCategoryPricing.java`
   ```java
   @Entity
   @Table(name = "vehicle_category_pricing")
   public class VehicleCategoryPricing {
   ```

9. [ ] `Branches.java`
   ```java
   @Entity
   @Table(name = "branches")
   public class Branches {
   ```

10. [ ] `Drivers.java`
    ```java
    @Entity
    @Table(name = "drivers")
    public class Drivers {
    ```

11. [ ] `Vehicles.java`
    ```java
    @Entity
    @Table(name = "vehicles")
    public class Vehicles {
    ```

12. [ ] `Customers.java`
    ```java
    @Entity
    @Table(name = "customers")
    public class Customers {
    ```

13. [ ] `Bookings.java`
    ```java
    @Entity
    @Table(name = "bookings")
    public class Bookings {
    ```

14. [ ] `Trips.java`
    ```java
    @Entity
    @Table(name = "trips")
    public class Trips {
    ```

15. [ ] `Employees.java`
    ```java
    @Entity
    @Table(name = "employees")
    public class Employees {
    ```

16. [ ] `Roles.java`
    ```java
    @Entity
    @Table(name = "roles")
    public class Roles {
    ```

17. [ ] `Notifications.java`
    ```java
    @Entity
    @Table(name = "notifications")
    public class Notifications {
    ```

18. [ ] `Invoices.java`
    ```java
    @Entity
    @Table(name = "invoices")
    public class Invoices {
    ```

### **Entities Cần Sửa @Table (đã có nhưng sai tên):**

1. [ ] `SystemSetting.java`
   ```java
   // ❌ TRƯỚC
   @Table(name = "SystemSettings")
   
   // ✅ SAU
   @Table(name = "system_settings")
   ```

2. [ ] `DriverRatings.java` (nếu có trong DB)
   ```java
   // ❌ TRƯỚC
   @Table(name = "DriverRatings")
   
   // ✅ SAU
   @Table(name = "driver_ratings")
   ```

### **Entities Đã Đúng (giữ nguyên):**

- ✅ `Users.java` → `@Table(name = "users")` (đã đúng)
- ✅ `ApprovalHistory.java` → `@Table(name = "approval_history")` (đã đúng)
- ✅ `ExpenseRequests.java` → `@Table(name = "expense_requests")` (đã đúng)
- ✅ `SystemAlerts.java` → `@Table(name = "system_alerts")` (đã đúng)
- ✅ `TripAssignmentHistory.java` → `@Table(name = "trip_assignment_history")` (đã đúng)
- ✅ `TripIncidents.java` → `@Table(name = "trip_incidents")` (đã đúng)

## 🔍 Bước Tiếp Theo Sau Khi Update Entities

1. [ ] **Tìm và sửa Native Queries**
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

2. [ ] **Test Backend**
   - Start Spring Boot application
   - Kiểm tra không có lỗi khi khởi động
   - Test một vài API endpoints

3. [ ] **Test Frontend**
   - Test các chức năng chính
   - Kiểm tra không có lỗi API

## 📚 Mapping Table Names

| Entity Class | @Table Name (snake_case) |
|-------------|-------------------------|
| AccountsReceivable | `accounts_receivable` |
| BookingVehicleDetails | `booking_vehicle_details` |
| Branches | `branches` |
| Bookings | `bookings` |
| Customers | `customers` |
| DriverDayOff | `driver_day_off` |
| Drivers | `drivers` |
| Employees | `employees` |
| HireTypes | `hire_types` |
| Invoices | `invoices` |
| Notifications | `notifications` |
| Roles | `roles` |
| SystemSetting | `system_settings` |
| Trips | `trips` |
| TripDrivers | `trip_drivers` |
| TripRouteCache | `trip_route_cache` |
| TripVehicles | `trip_vehicles` |
| Users | `users` |
| VehicleCategoryPricing | `vehicle_category_pricing` |
| Vehicles | `vehicles` |

---

**Ngày tạo**: 2025-11-22  
**Trạng thái**: Ready to execute

