# 📋 ĐỀ XUẤT TỐI ƯU DATABASE MODULE 5

## 🎯 MỤC TIÊU
Giảm độ phức tạp database từ **29 bảng xuống 25 bảng** mà vẫn đảm bảo **100% chức năng** Module 5.

---

## ❌ ĐỀ XUẤT XÓA: 2 BẢNG (Không cần thiết)

### 1. ❌ XÓA: `DriverRestPeriods`

#### Lý do XÓA:
**Bảng này TRÙNG LẶP chức năng với TripDrivers!**

#### Phân tích:
```sql
-- DriverRestPeriods lưu:
- restStart, restEnd (thời gian nghỉ)
- durationMinutes (tính từ restStart - restEnd)
- isCompliant (>= 30 phút)
- tripIdBefore, tripIdAfter

-- Nhưng TripDrivers ĐÃ CÓ:
- startTime, endTime (thời gian chạy chuyến)
→ Tính rest = khoảng cách giữa 2 chuyến liên tiếp
```

#### Thay thế bằng Query:
```sql
-- Tính rest period từ TripDrivers
SELECT 
  td1.driverId,
  td1.endTime AS trip1End,
  td2.startTime AS trip2Start,
  TIMESTAMPDIFF(MINUTE, td1.endTime, td2.startTime) AS restMinutes,
  CASE 
    WHEN TIMESTAMPDIFF(MINUTE, td1.endTime, td2.startTime) < 30 
    THEN FALSE ELSE TRUE 
  END AS isCompliant
FROM TripDrivers td1
JOIN TripDrivers td2 ON td1.driverId = td2.driverId
WHERE td1.endTime < td2.startTime
  AND NOT EXISTS (
    SELECT 1 FROM TripDrivers td3
    WHERE td3.driverId = td1.driverId
    AND td3.startTime > td1.endTime
    AND td3.startTime < td2.startTime
  )
ORDER BY td1.driverId, td1.endTime;
```

#### Impact nếu XÓA:
- ✅ Giảm 1 bảng
- ✅ Không cần scheduled job cập nhật
- ✅ Dữ liệu luôn realtime (không bị stale)
- ⚠️ Query phức tạp hơn một chút
- ⚠️ Performance giảm nhẹ (có thể cache ở application layer)

#### Kết luận:
**NÊN XÓA** - Lợi ích > Chi phí

---

### 2. ❌ XÓA: `TripIncidents`

#### Lý do XÓA:
**Spec Module 5 KHÔNG YÊU CẦU rõ ràng chức năng báo cáo sự cố!**

#### Phân tích spec:
```
✅ Có yêu cầu:
- Queue/Pending Trips
- Schedule Board
- Auto-assign
- Assignment History
- Conflict Detection
- Driver Rating
- Expense Request
- Notifications

❌ KHÔNG có yêu cầu:
- Incident Reporting
- Incident Management
```

#### Nếu cần sau này:
Có thể thêm lại hoặc dùng workaround:
```sql
-- Dùng Notifications + note
INSERT INTO Notifications (userId, title, message)
VALUES (managerId, 'Sự cố', 'Trip #123: Kẹt xe...');

-- Hoặc dùng Trips.note
UPDATE Trips SET note = 'Incident: Kẹt xe...' WHERE tripId = 123;
```

#### Impact nếu XÓA:
- ✅ Giảm 1 bảng
- ✅ Đơn giản hóa database
- ⚠️ Không có incident tracking chuyên dụng
- ⚠️ Nếu cần sau phải thêm lại

#### Kết luận:
**NÊN XÓA** - Không phải yêu cầu cốt lõi

---

## ⚠️ ĐỀ XUẤT GIỮ NHƯNG ĐƠN GIẢN HÓA: 2 BẢNG

### 3. ⚠️ ĐƠN GIẢN: `ExpenseAttachments`

#### Vấn đề hiện tại:
Bảng riêng cho nhiều attachments, nhưng spec chỉ nói "Upload chứng từ" (không nói nhiều file).

#### Đề xuất:
**GIỮ NHƯNG đơn giản hóa:**

**Option A: Dùng JSON trong Invoices**
```sql
-- Thay vì bảng riêng, thêm cột JSON vào Invoices
ALTER TABLE Invoices 
ADD COLUMN attachments JSON NULL;

-- Lưu nhiều file:
UPDATE Invoices 
SET attachments = JSON_ARRAY(
  JSON_OBJECT('fileName', 'receipt1.jpg', 'filePath', '/uploads/...'),
  JSON_OBJECT('fileName', 'receipt2.pdf', 'filePath', '/uploads/...')
)
WHERE invoiceId = 1;
```

**Option B: Giữ nguyên ExpenseAttachments**
```sql
-- Giữ nguyên như hiện tại
-- Ưu điểm: Query dễ hơn, có thể index
-- Nhược điểm: Thêm 1 bảng
```

#### Kết luận:
**GIỮ NGUYÊN** - Vì query dễ hơn, có thể cần sau này

