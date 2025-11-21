# 🌟 Hướng dẫn tích hợp Driver Rating vào Frontend

## 📁 Các file đã có sẵn

### 1. API Client
```
src/api/ratings.js
```
- `createRating(ratingData)` - Tạo đánh giá mới
- `getRatingByTrip(tripId)` - Lấy rating của trip
- `getDriverRatings(driverId, limit)` - Lấy tất cả ratings của driver
- `getDriverPerformance(driverId, days)` - Lấy thống kê hiệu suất

### 2. Components chính
```
src/components/module 5/
├── RateDriverDialog.jsx          ⭐ Dialog đánh giá tài xế
├── TripRatingButton.jsx          ⭐ Button tích hợp vào trip
├── DriverPerformance.jsx         ⭐ Hiển thị hiệu suất tài xế
├── TripDetailWithRating.example.jsx    📝 Ví dụ tích hợp vào Trip Detail
└── DriverDetailWithPerformance.example.jsx  📝 Ví dụ tích hợp vào Driver Detail

src/components/common/
└── StarRating.jsx                ⭐ Component hiển thị rating stars
```

## 🚀 Cách tích hợp

### Bước 1: Thêm nút đánh giá vào Trip Detail Page

**File cần sửa**: Trang chi tiết chuyến đi (Trip Detail)

```jsx
// Import component
import TripRatingButton from './components/module 5/TripRatingButton';

function TripDetail() {
  const [trip, setTrip] = useState(null);
  
  const loadTripDetail = async () => {
    // Load trip data...
  };

  return (
    <div className="trip-detail">
      {/* Thông tin chuyến đi */}
      <div className="trip-info">
        <h2>Chuyến #{trip.tripId}</h2>
        <p>Trạng thái: {trip.status}</p>
        {/* ... other trip info ... */}
      </div>

      {/* ⭐ THÊM BUTTON ĐÁNH GIÁ Ở ĐÂY */}
      {trip && (
        <div className="mt-4">
          <TripRatingButton 
            trip={trip}
            onRatingComplete={() => {
              // Reload trip data sau khi đánh giá
              loadTripDetail();
              // Hoặc show success message
              alert('Cảm ơn bạn đã đánh giá!');
            }}
          />
        </div>
      )}
    </div>
  );
}
```

**Lưu ý**: 
- Button chỉ hiển thị khi `trip.status === 'COMPLETED'`
- Nếu đã đánh giá rồi, sẽ hiển thị "Đã đánh giá" với số sao
- Nếu chưa đánh giá, hiển thị nút "Đánh giá tài xế"

### Bước 2: Thêm hiển thị rating trong Driver List

**File cần sửa**: Trang danh sách tài xế (Driver List)

```jsx
// Import component
import StarRating from './components/common/StarRating';

function DriverList() {
  const [drivers, setDrivers] = useState([]);

  return (
    <table className="table">
      <thead>
        <tr>
          <th>Tên tài xế</th>
          <th>Số điện thoại</th>
          <th>Đánh giá</th> {/* ⭐ Thêm cột này */}
          <th>Trạng thái</th>
        </tr>
      </thead>
      <tbody>
        {drivers.map(driver => (
          <tr key={driver.driverId}>
            <td>{driver.fullName}</td>
            <td>{driver.phone}</td>
            <td>
              {/* ⭐ THÊM RATING Ở ĐÂY */}
              <StarRating rating={driver.rating} size={16} />
            </td>
            <td>{driver.status}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

### Bước 3: Thêm tab Performance vào Driver Detail Page

**File cần sửa**: Trang chi tiết tài xế (Driver Detail)

```jsx
// Import component
import DriverPerformance from './components/module 5/DriverPerformance';
import StarRating from './components/common/StarRating';

