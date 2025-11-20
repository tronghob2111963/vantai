# 🔧 Troubleshooting - Driver Rating

## ❌ Lỗi gặp phải

### 1. Backend Error: "Can only rate completed trips"
```
java.lang.RuntimeException: Can only rate completed trips
```

**Nguyên nhân**: Trip không có status = 'COMPLETED'

**Giải pháp**: Chạy script SQL để update trips thành COMPLETED

```sql
-- File: PTCMSS/db_scripts/14_CREATE_COMPLETED_TRIPS_FOR_RATING.sql
UPDATE Trips 
SET status = 'COMPLETED',
    endTime = NOW()
WHERE tripId IN (1, 2, 3);
```

---

### 2. Frontend Error: "Failed to resolve import './config'"
```
Failed to resolve import "./config" from "src/api/ratings.js"
```

**Nguyên nhân**: File `ratings.js` import sai tên file

**Giải pháp**: ✅ Đã sửa - Đổi từ `./config` thành `./http`

---

### 3. Frontend Error: "Unexpected token '<', '<!doctype'..."
```
SyntaxError: Unexpected token '<', "<!doctype "... is not valid JSON
```

**Nguyên nhân**: API endpoint `/api/trips?status=COMPLETED` không tồn tại, server trả về HTML thay vì JSON

**Giải pháp**: ✅ Đã sửa - Dùng mock data thay vì gọi API chưa có

---

## ✅ Đã sửa

### Frontend (RatingManagementPage.jsx)
- ✅ Comment API call chưa có
- ✅ Dùng mock data để demo
- ✅ Vẫn check rating status qua API `/api/ratings/trip/{tripId}`

### Code hiện tại:
```javascript
const loadTrips = async () => {
  setLoading(true);
  try {
    // TODO: Replace with actual API call
    // const response = await fetch('/api/trips?status=COMPLETED');
    
    // Mock data for demo
    const mockTrips = [
      { tripId: 1, driverName: 'Nguyễn Văn A', ... },
      { tripId: 2, driverName: 'Trần Văn B', ... },
      { tripId: 3, driverName: 'Lê Văn C', ... },
    ];
    
    // Check rating status for each trip
    const tripsWithRating = await Promise.all(
      mockTrips.map(async (trip) => {
        try {
          const ratingResponse = await getRatingByTrip(trip.tripId);
          return { ...trip, hasRating: !!ratingResponse.data, rating: ratingResponse.data };
        } catch {
          return { ...trip, hasRating: false, rating: null };
        }
      })
    );
    
    setTrips(tripsWithRating);
  } catch (error) {
    console.error('Error loading trips:', error);
    setTrips([]);
  } finally {
    setLoading(false);
  }
};
```

---

## 🚀 Cách test ngay

### Bước 1: Update database
```bash
mysql -u root -p ptcmss_db < PTCMSS/db_scripts/14_CREATE_COMPLETED_TRIPS_FOR_RATING.sql
```

### Bước 2: Restart backend
```bash
cd PTCMSS/ptcmss-backend
mvn spring-boot:run
```

### Bước 3: Test frontend
1. Vào menu "Điều phối / Lịch chạy" → "Đánh giá tài xế"
2. Bạn sẽ thấy 3 trips mock data
3. Click "Đánh giá" trên trip 1, 2, hoặc 3
4. Chọn sao và submit

---

## 📋 Checklist

- [x] Sửa import `./config` → `./http` trong ratings.js
- [x] Comment API call chưa có trong RatingManagementPage
- [x] Dùng mock data để demo
- [x] Tạo script SQL update trips thành COMPLETED
- [ ] Chạy script SQL
- [ ] Test đánh giá trip

---

## 🔮 Tích hợp API thật sau này

Khi backend có API `/api/trips?status=COMPLETED`, uncomment dòng này:

```javascript
// Trong RatingManagementPage.jsx, dòng ~28
const response = await fetch('/api/trips?status=COMPLETED');
const data = await response.json();

// Và comment phần mock data
// const mockTrips = [...]
```

---

## 🐛 Nếu vẫn lỗi

### Lỗi: "Trip already rated"
- Trip đã được đánh giá rồi
- Thử trip khác hoặc xóa rating cũ:
```sql
DELETE FROM DriverRatings WHERE tripId = 1;
```

### Lỗi: "No driver assigned to this trip"
- Trip chưa có driver
- Gán driver cho trip:
```sql
INSERT INTO TripDrivers (tripId, driverId, driverRole)
VALUES (1, 1, 'Main Driver');
```

### Lỗi 400 khi submit rating
- Check console log backend
- Verify trip status = 'COMPLETED'
- Verify trip có driver
- Verify rating values (1-5)

---

## 📞 Debug tips

### Check trip status
```sql
SELECT tripId, status, startTime, endTime 
FROM Trips 
WHERE tripId = 1;
```

### Check trip driver
```sql
SELECT t.tripId, td.driverId, d.employeeId, u.fullName
FROM Trips t
JOIN TripDrivers td ON t.tripId = td.tripId
JOIN Drivers d ON td.driverId = d.driverId
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
WHERE t.tripId = 1;
```

### Check existing ratings
```sql
SELECT * FROM DriverRatings WHERE tripId = 1;
```

---

## ✨ Kết quả mong đợi

Sau khi sửa xong:
- ✅ Trang load được với 3 trips mock
- ✅ Click "Đánh giá" → Popup hiện ra
- ✅ Chọn sao → Submit thành công
- ✅ Nút đổi thành "Đã đánh giá"
- ✅ Backend log không có lỗi
