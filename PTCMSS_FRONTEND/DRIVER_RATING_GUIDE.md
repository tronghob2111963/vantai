# Hướng Dẫn Sử Dụng Chức Năng Đánh Giá Tài Xế

## Tổng Quan

Hệ thống đánh giá tài xế cho phép quản lý đánh giá hiệu suất của tài xế sau khi hoàn thành chuyến đi. Đánh giá dựa trên 4 tiêu chí chính với thang điểm từ 1-5 sao.

## Các Tiêu Chí Đánh Giá

1. **⏰ Đúng giờ** - Tài xế có đến đúng giờ và hoàn thành chuyến đúng thời gian
2. **😊 Thái độ** - Thái độ phục vụ, giao tiếp với khách hàng
3. **🛡️ An toàn** - Lái xe an toàn, tuân thủ luật giao thông
4. **✅ Tuân thủ quy trình** - Tuân thủ quy trình vận hành của công ty

**Đánh giá tổng thể** = Trung bình của 4 tiêu chí trên

## Các Component Chính

### 1. DriverRatingDashboard
**Đường dẫn:** `/ratings/dashboard`

Dashboard tổng quan hiệu suất tài xế:
- Thống kê tổng quan (tổng tài xế, đánh giá TB, số tài xế xuất sắc)
- Danh sách tài xế với đánh giá 30 ngày gần nhất
- Xếp hạng tài xế theo đánh giá
- Chi tiết từng tiêu chí đánh giá

**Tính năng:**
- Filter theo chi nhánh
- Sắp xếp theo: Đánh giá cao nhất / Nhiều đánh giá nhất / Tên A-Z
- Click vào tài xế để xem chi tiết

### 2. DriverRatingManagement
**Đường dẫn:** `/ratings/management`

Trang quản lý đánh giá chuyến đi:
- Danh sách các chuyến đã hoàn thành (COMPLETED)
- Phân loại: Chưa đánh giá / Đã đánh giá / Tất cả
- Đánh giá trực tiếp từ danh sách chuyến

**Tính năng:**
- Filter theo: Chi nhánh, Tài xế, Khoảng thời gian
- Tìm kiếm theo tên tài xế, khách hàng, mã chuyến
- Nút "Đánh giá" cho các chuyến chưa được đánh giá

### 3. DriverRatingsPage
**Đường dẫn:** `/ratings/driver/:driverId`

Trang chi tiết đánh giá của một tài xế:
- Thông tin tài xế
- Hiệu suất 30 ngày (có thể chọn 7/30/90 ngày)
- Danh sách tất cả đánh giá
- Danh sách chuyến đi theo chi nhánh để đánh giá

### 4. RateDriverDialog

Modal đánh giá tài xế:
- Form đánh giá 4 tiêu chí (1-5 sao)
- Hiển thị đánh giá tổng thể tự động
- Ô nhận xét (tùy chọn)
- Thông tin chuyến đi

## Quy Trình Sử Dụng

### Đánh Giá Chuyến Đi

1. Vào trang **Quản lý đánh giá** (`/ratings/management`)
2. Chọn chi nhánh
3. Filter "Chưa đánh giá" để xem các chuyến cần đánh giá
4. Click nút "Đánh giá" trên chuyến cần đánh giá
5. Đánh giá 4 tiêu chí bằng cách click vào số sao
6. Nhập nhận xét (nếu có)
7. Click "Gửi đánh giá"

### Xem Dashboard Tài Xế

1. Vào trang **Dashboard** (`/ratings/dashboard`)
2. Chọn chi nhánh
3. Xem thống kê tổng quan
4. Sắp xếp danh sách theo nhu cầu
5. Click vào tài xế để xem chi tiết

### Xem Chi Tiết Tài Xế

1. Từ Dashboard, click vào tài xế
2. Hoặc vào trực tiếp `/ratings/driver/:driverId`
3. Xem hiệu suất tổng quan
4. Xem danh sách đánh giá chi tiết
5. Có thể đánh giá thêm từ danh sách chuyến

## API Endpoints

