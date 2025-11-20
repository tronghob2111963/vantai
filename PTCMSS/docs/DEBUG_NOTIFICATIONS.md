# Debug Guide: Notifications không hiển thị

## Vấn đề
Backend log cho thấy query chạy thành công nhưng Frontend không hiển thị dữ liệu.

## Các bước debug

### 1. Kiểm tra dữ liệu trong database
```bash
mysql -u root -p your_database < PTCMSS/db_scripts/09_CHECK_APPROVAL_DATA.sql
```

Hoặc chạy từng query:
```sql
-- Kiểm tra driver_day_off PENDING
SELECT * FROM driver_day_off WHERE status = 'Pending';

-- Kiểm tra expense_requests PENDING
SELECT * FROM expense_requests WHERE status = 'PENDING';

-- Kiểm tra approval_history
SELECT * FROM approval_history WHERE status = 'PENDING';
```

**Nếu không có dữ liệu**: Chạy script tạo test data
```bash
mysql -u root -p your_database < PTCMSS/db_scripts/10_INSERT_TEST_APPROVAL_DATA.sql
```

### 2. Trigger sync approval history
```bash
curl -X POST http://localhost:8080/api/notifications/approvals/sync \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Hoặc đợi 5 phút để scheduled job chạy tự động.

### 3. Kiểm tra backend logs
Tìm các dòng log:
```
[ApprovalSync] Syncing driver day-off approvals...
[ApprovalSync] Created approval history for day-off X
[ApprovalSync] Synced X driver day-off approvals

[Notification] Get pending approvals for branch X
[Notification] Found X pending approvals
[Notification] Mapped X approval responses
```

**Nếu "Found 0 pending approvals"**: 
- Kiểm tra `approval_history` table có dữ liệu không
- Kiểm tra `branchId` có đúng không

### 4. Kiểm tra API response
Mở DevTools (F12) → Network tab → Tìm request `/api/notifications/dashboard`

**Response mẫu đúng**:
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "alerts": [...],
    "pendingApprovals": [
      {
        "id": 1,
        "approvalType": "DRIVER_DAY_OFF",
        "relatedEntityId": 1,
        "status": "PENDING",
        "requestedBy": 1,
        "requestedByName": "Nguyễn Văn A",
        "requestReason": "Nghỉ phép năm",
        "details": {
          "driverId": 1,
          "driverName": "Tài xế A",
          "startDate": "2025-11-27",
          "endDate": "2025-11-29",
          "reason": "Nghỉ phép năm"
        }
      }
    ],
    "stats": {...}
  }
}
```

**Nếu `pendingApprovals: []`**: Backend không trả về data
- Kiểm tra query trong backend log
- Kiểm tra `branchId` filter

### 5. Kiểm tra Frontend console
Mở DevTools (F12) → Console tab

Tìm logs:
```
[NotificationsWidget] Fetching dashboard with params: ?branchId=3
[NotificationsWidget] Dashboard data: {...}
[NotificationsWidget] Alerts: 0
[NotificationsWidget] Pending approvals: 0
```

**Nếu "Pending approvals: 0"**: 
- Kiểm tra `data.pendingApprovals` có tồn tại không
- Kiểm tra structure của response

### 6. Kiểm tra lazy loading issue
Nếu backend log cho thấy có data nhưng response trống, có thể là lazy loading issue.

**Fix**: Thêm `@Transactional` và eager fetch
```java
@Transactional(readOnly = true)
public List<ApprovalItemResponse> getPendingApprovals(Integer branchId) {
    // ...
}
```

### 7. Test với Postman/curl
```bash
# Lấy dashboard
curl -X GET "http://localhost:8080/api/notifications/dashboard?branchId=1" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Kiểm tra response
```

## Common Issues

### Issue 1: Không có dữ liệu trong database
**Solution**: Chạy script insert test data
```bash
mysql -u root -p your_database < PTCMSS/db_scripts/10_INSERT_TEST_APPROVAL_DATA.sql
```

### Issue 2: ApprovalHistory chưa được tạo
**Solution**: 
1. Đợi 5 phút (scheduled job)
2. Hoặc trigger manual: `POST /api/notifications/approvals/sync`

### Issue 3: Branch filter không đúng
**Solution**: 
- Admin: Chọn đúng chi nhánh trong dropdown
- Manager: Kiểm tra `branchId` của user
- Xem log: `[Notification] Get pending approvals for branch X`

### Issue 4: Lazy loading exception
**Symptoms**: Backend log có data nhưng response trống hoặc error

**Solution**: Thêm `@Transactional` và eager fetch trong repository
```java
@Query("SELECT ah FROM ApprovalHistory ah " +
       "LEFT JOIN FETCH ah.requestedBy " +
       "LEFT JOIN FETCH ah.branch " +
       "WHERE ah.status = :status")
List<ApprovalHistory> findByStatusWithDetails(@Param("status") ApprovalStatus status);
```

### Issue 5: Frontend không parse đúng response
**Symptoms**: Console log cho thấy data nhưng UI không hiển thị

**Solution**: Kiểm tra mapping
```javascript
const alerts = dashboard?.alerts || [];
const pending = dashboard?.pendingApprovals || [];
```

## Quick Test Checklist

- [ ] Database có dữ liệu PENDING
- [ ] ApprovalHistory đã được sync
- [ ] Backend log cho thấy "Found X pending approvals"
- [ ] API response có `pendingApprovals` array
- [ ] Frontend console log cho thấy data
- [ ] UI hiển thị "Chờ duyệt" section
- [ ] Có thể click "Duyệt"/"Từ chối"

## Manual Test Flow

1. **Tạo đơn nghỉ phép**:
   ```sql
   INSERT INTO driver_day_off (driverId, startDate, endDate, reason, status, createdAt)
   VALUES (1, '2025-12-01', '2025-12-03', 'Test', 'Pending', NOW());
   ```

2. **Trigger sync**:
   ```bash
   POST /api/notifications/approvals/sync
   ```

3. **Kiểm tra approval_history**:
   ```sql
   SELECT * FROM approval_history WHERE status = 'PENDING' ORDER BY requestedAt DESC LIMIT 1;
   ```

4. **Reload frontend**:
   - Vào `/dispatch/notifications`
   - Click "Làm mới"
   - Xem "Chờ duyệt" section

5. **Verify**:
   - Thấy yêu cầu trong danh sách
   - Có nút "Duyệt"/"Từ chối"
   - Click được và hoạt động

## Contact Support

Nếu vẫn không hoạt động sau khi thử tất cả các bước trên:
1. Export backend logs
2. Export database schema và sample data
3. Export frontend console logs
4. Export Network tab (API responses)
