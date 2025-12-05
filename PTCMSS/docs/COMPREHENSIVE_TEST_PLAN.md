# Kế hoạch Test Toàn Diện - PTCMSS

## Phân tích theo Role và Chức năng

### 1. CONSULTANT (Tư vấn viên)
**Chức năng:**
- Tạo booking mới
- Xem danh sách booking
- Cập nhật booking
- Tính giá
- Kiểm tra khả dụng xe
- Dashboard consultant

**Service cần test:**
- ✅ `BookingServiceImpl.create()` - Đã có test
- ✅ `BookingServiceImpl.update()` - Đã có test
- ✅ `BookingServiceImpl.getById()` - Đã có test
- ❌ `BookingServiceImpl.getAll()` - Cần test
- ❌ `BookingServiceImpl.getBookingList()` - Cần test
- ❌ `BookingServiceImpl.calculatePrice()` - Đã có test (3 cases)
- ❌ `BookingServiceImpl.checkAvailability()` - Đã có test (2 cases)
- ❌ `BookingServiceImpl.getConsultantDashboard()` - Cần test
- ❌ `BookingServiceImpl.addPayment()` - Cần test
- ❌ `BookingServiceImpl.delete()` - Cần test

### 2. COORDINATOR (Điều phối viên)
**Chức năng:**
- Xem danh sách chuyến chờ gán
- Gán tài xế/xe cho chuyến
- Hủy gán
- Gán lại
- Dashboard điều phối
- Tạo yêu cầu chi phí
- Xem danh sách yêu cầu chi phí
- Xử lý sự cố
- Cập nhật hồ sơ xe (không được set INUSE)
- Cập nhật hồ sơ tài xế (chỉ được set AVAILABLE/INACTIVE)

**Service cần test:**
- ❌ `DispatchServiceImpl.getPendingTrips()` - Đã có test (1 case, cần thêm)
- ❌ `DispatchServiceImpl.getAssignmentSuggestions()` - Cần test
- ❌ `DispatchServiceImpl.assign()` - Cần test (Priority 1)
- ❌ `DispatchServiceImpl.unassign()` - Cần test
- ❌ `DispatchServiceImpl.reassign()` - Cần test
- ❌ `DispatchServiceImpl.getDashboard()` - Cần test
- ❌ `DispatchServiceImpl.getTripDetail()` - Cần test
- ❌ `DispatchServiceImpl.searchTrips()` - Cần test
- ✅ `ExpenseRequestServiceImpl` - Đã có test đầy đủ (22 tests)
- ✅ `VehicleServiceImpl.update()` - Đã có test (1 case, cần thêm success case)
- ✅ `DriverServiceImpl.updateProfile()` - Đã có test (2 cases)

### 3. DRIVER (Tài xế)
**Chức năng:**
- Xem dashboard
- Xem lịch trình
- Xem/update hồ sơ
- Xin nghỉ phép
- Xem lịch sử nghỉ phép
- Hủy yêu cầu nghỉ phép
- Bắt đầu chuyến
- Hoàn thành chuyến
- Báo cáo sự cố
- Xem danh sách yêu cầu chi phí

**Service cần test:**
- ❌ `DriverServiceImpl.getDashboard()` - Cần test
- ❌ `DriverServiceImpl.getSchedule()` - Cần test
- ❌ `DriverServiceImpl.getProfile()` - Cần test
- ❌ `DriverServiceImpl.getProfileByUserId()` - Cần test
- ✅ `DriverServiceImpl.updateProfile()` - Đã có test
- ✅ `DriverServiceImpl.requestDayOff()` - Đã có test
- ❌ `DriverServiceImpl.getDayOffHistory()` - Cần test
- ❌ `DriverServiceImpl.cancelDayOffRequest()` - Cần test
- ❌ `DriverServiceImpl.startTrip()` - Cần test (Priority 1)
- ❌ `DriverServiceImpl.completeTrip()` - Cần test (Priority 1)
- ❌ `DriverServiceImpl.reportIncident()` - Cần test

