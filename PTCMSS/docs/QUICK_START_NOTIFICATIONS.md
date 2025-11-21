# Quick Start: Notifications & Approvals

## Setup

### 1. Chạy Database Migration
```bash
mysql -u root -p your_database < PTCMSS/db_scripts/08_CREATE_NOTIFICATIONS_TABLES.sql
```

### 2. Restart Backend
```bash
cd PTCMSS/ptcmss-backend
mvn spring-boot:run
```

### 3. Truy cập Frontend
```
http://localhost:5173/dispatch/notifications-dashboard
```

## Tự động tạo cảnh báo

### Scheduled Job (Tự động mỗi ngày 6h sáng)
```java
@Scheduled(cron = "0 0 6 * * *")
public void generateSystemAlerts() {
    // Tự động quét và tạo cảnh báo
}
```

### Manual Trigger (Test)
```bash
curl -X POST http://localhost:8080/api/notifications/alerts/generate \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Tạo yêu cầu phê duyệt

### Ví dụ: Nghỉ phép tài xế
```java
// 1. Tạo DriverDayOff
DriverDayOff dayOff = new DriverDayOff();
dayOff.setDriver(driver);
dayOff.setStartDate(LocalDate.of(2025, 12, 1));
dayOff.setEndDate(LocalDate.of(2025, 12, 3));
dayOff.setReason("Nghỉ phép năm");
dayOff.setStatus(DriverDayOffStatus.Pending);
driverDayOffRepository.save(dayOff);

// 2. Tạo ApprovalHistory
approvalService.createApprovalRequest(
    ApprovalType.DRIVER_DAY_OFF,
    dayOff.getId(),
    currentUser,
    "Nghỉ phép năm",
    driver.getBranch()
);
```

### Ví dụ: Yêu cầu tạm ứng
```java
// 1. Tạo ExpenseRequest
ExpenseRequests expense = new ExpenseRequests();
expense.setRequester(currentUser);
expense.setType("Nhiên liệu");
expense.setAmount(new BigDecimal("500000"));
expense.setNote("Tạm ứng tiền xăng");
expense.setStatus(ExpenseRequestStatus.PENDING);
expenseRequestRepository.save(expense);

// 2. Tạo ApprovalHistory
approvalService.createApprovalRequest(
    ApprovalType.EXPENSE_REQUEST,
    expense.getId(),
    currentUser,
    "Tạm ứng tiền xăng",
    currentUser.getBranch()
);
```

## API Examples

### Lấy dashboard
```bash
curl -X GET "http://localhost:8080/api/notifications/dashboard?branchId=1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Xác nhận cảnh báo
```bash
curl -X POST "http://localhost:8080/api/notifications/alerts/1/acknowledge" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"userId": 1}'
```

### Phê duyệt yêu cầu
```bash
curl -X POST "http://localhost:8080/api/notifications/approvals/1/approve" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "note": "Đã xem xét và đồng ý"}'
```

### Từ chối yêu cầu
```bash
curl -X POST "http://localhost:8080/api/notifications/approvals/1/reject" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "note": "Không đủ điều kiện"}'
```

## Cấu hình

### Thay đổi thời gian chạy scheduled job
Trong `application.properties`:
```properties
# Mặc định: 6h sáng mỗi ngày
notification.alert.cron=0 0 6 * * *

# Ví dụ khác:
# Mỗi giờ: 0 0 * * * *
# Mỗi 30 phút: 0 */30 * * * *
# 8h sáng: 0 0 8 * * *
```

### Thay đổi số ngày cảnh báo trước
Trong `NotificationServiceImpl.java`:
```java
private static final int EXPIRY_WARNING_DAYS = 30; // Cảnh báo trước 30 ngày
private static final int CRITICAL_WARNING_DAYS = 7; // Khẩn cấp trước 7 ngày
```

## Troubleshooting

### Không có cảnh báo
1. Kiểm tra scheduled job có chạy không:
   ```
   [Notification] Generating system alerts...
   ```
2. Kiểm tra dữ liệu:
   - Xe có `inspectionExpiry` không?
   - Tài xế có `licenseExpiry` không?
3. Trigger manual để test:
   ```bash
   POST /api/notifications/alerts/generate
   ```

### Không approve được
1. Kiểm tra quyền: Chỉ ADMIN/MANAGER
2. Kiểm tra status: Phải là PENDING
3. Xem log error trong console

### Cảnh báo trùng lặp
- Hệ thống tự động kiểm tra trùng lặp
- Chỉ tạo alert mới nếu chưa có alert tương tự chưa acknowledge

## Testing Checklist

- [ ] Tạo xe với inspectionExpiry < 30 ngày
- [ ] Chạy generate alerts
- [ ] Xem cảnh báo trong dashboard
- [ ] Click "Xác nhận" cảnh báo
- [ ] Tạo yêu cầu nghỉ phép
- [ ] Xem trong dashboard
- [ ] Approve/Reject yêu cầu
- [ ] Kiểm tra status đã cập nhật

## Xem thêm
- [Tài liệu đầy đủ](./notifications-approvals-feature.md)
- [API Documentation](../ptcmss-backend/README.md)
