# SerpAPI Google Maps Integration - Auto Distance Calculation

## Tổng quan

Đã tích hợp **SerpAPI Google Maps Directions API** để tự động tính khoảng cách giữa điểm đi và điểm đến trong module Booking.

### Tính năng

✅ **Tự động tính khoảng cách**: Khi người dùng nhập điểm đi và điểm đến, hệ thống sẽ tự động gọi SerpAPI để tính khoảng cách (km)
✅ **Tự động tính giá**: Giá cước được tính dựa trên khoảng cách tự động
✅ **Lưu database**: Khoảng cách được lưu vào bảng `Trips`
✅ **Fallback**: Nếu API lỗi, người dùng vẫn có thể nhập thủ công

---

## Các file đã thay đổi

### 1. Frontend

#### **Mới tạo:**
- `PTCMSS_FRONTEND/src/api/serpapi.js` - Service gọi SerpAPI

#### **Đã cập nhật:**
- `PTCMSS_FRONTEND/src/components/module 4/CreateOrderPage.jsx`
  - Import `calculateDistance` từ serpapi.js
  - Thêm states: `calculatingDistance`, `distanceError`
  - Thêm useEffect để auto-calculate distance khi pickup/dropoff thay đổi
  - Cập nhật UI hiển thị trạng thái calculating

- `PTCMSS_FRONTEND/src/components/module 4/EditOrderPage.jsx`
  - Tương tự CreateOrderPage
  - Load distance từ backend khi edit

### 2. Backend

#### **Database Migration:**
- `PTCMSS/db_scripts/11_ADD_DISTANCE_COLUMN.sql` - Migration script thêm cột `distance`

#### **Entity:**
- `PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/entity/Trips.java`
  - Thêm field `distance: BigDecimal`

#### **DTOs:**
- `PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/dto/request/Booking/TripRequest.java`
  - Thêm field `distance: Double`

- `PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/dto/response/Booking/TripResponse.java`
  - Thêm field `distance: Double`

#### **Service:**
- `PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/service/impl/BookingServiceImpl.java`
  - Cập nhật logic tạo/update Trip để lưu distance
  - Cập nhật mapper để trả về distance trong response

---

## Cách hoạt động

### Flow tự động tính khoảng cách:

1. **Người dùng nhập địa chỉ**
   - Điểm đi: "Hanoi Airport Terminal 1"
   - Điểm đến: "Pearl Westlake Hotel Hanoi"

2. **Frontend debounce 1.5s**
   - Sau 1.5s không nhập, gọi `calculateDistance(pickup, dropoff)`

3. **SerpAPI Request**
   ```javascript
   GET https://serpapi.com/search
   ?engine=google_maps_directions
   &api_key=YOUR_API_KEY
   &start_addr=Hanoi Airport Terminal 1
   &end_addr=Pearl Westlake Hotel Hanoi
   &travel_mode=0  // Driving
   &distance_unit=0  // Kilometers
   ```

4. **SerpAPI Response**
   ```json
   {
     "directions": [{
       "distance": 13400,  // meters
       "duration": 1200,   // seconds
       "formatted_distance": "13.4 km",
       "formatted_duration": "20 phút"
     }]
   }
   ```

5. **Frontend xử lý**
   - Convert meters → kilometers: `13400 / 1000 = 13.4`
   - Tự động điền vào input khoảng cách
   - Trigger calculate price với distance mới

6. **Backend lưu**
   - Khi submit booking, distance được gửi trong `TripRequest`
   - Backend lưu vào `Trips.distance`

---

## API Key Configuration

### Frontend
API key được hardcode trong `serpapi.js`:
```javascript
const SERPAPI_KEY = "d403ede6a15a2684e960ee9be9eb913a534330bf909263934657741c7f326742";
```

### Backend (Optional)
Nếu muốn tạo proxy endpoint để bảo mật API key:
```java
// BookingController.java
@PostMapping("/calculate-distance")
public DistanceResponse calculateDistance(@RequestBody DistanceRequest request) {
    // Call SerpAPI from backend
    // Return distance to frontend
}
```

---

## Database Schema

### Bảng `Trips`

```sql
CREATE TABLE Trips (
  tripId INT AUTO_INCREMENT PRIMARY KEY,
  bookingId INT NOT NULL,
  startLocation VARCHAR(255),
  endLocation VARCHAR(255),
  distance DECIMAL(10,2) NULL,  -- 👈 New column (in kilometers)
  useHighway BOOLEAN NULL,
  startTime DATETIME NULL,
  endTime DATETIME NULL,
  status ENUM('PENDING','ASSIGNED','IN_PROGRESS','COMPLETED','CANCELLED'),
  ...
);
```

### Migration

Chạy script migration:
```bash
mysql -u root -p ptcmss < PTCMSS/db_scripts/11_ADD_DISTANCE_COLUMN.sql
```

