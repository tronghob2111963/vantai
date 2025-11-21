# 📋 MODULE 5 - CẬP NHẬT DATABASE CHO QUẢN LÝ LỊCH TRÌNH & ĐIỀU PHỐI

## 🎯 Tổng quan
File `00_full_setup.sql` đã được cập nhật đầy đủ với **4 bảng mới** và các thành phần hỗ trợ cho **Module 5: Quản lý lịch trình & điều phối**.

---

## ✅ CÁC BẢNG MỚI ĐÃ THÊM

### 1️⃣ **TripAssignmentHistory** - Lịch sử phân công
**Mục đích:** Audit log để theo dõi mọi thay đổi phân công tài xế/xe

**Cấu trúc:**
```sql
- historyId (PK)
- tripId (FK -> Trips)
- action (ASSIGN/REASSIGN/UNASSIGN/CANCEL)
- driverId (FK -> Drivers)
- vehicleId (FK -> Vehicles)
- previousDriverId (FK -> Drivers)
- previousVehicleId (FK -> Vehicles)
- reason (VARCHAR 500)
- performedBy (FK -> Employees)
- createdAt (DATETIME)
```

**Indexes:**
- IX_TripAssignmentHistory_TripId
- IX_TripAssignmentHistory_CreatedAt
- IX_TripAssignmentHistory_DriverId

**Use cases:**
- Theo dõi ai đã gán/thay đổi phân công
- Audit trail cho compliance
- Phân tích lý do thay đổi phân công

---

### 2️⃣ **TripRatings** - Đánh giá tài xế
**Mục đích:** Lưu đánh giá hiệu suất tài xế sau mỗi chuyến đi

**Cấu trúc:**
```sql
- ratingId (PK)
- tripId (FK -> Trips)
- driverId (FK -> Drivers)
- rating (INT 1-5)
- comment (VARCHAR 500)
- ratedBy (FK -> Employees)
- ratedAt (DATETIME)
- UNIQUE (tripId, driverId)
```

**Indexes:**
- IX_TripRatings_DriverId
- IX_TripRatings_RatedAt

**Use cases:**
- Đánh giá hiệu suất tài xế
- Tính toán averageRating trong bảng Drivers
- Báo cáo KPI tài xế
- Ưu tiên phân công dựa trên rating

---

### 3️⃣ **DriverWorkload** - Khối lượng công việc
**Mục đích:** Tính toán workload và fairness score để phân công công bằng

**Cấu trúc:**
```sql
- workloadId (PK)
- driverId (FK -> Drivers)
- date (DATE)
- totalMinutes (INT)
- tripCount (INT)
- fairnessScore (DECIMAL 5,2)
- lastUpdated (DATETIME)
- UNIQUE (driverId, date)
```

**Indexes:**
- IX_DriverWorkload_Date
- IX_DriverWorkload_Score

**Use cases:**
- Tính toán fairness score cho thuật toán phân công
- Đảm bảo phân công công bằng giữa các tài xế
- Báo cáo workload theo ngày/tuần/tháng
- Phát hiện tài xế quá tải hoặc nhàn rỗi

---

### 4️⃣ **TripIncidents** - Báo cáo sự cố
**Mục đích:** Ghi nhận và quản lý sự cố xảy ra trong chuyến đi

**Cấu trúc:**
```sql
- incidentId (PK)
- tripId (FK -> Trips)
- driverId (FK -> Drivers)
- incidentType (VARCHAR 50)
- description (VARCHAR 1000)
- location (VARCHAR 255)
- reportedAt (DATETIME)
- severity (LOW/MEDIUM/HIGH/CRITICAL)
- status (REPORTED/INVESTIGATING/RESOLVED/CLOSED)
- resolvedBy (FK -> Employees)
- resolvedAt (DATETIME)
- note (VARCHAR 500)
```

**Indexes:**
- IX_TripIncidents_TripId
- IX_TripIncidents_DriverId
- IX_TripIncidents_Status
- IX_TripIncidents_Severity

**Use cases:**
- Báo cáo sự cố (tai nạn, hỏng xe, kẹt xe...)
- Theo dõi xử lý sự cố
- Phân tích nguyên nhân sự cố
- Đánh giá an toàn tài xế

---

## 🔄 CẬP NHẬT BẢNG HIỆN CÓ

### **Drivers** - Thêm cột mới
```sql
ALTER TABLE Drivers ADD COLUMN:
- averageRating DECIMAL(3,2) DEFAULT 5.00
- totalRatings INT DEFAULT 0
```

**Lý do:** Lưu cache rating để query nhanh hơn, tránh JOIN với TripRatings mỗi lần

---

## 📊 VIEWS MỚI

### 1. **v_DriverRatingsSummary**
Tổng hợp rating của tài xế với thống kê 30 ngày gần nhất
```sql
- driverId
- averageRating (từ bảng Drivers)
- totalRatings (từ bảng Drivers)
- calculatedAverageRating (tính từ TripRatings)
- rating30Days (rating trung bình 30 ngày)
- ratings30Days (số lượng rating 30 ngày)
```

### 2. **v_DriverWorkloadSummary**
Tổng hợp workload 7 ngày gần nhất của tài xế
```sql
- driverId, driverName, branchId, branchName
- totalMinutesLast7Days
- totalTripsLast7Days
- avgFairnessScore
```

