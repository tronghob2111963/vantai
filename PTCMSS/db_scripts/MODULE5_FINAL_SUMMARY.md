# ✅ MODULE 5 - HOÀN THÀNH 100% DATABASE

## 🎉 TỔNG KẾT

Database **PTCMSS** giờ đã **ĐẦY ĐỦ 100%** cho Module 5: Quản lý lịch trình & điều phối!

---

## 📊 DANH SÁCH BẢNG ĐẦY ĐỦ (15 bảng)

### ✅ Bảng cốt lõi (Core - 4 bảng)
1. **Trips** - Chuyến đi (đã update status: PENDING/ASSIGNED/IN_PROGRESS/COMPLETED/CANCELLED)
2. **TripDrivers** - Phân công tài xế
3. **TripVehicles** - Phân công xe
4. **Bookings** - Đơn đặt xe (đã thêm depositWaived, depositWaivedBy, depositWaivedReason, depositWaivedAt)

### ✅ Module 5 - Audit & Performance (4 bảng)
5. **TripAssignmentHistory** - Lịch sử phân công (Audit log)
6. **TripRatings** - Đánh giá tài xế
7. **DriverWorkload** - Workload & Fairness score
8. **TripIncidents** - Báo cáo sự cố

### ✅ Module 5 - Schedule & Availability (5 bảng)
9. **DriverShifts** - Ca làm việc tài xế
10. **VehicleShifts** - Ca hoạt động xe
11. **VehicleMaintenance** - Lịch bảo trì xe
12. **ScheduleConflicts** - Phát hiện xung đột lịch
13. **DriverRestPeriods** - Theo dõi thời gian nghỉ

### ✅ Module 5 - Expense Management (2 bảng)
14. **Invoices** - Hóa đơn (đã có sẵn, dùng cho Expense Request)
15. **ExpenseAttachments** - Đính kèm chứng từ chi phí

---

## 📈 VIEWS ĐẦY ĐỦ (7 views)

1. **v_DriverMonthlyPerformance** - Hiệu suất tháng
2. **v_DriverRatingsSummary** - Tổng hợp rating
3. **v_DriverWorkloadSummary** - Tổng hợp workload 7 ngày
4. **v_DriverAvailability** - Tính %Util theo ca làm việc ✨ NEW
5. **v_VehicleAvailability** - Xe khả dụng + bảo trì ✨ NEW
6. **v_PendingTrips** - Chuyến chờ gán (có deposit status) ✨ NEW
7. **v_ActiveConflicts** - Xung đột chưa xử lý ✨ NEW

---

## 🎯 ÁNH XẠ YÊU CẦU → DATABASE

### 1️⃣ Dispatcher Dashboard

#### ✅ Queue / Pending Trips
**Yêu cầu:**
- Chỉ hiển thị chuyến đã duyệt cọc/miễn cọc
- Chưa gán driver/vehicle
- Thời gian khởi hành trong ngày

**Database:**
```sql
SELECT * FROM v_PendingTrips
WHERE branchId = ?
  AND DATE(startTime) = CURDATE()
  AND depositStatus IN ('APPROVED', 'WAIVED')
  AND needsAssignment = TRUE;
```

**Bảng liên quan:**
- ✅ Trips (status = 'PENDING')
- ✅ Bookings (depositWaived, depositWaivedBy)
- ✅ Invoices (isDeposit, paymentStatus, approvedBy)
- ✅ v_PendingTrips (view tổng hợp)

---

#### ✅ Schedule Board (Driver–Vehicle Availability)
**Yêu cầu:**
- Timeline với %Util
- Hiển thị SHIFT, BUSY, MAINT, LEAVE
- Tính overlap, thiếu nghỉ

**Database:**
```sql
-- Driver Availability với %Util
SELECT * FROM v_DriverAvailability
WHERE date = CURDATE() AND branchId = ?;

-- Vehicle Availability với Maintenance
SELECT * FROM v_VehicleAvailability
WHERE date = CURDATE() AND branchId = ?;

-- Conflicts (overlap, insufficient rest)
SELECT * FROM v_ActiveConflicts
WHERE DATE(conflictTime) = CURDATE();
```

