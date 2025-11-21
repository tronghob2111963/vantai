# Chức năng Notifications & Approvals (Cảnh báo & Chờ duyệt)

## Tổng quan

Hệ thống cảnh báo và phê duyệt tự động giúp quản lý:
- **Cảnh báo (Alerts)**: Xe sắp hết đăng kiểm, bằng lái hết hạn, xung đột lịch, vượt giới hạn giờ lái
- **Chờ duyệt (Approvals)**: Nghỉ phép tài xế, yêu cầu tạm ứng, giảm giá, thay đổi lịch trình

## Tính năng chính

### 1. System Alerts (Cảnh báo hệ thống)

#### Các loại cảnh báo
- **VEHICLE_INSPECTION_EXPIRING**: Xe sắp hết hạn đăng kiểm
- **VEHICLE_INSURANCE_EXPIRING**: Bảo hiểm xe sắp hết hạn
- **DRIVER_LICENSE_EXPIRING**: Bằng lái sắp hết hạn
- **DRIVER_HEALTH_CHECK_DUE**: Sắp đến hạn khám sức khỏe
- **SCHEDULE_CONFLICT**: Xung đột lịch trình
- **DRIVING_HOURS_EXCEEDED**: Vượt giới hạn giờ lái
- **VEHICLE_MAINTENANCE_DUE**: Sắp đến hạn bảo dưỡng
- **DRIVER_REST_REQUIRED**: Tài xế cần nghỉ ngơi

#### Mức độ nghiêm trọng (Severity)
- **CRITICAL**: Khẩn cấp, cần xử lý ngay (đã hết hạn hoặc < 7 ngày)
- **HIGH**: Quan trọng, cần xử lý sớm (< 7 ngày)
- **MEDIUM**: Cần chú ý (< 30 ngày)
- **LOW**: Thông tin, không cần xử lý gấp

#### Tự động tạo cảnh báo
Hệ thống tự động chạy mỗi ngày lúc 6h sáng để:
1. Quét tất cả xe và tài xế
2. Kiểm tra ngày hết hạn
3. Tạo cảnh báo nếu cần
4. Xóa cảnh báo đã hết hiệu lực

### 2. Approval System (Hệ thống phê duyệt)

#### Các loại yêu cầu
- **DRIVER_DAY_OFF**: Nghỉ phép tài xế
- **EXPENSE_REQUEST**: Yêu cầu tạm ứng
- **DISCOUNT_REQUEST**: Yêu cầu giảm giá
- **SCHEDULE_CHANGE**: Thay đổi lịch trình
- **OVERTIME_REQUEST**: Yêu cầu làm thêm giờ
- **VEHICLE_REPAIR**: Yêu cầu sửa chữa xe

#### Trạng thái
- **PENDING**: Chờ duyệt
- **APPROVED**: Đã duyệt
- **REJECTED**: Từ chối
- **CANCELLED**: Đã hủy

#### Quy trình phê duyệt
1. Người yêu cầu tạo request (driver, consultant, etc.)
2. Hệ thống tạo ApprovalHistory với status PENDING
3. Manager/Admin xem và xử lý
4. Approve/Reject với ghi chú
5. Cập nhật entity liên quan (DriverDayOff, ExpenseRequest, etc.)
6. Lưu lịch sử: người xử lý, thời điểm, lý do

## Database Schema

### Bảng `system_alerts`
```sql
CREATE TABLE system_alerts (
    alertId INT AUTO_INCREMENT PRIMARY KEY,
    alertType VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    title VARCHAR(200),
    message VARCHAR(1000),
    relatedEntityType VARCHAR(50),
    relatedEntityId INT,
    branchId INT,
    isAcknowledged BOOLEAN DEFAULT FALSE,
    acknowledgedBy INT,
    acknowledgedAt TIMESTAMP NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiresAt TIMESTAMP NULL,
    FOREIGN KEY (branchId) REFERENCES branches(branchId),
    FOREIGN KEY (acknowledgedBy) REFERENCES users(userId)
);
```

