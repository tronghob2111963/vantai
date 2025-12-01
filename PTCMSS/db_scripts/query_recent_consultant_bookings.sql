-- ============================================
-- QUERY: TÌM ĐƠN HÀNG VỪA TẠO BỞI TƯ VẤN VIÊN
-- ============================================

-- Query 1: Tất cả đơn hàng được tạo bởi tư vấn viên (sắp xếp mới nhất trước)
SELECT 
    b.bookingId AS 'Mã đơn',
    b.createdAt AS 'Ngày tạo',
    b.status AS 'Trạng thái',
    b.totalCost AS 'Tổng tiền',
    b.depositAmount AS 'Tiền cọc',
    b.note AS 'Ghi chú',
    
    -- Thông tin tư vấn viên
    u.fullName AS 'Tư vấn viên',
    u.username AS 'Username TVV',
    u.email AS 'Email TVV',
    u.phone AS 'SĐT TVV',
    e.employeeId AS 'Employee ID',
    
    -- Thông tin chi nhánh
    br.branchName AS 'Chi nhánh',
    br.branchId AS 'Branch ID',
    
    -- Thông tin khách hàng
    c.fullName AS 'Khách hàng',
    c.phone AS 'SĐT khách hàng',
    
    -- Thông tin loại thuê
    ht.name AS 'Loại thuê',
    
    -- Thông tin chuyến
    COUNT(DISTINCT t.tripId) AS 'Số chuyến',
    GROUP_CONCAT(DISTINCT CONCAT(t.startLocation, ' → ', t.endLocation) SEPARATOR ' | ') AS 'Các chuyến'
    
FROM bookings b
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
LEFT JOIN roles r ON e.roleId = r.roleId
LEFT JOIN branches br ON b.branchId = br.branchId
LEFT JOIN customers c ON b.customerId = c.customerId
LEFT JOIN hire_types ht ON b.hireTypeId = ht.hireTypeId
LEFT JOIN trips t ON b.bookingId = t.bookingId

WHERE 
    b.consultantId IS NOT NULL  -- Chỉ lấy đơn có tư vấn viên
    AND r.roleName = 'Consultant'  -- Đảm bảo là tư vấn viên
    -- Có thể thêm filter theo thời gian:
    -- AND b.createdAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)  -- 7 ngày gần đây
    -- AND b.createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)  -- 30 ngày gần đây

GROUP BY 
    b.bookingId, b.createdAt, b.status, b.totalCost, b.depositAmount, b.note,
    u.fullName, u.username, u.email, u.phone, e.employeeId,
    br.branchName, br.branchId,
    c.fullName, c.phone,
    ht.name

ORDER BY b.createdAt DESC;

-- ============================================
-- Query 2: Đơn hàng mới nhất (7 ngày gần đây)
-- ============================================
SELECT 
    b.bookingId AS 'Mã đơn',
    DATE_FORMAT(b.createdAt, '%d/%m/%Y %H:%i:%s') AS 'Ngày tạo',
    b.status AS 'Trạng thái',
    FORMAT(b.totalCost, 0) AS 'Tổng tiền (VNĐ)',
    FORMAT(b.depositAmount, 0) AS 'Tiền cọc (VNĐ)',
    u.fullName AS 'Tư vấn viên',
    br.branchName AS 'Chi nhánh',
    c.fullName AS 'Khách hàng',
    c.phone AS 'SĐT khách hàng'
    
FROM bookings b
INNER JOIN employees e ON b.consultantId = e.employeeId
INNER JOIN users u ON e.userId = u.userId
INNER JOIN roles r ON e.roleId = r.roleId
INNER JOIN branches br ON b.branchId = br.branchId
INNER JOIN customers c ON b.customerId = c.customerId

WHERE 
    b.consultantId IS NOT NULL
    AND r.roleName = 'Consultant'
    AND b.createdAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)  -- 7 ngày gần đây

ORDER BY b.createdAt DESC;

