# Tóm tắt: Hạn chế quyền Coordinator với trạng thái xe "Đang sử dụng"

## Quy tắc nghiệp vụ

### Trạng thái "Đang sử dụng" (INUSE)
- ✅ Chỉ được cập nhật **TỰ ĐỘNG** bởi hệ thống khi xe được gán vào chuyến đi
- ❌ **KHÔNG** cho phép thay đổi thủ công bởi Coordinator
- ✅ Admin và Manager vẫn có thể thay đổi (nếu cần thiết)

### Quyền của Coordinator
Coordinator có thể:
- ✅ Xem danh sách xe của chi nhánh
- ✅ Xem chi tiết xe
- ✅ Cập nhật thông tin đăng kiểm, bảo hiểm
- ✅ Chuyển xe sang: **Sẵn sàng**, **Bảo trì**, **Không hoạt động**
- ❌ **KHÔNG** chuyển xe sang: **Đang sử dụng**
- ❌ **KHÔNG** thay đổi trạng thái khi xe đang **Đang sử dụng**

## Cơ chế bảo vệ (Double Protection)

### 1. Frontend Protection
**File:** `CoordinatorVehicleDetailPage.jsx`

```javascript
// Option "Đang sử dụng" bị loại bỏ khỏi dropdown
const STATUS_OPTIONS = [
    { value: "AVAILABLE", label: "Sẵn sàng" },
    // { value: "INUSE", label: "Đang sử dụng" }, // REMOVED
    { value: "MAINTENANCE", label: "Bảo trì" },
    { value: "INACTIVE", label: "Không hoạt động" },
];

// Validation trong handleSave
if (formData.status === "INUSE") {
    setToast({ 
        type: "error", 
        message: "Điều phối viên không được phép chuyển xe sang trạng thái 'Đang sử dụng'..." 
    });
    return;
}

// Disable dropdown khi xe đang INUSE
<select disabled={vehicle?.status === "INUSE"}>
```

### 2. Backend Protection
**File:** `VehicleServiceImpl.java`

```java
// Lấy role của user hiện tại
Authentication auth = SecurityContextHolder.getContext().getAuthentication();
boolean isCoordinator = auth.getAuthorities().stream()
    .anyMatch(a -> a.getAuthority().equals("ROLE_COORDINATOR"));

// Validation 1: Chặn Coordinator chuyển sang INUSE
if (isCoordinator && newStatus == VehicleStatus.INUSE && vehicle.getStatus() != VehicleStatus.INUSE) {
    throw new RuntimeException("Điều phối viên không được phép chuyển xe sang trạng thái 'Đang sử dụng'...");
}

// Validation 2: Chặn thay đổi khi xe đang INUSE
if (vehicle.getStatus() == VehicleStatus.INUSE && newStatus != VehicleStatus.INUSE) {
    throw new RuntimeException("Không thể thay đổi trạng thái khi xe đang trong chuyến đi.");
}
```

## UI/UX

### Khi xe ở trạng thái khác (AVAILABLE, MAINTENANCE, INACTIVE)
```
┌─────────────────────────────────────┐
│ Trạng thái: [Dropdown ▼]           │
│   - Sẵn sàng                        │
│   - Bảo trì                         │
│   - Không hoạt động                 │
└─────────────────────────────────────┘
```

### Khi xe đang ở trạng thái INUSE
```
┌─────────────────────────────────────┐
│ Trạng thái: [Đang sử dụng ▼] 🔒    │
│ ⚠️ Xe đang trong chuyến,            │
│    không thể thay đổi trạng thái    │
└─────────────────────────────────────┘
```

## Thông báo lỗi

### Frontend
```
❌ Điều phối viên không được phép chuyển xe sang trạng thái 'Đang sử dụng'. 
   Trạng thái này chỉ được cập nhật tự động khi xe được gán vào chuyến.
```

### Backend
```
❌ Điều phối viên không được phép chuyển xe sang trạng thái 'Đang sử dụng'. 
   Trạng thái này chỉ được cập nhật tự động khi xe được gán vào chuyến.

❌ Không thể thay đổi trạng thái khi xe đang trong chuyến đi.
```

## Test Cases

### ✅ Test Case 1: Coordinator chuyển AVAILABLE → MAINTENANCE
- **Kết quả:** Thành công
- **Lý do:** Được phép

### ✅ Test Case 2: Coordinator chuyển MAINTENANCE → AVAILABLE
- **Kết quả:** Thành công
- **Lý do:** Được phép

### ❌ Test Case 3: Coordinator chuyển AVAILABLE → INUSE
- **Kết quả:** Thất bại
- **Lý do:** Bị chặn bởi frontend validation
- **Thông báo:** "Điều phối viên không được phép..."

### ❌ Test Case 4: Coordinator bypass frontend, gửi API trực tiếp với status=INUSE
- **Kết quả:** Thất bại
- **Lý do:** Bị chặn bởi backend validation
- **HTTP Status:** 400 Bad Request
- **Thông báo:** "Điều phối viên không được phép..."

### ❌ Test Case 5: Coordinator thay đổi trạng thái khi xe đang INUSE
- **Kết quả:** Thất bại
- **Lý do:** Dropdown bị disable, không thể thay đổi
- **UI:** Hiển thị cảnh báo "Xe đang trong chuyến..."

### ✅ Test Case 6: Admin/Manager chuyển AVAILABLE → INUSE
- **Kết quả:** Thành công
- **Lý do:** Admin/Manager có đầy đủ quyền

## So sánh quyền

| Thao tác | Admin | Manager | Coordinator |
|----------|-------|---------|-------------|
| Xem danh sách xe | ✅ | ✅ | ✅ (chi nhánh) |
| Xem chi tiết xe | ✅ | ✅ | ✅ |
| Tạo xe mới | ✅ | ✅ | ❌ |
| Xóa xe | ✅ | ❌ | ❌ |
| Sửa thông tin cơ bản | ✅ | ✅ | ✅ |
| Chuyển sang AVAILABLE | ✅ | ✅ | ✅ |
| Chuyển sang INUSE | ✅ | ✅ | ❌ |
| Chuyển sang MAINTENANCE | ✅ | ✅ | ✅ |
| Chuyển sang INACTIVE | ✅ | ✅ | ✅ |
| Sửa khi xe đang INUSE | ✅ | ✅ | ❌ |

## Lưu ý kỹ thuật

1. **SecurityContextHolder**: Sử dụng để lấy role của user hiện tại trong backend
2. **Double Protection**: Validation ở cả frontend và backend để tránh bypass
3. **Backward Compatible**: Backend vẫn parse được cả "IN_USE" và "INUSE"
4. **UI Feedback**: Hiển thị rõ ràng khi không thể thay đổi (disabled + warning)
5. **Logging**: Có log chi tiết để debug khi cần

## Files đã thay đổi

### Frontend
- ✅ `vantai/PTCMSS_FRONTEND/src/components/module 5/CoordinatorVehicleDetailPage.jsx`
- ✅ `vantai/PTCMSS_FRONTEND/src/components/module 5/CoordinatorVehicleListPage.jsx`

### Backend
- ✅ `vantai/PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/service/impl/VehicleServiceImpl.java`

### Documentation
- ✅ `vantai/COORDINATOR_VEHICLE_STATUS_FIX.md`
- ✅ `vantai/COORDINATOR_VEHICLE_RESTRICTION_SUMMARY.md`
- ✅ `vantai/TEST_COORDINATOR_VEHICLE_STATUS.md`
