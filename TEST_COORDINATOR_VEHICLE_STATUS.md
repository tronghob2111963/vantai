# Hướng dẫn Test: Coordinator cập nhật trạng thái xe

## Chuẩn bị
1. Đảm bảo backend đang chạy
2. Đảm bảo frontend đang chạy
3. Có tài khoản Coordinator để test

## Các bước test

### Bước 1: Đăng nhập với tài khoản Coordinator
1. Mở trình duyệt và truy cập ứng dụng
2. Đăng nhập với tài khoản có role COORDINATOR
3. Kiểm tra menu sidebar có hiển thị "Danh sách xe"

### Bước 2: Vào trang Danh sách xe
1. Click vào menu "Danh sách xe"
2. Kiểm tra danh sách xe của chi nhánh hiển thị đúng
3. Chọn một xe bất kỳ để xem chi tiết

### Bước 3: Xem chi tiết xe
1. Click vào icon "Xem chi tiết" (icon mắt) của một xe
2. Trang chi tiết xe sẽ hiển thị:
   - Thông tin cơ bản (biển số, loại xe, hãng/model, chi nhánh)
   - Đăng kiểm & Bảo hiểm
   - Trạng thái hiện tại
   - Thông tin bổ sung

### Bước 4: Chỉnh sửa trạng thái xe
1. Click nút "Chỉnh sửa" ở góc trên bên phải
2. Dropdown "Trạng thái" sẽ được kích hoạt
3. Chọn trạng thái mới từ dropdown:
   - **Sẵn sàng** (AVAILABLE)
   - **Đang sử dụng** (INUSE) ← Test trạng thái này
   - **Bảo trì** (MAINTENANCE)
   - **Không hoạt động** (INACTIVE)

### Bước 5: Lưu thay đổi
1. Click nút "Lưu" (màu xanh lá)
2. Chờ response từ backend
3. Kiểm tra thông báo:
   - ✅ Thành công: "Cập nhật thành công" (màu xanh)
   - ❌ Lỗi: Hiển thị thông báo lỗi (màu đỏ)

### Bước 6: Kiểm tra kết quả
1. Sau khi lưu thành công, trang sẽ tự động reload
2. Kiểm tra trạng thái xe đã được cập nhật
3. Quay lại trang "Danh sách xe" và kiểm tra trạng thái hiển thị đúng

## Kiểm tra Console Logs

### Frontend Console (Browser DevTools)
Mở Console trong DevTools (F12) và tìm các log:
```
[CoordinatorVehicleDetail] Updating vehicle: <vehicleId> {updateData}
[CoordinatorVehicleDetail] Update response: {response}
```

Nếu có lỗi:
```
[CoordinatorVehicleDetail] Update error: {error}
```

### Backend Console (Terminal)
Kiểm tra terminal đang chạy backend, tìm các log:
```
[VehicleService] Updating vehicle ID=<id>, status=<status>
[VehicleService] Current vehicle status: <current_status>
[VehicleService] Parsing status: '<status_string>'
[VehicleService] Parsed as INUSE
[VehicleService] Updated vehicle status: INUSE
```

## Các trường hợp test

### Test Case 1: Chuyển từ AVAILABLE → INUSE
- Trạng thái ban đầu: Sẵn sàng
- Thao tác: Chọn "Đang sử dụng"
- Kết quả mong đợi: ✅ Cập nhật thành công

### Test Case 2: Chuyển từ INUSE → AVAILABLE
- Trạng thái ban đầu: Đang sử dụng
- Thao tác: Chọn "Sẵn sàng"
- Kết quả mong đợi: ✅ Cập nhật thành công

### Test Case 3: Chuyển từ AVAILABLE → MAINTENANCE
- Trạng thái ban đầu: Sẵn sàng
- Thao tác: Chọn "Bảo trì"
- Kết quả mong đợi: ✅ Cập nhật thành công

### Test Case 4: Chuyển từ MAINTENANCE → INUSE
- Trạng thái ban đầu: Bảo trì
- Thao tác: Chọn "Đang sử dụng"
- Kết quả mong đợi: ✅ Cập nhật thành công

### Test Case 5: Cập nhật cùng lúc trạng thái + đăng kiểm/bảo hiểm
- Thao tác: Thay đổi cả 3 trường (status, inspectionExpiry, insuranceExpiry)
- Kết quả mong đợi: ✅ Tất cả đều được cập nhật

## Xử lý lỗi thường gặp

### Lỗi 1: "Cập nhật thất bại" - 403 Forbidden
**Nguyên nhân:** Tài khoản không có quyền COORDINATOR hoặc token hết hạn
**Giải pháp:** 
- Kiểm tra role của user trong database
- Đăng xuất và đăng nhập lại

### Lỗi 2: "Không tìm thấy xe"
**Nguyên nhân:** Vehicle ID không tồn tại hoặc không thuộc chi nhánh của Coordinator
**Giải pháp:**
- Kiểm tra xe có tồn tại trong database
- Kiểm tra xe có thuộc chi nhánh của Coordinator không

### Lỗi 3: Status không được cập nhật
**Nguyên nhân:** Frontend gửi sai format status
**Giải pháp:**
- Kiểm tra console log xem status được gửi là gì
- Đảm bảo frontend gửi "INUSE" chứ không phải "IN_USE"

### Lỗi 4: "Không tìm thấy chi nhánh" hoặc "Không tìm thấy loại xe"
**Nguyên nhân:** categoryId hoặc branchId bị null/undefined
**Giải pháp:**
- Kiểm tra response từ API getVehicle có đầy đủ thông tin không
- Đảm bảo vehicle.categoryId và vehicle.branchId được map đúng

## Kết quả mong đợi

✅ Coordinator có thể:
- Xem danh sách xe của chi nhánh
- Xem chi tiết xe
- Chỉnh sửa thông tin xe (đăng kiểm, bảo hiểm, trạng thái)
- Chuyển xe sang trạng thái "Đang sử dụng" (INUSE)
- Chuyển xe sang bất kỳ trạng thái nào khác

✅ Hệ thống:
- Hiển thị đúng trạng thái xe với màu sắc tương ứng
- Lưu trạng thái vào database
- Đồng bộ trạng thái giữa frontend và backend

## Ghi chú
- Tất cả status values đã được đồng bộ: `AVAILABLE`, `INUSE`, `MAINTENANCE`, `INACTIVE`
- Backend đã hỗ trợ parse cả `"IN_USE"` và `"INUSE"` để backward compatible
- Coordinator có đầy đủ quyền update vehicle theo annotation `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','COORDINATOR')")`
