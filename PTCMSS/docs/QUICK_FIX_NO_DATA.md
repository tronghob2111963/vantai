# Quick Fix: Không có dữ liệu hiển thị

## Vấn đề
Backend log: "Found 0 pending approvals" cho branch 3

## Nguyên nhân
Không có dữ liệu trong bảng `ApprovalHistory` cho branch 3

## Giải pháp nhanh

### Bước 1: Kiểm tra dữ liệu
```sql
-- Kiểm tra approval_history
SELECT * FROM ApprovalHistory WHERE branchId = 3 AND status = 'PENDING';

-- Nếu trống, kiểm tra DriverDayOff
SELECT d.*, dr.branchId 
FROM DriverDayOff d 
JOIN Drivers dr ON d.driverId = dr.driverId 
WHERE dr.branchId = 3 AND d.status = 'Pending';

-- Kiểm tra ExpenseRequests
SELECT * FROM ExpenseRequests WHERE branchId = 3 AND status = 'PENDING';
```

### Bước 2: Tạo dữ liệu test trực tiếp
```bash
mysql -u root -p ptcmss_db < PTCMSS/db_scripts/11_INSERT_APPROVAL_HISTORY_DIRECT.sql
```

Script này sẽ:
1. Tạo DriverDayOff cho branch 3
2. Tạo ApprovalHistory tương ứng
3. Tạo ExpenseRequests cho branch 3
4. Tạo ApprovalHistory tương ứng

### Bước 3: Reload frontend
1. Vào `/dispatch/notifications`
2. Click "Làm mới"
3. Xem "Chờ duyệt" section

## Nếu vẫn không có dữ liệu

### Kiểm tra branch ID
```sql
-- Xem user manager_hcm thuộc branch nào
SELECT 
    u.userId,
    u.username,
    u.fullName,
    e.branchId,
    b.branchName
FROM Users u
JOIN Employees e ON u.userId = e.userId
JOIN Branches b ON e.branchId = b.branchId
WHERE u.username = 'manager_hcm';
```

Nếu manager_hcm thuộc branch khác (không phải 3), thì:

**Option 1**: Tạo dữ liệu cho đúng branch
```sql
-- Thay 3 bằng branchId thực tế
INSERT INTO ApprovalHistory (...)
VALUES (..., YOUR_BRANCH_ID);
```

**Option 2**: Đăng nhập với Admin để xem tất cả chi nhánh

### Kiểm tra tên bảng
```sql
-- Xem tất cả bảng
SHOW TABLES LIKE '%approval%';
SHOW TABLES LIKE '%day%';
SHOW TABLES LIKE '%expense%';
```

Nếu tên bảng khác (ví dụ: `approval_history` thay vì `ApprovalHistory`), cần sửa entity mapping trong Java.

## Test với Admin

1. Đăng nhập với tài khoản Admin
2. Vào `/dispatch/notifications`
3. Click dropdown chọn chi nhánh
4. Chọn "Tất cả chi nhánh"
5. Xem có dữ liệu không

Nếu Admin thấy dữ liệu nhưng Manager không thấy → Vấn đề là branch filter

## Manual Insert cho testing

```sql
-- Insert trực tiếp ApprovalHistory (thay YOUR_BRANCH_ID và YOUR_USER_ID)
INSERT INTO ApprovalHistory (
    approvalType,
    relatedEntityId,
    status,
    requestedBy,
    requestReason,
    requestedAt,
    branchId
) VALUES (
    'DRIVER_DAY_OFF',
    1,  -- ID của DriverDayOff (tạo trước)
    'PENDING',
    1,  -- YOUR_USER_ID
    'Test nghỉ phép',
    NOW(),
    3   -- YOUR_BRANCH_ID
);
```

## Verify

Sau khi insert, kiểm tra:

```sql
-- 1. Có dữ liệu trong ApprovalHistory
SELECT COUNT(*) FROM ApprovalHistory WHERE status = 'PENDING';

-- 2. Có dữ liệu cho branch cụ thể
SELECT COUNT(*) FROM ApprovalHistory WHERE branchId = 3 AND status = 'PENDING';

-- 3. Chi tiết
SELECT 
    ah.*,
    u.fullName as requestedByName
FROM ApprovalHistory ah
JOIN Users u ON ah.requestedBy = u.userId
WHERE ah.status = 'PENDING'
ORDER BY ah.requestedAt DESC;
```

## Restart Backend

Nếu đã có dữ liệu nhưng vẫn không hiển thị:
1. Restart backend
2. Clear browser cache
3. Hard reload (Ctrl+Shift+R)

## Debug Frontend

Mở Console (F12) và xem:
```
[NotificationsWidget] Dashboard data: {...}
[NotificationsWidget] Pending approvals: X
```

Nếu X = 0 nhưng backend có data → Vấn đề ở frontend parsing
Nếu X > 0 nhưng UI không hiển thị → Vấn đề ở rendering
