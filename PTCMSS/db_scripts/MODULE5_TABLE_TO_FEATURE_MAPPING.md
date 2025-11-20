# 🗺️ ÁNH XẠ BẢNG → CHỨC NĂNG MODULE 5

## 📋 DANH SÁCH CHỨC NĂNG MODULE 5

Theo spec, Module 5 có **9 chức năng chính:**

1. **Queue / Pending Trips** - Danh sách chuyến chờ gán
2. **Schedule Board** - Bảng lịch trình tài xế/xe
3. **Assign Driver & Vehicle** - Gán tài xế và xe
4. **Edit Assignment** - Sửa/hủy phân công
5. **View Trips** - Danh sách chuyến
6. **View Trip Detail** - Chi tiết chuyến
7. **Notifications & Approvals** - Thông báo & duyệt
8. **Expense Request** - Yêu cầu chi phí
9. **Driver Rating** - Đánh giá tài xế

---

## 🎯 ÁNH XẠ CHI TIẾT

### 1️⃣ CHỨC NĂNG: Queue / Pending Trips

**Mô tả:** Hiển thị danh sách chuyến đã duyệt cọc/miễn cọc, chưa gán tài xế

**Bảng cần:**

#### ✅ Bookings (CẬP NHẬT - thêm 4 cột)
```sql
-- Thêm vào bảng Bookings:
depositWaived BOOLEAN DEFAULT FALSE
depositWaivedBy INT NULL
depositWaivedReason VARCHAR(255) NULL
depositWaivedAt DATETIME NULL
```

**Lý do:**
- Để biết booking nào được "miễn cọc"
- Spec yêu cầu: "Deposit: Đã duyệt hoặc Miễn"
- Không có 4 cột này → không biết chuyến nào miễn cọc

**Dùng ở đâu:**
```sql
-- Query pending trips
SELECT * FROM Trips t
JOIN Bookings b ON t.bookingId = b.bookingId
WHERE t.status = 'PENDING'
  AND (
    -- Đã duyệt cọc
    EXISTS (SELECT 1 FROM Invoices i 
            WHERE i.bookingId = b.bookingId 
            AND i.isDeposit = TRUE 
            AND i.approvedBy IS NOT NULL)
    OR
    -- Hoặc miễn cọc
    b.depositWaived = TRUE
  );
```

---

#### ✅ Trips (CẬP NHẬT - thay đổi status)
```sql
-- Cũ:
status ENUM('SCHEDULED','ONGOING','COMPLETED','CANCELLED')

-- Mới:
status ENUM('PENDING','ASSIGNED','IN_PROGRESS','COMPLETED','CANCELLED')
```

**Lý do:**
- Cần status 'PENDING' để lọc chuyến chưa gán
- Cần status 'ASSIGNED' để biết đã gán nhưng chưa khởi hành
- Spec yêu cầu: "Trip: PENDING → ASSIGNED → IN_PROGRESS → COMPLETED"

**Dùng ở đâu:**
```sql
-- Lọc chuyến chờ gán
SELECT * FROM Trips WHERE status = 'PENDING';

-- Lọc chuyến đã gán
SELECT * FROM Trips WHERE status = 'ASSIGNED';
```

---

### 2️⃣ CHỨC NĂNG: Schedule Board (Driver-Vehicle Availability)

**Mô tả:** Timeline hiển thị SHIFT, BUSY, MAINT, LEAVE với %Util

**Bảng cần:**

#### ⭐ DriverShifts (BẢNG MỚI)
```sql
CREATE TABLE DriverShifts (
  shiftId INT PRIMARY KEY,
  driverId INT NOT NULL,
  date DATE NOT NULL,
  shiftStart TIME NOT NULL,
  shiftEnd TIME NOT NULL,
  breakStart TIME NULL,
  breakEnd TIME NULL,
  status ENUM('SCHEDULED','ACTIVE','COMPLETED','CANCELLED')
);
```

