# Các tác vụ còn lại cho role Kế toán (ACCOUNTANT)

## Đã hoàn thành ✅

### 1. Sửa lỗi 403 Forbidden
- ✅ Thêm quyền ACCOUNTANT vào `EmployeeController`:
  - `GET /api/employees` - Xem tất cả nhân viên
  - `GET /api/employees/role/{roleName}` - Lọc theo role
  - `GET /api/employees/branch/{branchId}` - Lọc theo chi nhánh
- ✅ Thêm quyền ACCOUNTANT vào `RoleController`:
  - `GET /api/roles` - Xem danh sách vai trò

### 2. Danh sách khách hàng
- ✅ Manager chỉ xem khách hàng của chi nhánh mình quản lý
- ✅ Ẩn dropdown chi nhánh cho Manager
- ✅ Backend tự động filter theo branchId của Manager

### 3. Danh sách đơn hàng
- ✅ Kế toán có thể xem danh sách đơn hàng
- ✅ Kế toán có nút "Chi tiết" để xem chi tiết đơn
- ✅ Ẩn nút "Sửa" cho Kế toán

### 4. Chi tiết đơn hàng
- ✅ Xóa sidebar thanh toán bên phải
- ✅ Xóa card "Thanh toán / Cọc"
- ✅ Xóa nút "Ghi nhận thanh toán"
- ✅ Xóa nút "Tạo QR"

### 5. Danh sách xe
- ✅ Nút "Thêm xe" đã ở vị trí đầu tiên

## Cần làm tiếp ⏳

### 1. Danh sách nhân viên (AdminUsersPage)

**Yêu cầu:**
- Kế toán chỉ xem được nhân viên của chi nhánh mình
- Ẩn nút "Thêm nhân viên"

**Cần làm:**
1. Thêm logic filter theo branchId của Kế toán trong AdminUsersPage
2. Ẩn nút "Thêm nhân viên" khi role là ACCOUNTANT
3. Có thể cần thêm API endpoint mới hoặc cập nhật logic filter

**Files cần sửa:**
- `vantai/PTCMSS_FRONTEND/src/components/module 1/AdminUsersPage.jsx`
- Có thể cần cập nhật `vantai/PTCMSS_FRONTEND/src/api/employees.js`

### 2. Danh sách xe (VehicleListPage)

**Yêu cầu:**
- Kế toán không được phép sửa/thêm xe
- Chỉ được xem chi tiết các chi phí đã chi cho chiếc xe đó

**Cần làm:**
1. Ẩn nút "Thêm xe" cho ACCOUNTANT
2. Ẩn nút "Sửa" trong danh sách xe
3. Trong trang chi tiết xe (VehicleDetailPage):
   - Chỉ hiển thị thông tin xe (read-only)
   - Hiển thị danh sách chi phí đã chi cho xe
   - Ẩn các nút chỉnh sửa

**Files cần sửa:**
- `vantai/PTCMSS_FRONTEND/src/components/module 3/VehicleListPage.jsx`
- `vantai/PTCMSS_FRONTEND/src/components/module 3/VehicleDetailPage.jsx`

### 3. Thông báo cho Kế toán

**Yêu cầu:**
Kế toán được nhận những thông báo liên quan về tiền:
- Request đặt cọc/thanh toán nốt chuyến từ tư vấn viên/tài xế
- Request duyệt chi - chi phí phụ trội từ tài xế/điều phối viên

**Cần làm:**
1. Kiểm tra hệ thống thông báo hiện tại (NotificationsWidget)
2. Đảm bảo backend gửi thông báo cho role ACCOUNTANT khi:
   - Có request đặt cọc mới
   - Có request thanh toán nốt chuyến
   - Có request duyệt chi phí phụ trội
3. Filter thông báo theo role trong frontend

**Files cần kiểm tra:**
- `vantai/PTCMSS_FRONTEND/src/components/module 5/NotificationsWidget.jsx`
- Backend notification service
- WebSocket configuration

## Chi tiết implementation

### Task 1: Danh sách nhân viên