### Ratings API
- `POST /api/ratings` - Tạo đánh giá mới
- `GET /api/ratings/trip/:tripId` - Lấy đánh giá của chuyến
- `GET /api/ratings/driver/:driverId` - Lấy danh sách đánh giá của tài xế
- `GET /api/ratings/driver/:driverId/performance?days=30` - Lấy hiệu suất tài xế

### Trips API
- `POST /api/dispatch/search` - Tìm kiếm chuyến (filter theo status=COMPLETED)

### Drivers API
- `GET /api/drivers/branch/:branchId` - Lấy danh sách tài xế theo chi nhánh

## Quy Tắc Nghiệp Vụ

1. **Chỉ đánh giá được chuyến COMPLETED**
   - Backend sẽ kiểm tra status của trip
   - Frontend chỉ hiển thị các chuyến đã hoàn thành

2. **Mỗi chuyến chỉ được đánh giá 1 lần**
   - Backend kiểm tra duplicate rating
   - Frontend hiển thị trạng thái "Đã đánh giá"

3. **Đánh giá tổng thể tự động tính**
   - Trung bình của 4 tiêu chí
   - Làm tròn 1 chữ số thập phân

4. **Hiệu suất tài xế tính theo 30 ngày**
   - Mặc định hiển thị 30 ngày gần nhất
   - Có thể chọn 7/30/90 ngày
   - Cập nhật tự động sau mỗi đánh giá mới

## Phân Loại Đánh Giá

- **Xuất sắc**: ≥ 4.5 sao (màu xanh lá)
- **Tốt**: 4.0 - 4.4 sao (màu xanh dương)
- **Khá**: 3.5 - 3.9 sao (màu vàng)
- **Cần cải thiện**: < 3.5 sao (màu đỏ)

## Cấu Trúc File

```
PTCMSS_FRONTEND/src/components/module 5/
├── DriverRatingDashboard.jsx      # Dashboard tổng quan
├── DriverRatingManagement.jsx     # Quản lý đánh giá chuyến
├── DriverRatingsPage.jsx          # Chi tiết tài xế
├── DriverPerformance.jsx          # Component hiệu suất
├── RateDriverDialog.jsx           # Modal đánh giá
├── TripRatingButton.jsx           # Button đánh giá nhanh
└── RatingManagementPage.jsx       # (Legacy - có thể thay thế)
```

## Routes Cần Thêm

```javascript
// Trong App.jsx hoặc routes config
import DriverRatingDashboard from './components/module 5/DriverRatingDashboard';
import DriverRatingManagement from './components/module 5/DriverRatingManagement';
import DriverRatingsPage from './components/module 5/DriverRatingsPage';

// Routes
<Route path="/ratings/dashboard" element={<DriverRatingDashboard />} />
<Route path="/ratings/management" element={<DriverRatingManagement />} />
<Route path="/ratings/driver/:driverId" element={<DriverRatingsPage />} />
```

## Menu Navigation

Thêm vào menu chính:

```javascript
{
  label: 'Đánh giá tài xế',
  icon: <Star />,
  children: [
    { label: 'Dashboard', path: '/ratings/dashboard' },
    { label: 'Quản lý đánh giá', path: '/ratings/management' }
  ]
}
```

## Lưu Ý

1. **Backend đã được sửa** - So sánh enum TripStatus đúng cách
2. **Cần rebuild backend** - Sau khi sửa RatingServiceImpl.java
3. **Restart backend** - Để áp dụng thay đổi
4. **Test kỹ** - Đảm bảo chỉ đánh giá được chuyến COMPLETED

## Troubleshooting

### Lỗi "Can only rate completed trips"
- Kiểm tra status của trip trong database
- Đảm bảo backend đã rebuild và restart
- Kiểm tra RatingServiceImpl.java đã sửa đúng

### Không hiển thị danh sách chuyến
- Kiểm tra đã chọn chi nhánh chưa
- Kiểm tra API `/api/dispatch/search` hoạt động
- Kiểm tra có chuyến COMPLETED trong database không

### Đánh giá không lưu
- Kiểm tra console log lỗi
- Kiểm tra driverId có đúng không
- Kiểm tra trip đã được đánh giá chưa
