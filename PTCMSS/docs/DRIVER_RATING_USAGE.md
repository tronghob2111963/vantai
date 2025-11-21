# Driver Rating & Performance - Hướng dẫn sử dụng

## 📋 Tổng quan

Hệ thống đánh giá tài xế cho phép đánh giá hiệu suất tài xế sau mỗi chuyến hoàn thành với 4 tiêu chí:
- ⏰ **Đúng giờ** (Punctuality)
- 😊 **Thái độ** (Attitude)  
- 🛡️ **An toàn** (Safety)
- ✅ **Tuân thủ quy trình** (Compliance)

Mỗi tiêu chí được đánh giá từ 1-5 sao, và hệ thống tự động tính điểm trung bình tổng thể.

## ✅ Đã hoàn thành

### Backend
- ✅ Database schema (`12_CREATE_DRIVER_RATINGS.sql`)
- ✅ Entity: `DriverRatings.java`
- ✅ Repository: `DriverRatingsRepository.java`
- ✅ Service: `RatingService.java` & `RatingServiceImpl.java`
- ✅ Controller: `RatingController.java`
- ✅ DTOs: `RatingRequest`, `RatingResponse`, `DriverPerformanceResponse`

### Frontend
- ✅ API client: `ratings.js`
- ✅ Dialog đánh giá: `RateDriverDialog.jsx`
- ✅ Hiển thị hiệu suất: `DriverPerformance.jsx`
- ✅ Component rating stars: `StarRating.jsx`
- ✅ Button tích hợp: `TripRatingButton.jsx`

## 🚀 Cách sử dụng

### 1. Chạy Database Migration

```sql
-- Chạy script tạo bảng
source PTCMSS/db_scripts/12_CREATE_DRIVER_RATINGS.sql;
```

### 2. Backend API Endpoints

#### Tạo đánh giá mới
```http
POST /api/ratings
Content-Type: application/json

{
  "tripId": 1,
  "punctualityRating": 5,
  "attitudeRating": 5,
  "safetyRating": 4,
  "complianceRating": 5,
  "comment": "Tài xế rất tốt, lái xe an toàn"
}
```

#### Lấy đánh giá của một chuyến
```http
GET /api/ratings/trip/{tripId}
```

#### Lấy tất cả đánh giá của tài xế
```http
GET /api/ratings/driver/{driverId}?limit=10
```

#### Lấy hiệu suất tài xế (30 ngày)
```http
GET /api/ratings/driver/{driverId}/performance?days=30
```

### 3. Frontend Integration

#### A. Thêm nút đánh giá vào Trip Detail

```jsx
import TripRatingButton from './components/module 5/TripRatingButton';

function TripDetail({ trip }) {
  return (
    <div>
      {/* Trip info */}
      
      {/* Rating button - chỉ hiện khi status = COMPLETED */}
      <TripRatingButton 
        trip={trip}
        onRatingComplete={() => {
          // Refresh trip data or show success message
          console.log('Rating completed!');
        }}
      />
    </div>
  );
}
```

#### B. Hiển thị rating trong Driver List

```jsx
import StarRating from './components/common/StarRating';

function DriverList({ drivers }) {
  return (
    <table>
      <tbody>
        {drivers.map(driver => (
          <tr key={driver.driverId}>
            <td>{driver.fullName}</td>
            <td>
              <StarRating rating={driver.rating} />
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

#### C. Hiển thị hiệu suất trong Driver Detail

```jsx
import DriverPerformance from './components/module 5/DriverPerformance';

function DriverDetail({ driverId }) {
  return (
    <div>
      {/* Driver info */}
      
      {/* Performance tab */}
      <div className="mt-6">
        <DriverPerformance driverId={driverId} />
      </div>
    </div>
  );
}
```

## 📊 Luồng hoạt động

### 1. Đánh giá tài xế
```
User xem Trip Detail (status = COMPLETED)
  ↓
Hiển thị nút "Đánh giá tài xế"
  ↓
Click → Mở RateDriverDialog
  ↓
User chọn sao cho 4 tiêu chí + comment (optional)
  ↓
