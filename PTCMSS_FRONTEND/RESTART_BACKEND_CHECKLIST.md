# ⚡ Restart Backend - Quick Checklist

## Vấn đề
API response thiếu `customerName`:
```json
{
  "customerPhone": "0987456321",  ✅
  "distance": null                ❌
  // customerName: THIẾU           ❌
}
```

---

## ✅ Giải pháp - 3 bước đơn giản:

### 1️⃣ Fix Database (1 phút)
```sql
-- Chạy file này:
source PTCMSS/db_scripts/13_FIX_TRIP_38_DATA.sql;

-- Hoặc copy-paste vào MySQL:
UPDATE Trips SET distance = 169.5 WHERE tripId = 38;

UPDATE Customers 
SET fullName = 'Nguyễn Văn A'
WHERE customerId = (
    SELECT customerId FROM Bookings 
    WHERE bookingId = (SELECT bookingId FROM Trips WHERE tripId = 38)
);
```

### 2️⃣ Restart Backend (2 phút)
```bash
# Terminal 1: Stop backend (Ctrl+C)

# Clean build
cd PTCMSS/ptcmss-backend
mvn clean install -DskipTests

# Restart
mvn spring-boot:run
```

### 3️⃣ Reload Frontend (5 giây)
```
Browser: Ctrl + Shift + R
```

---

## ✅ Verify Success

### Check 1: Backend Logs
```
[DriverDashboard] Customer: Nguyễn Văn A - 0987456321
[DriverDashboard] Trip ID: 38, Distance: 169.5
```

### Check 2: API Response
```json
{
  "customerName": "Nguyễn Văn A",    ✅
  "customerPhone": "0987456321",     ✅
  "distance": 169.5                  ✅
}
```

### Check 3: Frontend Console
```javascript
📊 Dashboard API Response: {
  customerName: "Nguyễn Văn A",
  customerPhone: "0987456321",
  distance: 169.5
}
```

### Check 4: UI Display
```
┌────────────────────────────────────────────────┐
│ 👤 Khách hàng    📞 Liên hệ    🗺️ Quãng đường    │
│ Nguyễn Văn A    0987456321   169.5 km        │
└────────────────────────────────────────────────┘
```

---

## 🚨 Nếu vẫn không work:

### Option A: Hard Clean
```bash
cd PTCMSS/ptcmss-backend
mvn clean
rm -rf target/
mvn install -DskipTests
mvn spring-boot:run
```

### Option B: Check Compilation
```bash
# Verify class file có customerName
cd target/classes/org/example/ptcmssbackend/dto/response/Driver
javap DriverDashboardResponse.class | grep customerName
```

### Option C: Manual Test
```bash
# Test API trực tiếp
curl http://localhost:8080/api/drivers/1/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📝 Summary

**Đã làm:**
- ✅ Code backend có customerName
- ✅ Code frontend có customerName
- ⏳ Backend chưa restart → **CẦN LÀM**
- ⏳ Database thiếu data → **CẦN FIX**

**Cần làm:**
1. Chạy SQL script fix data
2. Restart backend
3. Reload frontend
4. Verify UI

**Thời gian:** ~3 phút

**Kết quả:** Tất cả 3 thông tin hiển thị đầy đủ! 🎉
