# 🌟 Driver Rating & Performance System

## Tổng quan

Hệ thống đánh giá và theo dõi hiệu suất tài xế cho phép:
- ⭐ Đánh giá tài xế sau mỗi chuyến hoàn thành (1-5 sao)
- 📊 Theo dõi hiệu suất theo 4 tiêu chí: Đúng giờ, Thái độ, An toàn, Tuân thủ
- 📈 Tổng hợp và hiển thị rating trung bình 30 ngày
- 💬 Lưu trữ comment và feedback từ khách hàng

## ✅ Checklist triển khai

### 1. Database
- [x] Chạy migration script: `12_CREATE_DRIVER_RATINGS.sql`
- [x] Verify bảng `DriverRatings` đã được tạo
- [x] Verify trigger tính `overallRating` hoạt động
- [x] Verify view `DriverRatingSummary` có dữ liệu

### 2. Backend
- [x] Entity: `DriverRatings.java`
- [x] Repository: `DriverRatingsRepository.java`
- [x] Service: `RatingService.java` + `RatingServiceImpl.java`
- [x] Controller: `RatingController.java`
- [x] DTOs: `RatingRequest`, `RatingResponse`, `DriverPerformanceResponse`

### 3. Frontend
- [x] API client: `src/api/ratings.js`
- [x] Components:
  - [x] `RateDriverDialog.jsx` - Dialog đánh giá
  - [x] `DriverPerformance.jsx` - Hiển thị hiệu suất
  - [x] `StarRating.jsx` - Component rating stars
  - [x] `TripRatingButton.jsx` - Button tích hợp vào trip

### 4. Integration
- [ ] Tích hợp `TripRatingButton` vào Trip Detail page
- [ ] Tích hợp `DriverPerformance` vào Driver Detail page
- [ ] Hiển thị `StarRating` trong Driver List
- [ ] (Optional) Thêm widget "Top Rated Drivers" vào Dashboard

## 🚀 Quick Start

### Bước 1: Database Setup
```bash
# Kết nối MySQL
mysql -u root -p ptcmss_db

# Chạy migration
source PTCMSS/db_scripts/12_CREATE_DRIVER_RATINGS.sql;

# Verify
SELECT * FROM DriverRatings LIMIT 5;
SELECT * FROM DriverRatingSummary;
```

### Bước 2: Backend (đã hoàn thành)
Backend đã được implement đầy đủ. Restart server để load các class mới:
```bash
cd PTCMSS/ptcmss-backend
mvn clean install
mvn spring-boot:run
```

### Bước 3: Frontend Integration

#### A. Thêm vào Trip Detail
```jsx
// TripDetail.jsx
import TripRatingButton from './components/module 5/TripRatingButton';

function TripDetail() {
  return (
    <div>
      {/* ... trip info ... */}
      
      {/* Thêm button đánh giá */}
      <TripRatingButton 
        trip={trip}
        onRatingComplete={() => {
          // Refresh data hoặc show message
          loadTripDetail();
        }}
      />
    </div>
  );
}
```

#### B. Thêm vào Driver Detail
```jsx
// DriverDetail.jsx
import DriverPerformance from './components/module 5/DriverPerformance';

function DriverDetail() {
  return (
    <div>
      {/* ... driver info ... */}
      
      {/* Tab hiệu suất */}
      <DriverPerformance driverId={driverId} />
    </div>
  );
}
```

