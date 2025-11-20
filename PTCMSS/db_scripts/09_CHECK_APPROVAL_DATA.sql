-- Script kiểm tra dữ liệu approval

-- 1. Kiểm tra DriverDayOff PENDING
SELECT 
    d.dayOffId,
    d.driverId,
    dr.branchId,
    b.branchName,
    d.startDate,
    d.endDate,
    d.reason,
    d.status,
    d.createdAt
FROM DriverDayOff d
JOIN Drivers dr ON d.driverId = dr.driverId
JOIN Branches b ON dr.branchId = b.branchId
WHERE d.status = 'Pending'
ORDER BY d.createdAt DESC;

-- 2. Kiểm tra ExpenseRequests PENDING
SELECT 
    e.expenseRequestId,
    e.branchId,
    b.branchName,
    e.requesterId,
    u.fullName as requesterName,
    e.expenseType,
    e.amount,
    e.note,
    e.status,
    e.createdAt
FROM ExpenseRequests e
JOIN Branches b ON e.branchId = b.branchId
JOIN Users u ON e.requesterId = u.userId
WHERE e.status = 'PENDING'
ORDER BY e.createdAt DESC;

-- 3. Kiểm tra ApprovalHistory
SELECT 
    ah.historyId,
    ah.approvalType,
    ah.relatedEntityId,
    ah.status,
    ah.requestedBy,
    u.fullName as requestedByName,
    ah.branchId,
    b.branchName,
    ah.requestReason,
    ah.requestedAt
FROM ApprovalHistory ah
JOIN Users u ON ah.requestedBy = u.userId
LEFT JOIN Branches b ON ah.branchId = b.branchId
WHERE ah.status = 'PENDING'
ORDER BY ah.requestedAt DESC;

-- 4. Đếm số lượng
SELECT 
    'DriverDayOff PENDING' as type,
    COUNT(*) as count
FROM DriverDayOff
WHERE status = 'Pending'
UNION ALL
SELECT 
    'ExpenseRequests PENDING' as type,
    COUNT(*) as count
FROM ExpenseRequests
WHERE status = 'PENDING'
UNION ALL
SELECT 
    'ApprovalHistory PENDING' as type,
    COUNT(*) as count
FROM ApprovalHistory
WHERE status = 'PENDING';

-- 5. Kiểm tra theo chi nhánh
SELECT 
    b.branchId,
    b.branchName,
    COUNT(DISTINCT d.dayOffId) as dayoff_count,
    COUNT(DISTINCT e.expenseRequestId) as expense_count,
    COUNT(DISTINCT ah.historyId) as approval_count
FROM Branches b
LEFT JOIN Drivers dr ON b.branchId = dr.branchId
LEFT JOIN DriverDayOff d ON dr.driverId = d.driverId AND d.status = 'Pending'
LEFT JOIN ExpenseRequests e ON b.branchId = e.branchId AND e.status = 'PENDING'
LEFT JOIN ApprovalHistory ah ON b.branchId = ah.branchId AND ah.status = 'PENDING'
GROUP BY b.branchId, b.branchName
ORDER BY b.branchId;
