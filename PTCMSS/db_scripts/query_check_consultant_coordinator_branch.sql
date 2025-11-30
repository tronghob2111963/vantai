-- ============================================
-- QUERY: KIỂM TRA CONSULTANT VÀ COORDINATOR CÓ CÙNG BRANCH KHÔNG
-- ============================================

-- Query 1: Kiểm tra Consultant và Coordinator cùng chi nhánh
SELECT 
    -- Consultant info
    e_cons.employeeId AS 'Consultant Employee ID',
    u_cons.fullName AS 'Consultant Name',
    u_cons.username AS 'Consultant Username',
    e_cons.branchId AS 'Consultant Branch ID',
    br_cons.branchName AS 'Consultant Branch',
    
    -- Coordinator info
    e_coord.employeeId AS 'Coordinator Employee ID',
    u_coord.fullName AS 'Coordinator Name',
    u_coord.username AS 'Coordinator Username',
    e_coord.branchId AS 'Coordinator Branch ID',
    br_coord.branchName AS 'Coordinator Branch',
    
    -- Check
    CASE 
        WHEN e_cons.branchId = e_coord.branchId THEN '✅ CÙNG CHI NHÁNH'
        ELSE '❌ KHÁC CHI NHÁNH'
    END AS 'Kết quả'
    
FROM employees e_cons
JOIN users u_cons ON e_cons.userId = u_cons.userId
JOIN roles r_cons ON e_cons.roleId = r_cons.roleId
JOIN branches br_cons ON e_cons.branchId = br_cons.branchId

CROSS JOIN employees e_coord
JOIN users u_coord ON e_coord.userId = u_coord.userId
JOIN roles r_coord ON e_coord.roleId = r_coord.roleId
JOIN branches br_coord ON e_coord.branchId = br_coord.branchId

WHERE 
    r_cons.roleName = 'Consultant'
    AND r_coord.roleName = 'Manager'  -- Manager có thể làm coordinator
    AND e_cons.status = 'ACTIVE'
    AND e_coord.status = 'ACTIVE'

ORDER BY e_cons.branchId, e_coord.branchId;

-- ============================================
-- Query 2: Kiểm tra đơn hàng và branchId của consultant tạo đơn
-- ============================================
SELECT 
    b.bookingId AS 'Mã đơn',
    b.createdAt AS 'Ngày tạo',
    b.status AS 'Trạng thái',
    
    -- Branch của đơn
    b.branchId AS 'Branch ID (Đơn)',
    br.branchName AS 'Chi nhánh (Đơn)',
    
    -- Consultant tạo đơn
    b.consultantId AS 'Consultant ID',
    e_cons.employeeId AS 'Consultant Employee ID',
    e_cons.branchId AS 'Consultant Branch ID',
    br_cons.branchName AS 'Chi nhánh (Consultant)',
    u_cons.fullName AS 'Tư vấn viên',
    
    -- Check
    CASE 
        WHEN b.branchId = e_cons.branchId THEN '✅ ĐÚNG'
        ELSE '❌ SAI - BranchId không khớp!'
    END AS 'Kiểm tra'
    
FROM bookings b
LEFT JOIN branches br ON b.branchId = br.branchId
LEFT JOIN employees e_cons ON b.consultantId = e_cons.employeeId
LEFT JOIN branches br_cons ON e_cons.branchId = br_cons.branchId
LEFT JOIN users u_cons ON e_cons.userId = u_cons.userId

WHERE b.consultantId IS NOT NULL

ORDER BY b.createdAt DESC
LIMIT 20;

-- ============================================
-- Query 3: Tìm Coordinator có thể thấy đơn của Consultant nào
-- ============================================
SELECT 
    -- Coordinator
    e_coord.employeeId AS 'Coordinator ID',
    u_coord.fullName AS 'Coordinator Name',
    br_coord.branchName AS 'Coordinator Branch',
    
    -- Consultant cùng branch
    COUNT(DISTINCT e_cons.employeeId) AS 'Số Consultant cùng branch',
    GROUP_CONCAT(DISTINCT u_cons.fullName SEPARATOR ', ') AS 'Danh sách Consultant',
    
    -- Đơn hàng có thể thấy
    COUNT(DISTINCT b.bookingId) AS 'Số đơn có thể thấy',
    COUNT(DISTINCT CASE WHEN b.status = 'PENDING' THEN b.bookingId END) AS 'Đơn chờ xử lý'
    