function DriverDetail() {
  const { driverId } = useParams();
  const [driver, setDriver] = useState(null);
  const [activeTab, setActiveTab] = useState('info'); // 'info' hoặc 'performance'

  return (
    <div className="driver-detail">
      {/* Header với rating */}
      <div className="driver-header">
        <h2>{driver.fullName}</h2>
        <StarRating rating={driver.rating} size={20} />
      </div>

      {/* Tabs */}
      <div className="tabs">
        <button 
          onClick={() => setActiveTab('info')}
          className={activeTab === 'info' ? 'active' : ''}
        >
          Thông tin
        </button>
        <button 
          onClick={() => setActiveTab('performance')}
          className={activeTab === 'performance' ? 'active' : ''}
        >
          Hiệu suất
        </button>
      </div>

      {/* Tab content */}
      <div className="tab-content">
        {activeTab === 'info' && (
          <div>
            {/* Thông tin tài xế */}
            <p>Số điện thoại: {driver.phone}</p>
            <p>GPLX: {driver.licenseNumber}</p>
            {/* ... */}
          </div>
        )}

        {activeTab === 'performance' && (
          /* ⭐ THÊM PERFORMANCE COMPONENT Ở ĐÂY */
          <DriverPerformance driverId={driverId} />
        )}
      </div>
    </div>
  );
}
```

## 📝 Ví dụ hoàn chỉnh

Tôi đã tạo sẵn 2 file ví dụ hoàn chỉnh cho bạn tham khảo:

### 1. Trip Detail với Rating
```
src/components/module 5/TripDetailWithRating.example.jsx
```
- Ví dụ đầy đủ cách tích hợp `TripRatingButton`
- Có xử lý loading, error
- Có callback sau khi đánh giá thành công

### 2. Driver Detail với Performance
```
src/components/module 5/DriverDetailWithPerformance.example.jsx
```
- Ví dụ đầy đủ cách tích hợp `DriverPerformance`
- Có tabs chuyển đổi giữa Info và Performance
- Có hiển thị rating trong header

## 🎨 UI Components chi tiết

### 1. RateDriverDialog
**Khi nào hiển thị**: Khi user click nút "Đánh giá tài xế"

**Tính năng**:
- 4 tiêu chí đánh giá với 5 sao mỗi tiêu chí:
  - ⏰ Đúng giờ
  - 😊 Thái độ
  - 🛡️ An toàn
  - ✅ Tuân thủ quy trình
- Textarea cho comment (optional)
- Validation: Phải đánh giá đủ 4 tiêu chí
- Auto-close sau khi submit thành công

### 2. TripRatingButton
**Smart button** tự động:
- Check xem trip đã COMPLETED chưa → Nếu chưa: Không hiển thị
- Check xem đã đánh giá chưa → Nếu rồi: Hiển thị "Đã đánh giá" + stars
- Nếu chưa đánh giá: Hiển thị nút "Đánh giá tài xế"

**Props**:
```jsx
<TripRatingButton 
  trip={tripObject}              // Required: Object chứa tripId, status, driverName
  onRatingComplete={() => {}}    // Optional: Callback sau khi đánh giá thành công
/>
```

### 3. DriverPerformance
**Hiển thị**:
- Overall rating card (lớn, nổi bật)
- Grid 4 tiêu chí với stars và điểm số
- Dropdown chọn khoảng thời gian (7/30/90 ngày)
- List 10 đánh giá gần nhất với comment

**Props**:
```jsx
<DriverPerformance 
  driverId={1}  // Required: ID của tài xế
/>
```

### 4. StarRating
**Component tái sử dụng** để hiển thị rating:

**Props**:
```jsx
<StarRating 
  rating={4.5}        // Required: Số từ 0-5
  size={16}           // Optional: Kích thước sao (default: 16)
  showValue={true}    // Optional: Hiển thị số (default: true)
  className=""        // Optional: Custom class
/>
```

## 🔧 Cấu hình API

File `src/api/ratings.js` đã được cấu hình sẵn với các endpoints:

```javascript
// Tạo đánh giá
await createRating({
  tripId: 1,
  punctualityRating: 5,
  attitudeRating: 5,
  safetyRating: 4,
  complianceRating: 5,
  comment: "Tài xế rất tốt"
});

// Lấy rating của trip
const rating = await getRatingByTrip(tripId);

// Lấy tất cả ratings của driver
const ratings = await getDriverRatings(driverId, 10); // limit 10

// Lấy performance
const performance = await getDriverPerformance(driverId, 30); // 30 ngày
```

## 🎯 Checklist tích hợp

- [ ] **Trip Detail Page**
  - [ ] Import `TripRatingButton`
  - [ ] Thêm component vào UI
  - [ ] Test với trip COMPLETED
  - [ ] Test với trip đã có rating

- [ ] **Driver List Page**
  - [ ] Import `StarRating`
  - [ ] Thêm cột "Đánh giá" vào table
  - [ ] Hiển thị rating cho mỗi driver

- [ ] **Driver Detail Page**
  - [ ] Import `DriverPerformance` và `StarRating`
  - [ ] Thêm rating vào header
  - [ ] Tạo tab "Hiệu suất"
  - [ ] Thêm `DriverPerformance` component

- [ ] **Testing**
  - [ ] Test đánh giá trip mới
  - [ ] Test xem rating đã tạo
  - [ ] Test hiển thị performance
  - [ ] Test với nhiều khoảng thời gian (7/30/90 ngày)

## 🐛 Troubleshooting

### Lỗi: "Cannot find module"
```bash
# Kiểm tra đường dẫn import
# Đúng:
import TripRatingButton from './components/module 5/TripRatingButton';
import StarRating from './components/common/StarRating';
```

### Lỗi: API không hoạt động
```javascript
// Kiểm tra backend đã chạy chưa
// Kiểm tra URL trong src/api/config.js
// Check Network tab trong DevTools
```

### Button không hiển thị
```javascript
// Kiểm tra trip.status === 'COMPLETED'
// Kiểm tra trip object có đầy đủ fields không
console.log('Trip:', trip);
```

## 📞 Cần hỗ trợ?

Xem thêm tài liệu:
- `PTCMSS/docs/DRIVER_RATING_README.md` - Tổng quan
- `PTCMSS/docs/DRIVER_RATING_USAGE.md` - Chi tiết API
- `TripDetailWithRating.example.jsx` - Code mẫu Trip Detail
- `DriverDetailWithPerformance.example.jsx` - Code mẫu Driver Detail
