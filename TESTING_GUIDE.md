# Hướng dẫn Test Logic Kiểm Tra Chuyến Trước Khi Duyệt Nghỉ Phép

## 🎯 Mục đích
Kiểm tra xem hệ thống có phát hiện và xử lý đúng khi tài xế xin nghỉ phép nhưng đã có chuyến được gán trong khoảng thời gian nghỉ.

## 📋 Các bước test

### **Test Case 1: Tài xế có chuyến trong ngày nghỉ**

#### Bước 1: Chuẩn bị dữ liệu
1. Đăng nhập với role **Tài xế** (Driver)
2. Tạo một chuyến cho tài xế này với ngày cụ thể (ví dụ: 15/12/2024)
3. Đảm bảo chuyến có status là `SCHEDULED` hoặc `ONGOING` (chưa hoàn thành)

#### Bước 2: Tài xế xin nghỉ phép
1. Đăng nhập với role **Tài xế** (Driver)
2. Vào menu "Xin nghỉ phép"
3. Chọn ngày nghỉ **trùng với ngày có chuyến** (ví dụ: 15/12/2024)
4. Điền lý do và gửi yêu cầu

#### Bước 3: Điều phối viên duyệt
1. Đăng nhập với role **Điều phối viên** (Coordinator) hoặc **Quản lý** (Manager)
2. Vào trang "Cảnh báo & Chờ duyệt" (`/dispatch/notifications-dashboard`)
3. Tìm yêu cầu nghỉ phép vừa tạo
4. Click nút **"Duyệt"**

#### Bước 4: Kiểm tra kết quả
✅ **Kỳ vọng:**
- Hệ thống hiển thị dialog cảnh báo màu vàng
- Dialog hiển thị: "Cảnh báo: Tài xế có chuyến trong ngày nghỉ"
- Danh sách các chuyến xung đột được hiển thị với thông tin:
  - Mã chuyến
  - Khách hàng
  - Lộ trình
  - Thời gian
- Có 2 nút:
  - **"Hủy"** - Đóng dialog
  - **"Hủy gán X chuyến và duyệt nghỉ phép"** - Hủy gán chuyến và tiếp tục duyệt

#### Bước 5: Test các hành động
**Test 5a: Hủy gán và duyệt**
1. Click nút "Hủy gán X chuyến và duyệt nghỉ phép"
2. ✅ Kỳ vọng:
   - Các chuyến xung đột bị hủy gán
   - Dialog duyệt nghỉ phép hiện ra
   - Note tự động điền: "Đã hủy gán X chuyến xung đột..."
   - Sau khi duyệt, nghỉ phép được approve
   - Chuyến không còn được gán cho tài xế này

**Test 5b: Hủy thao tác**
1. Click nút "Hủy"
2. ✅ Kỳ vọng:
   - Dialog đóng lại
   - Yêu cầu nghỉ phép vẫn ở trạng thái "Chờ duyệt"
   - Chuyến vẫn được gán cho tài xế

---

### **Test Case 2: Tài xế KHÔNG có chuyến trong ngày nghỉ**

#### Bước 1: Chuẩn bị
1. Đảm bảo tài xế **KHÔNG có chuyến** trong ngày muốn nghỉ

#### Bước 2: Tài xế xin nghỉ phép
1. Tài xế xin nghỉ phép cho ngày không có chuyến

#### Bước 3: Điều phối viên duyệt
1. Click nút "Duyệt"

#### Bước 4: Kiểm tra kết quả
✅ **Kỳ vọng:**
- **KHÔNG** hiển thị dialog cảnh báo
- Dialog duyệt nghỉ phép hiện ra ngay lập tức
- Có thể duyệt bình thường

---

### **Test Case 3: Tài xế có chuyến đã hoàn thành**

#### Bước 1: Chuẩn bị
1. Tạo chuyến cho tài xế với status `COMPLETED`

#### Bước 2: Tài xế xin nghỉ phép
1. Xin nghỉ phép cho ngày có chuyến đã hoàn thành

