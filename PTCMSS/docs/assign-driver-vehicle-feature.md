# Chức năng Gán Tài xế & Xe (Assign Driver & Vehicle)

## Tổng quan

Chức năng này cho phép điều phối viên gán tài xế và xe cho các chuyến đi từ danh sách Pending, với hai chế độ:
- **Auto-Assign (Tự động)**: Hệ thống tự động chọn cặp tài xế + xe tối ưu dựa trên thuật toán công bằng (fairness)
- **Manual Select (Thủ công)**: Điều phối viên tự chọn từ danh sách ứng viên hợp lệ

## Quy trình hoạt động

### 1. Mở popup gán chuyến
- Từ màn hình điều phối (M5), click vào chuyến Pending
- Popup hiển thị:
  - **Tóm tắt chuyến**: Thời gian, Route (From–To), Loại xe, Số khách, Chi nhánh
  - **Danh sách gợi ý**: Top 10 cặp tài xế + xe tốt nhất
  - **Chọn thủ công**: Dropdown tài xế và xe (chỉ hiển thị ứng viên hợp lệ)

### 2. Danh sách gợi ý (Suggestions)
Hệ thống tự động đánh giá và hiển thị:
- **Cặp đề xuất**: Tài xế + Xe với điểm số công bằng
- **Lý do**: Giải thích tại sao cặp này phù hợp
- **Điểm số**: Thấp = ưu tiên cao (công bằng hơn)

### 3. Chế độ gán

#### Auto-Assign (Tự động)
```
POST /api/dispatch/assign
{
  "bookingId": 123,
  "tripIds": [456],
  "autoAssign": true
}
```
- Hệ thống tự động chọn cặp có điểm công bằng thấp nhất
- Không cần chọn tài xế/xe thủ công

#### Manual Select (Thủ công)
```
POST /api/dispatch/assign
{
  "bookingId": 123,
  "tripIds": [456],
  "driverId": 101,
  "vehicleId": 55,
  "autoAssign": false
}
```
- Điều phối viên chọn từ dropdown
- Chỉ hiển thị ứng viên hợp lệ (đã lọc)

## Quy tắc lọc ứng viên hợp lệ

### Tài xế (Driver)
✅ **Hợp lệ khi**:
- Cùng chi nhánh với chuyến
- Không nghỉ phép (day-off) vào ngày đó
- Bằng lái còn hạn
- Không trùng giờ với chuyến khác

❌ **Loại bỏ khi**:
- Đang nghỉ phép (APPROVED day-off)
- Bằng lái hết hạn
- Trùng giờ với chuyến SCHEDULED/ONGOING khác

### Xe (Vehicle)
✅ **Hợp lệ khi**:
- Cùng chi nhánh
- Trạng thái AVAILABLE
- Không trùng giờ với chuyến khác

❌ **Loại bỏ khi**:
- Trạng thái không phải AVAILABLE (MAINTENANCE, INACTIVE, etc.)
- Trùng giờ với chuyến khác

## Thuật toán công bằng (Fairness Scoring)

### Công thức tính điểm
```
Score = (tripsToday × 40) + (tripsThisWeek × 30) + (recentAssignments × 30)
```

### Các yếu tố đánh giá

1. **Số chuyến trong ngày** (40% trọng số)
   - Đếm số chuyến tài xế đã chạy trong ngày
   - Ưu tiên tài xế có ít chuyến hơn

2. **Số chuyến trong tuần** (30% trọng số)
   - Đếm từ thứ 2 đến Chủ nhật
   - Đảm bảo phân bổ đều trong tuần

3. **Mức độ gán gần đây** (30% trọng số)
   - Đếm số chuyến trong 3 ngày gần đây
   - Tránh gán liên tục cho cùng một tài xế

### Ví dụ tính điểm

**Tài xế A**:
- Hôm nay: 2 chuyến
- Tuần này: 8 chuyến
- 3 ngày gần: 5 chuyến
- **Score = (2×40) + (8×30) + (5×30) = 470**

**Tài xế B**:
- Hôm nay: 1 chuyến
- Tuần này: 5 chuyến
- 3 ngày gần: 3 chuyến
- **Score = (1×40) + (5×30) + (3×30) = 280** ← **Ưu tiên**

## API Endpoints

### 1. Lấy gợi ý gán chuyến
```http
GET /api/dispatch/trips/{tripId}/suggestions
Authorization: Bearer <token>
```