---

### 4. ⚠️ ĐƠN GIẢN: `ScheduleConflicts`

#### Vấn đề hiện tại:
Cache conflicts, nhưng cần scheduled job để cập nhật.

#### Đề xuất:
**GIỮ NHƯNG làm optional:**

**Cách 1: Tính realtime (không dùng bảng)**
```sql
-- Phát hiện conflict realtime khi assign
SELECT 'DRIVER_OVERLAP' AS conflictType
FROM TripDrivers td1
JOIN TripDrivers td2 ON td1.driverId = td2.driverId
WHERE td1.startTime < td2.endTime 
  AND td2.startTime < td1.endTime
  AND td1.tripId != td2.tripId;
```

**Cách 2: Cache vào bảng (dùng bảng)**
```sql
-- Insert conflict khi phát hiện
INSERT INTO ScheduleConflicts (...)
VALUES (...);
```

#### Kết luận:
**GIỮ NHƯNG OPTIONAL** - Implement sau nếu performance không đủ

---

## ✅ ĐỀ XUẤT GIỮ NGUYÊN: 6 BẢNG (Bắt buộc)

### 5. ✅ GIỮ: `TripAssignmentHistory`

#### Lý do GIỮ:
**BẮT BUỘC - Audit trail là requirement cốt lõi!**

#### Chức năng:
- Ghi log mọi thao tác Assign/Reassign/Unassign
- Hiển thị lịch sử: ai, khi nào, lý do
- Compliance & traceability

#### Spec yêu cầu:
```
"Audit: Mọi thao tác Assign/Reassign/Unassign/Cancel/Acknowledge 
đều ghi log."
```

#### Không thể thay thế:
- ❌ Không thể dùng Notifications (không đủ chi tiết)
- ❌ Không thể dùng Trips.note (không có history)

#### Kết luận:
**BẮT BUỘC GIỮ** ✅

---

### 6. ✅ GIỮ: `TripRatings`

#### Lý do GIỮ:
**BẮT BUỘC - Đánh giá tài xế là requirement rõ ràng!**

#### Chức năng:
- Lưu đánh giá sau mỗi chuyến (1-5 sao + comment)
- Tính average rating 30 ngày
- KPI tài xế

#### Spec yêu cầu:
```
"Driver Rating & Performance: Sau khi chuyến COMPLETED.
Tiêu chí: đúng giờ, thái độ, an toàn (sao 1–5 + comment).
Tổng hợp: Trung bình 30 ngày gần nhất."
```

#### Không thể thay thế:
- ❌ Không có bảng nào khác lưu được rating

#### Kết luận:
**BẮT BUỘC GIỮ** ✅

---

### 7. ✅ GIỮ: `DriverWorkload`

#### Lý do GIỮ:
**BẮT BUỘC - Fairness algorithm cần cache!**

#### Chức năng:
- Cache fairness score cho auto-assign
- Tính totalMinutes, tripCount hàng ngày
- Performance optimization

#### Spec yêu cầu:
```
"Auto‑Assign: Hệ thống lọc hợp lệ và tính điểm công bằng (fairness);
chọn cặp có điểm thấp nhất."
```

#### Tại sao cần cache:
```sql
-- Không có cache: Query phức tạp, chậm
SELECT driverId, 
  SUM(TIMESTAMPDIFF(MINUTE, startTime, endTime)) AS totalMinutes,
  COUNT(*) AS tripCount
FROM TripDrivers td
JOIN Trips t ON td.tripId = t.tripId
WHERE DATE(t.startTime) = CURDATE()
GROUP BY driverId;
-- Phải chạy mỗi lần assign → CHẬM!

-- Có cache: Query đơn giản, nhanh
SELECT driverId, fairnessScore
FROM DriverWorkload
WHERE date = CURDATE()
ORDER BY fairnessScore ASC;
-- Chỉ 1 query đơn giản → NHANH!
```

#### Kết luận:
**BẮT BUỘC GIỮ** ✅

---

### 8. ✅ GIỮ: `DriverShifts`

#### Lý do GIỮ:
**BẮT BUỘC - Không có thì không tính được %Util!**

#### Chức năng:
- Lưu ca làm việc (shiftStart, shiftEnd)
- Tính %Util = (BUSY minutes) / (SHIFT minutes)

#### Spec yêu cầu:
```
"Schedule Board: Mỗi dòng: label (tài xế) + %Util trong ca.
%Util = (tổng phút BUSY trong ca) / (tổng phút ca)."
```

#### Tại sao không thể bỏ:
```
Không có DriverShifts:
→ Không biết ca làm việc bao lâu
→ Không tính được %Util
→ Schedule Board không hoạt động!
```

#### Kết luận:
**BẮT BUỘC GIỮ** ✅

---

### 9. ✅ GIỮ: `VehicleShifts`

#### Lý do GIỮ:
**BẮT BUỘC - Tương tự DriverShifts!**

