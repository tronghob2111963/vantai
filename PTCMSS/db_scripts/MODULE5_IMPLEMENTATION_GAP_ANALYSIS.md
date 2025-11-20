# 🔍 MODULE 5 - PHÂN TÍCH KHOẢNG TRỐNG IMPLEMENTATION

## 📋 Tổng quan đánh giá

Dựa trên yêu cầu chi tiết Module 5, đây là phân tích **ĐÃ CÓ** vs **THIẾU** trong database hiện tại.

---

## ✅ ĐÃ CÓ TRONG DATABASE (70%)

### 1. **Bảng cốt lõi đã đủ**
- ✅ Trips (tripId, bookingId, startTime, endTime, status, startLocation, endLocation)
- ✅ TripDrivers (phân công tài xế cho chuyến)
- ✅ TripVehicles (phân công xe cho chuyến)
- ✅ Drivers (thông tin tài xế, status, rating, averageRating, totalRatings)
- ✅ Vehicles (thông tin xe, status)
- ✅ DriverDayOff (nghỉ phép tài xế)
- ✅ Bookings (đơn đặt xe, depositAmount, status)
- ✅ Branches (chi nhánh)

### 2. **Bảng Module 5 mới đã thêm**
- ✅ TripAssignmentHistory (audit log phân công)
- ✅ TripRatings (đánh giá tài xế)
- ✅ DriverWorkload (workload & fairness score)
- ✅ TripIncidents (báo cáo sự cố)

### 3. **Views hỗ trợ**
- ✅ v_DriverMonthlyPerformance
- ✅ v_DriverRatingsSummary
- ✅ v_DriverWorkloadSummary

### 4. **System Settings**
- ✅ FAIRNESS_WEIGHT_DAILY_HOURS
- ✅ FAIRNESS_WEIGHT_WEEKLY_TRIPS
- ✅ FAIRNESS_WEIGHT_REST_TIME
- ✅ MAX_DRIVING_HOURS_PER_DAY

---

## ❌ THIẾU HOẶC CẦN BỔ SUNG (30%)

### 🔴 **CRITICAL - Thiếu hoàn toàn**

#### 1. **Bảng DriverShifts (Ca làm việc tài xế)**
**Yêu cầu:** Schedule Board cần hiển thị ca làm việc (SHIFT block)

```sql
CREATE TABLE IF NOT EXISTS DriverShifts (
  shiftId INT AUTO_INCREMENT PRIMARY KEY,
  driverId INT NOT NULL,
  shiftDate DATE NOT NULL,
  shiftType ENUM('MORNING','AFTERNOON','NIGHT','FULL_DAY') NOT NULL,
  startTime TIME NOT NULL,
  endTime TIME NOT NULL,
  status ENUM('SCHEDULED','ACTIVE','COMPLETED','CANCELLED') DEFAULT 'SCHEDULED',
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ds_driver FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  UNIQUE KEY UK_DriverShifts (driverId, shiftDate, shiftType)
) ENGINE=InnoDB;

CREATE INDEX IX_DriverShifts_Date ON DriverShifts(shiftDate);
CREATE INDEX IX_DriverShifts_Driver_Date ON DriverShifts(driverId, shiftDate);
```

**Lý do cần:**
- Tính %Util = (BUSY minutes) / (SHIFT minutes)
- Hiển thị SHIFT block trên Timeline
- Validate không gán ngoài ca làm việc

---

#### 2. **Bảng VehicleMaintenanceSchedule (Lịch bảo dưỡng xe)**
**Yêu cầu:** Schedule Board cần hiển thị MAINT block

