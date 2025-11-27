# 🗄️ Database Schema Documentation

Chi tiết về cấu trúc database của hệ thống PTCMSS.

## Tổng quan

- **Database**: `ptcmss_db`
- **Engine**: MySQL 8.0
- **Charset**: utf8mb4_unicode_ci
- **Total Tables**: 29 tables + 3 views
- **Auto-generated**: Yes (Hibernate DDL)

## 📊 Tables by Module

### Module 1: User Management & Authentication (4 tables)

#### `users`
Thông tin người dùng hệ thống
```sql
- userId (PK, AUTO_INCREMENT)
- roleId (FK -> roles)
- fullName, username, passwordHash
- email, phone, avatar, address
- status (ACTIVE, INACTIVE, SUSPENDED)
- email_verified, verification_token
- createdAt
```

#### `roles`
Vai trò trong hệ thống
```sql
- roleId (PK, AUTO_INCREMENT)
- roleName (Admin, Manager, Consultant, Driver, Accountant)
- description
- status (ACTIVE, INACTIVE, SUSPENDED)
```

#### `employees`
Nhân viên (liên kết user với branch)
```sql
- employeeId (PK, AUTO_INCREMENT)
- userId (FK -> users, UNIQUE)
- branchId (FK -> branches)
- roleId (FK -> roles)
- status (ACTIVE, INACTIVE, ONLEAVE)
```

---

### Module 2: Driver Management (3 tables)

#### `drivers`
Thông tin tài xế
```sql
- driverId (PK, AUTO_INCREMENT)
- employeeId (FK -> employees, UNIQUE)
- branchId (FK -> branches)
- licenseNumber (UNIQUE), licenseClass, licenseExpiry
- healthCheckDate
- rating (0-5), priorityLevel (1-10)
- status (AVAILABLE, ONTRIP, INACTIVE)
- note, createdAt
```

#### `driver_day_off`
Đăng ký nghỉ phép
```sql
- dayOffId (PK, AUTO_INCREMENT)
- driverId (FK -> drivers)
- startDate, endDate
- reason
- approvedBy (FK -> employees)
- status (PENDING, APPROVED, REJECTED)
- createdAt
```

#### `driver_ratings`
Đánh giá tài xế
```sql
- ratingId (PK, AUTO_INCREMENT)
- driverId (FK -> drivers)
- tripId (FK -> trips)
- customerId (FK -> customers)
- ratedBy (FK -> users)
- safetyRating, punctualityRating, attitudeRating, complianceRating (1-5)
- overallRating (calculated)
- comment, ratedAt
```

---

### Module 3: Vehicle Management (2 tables)

#### `vehicles`
Thông tin phương tiện
```sql
- vehicleId (PK, AUTO_INCREMENT)
- categoryId (FK -> vehicle_category_pricing)
- branchId (FK -> branches)
- licensePlate (UNIQUE), model, brand
- capacity, productionYear
- registrationDate, inspectionExpiry, insuranceExpiry
- odometer
- status (AVAILABLE, INUSE, MAINTENANCE, INACTIVE)
```

#### `vehicle_category_pricing`
Danh mục loại xe & giá
```sql
- categoryId (PK, AUTO_INCREMENT)
- categoryName (Xe 9 chỗ, 16 chỗ, 29 chỗ, 45 chỗ, giường nằm)
- seats, description
- baseFare, pricePerKm, highwayFee, fixedCosts
- effectiveDate
- status (ACTIVE, INACTIVE)
- createdAt
```

---

### Module 4: Booking & Customer (4 tables)

#### `customers`
Khách hàng
```sql
- customerId (PK, AUTO_INCREMENT)
- fullName, phone, email, address
- note
- createdAt, createdBy (FK -> employees)
- status (ACTIVE, INACTIVE)
```

#### `bookings`
Đơn đặt xe
```sql
- bookingId (PK, AUTO_INCREMENT)
- customerId (FK -> customers)
- branchId (FK -> branches)
- consultantId (FK -> employees)
- hireTypeId (FK -> hire_types)
- useHighway (boolean)
- bookingDate, estimatedCost, depositAmount, totalCost
- totalDistance, totalDuration
- status (PENDING, CONFIRMED, INPROGRESS, COMPLETED, CANCELLED)
- note, createdAt, updatedAt
```

#### `booking_vehicle_details`
Chi tiết xe trong booking
```sql
- bookingId (PK, FK -> bookings)
- vehicleCategoryId (PK, FK -> vehicle_category_pricing)
- quantity (số lượng xe cần)
```

#### `hire_types`
Loại hình thuê xe
```sql
- hireTypeId (PK, AUTO_INCREMENT)
- code (ONE_WAY, ROUND_TRIP, MULTI_DAY, PERIODIC, AIRPORT_TRANSFER)
- name, description
- isActive
```

