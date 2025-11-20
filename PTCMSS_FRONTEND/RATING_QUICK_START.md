# ⚡ Driver Rating - Quick Start

## 📍 Vị trí các file Frontend

```
PTCMSS_FRONTEND/
├── src/
│   ├── api/
│   │   └── ratings.js                    ✅ API client
│   └── components/
│       ├── common/
│       │   └── StarRating.jsx            ✅ Component rating stars
│       └── module 5/
│           ├── RateDriverDialog.jsx      ✅ Dialog đánh giá
│           ├── TripRatingButton.jsx      ✅ Button cho trip
│           ├── DriverPerformance.jsx     ✅ Hiển thị hiệu suất
│           ├── TripDetailWithRating.example.jsx      📝 Ví dụ
│           └── DriverDetailWithPerformance.example.jsx  📝 Ví dụ
```

## 🚀 3 bước tích hợp nhanh

### 1️⃣ Thêm vào Trip Detail (Đánh giá sau khi hoàn thành)

```jsx
import TripRatingButton from './components/module 5/TripRatingButton';

<TripRatingButton trip={trip} onRatingComplete={loadTripDetail} />
```

### 2️⃣ Thêm vào Driver List (Hiển thị rating)

```jsx
import StarRating from './components/common/StarRating';

<StarRating rating={driver.rating} />
```

### 3️⃣ Thêm vào Driver Detail (Xem hiệu suất)

```jsx
import DriverPerformance from './components/module 5/DriverPerformance';

<DriverPerformance driverId={driverId} />
```

## 📝 Xem ví dụ đầy đủ

- **Trip Detail**: `src/components/module 5/TripDetailWithRating.example.jsx`
- **Driver Detail**: `src/components/module 5/DriverDetailWithPerformance.example.jsx`

## 📖 Tài liệu chi tiết

- `RATING_INTEGRATION_GUIDE.md` - Hướng dẫn tích hợp đầy đủ
- `PTCMSS/docs/DRIVER_RATING_README.md` - Tổng quan hệ thống