-- ============================================
-- Query 3: Đơn hàng mới nhất (30 ngày gần đây) - Chi tiết hơn
-- ============================================
SELECT 
    b.bookingId AS 'Mã đơn',
    DATE_FORMAT(b.createdAt, '%d/%m/%Y %H:%i:%s') AS 'Ngày tạo',
    TIMESTAMPDIFF(HOUR, b.createdAt, NOW()) AS 'Giờ trước',
    b.status AS 'Trạng thái',
    
    -- Tư vấn viên
    CONCAT(u.fullName, ' (', u.username, ')') AS 'Tư vấn viên',
    u.email AS 'Email TVV',
    
    -- Chi nhánh
    br.branchName AS 'Chi nhánh',
    
    -- Khách hàng
    CONCAT(c.fullName, ' - ', c.phone) AS 'Khách hàng',
    
    -- Đơn hàng
    FORMAT(b.totalCost, 0) AS 'Tổng tiền',
    FORMAT(b.depositAmount, 0) AS 'Tiền cọc',
    ht.name AS 'Loại thuê',
    b.note AS 'Ghi chú',
    
    -- Số chuyến
    (SELECT COUNT(*) FROM trips t WHERE t.bookingId = b.bookingId) AS 'Số chuyến'
    
FROM bookings b
INNER JOIN employees e ON b.consultantId = e.employeeId
INNER JOIN users u ON e.userId = u.userId
INNER JOIN roles r ON e.roleId = r.roleId
INNER JOIN branches br ON b.branchId = br.branchId
INNER JOIN customers c ON b.customerId = c.customerId
LEFT JOIN hire_types ht ON b.hireTypeId = ht.hireTypeId

WHERE 
    b.consultantId IS NOT NULL
    AND r.roleName = 'Consultant'
    AND b.createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)  -- 30 ngày gần đây

ORDER BY b.createdAt DESC
LIMIT 50;  -- Giới hạn 50 đơn mới nhất

-- ============================================
-- Query 4: Thống kê đơn hàng theo tư vấn viên
-- ============================================
SELECT 
    u.fullName AS 'Tư vấn viên',
    u.username AS 'Username',
    br.branchName AS 'Chi nhánh',
    COUNT(b.bookingId) AS 'Tổng số đơn',
    COUNT(CASE WHEN b.createdAt >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 END) AS 'Đơn 7 ngày',
    COUNT(CASE WHEN b.createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) AS 'Đơn 30 ngày',
    SUM(b.totalCost) AS 'Tổng giá trị',
    MAX(b.createdAt) AS 'Đơn mới nhất'
    
FROM bookings b
INNER JOIN employees e ON b.consultantId = e.employeeId
INNER JOIN users u ON e.userId = u.userId
INNER JOIN roles r ON e.roleId = r.roleId
INNER JOIN branches br ON b.branchId = br.branchId

WHERE 
    b.consultantId IS NOT NULL
    AND r.roleName = 'Consultant'

GROUP BY u.fullName, u.username, br.branchName

ORDER BY 'Đơn mới nhất' DESC;

-- ============================================
-- Query 5: Đơn hàng chưa có chuyến (cần điều phối)
-- ============================================
SELECT 
    b.bookingId AS 'Mã đơn',
    DATE_FORMAT(b.createdAt, '%d/%m/%Y %H:%i:%s') AS 'Ngày tạo',
    b.status AS 'Trạng thái',
    u.fullName AS 'Tư vấn viên',
    br.branchName AS 'Chi nhánh',
    c.fullName AS 'Khách hàng',
    FORMAT(b.totalCost, 0) AS 'Tổng tiền',
    (SELECT COUNT(*) FROM trips t WHERE t.bookingId = b.bookingId) AS 'Số chuyến'
    
FROM bookings b
INNER JOIN employees e ON b.consultantId = e.employeeId
INNER JOIN users u ON e.userId = u.userId
INNER JOIN roles r ON e.roleId = r.roleId
INNER JOIN branches br ON b.branchId = br.branchId
INNER JOIN customers c ON b.customerId = c.customerId

WHERE 
    b.consultantId IS NOT NULL
    AND r.roleName = 'Consultant'
    AND b.status IN ('PENDING', 'CONFIRMED')
    AND NOT EXISTS (
        SELECT 1 FROM trips t 
        WHERE t.bookingId = b.bookingId
    )

ORDER BY b.createdAt DESC;