---

### Module 5: Trip Dispatch (6 tables)

#### `trips`
Chuyến đi
```sql
- tripId (PK, AUTO_INCREMENT)
- bookingId (FK -> bookings)
- startTime, endTime
- startLocation, endLocation
- startLatitude, startLongitude, endLatitude, endLongitude
- distance (km), estimatedDuration (minutes), actualDuration
- routeData (JSON - from SerpAPI)
- trafficStatus (LIGHT, MODERATE, HEAVY, UNKNOWN)
- useHighway, incidentalCosts
- status (SCHEDULED, ONGOING, COMPLETED, CANCELLED)
```

#### `trip_drivers`
Gán tài xế cho chuyến
```sql
- tripId (PK, FK -> trips)
- driverId (PK, FK -> drivers)
- driverRole (Main Driver, Support Driver)
- startTime, endTime
- note
```

#### `trip_vehicles`
Gán xe cho chuyến
```sql
- tripVehicleId (PK, AUTO_INCREMENT)
- tripId (FK -> trips)
- vehicleId (FK -> vehicles)
- assignedAt
- note
```

#### `trip_assignment_history`
Lịch sử gán/hủy
```sql
- id (PK, AUTO_INCREMENT)
- tripId (FK -> trips)
- driverId (FK -> drivers)
- vehicleId (FK -> vehicles)
- action (ASSIGN, UNASSIGN, REASSIGN, ACCEPT, CANCEL)
- note, createdAt
```

#### `trip_incidents`
Sự cố trong chuyến
```sql
- incidentId (PK, AUTO_INCREMENT)
- tripId (FK -> trips)
- driverId (FK -> drivers)
- description, severity
- resolved (boolean)
- createdAt
```

---

### Module 6: Financial Management (6 tables)

#### `invoices`
Hóa đơn thu/chi
```sql
- invoiceId (PK, AUTO_INCREMENT)
- branchId (FK -> branches)
- bookingId (FK -> bookings)
- customerId (FK -> customers)
- type (INCOME, EXPENSE)
- costType (fuel, toll, maintenance, salary, etc.)
- isDeposit (boolean)
- amount, subtotal, vatAmount
- paymentMethod (CASH, BANK_TRANSFER, QR, CARD)
- paymentStatus (UNPAID, PAID, REFUNDED)
- status (ACTIVE, CANCELLED)
- invoiceNumber (UNIQUE), receiptNumber, referenceNumber
- bankName, bankAccount, cashierName
- dueDate, promiseToPayDate
- paymentTerms (NET_7, NET_14, NET_30, etc.)
- debtLabel (NORMAL, OVERDUE, etc.)
- invoiceDate, sentAt, sentToEmail
- note, contactNote
- requestedBy, createdBy, approvedBy, cancelledBy
- approvedAt, cancelledAt, cancellationReason
- createdAt
```

#### `invoice_items`
Chi tiết dòng hóa đơn
```sql
- itemId (PK, AUTO_INCREMENT)
- invoiceId (FK -> invoices)
- description
- quantity, unitPrice
- amount (calculated = quantity * unitPrice)
- taxRate, taxAmount
- note
- createdAt, updatedAt
```

#### `payment_history`
Lịch sử thanh toán
```sql
- paymentId (PK, AUTO_INCREMENT)
- invoiceId (FK -> invoices)
- amount
- paymentMethod, paymentDate
- bankName, bankAccount, referenceNumber
- receiptNumber, cashierName
- note
- createdBy (FK -> employees)
- createdAt
```

#### `debt_reminder_history`
Lịch sử nhắc nợ
```sql
- reminderId (PK, AUTO_INCREMENT)
- invoiceId (FK -> invoices)
- reminderType (EMAIL, SMS, PHONE)
- reminderDate
- recipient, message
- sentBy (FK -> users)
- createdAt
```

#### `expense_requests`
Yêu cầu chi phí
```sql
- expenseRequestId (PK, AUTO_INCREMENT)
- branchId (FK -> branches)
- vehicleId (FK -> vehicles)
- requesterId (FK -> users)
- expenseType (fuel, maintenance, etc.)
- amount
- note, rejectionReason
- status (PENDING, APPROVED, REJECTED)
- approvedBy (FK -> users)
- createdAt, updatedAt, approvedAt
```

---

### System & Common (4 tables)

#### `branches`
Chi nhánh
```sql
- branchId (PK, AUTO_INCREMENT)
- branchName, location
- managerId (FK -> employees)
- status (ACTIVE, INACTIVE, UNDERREVIEW, CLOSED)
- createdAt
```