```sql
CREATE TABLE IF NOT EXISTS VehicleMaintenanceSchedule (
  maintenanceId INT AUTO_INCREMENT PRIMARY KEY,
  vehicleId INT NOT NULL,
  maintenanceType VARCHAR(50) NOT NULL,
  scheduledStartTime DATETIME NOT NULL,
  scheduledEndTime DATETIME NOT NULL,
  actualStartTime DATETIME NULL,
  actualEndTime DATETIME NULL,
  status ENUM('SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'SCHEDULED',
  description VARCHAR(500),
  cost DECIMAL(10,2),
  performedBy VARCHAR(100),
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_vms_vehicle FOREIGN KEY (vehicleId) REFERENCES Vehicles(vehicleId),
  CHECK (scheduledStartTime < scheduledEndTime)
) ENGINE=InnoDB;

CREATE INDEX IX_VehicleMaintenance_Vehicle ON VehicleMaintenanceSchedule(vehicleId);
CREATE INDEX IX_VehicleMaintenance_Status ON VehicleMaintenanceSchedule(status);
CREATE INDEX IX_VehicleMaintenance_Time ON VehicleMaintenanceSchedule(scheduledStartTime, scheduledEndTime);
```

**Lý do cần:**
- Hiển thị MAINT block trên Timeline
- Validate không gán xe đang bảo dưỡng
- Theo dõi chi phí bảo dưỡng

---

#### 3. **Bảng TripPriority (Độ ưu tiên chuyến)**
**Yêu cầu:** Queue hiển thị cột "Ưu tiên (Low/Normal/High/Hot)"

```sql
-- Option 1: Thêm cột vào Trips
ALTER TABLE Trips 
  ADD COLUMN priority ENUM('LOW','NORMAL','HIGH','HOT') DEFAULT 'NORMAL' AFTER status;

CREATE INDEX IX_Trips_Priority ON Trips(priority);

-- Option 2: Thêm cột vào Bookings (tốt hơn vì priority thuộc booking)
ALTER TABLE Bookings
  ADD COLUMN priority ENUM('LOW','NORMAL','HIGH','HOT') DEFAULT 'NORMAL' AFTER status;

CREATE INDEX IX_Bookings_Priority ON Bookings(priority);
```

**Lý do cần:**
- Sắp xếp queue theo độ ưu tiên
- Filter nhanh "High/Hot priority"
- Thuật toán auto-assign ưu tiên chuyến HOT

---

#### 4. **Bảng DepositApprovals (Duyệt cọc)**
**Yêu cầu:** Queue chỉ hiển thị "đã duyệt cọc hoặc miễn cọc hợp lệ"

```sql
CREATE TABLE IF NOT EXISTS DepositApprovals (
  approvalId INT AUTO_INCREMENT PRIMARY KEY,
  bookingId INT NOT NULL,
  depositAmount DECIMAL(12,2) NOT NULL,
  isExempted BOOLEAN DEFAULT FALSE,
  exemptionReason VARCHAR(500),
  approvedBy INT NULL,
  approvedAt DATETIME NULL,
  status ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_da_booking FOREIGN KEY (bookingId) REFERENCES Bookings(bookingId),
  CONSTRAINT fk_da_approver FOREIGN KEY (approvedBy) REFERENCES Employees(employeeId),
  UNIQUE KEY UK_DepositApprovals (bookingId)
) ENGINE=InnoDB;

CREATE INDEX IX_DepositApprovals_Status ON DepositApprovals(status);
CREATE INDEX IX_DepositApprovals_Booking ON DepositApprovals(bookingId);
```

**Lý do cần:**
- Validate booking đã duyệt cọc mới vào Queue
- Hiển thị tooltip "Đã duyệt" hoặc "Miễn"
- Audit trail cho việc duyệt cọc

---

#### 5. **Bảng DispatchNotifications (Thông báo điều phối)**
**Yêu cầu:** Widget "Notifications & Approvals" trên Dashboard

