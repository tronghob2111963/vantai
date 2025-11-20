# 🔍 PHÂN TÍCH ĐẦY ĐỦ - MODULE 5 DATABASE vs YÊU CẦU

## 📋 YÊU CẦU MODULE 5 (Từ spec)

### 🎯 Các chức năng chính:

1. **Dispatcher Dashboard**
   - Queue/Pending Trips (chuyến chờ gán)
   - Schedule Board (Driver-Vehicle Availability)
   - Timeline với %Util, BUSY, MAINT, LEAVE

2. **Assign Driver & Vehicle**
   - Auto-Assign (fairness algorithm)
   - Manual Select
   - Ghi lịch sử điều phối

3. **Edit Assignment / Reassign & Unassign**
   - Thay đổi phân công
   - Bắt buộc ghi lý do

4. **View Trips & Trip Detail**
   - Danh sách chuyến
   - Chi tiết chuyến + timeline
   - Cảnh báo xung đột

5. **Notifications & Approvals**
   - Cảnh báo (license, đăng kiểm, xung đột, giờ lái)
   - Chờ duyệt (nghỉ phép, yêu cầu giảm giá)

6. **Expense Request**
   - Chi phí vận hành
   - Upload chứng từ
   - Workflow duyệt

7. **Driver Rating & Performance**
   - Đánh giá sau chuyến
   - Tổng hợp 30 ngày

---

## ✅ ĐÃ CÓ TRONG DATABASE HIỆN TẠI

### 1. Bảng cốt lõi (Core Tables)
- ✅ **Trips** - Chuyến đi
- ✅ **TripDrivers** - Phân công tài xế
- ✅ **TripVehicles** - Phân công xe
- ✅ **Drivers** - Tài xế (có averageRating, totalRatings)
- ✅ **Vehicles** - Phương tiện
- ✅ **DriverDayOff** - Nghỉ phép tài xế
- ✅ **Bookings** - Đơn đặt xe

### 2. Bảng Module 5 đã thêm
- ✅ **TripAssignmentHistory** - Lịch sử phân công (Audit log)
- ✅ **TripRatings** - Đánh giá tài xế
- ✅ **DriverWorkload** - Workload & Fairness score
- ✅ **TripIncidents** - Báo cáo sự cố

### 3. Bảng hỗ trợ
- ✅ **Invoices** - Hóa đơn (có thể dùng cho Expense)
- ✅ **Notifications** - Thông báo
- ✅ **SystemSettings** - Cấu hình (có fairness weights)

### 4. Views
- ✅ **v_DriverMonthlyPerformance** - Hiệu suất tháng
- ✅ **v_DriverRatingsSummary** - Tổng hợp rating
- ✅ **v_DriverWorkloadSummary** - Tổng hợp workload 7 ngày

---

## ❌ THIẾU TRONG DATABASE (CRITICAL GAPS)

### 🚨 Gap 1: Driver/Vehicle Shifts (Ca làm việc)
**Yêu cầu:** Schedule Board cần hiển thị SHIFT (dải ca làm)

**Thiếu:**
```sql
CREATE TABLE DriverShifts (
  shiftId INT AUTO_INCREMENT PRIMARY KEY,
  driverId INT NOT NULL,
  date DATE NOT NULL,
  shiftStart TIME NOT NULL,
  shiftEnd TIME NOT NULL,
  status ENUM('SCHEDULED','ACTIVE','COMPLETED','CANCELLED'),
  FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  UNIQUE KEY (driverId, date)
);

CREATE TABLE VehicleShifts (
  shiftId INT AUTO_INCREMENT PRIMARY KEY,
  vehicleId INT NOT NULL,
  date DATE NOT NULL,
  shiftStart TIME NOT NULL,
  shiftEnd TIME NOT NULL,
  status ENUM('AVAILABLE','MAINTENANCE','INACTIVE'),
  FOREIGN KEY (vehicleId) REFERENCES Vehicles(vehicleId)
);
```

**Impact:** Không tính được %Util chính xác (cần biết ca làm để tính)

---

### 🚨 Gap 2: Vehicle Maintenance Schedule
**Yêu cầu:** Timeline hiển thị MAINT (bảo trì)