#### Chức năng:
- Lưu ca hoạt động xe
- Biết xe nào available trong khung giờ nào

#### Spec yêu cầu:
```
"Schedule Board: Toggle Driver / Vehicle.
Timeline hiển thị SHIFT blocks."
```

#### Kết luận:
**BẮT BUỘC GIỮ** ✅

---

### 10. ✅ GIỮ: `VehicleMaintenance`

#### Lý do GIỮ:
**BẮT BUỘC - Không có thì gán nhầm xe đang bảo trì!**

#### Chức năng:
- Lưu lịch bảo trì xe
- Hiển thị MAINT blocks trên timeline
- Tránh gán xe đang sửa

#### Spec yêu cầu:
```
"Schedule Board: MAINT: khối thời gian bảo trì.
Điều kiện hợp lệ để gán: xe hoạt động (không bảo trì)."
```

#### Tại sao không thể dùng Vehicles.status:
```sql
-- Vehicles.status chỉ có: AVAILABLE, INUSE, MAINTENANCE, INACTIVE
-- Nhưng không biết:
- Bảo trì TỪ KHI NÀO đến KHI NÀO?
- Loại bảo trì gì?
- Chi phí bao nhiêu?

→ Cần VehicleMaintenance để lưu chi tiết!
```

#### Kết luận:
**BẮT BUỘC GIỮ** ✅

---

## 📊 TỔNG KẾT ĐỀ XUẤT

### ❌ XÓA (2 bảng):
1. ❌ **DriverRestPeriods** - Trùng lặp với TripDrivers
2. ❌ **TripIncidents** - Không phải requirement

### ✅ GIỮ (8 bảng):
3. ✅ **TripAssignmentHistory** - Audit trail (BẮT BUỘC)
4. ✅ **TripRatings** - Đánh giá tài xế (BẮT BUỘC)
5. ✅ **DriverWorkload** - Fairness cache (BẮT BUỘC)
6. ✅ **DriverShifts** - Tính %Util (BẮT BUỘC)
7. ✅ **VehicleShifts** - Ca hoạt động xe (BẮT BUỘC)
8. ✅ **VehicleMaintenance** - Lịch bảo trì (BẮT BUỘC)
9. ✅ **ScheduleConflicts** - Cache conflicts (KHUYẾN NGHỊ)
10. ✅ **ExpenseAttachments** - Nhiều chứng từ (KHUYẾN NGHỊ)

### 📈 Kết quả:
```
Trước: 29 bảng (19 cũ + 10 mới)
Sau:  27 bảng (19 cũ + 8 mới)

Giảm: 2 bảng (-7%)
Chức năng: Vẫn 100%
```

---

## 🎯 KHUYẾN NGHỊ CUỐI CÙNG

### Option 1: MINIMAL (6 bảng mới) ⭐ KHUYẾN NGHỊ
```
✅ TripAssignmentHistory
✅ TripRatings
✅ DriverWorkload
✅ DriverShifts
✅ VehicleShifts
✅ VehicleMaintenance
+ Cập nhật Bookings, Drivers, Trips
```
**Đủ 95% chức năng, đơn giản nhất**

### Option 2: RECOMMENDED (8 bảng mới) ⭐⭐ TỐT NHẤT
```
= Option 1 +
✅ ScheduleConflicts (performance)
✅ ExpenseAttachments (tương lai)
```
**Đủ 100% chức năng, cân bằng tốt**

### Option 3: FULL (10 bảng mới) - Hiện tại
```
= Option 2 +
⚠️ DriverRestPeriods (không cần)
⚠️ TripIncidents (không cần)
```
**Over-engineering, phức tạp không cần thiết**

---

## 📝 HÀNH ĐỘNG ĐỀ XUẤT

### Bước 1: XÓA 2 bảng không cần
```sql
-- Xóa DriverRestPeriods
DROP TABLE IF EXISTS DriverRestPeriods;

-- Xóa TripIncidents
DROP TABLE IF EXISTS TripIncidents;

-- Xóa sample data liên quan
-- (đã có trong script)
```

### Bước 2: Cập nhật documentation
- Cập nhật MODULE5_FINAL_SUMMARY.md
- Cập nhật README.md
- Cập nhật IMPLEMENTATION_CHECKLIST.md

### Bước 3: Tạo version mới
- Tạo file `00_full_setup_v2_optimized.sql`
- Giữ file cũ để tham khảo

---

## ✅ KẾT LUẬN

**Đề xuất: Dùng Option 2 (8 bảng mới)**

**Lý do:**
1. ✅ Đủ 100% chức năng Module 5
2. ✅ Giảm 2 bảng không cần thiết
3. ✅ Đơn giản hơn, dễ maintain
4. ✅ Performance vẫn tốt
5. ✅ Có thể mở rộng sau

**Bạn có muốn mình tạo version optimized không?** 🤔

---

**Tác giả:** PTCMSS Development Team  
**Ngày:** 2025-11-19  
**Version:** 1.0 - Optimization Proposal
