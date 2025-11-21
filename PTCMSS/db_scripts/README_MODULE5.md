# 🚀 HƯỚNG DẪN CÀI ĐẶT MODULE 5 - QUẢN LÝ LỊCH TRÌNH & ĐIỀU PHỐI

## 📋 Tổng quan

Module 5 bổ sung **4 bảng mới** vào database PTCMSS để hỗ trợ đầy đủ chức năng quản lý lịch trình và điều phối:

1. **TripAssignmentHistory** - Lịch sử phân công (Audit log)
2. **TripRatings** - Đánh giá tài xế
3. **DriverWorkload** - Khối lượng công việc & Fairness score
4. **TripIncidents** - Báo cáo sự cố

---

## 🎯 Chọn phương án cài đặt

### ✅ Phương án 1: Cài đặt mới (Fresh Install)

**Khi nào dùng:** Database chưa tồn tại hoặc muốn reset toàn bộ

```bash
# Chạy script đầy đủ
mysql -u root -p < 00_full_setup.sql

# Hoặc từ MySQL CLI
mysql> source /path/to/00_full_setup.sql;
```

**Kết quả:**
- Tạo database `ptcmss_db` mới
- Tạo tất cả bảng (bao gồm 4 bảng Module 5)
- Insert dữ liệu mẫu đầy đủ

---

### ✅ Phương án 2: Cập nhật database hiện có

**Khi nào dùng:** Database đã tồn tại, chỉ cần thêm Module 5

```bash
# Backup database trước khi update (QUAN TRỌNG!)
mysqldump -u root -p ptcmss_db > backup_before_module5.sql

# Chạy script cập nhật Module 5
mysql -u root -p ptcmss_db < 08_MODULE5_ADDITIONS.sql
```

**Kết quả:**
- Thêm 4 bảng mới
- Cập nhật bảng Drivers (thêm cột averageRating, totalRatings)
- Tạo 2 views mới
- Thêm 3 system settings cho fairness algorithm
- Insert dữ liệu mẫu (optional)

---

## 📝 Chi tiết các file

### 1. `00_full_setup.sql`
- **Mục đích:** Script đầy đủ để setup database từ đầu
- **Nội dung:** 
  - Tất cả bảng cũ + 4 bảng Module 5
  - Triggers, Views, Indexes
  - Seed data đầy đủ
- **Khi nào dùng:** Fresh install hoặc reset database

### 2. `08_MODULE5_ADDITIONS.sql`
- **Mục đích:** Script cập nhật riêng cho Module 5
- **Nội dung:**
  - Chỉ tạo 4 bảng mới
  - ALTER bảng Drivers
  - Tạo views và settings mới
  - Sample data (có thể comment out)
- **Khi nào dùng:** Database đã tồn tại, chỉ cần thêm Module 5

### 3. `MODULE5_UPDATES_SUMMARY.md`
- **Mục đích:** Tài liệu chi tiết về Module 5
- **Nội dung:**
  - Cấu trúc 4 bảng mới
  - Use cases và ví dụ
  - Hướng dẫn implement backend
  - Best practices

---

## 🔍 Kiểm tra sau khi cài đặt

### 1. Kiểm tra bảng đã tạo thành công

```sql
USE ptcmss_db;

-- Kiểm tra 4 bảng mới
SHOW TABLES LIKE 'Trip%';
SHOW TABLES LIKE 'Driver%';

-- Kết quả mong đợi:
-- TripAssignmentHistory
-- TripRatings
-- TripIncidents
-- DriverWorkload
```

### 2. Kiểm tra cột mới trong Drivers

```sql
DESCRIBE Drivers;

-- Phải có 2 cột mới:
-- averageRating DECIMAL(3,2)
-- totalRatings INT
```

### 3. Kiểm tra Views

```sql
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Phải có:
-- v_DriverMonthlyPerformance
-- v_DriverRatingsSummary
-- v_DriverWorkloadSummary
```

### 4. Kiểm tra dữ liệu mẫu