**Thiếu:**
```sql
CREATE TABLE VehicleMaintenance (
  maintenanceId INT AUTO_INCREMENT PRIMARY KEY,
  vehicleId INT NOT NULL,
  maintenanceType VARCHAR(50),
  scheduledStart DATETIME NOT NULL,
  scheduledEnd DATETIME NOT NULL,
  actualStart DATETIME,
  actualEnd DATETIME,
  status ENUM('SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED'),
  cost DECIMAL(10,2),
  note VARCHAR(500),
  FOREIGN KEY (vehicleId) REFERENCES Vehicles(vehicleId)
);
```

**Impact:** Không biết xe nào đang bảo trì để tránh gán

---

### 🚨 Gap 3: Approval Workflow
**Yêu cầu:** Notifications & Approvals (chờ duyệt nghỉ phép, yêu cầu giảm giá)

**Hiện tại:** 
- DriverDayOff có `approvedBy` và `status` (PENDING/APPROVED/REJECTED) ✅
- Invoices có `approvedBy` và `approvedAt` ✅

**Thiếu:** Bảng tổng quát cho các loại approval khác
```sql
CREATE TABLE ApprovalRequests (
  requestId INT AUTO_INCREMENT PRIMARY KEY,
  requestType ENUM('DAY_OFF','DISCOUNT','EXPENSE','REASSIGN'),
  referenceId INT, -- ID của bản ghi liên quan
  requestedBy INT NOT NULL,
  approvedBy INT,
  status ENUM('PENDING','APPROVED','REJECTED'),
  reason VARCHAR(500),
  requestedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  processedAt DATETIME,
  FOREIGN KEY (requestedBy) REFERENCES Employees(employeeId),
  FOREIGN KEY (approvedBy) REFERENCES Employees(employeeId)
);
```

**Impact:** Có thể dùng DriverDayOff và Invoices hiện tại, nhưng không linh hoạt cho các loại approval mới

---

### 🚨 Gap 4: Conflict Detection (Phát hiện xung đột)
**Yêu cầu:** Cảnh báo xung đột lịch, overlap

**Thiếu:** Bảng lưu các xung đột đã phát hiện
```sql
CREATE TABLE ScheduleConflicts (
  conflictId INT AUTO_INCREMENT PRIMARY KEY,
  conflictType ENUM('DRIVER_OVERLAP','VEHICLE_OVERLAP','INSUFFICIENT_REST'),
  driverId INT,
  vehicleId INT,
  tripId1 INT,
  tripId2 INT,
  detectedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  resolvedAt DATETIME,
  resolvedBy INT,
  status ENUM('DETECTED','ACKNOWLEDGED','RESOLVED','IGNORED'),
  FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  FOREIGN KEY (vehicleId) REFERENCES Vehicles(vehicleId),
  FOREIGN KEY (tripId1) REFERENCES Trips(tripId),
  FOREIGN KEY (tripId2) REFERENCES Trips(tripId),
  FOREIGN KEY (resolvedBy) REFERENCES Employees(employeeId)
);
```

**Impact:** Phải tính toán xung đột realtime mỗi lần query (chậm)

---

### 🚨 Gap 5: Driver Rest Tracking
**Yêu cầu:** Cảnh báo thiếu nghỉ (< 30 phút giữa 2 chuyến)

**Thiếu:** Bảng theo dõi thời gian nghỉ
```sql
CREATE TABLE DriverRestPeriods (
  restId INT AUTO_INCREMENT PRIMARY KEY,
  driverId INT NOT NULL,
  date DATE NOT NULL,
  restStart DATETIME NOT NULL,
  restEnd DATETIME NOT NULL,
  durationMinutes INT,
  isCompliant BOOLEAN, -- >= 30 phút
  FOREIGN KEY (driverId) REFERENCES Drivers(driverId)
);
```

**Impact:** Có thể tính từ TripDrivers, nhưng không cache được

---

### ⚠️ Gap 6: Expense Request với Upload
**Yêu cầu:** Upload chứng từ cho chi phí

**Hiện tại:** Invoices có cột `img VARCHAR(255)` ✅