**Lý do:**
- Để hiển thị **SHIFT blocks** (dải ca làm việc)
- Để tính **%Util = (BUSY minutes) / (SHIFT minutes)**
- Spec yêu cầu: "SHIFT: dải ca làm. %Util = (tổng phút BUSY trong ca) / (tổng phút ca)"

**Không có bảng này:**
- ❌ Không biết tài xế làm ca nào (8h-17h? 13h-22h?)
- ❌ Không tính được %Util (không biết mẫu số)
- ❌ Schedule Board không hoạt động!

**Dùng ở đâu:**
```sql
-- Tính %Util
SELECT 
  d.driverId,
  ds.shiftStart,
  ds.shiftEnd,
  TIMESTAMPDIFF(MINUTE, ds.shiftStart, ds.shiftEnd) AS shiftMinutes,
  COALESCE(dw.totalMinutes, 0) AS busyMinutes,
  ROUND(busyMinutes * 100.0 / shiftMinutes, 2) AS utilizationPercent
FROM Drivers d
JOIN DriverShifts ds ON d.driverId = ds.driverId
LEFT JOIN DriverWorkload dw ON d.driverId = dw.driverId AND ds.date = dw.date
WHERE ds.date = CURDATE();
```

---

#### ⭐ VehicleShifts (BẢNG MỚI)
```sql
CREATE TABLE VehicleShifts (
  shiftId INT PRIMARY KEY,
  vehicleId INT NOT NULL,
  date DATE NOT NULL,
  shiftStart TIME NOT NULL,
  shiftEnd TIME NOT NULL,
  status ENUM('AVAILABLE','MAINTENANCE','INACTIVE')
);
```

**Lý do:**
- Tương tự DriverShifts nhưng cho xe
- Spec yêu cầu: "Toggle Driver / Vehicle"
- Biết xe nào available trong khung giờ nào

**Dùng ở đâu:**
```sql
-- Lọc xe available trong khung giờ
SELECT * FROM VehicleShifts
WHERE date = CURDATE()
  AND shiftStart <= '14:00:00'
  AND shiftEnd >= '18:00:00'
  AND status = 'AVAILABLE';
```

---

#### ⭐ VehicleMaintenance (BẢNG MỚI)
```sql
CREATE TABLE VehicleMaintenance (
  maintenanceId INT PRIMARY KEY,
  vehicleId INT NOT NULL,
  maintenanceType VARCHAR(50),
  scheduledStart DATETIME NOT NULL,
  scheduledEnd DATETIME NOT NULL,
  status ENUM('SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED')
);
```

**Lý do:**
- Để hiển thị **MAINT blocks** (khối bảo trì)
- Để tránh gán xe đang bảo trì
- Spec yêu cầu: "MAINT: khối thời gian bảo trì"

**Không có bảng này:**
- ❌ Không biết xe bảo trì từ khi nào đến khi nào
- ❌ Có thể gán nhầm xe đang sửa
- ❌ Không hiển thị được MAINT blocks

**Dùng ở đâu:**
```sql
-- Kiểm tra xe có đang bảo trì không
SELECT * FROM VehicleMaintenance
WHERE vehicleId = 5
  AND status IN ('SCHEDULED','IN_PROGRESS')
  AND CURDATE() BETWEEN DATE(scheduledStart) AND DATE(scheduledEnd);
```

---

#### ⭐ DriverWorkload (BẢNG MỚI)
```sql
CREATE TABLE DriverWorkload (
  workloadId INT PRIMARY KEY,
  driverId INT NOT NULL,
  date DATE NOT NULL,
  totalMinutes INT DEFAULT 0,
  tripCount INT DEFAULT 0,
  fairnessScore DECIMAL(5,2) DEFAULT 0
);
```

**Lý do:**
- Cache **BUSY minutes** (tổng phút chạy chuyến)
- Tính **%Util** nhanh
- Dùng cho **fairness algorithm** (chức năng 3)

**Không có bảng này:**
- ⚠️ Phải tính BUSY minutes realtime mỗi lần (chậm)
- ⚠️ Query phức tạp: JOIN TripDrivers + Trips + SUM

