-- =====================================================
-- Script: 13_INSERT_TEST_RATINGS.sql
-- Mục đích: Insert test data cho Driver Ratings
-- =====================================================

-- Insert sample ratings cho testing
-- Lưu ý: Chỉ insert cho các trip đã COMPLETED và chưa có rating

INSERT INTO DriverRatings (tripId, driverId, customerId, punctualityRating, attitudeRating, safetyRating, complianceRating, comment, ratedBy)
SELECT 
    t.tripId,
    td.driverId,
    b.customerId,
    FLOOR(4 + RAND() * 2) as punctualityRating,  -- Random 4-5
    FLOOR(4 + RAND() * 2) as attitudeRating,     -- Random 4-5
    FLOOR(4 + RAND() * 2) as safetyRating,       -- Random 4-5
    FLOOR(4 + RAND() * 2) as complianceRating,   -- Random 4-5
    CASE 
        WHEN RAND() > 0.5 THEN 'Tài xế rất tốt, lái xe an toàn'
        WHEN RAND() > 0.3 THEN 'Đúng giờ, thái độ tốt'
        ELSE 'Hài lòng với dịch vụ'
    END as comment,
    b.consultantId as ratedBy
FROM Trips t
JOIN TripDrivers td ON t.tripId = td.tripId
JOIN Bookings b ON t.bookingId = b.bookingId
WHERE t.status = 'COMPLETED'
AND NOT EXISTS (SELECT 1 FROM DriverRatings WHERE tripId = t.tripId)
LIMIT 20;

-- Verify inserted data
SELECT 
    dr.ratingId,
    dr.tripId,
    d.driverId,
    u.fullName as driverName,
    dr.punctualityRating,
    dr.attitudeRating,
    dr.safetyRating,
    dr.complianceRating,
    dr.overallRating,
    dr.comment,
    dr.ratedAt
FROM DriverRatings dr
JOIN Drivers d ON dr.driverId = d.driverId
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
ORDER BY dr.ratedAt DESC
LIMIT 10;

-- Check driver rating summary
SELECT * FROM DriverRatingSummary
ORDER BY avgOverall DESC;

-- Update Drivers.rating với trung bình 30 ngày
UPDATE Drivers d
SET d.rating = (
    SELECT ROUND(AVG(dr.overallRating), 2)
    FROM DriverRatings dr
    WHERE dr.driverId = d.driverId
    AND dr.ratedAt >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
)
WHERE EXISTS (
    SELECT 1 FROM DriverRatings dr2 
    WHERE dr2.driverId = d.driverId
);

-- Verify updated driver ratings
SELECT 
    d.driverId,
    u.fullName as driverName,
    d.rating as currentRating,
    COUNT(dr.ratingId) as totalRatings,
    ROUND(AVG(dr.overallRating), 2) as avgLast30Days
FROM Drivers d
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
LEFT JOIN DriverRatings dr ON d.driverId = dr.driverId 
    AND dr.ratedAt >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY d.driverId, u.fullName, d.rating
HAVING totalRatings > 0
ORDER BY currentRating DESC;

COMMIT;