**Response**:
```json
{
  "status": 200,
  "message": "Loaded suggestions",
  "data": {
    "summary": {
      "tripId": 456,
      "bookingId": 123,
      "branchName": "Chi nhánh HCM",
      "startTime": "2025-11-21T08:00:00Z",
      "endTime": "2025-11-21T12:00:00Z",
      "routeLabel": "Tân Bình -> Quận 1"
    },
    "suggestions": [
      {
        "driver": {
          "id": 101,
          "name": "Nguyễn Văn A",
          "phone": "0901234567"
        },
        "vehicle": {
          "id": 55,
          "plate": "29A-123.45",
          "model": "Toyota Innova"
        },
        "score": 280,
        "reasons": [
          "Tài xế: Nguyễn Văn A (điểm: 280)",
          "Xe: 29A-123.45 (điểm: 0)",
          "Tổng điểm: 280"
        ]
      }
    ],
    "drivers": [
      {
        "id": 101,
        "name": "Nguyễn Văn A",
        "phone": "0901234567",
        "tripsToday": 1,
        "score": 280,
        "eligible": true,
        "reasons": [
          "Không nghỉ phép",
          "Bằng lái còn hạn",
          "Rảnh tại thời điểm này",
          "Số chuyến hôm nay: 1",
          "Số chuyến tuần này: 5",
          "Điểm công bằng: 280 (thấp = ưu tiên)"
        ]
      }
    ],
    "vehicles": [
      {
        "id": 55,
        "plate": "29A-123.45",
        "model": "Toyota Innova",
        "capacity": 7,
        "status": "AVAILABLE",
        "score": 0,
        "eligible": true,
        "reasons": [
          "Xe sẵn sàng",
          "Rảnh tại thời điểm này",
          "Đủ điều kiện gán"
        ]
      }
    ],
    "recommendedDriverId": 101,
    "recommendedVehicleId": 55
  }
}
```

### 2. Gán chuyến
```http
POST /api/dispatch/assign
Authorization: Bearer <token>
Content-Type: application/json

{
  "bookingId": 123,
  "tripIds": [456],
  "driverId": 101,      // Optional nếu autoAssign = true
  "vehicleId": 55,      // Optional nếu autoAssign = true
  "autoAssign": false,  // true = tự động, false = thủ công
  "note": "Ghi chú"
}
```

**Response**:
```json
{
  "status": 200,
  "message": "Assign successfully",
  "data": {
    "bookingId": 123,
    "bookingStatus": "INPROGRESS",
    "trips": [
      {
        "tripId": 456,
        "tripStatus": "SCHEDULED",
        "driverId": 101,
        "driverName": "Nguyễn Văn A",
        "vehicleId": 55,
        "vehicleLicensePlate": "29A-123.45"
      }
    ]
  }
}
```

## Sau khi gán thành công

1. **Cập nhật trạng thái**:
   - Trip: `SCHEDULED` (đã gán)
   - Booking: `INPROGRESS` (nếu có trip đã gán)

2. **Ghi lịch sử điều phối**:
   - Lưu vào bảng `trip_assignment_history`
   - Ghi nhận: thời gian, người gán, tài xế, xe, lý do

3. **Gửi thông báo** (TODO):
   - Notification cho tài xế qua app/SMS
   - Email xác nhận cho khách hàng

## Cấu hình trọng số (TODO)

Hiện tại trọng số cố định:
- Ngày: 40%
- Tuần: 30%
- Gần đây: 30%

**Tương lai**: Cho phép cấu hình trong System Settings:
```json
{
  "fairness_weights": {
    "daily_trips": 40,
    "weekly_trips": 30,
    "recent_assignments": 30
  }
}
```

## Lưu ý kỹ thuật

### Backend
- Service: `DispatchServiceImpl.getAssignmentSuggestions()`
- Fairness logic: `evaluateDriverCandidates()`
- Auto-assign: `pickBestDriverForTrip()`, `pickBestVehicleForTrip()`

### Frontend
- Component: `AssignDriverDialog.jsx`
- API: `dispatch.js` → `getAssignmentSuggestions()`, `assignTrips()`
- State management: React hooks

### Performance
- Suggestions được cache trong popup (không reload khi chọn)
- Chỉ load khi mở popup lần đầu
- Timeout 30s cho API calls

## Testing

### Test cases cần kiểm tra

1. **Lọc ứng viên**:
   - ✅ Tài xế nghỉ phép không hiển thị
   - ✅ Xe đang bảo trì không hiển thị
   - ✅ Trùng giờ không hiển thị

2. **Fairness scoring**:
   - ✅ Tài xế ít chuyến được ưu tiên
   - ✅ Điểm số tính đúng công thức
   - ✅ Sort theo điểm tăng dần

3. **Auto-assign**:
   - ✅ Chọn đúng cặp điểm thấp nhất
   - ✅ Fallback nếu không có ứng viên

4. **Manual assign**:
   - ✅ Chỉ cho chọn ứng viên hợp lệ
   - ✅ Validate trước khi gán
   - ✅ Error handling

## Roadmap

### Phase 1 (Hiện tại) ✅
- [x] API suggestions với fairness scoring
- [x] Frontend popup với auto/manual mode
- [x] Lọc ứng viên hợp lệ
- [x] Tính điểm công bằng cơ bản

### Phase 2 (Sắp tới)
- [ ] Notification cho tài xế
- [ ] Ghi lịch sử chi tiết
- [ ] Cấu hình trọng số động
- [ ] Dashboard fairness analytics

### Phase 3 (Tương lai)
- [ ] Machine learning cho gợi ý
- [ ] Tối ưu route (TSP)
- [ ] Dự đoán thời gian hoàn thành
- [ ] Tích hợp GPS real-time