**Dùng ở đâu:**
```sql
-- Lấy BUSY minutes đã cache
SELECT totalMinutes FROM DriverWorkload
WHERE driverId = 1 AND date = CURDATE();

-- Thay vì phải tính:
SELECT SUM(TIMESTAMPDIFF(MINUTE, td.startTime, td.endTime))
FROM TripDrivers td
JOIN Trips t ON td.tripId = t.tripId
WHERE td.driverId = 1 AND DATE(t.startTime) = CURDATE();
```

---

### 3️⃣ CHỨC NĂNG: Assign Driver & Vehicle (Auto-Assign)

**Mô tả:** Tự động gán tài xế dựa trên fairness score

**Bảng cần:**

#### ⭐ DriverWorkload (BẢNG MỚI) - Đã mô tả ở trên
```sql
-- Cột quan trọng:
fairnessScore DECIMAL(5,2) DEFAULT 0
```

**Lý do:**
- Cache **fairness score** để auto-assign nhanh
- Spec yêu cầu: "Auto-Assign: tính điểm công bằng (fairness); chọn cặp có điểm thấp nhất"

**Công thức fairness:**
```
fairnessScore = 
  (giờ làm hôm nay * 0.4) + 
  (số chuyến tuần này * 0.3) + 
  (thời gian nghỉ * 0.3)
```

**Không có bảng này:**
- ❌ Phải tính fairness realtime mỗi lần assign (3-5 giây)
- ❌ Query cực kỳ phức tạp (JOIN nhiều bảng, tính SUM, AVG...)

**Dùng ở đâu:**
```sql
-- Auto-assign: Chọn tài xế có fairness thấp nhất
SELECT driverId, fairnessScore
FROM DriverWorkload
WHERE date = CURDATE()
  AND driverId IN (/* danh sách hợp lệ */)
ORDER BY fairnessScore ASC
LIMIT 1;
```

---

### 4️⃣ CHỨC NĂNG: Edit Assignment (Reassign/Unassign)

**Mô tả:** Sửa/hủy phân công và ghi log

**Bảng cần:**

#### ⭐ TripAssignmentHistory (BẢNG MỚI)
```sql
CREATE TABLE TripAssignmentHistory (
  historyId INT PRIMARY KEY,
  tripId INT NOT NULL,
  action ENUM('ASSIGN','REASSIGN','UNASSIGN','CANCEL'),
  driverId INT NULL,
  vehicleId INT NULL,
  previousDriverId INT NULL,
  previousVehicleId INT NULL,
  reason VARCHAR(500),
  performedBy INT NOT NULL,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Lý do:**
- Ghi log **mọi thao tác** Assign/Reassign/Unassign
- Spec yêu cầu: "Audit: Mọi thao tác Assign/Reassign/Unassign/Cancel đều ghi log"
- Compliance & traceability

**Không có bảng này:**
- ❌ Không biết ai đã gán/đổi tài xế
- ❌ Không biết lý do reassign
- ❌ Không có audit trail (vi phạm compliance)

**Dùng ở đâu:**
```sql
-- Xem lịch sử phân công
SELECT * FROM TripAssignmentHistory
WHERE tripId = 123
ORDER BY createdAt DESC;

-- Log khi reassign
INSERT INTO TripAssignmentHistory 
(tripId, action, driverId, previousDriverId, reason, performedBy)
VALUES (123, 'REASSIGN', 5, 3, 'Tài xế cũ bị ốm', 2);
```

---

### 5️⃣ & 6️⃣ CHỨC NĂNG: View Trips & View Trip Detail

**Mô tả:** Xem danh sách và chi tiết chuyến

**Bảng cần:**

#### ✅ TripAssignmentHistory (Đã mô tả ở trên)

**Dùng ở đâu:**
```sql
-- View Trip Detail: Hiển thị lịch sử phân công
SELECT 
  h.action,
  h.createdAt,
  u.fullName AS performedBy,
  h.reason