**Bảng liên quan:**
- ✅ DriverShifts (ca làm việc)
- ✅ VehicleShifts (ca hoạt động)
- ✅ DriverWorkload (totalMinutes → tính %Util)
- ✅ VehicleMaintenance (MAINT blocks)
- ✅ DriverDayOff (LEAVE blocks)
- ✅ ScheduleConflicts (overlap detection)
- ✅ DriverRestPeriods (insufficient rest)

---

### 2️⃣ Assign Driver & Vehicle

#### ✅ Auto-Assign (Fairness Algorithm)
**Yêu cầu:**
- Lọc ứng viên hợp lệ
- Tính điểm công bằng (fairness score)
- Chọn cặp có điểm thấp nhất

**Database:**
```sql
-- Lấy fairness score
SELECT driverId, fairnessScore 
FROM DriverWorkload
WHERE date = CURDATE()
ORDER BY fairnessScore ASC;

-- Kiểm tra hợp lệ
SELECT d.* FROM Drivers d
JOIN DriverShifts ds ON d.driverId = ds.driverId
WHERE d.branchId = ?
  AND d.status = 'AVAILABLE'
  AND ds.date = ?
  AND NOT EXISTS (
    SELECT 1 FROM TripDrivers td
    JOIN Trips t ON td.tripId = t.tripId
    WHERE td.driverId = d.driverId
    AND t.startTime BETWEEN ? AND ?
  );
```

**Bảng liên quan:**
- ✅ DriverWorkload (fairnessScore)
- ✅ Drivers (status, branchId, license)
- ✅ DriverShifts (ca làm việc)
- ✅ DriverDayOff (nghỉ phép)
- ✅ TripDrivers (kiểm tra trùng giờ)

---

#### ✅ Manual Select & Assignment History
**Yêu cầu:**
- Ghi log mọi thao tác Assign/Reassign/Unassign
- Lưu lý do, người thực hiện

**Database:**
```sql
-- Insert assignment
INSERT INTO TripDrivers (tripId, driverId, ...) VALUES (...);
INSERT INTO TripVehicles (tripId, vehicleId, ...) VALUES (...);

-- Log history
INSERT INTO TripAssignmentHistory 
(tripId, action, driverId, vehicleId, reason, performedBy)
VALUES (?, 'ASSIGN', ?, ?, ?, ?);

-- Update trip status
UPDATE Trips SET status = 'ASSIGNED' WHERE tripId = ?;
```

**Bảng liên quan:**
- ✅ TripAssignmentHistory (audit log)
- ✅ TripDrivers (phân công)
- ✅ TripVehicles (phân công)
- ✅ Trips (status update)

---

### 3️⃣ Edit Assignment / Reassign & Unassign

**Yêu cầu:**
- Thay đổi phân công
- Bắt buộc ghi lý do
- Không cho sửa khi IN_PROGRESS/COMPLETED

**Database:**
```sql
-- Reassign
UPDATE TripDrivers SET driverId = ? WHERE tripId = ?;

-- Log reassignment
INSERT INTO TripAssignmentHistory 
(tripId, action, driverId, previousDriverId, reason, performedBy)
VALUES (?, 'REASSIGN', ?, ?, ?, ?);

-- Unassign
DELETE FROM TripDrivers WHERE tripId = ?;
UPDATE Trips SET status = 'PENDING' WHERE tripId = ?;

-- Log unassignment
INSERT INTO TripAssignmentHistory 
(tripId, action, previousDriverId, reason, performedBy)
VALUES (?, 'UNASSIGN', ?, ?, ?);
```

**Bảng liên quan:**
- ✅ TripAssignmentHistory (log REASSIGN/UNASSIGN)
- ✅ TripDrivers (update/delete)
- ✅ Trips (status check & update)

---

### 4️⃣ View Trips & Trip Detail

**Yêu cầu:**
- Danh sách chuyến với filter
- Chi tiết chuyến + timeline
- Cảnh báo xung đột