FROM employees e_coord
JOIN users u_coord ON e_coord.userId = u_coord.userId
JOIN roles r_coord ON e_coord.roleId = r_coord.roleId
JOIN branches br_coord ON e_coord.branchId = br_coord.branchId

LEFT JOIN employees e_cons ON e_cons.branchId = e_coord.branchId
JOIN roles r_cons ON e_cons.roleId = r_cons.roleId
JOIN users u_cons ON e_cons.userId = u_cons.userId

LEFT JOIN bookings b ON b.branchId = e_coord.branchId

WHERE 
    r_coord.roleName = 'Manager'  -- Manager có thể làm coordinator
    AND r_cons.roleName = 'Consultant'
    AND e_coord.status = 'ACTIVE'
    AND e_cons.status = 'ACTIVE'

GROUP BY e_coord.employeeId, u_coord.fullName, br_coord.branchName

ORDER BY br_coord.branchName;

-- ============================================
-- Query 4: Kiểm tra đơn bookingId = 14 và Coordinator có thể thấy không
-- ============================================
SELECT 
    -- Đơn hàng
    b.bookingId,
    b.branchId AS 'Branch ID (Đơn)',
    br.branchName AS 'Chi nhánh (Đơn)',
    b.consultantId,
    u_cons.fullName AS 'Consultant',
    e_cons.branchId AS 'Branch ID (Consultant)',
    
    -- Coordinator
    e_coord.employeeId AS 'Coordinator ID',
    u_coord.fullName AS 'Coordinator',
    e_coord.branchId AS 'Branch ID (Coordinator)',
    br_coord.branchName AS 'Chi nhánh (Coordinator)',
    
    -- Check
    CASE 
        WHEN b.branchId = e_coord.branchId THEN '✅ Coordinator CÓ THỂ THẤY đơn này'
        ELSE '❌ Coordinator KHÔNG THỂ THẤY đơn này'
    END AS 'Kết quả'
    
FROM bookings b
LEFT JOIN branches br ON b.branchId = br.branchId  -- FIX: Thêm JOIN với branches
LEFT JOIN employees e_cons ON b.consultantId = e_cons.employeeId
LEFT JOIN users u_cons ON e_cons.userId = u_cons.userId

CROSS JOIN employees e_coord
JOIN users u_coord ON e_coord.userId = u_coord.userId
JOIN roles r_coord ON e_coord.roleId = r_coord.roleId
JOIN branches br_coord ON e_coord.branchId = br_coord.branchId

WHERE 
    b.bookingId = 14
    AND r_coord.roleName = 'Manager'  -- Manager có thể làm coordinator
    AND e_coord.status = 'ACTIVE';

-- ============================================
-- Query 5: Query đơn giản để test nhanh (FIXED)
-- ============================================
SELECT 
    b.bookingId,
    b.branchId AS 'Branch ID (Đơn)',
    br.branchName AS 'Chi nhánh (Đơn)',
    e_cons.branchId AS 'Branch ID (Consultant)',
    e_coord.branchId AS 'Branch ID (Coordinator)',
    CASE 
        WHEN b.branchId = e_coord.branchId THEN '✅ CÓ THỂ THẤY'
        ELSE '❌ KHÔNG THỂ THẤY'
    END AS 'Kết quả'
FROM bookings b
LEFT JOIN branches br ON b.branchId = br.branchId  -- FIX: Thêm JOIN
LEFT JOIN employees e_cons ON b.consultantId = e_cons.employeeId
CROSS JOIN employees e_coord
JOIN roles r_coord ON e_coord.roleId = r_coord.roleId
WHERE b.bookingId = 14
  AND r_coord.roleName = 'Manager';