```sql
CREATE TABLE IF NOT EXISTS DispatchNotifications (
  notificationId INT AUTO_INCREMENT PRIMARY KEY,
  notificationType ENUM('WARNING','APPROVAL_REQUEST','INFO','ALERT') NOT NULL,
  category VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  message VARCHAR(1000),
  relatedEntityType VARCHAR(50),
  relatedEntityId INT,
  severity ENUM('LOW','MEDIUM','HIGH','CRITICAL') DEFAULT 'MEDIUM',
  status ENUM('UNREAD','READ','ACKNOWLEDGED','RESOLVED') DEFAULT 'UNREAD',
  targetUserId INT NULL,
  targetRoleId INT NULL,
  acknowledgedBy INT NULL,
  acknowledgedAt DATETIME NULL,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  expiresAt DATETIME NULL,
  CONSTRAINT fk_dn_targetUser FOREIGN KEY (targetUserId) REFERENCES Users(userId),
  CONSTRAINT fk_dn_targetRole FOREIGN KEY (targetRoleId) REFERENCES Roles(roleId),
  CONSTRAINT fk_dn_acknowledger FOREIGN KEY (acknowledgedBy) REFERENCES Employees(employeeId)
) ENGINE=InnoDB;

CREATE INDEX IX_DispatchNotifications_Status ON DispatchNotifications(status);
CREATE INDEX IX_DispatchNotifications_Type ON DispatchNotifications(notificationType);
CREATE INDEX IX_DispatchNotifications_Target ON DispatchNotifications(targetUserId, status);
CREATE INDEX IX_DispatchNotifications_Created ON DispatchNotifications(createdAt);
```

**Lý do cần:**
- Cảnh báo xe sắp hết đăng kiểm
- Cảnh báo bằng lái sắp hết hạn
- Cảnh báo xung đột lịch
- Cảnh báo vượt giờ lái
- Yêu cầu duyệt nghỉ phép

---

### 🟡 **MEDIUM - Cần bổ sung cột**

#### 6. **Trips table - Thiếu cột quan trọng**

```sql
ALTER TABLE Trips
  ADD COLUMN priority ENUM('LOW','NORMAL','HIGH','HOT') DEFAULT 'NORMAL' AFTER status,
  ADD COLUMN assignmentMethod ENUM('AUTO','MANUAL') NULL AFTER priority,
  ADD COLUMN assignedBy INT NULL AFTER assignmentMethod,
  ADD COLUMN assignedAt DATETIME NULL AFTER assignedBy,
  ADD COLUMN estimatedDuration INT NULL COMMENT 'Estimated duration in minutes' AFTER endTime,
  ADD COLUMN actualDuration INT NULL COMMENT 'Actual duration in minutes' AFTER estimatedDuration;

ALTER TABLE Trips
  ADD CONSTRAINT fk_trips_assignedBy FOREIGN KEY (assignedBy) REFERENCES Employees(employeeId);

CREATE INDEX IX_Trips_AssignedBy ON Trips(assignedBy);
CREATE INDEX IX_Trips_AssignedAt ON Trips(assignedAt);
```

**Lý do:**
- `priority`: Sắp xếp queue
- `assignmentMethod`: Biết chuyến được gán AUTO hay MANUAL
- `assignedBy`: Audit - ai đã gán
- `assignedAt`: Audit - khi nào gán
- `estimatedDuration`: Tính overlap, validate conflict
- `actualDuration`: So sánh với estimate, KPI

---

#### 7. **Bookings table - Thiếu cột**

```sql
ALTER TABLE Bookings
  ADD COLUMN priority ENUM('LOW','NORMAL','HIGH','HOT') DEFAULT 'NORMAL' AFTER status,
  ADD COLUMN depositApprovalStatus ENUM('PENDING','APPROVED','REJECTED','EXEMPTED') DEFAULT 'PENDING' AFTER depositAmount,
  ADD COLUMN depositApprovedBy INT NULL AFTER depositApprovalStatus,
  ADD COLUMN depositApprovedAt DATETIME NULL AFTER depositApprovedBy;

ALTER TABLE Bookings
  ADD CONSTRAINT fk_bookings_depositApprover FOREIGN KEY (depositApprovedBy) REFERENCES Employees(employeeId);

CREATE INDEX IX_Bookings_DepositApproval ON Bookings(depositApprovalStatus);
```

**Lý do:**
- `priority`: Ưu tiên xử lý booking
- `depositApprovalStatus`: Validate vào Queue
- `depositApprovedBy`: Audit
- `depositApprovedAt`: Audit

---

#### 8. **Drivers table - Thiếu cột**