**Database:**
```sql
-- List trips
SELECT t.*, d.licenseNumber, v.licensePlate
FROM Trips t
LEFT JOIN TripDrivers td ON t.tripId = td.tripId
LEFT JOIN Drivers d ON td.driverId = d.driverId
LEFT JOIN TripVehicles tv ON t.tripId = tv.tripId
LEFT JOIN Vehicles v ON tv.vehicleId = v.vehicleId
WHERE t.branchId = ? AND DATE(t.startTime) = ?;

-- Trip detail với history
SELECT * FROM TripAssignmentHistory
WHERE tripId = ?
ORDER BY createdAt DESC;

-- Conflicts liên quan
SELECT * FROM ScheduleConflicts
WHERE tripId1 = ? OR tripId2 = ?;
```

**Bảng liên quan:**
- ✅ Trips (danh sách)
- ✅ TripDrivers, TripVehicles (phân công)
- ✅ TripAssignmentHistory (lịch sử)
- ✅ ScheduleConflicts (cảnh báo)

---

### 5️⃣ Notifications & Approvals

**Yêu cầu:**
- Cảnh báo: license, đăng kiểm, xung đột, giờ lái
- Chờ duyệt: nghỉ phép, yêu cầu giảm giá

**Database:**
```sql
-- Cảnh báo license sắp hết hạn
SELECT * FROM Drivers
WHERE licenseExpiry <= DATE_ADD(CURDATE(), INTERVAL 30 DAY);

-- Cảnh báo đăng kiểm
SELECT * FROM Vehicles
WHERE inspectionExpiry <= DATE_ADD(CURDATE(), INTERVAL 30 DAY);

-- Xung đột chưa xử lý
SELECT * FROM v_ActiveConflicts;

-- Nghỉ phép chờ duyệt
SELECT * FROM DriverDayOff
WHERE status = 'PENDING';

-- Chi phí chờ duyệt
SELECT * FROM Invoices
WHERE type = 'Expense' AND approvedBy IS NULL;
```

**Bảng liên quan:**
- ✅ Drivers (licenseExpiry, healthCheckDate)
- ✅ Vehicles (inspectionExpiry, insuranceExpiry)
- ✅ ScheduleConflicts (xung đột)
- ✅ DriverDayOff (nghỉ phép)
- ✅ Invoices (chi phí)
- ✅ Notifications (thông báo)

---

### 6️⃣ Expense Request

**Yêu cầu:**
- Form chi phí vận hành
- Upload chứng từ
- Workflow duyệt

**Database:**
```sql
-- Tạo expense request
INSERT INTO Invoices 
(branchId, type, costType, amount, note, requestedBy, createdBy)
VALUES (?, 'Expense', ?, ?, ?, ?, ?);

-- Upload attachments
INSERT INTO ExpenseAttachments 
(invoiceId, fileName, filePath, fileType, fileSize, uploadedBy)
VALUES (?, ?, ?, ?, ?, ?);

-- Approve expense
UPDATE Invoices 
SET approvedBy = ?, approvedAt = NOW(), paymentStatus = 'PAID'
WHERE invoiceId = ?;
```

**Bảng liên quan:**
- ✅ Invoices (type = 'Expense')
- ✅ ExpenseAttachments (nhiều file đính kèm)

---

### 7️⃣ Driver Rating & Performance

**Yêu cầu:**
- Đánh giá sau chuyến COMPLETED
- Tổng hợp 30 ngày gần nhất

**Database:**
```sql
-- Insert rating
INSERT INTO TripRatings 
(tripId, driverId, rating, comment, ratedBy)
VALUES (?, ?, ?, ?, ?);

-- Update driver average rating
UPDATE Drivers d
SET 
  averageRating = (SELECT AVG(rating) FROM TripRatings WHERE driverId = d.driverId),
  totalRatings = (SELECT COUNT(*) FROM TripRatings WHERE driverId = d.driverId)
WHERE driverId = ?;

-- View ratings summary
SELECT * FROM v_DriverRatingsSummary WHERE driverId = ?;
```

**Bảng liên quan:**
- ✅ TripRatings (đánh giá)
- ✅ Drivers (averageRating, totalRatings)
- ✅ v_DriverRatingsSummary (tổng hợp 30 ngày)

---

## 🚀 FILES QUAN TRỌNG

### 1. **00_full_setup.sql** (FILE CHÍNH)
- ✅ Tất cả 15 bảng
- ✅ Tất cả 7 views
- ✅ Triggers, indexes
- ✅ Sample data đầy đủ
- **Dùng cho:** Fresh install