### Bảng `approval_history`
```sql
CREATE TABLE approval_history (
    historyId INT AUTO_INCREMENT PRIMARY KEY,
    approvalType VARCHAR(50) NOT NULL,
    relatedEntityId INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    requestedBy INT NOT NULL,
    approvedBy INT,
    requestReason VARCHAR(500),
    approvalNote VARCHAR(500),
    requestedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processedAt TIMESTAMP NULL,
    branchId INT,
    FOREIGN KEY (requestedBy) REFERENCES users(userId),
    FOREIGN KEY (approvedBy) REFERENCES users(userId),
    FOREIGN KEY (branchId) REFERENCES branches(branchId)
);
```

## API Endpoints

### Dashboard
```http
GET /api/notifications/dashboard?branchId={branchId}
Authorization: Bearer <token>
```

**Response**:
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "alerts": [...],
    "pendingApprovals": [...],
    "stats": {
      "totalAlerts": 5,
      "criticalAlerts": 2,
      "highAlerts": 1,
      "totalPendingApprovals": 3,
      "driverDayOffRequests": 2,
      "expenseRequests": 1,
      "discountRequests": 0
    }
  }
}
```

### Lấy danh sách cảnh báo
```http
GET /api/notifications/alerts?branchId={branchId}
Authorization: Bearer <token>
```

### Xác nhận cảnh báo
```http
POST /api/notifications/alerts/{alertId}/acknowledge
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": 1
}
```

### Lấy yêu cầu chờ duyệt
```http
GET /api/notifications/approvals/pending?branchId={branchId}
Authorization: Bearer <token>
```

### Phê duyệt yêu cầu
```http
POST /api/notifications/approvals/{historyId}/approve
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": 1,
  "note": "Đã xem xét và đồng ý"
}
```

### Từ chối yêu cầu
```http
POST /api/notifications/approvals/{historyId}/reject
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": 1,
  "note": "Không đủ điều kiện"
}
```

### Tạo cảnh báo (manual trigger)
```http
POST /api/notifications/alerts/generate
Authorization: Bearer <token>
```

## Frontend Components

### NotificationsDashboard
Component chính hiển thị dashboard với:
- **Stats Cards**: Tổng quan số liệu
- **Alerts List**: Danh sách cảnh báo với nút "Xác nhận"
- **Approvals List**: Danh sách yêu cầu với nút "Duyệt" / "Từ chối"

**Props**: Không có (tự load data)

**Location**: `/dispatch/notifications-dashboard`

**Permissions**: ADMIN, MANAGER, COORDINATOR

### Cách sử dụng
```jsx
import NotificationsDashboard from "./components/module 5/NotificationsDashboard";

// Trong route
<Route path="/dispatch/notifications-dashboard" element={<NotificationsDashboard />} />
```

## Quy tắc cảnh báo

### Thời gian cảnh báo
- **30 ngày trước**: Cảnh báo MEDIUM
- **7 ngày trước**: Cảnh báo HIGH
- **Đã hết hạn**: Cảnh báo CRITICAL

### Logic tạo cảnh báo

#### Xe sắp hết đăng kiểm
```java
if (vehicle.inspectionExpiry < today) {
    severity = CRITICAL;
} else if (vehicle.inspectionExpiry < today + 7 days) {
    severity = HIGH;
} else if (vehicle.inspectionExpiry < today + 30 days) {
    severity = MEDIUM;
}
```

#### Bằng lái sắp hết hạn
```java
if (driver.licenseExpiry < today) {
    severity = CRITICAL;
} else if (driver.licenseExpiry < today + 7 days) {
    severity = HIGH;
} else if (driver.licenseExpiry < today + 30 days) {
    severity = MEDIUM;
}
```

## Scheduled Jobs

### Tự động tạo cảnh báo
```java
@Scheduled(cron = "0 0 6 * * *") // Mỗi ngày lúc 6h sáng
public void generateSystemAlerts() {
    generateVehicleInspectionAlerts();
    generateVehicleInsuranceAlerts();
    generateDriverLicenseAlerts();
    generateDriverHealthCheckAlerts();
    alertsRepository.deleteExpiredAlerts(Instant.now());
}
```

### Cấu hình
Trong `application.properties`:
```properties
# Enable scheduling
spring.task.scheduling.enabled=true