```sql
ALTER TABLE Drivers
  ADD COLUMN maxDrivingHoursPerDay INT DEFAULT 10 AFTER priorityLevel,
  ADD COLUMN maxContinuousDrivingMinutes INT DEFAULT 240 AFTER maxDrivingHoursPerDay,
  ADD COLUMN minRestMinutes INT DEFAULT 30 AFTER maxContinuousDrivingMinutes,
  ADD COLUMN currentShiftStartTime DATETIME NULL AFTER minRestMinutes,
  ADD COLUMN currentShiftEndTime DATETIME NULL AFTER currentShiftStartTime;

CREATE INDEX IX_Drivers_CurrentShift ON Drivers(currentShiftStartTime, currentShiftEndTime);
```

**Lý do:**
- Validate giới hạn giờ lái
- Tính toán rest time
- Hiển thị ca làm việc hiện tại

---

#### 9. **Vehicles table - Thiếu cột**

```sql
ALTER TABLE Vehicles
  ADD COLUMN currentMaintenanceId INT NULL AFTER status,
  ADD COLUMN lastMaintenanceDate DATE NULL AFTER currentMaintenanceId,
  ADD COLUMN nextMaintenanceDate DATE NULL AFTER lastMaintenanceDate,
  ADD COLUMN maintenanceIntervalKm INT DEFAULT 10000 AFTER nextMaintenanceDate;

CREATE INDEX IX_Vehicles_NextMaintenance ON Vehicles(nextMaintenanceDate);
```

**Lý do:**
- Cảnh báo sắp đến hạn bảo dưỡng
- Validate không gán xe đang bảo dưỡng

---

### 🟢 **LOW - Tối ưu hóa**

#### 10. **View bổ sung cho Dashboard**