FROM TripAssignmentHistory h
JOIN Employees e ON h.performedBy = e.employeeId
JOIN Users u ON e.userId = u.userId
WHERE h.tripId = 123
ORDER BY h.createdAt DESC;
```

---

#### ⚠️ ScheduleConflicts (BẢNG MỚI - Optional)
```sql
CREATE TABLE ScheduleConflicts (
  conflictId INT PRIMARY KEY,
  conflictType ENUM('DRIVER_OVERLAP','VEHICLE_OVERLAP','INSUFFICIENT_REST'),
  driverId INT NULL,
  vehicleId INT NULL,
  tripId1 INT NULL,
  tripId2 INT NULL,
  conflictTime DATETIME,
  description VARCHAR(500),
  status ENUM('DETECTED','ACKNOWLEDGED','RESOLVED','IGNORED')
);
```

**Lý do:**
- Cache **conflicts** để hiển thị nhanh
- Spec yêu cầu: "Cảnh báo xung đột (nếu có)"

**Không có bảng này:**
- ⚠️ Phải tính conflict realtime (chậm hơn)
- ⚠️ Nhưng vẫn làm được bằng query

**Dùng ở đâu:**
```sql
-- View Trip Detail: Hiển thị conflicts
SELECT * FROM ScheduleConflicts
WHERE (tripId1 = 123 OR tripId2 = 123)
  AND status IN ('DETECTED','ACKNOWLEDGED');
```

---

### 7️⃣ CHỨC NĂNG: Notifications & Approvals

**Mô tả:** Cảnh báo license hết hạn, đăng kiểm, xung đột...

**Bảng cần:**

#### ✅ Drivers (ĐÃ CÓ)
```sql
-- Các cột cần:
licenseExpiry DATE
healthCheckDate DATE
```

**Dùng ở đâu:**
```sql
-- Cảnh báo license sắp hết hạn
SELECT * FROM Drivers
WHERE licenseExpiry <= DATE_ADD(CURDATE(), INTERVAL 30 DAY);
```

---

#### ✅ Vehicles (ĐÃ CÓ)
```sql
-- Các cột cần:
inspectionExpiry DATE
insuranceExpiry DATE
```

**Dùng ở đâu:**
```sql
-- Cảnh báo đăng kiểm sắp hết hạn
SELECT * FROM Vehicles
WHERE inspectionExpiry <= DATE_ADD(CURDATE(), INTERVAL 30 DAY);
```

---

#### ✅ DriverDayOff (ĐÃ CÓ)
```sql
-- Các cột cần:
status ENUM('PENDING','APPROVED','REJECTED')
approvedBy INT
```

**Dùng ở đâu:**
```sql
-- Danh sách nghỉ phép chờ duyệt
SELECT * FROM DriverDayOff
WHERE status = 'PENDING';
```

---

### 8️⃣ CHỨC NĂNG: Expense Request

**Mô tả:** Yêu cầu chi phí với upload chứng từ

**Bảng cần:**

#### ✅ Invoices (ĐÃ CÓ)
```sql
-- Các cột cần:
type ENUM('Income','Expense')
costType VARCHAR(50)
approvedBy INT
approvedAt DATETIME
```

**Dùng ở đâu:**
```sql
-- Tạo expense request
INSERT INTO Invoices (type, costType, amount, requestedBy)
VALUES ('Expense', 'fuel', 500000, 1);

-- Duyệt expense
UPDATE Invoices 
SET approvedBy = 2, approvedAt = NOW()
WHERE invoiceId = 10;
```

---

#### ⭐ ExpenseAttachments (BẢNG MỚI)
```sql
CREATE TABLE ExpenseAttachments (
  attachmentId INT PRIMARY KEY,
  invoiceId INT NOT NULL,
  fileName VARCHAR(255),
  filePath VARCHAR(500),
  fileType VARCHAR(50),
  fileSize BIGINT
);
```

**Lý do:**
- Upload **nhiều chứng từ** cho 1 expense
- Spec yêu cầu: "Upload chứng từ"

**Không có bảng này:**
- ⚠️ Invoices.img chỉ lưu được 1 ảnh
- ⚠️ Không đủ cho nhiều chứng từ

**Dùng ở đâu:**
```sql
-- Upload nhiều file
INSERT INTO ExpenseAttachments (invoiceId, fileName, filePath)
VALUES 
  (10, 'receipt1.jpg', '/uploads/receipt1.jpg'),
  (10, 'receipt2.pdf', '/uploads/receipt2.pdf');

