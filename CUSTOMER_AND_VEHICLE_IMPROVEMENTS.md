# Cải tiến Danh sách Khách hàng và Xe

## Tóm tắt thay đổi

### 1. Danh sách Khách hàng - Role Manager chỉ xem khách hàng của chi nhánh mình quản lý

#### Backend Changes

**CustomerController.java**
- Thêm tham số `userId` vào API `GET /api/customers`
- Cập nhật description: "Manager chỉ xem khách hàng của chi nhánh mình quản lý"

**CustomerService.java**
- Cập nhật interface method `listCustomers` để nhận thêm tham số `userId`

**CustomerServiceImpl.java**
- Thêm logic kiểm tra role của user
- Nếu user là MANAGER, tự động filter theo `branchId` của manager đó
- Sử dụng `employeeRepository.findByUserId()` để lấy thông tin employee và branch

**CustomerRepository.java**
- Đã có sẵn query `findWithFilters` hỗ trợ filter theo `branchId`
- Không cần thay đổi

#### Frontend Changes

**customers.js (API)**
- Thêm tham số `userId` vào function `listCustomers`

**CustomerListPage.jsx**
- Import thêm: `getEmployeeByUserId`, `getCurrentRole`, `getStoredUserId`, `ROLES`
- Thêm state để lưu thông tin manager: `managerBranchId`, `managerBranchName`
- Thêm useEffect để load thông tin chi nhánh của manager khi component mount
- Cập nhật `fetchCustomers` để gửi `userId` trong request
- Cập nhật header để hiển thị tên chi nhánh của manager
- Ẩn dropdown "Chi nhánh" cho role Manager (chỉ hiển thị cho Admin và các role khác)

### 2. Danh sách Xe - Chuyển nút "Thêm xe" về trước

**VehicleListPage.jsx**
- Nút "Thêm xe" đã được đặt ở vị trí `left` (trước các bộ lọc)
- Prop `createButtonPosition="left"` đã được set trong FilterBar
- Không cần thay đổi gì thêm

## Kết quả

### Manager Role
- Khi đăng nhập với role MANAGER, danh sách khách hàng sẽ tự động lọc theo chi nhánh mà manager quản lý
- Dropdown "Chi nhánh" sẽ bị ẩn đi
- Header hiển thị: "Chi nhánh: [Tên chi nhánh] • Tổng: X khách hàng"

### Admin và các role khác
- Vẫn có thể xem tất cả khách hàng
- Vẫn có dropdown "Chi nhánh" để filter
- Header hiển thị: "Quản lý thông tin khách hàng • Tổng: X khách hàng"

### Danh sách Xe
- Nút "Thêm xe" đã được đặt ở vị trí đầu tiên, trước các bộ lọc
- Layout: [Thêm xe] ... [Bộ lọc] [Làm mới]

## Files đã thay đổi

### Backend
1. `vantai/PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/controller/CustomerController.java`
2. `vantai/PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/service/CustomerService.java`
3. `vantai/PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/service/impl/CustomerServiceImpl.java`

### Frontend
1. `vantai/PTCMSS_FRONTEND/src/api/customers.js`
2. `vantai/PTCMSS_FRONTEND/src/components/module 1/CustomerListPage.jsx`

## Testing

### Test Case 1: Manager xem danh sách khách hàng
1. Đăng nhập với tài khoản Manager
2. Vào trang "Danh sách khách hàng"
3. Kiểm tra:
   - Header hiển thị tên chi nhánh của manager
   - Dropdown "Chi nhánh" bị ẩn
   - Chỉ hiển thị khách hàng của chi nhánh manager quản lý

### Test Case 2: Admin xem danh sách khách hàng
1. Đăng nhập với tài khoản Admin
2. Vào trang "Danh sách khách hàng"
3. Kiểm tra:
   - Header hiển thị "Quản lý thông tin khách hàng"
   - Dropdown "Chi nhánh" vẫn hiển thị
   - Có thể filter theo chi nhánh
   - Hiển thị tất cả khách hàng

### Test Case 3: Vị trí nút "Thêm xe"
1. Vào trang "Danh sách xe"
2. Kiểm tra nút "Thêm xe" nằm ở vị trí đầu tiên, bên trái các bộ lọc
