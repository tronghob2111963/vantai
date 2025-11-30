# Sửa quyền Kế toán - Xóa các chức năng không thuộc quyền

## Tóm tắt thay đổi

Kế toán chỉ được xem thông tin, không được phép:
1. Sửa đơn hàng
2. Tạo thanh toán tiền mặt/QR

## Chi tiết thay đổi

### 1. Xóa nút "Sửa" trong danh sách đơn hàng

**File:** `ConsultantOrderListPage.jsx`

**Thay đổi:**
- Thêm biến `isAccountant` để kiểm tra role
- Cập nhật prop `showActions={!isManager && !isAccountant}` trong OrdersTable
- Khi `showActions=false`, cột "Hành động" với nút "Chi tiết" và "Sửa" sẽ bị ẩn

**Code:**
```javascript
// Thêm check role
const isAccountant = currentRole === ROLES.ACCOUNTANT;

// Ẩn actions cho Manager và Accountant
<OrdersTable
    ...
    showActions={!isManager && !isAccountant}
/>
```

### 2. Xóa phần tạo thanh toán trong chi tiết đơn hàng

**File:** `OrderDetailPage.jsx`

**Thay đổi:**
- Xóa nút "Ghi nhận thanh toán" và "Tạo QR" trong `PaymentInfoCard`
- Xóa nút "Ghi nhận thanh toán" trong sidebar bên phải
- Kế toán vẫn có thể xem thông tin thanh toán và lịch sử, nhưng không thể tạo mới

**Code đã xóa:**
```javascript
// Đã xóa:
<button onClick={onOpenDeposit}>
    <BadgeDollarSign />
    <span>Ghi nhận thanh toán</span>
</button>

<button onClick={onGenerateQr}>
    <QrCode />
    <span>Tạo QR</span>
</button>
```

## Kết quả

### Kế toán (ACCOUNTANT) role:

**Danh sách đơn hàng (`/accountant/orders`):**
- ✅ Xem danh sách đơn hàng
- ✅ Lọc theo trạng thái, ngày, tìm kiếm
- ✅ Xem chi tiết đơn (nút "Chi tiết")
- ❌ Không có nút "Sửa"
- ❌ Không có cột "Hành động"

**Chi tiết đơn hàng (`/orders/:orderId`):**
- ✅ Xem đầy đủ thông tin đơn hàng
- ✅ Xem thông tin khách hàng
- ✅ Xem lịch trình
- ✅ Xem báo giá
- ✅ Xem thông tin thanh toán (đã thu, còn lại)
- ✅ Xem lịch sử thanh toán
- ❌ Không có nút "Ghi nhận thanh toán"
- ❌ Không có nút "Tạo QR"
- ❌ Không có sidebar thanh toán bên phải

### Các role khác (ADMIN, CONSULTANT, COORDINATOR):

- Vẫn giữ nguyên tất cả chức năng
- Có thể sửa đơn hàng
- Có thể tạo thanh toán TM/QR

## Files đã thay đổi

1. `vantai/PTCMSS_FRONTEND/src/components/module 4/ConsultantOrderListPage.jsx`
   - Thêm `isAccountant` check
   - Cập nhật `showActions` prop

2. `vantai/PTCMSS_FRONTEND/src/components/module 4/OrderDetailPage.jsx`
   - Xóa nút "Ghi nhận thanh toán" trong PaymentInfoCard
   - Xóa nút "Tạo QR" trong PaymentInfoCard
   - Xóa nút "Ghi nhận thanh toán" trong sidebar

## Testing

### Test Case 1: Kế toán xem danh sách đơn hàng
1. Đăng nhập với tài khoản Kế toán
2. Vào menu "Danh sách đơn hàng" (`/accountant/orders`)
3. Kiểm tra:
   - Danh sách đơn hàng hiển thị đầy đủ
   - Có nút "Chi tiết" để xem chi tiết
   - KHÔNG có nút "Sửa"
   - KHÔNG có cột "Hành động" (hoặc cột này bị ẩn)

### Test Case 2: Kế toán xem chi tiết đơn hàng
1. Đăng nhập với tài khoản Kế toán
2. Click vào một đơn hàng để xem chi tiết
3. Kiểm tra:
   - Thông tin đơn hàng hiển thị đầy đủ
   - Thông tin thanh toán hiển thị (đã thu, còn lại)
   - Lịch sử thanh toán hiển thị
   - KHÔNG có nút "Ghi nhận thanh toán"
   - KHÔNG có nút "Tạo QR"
   - KHÔNG có sidebar thanh toán bên phải

### Test Case 3: Consultant vẫn có đầy đủ quyền
1. Đăng nhập với tài khoản Consultant
2. Vào danh sách đơn hàng
3. Kiểm tra:
   - Có nút "Sửa" trong danh sách
   - Có thể sửa đơn hàng
   - Có nút "Ghi nhận thanh toán" trong chi tiết
   - Có nút "Tạo QR" trong chi tiết

## Lưu ý

- Kế toán vẫn có thể truy cập vào trang chi tiết đơn hàng thông qua URL trực tiếp
- Backend cần có validation để đảm bảo Kế toán không thể gọi API tạo thanh toán
- Nếu cần thêm quyền cho Kế toán trong tương lai, chỉ cần thay đổi điều kiện `showActions` và thêm lại các nút đã xóa
