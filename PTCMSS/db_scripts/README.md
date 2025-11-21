# 📚 PTCMSS DATABASE SCRIPTS - DOCUMENTATION

## 🎯 Tổng quan

Thư mục này chứa tất cả database scripts và documentation cho hệ thống **PTCMSS** (Passenger Transport Company Management System).

**Trạng thái hiện tại:** Database đã hoàn thành **100%** cho **Module 5: Quản lý lịch trình & điều phối**

---

## 📂 Cấu trúc Files

### 🗄️ SQL Scripts

#### 1. **00_full_setup.sql** ⭐ MAIN FILE
**Mục đích:** Script đầy đủ để setup database từ đầu

**Nội dung:**
- 15 bảng (4 core + 4 audit + 5 schedule + 2 expense)
- 7 views
- 2 triggers
- 50+ indexes
- Sample data đầy đủ

**Khi nào dùng:** Fresh install hoặc reset database

**Cách chạy:**
```bash
mysql -u root -p < 00_full_setup.sql
```

---

#### 2. **08_MODULE5_ADDITIONS.sql**
**Mục đích:** Bổ sung 4 bảng đầu tiên cho Module 5

**Nội dung:**
- TripAssignmentHistory
- TripRatings
- DriverWorkload
- TripIncidents

**Khi nào dùng:** Update database hiện có (bước 1)

---

#### 3. **10_MODULE5_CRITICAL_ADDITIONS.sql** ⭐ UPDATE FILE
**Mục đích:** Bổ sung 6 bảng critical còn thiếu

**Nội dung:**
- DriverShifts
- VehicleShifts
- VehicleMaintenance
- ScheduleConflicts
- DriverRestPeriods
- ExpenseAttachments
- ALTER Trips status
- ALTER Bookings deposit waived
- 4 views mới

**Khi nào dùng:** Update database hiện có (bước 2 - QUAN TRỌNG)

**Cách chạy:**
```bash
# Backup trước!
mysqldump -u root -p ptcmss_db > backup.sql

# Chạy update
mysql -u root -p ptcmss_db < 10_MODULE5_CRITICAL_ADDITIONS.sql
```

---

#### 4. **07_UPDATE_BOOKING_STATUS_SIMPLE.sql**
**Mục đích:** Update booking status enum

**Khi nào dùng:** Nếu cần update status riêng

---

### 📖 Documentation Files

#### 1. **MODULE5_FINAL_SUMMARY.md** ⭐ ĐỌC ĐẦU TIÊN
**Nội dung:**
- Tổng kết 100% hoàn thành
- Danh sách 15 bảng + 7 views
- Ánh xạ yêu cầu → database
- Queries mẫu cho từng chức năng

**Đọc file này để:** Hiểu tổng quan toàn bộ Module 5

---

#### 2. **MODULE5_COMPLETE_GAP_ANALYSIS.md**
**Nội dung:**
- Phân tích chi tiết gap giữa yêu cầu và database
- Giải thích tại sao cần từng bảng
- Impact analysis

**Đọc file này để:** Hiểu lý do thiết kế

---

#### 3. **MODULE5_ERD.md**
**Nội dung:**
- Sơ đồ quan hệ (ERD)
- Data flow diagrams
- Indexes strategy

**Đọc file này để:** Visualize cấu trúc database

---

#### 4. **MODULE5_UPDATES_SUMMARY.md**
**Nội dung:**
- Chi tiết 4 bảng đầu tiên
- Use cases cụ thể
- Best practices

---

#### 5. **README_MODULE5.md**
**Nội dung:**
- Hướng dẫn cài đặt chi tiết
- Troubleshooting
- Queries hữu ích
- Next steps backend

---

#### 6. **QUICK_START_MODULE5.md**
**Nội dung:**
- Quick reference
- Cài đặt nhanh
- Kiểm tra nhanh

**Đọc file này để:** Bắt đầu nhanh

---

#### 7. **IMPLEMENTATION_CHECKLIST.md** ⭐ CHO DEVELOPERS
**Nội dung:**
- Checklist đầy đủ cho backend (0/48 tasks)
- Checklist đầy đủ cho frontend (0/20 components)
- Checklist testing (0/55 tests)
- Roadmap 6 tuần

**Đọc file này để:** Lập kế hoạch implement

---

## 🚀 QUICK START

### Scenario 1: Cài đặt mới (Fresh Install)

```bash
# 1. Tạo database
mysql -u root -p < 00_full_setup.sql

# 2. Kiểm tra
mysql -u root -p ptcmss_db
mysql> SHOW TABLES;
mysql> SELECT COUNT(*) FROM TripAssignmentHistory;
```