### 4. ACCOUNTANT (Kế toán)
**Chức năng:**
- Duyệt/từ chối yêu cầu chi phí
- Xem danh sách hóa đơn
- Tạo hóa đơn
- Cập nhật hóa đơn
- Ghi nhận thanh toán
- Xác nhận thanh toán
- Xem lịch sử thanh toán
- Gửi hóa đơn
- Hủy hóa đơn

**Service cần test:**
- ✅ `ExpenseRequestServiceImpl.approveRequest()` - Đã có test
- ✅ `ExpenseRequestServiceImpl.rejectRequest()` - Đã có test
- ❌ `InvoiceServiceImpl.createInvoice()` - Cần test (Priority 2)
- ❌ `InvoiceServiceImpl.updateInvoice()` - Cần test
- ❌ `InvoiceServiceImpl.voidInvoice()` - Cần test
- ❌ `InvoiceServiceImpl.recordPayment()` - Cần test
- ❌ `InvoiceServiceImpl.confirmPayment()` - Cần test
- ❌ `InvoiceServiceImpl.getInvoices()` - Cần test
- ❌ `InvoiceServiceImpl.getPaymentHistory()` - Cần test
- ❌ `InvoiceServiceImpl.sendInvoice()` - Cần test
- ❌ `PaymentService.generateQRCode()` - Cần test
- ❌ `PaymentService.createDeposit()` - Cần test

### 5. MANAGER (Quản lý)
**Chức năng:**
- Xem dashboard
- Quản lý nhân viên
- Quản lý khách hàng
- Quản lý xe
- Xem báo cáo
- Duyệt yêu cầu nghỉ phép
- Quản lý cài đặt hệ thống

**Service cần test:**
- ❌ `EmployeeServiceImpl.createEmployee()` - Cần test
- ❌ `EmployeeServiceImpl.updateEmployee()` - Cần test
- ❌ `CustomerService.createCustomer()` - Cần test
- ❌ `CustomerService.findOrCreateCustomer()` - Cần test
- ❌ `CustomerService.listCustomers()` - Cần test
- ✅ `VehicleServiceImpl.create()` - Đã có test
- ✅ `VehicleServiceImpl.update()` - Đã có test (1 case, cần thêm)
- ❌ `VehicleServiceImpl.getById()` - Cần test
- ❌ `VehicleServiceImpl.getAll()` - Cần test
- ❌ `VehicleServiceImpl.delete()` - Cần test
- ❌ `SystemSettingServiceImpl.getAll()` - Cần test
- ❌ `SystemSettingServiceImpl.update()` - Cần test
- ❌ `AnalyticsService.getVehicleEfficiency()` - Cần test

### 6. ADMIN (Quản trị viên)
**Chức năng:**
- Tất cả chức năng của Manager
- Quản lý người dùng
- Quản lý role
- Quản lý chi nhánh
- Quản lý cài đặt hệ thống

**Service cần test:**
- ❌ `UserService` - Cần test
- ❌ `BranchService` - Cần test
- ❌ `RoleService` - Cần test
- ❌ `SystemSettingServiceImpl.create()` - Cần test
- ❌ `SystemSettingServiceImpl.delete()` - Cần test

### 7. AUTHENTICATION (Tất cả roles)
**Chức năng:**
- Đăng nhập
- Refresh token
- Quên mật khẩu
- Đặt mật khẩu

**Service cần test:**
- ❌ `AuthenticationServiceImpl.getAccessToken()` - Cần test (Priority 2)
- ❌ `AuthenticationServiceImpl.getRefreshToken()` - Cần test
- ❌ `AuthenticationServiceImpl.forgotPassword()` - Cần test
- ❌ `AuthenticationServiceImpl.setPassword()` - Cần test

### 8. NOTIFICATION (Tất cả roles)
**Chức năng:**
- Xem thông báo
- Đánh dấu đã đọc
- Xóa thông báo
- Dashboard thông báo