# Cron expression (có thể thay đổi)
notification.alert.cron=0 0 6 * * *

# Số ngày cảnh báo trước
notification.warning.days=30
notification.critical.days=7
```

## Phân quyền

### Xem cảnh báo
- **ADMIN**: Xem tất cả chi nhánh
- **MANAGER**: Xem chi nhánh mình quản lý
- **COORDINATOR**: Xem chi nhánh mình thuộc về

### Xác nhận cảnh báo
- **ADMIN, MANAGER, COORDINATOR**: Có thể acknowledge

### Phê duyệt yêu cầu
- **ADMIN**: Duyệt tất cả
- **MANAGER**: Duyệt trong chi nhánh mình quản lý
- **COORDINATOR**: Chỉ xem, không duyệt

## Workflow Examples

### Workflow 1: Nghỉ phép tài xế
1. Tài xế tạo yêu cầu nghỉ phép (DriverDayOff với status PENDING)
2. Hệ thống tự động tạo ApprovalHistory
3. Manager vào dashboard, xem yêu cầu
4. Manager approve/reject
5. Hệ thống cập nhật DriverDayOff.status = APPROVED/REJECTED
6. Lưu ApprovalHistory với người duyệt và thời điểm

### Workflow 2: Xe sắp hết đăng kiểm
1. Scheduled job chạy mỗi ngày 6h sáng
2. Quét tất cả xe, tìm xe có inspectionExpiry < 30 ngày
3. Tạo SystemAlert với severity phù hợp
4. Manager vào dashboard, thấy cảnh báo
5. Manager xử lý (đưa xe đi đăng kiểm)
6. Manager click "Xác nhận" để đánh dấu đã biết
7. Alert.isAcknowledged = true

## Testing

### Test cảnh báo tự động
```bash
# Trigger manual
curl -X POST http://localhost:8080/api/notifications/alerts/generate \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test approve/reject
```bash
# Approve
curl -X POST http://localhost:8080/api/notifications/approvals/1/approve \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "note": "OK"}'

# Reject
curl -X POST http://localhost:8080/api/notifications/approvals/1/reject \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "note": "Không đủ điều kiện"}'
```

## Troubleshooting

### Không có cảnh báo
- Kiểm tra scheduled job có chạy không
- Kiểm tra dữ liệu xe/tài xế có ngày hết hạn không
- Xem log: `[Notification] Generating system alerts...`

### Không approve được
- Kiểm tra quyền: chỉ ADMIN/MANAGER
- Kiểm tra status: phải là PENDING
- Xem log error trong console

### Cảnh báo trùng lặp
- Hệ thống tự động kiểm tra trùng lặp
- Chỉ tạo alert mới nếu chưa có alert tương tự chưa acknowledge

## Roadmap

### Phase 1 (Hiện tại) ✅
- [x] System alerts tự động
- [x] Approval workflow cơ bản
- [x] Dashboard UI
- [x] Acknowledge alerts
- [x] Approve/Reject requests

### Phase 2 (Sắp tới)
- [ ] Email notifications
- [ ] SMS alerts cho cảnh báo CRITICAL
- [ ] Push notifications (mobile app)
- [ ] Alert rules configuration
- [ ] Approval delegation (ủy quyền)

### Phase 3 (Tương lai)
- [ ] Machine learning để dự đoán cảnh báo
- [ ] Analytics dashboard
- [ ] Custom alert rules
- [ ] Workflow automation
- [ ] Integration với calendar
