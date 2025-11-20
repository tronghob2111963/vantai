# Hướng dẫn: Tự động Sync Approval History

## Tổng quan

Hệ thống tự động tạo `ApprovalHistory` từ các bản ghi PENDING trong:
- **DriverDayOff** (Đơn xin nghỉ phép)
- **ExpenseRequests** (Phiếu tạm ứng)

## Cách hoạt động

### 1. Scheduled Jobs (Tự động)
Service `ApprovalSyncServiceImpl` chạy mỗi 5 phút để:
1. Quét tất cả `DriverDayOff` với status = PENDING
2. Quét tất cả `ExpenseRequests` với status = PENDING
3. Kiểm tra xem đã có `ApprovalHistory` chưa
4. Nếu chưa có, tạo mới với:
   - `approvalType`: DRIVER_DAY_OFF hoặc EXPENSE_REQUEST
   - `relatedEntityId`: ID của entity
   - `status`: PENDING
   - `requestedBy`: User tạo yêu cầu
   - `requestReason`: Lý do
   - `branch`: Chi nhánh

### 2. Workflow

#### Đơn xin nghỉ phép (DriverDayOff)
```
1. Tài xế tạo đơn nghỉ phép
   DriverDayOff.status = PENDING
   
2. Scheduled job chạy (mỗi 5 phút)
   → Tìm thấy DriverDayOff PENDING
   → Tạo ApprovalHistory
   
3. Manager vào "Thông báo điều phối"
   → Thấy yêu cầu trong "Chờ duyệt"
   → Click "Duyệt" hoặc "Từ chối"
   
4. Hệ thống cập nhật
   → ApprovalHistory.status = APPROVED/REJECTED
   → DriverDayOff.status = Approved/Rejected
```

#### Phiếu tạm ứng (ExpenseRequests)
```
1. User tạo phiếu tạm ứng
   ExpenseRequests.status = PENDING
   
2. Scheduled job chạy (mỗi 5 phút)
   → Tìm thấy ExpenseRequests PENDING
   → Tạo ApprovalHistory
   
3. Manager vào "Thông báo điều phối"
   → Thấy yêu cầu trong "Chờ duyệt"
   → Click "Duyệt" hoặc "Từ chối"
   
4. Hệ thống cập nhật
   → ApprovalHistory.status = APPROVED/REJECTED
   → ExpenseRequests.status = APPROVED/REJECTED
```

## Lọc theo chi nhánh

### Admin
- Có dropdown chọn chi nhánh
- Chọn "Tất cả chi nhánh" để xem tất cả
- Chọn chi nhánh cụ thể để lọc

### Manager/Coordinator
- Tự động lọc theo chi nhánh mình quản lý
- Không có dropdown chọn

## API Endpoints

### Lấy dashboard (có lọc chi nhánh)
```http
GET /api/notifications/dashboard?branchId={branchId}
Authorization: Bearer <token>
```

**Params**:
- `branchId` (optional): ID chi nhánh cần lọc
- Nếu không truyền: Admin xem tất cả, Manager/Coordinator xem chi nhánh mình

### Manual sync (Admin only)
```http
POST /api/notifications/approvals/sync
Authorization: Bearer <token>
```

Trigger thủ công để sync ngay lập tức (không cần đợi 5 phút).

## Cấu hình

### Thay đổi tần suất sync
Trong `ApprovalSyncServiceImpl.java`:
```java
@Scheduled(fixedRate = 300000) // 5 phút = 300000ms
public void syncDriverDayOffApprovals() {
    // ...
}

// Thay đổi:
@Scheduled(fixedRate = 60000)  // 1 phút
@Scheduled(fixedRate = 600000) // 10 phút
```

### Disable auto-sync
Trong `application.properties`:
```properties
# Disable scheduling
spring.task.scheduling.enabled=false
```

## Testing

### 1. Tạo đơn nghỉ phép
```sql
INSERT INTO driver_day_off (driverId, startDate, endDate, reason, status, createdAt)
VALUES (1, '2025-12-01', '2025-12-03', 'Nghỉ phép năm', 'Pending', NOW());
```

### 2. Tạo phiếu tạm ứng
```sql
INSERT INTO expense_requests (branchId, requesterId, expenseType, amount, note, status, createdAt)
VALUES (1, 1, 'Nhiên liệu', 500000, 'Tạm ứng tiền xăng', 'PENDING', NOW());
```

### 3. Đợi 5 phút hoặc trigger manual
```bash
curl -X POST http://localhost:8080/api/notifications/approvals/sync \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 4. Kiểm tra approval_history
```sql
SELECT * FROM approval_history WHERE status = 'PENDING';
```

### 5. Vào frontend
```
http://localhost:5173/dispatch/notifications
```
→ Xem trong "Chờ duyệt"

## Troubleshooting

### Không thấy yêu cầu trong "Chờ duyệt"
1. Kiểm tra scheduled job có chạy không:
   ```
   [ApprovalSync] Syncing driver day-off approvals...
   [ApprovalSync] Synced X driver day-off approvals
   ```
2. Kiểm tra dữ liệu:
   ```sql
   SELECT * FROM driver_day_off WHERE status = 'Pending';
   SELECT * FROM expense_requests WHERE status = 'PENDING';
   ```
3. Trigger manual sync:
   ```bash
   POST /api/notifications/approvals/sync
   ```

### Yêu cầu bị trùng lặp
- Hệ thống tự động kiểm tra trùng lặp
- Chỉ tạo ApprovalHistory mới nếu chưa có PENDING cho entity đó

### Không lọc được theo chi nhánh
1. Kiểm tra `branchId` trong request
2. Kiểm tra `branch` field trong `DriverDayOff` và `ExpenseRequests`
3. Xem log backend

## Database Schema

### approval_history
```sql
CREATE TABLE approval_history (
    historyId INT AUTO_INCREMENT PRIMARY KEY,
    approvalType VARCHAR(50) NOT NULL,  -- 'DRIVER_DAY_OFF', 'EXPENSE_REQUEST'
    relatedEntityId INT NOT NULL,       -- dayOffId hoặc expenseRequestId
    status VARCHAR(20) NOT NULL,        -- 'PENDING', 'APPROVED', 'REJECTED'
    requestedBy INT NOT NULL,
    approvedBy INT,
    requestReason VARCHAR(500),
    approvalNote VARCHAR(500),
    requestedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processedAt TIMESTAMP NULL,
    branchId INT,
    FOREIGN KEY (branchId) REFERENCES branches(branchId)
);
```

## Roadmap

### Phase 1 (Hiện tại) ✅
- [x] Auto-sync DriverDayOff
- [x] Auto-sync ExpenseRequests
- [x] Lọc theo chi nhánh
- [x] Dropdown chọn chi nhánh (Admin)

### Phase 2 (Sắp tới)
- [ ] Sync discount requests
- [ ] Sync schedule changes
- [ ] Email notification khi có yêu cầu mới
- [ ] Dashboard analytics

### Phase 3 (Tương lai)
- [ ] Approval workflow với nhiều cấp
- [ ] Delegation (ủy quyền)
- [ ] Bulk approve/reject
- [ ] Mobile app notifications
