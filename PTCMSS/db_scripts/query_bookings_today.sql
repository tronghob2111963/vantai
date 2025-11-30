-- ============================================
-- QUERY: KIỂM TRA ĐƠN HÀNG ĐƯỢC TẠO HÔM NAY
-- ============================================
-- LƯU Ý: createdAt được lưu ở UTC, nhưng cần lấy đơn theo giờ Việt Nam (UTC+7)
-- Giải pháp: Convert createdAt sang timezone VN (+07:00) rồi so sánh với CURDATE()
-- Ví dụ: 30/11 18:23 UTC = 01/12 01:23 VN → Nên tính là đơn ngày 01/12

-- Query 1: Đơn hàng được tạo hôm nay (FIX TIMEZONE - Dùng UTC)
SELECT 
    b.bookingId AS 'Mã đơn',
    DATE_FORMAT(b.createdAt, '%d/%m/%Y %H:%i:%s') AS 'Ngày tạo (UTC)',
    DATE_FORMAT(CONVERT_TZ(b.createdAt, '+00:00', '+07:00'), '%d/%m/%Y %H:%i:%s') AS 'Ngày tạo (VN)',
    TIME(b.createdAt) AS 'Giờ tạo (UTC)',
    TIMESTAMPDIFF(MINUTE, b.createdAt, NOW()) AS 'Phút trước',
    b.status AS 'Trạng thái',
    FORMAT(b.totalCost, 0) AS 'Tổng tiền (VNĐ)',
    FORMAT(b.depositAmount, 0) AS 'Tiền cọc (VNĐ)',
    
    -- Tư vấn viên
    CASE 
        WHEN b.consultantId IS NULL THEN 'Không có'
        ELSE CONCAT(u.fullName, ' (', u.username, ')')
    END AS 'Tư vấn viên',
    
    -- Chi nhánh
    br.branchName AS 'Chi nhánh',
    
    -- Khách hàng
    c.fullName AS 'Khách hàng',
    c.phone AS 'SĐT khách hàng',
    
    -- Loại thuê
    COALESCE(ht.name, 'N/A') AS 'Loại thuê',
    
    -- Số chuyến
    (SELECT COUNT(*) FROM trips t WHERE t.bookingId = b.bookingId) AS 'Số chuyến',
    
    -- Ghi chú
    b.note AS 'Ghi chú'
    
FROM bookings b
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
LEFT JOIN roles r ON e.roleId = r.roleId
LEFT JOIN branches br ON b.branchId = br.branchId
LEFT JOIN customers c ON b.customerId = c.customerId
LEFT JOIN hire_types ht ON b.hireTypeId = ht.hireTypeId

WHERE 
    -- FIX: Convert createdAt sang giờ VN (UTC+7) rồi so với CURDATE()
    -- Vì: 30/11 18:23 UTC = 01/12 01:23 VN → Nên tính là đơn ngày 01/12
    DATE(CONVERT_TZ(b.createdAt, '+00:00', '+07:00')) = CURDATE()

ORDER BY b.createdAt DESC;

-- ============================================
-- Query 2: Đơn hàng được tạo hôm nay (chỉ của tư vấn viên) - FIX TIMEZONE
-- ============================================
SELECT 
    b.bookingId AS 'Mã đơn',
    DATE_FORMAT(b.createdAt, '%H:%i:%s') AS 'Giờ tạo (UTC)',
    DATE_FORMAT(CONVERT_TZ(b.createdAt, '+00:00', '+07:00'), '%H:%i:%s') AS 'Giờ tạo (VN)',
    b.status AS 'Trạng thái',
    FORMAT(b.totalCost, 0) AS 'Tổng tiền',
    u.fullName AS 'Tư vấn viên',
    br.branchName AS 'Chi nhánh',
    c.fullName AS 'Khách hàng',
    (SELECT COUNT(*) FROM trips t WHERE t.bookingId = b.bookingId) AS 'Số chuyến'
    
FROM bookings b
INNER JOIN employees e ON b.consultantId = e.employeeId
INNER JOIN users u ON e.userId = u.userId
INNER JOIN roles r ON e.roleId = r.roleId
INNER JOIN branches br ON b.branchId = br.branchId
INNER JOIN customers c ON b.customerId = c.customerId

WHERE 
    -- FIX: Convert sang giờ VN rồi so với CURDATE()
    DATE(CONVERT_TZ(b.createdAt, '+00:00', '+07:00')) = CURDATE()
    AND r.roleName = 'Consultant'

ORDER BY b.createdAt DESC;