-- Lấy danh sách attachments
SELECT * FROM ExpenseAttachments WHERE invoiceId = 10;
```

---

### 9️⃣ CHỨC NĂNG: Driver Rating & Performance

**Mô tả:** Đánh giá tài xế sau chuyến, tổng hợp 30 ngày

**Bảng cần:**

#### ⭐ TripRatings (BẢNG MỚI)
```sql
CREATE TABLE TripRatings (
  ratingId INT PRIMARY KEY,
  tripId INT NOT NULL,
  driverId INT NOT NULL,
  rating INT CHECK (rating BETWEEN 1 AND 5),
  comment VARCHAR(500),
  ratedBy INT NULL,
  ratedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Lý do:**
- Lưu **đánh giá** sau mỗi chuyến
- Spec yêu cầu: "Sau khi chuyến COMPLETED. Tiêu chí: sao 1–5 + comment"

**Không có bảng này:**
- ❌ Không lưu được đánh giá
- ❌ Không tính được average rating

**Dùng ở đâu:**
```sql
-- Đánh giá tài xế
INSERT INTO TripRatings (tripId, driverId, rating, comment, ratedBy)
VALUES (123, 5, 5, 'Tài xế lái xe tốt', 2);

-- Tính average rating
SELECT AVG(rating) FROM TripRatings
WHERE driverId = 5;
```

---

#### ✅ Drivers (CẬP NHẬT - thêm 2 cột)
```sql
-- Thêm vào bảng Drivers:
averageRating DECIMAL(3,2) DEFAULT 5.00
totalRatings INT DEFAULT 0
```

**Lý do:**
- Cache **average rating** để query nhanh
- Không cần JOIN TripRatings mỗi lần

**Dùng ở đâu:**
```sql
-- Lấy rating nhanh
SELECT averageRating FROM Drivers WHERE driverId = 5;

-- Thay vì:
SELECT AVG(rating) FROM TripRatings WHERE driverId = 5;
```

---

## 📊 BẢNG TỔNG HỢP

| Bảng | Loại | Chức năng sử dụng |
|------|------|-------------------|
| **Bookings** | CẬP NHẬT (+4 cột) | 1. Queue/Pending Trips |
| **Trips** | CẬP NHẬT (status) | 1. Queue/Pending Trips<br>5. View Trips |
| **Drivers** | CẬP NHẬT (+2 cột) | 9. Driver Rating |
| **DriverShifts** | MỚI | 2. Schedule Board |
| **VehicleShifts** | MỚI | 2. Schedule Board |
| **VehicleMaintenance** | MỚI | 2. Schedule Board |
| **DriverWorkload** | MỚI | 2. Schedule Board<br>3. Auto-Assign |
| **TripAssignmentHistory** | MỚI | 4. Edit Assignment<br>6. View Trip Detail |
| **ScheduleConflicts** | MỚI (Optional) | 6. View Trip Detail |
| **ExpenseAttachments** | MỚI | 8. Expense Request |
| **TripRatings** | MỚI | 9. Driver Rating |

---

## ❌ BẢNG KHÔNG DÙNG CHO CHỨC NĂNG NÀO

### DriverRestPeriods ❌
- **Không phục vụ chức năng cụ thể nào**
- Có thể tính từ TripDrivers
- → Đề xuất XÓA

### TripIncidents ❌
- **Không có trong 9 chức năng Module 5**
- Spec không yêu cầu
- → Đề xuất XÓA

---

## ✅ KẾT LUẬN

**Cần thiết: 8 bảng mới + 3 bảng cập nhật**

**Không cần: 2 bảng (DriverRestPeriods, TripIncidents)**

**Tổng: 27 bảng (thay vì 29)**

---

**Bây giờ rõ chưa bạn?** 😊