**Thiếu:** Hỗ trợ nhiều file đính kèm
```sql
CREATE TABLE ExpenseAttachments (
  attachmentId INT AUTO_INCREMENT PRIMARY KEY,
  invoiceId INT NOT NULL,
  fileName VARCHAR(255),
  filePath VARCHAR(500),
  fileType VARCHAR(50),
  fileSize BIGINT,
  uploadedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (invoiceId) REFERENCES Invoices(invoiceId)
);
```

**Impact:** Chỉ lưu được 1 ảnh/invoice, không đủ cho nhiều chứng từ

---

### ⚠️ Gap 7: Trip Status Transitions
**Yêu cầu:** PENDING → ASSIGNED → IN_PROGRESS → COMPLETED

**Hiện tại:** 
- Trips có status: SCHEDULED, ONGOING, COMPLETED, CANCELLED
- Bookings có status: PENDING, QUOTATION_SENT, CONFIRMED, IN_PROGRESS, COMPLETED, CANCELLED

**Vấn đề:** Không có trạng thái "ASSIGNED" riêng cho Trip

**Đề xuất:** Thêm status vào Trips
```sql
ALTER TABLE Trips 
MODIFY status ENUM('PENDING','ASSIGNED','IN_PROGRESS','COMPLETED','CANCELLED') 
DEFAULT 'PENDING';
```

---

### ⚠️ Gap 8: Deposit Approval Tracking
**Yêu cầu:** Chỉ hiển thị chuyến "đã xác nhận & cọc đã duyệt/miễn"

**Hiện tại:** 
- Invoices có `isDeposit`, `paymentStatus`, `approvedBy`
- Bookings có `depositAmount`

**Thiếu:** Cột đánh dấu "miễn cọc"
```sql
ALTER TABLE Bookings 
ADD COLUMN depositWaived BOOLEAN DEFAULT FALSE,
ADD COLUMN depositWaivedBy INT,
ADD COLUMN depositWaivedReason VARCHAR(255),
ADD FOREIGN KEY (depositWaivedBy) REFERENCES Employees(employeeId);
```

---

## 📊 TỔNG KẾT GAP ANALYSIS

### 🔴 CRITICAL (Phải có ngay):
1. ✅ **DriverShifts / VehicleShifts** - Để tính %Util
2. ✅ **VehicleMaintenance** - Để tránh gán xe đang bảo trì
3. ✅ **ScheduleConflicts** - Cache xung đột
4. ✅ **Trip status ASSIGNED** - Workflow đúng

### 🟡 IMPORTANT (Nên có):
5. ⚠️ **DriverRestPeriods** - Cache thời gian nghỉ
6. ⚠️ **ExpenseAttachments** - Nhiều chứng từ
7. ⚠️ **Deposit waived tracking** - Miễn cọc

### 🟢 NICE TO HAVE (Có thể dùng workaround):
8. ⚠️ **ApprovalRequests** - Có thể dùng DriverDayOff + Invoices

---

## ✅ KẾT LUẬN

### Database hiện tại đã có:
- ✅ 70% chức năng cốt lõi
- ✅ Audit log (TripAssignmentHistory)
- ✅ Rating system (TripRatings)
- ✅ Fairness algorithm (DriverWorkload)
- ✅ Incident tracking (TripIncidents)

### Cần bổ sung ngay (CRITICAL):
1. **DriverShifts** - Ca làm việc tài xế
2. **VehicleShifts** - Ca hoạt động xe
3. **VehicleMaintenance** - Lịch bảo trì
4. **ScheduleConflicts** - Xung đột lịch
5. **ALTER Trips.status** - Thêm ASSIGNED, PENDING

### Có thể implement sau:
- DriverRestPeriods (tính từ TripDrivers)
- ExpenseAttachments (dùng Invoices.img trước)
- Deposit waived (dùng note trong Bookings)

---

## 🚀 HÀNH ĐỘNG TIẾP THEO

Tạo file **10_MODULE5_CRITICAL_ADDITIONS.sql** với:
1. DriverShifts
2. VehicleShifts  
3. VehicleMaintenance
4. ScheduleConflicts
5. ALTER Trips status
6. Deposit waived columns

Sau đó database sẽ đủ 95% cho Module 5! 🎯