### 2. **10_MODULE5_CRITICAL_ADDITIONS.sql**
- ✅ 6 bảng critical mới
- ✅ 4 views mới
- ✅ ALTER Trips status
- ✅ ALTER Bookings deposit waived
- **Dùng cho:** Update database hiện có

### 3. **08_MODULE5_ADDITIONS.sql**
- ✅ 4 bảng đầu tiên (History, Ratings, Workload, Incidents)
- **Dùng cho:** Bổ sung cơ bản

### 4. **MODULE5_COMPLETE_GAP_ANALYSIS.md**
- ✅ Phân tích chi tiết gap
- ✅ So sánh yêu cầu vs database
- **Dùng cho:** Hiểu rõ thiết kế

### 5. **MODULE5_ERD.md**
- ✅ Sơ đồ quan hệ
- ✅ Data flow
- **Dùng cho:** Visualize cấu trúc

---

## ✅ CHECKLIST HOÀN THÀNH

### Dispatcher Dashboard
- ✅ Queue/Pending Trips → v_PendingTrips
- ✅ Schedule Board → DriverShifts, VehicleShifts
- ✅ %Util calculation → v_DriverAvailability
- ✅ BUSY/MAINT/LEAVE → DriverWorkload, VehicleMaintenance, DriverDayOff
- ✅ Overlap detection → ScheduleConflicts
- ✅ Insufficient rest → DriverRestPeriods

### Assign & Reassign
- ✅ Auto-assign fairness → DriverWorkload.fairnessScore
- ✅ Manual select → TripDrivers, TripVehicles
- ✅ Assignment history → TripAssignmentHistory
- ✅ Reason tracking → TripAssignmentHistory.reason

### Trip Management
- ✅ Trip status workflow → Trips.status (PENDING/ASSIGNED/IN_PROGRESS/COMPLETED/CANCELLED)
- ✅ View trips → Trips + filters
- ✅ Trip detail → TripAssignmentHistory
- ✅ Conflict warnings → ScheduleConflicts

### Notifications & Approvals
- ✅ License expiry → Drivers.licenseExpiry
- ✅ Inspection expiry → Vehicles.inspectionExpiry
- ✅ Conflict alerts → ScheduleConflicts
- ✅ Day off approval → DriverDayOff.status
- ✅ Expense approval → Invoices.approvedBy

### Expense Management
- ✅ Expense request → Invoices (type='Expense')
- ✅ Multiple attachments → ExpenseAttachments
- ✅ Approval workflow → Invoices.approvedBy, approvedAt

### Driver Performance
- ✅ Trip ratings → TripRatings
- ✅ Average rating → Drivers.averageRating
- ✅ 30-day summary → v_DriverRatingsSummary

### Deposit Management
- ✅ Deposit approval → Invoices.isDeposit, approvedBy
- ✅ Deposit waived → Bookings.depositWaived, depositWaivedBy
- ✅ Deposit status → v_PendingTrips.depositStatus

---

## 🎯 KẾT LUẬN

### ✅ Database đã đầy đủ 100% cho Module 5!

**Tổng số:**
- 15 bảng (4 core + 4 audit + 5 schedule + 2 expense)
- 7 views (3 cũ + 4 mới)
- 2 triggers
- 50+ indexes
- Sample data đầy đủ

**Có thể implement ngay:**
1. ✅ Dispatcher Dashboard (100%)
2. ✅ Auto-assign với fairness (100%)
3. ✅ Schedule Board với %Util (100%)
4. ✅ Conflict detection (100%)
5. ✅ Assignment history (100%)
6. ✅ Driver rating (100%)
7. ✅ Expense management (100%)
8. ✅ Notifications & Approvals (100%)

**Next steps:**
1. Chạy `00_full_setup.sql` (fresh install) hoặc `10_MODULE5_CRITICAL_ADDITIONS.sql` (update)
2. Implement Entity classes (Java)
3. Implement Repository interfaces
4. Implement Service layer
5. Implement Controller endpoints
6. Implement Frontend components

---

**🎉 MODULE 5 DATABASE - HOÀN THÀNH 100%! 🎉**

*Tác giả: PTCMSS Development Team*  
*Ngày hoàn thành: 2025-11-19*  
*Version: 3.0 - Module 5 Complete*