**Kết quả mong đợi:**
- 25+ bảng
- 7 views
- Sample data đầy đủ

---

### Scenario 2: Cập nhật database hiện có

```bash
# 1. Backup (QUAN TRỌNG!)
mysqldump -u root -p ptcmss_db > backup_$(date +%Y%m%d).sql

# 2. Chạy update Module 5 (nếu chưa có 4 bảng đầu)
mysql -u root -p ptcmss_db < 08_MODULE5_ADDITIONS.sql

# 3. Chạy critical additions (6 bảng còn lại)
mysql -u root -p ptcmss_db < 10_MODULE5_CRITICAL_ADDITIONS.sql

# 4. Kiểm tra
mysql -u root -p ptcmss_db
mysql> SELECT * FROM v_PendingTrips LIMIT 5;
mysql> SELECT * FROM v_DriverAvailability WHERE date = CURDATE();
```

---

### Scenario 3: Kiểm tra database hiện tại

```sql
-- Kiểm tra bảng Module 5
SHOW TABLES LIKE 'Trip%';
SHOW TABLES LIKE 'Driver%';
SHOW TABLES LIKE 'Vehicle%';
SHOW TABLES LIKE 'Schedule%';

-- Kiểm tra views
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Kiểm tra Trips status
DESCRIBE Trips;
-- Phải có: ENUM('PENDING','ASSIGNED','IN_PROGRESS','COMPLETED','CANCELLED')

-- Kiểm tra Bookings deposit waived
DESCRIBE Bookings;
-- Phải có: depositWaived, depositWaivedBy, depositWaivedReason, depositWaivedAt
```

---

## 📊 DATABASE SCHEMA OVERVIEW

### Core Tables (4)
1. **Trips** - Chuyến đi
2. **TripDrivers** - Phân công tài xế
3. **TripVehicles** - Phân công xe
4. **Bookings** - Đơn đặt xe

### Module 5 - Audit & Performance (4)
5. **TripAssignmentHistory** - Lịch sử phân công
6. **TripRatings** - Đánh giá tài xế
7. **DriverWorkload** - Workload & Fairness
8. **TripIncidents** - Báo cáo sự cố

### Module 5 - Schedule & Availability (5)
9. **DriverShifts** - Ca làm việc tài xế
10. **VehicleShifts** - Ca hoạt động xe
11. **VehicleMaintenance** - Lịch bảo trì
12. **ScheduleConflicts** - Xung đột lịch
13. **DriverRestPeriods** - Thời gian nghỉ

### Module 5 - Expense (2)
14. **Invoices** - Hóa đơn
15. **ExpenseAttachments** - Chứng từ

### Views (7)
1. v_DriverMonthlyPerformance
2. v_DriverRatingsSummary
3. v_DriverWorkloadSummary
4. v_DriverAvailability ⭐ NEW
5. v_VehicleAvailability ⭐ NEW
6. v_PendingTrips ⭐ NEW
7. v_ActiveConflicts ⭐ NEW

---

## 🎯 USE CASES & QUERIES

### 1. Lấy danh sách chuyến chờ gán

```sql
SELECT * FROM v_PendingTrips
WHERE branchId = 1
  AND DATE(startTime) = CURDATE()
  AND depositStatus IN ('APPROVED', 'WAIVED')
  AND needsAssignment = TRUE;
```

### 2. Tính %Util của tài xế

```sql
SELECT 
  driverName,
  shiftMinutes,
  busyMinutes,
  utilizationPercent
FROM v_DriverAvailability
WHERE date = CURDATE() AND branchId = 1
ORDER BY utilizationPercent DESC;
```

### 3. Tìm tài xế khả dụng cho auto-assign

```sql
SELECT d.driverId, u.fullName, dw.fairnessScore
FROM Drivers d
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
LEFT JOIN DriverWorkload dw ON d.driverId = dw.driverId AND dw.date = CURDATE()
WHERE d.branchId = 1
  AND d.status = 'AVAILABLE'
  AND NOT EXISTS (
    SELECT 1 FROM DriverDayOff ddo
    WHERE ddo.driverId = d.driverId
    AND CURDATE() BETWEEN ddo.startDate AND ddo.endDate
    AND ddo.status = 'APPROVED'
  )
  AND NOT EXISTS (
    SELECT 1 FROM TripDrivers td
    JOIN Trips t ON td.tripId = t.tripId
    WHERE td.driverId = d.driverId
    AND t.startTime BETWEEN '2025-11-19 08:00:00' AND '2025-11-19 12:00:00'
  )
ORDER BY COALESCE(dw.fairnessScore, 0) ASC
LIMIT 5;
```