#### Bước 3: Điều phối viên duyệt
1. Click nút "Duyệt"

#### Bước 4: Kiểm tra kết quả
✅ **Kỳ vọng:**
- **KHÔNG** hiển thị dialog cảnh báo (vì chuyến đã hoàn thành)
- Có thể duyệt bình thường

---

### **Test Case 4: Nghỉ phép nhiều ngày**

#### Bước 1: Chuẩn bị
1. Tạo nhiều chuyến cho tài xế trong khoảng thời gian (ví dụ: 15/12 - 20/12)

#### Bước 2: Tài xế xin nghỉ phép
1. Xin nghỉ phép từ 15/12 đến 20/12

#### Bước 3: Điều phối viên duyệt
1. Click nút "Duyệt"

#### Bước 4: Kiểm tra kết quả
✅ **Kỳ vọng:**
- Hiển thị dialog cảnh báo
- Danh sách **TẤT CẢ** các chuyến trong khoảng 15/12 - 20/12
- Có thể hủy gán tất cả cùng lúc

---

## 🔍 Cách kiểm tra trong Browser Console

Mở **Developer Tools** (F12) → Tab **Console** để xem logs:

### Logs khi click "Duyệt":
```
🔍 [TEST] Checking day off approval: { approvalType, driverId, startDate, endDate, ... }
📅 [TEST] Fetching driver schedule for driverId: X
📋 [TEST] Driver schedule received: Y trips
📆 [TEST] Leave period: { start: "...", end: "..." }
⚠️ [TEST] Found conflicting trip: { tripId, tripDate, status, ... }
✅ [TEST] Total conflicts found: Z
🚨 [TEST] Showing conflict dialog with Z conflicting trips
```

### Logs khi không có xung đột:
```
✅ [TEST] No conflicts found, proceeding with normal approval
```

### Logs khi không phải day off request:
```
ℹ️ [TEST] Not a DRIVER_DAY_OFF request, skipping check
```

---

## ✅ Checklist Test

- [ ] Test Case 1: Có chuyến → Hiển thị cảnh báo
- [ ] Test Case 1: Hủy gán chuyến → Chuyến bị hủy gán
- [ ] Test Case 1: Hủy gán chuyến → Nghỉ phép được duyệt
- [ ] Test Case 2: Không có chuyến → Duyệt bình thường
- [ ] Test Case 3: Chuyến đã hoàn thành → Không cảnh báo
- [ ] Test Case 4: Nghỉ nhiều ngày → Hiển thị tất cả chuyến xung đột
- [ ] Console logs hiển thị đúng thông tin
- [ ] Dialog hiển thị đúng thông tin chuyến
- [ ] Nút "Hủy gán" hoạt động đúng

---

## 🐛 Debug Tips

1. **Nếu không thấy dialog cảnh báo:**
   - Kiểm tra console logs
   - Kiểm tra `driverId` có đúng không
   - Kiểm tra `startDate` và `endDate` có đúng format không
   - Kiểm tra API `getDriverSchedule` có trả về dữ liệu không

2. **Nếu không tìm thấy chuyến xung đột:**
   - Kiểm tra `trip.startTime` có đúng format không
   - Kiểm tra status của chuyến (phải là SCHEDULED hoặc ONGOING)
   - Kiểm tra logic so sánh ngày tháng

3. **Nếu unassign không hoạt động:**
   - Kiểm tra `tripId` có đúng không
   - Kiểm tra API `unassignTrip` có được gọi không
   - Kiểm tra response từ API

---

## 📝 Ghi chú

- Logic này chỉ áp dụng cho **DRIVER_DAY_OFF** requests
- Chỉ kiểm tra chuyến có status **SCHEDULED** hoặc **ONGOING** (bỏ qua COMPLETED, CANCELLED)
- Nếu API `getDriverSchedule` fail, hệ thống vẫn cho phép duyệt (không block user)

