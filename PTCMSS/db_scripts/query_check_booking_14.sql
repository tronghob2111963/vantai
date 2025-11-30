-- ============================================
-- QUERY: KIỂM TRA ĐƠN HÀNG VỪA TẠO (bookingId = 14)
-- ============================================

-- Query 1: Tìm đơn hàng theo bookingId = 14
SELECT 
    b.bookingId AS 'Mã đơn',
    b.createdAt AS 'Thời gian tạo (DB)',
    DATE(b.createdAt) AS 'Ngày tạo',
    TIME(b.createdAt) AS 'Giờ tạo',
    DATE_FORMAT(b.createdAt, '%d/%m/%Y %H:%i:%s') AS 'Ngày giờ (VN)',
    b.status AS 'Trạng thái',
    FORMAT(b.totalCost, 0) AS 'Tổng tiền',
    b.consultantId AS 'Consultant ID',
    u.fullName AS 'Tư vấn viên',
    u.username AS 'Username TVV',
    br.branchId AS 'Branch ID',
    br.branchName AS 'Chi nhánh',
    c.fullName AS 'Khách hàng',
    c.phone AS 'SĐT khách hàng',
    (SELECT COUNT(*) FROM trips t WHERE t.bookingId = b.bookingId) AS 'Số chuyến'
    
FROM bookings b
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
LEFT JOIN branches br ON b.branchId = br.branchId
LEFT JOIN customers c ON b.customerId = c.customerId

WHERE b.bookingId = 14;

-- ============================================
-- Query 2: So sánh với CURDATE() và UTC
-- ============================================
SELECT 
    b.bookingId,
    b.createdAt AS 'Created At',
    DATE(b.createdAt) AS 'Date (DB)',
    CURDATE() AS 'CURDATE()',
    DATE(UTC_TIMESTAMP()) AS 'UTC_DATE()',
    CASE 
        WHEN DATE(b.createdAt) = CURDATE() THEN '✅ Match CURDATE()'
        ELSE '❌ Không match CURDATE()'
    END AS 'Check CURDATE',
    CASE 
        WHEN DATE(b.createdAt) = DATE(UTC_TIMESTAMP()) THEN '✅ Match UTC_DATE()'
        ELSE '❌ Không match UTC_DATE()'
    END AS 'Check UTC_DATE',
    TIMESTAMPDIFF(HOUR, b.createdAt, NOW()) AS 'Giờ trước'
    
FROM bookings b
WHERE b.bookingId = 14;

-- ============================================
-- Query 3: Kiểm tra timezone của database
-- ============================================
SELECT 
    @@global.time_zone AS 'Global Timezone',
    @@session.time_zone AS 'Session Timezone',
    NOW() AS 'NOW()',
    CURDATE() AS 'CURDATE()',
    UTC_TIMESTAMP() AS 'UTC_TIMESTAMP()',
    DATE(UTC_TIMESTAMP()) AS 'UTC_DATE()',
    (SELECT createdAt FROM bookings WHERE bookingId = 14) AS 'Booking 14 Created At',
    DATE((SELECT createdAt FROM bookings WHERE bookingId = 14)) AS 'Booking 14 Date';

-- ============================================
-- Query 4: Tìm đơn hàng trong 24 giờ qua (an toàn nhất)
-- ============================================
SELECT 
    b.bookingId,
    DATE_FORMAT(b.createdAt, '%d/%m/%Y %H:%i:%s') AS 'Ngày giờ tạo',
    TIMESTAMPDIFF(MINUTE, b.createdAt, NOW()) AS 'Phút trước',
    b.status,
    FORMAT(b.totalCost, 0) AS 'Tổng tiền',
    b.consultantId,
    u.fullName AS 'Tư vấn viên',
    br.branchName AS 'Chi nhánh'
    
FROM bookings b
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
LEFT JOIN branches br ON b.branchId = br.branchId

WHERE 
    b.createdAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
    AND b.bookingId = 14  -- Hoặc bỏ dòng này để xem tất cả đơn 24h qua

ORDER BY b.createdAt DESC;

