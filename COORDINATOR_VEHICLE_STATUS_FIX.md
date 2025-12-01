# Restriction: Coordinator KHÔNG được chuyển xe sang trạng thái "Đang sử dụng"

## Yêu cầu
Khi đăng nhập với quyền Coordinator, trong phần Danh sách xe, Điều phối viên **KHÔNG ĐƯỢC PHÉP** chuyển xe sang trạng thái "Đang sử dụng". Trạng thái này chỉ được cập nhật tự động bởi hệ thống khi xe được gán vào chuyến đi.

## Lý do
Trạng thái "Đang sử dụng" (INUSE) phản ánh việc xe đang được gán vào một chuyến đi cụ thể. Việc cho phép Coordinator thay đổi trạng thái này thủ công có thể gây ra:
- Mất đồng bộ giữa trạng thái xe và chuyến đi thực tế
- Khó khăn trong việc theo dõi xe đang hoạt động
- Rủi ro về quản lý tài nguyên

## Giải pháp đã thực hiện

### 1. Frontend - Module 5 (Coordinator)
**File: `CoordinatorVehicleDetailPage.jsx`**
- ❌ **Loại bỏ option "Đang sử dụng"** khỏi dropdown `STATUS_OPTIONS`
- ✅ Coordinator chỉ có thể chọn: Sẵn sàng, Bảo trì, Không hoạt động
- 🔒 **Disable dropdown** khi xe đang ở trạng thái INUSE
- ⚠️ Hiển thị cảnh báo: "Xe đang trong chuyến, không thể thay đổi trạng thái"
- ✅ Thêm **validation trong handleSave**: Chặn nếu Coordinator cố gắng gửi status = "INUSE"
- ✅ Hiển thị đúng label "Đang sử dụng" khi xe ở trạng thái INUSE (read-only)

**File: `CoordinatorVehicleListPage.jsx`**
- ✅ Hiển thị đúng trạng thái "Đang sử dụng" với màu xanh dương
- ✅ Coordinator chỉ có thể xem, không thể thay đổi từ trang list

### 2. Cập nhật Frontend - Module 3 (Admin/Manager)
**File: `VehicleListPage.jsx`**
- Đổi `VEHICLE_STATUS.ON_TRIP` → `VEHICLE_STATUS.INUSE`
- Cập nhật `STATUS_LABEL` từ `"ON_TRIP": "Đang chạy"` → `"INUSE": "Đang sử dụng"`
- Thêm `INACTIVE` status
- Cập nhật tất cả dropdown options
- Cập nhật mock data

**File: `VehicleDetailPage.jsx`**
- Cập nhật `STATUS_LABEL` thêm `"INUSE": "Đang sử dụng"`
- Cập nhật `VehicleStatusBadge` component để hiển thị đúng màu cho `INUSE` và `INACTIVE`
- **Xóa validation logic** chặn việc thay đổi trạng thái `ON_TRIP` thủ công

### 3. Backend - Validation Logic
**File: `VehicleController.java`**
- Endpoint `PUT /api/vehicles/{id}` có quyền cho COORDINATOR (nhưng có validation)
  ```java
  @PreAuthorize("hasAnyRole('ADMIN','MANAGER','COORDINATOR')")
  ```

**File: `VehicleServiceImpl.java`**
- ✅ **Thêm validation kiểm tra role**: Lấy role từ `SecurityContextHolder`
- 🔒 **Chặn Coordinator chuyển sang INUSE**:
  ```java
  if (isCoordinator && newStatus == VehicleStatus.INUSE && vehicle.getStatus() != VehicleStatus.INUSE) {
      throw new RuntimeException("Điều phối viên không được phép...");
  }
  ```
- 🔒 **Chặn Coordinator thay đổi khi xe đang INUSE**:
  ```java
  if (vehicle.getStatus() == VehicleStatus.INUSE && newStatus != VehicleStatus.INUSE) {
      throw new RuntimeException("Không thể thay đổi trạng thái khi xe đang trong chuyến đi.");
  }
  ```
- ✅ Method `parseVehicleStatus()` hỗ trợ convert `"IN_USE"` → `INUSE` (backward compatible)

**File: `VehicleStatus.java` (enum)**
```java
public enum VehicleStatus {
    AVAILABLE,
    INUSE,      // Đang sử dụng
    MAINTENANCE,
    INACTIVE
}
```

## Kết quả
✅ Coordinator có thể xem danh sách xe của chi nhánh
✅ Coordinator có thể xem chi tiết xe
✅ Coordinator có thể chỉnh sửa thông tin xe (đăng kiểm, bảo hiểm)
✅ Coordinator có thể chuyển xe sang: **Sẵn sàng**, **Bảo trì**, **Không hoạt động**
❌ Coordinator **KHÔNG THỂ** chuyển xe sang trạng thái "Đang sử dụng" (INUSE)
🔒 Coordinator **KHÔNG THỂ** thay đổi trạng thái khi xe đang INUSE
✅ Validation được thực hiện ở cả frontend và backend (double protection)

## Các trạng thái xe hiện tại
1. **AVAILABLE** - Sẵn sàng (màu xanh lá)
2. **INUSE** - Đang sử dụng (màu xanh dương)
3. **MAINTENANCE** - Bảo trì (màu cam)
4. **INACTIVE** - Không hoạt động (màu xám)

## Testing
1. Đăng nhập với tài khoản Coordinator
2. Vào menu "Danh sách xe"
3. Click vào một xe để xem chi tiết
4. Click nút "Chỉnh sửa"
5. Thay đổi trạng thái sang "Đang sử dụng"
6. Click "Lưu"
7. Kiểm tra trạng thái đã được cập nhật thành công
