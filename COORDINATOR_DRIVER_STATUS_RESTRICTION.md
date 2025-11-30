# Hạn chế quyền: Coordinator chỉ được chuyển tài xế sang ACTIVE và INACTIVE

## Yêu cầu nghiệp vụ

Điều phối viên (Coordinator) **CHỈ ĐƯỢC PHÉP** chuyển tài xế sang 2 trạng thái:
- ✅ **ACTIVE** (Hoạt động)
- ✅ **INACTIVE** (Không hoạt động)

Các trạng thái khác được cập nhật **TỰ ĐỘNG** bởi hệ thống:
- ❌ **ON_TRIP** (Đang chạy) - Khi tài xế được gán vào chuyến
- ❌ **OFF_DUTY** (Nghỉ) - Khi tài xế đăng ký nghỉ và được duyệt
- ❌ **AVAILABLE** (Sẵn sàng) - Legacy status

## Lý do

1. **Tránh mất đồng bộ**: Trạng thái ON_TRIP phản ánh tài xế đang trong chuyến thực tế
2. **Quản lý lịch nghỉ**: OFF_DUTY cần qua quy trình phê duyệt
3. **Đơn giản hóa**: Coordinator chỉ cần bật/tắt trạng thái hoạt động của tài xế

## Giải pháp đã thực hiện

### 1. Frontend - CoordinatorDriverDetailPage.jsx

#### Giới hạn dropdown options
```javascript
// Coordinator CHỈ được chọn 2 trạng thái
const STATUS_OPTIONS = [
    { value: "ACTIVE", label: "Hoạt động" },
    { value: "INACTIVE", label: "Không hoạt động" },
];

// Mapping đầy đủ để hiển thị (read-only)
const ALL_STATUS_LABELS = {
    "ACTIVE": "Hoạt động",
    "AVAILABLE": "Sẵn sàng",
    "ON_TRIP": "Đang chạy",
    "OFF_DUTY": "Nghỉ",
    "INACTIVE": "Không hoạt động",
};
```

#### Validation trong handleSave
```javascript
const allowedStatuses = ["ACTIVE", "INACTIVE"];
if (formData.status && !allowedStatuses.includes(formData.status)) {
    setToast({ 
        type: "error", 
        message: "Điều phối viên chỉ được phép chuyển tài xế sang trạng thái 'Hoạt động' hoặc 'Không hoạt động'." 
    });
    return;
}
```

#### UI/UX Enhancements
- 🔒 **Disable dropdown** khi tài xế đang ON_TRIP
- ⚠️ Hiển thị cảnh báo: "Tài xế đang trong chuyến, không thể thay đổi trạng thái"
- 💡 Hiển thị hint: "Chỉ có thể chuyển sang: Hoạt động hoặc Không hoạt động"
- ✅ Hiển thị đúng màu sắc cho tất cả trạng thái (read-only)

### 2. Backend - DriverServiceImpl.java

#### Validation logic
```java
// Lấy role của user hiện tại
Authentication auth = SecurityContextHolder.getContext().getAuthentication();
boolean isCoordinator = auth.getAuthorities().stream()
    .anyMatch(a -> a.getAuthority().equals("ROLE_COORDINATOR"));

// Coordinator chỉ được chuyển sang ACTIVE hoặc INACTIVE
if (isCoordinator) {
    if (newStatus != DriverStatus.ACTIVE && newStatus != DriverStatus.INACTIVE) {
        throw new RuntimeException("Điều phối viên chỉ được phép chuyển tài xế sang trạng thái 'Hoạt động' (ACTIVE) hoặc 'Không hoạt động' (INACTIVE).");
    }
    
    // Không được thay đổi khi tài xế đang ON_TRIP
    if (driver.getStatus() == DriverStatus.ON_TRIP) {
        throw new RuntimeException("Không thể thay đổi trạng thái khi tài xế đang trong chuyến đi.");
    }
}
```

### 3. Backend - DriverStatus.java (enum)