-- ============================================
-- Query 3: Thống kê đơn hàng hôm nay theo chi nhánh
-- ============================================
SELECT 
    br.branchName AS 'Chi nhánh',
    COUNT(b.bookingId) AS 'Tổng số đơn',
    COUNT(CASE WHEN b.status = 'PENDING' THEN 1 END) AS 'Chờ xử lý',
    COUNT(CASE WHEN b.status = 'CONFIRMED' THEN 1 END) AS 'Đã xác nhận',
    COUNT(CASE WHEN b.status = 'INPROGRESS' THEN 1 END) AS 'Đang thực hiện',
    COUNT(CASE WHEN b.status = 'COMPLETED' THEN 1 END) AS 'Hoàn thành',
    COUNT(CASE WHEN b.status = 'CANCELLED' THEN 1 END) AS 'Đã hủy',
    SUM(b.totalCost) AS 'Tổng giá trị',
    COUNT(CASE WHEN b.consultantId IS NOT NULL THEN 1 END) AS 'Có tư vấn viên',
    COUNT(CASE WHEN b.consultantId IS NULL THEN 1 END) AS 'Không có TVV'
    
FROM bookings b
LEFT JOIN branches br ON b.branchId = br.branchId

WHERE DATE(CONVERT_TZ(b.createdAt, '+00:00', '+07:00')) = CURDATE()  -- FIX: Convert sang giờ VN

GROUP BY br.branchName

ORDER BY 'Tổng số đơn' DESC;

-- ============================================
-- Query 4: Đơn hàng hôm nay chưa có chuyến (cần điều phối)
-- ============================================
SELECT 
    b.bookingId AS 'Mã đơn',
    DATE_FORMAT(b.createdAt, '%H:%i:%s') AS 'Giờ tạo',
    b.status AS 'Trạng thái',
    FORMAT(b.totalCost, 0) AS 'Tổng tiền',
    u.fullName AS 'Tư vấn viên',
    br.branchName AS 'Chi nhánh',
    c.fullName AS 'Khách hàng',
    c.phone AS 'SĐT khách hàng',
    TIMESTAMPDIFF(HOUR, b.createdAt, NOW()) AS 'Giờ chờ'
    
FROM bookings b
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
LEFT JOIN branches br ON b.branchId = br.branchId
LEFT JOIN customers c ON b.customerId = c.customerId

WHERE 
    DATE(CONVERT_TZ(b.createdAt, '+00:00', '+07:00')) = CURDATE()  -- FIX: Convert sang giờ VN
    AND b.status IN ('PENDING', 'CONFIRMED')
    AND NOT EXISTS (
        SELECT 1 FROM trips t 
        WHERE t.bookingId = b.bookingId
    )

ORDER BY b.createdAt DESC;

-- ============================================
-- Query 5: Đơn hàng hôm nay theo từng giờ (timeline) - FIX TIMEZONE
-- ============================================
SELECT 
    DATE_FORMAT(CONVERT_TZ(b.createdAt, '+00:00', '+07:00'), '%H:00') AS 'Giờ (VN)',
    COUNT(b.bookingId) AS 'Số đơn',
    GROUP_CONCAT(b.bookingId ORDER BY b.createdAt SEPARATOR ', ') AS 'Danh sách mã đơn'
    
FROM bookings b

WHERE DATE(CONVERT_TZ(b.createdAt, '+00:00', '+07:00')) = CURDATE()  -- FIX: Convert sang giờ VN

GROUP BY DATE_FORMAT(CONVERT_TZ(b.createdAt, '+00:00', '+07:00'), '%H:00')

ORDER BY 'Giờ' ASC;

-- ============================================
-- Query 6: Đơn hàng hôm nay - Quick check (FIX TIMEZONE)
-- ============================================
SELECT 
    b.bookingId,
    TIME(b.createdAt) AS 'Giờ tạo (UTC)',
    TIME(CONVERT_TZ(b.createdAt, '+00:00', '+07:00')) AS 'Giờ tạo (VN)',
    b.status,
    b.totalCost,
    br.branchName,
    CASE 
        WHEN b.consultantId IS NULL THEN 'Không có TVV'
        ELSE u.fullName
    END AS 'Tư vấn viên'
    
FROM bookings b
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
LEFT JOIN branches br ON b.branchId = br.branchId

WHERE 
    -- FIX: Convert sang giờ VN rồi so với CURDATE()
    DATE(CONVERT_TZ(b.createdAt, '+00:00', '+07:00')) = CURDATE()

ORDER BY b.createdAt DESC;

