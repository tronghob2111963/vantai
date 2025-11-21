-- Script insert trực tiếp vào ApprovalHistory để test

-- 1. Tạo đơn nghỉ phép cho branch 3
INSERT INTO DriverDayOff (driverId, startDate, endDate, reason, status, createdAt)
SELECT 
    d.driverId,
    DATE_ADD(CURDATE(), INTERVAL 7 DAY),
    DATE_ADD(CURDATE(), INTERVAL 9 DAY),
    'Nghỉ phép test',
    'Pending',
    NOW()
FROM Drivers d
WHERE d.branchId = 3
LIMIT 1;

-- Lấy ID vừa tạo
SET @dayOffId = LAST_INSERT_ID();

-- 2. Tạo ApprovalHistory cho đơn nghỉ phép
INSERT INTO ApprovalHistory (
    approvalType,
    relatedEntityId,
    status,
    requestedBy,
    requestReason,
    requestedAt,
    branchId
)
SELECT 
    'DRIVER_DAY_OFF',
    @dayOffId,
    'PENDING',
    e.userId,
    'Nghỉ phép test',
    NOW(),
    3
FROM Drivers d
JOIN Employees e ON d.employeeId = e.employeeId
WHERE d.branchId = 3
LIMIT 1;

-- 3. Tạo phiếu tạm ứng cho branch 3
INSERT INTO ExpenseRequests (
    branchId,
    requesterId,
    expenseType,
    amount,
    note,
    status,
    createdAt,
    updatedAt
)
SELECT 
    3,
    u.userId,
    'Test expense',
    100000,
    'Test tạm ứng',
    'PENDING',
    NOW(),
    NOW()
FROM Users u
JOIN Employees e ON u.userId = e.userId
WHERE e.branchId = 3
LIMIT 1;

-- Lấy ID vừa tạo
SET @expenseId = LAST_INSERT_ID();

-- 4. Tạo ApprovalHistory cho phiếu tạm ứng
INSERT INTO ApprovalHistory (
    approvalType,
    relatedEntityId,
    status,
    requestedBy,
    requestReason,
    requestedAt,
    branchId
)
SELECT 
    'EXPENSE_REQUEST',
    @expenseId,
    'PENDING',
    u.userId,
    'Yêu cầu tạm ứng test',
    NOW(),
    3
FROM Users u
JOIN Employees e ON u.userId = e.userId
WHERE e.branchId = 3
LIMIT 1;

-- 5. Kiểm tra kết quả
SELECT 
    'ApprovalHistory for branch 3' as info,
    COUNT(*) as count
FROM ApprovalHistory
WHERE branchId = 3 AND status = 'PENDING';

-- 6. Hiển thị chi tiết
SELECT 
    ah.historyId,
    ah.approvalType,
    ah.relatedEntityId,
    ah.status,
    u.fullName as requestedByName,
    ah.requestReason,
    ah.branchId,
    ah.requestedAt
FROM ApprovalHistory ah
JOIN Users u ON ah.requestedBy = u.userId
WHERE ah.branchId = 3 AND ah.status = 'PENDING'
ORDER BY ah.requestedAt DESC;

COMMIT;