---

## ⚙️ SYSTEM SETTINGS MỚI

Thêm 3 settings cho thuật toán fairness:
```sql
(6, 'FAIRNESS_WEIGHT_DAILY_HOURS', '0.4', ...)
(7, 'FAIRNESS_WEIGHT_WEEKLY_TRIPS', '0.3', ...)
(8, 'FAIRNESS_WEIGHT_REST_TIME', '0.3', ...)
```

**Công thức fairness score:**
```
fairnessScore = 
  (dailyHours * 0.4) + 
  (weeklyTrips * 0.3) + 
  (restTime * 0.3)
```

---

## 📈 INDEXES BỔ SUNG

### Trips table:
- `IX_Trips_Branch_Status_Time` - Tối ưu query theo chi nhánh + status + thời gian

---

## 💾 DỮ LIỆU MẪU

### TripAssignmentHistory (3 records)
- Gán tài xế A cho Trip 1 (Hà Nội - Hạ Long)
- Gán tài xế D cho Trip 2 (Đón sân bay)
- Gán tài xế E cho Trip 6 (Đi Nội Bài)

### TripRatings (2 records)
- Trip 1: Rating 5/5 và 4/5 cho tài xế A

### DriverWorkload (7 records)
- Workload của 5 tài xế trong các ngày 25/10, 28/10, 29/10, 01/11

### TripIncidents (2 records)
- Kẹt xe trên cao tốc (LOW severity, CLOSED)
- Lốp xe xì hơi (MEDIUM severity, RESOLVED)

---

## 🚀 CÁCH SỬ DỤNG

### 1. Chạy script đầy đủ (Fresh install):
```bash
mysql -u root -p < PTCMSS/db_scripts/00_full_setup.sql
```

### 2. Hoặc chạy từng phần (nếu DB đã tồn tại):
```sql
-- Chỉ tạo 4 bảng mới
CREATE TABLE TripAssignmentHistory ...
CREATE TABLE TripRatings ...
CREATE TABLE DriverWorkload ...
CREATE TABLE TripIncidents ...

-- Cập nhật bảng Drivers
ALTER TABLE Drivers 
  ADD COLUMN averageRating DECIMAL(3,2) DEFAULT 5.00,
  ADD COLUMN totalRatings INT DEFAULT 0;

-- Tạo views
CREATE OR REPLACE VIEW v_DriverRatingsSummary ...
CREATE OR REPLACE VIEW v_DriverWorkloadSummary ...
```

---

## 🎯 CHỨC NĂNG MODULE 5 CÓ THỂ IMPLEMENT

### ✅ Đã có đủ database cho:

1. **Phân công tự động (Auto-dispatch)**
   - Dựa trên fairnessScore từ DriverWorkload
   - Ưu tiên tài xế có rating cao
   - Tránh tài xế đang nghỉ phép (DriverDayOff)

2. **Lịch sử phân công (Assignment History)**
   - Xem ai đã gán/thay đổi
   - Lý do thay đổi
   - Timeline audit

3. **Đánh giá tài xế (Driver Rating)**
   - Rating sau mỗi chuyến
   - Tính average rating tự động
   - Báo cáo rating theo thời gian

4. **Quản lý workload (Workload Management)**
   - Theo dõi giờ làm việc
   - Số chuyến đi
   - Fairness score
   - Cảnh báo quá tải

5. **Báo cáo sự cố (Incident Reporting)**
   - Ghi nhận sự cố
   - Theo dõi xử lý
   - Phân tích nguyên nhân
   - Báo cáo an toàn

---

## 📝 GHI CHÚ QUAN TRỌNG

### ⚠️ Cần implement ở Backend:

1. **Trigger/Service cập nhật averageRating:**
```java
// Sau khi insert TripRatings
UPDATE Drivers SET 
  averageRating = (SELECT AVG(rating) FROM TripRatings WHERE driverId = ?),
  totalRatings = (SELECT COUNT(*) FROM TripRatings WHERE driverId = ?)
WHERE driverId = ?;
```

2. **Scheduled Job cập nhật DriverWorkload:**
```java
// Chạy mỗi ngày lúc 00:00
// Tính totalMinutes, tripCount, fairnessScore cho ngày hôm trước
```

3. **Service tính fairness score:**
```java
public double calculateFairnessScore(int driverId, LocalDate date) {
  // Lấy weights từ SystemSettings
  // Tính toán dựa trên công thức
  // Lưu vào DriverWorkload
}
```

---

## ✨ KẾT LUẬN

**Module 5 giờ đã có đầy đủ database schema để implement 100% chức năng!**

Các bảng mới này giải quyết được:
- ✅ Audit trail cho phân công
- ✅ Đánh giá hiệu suất tài xế
- ✅ Phân công công bằng (fairness)
- ✅ Quản lý sự cố

**Next steps:**
1. Implement Entity classes (Java)
2. Implement Repository interfaces
3. Implement Service layer với business logic
4. Implement Controller endpoints
5. Implement Frontend components

---

**Tác giả:** PTCMSS Development Team  
**Ngày cập nhật:** 2025-11-19  
**Version:** 2.0 - Module 5 Complete
