# Triển khai các chức năng cho vai trò Kế toán (Accountant)

## Ngày: 1/12/2025

## Tóm tắt các yêu cầu

### 1. ✅ Danh sách nhân viên (EmployeeManagementPage)
- **Yêu cầu**: Kế toán chỉ xem được danh sách nhân viên của chi nhánh mình, ẩn nút thêm nhân viên
- **Trạng thái**: ✅ Đã hoàn thành
- **Thay đổi**:
  - Thêm biến `isAccountant` để kiểm tra vai trò
  - Lọc nhân viên theo chi nhánh của kế toán (tương tự Manager)
  - Ẩn nút "Tạo tài khoản mới" với kế toán
  - Ẩn dropdown chọn chi nhánh với kế toán (đã lock theo chi nhánh)
  - Hiển thị "Chỉ xem" trong cột thao tác thay vì nút sửa/xóa
  - Load branchId từ employee record của kế toán

### 2. ✅ Danh sách xe (VehicleListPage)
- **Yêu cầu**: Kế toán không được phép sửa/thêm xe, chỉ được xem chi tiết các chi phí đã chi cho chiếc xe đó
- **Trạng thái**: ✅ Đã hoàn thành (từ session trước)
- **Thay đổi**: Đã ẩn nút thêm/sửa, chỉ hiển thị nút xem chi phí

### 3. ✅ Thông báo (Notifications)
- **Yêu cầu**: Kế toán được nhận những thông báo liên quan về tiền:
  - Request đặt cọc/thanh toán nốt chuyến từ tư vấn viên/tài xế
  - Request duyệt chi - chi phí phụ trội từ tài xế/điều phối viên
- **Trạng thái**: ✅ Backend API đã có sẵn
- **API đã có**:
  - `GET /api/notifications/user/{userId}` - Lấy notifications của user với pagination
  - `GET /api/notifications/dashboard` - Dashboard tổng quan
  - `GET /api/notifications/alerts` - Lấy cảnh báo hệ thống
  - `POST /api/notifications/alerts/{alertId}/acknowledge` - Xác nhận đã xem cảnh báo
  - WebSocket support cho real-time notifications
  - **Permissions**: ACCOUNTANT role đã được thêm vào tất cả endpoints
- **Frontend**: 
  - Có thể sử dụng DriverNotificationsPage làm template
  - WebSocketContext đã có sẵn để nhận real-time notifications

### 4. ✅ Bảng điều khiển (AccountantDashboard)
- **Yêu cầu**: Sửa lỗi không duyệt request được ở màn hình này
- **Trạng thái**: ✅ Backend API đã có sẵn, cần test
- **API đã có**:
  - Dashboard đã có UI để duyệt/từ chối requests
  - Có 2 loại requests:
    1. **Approval requests** (chi phí, nghỉ phép, etc.):
       - `GET /api/notifications/approvals/pending` - Lấy danh sách chờ duyệt
       - `POST /api/notifications/approvals/{historyId}/approve` - Duyệt yêu cầu
       - `POST /api/notifications/approvals/{historyId}/reject` - Từ chối yêu cầu
    2. **Payment requests** (thanh toán từ driver/consultant):
       - `GET /api/invoices/payments/pending` - Lấy danh sách thanh toán chờ xác nhận
       - `POST /api/invoices/payments/{paymentId}/confirm` - Xác nhận đã nhận tiền
  - **Permissions**: ACCOUNTANT role đã được thêm vào tất cả endpoints cần thiết

## Chi tiết thay đổi code

### File: `vantai/PTCMSS_FRONTEND/src/components/module 1/EmployeeManagementPage.jsx`

#### 1. Thêm biến kiểm tra vai trò Accountant
```javascript
const isAccountant = currentRole === ROLES.ACCOUNTANT;
```

#### 2. Load branch cho cả Manager và Accountant
```javascript
// Load Manager/Accountant's branch
React.useEffect(() => {
    if ((!isManager && !isAccountant) || !currentUserId) return;
    
    (async () => {
        try {
            const resp = await getEmployeeByUserId(currentUserId);
            const emp = resp?.data || resp;
            if (emp?.branchId) {
                setManagerBranchId(emp.branchId);
                setManagerBranchName(emp.branchName || "");
                setFilterBranch(String(emp.branchId));
            }
        } catch (err) {
            console.error("Error loading user branch:", err);
        }
    })();
}, [isManager, isAccountant, currentUserId]);
```