#### `notifications`
Thông báo
```sql
- notificationId (PK, AUTO_INCREMENT)
- userId (FK -> users)
- title, message
- isRead (boolean)
- createdAt
```

#### `system_alerts`
Cảnh báo hệ thống
```sql
- alertId (PK, AUTO_INCREMENT)
- branchId (FK -> branches)
- alertType (VEHICLE_INSPECTION_EXPIRING, DRIVER_LICENSE_EXPIRING, 
             VEHICLE_MAINTENANCE_DUE, DRIVING_HOURS_EXCEEDED, etc.)
- severity (LOW, MEDIUM, HIGH, CRITICAL)
- title, message
- relatedEntityType, relatedEntityId
- isAcknowledged, acknowledgedBy, acknowledgedAt
- expiresAt, createdAt
```

#### `system_settings`
Cấu hình hệ thống
```sql
- settingId (PK, AUTO_INCREMENT)
- settingKey (UNIQUE) (VAT_RATE, DEFAULT_HIGHWAY, MAX_DRIVING_HOURS_PER_DAY, etc.)
- settingValue
- valueType (string, int, decimal, boolean)
- category (Billing, Booking, Driver, General)
- description
- effectiveStartDate, effectiveEndDate
- status (ACTIVE, INACTIVE)
- updatedBy (FK -> employees)
- updatedAt
```

#### `approval_history`
Lịch sử phê duyệt
```sql
- historyId (PK, AUTO_INCREMENT)
- branchId (FK -> branches)
- approvalType (DRIVER_DAY_OFF, EXPENSE_REQUEST, DISCOUNT_REQUEST, 
                OVERTIME_REQUEST, SCHEDULE_CHANGE, VEHICLE_REPAIR)
- relatedEntityId
- requestedBy (FK -> users)
- requestReason
- requestedAt
- status (PENDING, APPROVED, REJECTED, CANCELLED)
- approvedBy (FK -> users)
- approvalNote
- processedAt
```

---

## 📈 Views

### `v_drivermonthlyperformance`
Hiệu suất tài xế theo tháng
```sql
SELECT 
  driverId, year, month,
  COUNT(trips) as tripsCount,
  SUM(minutes) as minutesOnTrip
FROM trip_drivers
GROUP BY driverId, year, month
```

### `v_tripdistanceanalytics`
Phân tích khoảng cách & thời gian
```sql
SELECT 
  tripId, bookingId, branchId,
  distance, estimatedDuration, actualDuration,
  (actualDuration - estimatedDuration) / estimatedDuration * 100 as durationVariancePercent,
  trafficStatus, tripStatus
FROM trips
```

---

## 🔗 Key Relationships

```
users ──┬── employees ──┬── drivers
        │               ├── branches (manager)
        │               └── consultants

bookings ──┬── trips ──┬── trip_drivers ── drivers
           │           ├── trip_vehicles ── vehicles
           │           └── trip_incidents
           │
           ├── invoices ──┬── invoice_items
           │              └── payment_history
           │
           └── booking_vehicle_details ── vehicle_category_pricing

branches ──┬── employees
           ├── vehicles
           ├── bookings
           └── system_alerts
```

---

## 🔐 Indexes

Các indexes quan trọng được tạo tự động:

- **Primary Keys**: Tất cả tables
- **Foreign Keys**: Tất cả relationships
- **Unique Constraints**: username, email, licensePlate, licenseNumber, invoiceNumber
- **Performance Indexes**: 
  - `IX_Bookings_BranchId`
  - `IX_Trips_BookingId`
  - `IX_Drivers_BranchId`
  - `IX_Vehicles_BranchId`
  - `IX_Invoices_Branch`
  - `IX_Cache_Locations`

---

## 📝 Notes

1. **Auto-increment**: Tất cả PK sử dụng AUTO_INCREMENT
2. **Timestamps**: Hầu hết tables có `createdAt`, một số có `updatedAt`
3. **Soft Delete**: Sử dụng `status` field thay vì xóa thật
4. **Enums**: Nhiều fields sử dụng ENUM để đảm bảo data integrity
5. **JSON Fields**: `routeData` trong trips
6. **Calculated Fields**: `amount` trong invoice_items
7. **Charset**: utf8mb4_unicode_ci cho hỗ trợ tiếng Việt và emoji

---

## 🚀 Initialization

Khi chạy lần đầu:

1. **Hibernate DDL** tự động tạo tất cả tables
2. **data.sql** tự động insert:
   - 5 roles (Admin, Manager, Consultant, Driver, Accountant)
   - 1 admin user (username: admin, password: 123456)
   - 1 default branch (Hà Nội)
   - 5 hire types
   - 5 vehicle categories
   - 5 system settings

Không cần chạy script SQL thủ công!
