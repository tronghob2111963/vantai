# Quick Fix Checklist - Dashboard Not Showing Data

## ⚡ Làm theo thứ tự này:

### 1️⃣ Restart Backend
```bash
cd PTCMSS/ptcmss-backend
mvn clean install
mvn spring-boot:run
```
✅ Code đã được update với @Transactional và logging

---

### 2️⃣ Run Database Script
```sql
-- Chạy file này trong MySQL:
PTCMSS/db_scripts/12_ADD_CUSTOMER_PHONE_DISTANCE.sql
```
✅ Script sẽ:
- Thêm phone cho customers chưa có
- Thêm distance cho trips chưa có
- Verify data integrity

---

### 3️⃣ Clear Browser Cache & Reload Frontend
```bash
# Trong browser:
1. F12 → Console
2. Right-click Reload button → "Empty Cache and Hard Reload"
3. Hoặc Ctrl+Shift+R
```

---

### 4️⃣ Check Console Logs

#### Backend Console (Terminal):
Tìm dòng này khi load dashboard:
```
[DriverDashboard] Fetching dashboard for driver 1
[DriverDashboard] Trip ID: 123, Distance: 169.5
[DriverDashboard] Booking: 456
[DriverDashboard] Customer Phone: 0901234567
```

#### Frontend Console (Browser F12):
Tìm dòng này:
```javascript
📊 Dashboard API Response: { customerPhone: "0901234567", distance: 169.5 }
📞 Customer Phone: 0901234567
🗺️ Distance: 169.5
🔄 Mapped Trip: { customerPhone: "0901234567", distance: 169.5 }
```

---

### 5️⃣ Verify UI

Trong Dashboard, phần "Trip Details" phải có 4 cột:
```
┌─────────────────────────────────────────────────────────┐
│ 📍 Điểm đón    👤 Khách hàng    📞 Liên hệ    🗺️ Quãng đường │
│ Hồ Chí Minh    —               0901234567    169.5 km    │
└─────────────────────────────────────────────────────────┘
```

---

## 🔍 Nếu vẫn không hiển thị:

### Check 1: Database có data không?
```sql
SELECT 
    t.tripId,
    t.distance,
    c.phone,
    t.status
FROM Trips t
LEFT JOIN Bookings b ON t.bookingId = b.bookingId
LEFT JOIN Customers c ON b.customerId = c.customerId
WHERE t.status IN ('SCHEDULED', 'ONGOING')
LIMIT 5;
```

**Kết quả mong đợi:**
- distance: NOT NULL (VD: 169.5)
- phone: NOT NULL (VD: 0901234567)

**Nếu NULL:** Chạy lại script ở bước 2

---

### Check 2: Backend có lỗi không?
Tìm trong backend console:
```
ERROR
LazyInitializationException
could not initialize proxy
```

**Nếu có lỗi:** @Transactional chưa work → Check import:
```java
import org.springframework.transaction.annotation.Transactional;
```

---

### Check 3: API Response có đúng không?
Trong browser console, check:
```javascript
📊 Dashboard API Response: { ... }
```

**Nếu customerPhone hoặc distance = undefined:**
→ Backend không trả về → Check backend logs

**Nếu cả object = null:**
→ Không có trip SCHEDULED/ONGOING → Tạo trip mới

---

### Check 4: Frontend có render không?
Tìm trong browser console:
```javascript
🔄 Mapped Trip: { ... }
```

**Nếu có data nhưng UI không hiển thị:**
→ Vấn đề ở component rendering → Check React DevTools

---

## 🆘 Still Not Working?

### Option A: Create Test Trip
```sql
-- Run this to create a complete test trip:
INSERT INTO Customers (fullName, phone, email, status) 
VALUES ('Test Customer', '0901234567', 'test@test.com', 'ACTIVE');

SET @cust_id = LAST_INSERT_ID();

INSERT INTO Bookings (customerId, branchId, status, bookingDate)
VALUES (@cust_id, 1, 'CONFIRMED', NOW());

SET @book_id = LAST_INSERT_ID();

INSERT INTO Trips (bookingId, startLocation, endLocation, distance, startTime, status)
VALUES (@book_id, 'Hồ Chí Minh', 'Cần Thơ', 169.5, DATE_ADD(NOW(), INTERVAL 1 HOUR), 'SCHEDULED');

SET @trip_id = LAST_INSERT_ID();

-- Assign to driver (replace 1 with your driver ID)
INSERT INTO TripDrivers (tripId, driverId) VALUES (@trip_id, 1);
```

### Option B: Send Me Debug Info
Gửi cho tôi:
1. Backend console logs (toàn bộ output khi call API)
2. Frontend console logs (screenshot)
3. Database query result:
```sql
SELECT t.*, b.*, c.* 
FROM Trips t
LEFT JOIN Bookings b ON t.bookingId = b.bookingId
LEFT JOIN Customers c ON b.customerId = c.customerId
WHERE t.status IN ('SCHEDULED', 'ONGOING')
LIMIT 1;
```

---

## ✅ Success Indicators

Khi thành công, bạn sẽ thấy:

1. **Backend logs:**
   ```
   [DriverDashboard] Customer Phone: 0901234567
   [DriverDashboard] Trip ID: 123, Distance: 169.5
   ```

2. **Frontend console:**
   ```javascript
   📞 Customer Phone: 0901234567
   🗺️ Distance: 169.5
   ```

3. **UI hiển thị:**
   - Cột "Liên hệ" có số điện thoại
   - Cột "Quãng đường" có số km

---

## 📝 Files Changed

- ✅ `DriverDashboardResponse.java` - Added customerPhone & distance
- ✅ `DriverServiceImpl.java` - Added @Transactional & logging
- ✅ `DriverDashboard.jsx` - Added console logs & UI columns
- ✅ `12_ADD_CUSTOMER_PHONE_DISTANCE.sql` - Database update script

**Tất cả đã ready!** Chỉ cần restart backend và chạy SQL script.