```java
public enum DriverStatus {
    ACTIVE,      // Hoạt động - Coordinator có thể chuyển
    AVAILABLE,   // Sẵn sàng (legacy)
    ON_TRIP,     // Đang chạy - Chỉ hệ thống cập nhật
    OFF_DUTY,    // Nghỉ - Chỉ hệ thống cập nhật
    INACTIVE,    // Không hoạt động - Coordinator có thể chuyển
    
    // Legacy variants for backward compatibility
    Available, OnTrip, Inactive, ONTRIP
}
```

## UI/UX Flow

### Khi tài xế ở trạng thái ACTIVE, AVAILABLE, OFF_DUTY, hoặc INACTIVE
```
┌─────────────────────────────────────────────┐
│ Trạng thái: [Dropdown ▼]                   │
│   - Hoạt động                               │
│   - Không hoạt động                         │
│                                             │
│ 💡 Chỉ có thể chuyển sang: Hoạt động       │
│    hoặc Không hoạt động                     │
└─────────────────────────────────────────────┘
```

### Khi tài xế đang ON_TRIP
```
┌─────────────────────────────────────────────┐
│ Trạng thái: [Đang chạy ▼] 🔒              │
│                                             │
│ ⚠️ Tài xế đang trong chuyến,               │
│    không thể thay đổi trạng thái            │
│                                             │
│ 💡 Chỉ có thể chuyển sang: Hoạt động       │
│    hoặc Không hoạt động                     │
└─────────────────────────────────────────────┘
```

## Thông báo lỗi

### Frontend
```
❌ Điều phối viên chỉ được phép chuyển tài xế sang trạng thái 
   'Hoạt động' hoặc 'Không hoạt động'.
```

### Backend
```
❌ Điều phối viên chỉ được phép chuyển tài xế sang trạng thái 
   'Hoạt động' (ACTIVE) hoặc 'Không hoạt động' (INACTIVE).

❌ Không thể thay đổi trạng thái khi tài xế đang trong chuyến đi.

❌ Trạng thái không hợp lệ: <status>
```

## Test Cases

### ✅ Test Case 1: Coordinator chuyển AVAILABLE → ACTIVE
- **Kết quả:** Thành công
- **Lý do:** Được phép

### ✅ Test Case 2: Coordinator chuyển ACTIVE → INACTIVE
- **Kết quả:** Thành công
- **Lý do:** Được phép

### ✅ Test Case 3: Coordinator chuyển INACTIVE → ACTIVE
- **Kết quả:** Thành công
- **Lý do:** Được phép

### ❌ Test Case 4: Coordinator chuyển ACTIVE → ON_TRIP
- **Kết quả:** Thất bại
- **Lý do:** Không có option ON_TRIP trong dropdown
- **Thông báo:** (Không thể chọn)

### ❌ Test Case 5: Coordinator chuyển ACTIVE → OFF_DUTY
- **Kết quả:** Thất bại
- **Lý do:** Không có option OFF_DUTY trong dropdown
- **Thông báo:** (Không thể chọn)

### ❌ Test Case 6: Coordinator bypass frontend, gửi API với status=ON_TRIP
- **Kết quả:** Thất bại
- **Lý do:** Bị chặn bởi backend validation
- **HTTP Status:** 400 Bad Request
- **Thông báo:** "Điều phối viên chỉ được phép..."

### ❌ Test Case 7: Coordinator thay đổi trạng thái khi tài xế đang ON_TRIP
- **Kết quả:** Thất bại
- **Lý do:** Dropdown bị disable
- **UI:** Hiển thị cảnh báo "Tài xế đang trong chuyến..."

### ✅ Test Case 8: Admin/Manager chuyển ACTIVE → ON_TRIP
- **Kết quả:** Thành công
- **Lý do:** Admin/Manager có đầy đủ quyền

## So sánh quyền