#### C. Thêm vào Driver List
```jsx
// DriverList.jsx
import StarRating from './components/common/StarRating';

function DriverList() {
  return (
    <table>
      <tbody>
        {drivers.map(driver => (
          <tr key={driver.driverId}>
            <td>{driver.fullName}</td>
            <td><StarRating rating={driver.rating} /></td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

## 📋 API Endpoints

### POST /api/ratings
Tạo đánh giá mới
```json
{
  "tripId": 1,
  "punctualityRating": 5,
  "attitudeRating": 5,
  "safetyRating": 4,
  "complianceRating": 5,
  "comment": "Tài xế rất tốt"
}
```

### GET /api/ratings/trip/{tripId}
Lấy đánh giá của một chuyến

### GET /api/ratings/driver/{driverId}?limit=10
Lấy danh sách đánh giá của tài xế

### GET /api/ratings/driver/{driverId}/performance?days=30
Lấy thống kê hiệu suất tài xế

## 🎨 UI Components

### 1. RateDriverDialog
Modal popup để đánh giá tài xế:
- 4 tiêu chí với 5 sao mỗi tiêu chí
- Textarea cho comment (optional)
- Validation: Phải đánh giá đủ 4 tiêu chí
- Auto-close sau khi submit thành công

### 2. DriverPerformance
Hiển thị hiệu suất tài xế:
- Overall rating card (lớn, nổi bật)
- Grid 4 tiêu chí với stars
- Dropdown chọn khoảng thời gian (7/30/90 ngày)
- List 10 đánh giá gần nhất

### 3. StarRating
Component tái sử dụng:
- Props: `rating`, `size`, `showValue`
- Tự động fill màu vàng cho số sao
- Hiển thị giá trị số (optional)

### 4. TripRatingButton
Smart button tự động check:
- Nếu trip chưa COMPLETED: Không hiển thị
- Nếu đã rated: Hiển thị "Đã đánh giá" + stars
- Nếu chưa rated: Hiển thị nút "Đánh giá tài xế"

## 📊 Business Logic

### Tính toán Rating
1. User đánh giá 4 tiêu chí (1-5 sao mỗi tiêu chí)
2. Database trigger tự động tính `overallRating` = trung bình 4 tiêu chí
3. Backend service update `Drivers.rating` = trung bình tất cả ratings trong 30 ngày gần nhất

### Validation Rules
- Chỉ đánh giá được trip có status = COMPLETED
- Mỗi trip chỉ được đánh giá 1 lần (unique constraint)
- Tất cả 4 tiêu chí phải được đánh giá (1-5)
- Comment là optional

### Performance Calculation
- Mặc định: 30 ngày gần nhất
- Có thể chọn: 7, 30, hoặc 90 ngày
- Tính AVG cho từng tiêu chí riêng biệt
- Hiển thị 10 ratings gần nhất

## 🧪 Testing

### Test Case 1: Đánh giá chuyến hoàn thành
1. Tạo trip với status COMPLETED
2. Vào Trip Detail
3. Click "Đánh giá tài xế"
4. Chọn sao cho 4 tiêu chí
5. Nhập comment (optional)
6. Submit
7. Verify: Nút đổi thành "Đã đánh giá"

### Test Case 2: Không thể đánh giá 2 lần
1. Đánh giá trip lần 1 (thành công)
2. Refresh page
3. Verify: Hiển thị "Đã đánh giá" thay vì button
4. Try đánh giá lại qua API → Lỗi "Trip already rated"

### Test Case 3: Hiển thị hiệu suất
1. Tạo 5-10 ratings cho 1 driver
2. Vào Driver Detail
3. Click tab "Hiệu suất"
4. Verify: Hiển thị đúng AVG cho 4 tiêu chí
5. Verify: List recent ratings hiển thị đúng

### Test Case 4: Update driver overall rating
1. Driver có rating = 4.5
2. Tạo rating mới = 5.0
3. Verify: Driver.rating được update (trung bình 30 ngày)

## 📁 File Structure

```
PTCMSS/
├── db_scripts/
│   └── 12_CREATE_DRIVER_RATINGS.sql
├── ptcmss-backend/
│   └── src/main/java/.../
│       ├── entity/
│       │   └── DriverRatings.java
│       ├── repository/
│       │   └── DriverRatingsRepository.java
│       ├── service/
│       │   ├── RatingService.java
│       │   └── impl/RatingServiceImpl.java
│       ├── controller/
│       │   └── RatingController.java
│       └── dto/
│           ├── RatingRequest.java
│           ├── RatingResponse.java
│           └── DriverPerformanceResponse.java
└── docs/
    ├── DRIVER_RATING_README.md (this file)
    ├── DRIVER_RATING_USAGE.md
    └── DRIVER_RATING_IMPLEMENTATION.md

PTCMSS_FRONTEND/
└── src/
    ├── api/
    │   └── ratings.js
    └── components/
        ├── common/
        │   └── StarRating.jsx
        └── module 5/
            ├── RateDriverDialog.jsx
            ├── DriverPerformance.jsx
            ├── TripRatingButton.jsx
            ├── TripDetailWithRating.example.jsx
            └── DriverDetailWithPerformance.example.jsx
```

## 🔧 Configuration

### Thay đổi số ngày tính trung bình
File: `RatingServiceImpl.java`
```java
private void updateDriverOverallRating(Integer driverId) {
    // Đổi 30 thành số ngày mong muốn
    Instant since = Instant.now().minus(30, ChronoUnit.DAYS);
    // ...
}
```

### Thêm tiêu chí đánh giá mới
1. Update database: Thêm column vào `DriverRatings`
2. Update trigger: Sửa công thức tính `overallRating`
3. Update entity: Thêm field vào `DriverRatings.java`
4. Update DTO: Thêm field vào `RatingRequest.java`
5. Update UI: Thêm vào `criteria` array trong `RateDriverDialog.jsx`

## 📞 Support

Nếu gặp vấn đề:
1. Check console log (browser & server)
2. Verify database tables đã được tạo
3. Check API response trong Network tab
4. Xem file `DRIVER_RATING_USAGE.md` để biết chi tiết

## 🎯 Next Steps

- [ ] Tích hợp vào các trang hiện có
- [ ] Test với dữ liệu thực
- [ ] Thêm widget "Top Rated Drivers" vào Dashboard
- [ ] Email notification khi nhận rating mới
- [ ] Export rating reports