#### 3. Filter nhân viên theo chi nhánh
```javascript
// Manager và Accountant chỉ xem nhân viên trong chi nhánh của mình
if ((isManager || isAccountant) && managerBranchId && emp.branchId !== managerBranchId) return false;
```

#### 4. Ẩn nút thêm nhân viên với Accountant
```javascript
{/* Chỉ Admin mới có nút thêm nhân viên */}
{isAdmin && (
    <button onClick={() => navigate("/admin/users/new")}>
        Tạo tài khoản mới
    </button>
)}
```

#### 5. Ẩn dropdown chi nhánh với Accountant
```javascript
{/* Chi nhánh - Ẩn với Manager và Accountant vì đã lock theo chi nhánh */}
{!isManager && !isAccountant && (
    <div>
        <select value={filterBranch} onChange={(e) => setFilterBranch(e.target.value)}>
            ...
        </select>
    </div>
)}
```

#### 6. Hiển thị "Chỉ xem" trong cột thao tác
```javascript
{/* Accountant chỉ xem, không có nút thao tác */}
{isAccountant && !isAdmin && !isManager && (
    <span className="text-xs text-slate-400">Chỉ xem</span>
)}
```

## Các API cần kiểm tra

### 1. Notifications API
- `GET /api/notifications` - Lấy danh sách thông báo
- `POST /api/notifications` - Tạo thông báo mới
- WebSocket endpoint cho real-time notifications

### 2. Approval API (AccountantDashboard)
- `GET /api/approvals/pending` - Lấy danh sách yêu cầu chờ duyệt
- `POST /api/approvals/{id}/approve` - Duyệt yêu cầu
- `POST /api/approvals/{id}/reject` - Từ chối yêu cầu

### 3. Payment API (AccountantDashboard)
- `GET /api/payments/pending` - Lấy danh sách thanh toán chờ xác nhận
- `POST /api/payments/{id}/confirm` - Xác nhận đã nhận tiền
- `POST /api/payments/{id}/reject` - Đánh dấu chưa nhận được tiền

## Các bước tiếp theo

1. ✅ Hoàn thành EmployeeManagementPage cho Accountant
2. ✅ Xác nhận backend API đã có đầy đủ
3. 🔄 Test các chức năng với vai trò Accountant:
   - Test xem danh sách nhân viên chi nhánh
   - Test xem danh sách xe (chỉ xem chi phí)
   - Test nhận notifications
   - Test duyệt/từ chối requests trong Dashboard
   - Test xác nhận payment requests
4. ⏳ Tạo AccountantNotificationsPage nếu cần (có thể dùng DriverNotificationsPage)
5. ⏳ Kiểm tra WebSocket notifications cho accountant role

## Ghi chú kỹ thuật

- Backend EmployeeController đã có permission cho ACCOUNTANT role
- Frontend đã sử dụng `getCurrentRole()` và `ROLES.ACCOUNTANT` từ session utils
- AccountantDashboard đã có UI hoàn chỉnh, chỉ cần kiểm tra API
- WebSocket context đã có sẵn cho real-time notifications


## Hướng dẫn Test

### 1. Test Danh sách nhân viên
1. Đăng nhập với tài khoản Accountant
2. Vào menu "Quản lý nhân viên"
3. Kiểm tra:
   - ✅ Chỉ hiển thị nhân viên trong chi nhánh của accountant
   - ✅ Không có nút "Tạo tài khoản mới"
   - ✅ Không có dropdown chọn chi nhánh (đã lock)
   - ✅ Cột "Thao tác" hiển thị "Chỉ xem" thay vì nút sửa/xóa
   - ✅ Hiển thị tên chi nhánh ở header

### 2. Test Danh sách xe
1. Vào menu "Quản lý xe"
2. Kiểm tra:
   - ✅ Không có nút "Thêm xe"
   - ✅ Không có nút "Sửa" trên từng xe
   - ✅ Chỉ có nút "Xem chi phí"
   - ✅ Click vào "Xem chi phí" hiển thị modal chi tiết các khoản chi

### 3. Test Thông báo
1. Vào trang Notifications
2. Kiểm tra:
   - ✅ Nhận được thông báo về yêu cầu thanh toán từ driver/consultant
   - ✅ Nhận được thông báo về yêu cầu duyệt chi phí
   - ✅ Có thể đánh dấu đã đọc
   - ✅ Real-time notifications qua WebSocket