**Service cần test:**
- ❌ `NotificationServiceImpl.getUserNotifications()` - Cần test
- ❌ `NotificationServiceImpl.getPendingApprovals()` - Cần test
- ❌ `NotificationServiceImpl.approveRequest()` - Cần test
- ❌ `NotificationServiceImpl.rejectRequest()` - Cần test
- ❌ `NotificationServiceImpl.deleteNotification()` - Cần test

---

## Kế hoạch Viết Test (Theo Priority)

### Phase 1: Critical Business Logic (Tuần 1-2)
1. ✅ `BookingServiceImpl.create()` - Đã xong
2. ✅ `BookingServiceImpl.update()` - Đã xong
3. ❌ `DispatchServiceImpl.assign()` - Gán tài xế/xe
4. ❌ `DriverServiceImpl.startTrip()` - Bắt đầu chuyến
5. ❌ `DriverServiceImpl.completeTrip()` - Hoàn thành chuyến

### Phase 2: Data Retrieval & CRUD (Tuần 3-4)
1. ❌ `BookingServiceImpl.getAll()` - List bookings
2. ❌ `BookingServiceImpl.delete()` - Xóa booking
3. ❌ `DriverServiceImpl.getProfile()` / `getSchedule()` - Profile & schedule
4. ❌ `VehicleServiceImpl.getById()` / `getAll()` - Get vehicles
5. ❌ `DispatchServiceImpl.getTripDetail()` - Chi tiết chuyến
6. ❌ `InvoiceServiceImpl.createInvoice()` - Tạo hóa đơn
7. ❌ `InvoiceServiceImpl.getInvoices()` - List invoices

### Phase 3: Supporting Functions (Tuần 5-6)
1. ❌ `BookingServiceImpl.addPayment()` - Thêm thanh toán
2. ❌ `DriverServiceImpl.getDayOffHistory()` - Lịch sử nghỉ phép
3. ❌ `VehicleServiceImpl.delete()` - Xóa xe
4. ❌ `DispatchServiceImpl.unassign()` / `reassign()` - Hủy/gán lại
5. ❌ `InvoiceServiceImpl.recordPayment()` - Ghi nhận thanh toán
6. ❌ `PaymentService.generateQRCode()` - Tạo QR code

### Phase 4: Authentication & Utilities (Tuần 7-8)
1. ❌ `AuthenticationServiceImpl.getAccessToken()` - Đăng nhập
2. ❌ `CustomerService.findOrCreateCustomer()` - Tìm/tạo khách hàng
3. ❌ `EmployeeServiceImpl.createEmployee()` - Tạo nhân viên
4. ❌ `SystemSettingServiceImpl.getAll()` / `update()` - Cài đặt hệ thống
5. ❌ `NotificationServiceImpl.getUserNotifications()` - Thông báo

---

## Tổng số Test Cases Cần Viết

### BookingServiceImpl: ~15 tests (đã có 12, cần thêm 3)
- `getAll()` - 3 tests
- `delete()` - 2 tests
- `addPayment()` - 2 tests
- `getConsultantDashboard()` - 2 tests
- `getBookingList()` - 2 tests

### DriverServiceImpl: ~20 tests (đã có 3, cần thêm 17)
- `getDashboard()` - 2 tests
- `getSchedule()` - 3 tests
- `getProfile()` - 2 tests
- `getProfileByUserId()` - 2 tests
- `getDayOffHistory()` - 2 tests
- `cancelDayOffRequest()` - 3 tests
- `startTrip()` - 3 tests (Priority 1)
- `completeTrip()` - 3 tests (Priority 1)
- `reportIncident()` - 2 tests
- `createDriver()` - 2 tests
- `getDriversByBranchId()` - 2 tests

### DispatchServiceImpl: ~15 tests (đã có 1, cần thêm 14)
- `getPendingTrips()` - 2 tests (thêm cases)
- `getAllPendingTrips()` - 2 tests
- `getAssignmentSuggestions()` - 3 tests
- `assign()` - 4 tests (Priority 1)
- `unassign()` - 2 tests
- `reassign()` - 2 tests
- `getDashboard()` - 2 tests
- `getTripDetail()` - 2 tests
- `searchTrips()` - 2 tests
- `driverAcceptTrip()` - 2 tests

