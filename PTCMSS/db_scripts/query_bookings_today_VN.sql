-- ============================================
-- QUERY: ĐƠN HÀNG HÔM NAY THEO GIỜ VIỆT NAM (UTC+7)
-- ============================================
-- LƯU Ý: createdAt lưu ở UTC, nhưng cần lấy đơn theo giờ VN
-- Ví dụ: 30/11 18:23 UTC = 01/12 01:23 VN → Tính là đơn ngày 01/12

-- Query nhanh nhất: Đơn hàng hôm nay (theo giờ VN)
SELECT 
    b.bookingId AS 'Mã đơn',
    DATE_FORMAT(CONVERT_TZ(b.createdAt, '+00:00', '+07:00'), '%d/%m/%Y %H:%i:%s') AS 'Ngày giờ tạo (VN)',
    TIME(CONVERT_TZ(b.createdAt, '+00:00', '+07:00')) AS 'Giờ tạo (VN)',
    b.status AS 'Trạng thái',
    FORMAT(b.totalCost, 0) AS 'Tổng tiền',
    br.branchName AS 'Chi nhánh',
    CASE 
        WHEN b.consultantId IS NULL THEN 'Không có TVV'
        ELSE u.fullName
    END AS 'Tư vấn viên',
    (SELECT COUNT(*) FROM trips t WHERE t.bookingId = b.bookingId) AS 'Số chuyến'
    
FROM bookings b
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
LEFT JOIN branches br ON b.branchId = br.branchId

WHERE 
    -- Convert createdAt sang giờ VN rồi so với CURDATE()
    DATE(CONVERT_TZ(b.createdAt, '+00:00', '+07:00')) = CURDATE()

ORDER BY b.createdAt DESC;