```sql
-- Kiểm tra TripAssignmentHistory
SELECT COUNT(*) FROM TripAssignmentHistory;
-- Kết quả: 3 records

-- Kiểm tra TripRatings
SELECT COUNT(*) FROM TripRatings;
-- Kết quả: 2 records

-- Kiểm tra DriverWorkload
SELECT COUNT(*) FROM DriverWorkload;
-- Kết quả: 7 records

-- Kiểm tra TripIncidents
SELECT COUNT(*) FROM TripIncidents;
-- Kết quả: 2 records
```

### 5. Test Views

```sql
-- Test v_DriverRatingsSummary
SELECT * FROM v_DriverRatingsSummary WHERE driverId = 1;

-- Test v_DriverWorkloadSummary
SELECT * FROM v_DriverWorkloadSummary WHERE driverId IN (1,2,3);
```

---

## 🛠️ Troubleshooting

### ❌ Lỗi: "Table already exists"

**Nguyên nhân:** Bảng đã tồn tại từ trước

**Giải pháp:**
```sql
-- Option 1: Drop bảng cũ (MẤT DỮ LIỆU!)
DROP TABLE IF EXISTS TripAssignmentHistory;
DROP TABLE IF EXISTS TripRatings;
DROP TABLE IF EXISTS DriverWorkload;
DROP TABLE IF EXISTS TripIncidents;

-- Sau đó chạy lại script
```

```sql
-- Option 2: Kiểm tra và giữ dữ liệu cũ
-- Script đã dùng CREATE TABLE IF NOT EXISTS nên không lỗi
-- Nếu vẫn lỗi, check foreign key constraints
```

---

### ❌ Lỗi: "Cannot add foreign key constraint"

**Nguyên nhân:** Bảng tham chiếu chưa tồn tại hoặc dữ liệu không hợp lệ

**Giải pháp:**
```sql
-- Kiểm tra bảng cha đã tồn tại
SHOW TABLES LIKE 'Trips';
SHOW TABLES LIKE 'Drivers';
SHOW TABLES LIKE 'Vehicles';
SHOW TABLES LIKE 'Employees';

-- Kiểm tra dữ liệu hợp lệ
SELECT * FROM Trips WHERE tripId IN (1,2,6);
SELECT * FROM Drivers WHERE driverId IN (1,2,4,5);
```

---

### ❌ Lỗi: "Duplicate entry for key 'UK_DriverWorkload_Date'"

**Nguyên nhân:** Đã có dữ liệu cho (driverId, date) đó

**Giải pháp:**
```sql
-- Script đã dùng ON DUPLICATE KEY UPDATE
-- Nếu vẫn lỗi, xóa dữ liệu cũ:
DELETE FROM DriverWorkload WHERE driverId = 1 AND date = '2025-10-25';

-- Hoặc update thay vì insert
UPDATE DriverWorkload 
SET totalMinutes = 780, tripCount = 1, fairnessScore = 45.5
WHERE driverId = 1 AND date = '2025-10-25';
```

---

### ❌ Lỗi: "Column 'averageRating' doesn't exist"

**Nguyên nhân:** Chưa chạy ALTER TABLE Drivers

**Giải pháp:**
```sql
-- Chạy lại ALTER TABLE
ALTER TABLE Drivers 
  ADD COLUMN averageRating DECIMAL(3,2) DEFAULT 5.00,
  ADD COLUMN totalRatings INT DEFAULT 0;
```

---

## 📊 Queries hữu ích

### 1. Xem lịch sử phân công của 1 trip

```sql
SELECT 
  h.historyId,
  h.action,
  h.createdAt,
  d.licenseNumber AS driverLicense,
  v.licensePlate AS vehiclePlate,
  h.reason,
  e.fullName AS performedBy
FROM TripAssignmentHistory h
LEFT JOIN Drivers d ON h.driverId = d.driverId
LEFT JOIN Vehicles v ON h.vehicleId = v.vehicleId
LEFT JOIN Employees emp ON h.performedBy = emp.employeeId
LEFT JOIN Users e ON emp.userId = e.userId
WHERE h.tripId = 1
ORDER BY h.createdAt DESC;
```

### 2. Xem rating của tài xế