```javascript
// AdminUsersPage.jsx

// Thêm check role
const currentRole = getCurrentRole();
const currentUserId = getStoredUserId();
const isAccountant = currentRole === ROLES.ACCOUNTANT;

// Load branch của accountant
const [accountantBranchId, setAccountantBranchId] = useState(null);

useEffect(() => {
    if (!isAccountant || !currentUserId) return;
    
    (async () => {
        try {
            const resp = await getEmployeeByUserId(currentUserId);
            const emp = resp?.data || resp;
            if (emp?.branchId) {
                setAccountantBranchId(emp.branchId);
            }
        } catch (err) {
            console.error("Error loading accountant branch:", err);
        }
    })();
}, [isAccountant, currentUserId]);

// Filter employees
const filteredEmployees = employees.filter(emp => {
    if (isAccountant && accountantBranchId) {
        return emp.branchId === accountantBranchId;
    }
    return true;
});

// Ẩn nút thêm nhân viên
{!isAccountant && (
    <button onClick={handleCreateEmployee}>
        Thêm nhân viên
    </button>
)}
```

### Task 2: Danh sách xe

```javascript
// VehicleListPage.jsx

const isAccountant = currentRole === ROLES.ACCOUNTANT;

// Ẩn nút thêm xe
{!isAccountant && (
    <button onClick={handleCreateVehicle}>
        Thêm xe
    </button>
)}

// Trong FilterBar, ẩn nút thêm xe
<FilterBar
    ...
    showCreateButton={!isAccountant}
/>

// VehicleDetailPage.jsx

const isAccountant = currentRole === ROLES.ACCOUNTANT;

// Ẩn các nút chỉnh sửa
{!isAccountant && (
    <button onClick={handleEdit}>Sửa</button>
)}

// Hiển thị danh sách chi phí
<ExpenseListCard vehicleId={vehicleId} />
```

### Task 3: Thông báo

```javascript
// Backend - NotificationService.java

public void sendPaymentRequestNotification(PaymentRequest request) {
    // Gửi cho ACCOUNTANT
    List<User> accountants = userRepository.findByRole(Role.ACCOUNTANT);
    for (User accountant : accountants) {
        notificationRepository.save(Notification.builder()
            .userId(accountant.getId())
            .type(NotificationType.PAYMENT_REQUEST)
            .title("Yêu cầu thanh toán mới")
            .message("Có yêu cầu thanh toán từ " + request.getCreatedBy())
            .build());
    }
}

// Frontend - NotificationsWidget.jsx

// Filter notifications theo role
const filteredNotifications = notifications.filter(notif => {
    if (isAccountant) {
        // Chỉ hiển thị thông báo liên quan tiền
        return ['PAYMENT_REQUEST', 'DEPOSIT_REQUEST', 'EXPENSE_APPROVAL'].includes(notif.type);
    }
    return true;
});
```

## Testing checklist

### Danh sách nhân viên
- [ ] Kế toán chỉ xem được nhân viên của chi nhánh mình
- [ ] Không có nút "Thêm nhân viên"
- [ ] Có thể xem chi tiết nhân viên
- [ ] Không thể sửa/xóa nhân viên

### Danh sách xe
- [ ] Không có nút "Thêm xe"
- [ ] Không có nút "Sửa" trong danh sách
- [ ] Có nút "Chi tiết" để xem thông tin xe
- [ ] Trong chi tiết xe, hiển thị danh sách chi phí
- [ ] Không có các nút chỉnh sửa thông tin xe

### Thông báo
- [ ] Nhận thông báo khi có request đặt cọc
- [ ] Nhận thông báo khi có request thanh toán
- [ ] Nhận thông báo khi có request duyệt chi phí
- [ ] Không nhận các thông báo không liên quan (phân xe, lịch trình, etc.)

## Priority

1. **HIGH**: Danh sách nhân viên (đang bị lỗi 403 - đã fix backend, cần fix frontend)
2. **HIGH**: Danh sách xe (cần ẩn các nút chỉnh sửa)
3. **MEDIUM**: Thông báo (cần kiểm tra và filter)

## Notes

- Backend đã được cập nhật để cho phép ACCOUNTANT truy cập `/api/employees` và `/api/roles`
- Cần rebuild backend sau khi sửa: `mvn clean install -DskipTests`
- Frontend cần thêm logic filter và ẩn nút cho từng trang
