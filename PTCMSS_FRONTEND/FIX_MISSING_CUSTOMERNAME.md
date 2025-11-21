# Fix Missing customerName in API Response

## Vấn đề hiện tại

API Response:
```json
{
  "status": 200,
  "message": "Get driver dashboard successfully",
  "data": {
    "tripId": 38,
    "startLocation": "Hồ Chí Minh",
    "endLocation": "Cần Thơ",
    "startTime": "2025-11-20T11:06:00Z",
    "endTime": "2025-11-20T14:06:00Z",
    "status": "SCHEDULED",
    "customerPhone": "0987456321",  ✅ Có
    "distance": null                 ❌ Null
    // ❌ THIẾU customerName
  }
}
```

## Nguyên nhân

1. **Backend chưa restart** sau khi thêm code customerName
2. **Distance = null** trong database cho trip 38

## Giải pháp

### Bước 1: Rebuild & Restart Backend

```bash
# Stop backend hiện tại (Ctrl+C)

# Clean và rebuild
cd PTCMSS/ptcmss-backend
mvn clean install -DskipTests

# Restart
mvn spring-boot:run
```

**Hoặc nếu dùng IDE:**
1. Stop application
2. Build → Rebuild Project
3. Run lại

### Bước 2: Verify Backend Logs

Sau khi restart, khi load dashboard, check logs:

```
[DriverDashboard] Fetching dashboard for driver X
[DriverDashboard] Trip ID: 38, Distance: null
[DriverDashboard] Booking: XXX
[DriverDashboard] Customer: [Tên khách hàng] - 0987456321
```

**Nếu thấy:**
- `Customer: null - 0987456321` → Customer không có fullName trong DB
- `Customer: [Tên] - 0987456321` → OK, nhưng response vẫn thiếu → Check JSON serialization

### Bước 3: Fix Database - Add Distance

```sql
-- Check trip 38
SELECT 
    t.tripId,
    t.distance,
    t.bookingId,
    b.customerId,
    c.fullName,
    c.phone
FROM Trips t
LEFT JOIN Bookings b ON t.bookingId = b.bookingId
LEFT JOIN Customers c ON b.customerId = c.customerId
WHERE t.tripId = 38;
```

**Nếu distance = NULL:**
```sql
-- Update distance cho trip 38
UPDATE Trips 
SET distance = 169.5 
WHERE tripId = 38;
```

**Nếu customer fullName = NULL:**
```sql
-- Update customer name
UPDATE Customers 
SET fullName = 'Nguyễn Văn A'
WHERE customerId = (
    SELECT customerId FROM Bookings 
    WHERE bookingId = (
        SELECT bookingId FROM Trips WHERE tripId = 38
    )
);
```

### Bước 4: Test API Manually

```bash
# Test với curl hoặc Postman
curl -X GET "http://localhost:8080/api/drivers/{driverId}/dashboard" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response:**
```json
{
  "status": 200,
  "message": "Get driver dashboard successfully",
  "data": {
    "tripId": 38,
    "startLocation": "Hồ Chí Minh",
    "endLocation": "Cần Thơ",
    "startTime": "2025-11-20T11:06:00Z",
    "endTime": "2025-11-20T14:06:00Z",
    "status": "SCHEDULED",
    "customerName": "Nguyễn Văn A",    // ✅ PHẢI CÓ
    "customerPhone": "0987456321",     // ✅ Đã có
    "distance": 169.5                  // ✅ PHẢI CÓ
  }
}
```

### Bước 5: Reload Frontend

```
Ctrl + Shift + R (hard reload)
```

---

## Quick Debug Commands

### Check if backend code is updated:
```bash
# Check compiled class
cd PTCMSS/ptcmss-backend/target/classes
grep -r "customerName" .
```

### Check database:
```sql
-- Check trip 38 data
SELECT 
    t.tripId,
    t.startLocation,
    t.endLocation,
    t.distance,
    c.fullName AS customerName,
    c.phone AS customerPhone
FROM Trips t
JOIN Bookings b ON t.bookingId = b.bookingId
JOIN Customers c ON b.customerId = c.customerId
WHERE t.tripId = 38;
```

**Expected Result:**
```
tripId | startLocation | endLocation | distance | customerName    | customerPhone
38     | Hồ Chí Minh   | Cần Thơ     | 169.5    | Nguyễn Văn A   | 0987456321
```

---

## Troubleshooting

### Issue 1: Backend restart nhưng vẫn thiếu customerName

**Check 1:** Verify DTO có đúng không
```bash
cd PTCMSS/ptcmss-backend/target/classes/org/example/ptcmssbackend/dto/response/Driver
cat DriverDashboardResponse.class | strings | grep customerName
```

**Check 2:** Verify Service có gọi đúng constructor không
```bash
cd PTCMSS/ptcmss-backend/target/classes/org/example/ptcmssbackend/service/impl
cat DriverServiceImpl.class | strings | grep customerName
```

**Solution:** Clean rebuild
```bash
mvn clean install -DskipTests
```

### Issue 2: customerName = null trong response

**Cause:** Customer không có fullName trong database

**Check:**
```sql
SELECT c.customerId, c.fullName, c.phone
FROM Customers c
WHERE c.customerId = (
    SELECT b.customerId FROM Bookings b
    WHERE b.bookingId = (
        SELECT t.bookingId FROM Trips t WHERE t.tripId = 38
    )
);
```

**Solution:**
```sql
UPDATE Customers 
SET fullName = 'Nguyễn Văn A'
WHERE customerId = [ID từ query trên];
```

### Issue 3: distance = null

**Cause:** Trip không có distance trong database

**Solution:**
```sql
UPDATE Trips 
SET distance = 169.5
WHERE tripId = 38;
```

---

## Verification Checklist

- [ ] Backend đã restart sau khi update code
- [ ] Backend logs hiển thị customerName
- [ ] Database có fullName cho customer
- [ ] Database có distance cho trip
- [ ] API response có customerName field
- [ ] API response có distance field
- [ ] Frontend console log hiển thị customerName
- [ ] UI hiển thị tên khách hàng
- [ ] UI hiển thị quãng đường

---

## Expected Final Result

**API Response:**
```json
{
  "customerName": "Nguyễn Văn A",
  "customerPhone": "0987456321",
  "distance": 169.5
}
```

**UI Display:**
```
┌──────────────────────────────────────────────────────────┐
│ 📍 Điểm đón      👤 Khách hàng    📞 Liên hệ    🗺️ Quãng đường │
│ Hồ Chí Minh      Nguyễn Văn A    0987456321   169.5 km  │
└──────────────────────────────────────────────────────────┘
```

---

## Next Steps

1. **STOP backend** (Ctrl+C)
2. **Clean build**: `mvn clean install -DskipTests`
3. **Restart**: `mvn spring-boot:run`
4. **Check logs** khi load dashboard
5. **Update database** nếu thiếu data
6. **Test API** với curl/Postman
7. **Reload frontend** và verify UI

**Quan trọng:** Backend PHẢI restart để code mới có hiệu lực!
