# Unit Test Plan - PTCMSS

## Trạng thái hiện tại

### ✅ Đã có test:
- `BookingServiceImplTest` - Test booking creation, availability check
- `DispatchServiceImplTest` - Test trip assignment
- `DriverServiceImplTest` - Test driver management
- `VehicleServiceImplTest` - Test vehicle management
- `BookingVehicleDetailsRepositoryTest` - Test repository queries

### 📋 Cần viết test (theo độ ưu tiên):

#### 🔴 Critical Priority (Business Logic Core)
1. **ExpenseRequestServiceImpl**
   - `createRequest()` - Tạo yêu cầu chi phí
   - `approveRequest()` - Duyệt yêu cầu, update notification
   - `rejectRequest()` - Từ chối yêu cầu
   - `listByRequester()` - Lấy danh sách theo người yêu cầu

2. **InvoiceServiceImpl**
   - `createInvoice()` - Tạo hóa đơn
   - `updateInvoice()` - Cập nhật hóa đơn
   - `cancelInvoice()` - Hủy hóa đơn
   - `recordPayment()` - Ghi nhận thanh toán

3. **PaymentServiceImpl**
   - `recordPayment()` - Ghi nhận thanh toán
   - `confirmPayment()` - Xác nhận thanh toán
   - `refundPayment()` - Hoàn tiền

4. **IncidentController/Service**
   - `reportIncident()` - Báo cáo sự cố
   - `resolveIncident()` - Xử lý sự cố
   - `listByDriver()` - Lấy danh sách theo tài xế

#### 🟡 High Priority (User Management)
5. **EmployeeServiceImpl**
   - `createEmployee()` - Tạo nhân viên
   - `updateEmployee()` - Cập nhật nhân viên
   - `getEmployeeByUserId()` - Lấy theo userId

6. **CustomerServiceImpl**
   - `createCustomer()` - Tạo khách hàng
   - `updateCustomer()` - Cập nhật khách hàng
   - `searchCustomers()` - Tìm kiếm khách hàng

7. **AuthenticationServiceImpl**
   - `login()` - Đăng nhập
   - `register()` - Đăng ký
   - `refreshToken()` - Làm mới token

#### 🟢 Medium Priority (Supporting Services)
8. **NotificationServiceImpl**
   - `sendNotification()` - Gửi thông báo
   - `markAsRead()` - Đánh dấu đã đọc
   - `getUnreadCount()` - Đếm chưa đọc

9. **SystemSettingServiceImpl**
   - `getSetting()` - Lấy cài đặt
   - `updateSetting()` - Cập nhật cài đặt
   - `getAllSettings()` - Lấy tất cả cài đặt

10. **AnalyticsService**
    - `getVehicleEfficiency()` - Hiệu quả xe
    - `getRevenueStats()` - Thống kê doanh thu
    - `getBookingStats()` - Thống kê đơn hàng

11. **DepositServiceImpl**
    - `calculateDeposit()` - Tính tiền cọc
    - `processRefund()` - Xử lý hoàn cọc

12. **RatingServiceImpl**
    - `rateDriver()` - Đánh giá tài xế
    - `getDriverRating()` - Lấy điểm đánh giá

## Cấu trúc test

### Backend Test Structure
```
src/test/java/org/example/ptcmssbackend/
├── service/
│   ├── ExpenseRequestServiceImplTest.java
│   ├── InvoiceServiceImplTest.java
│   ├── PaymentServiceImplTest.java
│   ├── EmployeeServiceImplTest.java
│   ├── CustomerServiceImplTest.java
│   ├── AuthenticationServiceImplTest.java
│   ├── NotificationServiceImplTest.java
│   ├── SystemSettingServiceImplTest.java
│   ├── AnalyticsServiceTest.java
│   ├── DepositServiceImplTest.java
│   └── RatingServiceImplTest.java
├── controller/
│   ├── IncidentControllerTest.java
│   ├── ExpenseRequestControllerTest.java
│   └── InvoiceControllerTest.java
└── repository/
    ├── ExpenseRequestRepositoryTest.java
    └── InvoiceRepositoryTest.java
```

## Test Coverage Goals

- **Critical Services**: 80%+ coverage
- **Supporting Services**: 70%+ coverage
- **Controllers**: 60%+ coverage (focus on business logic)
- **Repositories**: 50%+ coverage (focus on custom queries)

## Best Practices

1. **Use Mockito** for mocking dependencies
2. **Use AssertJ** for fluent assertions
3. **Test both success and failure cases**
4. **Test edge cases** (null, empty, boundary values)
5. **Test business rules** (validation, constraints)
6. **Use @ExtendWith(MockitoExtension.class)** for unit tests
7. **Use @SpringBootTest** only for integration tests

## Running Tests

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=ExpenseRequestServiceImplTest

# Run with coverage
mvn test jacoco:report
```

## Next Steps

1. Bắt đầu với **ExpenseRequestServiceImplTest** (critical business logic)
2. Tiếp theo **InvoiceServiceImplTest** và **PaymentServiceImplTest**
3. Sau đó các service về user management
4. Cuối cùng là supporting services