```sql
-- View: Pending Trips Queue
CREATE OR REPLACE VIEW v_PendingTripsQueue AS
SELECT 
  t.tripId,
  t.bookingId,
  b.customerId,
  c.fullName AS customerName,
  c.phone AS customerPhone,
  t.startLocation,
  t.endLocation,
  t.startTime,
  t.priority,
  b.depositApprovalStatus,
  b.depositApprovedBy,
  b.depositApprovedAt,
  vcp.categoryName AS vehicleCategory,
  b.branchId,
  br.branchName,
  CASE 
    WHEN t.startTime < NOW() THEN CONCAT('Trễ ', TIMESTAMPDIFF(MINUTE, t.startTime, NOW()), 'p')
    ELSE CONCAT('Còn ', TIMESTAMPDIFF(MINUTE, NOW(), t.startTime), 'p')
  END AS timeStatus,
  CASE 
    WHEN t.startTime < NOW() THEN 'LATE'
    WHEN TIMESTAMPDIFF(MINUTE, NOW(), t.startTime) <= 30 THEN 'URGENT'
    ELSE 'NORMAL'
  END AS urgencyLevel
FROM Trips t
JOIN Bookings b ON t.bookingId = b.bookingId
JOIN Customers c ON b.customerId = c.customerId
JOIN Branches br ON b.branchId = br.branchId
LEFT JOIN BookingVehicleDetails bvd ON b.bookingId = bvd.bookingId
LEFT JOIN VehicleCategoryPricing vcp ON bvd.vehicleCategoryId = vcp.categoryId
WHERE t.status = 'SCHEDULED'
  AND b.depositApprovalStatus IN ('APPROVED', 'EXEMPTED')
  AND NOT EXISTS (
    SELECT 1 FROM TripDrivers td WHERE td.tripId = t.tripId
  )
  AND NOT EXISTS (
    SELECT 1 FROM TripVehicles tv WHERE tv.tripId = t.tripId
  );

-- View: Driver Availability Timeline
CREATE OR REPLACE VIEW v_DriverAvailabilityTimeline AS
SELECT 
  d.driverId,
  u.fullName AS driverName,
  d.branchId,
  b.branchName,
  d.status AS driverStatus,
  ds.shiftDate,
  ds.startTime AS shiftStart,
  ds.endTime AS shiftEnd,
  TIMESTAMPDIFF(MINUTE, ds.startTime, ds.endTime) AS shiftMinutes,
  COALESCE(dw.totalMinutes, 0) AS busyMinutes,
  ROUND((COALESCE(dw.totalMinutes, 0) * 100.0) / TIMESTAMPDIFF(MINUTE, ds.startTime, ds.endTime), 2) AS utilizationPercent
FROM Drivers d
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
JOIN Branches b ON d.branchId = b.branchId
LEFT JOIN DriverShifts ds ON d.driverId = ds.driverId AND ds.shiftDate = CURDATE()
LEFT JOIN DriverWorkload dw ON d.driverId = dw.driverId AND dw.date = CURDATE()
WHERE d.status != 'INACTIVE';

-- View: Vehicle Availability Timeline
CREATE OR REPLACE VIEW v_VehicleAvailabilityTimeline AS
SELECT 
  v.vehicleId,
  v.licensePlate,
  v.branchId,
  b.branchName,
  v.status AS vehicleStatus,
  vcp.categoryName,
  v.capacity,
  COUNT(DISTINCT tv.tripId) AS tripsToday,
  SUM(TIMESTAMPDIFF(MINUTE, t.startTime, t.endTime)) AS busyMinutesToday
FROM Vehicles v
JOIN Branches b ON v.branchId = b.branchId
JOIN VehicleCategoryPricing vcp ON v.categoryId = vcp.categoryId
LEFT JOIN TripVehicles tv ON v.vehicleId = tv.vehicleId
LEFT JOIN Trips t ON tv.tripId = t.tripId AND DATE(t.startTime) = CURDATE()
WHERE v.status != 'INACTIVE'
GROUP BY v.vehicleId, v.licensePlate, v.branchId, b.branchName, v.status, vcp.categoryName, v.capacity;

-- View: Dispatch Warnings
CREATE OR REPLACE VIEW v_DispatchWarnings AS
SELECT 
  'VEHICLE_INSPECTION' AS warningType,
  v.vehicleId AS entityId,
  v.licensePlate AS entityName,
  CONCAT('Xe ', v.licensePlate, ' sắp hết hạn đăng kiểm (', v.inspectionExpiry, ')') AS message,
  DATEDIFF(v.inspectionExpiry, CURDATE()) AS daysRemaining,
  CASE 
    WHEN DATEDIFF(v.inspectionExpiry, CURDATE()) <= 7 THEN 'CRITICAL'
    WHEN DATEDIFF(v.inspectionExpiry, CURDATE()) <= 30 THEN 'HIGH'
    ELSE 'MEDIUM'
  END AS severity
FROM Vehicles v
WHERE v.inspectionExpiry IS NOT NULL 
  AND v.inspectionExpiry <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND v.status != 'INACTIVE'

UNION ALL

SELECT 
  'DRIVER_LICENSE' AS warningType,
  d.driverId AS entityId,
  u.fullName AS entityName,
  CONCAT('Bằng lái của ', u.fullName, ' sắp hết hạn (', d.licenseExpiry, ')') AS message,
  DATEDIFF(d.licenseExpiry, CURDATE()) AS daysRemaining,
  CASE 
    WHEN DATEDIFF(d.licenseExpiry, CURDATE()) <= 7 THEN 'CRITICAL'
    WHEN DATEDIFF(d.licenseExpiry, CURDATE()) <= 30 THEN 'HIGH'
    ELSE 'MEDIUM'
  END AS severity
FROM Drivers d
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
WHERE d.licenseExpiry IS NOT NULL 
  AND d.licenseExpiry <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND d.status != 'INACTIVE'

UNION ALL

SELECT 
  'VEHICLE_INSURANCE' AS warningType,
  v.vehicleId AS entityId,
  v.licensePlate AS entityName,
  CONCAT('Bảo hiểm xe ', v.licensePlate, ' sắp hết hạn (', v.insuranceExpiry, ')') AS message,
  DATEDIFF(v.insuranceExpiry, CURDATE()) AS daysRemaining,
  CASE 
    WHEN DATEDIFF(v.insuranceExpiry, CURDATE()) <= 7 THEN 'CRITICAL'
    WHEN DATEDIFF(v.insuranceExpiry, CURDATE()) <= 30 THEN 'HIGH'
    ELSE 'MEDIUM'
  END AS severity
FROM Vehicles v
WHERE v.insuranceExpiry IS NOT NULL 
  AND v.insuranceExpiry <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND v.status != 'INACTIVE';
```