Submit → POST /api/ratings
  ↓
Backend:
  - Validate trip COMPLETED
  - Validate chưa có rating
  - Create DriverRatings
  - Trigger tự động tính overallRating
  - Update Drivers.rating (trung bình 30 ngày)
  ↓
Success → Hiển thị "Đã đánh giá" với stars
```

### 2. Xem hiệu suất tài xế
```
Vào trang Driver Detail
  ↓
GET /api/ratings/driver/{id}/performance?days=30
  ↓
Backend:
  - Query DriverRatings trong 30 ngày
  - Tính AVG cho từng tiêu chí
  - Lấy recent ratings
  ↓
Frontend hiển thị:
  - Overall rating card
  - 4 tiêu chí breakdown
  - Recent ratings list
```

## 🎨 UI Components

### RateDriverDialog
- Modal popup với 4 tiêu chí đánh giá
- Mỗi tiêu chí có 5 sao để chọn
- Textarea cho comment (optional)
- Validation: Phải đánh giá đủ 4 tiêu chí

### DriverPerformance
- Card tổng quan với overall rating lớn
- Grid 2x2 hiển thị 4 tiêu chí
- Dropdown chọn khoảng thời gian (7/30/90 ngày)
- List recent ratings với comment

### StarRating
- Component tái sử dụng để hiển thị rating
- Props: rating (number), size, showValue
- Tự động fill màu vàng cho số sao tương ứng

### TripRatingButton
- Tự động check xem trip đã được đánh giá chưa
- Nếu chưa: Hiển thị nút "Đánh giá tài xế"
- Nếu rồi: Hiển thị "Đã đánh giá" với stars

## 🔧 Tùy chỉnh

### Thay đổi số ngày tính trung bình
Mặc định là 30 ngày. Để thay đổi:

```java
// RatingServiceImpl.java
private void updateDriverOverallRating(Integer driverId) {
    Instant since = Instant.now().minus(60, ChronoUnit.DAYS); // Đổi thành 60 ngày
    // ...
}
```

### Thêm tiêu chí đánh giá mới
1. Thêm column vào bảng `DriverRatings`
2. Update trigger `before_driver_rating_insert`
3. Thêm field vào `DriverRatings.java`
4. Update `RatingRequest.java`
5. Thêm vào `criteria` array trong `RateDriverDialog.jsx`

## 📝 Testing

### Test data
```sql
-- Insert test ratings
INSERT INTO DriverRatings (tripId, driverId, customerId, punctualityRating, attitudeRating, safetyRating, complianceRating, comment, ratedBy)
VALUES 
(1, 1, 1, 5, 5, 4, 5, 'Tài xế rất tốt', 1),
(2, 1, 2, 4, 5, 5, 4, 'Lái xe an toàn', 1),
(3, 2, 1, 3, 4, 4, 3, 'Bình thường', 1);

-- Check average
SELECT * FROM DriverRatingSummary;
```

### Manual testing
1. Tạo trip với status COMPLETED
2. Vào Trip Detail, click "Đánh giá tài xế"
3. Chọn sao cho 4 tiêu chí, nhập comment
4. Submit và verify:
   - Rating được lưu vào DB
   - Nút đổi thành "Đã đánh giá"
   - Driver.rating được update
5. Vào Driver Detail, check Performance tab

## 🐛 Troubleshooting

### Lỗi "Trip already rated"
- Mỗi trip chỉ được đánh giá 1 lần
- Check bảng DriverRatings xem đã có rating cho tripId chưa

### Lỗi "Can only rate completed trips"
- Chỉ có thể đánh giá trip với status = COMPLETED
- Update trip status trước khi đánh giá

### Rating không hiển thị
- Check API response trong Network tab
- Verify driverId và tripId đúng
- Check console log có error không

## 📈 Future Enhancements

- [ ] Dashboard widget "Top Rated Drivers"
- [ ] Email notification khi nhận rating mới
- [ ] Export rating reports
- [ ] Rating trends chart
- [ ] Compare drivers performance
- [ ] Customer rating history