| Thao tác | Admin | Manager | Coordinator |
|----------|-------|---------|-------------|
| Xem danh sách tài xế | ✅ | ✅ | ✅ (chi nhánh) |
| Xem chi tiết tài xế | ✅ | ✅ | ✅ |
| Tạo tài xế mới | ✅ | ✅ | ❌ |
| Xóa tài xế | ✅ | ❌ | ❌ |
| Sửa thông tin cơ bản | ✅ | ✅ | ✅ |
| Chuyển sang ACTIVE | ✅ | ✅ | ✅ |
| Chuyển sang INACTIVE | ✅ | ✅ | ✅ |
| Chuyển sang ON_TRIP | ✅ | ✅ | ❌ |
| Chuyển sang OFF_DUTY | ✅ | ✅ | ❌ |
| Chuyển sang AVAILABLE | ✅ | ✅ | ❌ |
| Sửa khi đang ON_TRIP | ✅ | ✅ | ❌ |

## Workflow tự động

### Khi tài xế được gán vào chuyến
```
ACTIVE/AVAILABLE → ON_TRIP (tự động)
```

### Khi tài xế hoàn thành chuyến
```
ON_TRIP → ACTIVE (tự động)
```

### Khi tài xế đăng ký nghỉ và được duyệt
```
ACTIVE → OFF_DUTY (tự động)
```

### Khi kết thúc kỳ nghỉ
```
OFF_DUTY → ACTIVE (tự động)
```

## Màu sắc trạng thái

| Trạng thái | Màu | Mô tả |
|------------|-----|-------|
| ACTIVE | 🟢 Xanh lá | Hoạt động, sẵn sàng nhận chuyến |
| AVAILABLE | 🟢 Xanh lá | Sẵn sàng (legacy) |
| ON_TRIP | 🔵 Xanh dương | Đang trong chuyến |
| OFF_DUTY | 🟡 Vàng | Đang nghỉ |
| INACTIVE | ⚫ Xám | Không hoạt động |

## Files đã thay đổi

### Frontend
- ✅ `vantai/PTCMSS_FRONTEND/src/components/module 5/CoordinatorDriverDetailPage.jsx`

### Backend
- ✅ `vantai/PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/service/impl/DriverServiceImpl.java`
- ✅ `vantai/PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/enums/DriverStatus.java`

### Documentation
- ✅ `vantai/COORDINATOR_DRIVER_STATUS_RESTRICTION.md`

## Lưu ý kỹ thuật

1. **Double Protection**: Validation ở cả frontend và backend
2. **SecurityContextHolder**: Sử dụng để lấy role của user hiện tại
3. **Backward Compatible**: Enum hỗ trợ cả legacy values (Available, OnTrip, etc.)
4. **UI Feedback**: Disable + warning khi không thể thay đổi
5. **Logging**: Log chi tiết để debug

## Hướng dẫn test

1. Đăng nhập với tài khoản Coordinator
2. Vào "Danh sách tài xế" → Click vào một tài xế
3. Click "Chỉnh sửa"
4. Kiểm tra dropdown "Trạng thái" chỉ có 2 options: Hoạt động, Không hoạt động
5. Thử chuyển trạng thái → Click "Lưu"
6. Kiểm tra thông báo thành công
7. Nếu tài xế đang ON_TRIP, dropdown sẽ bị disable

## Kết quả mong đợi

✅ Coordinator có thể:
- Xem danh sách tài xế của chi nhánh
- Xem chi tiết tài xế
- Cập nhật thông tin cá nhân, GPLX, sức khỏe
- Chuyển tài xế sang: **Hoạt động** (ACTIVE)
- Chuyển tài xế sang: **Không hoạt động** (INACTIVE)

❌ Coordinator KHÔNG thể:
- Chuyển tài xế sang: **Đang chạy** (ON_TRIP)
- Chuyển tài xế sang: **Nghỉ** (OFF_DUTY)
- Chuyển tài xế sang: **Sẵn sàng** (AVAILABLE)
- Thay đổi trạng thái khi tài xế đang ON_TRIP

🔒 Validation được thực hiện ở cả frontend và backend (double protection)