### 4. Test Bảng điều khiển (Dashboard)
1. Vào AccountantDashboard
2. Kiểm tra phần "Yêu cầu chi phí chờ duyệt":
   - ✅ Hiển thị danh sách requests
   - ✅ Có thể search và filter
   - ✅ Click "Duyệt" một request:
     - Hiển thị modal xác nhận
     - Click "Xác nhận" → API call thành công
     - Request biến mất khỏi danh sách pending
     - Hiển thị toast "Đã duyệt yêu cầu #XXX"
   - ✅ Click "Từ chối" một request:
     - Hiển thị modal yêu cầu nhập lý do
     - Nhập lý do và click "Xác nhận"
     - API call thành công
     - Request biến mất khỏi danh sách
     - Hiển thị toast "Đã từ chối yêu cầu #XXX"
   - ✅ Bulk actions (chọn nhiều requests):
     - Chọn checkbox nhiều requests
     - Click "Duyệt đã chọn" hoặc "Từ chối đã chọn"
     - Tất cả requests được xử lý

3. Kiểm tra phần "Yêu cầu thanh toán chờ xác nhận":
   - ✅ Hiển thị danh sách payment requests
   - ✅ Click "Đã nhận":
     - API call thành công
     - Payment được confirm
     - Hiển thị toast "Đã xác nhận nhận tiền"
   - ✅ Click "Chưa nhận được":
     - API call thành công
     - Payment bị reject
     - Hiển thị toast thông báo

### 5. Test Permissions
1. Thử truy cập các trang không được phép:
   - ✅ Không thể tạo/sửa nhân viên
   - ✅ Không thể tạo/sửa xe
   - ✅ Không thể tạo/sửa đơn hàng (đã xử lý từ session trước)
2. Kiểm tra API permissions:
   - ✅ GET /api/employees - có quyền
   - ✅ GET /api/employees/branch/{branchId} - có quyền
   - ✅ GET /api/notifications/approvals/pending - có quyền
   - ✅ POST /api/notifications/approvals/{id}/approve - có quyền
   - ✅ POST /api/notifications/approvals/{id}/reject - có quyền

## Troubleshooting

### Lỗi: Không duyệt được request
**Nguyên nhân**: API endpoint không hoạt động hoặc thiếu userId
**Giải pháp**: 
- Kiểm tra console log xem có error gì
- Verify userId được gửi trong request body
- Kiểm tra backend logs

### Lỗi: Không nhận được notifications
**Nguyên nhân**: WebSocket chưa connect hoặc backend chưa gửi
**Giải pháp**:
- Kiểm tra WebSocket connection trong browser DevTools
- Verify backend có gửi notifications cho accountant role
- Kiểm tra NotificationService backend

### Lỗi: Thấy nhân viên từ chi nhánh khác
**Nguyên nhân**: Filter logic chưa đúng hoặc branchId không load được
**Giải pháp**:
- Kiểm tra console log xem managerBranchId có giá trị không
- Verify API getEmployeeByUserId trả về đúng branchId
- Kiểm tra filter logic trong useMemo

## Backend Endpoints Summary

### Notifications & Approvals
```
GET    /api/notifications/dashboard?branchId={branchId}
GET    /api/notifications/alerts?branchId={branchId}
POST   /api/notifications/alerts/{alertId}/acknowledge
GET    /api/notifications/approvals/pending?branchId={branchId}
GET    /api/notifications/approvals/processed?branchId={branchId}
POST   /api/notifications/approvals/{historyId}/approve
POST   /api/notifications/approvals/{historyId}/reject
GET    /api/notifications/user/{userId}?page={page}&limit={limit}
DELETE /api/notifications/{notificationId}?userId={userId}
```

### Expense Requests
```
GET    /api/expense-requests/pending
POST   /api/expense-requests/{id}/approve?note={note}
POST   /api/expense-requests/{id}/reject?note={note}
GET    /api/expense-requests?status={status}&branchId={branchId}
```

### Employees
```
GET    /api/employees
GET    /api/employees/branch/{branchId}
GET    /api/employees/user/{userId}
```

### Invoices/Payments
```
GET    /api/invoices/payments/pending?branchId={branchId}
POST   /api/invoices/payments/{paymentId}/confirm
```

Tất cả endpoints trên đều có permission cho ACCOUNTANT role.