---

## 📊 TÓM TẮT ĐÁNH GIÁ

### Điểm mạnh ✅
1. **Cấu trúc cơ bản đã tốt** - Trips, Drivers, Vehicles, Bookings đầy đủ
2. **Module 5 core tables đã có** - TripAssignmentHistory, TripRatings, DriverWorkload, TripIncidents
3. **Audit trail đã được thiết kế** - Có thể track được lịch sử phân công
4. **Fairness algorithm có foundation** - DriverWorkload + SystemSettings

### Điểm yếu ❌
1. **Thiếu DriverShifts** - Không tính được %Util, không hiển thị SHIFT block
2. **Thiếu VehicleMaintenanceSchedule** - Không hiển thị MAINT block, không validate xe đang bảo dưỡng
3. **Thiếu Priority** - Không sắp xếp queue theo độ ưu tiên
4. **Thiếu DepositApprovals** - Không validate cọc đã duyệt
5. **Thiếu DispatchNotifications** - Không có widget cảnh báo trên Dashboard
6. **Thiếu metadata** - assignmentMethod, assignedBy, assignedAt, estimatedDuration

---

## 🎯 ĐỘ ƯU TIÊN IMPLEMENT

### 🔴 **P0 - CRITICAL (Phải có ngay)**
1. DriverShifts
2. Priority (Trips/Bookings)
3. DepositApprovals hoặc depositApprovalStatus
4. assignmentMethod, assignedBy, assignedAt

### 🟡 **P1 - HIGH (Cần có sớm)**
5. VehicleMaintenanceSchedule
6. DispatchNotifications
7. estimatedDuration, actualDuration
8. Views: v_PendingTripsQueue, v_DriverAvailabilityTimeline

### 🟢 **P2 - MEDIUM (Có thể sau)**
9. maxDrivingHoursPerDay, minRestMinutes
10. View: v_DispatchWarnings
11. currentMaintenanceId, nextMaintenanceDate

---

## 📈 ROADMAP ĐỀ XUẤT

### Phase 1: Database Schema (1-2 ngày)
- Tạo 5 bảng mới (DriverShifts, VehicleMaintenanceSchedule, DepositApprovals, DispatchNotifications)
- ALTER các bảng hiện có (Trips, Bookings, Drivers, Vehicles)
- Tạo 4 views mới

### Phase 2: Backend API (3-5 ngày)
- Entity classes cho 5 bảng mới
- Repository interfaces
- Service layer (DispatchService, ShiftService, MaintenanceService)
- Controller endpoints
- Fairness algorithm implementation

### Phase 3: Frontend Components (5-7 ngày)
- Dispatcher Dashboard
- Queue / Pending Trips
- Schedule Board (Timeline)
- Assign Driver & Vehicle popup
- Notifications widget

### Phase 4: Testing & Optimization (2-3 ngày)
- Unit tests
- Integration tests
- Performance optimization
- Bug fixes

**Tổng thời gian ước tính: 11-17 ngày**

---

## 🚀 NEXT STEPS

1. **Review & Approve** - Xác nhận các bảng/cột cần thêm
2. **Create SQL Script** - Tạo script migration cho Phase 1
3. **Update ERD** - Cập nhật sơ đồ database
4. **Backend Implementation** - Bắt đầu code Entity/Repository/Service
5. **Frontend Implementation** - Bắt đầu code Components

---

**Kết luận:** Database hiện tại đã có **70% foundation** cho Module 5, nhưng cần bổ sung **30% critical components** để implement đầy đủ các tính năng theo yêu cầu.