```sql
SELECT 
  d.driverId,
  u.fullName AS driverName,
  d.averageRating,
  d.totalRatings,
  tr.rating AS lastRating,
  tr.comment AS lastComment,
  tr.ratedAt AS lastRatedAt
FROM Drivers d
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
LEFT JOIN TripRatings tr ON d.driverId = tr.driverId
WHERE d.driverId = 1
ORDER BY tr.ratedAt DESC
LIMIT 5;
```

### 3. Xem workload 7 ngày gần nhất

```sql
SELECT * FROM v_DriverWorkloadSummary
WHERE driverId = 1;
```

### 4. Xem sự cố chưa xử lý

```sql
SELECT 
  i.incidentId,
  i.tripId,
  d.licenseNumber AS driverLicense,
  i.incidentType,
  i.severity,
  i.status,
  i.description,
  i.reportedAt
FROM TripIncidents i
JOIN Drivers d ON i.driverId = d.driverId
WHERE i.status IN ('REPORTED', 'INVESTIGATING')
ORDER BY i.severity DESC, i.reportedAt DESC;
```

### 5. Top 5 tài xế có rating cao nhất

```sql
SELECT 
  d.driverId,
  u.fullName AS driverName,
  d.averageRating,
  d.totalRatings,
  b.branchName
FROM Drivers d
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
JOIN Branches b ON d.branchId = b.branchId
WHERE d.status = 'AVAILABLE'
  AND d.totalRatings >= 5
ORDER BY d.averageRating DESC, d.totalRatings DESC
LIMIT 5;
```

---

## 🎯 Next Steps - Backend Implementation

### 1. Tạo Entity Classes

```java
// TripAssignmentHistory.java
@Entity
@Table(name = "TripAssignmentHistory")
public class TripAssignmentHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer historyId;
    
    @ManyToOne
    @JoinColumn(name = "tripId")
    private Trip trip;
    
    @Enumerated(EnumType.STRING)
    private AssignmentAction action;
    
    // ... other fields
}

// TripRatings.java
// DriverWorkload.java
// TripIncidents.java
```

### 2. Tạo Repository Interfaces

```java
public interface TripAssignmentHistoryRepository 
    extends JpaRepository<TripAssignmentHistory, Integer> {
    List<TripAssignmentHistory> findByTripIdOrderByCreatedAtDesc(Integer tripId);
}

public interface TripRatingsRepository 
    extends JpaRepository<TripRatings, Integer> {
    List<TripRatings> findByDriverIdOrderByRatedAtDesc(Integer driverId);
    Optional<TripRatings> findByTripIdAndDriverId(Integer tripId, Integer driverId);
}

// ... other repositories
```

### 3. Tạo Service Layer

```java
@Service
public class DispatchService {
    
    // Auto-assign driver based on fairness score
    public Driver findBestAvailableDriver(LocalDateTime tripTime, Integer branchId) {
        // Logic: Query DriverWorkload, check availability, calculate fairness
    }
    
    // Log assignment history
    public void logAssignment(Trip trip, Driver driver, Vehicle vehicle, String reason) {
        // Insert into TripAssignmentHistory
    }
    
    // Calculate and update driver rating
    public void updateDriverRating(Integer driverId) {
        // Calculate from TripRatings, update Drivers table
    }
}
```

### 4. Tạo Scheduled Jobs

```java
@Component
public class WorkloadScheduler {
    
    @Scheduled(cron = "0 0 0 * * *") // Chạy lúc 00:00 mỗi ngày
    public void calculateDailyWorkload() {
        // Tính totalMinutes, tripCount, fairnessScore cho ngày hôm trước
        // Insert/Update vào DriverWorkload
    }
}
```

---

## 📞 Hỗ trợ

Nếu gặp vấn đề, kiểm tra:
1. ✅ MySQL version >= 5.7
2. ✅ InnoDB engine được enable
3. ✅ Foreign key checks được enable
4. ✅ Đủ quyền CREATE TABLE, ALTER TABLE, CREATE VIEW

---

**Chúc bạn implement thành công Module 5! 🎉**