---

## Testing

### Test Case 1: Auto-calculate distance
1. Mở CreateOrderPage
2. Nhập điểm đi: "Hanoi Airport"
3. Nhập điểm đến: "Hoan Kiem Lake Hanoi"
4. Đợi 1.5s
5. **Expected**: Khoảng cách tự động hiển thị (VD: 28.5 km)

### Test Case 2: Manual input on error
1. Mở CreateOrderPage
2. Nhập điểm đi: "xyz123invalid"
3. Nhập điểm đến: "abc456invalid"
4. Đợi 1.5s
5. **Expected**: Hiển thị lỗi, cho phép nhập thủ công

### Test Case 3: Price calculation
1. Tạo booking với distance = 50 km
2. Chọn loại xe: Sedan 4 chỗ
3. **Expected**:
   - Giá = baseFare + (pricePerKm × 50)
   - VD: 100,000đ + (10,000đ × 50) = 600,000đ

---

## Error Handling

### Các trường hợp lỗi:

1. **SerpAPI không tìm thấy route**
   - Error: "No route found between the two locations"
   - Fallback: Cho phép nhập thủ công

2. **API key invalid/expired**
   - Error: "SerpAPI error: 401 Unauthorized"
   - Solution: Kiểm tra API key tại https://serpapi.com/manage-api-key

3. **Quota exceeded**
   - Error: "SerpAPI error: 429 Too Many Requests"
   - Solution: Nâng cấp plan hoặc đợi reset quota

4. **Network error**
   - Error: "Failed to fetch"
   - Fallback: Cho phép nhập thủ công

---

## SerpAPI Pricing

### Free Tier
- **100 searches/tháng** miễn phí
- Không cần credit card

### Developer Plan
- **$50/tháng**: 5,000 searches
- **$0.01/search** nếu vượt quota

### Production Plan
- **$250/tháng**: 30,000 searches
- **$0.008/search** nếu vượt quota

🔗 Chi tiết: https://serpapi.com/pricing

---

## Best Practices

### 1. Debounce Input
✅ **Đã implement**: Debounce 1.5s để giảm số lượng API calls

### 2. Cache Results (Optional - chưa implement)
```javascript
// Cache kết quả trong localStorage
const cacheKey = `distance_${pickup}_${dropoff}`;
const cached = localStorage.getItem(cacheKey);
if (cached) {
  return JSON.parse(cached);
}
```

### 3. Validate Input
✅ **Đã implement**: Chỉ call API khi địa chỉ > 5 ký tự

### 4. Error Messages
✅ **Đã implement**: Hiển thị toast notification khi lỗi

---

## Alternative Solutions

Nếu muốn chuyển sang Google Maps API chính thức:

### Google Maps Distance Matrix API
```javascript
const service = new google.maps.DistanceMatrixService();
service.getDistanceMatrix({
  origins: [pickup],
  destinations: [dropoff],
  travelMode: 'DRIVING',
  unitSystem: google.maps.UnitSystem.METRIC,
}, callback);
```

**Ưu điểm:**
- Official API, độ tin cậy cao
- Free credit $200/tháng

**Nhược điểm:**
- Setup phức tạp hơn (billing, API key, restrictions)
- Cần enable Google Cloud Platform

---

## Troubleshooting

### Issue: Khoảng cách không tự động tính

**Kiểm tra:**
1. Console log có error không?
2. API key còn valid không?
3. Địa chỉ có đủ cụ thể không? (Nên có tên thành phố)

### Issue: Giá không tự động cập nhật

**Kiểm tra:**
1. `distanceKm` state có thay đổi không?
2. useEffect tính giá có chạy không?
3. Backend API `/calculate-price` có nhận đúng distance không?

### Issue: Database không lưu distance

**Kiểm tra:**
1. Migration đã chạy chưa?
2. Backend DTO có field `distance` chưa?
3. Service có set `trip.setDistance()` chưa?

---

## Future Enhancements

### 1. Places Autocomplete
```javascript
// Gợi ý địa điểm khi nhập
const suggestions = await searchPlaces(query);
```

### 2. Multiple Routes
- Hiển thị nhiều tuyến đường
- Cho phép chọn tuyến ngắn nhất/nhanh nhất

### 3. Real-time Traffic
- Tính toán dựa trên traffic hiện tại
- Cảnh báo nếu có tắc đường

### 4. Cost Estimation Breakdown
- Chi phí nhiên liệu
- Chi phí cao tốc
- Chi phí tài xế

---

## Support

### SerpAPI Documentation
- Directions API: https://serpapi.com/google-maps-directions-api
- Dashboard: https://serpapi.com/dashboard

### Contact
- Technical issues: Liên hệ team developer
- API issues: support@serpapi.com

---

**Last Updated:** 2025-11-20
**Version:** 1.0
**Author:** Claude Code (AI Assistant)