### InvoiceServiceImpl: ~20 tests
- `createInvoice()` - 4 tests
- `updateInvoice()` - 3 tests
- `voidInvoice()` - 3 tests
- `getInvoices()` - 3 tests
- `recordPayment()` - 3 tests
- `confirmPayment()` - 3 tests
- `getPaymentHistory()` - 2 tests
- `sendInvoice()` - 2 tests
- `getPendingPayments()` - 2 tests

### VehicleServiceImpl: ~15 tests (đã có 4, cần thêm 11)
- `getById()` - 2 tests
- `getAll()` - 2 tests
- `search()` - 2 tests
- `filter()` - 3 tests
- `delete()` - 3 tests
- `getVehicleExpenses()` - 2 tests
- `getVehicleMaintenance()` - 2 tests
- `createMaintenance()` - 2 tests
- `createExpense()` - 2 tests

### CustomerService: ~8 tests
- `findOrCreateCustomer()` - 3 tests
- `createCustomer()` - 2 tests
- `findByPhone()` - 2 tests
- `listCustomers()` - 3 tests

### EmployeeServiceImpl: ~10 tests
- `createEmployee()` - 3 tests
- `updateEmployee()` - 3 tests
- `findByRoleName()` - 2 tests
- `findByBranchId()` - 2 tests
- `findAvailableManagers()` - 2 tests

### AuthenticationServiceImpl: ~8 tests
- `getAccessToken()` - 3 tests
- `getRefreshToken()` - 2 tests
- `forgotPassword()` - 2 tests
- `setPassword()` - 2 tests

### SystemSettingServiceImpl: ~10 tests
- `getAll()` - 2 tests
- `getById()` - 2 tests
- `getByKey()` - 2 tests
- `create()` - 2 tests
- `update()` - 2 tests
- `delete()` - 2 tests

### NotificationServiceImpl: ~12 tests
- `getUserNotifications()` - 3 tests
- `getPendingApprovals()` - 2 tests
- `approveRequest()` - 2 tests
- `rejectRequest()` - 2 tests
- `deleteNotification()` - 2 tests
- `getDashboard()` - 2 tests

### PaymentService: ~6 tests
- `generateQRCode()` - 3 tests
- `createDeposit()` - 3 tests

### DepositService: ~8 tests
- `createDeposit()` - 2 tests
- `getDepositsByBooking()` - 2 tests
- `getTotalDepositPaid()` - 2 tests
- `cancelDeposit()` - 2 tests

**TỔNG CỘNG: ~150 test cases cần viết**

---

## Ưu tiên Thực hiện

### Tuần 1-2: Critical Business Logic
- [x] BookingServiceImpl.create() - Done
- [x] BookingServiceImpl.update() - Done
- [ ] DispatchServiceImpl.assign() - Next
- [ ] DriverServiceImpl.startTrip()
- [ ] DriverServiceImpl.completeTrip()

### Tuần 3-4: Data Retrieval
- [ ] BookingServiceImpl.getAll()
- [ ] DriverServiceImpl.getProfile() / getSchedule()
- [ ] VehicleServiceImpl.getById() / getAll()
- [ ] InvoiceServiceImpl.createInvoice()
- [ ] InvoiceServiceImpl.getInvoices()

### Tuần 5-6: Supporting Functions
- [ ] BookingServiceImpl.addPayment()
- [ ] InvoiceServiceImpl.recordPayment()
- [ ] PaymentService.generateQRCode()
- [ ] DispatchServiceImpl.unassign() / reassign()

### Tuần 7-8: Authentication & Utilities
- [ ] AuthenticationServiceImpl.getAccessToken()
- [ ] CustomerService.findOrCreateCustomer()
- [ ] EmployeeServiceImpl.createEmployee()
- [ ] SystemSettingServiceImpl.getAll() / update()

