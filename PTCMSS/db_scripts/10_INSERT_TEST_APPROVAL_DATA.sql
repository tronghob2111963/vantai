-- Script tạo dữ liệu test cho approval

-- 1. Tạo đơn nghỉ phép PENDING (nếu chưa có)
-- Giả sử có driver với ID = 1, branch = 1
INSERT INTO DriverDayOff (driverId, startDate, endDate, reason, status, createdAt)
SELECT 
    d.driverId,
    DATE_ADD(CURDATE(), INTERVAL 7 DAY) as startDate,
    DATE_ADD(CURDATE(), INTERVAL 9 DAY) as endDate,
    'Nghỉ phép năm' as reason,
    'Pending' as status,
    NOW() as createdAt
FROM Drivers d
WHERE d.driverId = 1
AND NOT EXISTS (
    SELECT 1 FROM DriverDayOff 
    WHERE driverId = 1 
    AND status = 'Pending'
    AND startDate = DATE_ADD(CURDATE(), INTERVAL 7 DAY)
)
LIMIT 1;

-- 2. Tạo thêm đơn nghỉ phép cho driver khác (nếu có)
INSERT INTO DriverDayOff (driverId, startDate, endDate, reason, status, createdAt)
SELECT 
    d.driverId,
    DATE_ADD(CURDATE(), INTERVAL 5 DAY) as startDate,
    DATE_ADD(CURDATE(), INTERVAL 6 DAY) as endDate,
    'Việc gia đình' as reason,
    'Pending' as status,
    NOW() as createdAt
FROM Drivers d
WHERE d.driverId > 1
AND NOT EXISTS (
    SELECT 1 FROM DriverDayOff 
    WHERE driverId = d.driverId 
    AND status = 'Pending'
)
LIMIT 1;

-- 3. Tạo phiếu tạm ứng PENDING
-- Giả sử có user với ID = 1, branch = 1
INSERT INTO ExpenseRequests (branchId, requesterId, expenseType, amount, note, status, createdAt, updatedAt)
SELECT 
    1 as branchId,
    u.userId as requesterId,
    'Nhiên liệu' as expenseType,
    500000 as amount,
    'Tạm ứng tiền xăng tháng 11' as note,
    'PENDING' as status,
    NOW() as createdAt,
    NOW() as updatedAt
FROM Users u
WHERE u.userId = 1
AND NOT EXISTS (
    SELECT 1 FROM ExpenseRequests 
    WHERE requesterId = 1 
    AND status = 'PENDING'
    AND expenseType = 'Nhiên liệu'
)
LIMIT 1;

-- 4. Tạo thêm phiếu tạm ứng khác
INSERT INTO ExpenseRequests (branchId, requesterId, expenseType, amount, note, status, createdAt, updatedAt)
SELECT 
    b.branchId,
    u.userId as requesterId,
    'Bảo dưỡng' as expenseType,
    300000 as amount,
    'Chi phí bảo dưỡng xe định kỳ' as note,
    'PENDING' as status,
    NOW() as createdAt,
    NOW() as updatedAt
FROM Users u
CROSS JOIN Branches b
WHERE u.userId > 1
AND b.branchId = 1
AND NOT EXISTS (
    SELECT 1 FROM ExpenseRequests 
    WHERE requesterId = u.userId 
    AND status = 'PENDING'
    AND expenseType = 'Bảo dưỡng'
)
LIMIT 1;

-- 5. Kiểm tra kết quả
SELECT 'DriverDayOff PENDING' as type, COUNT(*) as count FROM DriverDayOff WHERE status = 'Pending'
UNION ALL
SELECT 'ExpenseRequests PENDING' as type, COUNT(*) as count FROM ExpenseRequests WHERE status = 'PENDING';

-- 6. Hiển thị dữ liệu vừa tạo
SELECT 
    'DriverDayOff' as type,
    d.dayOffId as id,
    dr.branchId,
    b.branchName,
    CONCAT('Driver #', d.driverId) as requester,
    d.reason as description,
    d.createdAt
FROM DriverDayOff d
JOIN Drivers dr ON d.driverId = dr.driverId
JOIN Branches b ON dr.branchId = b.branchId
WHERE d.status = 'Pending'

UNION ALL

SELECT 
    'ExpenseRequest' as type,
    e.expenseRequestId as id,
    e.branchId,
    b.branchName,
    u.fullName as requester,
    CONCAT(e.expenseType, ' - ', FORMAT(e.amount, 0), ' VNĐ') as description,
    e.createdAt
FROM ExpenseRequests e
JOIN Branches b ON e.branchId = b.branchId
JOIN Users u ON e.requesterId = u.userId
WHERE e.status = 'PENDING'

ORDER BY createdAt DESC;

COMMIT;