### 4. Phát hiện xung đột

```sql
-- Xung đột chưa xử lý
SELECT * FROM v_ActiveConflicts
WHERE DATE(conflictTime) = CURDATE();

-- Tài xế có 2 chuyến trùng giờ
SELECT 
  td1.driverId,
  t1.tripId AS trip1,
  t1.startTime AS start1,
  t1.endTime AS end1,
  t2.tripId AS trip2,
  t2.startTime AS start2,
  t2.endTime AS end2
FROM TripDrivers td1
JOIN Trips t1 ON td1.tripId = t1.tripId
JOIN TripDrivers td2 ON td1.driverId = td2.driverId AND td1.tripId < td2.tripId
JOIN Trips t2 ON td2.tripId = t2.tripId
WHERE t1.startTime < t2.endTime AND t2.startTime < t1.endTime
  AND t1.status NOT IN ('CANCELLED', 'COMPLETED')
  AND t2.status NOT IN ('CANCELLED', 'COMPLETED');
```

### 5. Gán chuyến và log history

```sql
START TRANSACTION;

-- 1. Gán tài xế
INSERT INTO TripDrivers (tripId, driverId, driverRole)
VALUES (10, 1, 'Main Driver');

-- 2. Gán xe
INSERT INTO TripVehicles (tripId, vehicleId)
VALUES (10, 3);

-- 3. Update trip status
UPDATE Trips SET status = 'ASSIGNED' WHERE tripId = 10;

-- 4. Log history
INSERT INTO TripAssignmentHistory 
(tripId, action, driverId, vehicleId, reason, performedBy)
VALUES (10, 'ASSIGN', 1, 3, 'Auto-assigned by fairness algorithm', 2);

-- 5. Send notification
INSERT INTO Notifications (userId, title, message)
SELECT u.userId, 'Chuyến mới', CONCAT('Bạn được gán lái Trip #10')
FROM Drivers d
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
WHERE d.driverId = 1;

COMMIT;
```

---

## 🔧 TROUBLESHOOTING

### Lỗi: "Table already exists"
```sql
-- Kiểm tra bảng đã tồn tại
SHOW TABLES LIKE 'TripAssignmentHistory';

-- Nếu cần drop và tạo lại
DROP TABLE IF EXISTS TripAssignmentHistory;
-- Sau đó chạy lại script
```

### Lỗi: "Cannot add foreign key constraint"
```sql
-- Kiểm tra bảng cha đã tồn tại
SHOW TABLES LIKE 'Trips';
SHOW TABLES LIKE 'Drivers';

-- Kiểm tra dữ liệu hợp lệ
SELECT * FROM Trips WHERE tripId NOT IN (SELECT DISTINCT tripId FROM Bookings);
```

### Lỗi: "Duplicate entry"
```sql
-- Script đã dùng ON DUPLICATE KEY UPDATE
-- Nếu vẫn lỗi, xóa dữ liệu cũ:
DELETE FROM TripAssignmentHistory WHERE historyId = 1;
-- Sau đó chạy lại INSERT
```

---

## 📞 SUPPORT & RESOURCES

### Documentation
- **MODULE5_FINAL_SUMMARY.md** - Tổng quan
- **MODULE5_ERD.md** - Sơ đồ database
- **README_MODULE5.md** - Hướng dẫn chi tiết
- **IMPLEMENTATION_CHECKLIST.md** - Roadmap implement

### Scripts
- **00_full_setup.sql** - Fresh install
- **10_MODULE5_CRITICAL_ADDITIONS.sql** - Update database

### Requirements
- MySQL >= 5.7
- InnoDB engine
- utf8mb4 charset

---

## 📈 PROGRESS

- ✅ **Database:** 100% (15/15 bảng, 7/7 views)
- ✅ **Documentation:** 100%
- ⏳ **Backend:** 0% (cần implement)
- ⏳ **Frontend:** 0% (cần implement)
- ⏳ **Testing:** 0% (cần implement)

**Tổng tiến độ:** 25% (Database + Docs hoàn thành)

---

## 🎯 NEXT STEPS

1. ✅ Database setup (DONE)
2. ⏳ Implement Entity classes (15 classes)
3. ⏳ Implement Repository interfaces (15 interfaces)
4. ⏳ Implement Service layer (10 services)
5. ⏳ Implement Controller endpoints (8 controllers)
6. ⏳ Implement Frontend components (20 components)
7. ⏳ Testing (55 tests)

**Xem chi tiết:** IMPLEMENTATION_CHECKLIST.md

---

**Last updated:** 2025-11-19  
**Version:** 3.0 - Module 5 Complete  
**Author:** PTCMSS Development Team
