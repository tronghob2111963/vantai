# Debug Dashboard - Customer Phone & Distance

## Vấn đề
Số điện thoại khách hàng và quãng đường chưa hiển thị trên Dashboard.

## Các bước debug

### 1. Kiểm tra Backend Logs
Sau khi restart backend, khi tài xế load dashboard, check console logs:

```
[DriverDashboard] Fetching dashboard for driver 1
[DriverDashboard] Trip ID: 123, Distance: 169.5
[DriverDashboard] Booking: 456
[DriverDashboard] Customer Phone: 0901234567
```

**Nếu thấy "null":**
- ✅ Distance null → Cần thêm dữ liệu distance vào bảng Trips
- ✅ Booking null → Trip không có booking (cần tạo trip từ booking)
- ✅ Customer Phone null → Customer không có phone hoặc booking không có customer

### 2. Kiểm tra Frontend Console
Mở DevTools (F12) → Console, tìm logs:

```javascript
📊 Dashboard API Response: {
  tripId: 123,
  startLocation: "Hồ Chí Minh",
  endLocation: "Cần Thơ",
  customerPhone: "0901234567",  // ← Kiểm tra có giá trị không
  distance: 169.5                // ← Kiểm tra có giá trị không
}

🔄 Mapped Trip: {
  tripId: 123,
  customerPhone: "0901234567",
  distance: 169.5
}
```

**Nếu customerPhone hoặc distance là undefined/null:**
- Backend không trả về → Check backend logs
- API response không đúng format → Check API endpoint

### 3. Kiểm tra Database

#### 3.1. Kiểm tra Trip có distance không
```sql
SELECT tripId, startLocation, endLocation, distance, bookingId
FROM Trips
WHERE tripId = 123;
```

**Kết quả mong đợi:**
```
tripId | startLocation | endLocation | distance | bookingId
123    | Hồ Chí Minh   | Cần Thơ     | 169.50   | 456
```

**Nếu distance = NULL:**
```sql
-- Cập nhật distance cho trip
UPDATE Trips 
SET distance = 169.5 
WHERE tripId = 123;
```

#### 3.2. Kiểm tra Booking có Customer không
```sql
SELECT b.bookingId, b.customerId, c.fullName, c.phone
FROM Bookings b
LEFT JOIN Customers c ON b.customerId = c.customerId
WHERE b.bookingId = 456;
```

**Kết quả mong đợi:**
```
bookingId | customerId | fullName      | phone
456       | 789        | Nguyễn Văn A  | 0901234567
```

**Nếu customerId = NULL:**
```sql
-- Trip này không có booking hợp lệ
-- Cần tạo lại trip từ booking hoặc gán booking cho trip
UPDATE Trips 
SET bookingId = <valid_booking_id>
WHERE tripId = 123;
```

**Nếu phone = NULL:**
```sql
-- Cập nhật phone cho customer
UPDATE Customers 
SET phone = '0901234567'
WHERE customerId = 789;
```

### 4. Kiểm tra Lazy Loading Issue

Vấn đề có thể là JPA Lazy Loading. Khi fetch Trip, Booking và Customer chưa được load.

**Giải pháp 1: Thêm @Transactional**
File: `DriverServiceImpl.java`

```java
@Override
@Transactional(readOnly = true)  // ← Thêm dòng này
public DriverDashboardResponse getDashboard(Integer driverId) {
    // ... existing code
}
```

**Giải pháp 2: Eager Fetch trong Repository**
Tạo custom query trong `TripDriverRepository`:

```java
@Query("SELECT td FROM TripDrivers td " +
       "JOIN FETCH td.trip t " +
       "LEFT JOIN FETCH t.booking b " +
       "LEFT JOIN FETCH b.customer c " +
       "WHERE td.driver.id = :driverId " +
       "AND (t.status = 'SCHEDULED' OR t.status = 'ONGOING')")
List<TripDrivers> findActiveTripsWithDetails(@Param("driverId") Integer driverId);
```

Sau đó update service:
```java
var driverTrips = tripDriverRepository.findActiveTripsWithDetails(driverId);
```

### 5. Test với Mock Data

Nếu database chưa có dữ liệu đầy đủ, tạo test data:

```sql
-- 1. Tạo Customer
INSERT INTO Customers (fullName, phone, email, status) 
VALUES ('Nguyễn Văn A', '0901234567', 'test@example.com', 'ACTIVE');

-- 2. Tạo Booking với customer vừa tạo
INSERT INTO Bookings (customerId, branchId, status, bookingDate)
VALUES (LAST_INSERT_ID(), 1, 'CONFIRMED', NOW());

-- 3. Tạo hoặc update Trip với booking vừa tạo
UPDATE Trips 
SET bookingId = LAST_INSERT_ID(),
    distance = 169.5
WHERE tripId = 123;
```

### 6. Kiểm tra UI Rendering

Nếu data đã có trong console nhưng không hiển thị:

**Check 1: activeTrip có đúng data không?**
Thêm log trước return trong component:
```javascript
console.log("🎯 Active Trip for UI:", activeTrip);
```

**Check 2: TripCard có nhận đúng props không?**
Trong TripCard component:
```javascript
function TripCard({ activeTrip, ... }) {
  console.log("📦 TripCard received:", activeTrip);
  const t = activeTrip;
  console.log("📞 Phone in card:", t?.customer_phone);
  console.log("🗺️ Distance in card:", t?.distance);
  // ...
}
```

### 7. Quick Fix - Hardcode Test

Để test UI nhanh, tạm thời hardcode data:

```javascript
const activeTrip = trip
  ? {
      trip_id: trip.tripId,
      pickup_time: trip.pickupTime,
      pickup_address: trip.pickupAddress,
      dropoff_address: trip.dropoffAddress,
      customer_name: null,
      customer_phone: trip.customerPhone || "0901234567", // ← Test
      distance: trip.distance || 169.5,                   // ← Test
      note: null,
    }
  : null;
```

Nếu hiển thị được → Vấn đề ở backend/API
Nếu vẫn không hiển thị → Vấn đề ở UI rendering

---

## Checklist Debug

- [ ] Backend logs có hiển thị customerPhone và distance?
- [ ] Frontend console có nhận được data từ API?
- [ ] Database có dữ liệu distance trong Trips?
- [ ] Database có dữ liệu phone trong Customers?
- [ ] Trip có liên kết với Booking hợp lệ?
- [ ] Booking có liên kết với Customer hợp lệ?
- [ ] Thêm @Transactional vào getDashboard()?
- [ ] UI component có render đúng data?

---

## Expected Flow

```
Database
  ↓
Trip (distance) → Booking → Customer (phone)
  ↓
DriverServiceImpl.getDashboard()
  ↓
DriverDashboardResponse { customerPhone, distance }
  ↓
API Response JSON
  ↓
Frontend: getDriverDashboard()
  ↓
fetchDashboard() → mapped trip
  ↓
activeTrip { customer_phone, distance }
  ↓
TripCard component
  ↓
UI Display: 📞 0901234567 | 🗺️ 169.5 km
```

---

## Common Issues & Solutions

### Issue 1: LazyInitializationException
**Error:** `could not initialize proxy - no Session`

**Solution:**
```java
@Transactional(readOnly = true)
public DriverDashboardResponse getDashboard(Integer driverId) {
    // ...
}
```

### Issue 2: Distance = null
**Cause:** Database không có giá trị

**Solution:**
```sql
UPDATE Trips SET distance = 169.5 WHERE tripId = 123;
```

### Issue 3: Customer Phone = null
**Cause:** 
- Customer không có phone
- Booking không có customer
- Trip không có booking

**Solution:** Check foreign keys và update data

### Issue 4: API trả về null
**Cause:** Không có trip SCHEDULED hoặc ONGOING

**Solution:** Tạo trip mới hoặc update status:
```sql
UPDATE Trips SET status = 'SCHEDULED' WHERE tripId = 123;
```

---

## Next Steps

1. **Restart backend** để apply code changes
2. **Clear browser cache** và reload frontend
3. **Check console logs** (backend + frontend)
4. **Verify database** có đủ dữ liệu
5. **Test với trip có đầy đủ data**

Nếu vẫn không work, gửi cho tôi:
- Backend logs khi call API
- Frontend console logs
- Database query results