-- ============================================
-- Query 7: Kiểm tra timezone và đơn hàng mới nhất (FIX TIMEZONE ISSUE)
-- ============================================
-- Kiểm tra timezone hiện tại
SELECT 
    @@global.time_zone AS 'Global Timezone',
    @@session.time_zone AS 'Session Timezone',
    NOW() AS 'NOW()',
    CURDATE() AS 'CURDATE()',
    UTC_TIMESTAMP() AS 'UTC_TIMESTAMP()',
    DATE(UTC_TIMESTAMP()) AS 'UTC_DATE()';

-- Đơn hàng hôm nay (dùng UTC để tránh lỗi timezone)
SELECT 
    b.bookingId,
    b.createdAt AS 'Created At (DB)',
    DATE(b.createdAt) AS 'Date (DB)',
    DATE(CONVERT_TZ(b.createdAt, @@session.time_zone, '+00:00')) AS 'Date (UTC)',
    TIME(b.createdAt) AS 'Giờ tạo',
    b.status,
    FORMAT(b.totalCost, 0) AS 'Tổng tiền',
    br.branchName AS 'Chi nhánh',
    CASE 
        WHEN b.consultantId IS NULL THEN 'Không có TVV'
        ELSE u.fullName
    END AS 'Tư vấn viên',
    b.consultantId AS 'Consultant ID'
    
FROM bookings b
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
LEFT JOIN branches br ON b.branchId = br.branchId

WHERE 
    -- Dùng UTC date hoặc cả 2 timezone
    DATE(b.createdAt) = CURDATE()
    OR DATE(CONVERT_TZ(b.createdAt, @@session.time_zone, '+00:00')) = DATE(UTC_TIMESTAMP())

ORDER BY b.createdAt DESC;

-- ============================================
-- Query 8: Tìm đơn hàng theo bookingId (để debug)
-- ============================================
SELECT 
    b.bookingId,
    b.createdAt AS 'Created At',
    DATE(b.createdAt) AS 'Date',
    TIME(b.createdAt) AS 'Time',
    DATE_FORMAT(b.createdAt, '%Y-%m-%d %H:%i:%s') AS 'Formatted',
    b.status,
    b.totalCost,
    b.consultantId,
    u.fullName AS 'Tư vấn viên',
    br.branchName AS 'Chi nhánh',
    c.fullName AS 'Khách hàng',
    (SELECT COUNT(*) FROM trips t WHERE t.bookingId = b.bookingId) AS 'Số chuyến'
    
FROM bookings b
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
LEFT JOIN branches br ON b.branchId = br.branchId
LEFT JOIN customers c ON b.customerId = c.customerId

WHERE b.bookingId = 14;  -- Thay đổi bookingId cần tìm

-- ============================================
-- Query 9: Đơn hàng trong 24 giờ qua (tránh lỗi timezone)
-- ============================================
SELECT 
    b.bookingId,
    b.createdAt AS 'Created At',
    TIMESTAMPDIFF(HOUR, b.createdAt, NOW()) AS 'Giờ trước',
    b.status,
    FORMAT(b.totalCost, 0) AS 'Tổng tiền',
    br.branchName AS 'Chi nhánh',
    CASE 
        WHEN b.consultantId IS NULL THEN 'Không có TVV'
        ELSE CONCAT(u.fullName, ' (ID:', b.consultantId, ')')
    END AS 'Tư vấn viên',
    (SELECT COUNT(*) FROM trips t WHERE t.bookingId = b.bookingId) AS 'Số chuyến'
    
FROM bookings b
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
LEFT JOIN branches br ON b.branchId = br.branchId

WHERE 
    b.createdAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)  -- 24 giờ qua

ORDER BY b.createdAt DESC;

-- ============================================
-- Query 10: Đơn hàng hôm nay - Dùng cả 2 cách (SAFE)
-- ============================================
SELECT 
    b.bookingId,
    DATE_FORMAT(b.createdAt, '%d/%m/%Y %H:%i:%s') AS 'Ngày giờ tạo',
    b.status,
    FORMAT(b.totalCost, 0) AS 'Tổng tiền',
    br.branchName AS 'Chi nhánh',
    CASE 
        WHEN b.consultantId IS NULL THEN 'Không có TVV'
        ELSE u.fullName
    END AS 'Tư vấn viên',
    b.consultantId AS 'Consultant ID'
    
FROM bookings b
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
LEFT JOIN branches br ON b.branchId = br.branchId

WHERE 
    -- FIX TIMEZONE: Convert sang giờ VN rồi so với CURDATE()
    DATE(CONVERT_TZ(b.createdAt, '+00:00', '+07:00')) = CURDATE()
    -- Hoặc trong 24 giờ qua (an toàn hơn)
    OR b.createdAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)

ORDER BY b.createdAt DESC;

