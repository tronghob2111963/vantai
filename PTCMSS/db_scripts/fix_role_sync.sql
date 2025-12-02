-- Script để đồng bộ roleId giữa bảng users và employees
-- Chạy script này để fix dữ liệu hiện tại

USE ptcmss_db;

-- Cập nhật roleId của employees để khớp với users
UPDATE employees e
INNER JOIN users u ON e.userId = u.userId
SET e.roleId = u.roleId
WHERE e.roleId != u.roleId;

-- Kiểm tra kết quả
SELECT 
    u.userId,
    u.username,
    u.roleId AS user_roleId,
    ur.roleName AS user_roleName,
    e.employeeId,
    e.roleId AS employee_roleId,
    er.roleName AS employee_roleName,
    CASE 
        WHEN u.roleId = e.roleId THEN 'OK'
        ELSE 'MISMATCH'
    END AS status
FROM users u
LEFT JOIN employees e ON u.userId = e.userId
LEFT JOIN roles ur ON u.roleId = ur.roleId
LEFT JOIN roles er ON e.roleId = er.roleId
ORDER BY u.userId;
