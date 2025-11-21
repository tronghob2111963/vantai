-- =====================================================
-- Script: 12_CREATE_DRIVER_RATINGS.sql
-- Mục đích: Tạo bảng đánh giá tài xế (Driver Rating & Performance)
-- =====================================================

-- Bảng DriverRatings: Đánh giá tài xế sau mỗi chuyến
CREATE TABLE IF NOT EXISTS DriverRatings (
    ratingId INT AUTO_INCREMENT PRIMARY KEY,
    tripId INT NOT NULL,
    driverId INT NOT NULL,
    customerId INT,
    
    -- Các tiêu chí đánh giá (1-5 sao)
    punctualityRating TINYINT CHECK (punctualityRating BETWEEN 1 AND 5) COMMENT 'Đúng giờ',
    attitudeRating TINYINT CHECK (attitudeRating BETWEEN 1 AND 5) COMMENT 'Thái độ',
    safetyRating TINYINT CHECK (safetyRating BETWEEN 1 AND 5) COMMENT 'An toàn',
    complianceRating TINYINT CHECK (complianceRating BETWEEN 1 AND 5) COMMENT 'Tuân thủ quy trình',
    
    -- Tổng điểm và trung bình
    overallRating DECIMAL(3,2) COMMENT 'Trung bình 4 tiêu chí',
    
    -- Comment từ khách hàng
    comment TEXT,
    
    -- Metadata
    ratedBy INT COMMENT 'User ID người đánh giá (có thể là khách hoặc admin)',
    ratedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (tripId) REFERENCES Trips(tripId) ON DELETE CASCADE,
    FOREIGN KEY (driverId) REFERENCES Drivers(driverId) ON DELETE CASCADE,
    FOREIGN KEY (customerId) REFERENCES Customers(customerId) ON DELETE SET NULL,
    FOREIGN KEY (ratedBy) REFERENCES Users(userId) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_driver (driverId),
    INDEX idx_trip (tripId),
    INDEX idx_rated_at (ratedAt),
    INDEX idx_overall_rating (overallRating),
    
    -- Unique constraint: Mỗi trip chỉ được đánh giá 1 lần
    UNIQUE KEY uk_trip_rating (tripId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Đánh giá tài xế sau mỗi chuyến hoàn thành';

-- Bảng DriverPerformanceStats: Thống kê hiệu suất tài xế
CREATE TABLE IF NOT EXISTS DriverPerformanceStats (
    statId INT AUTO_INCREMENT PRIMARY KEY,
    driverId INT NOT NULL,
    
    -- Khoảng thời gian thống kê
    periodType VARCHAR(20) NOT NULL COMMENT 'DAILY, WEEKLY, MONTHLY, LAST_30_DAYS',
    periodStart DATE NOT NULL,
    periodEnd DATE NOT NULL,
    
    -- Thống kê rating
    totalRatings INT DEFAULT 0,
    avgPunctuality DECIMAL(3,2),
    avgAttitude DECIMAL(3,2),
    avgSafety DECIMAL(3,2),
    avgCompliance DECIMAL(3,2),
    avgOverall DECIMAL(3,2),
    
    -- Thống kê chuyến
    totalTrips INT DEFAULT 0,
    completedTrips INT DEFAULT 0,
    cancelledTrips INT DEFAULT 0,
    
    -- Thống kê thời gian
    totalHours DECIMAL(10,2) COMMENT 'Tổng giờ lái',
    onTimeTrips INT DEFAULT 0 COMMENT 'Số chuyến đúng giờ',
    lateTrips INT DEFAULT 0 COMMENT 'Số chuyến trễ',
    
    -- Metadata
    calculatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (driverId) REFERENCES Drivers(driverId) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_driver_period (driverId, periodType, periodStart),
    INDEX idx_period (periodStart, periodEnd),
    
    -- Unique constraint
    UNIQUE KEY uk_driver_period (driverId, periodType, periodStart, periodEnd)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Thống kê hiệu suất tài xế theo thời gian';

-- Trigger: Tự động tính overallRating khi insert/update
DELIMITER $$

CREATE TRIGGER before_driver_rating_insert
BEFORE INSERT ON DriverRatings
FOR EACH ROW
BEGIN
    SET NEW.overallRating = (
        COALESCE(NEW.punctualityRating, 0) + 
        COALESCE(NEW.attitudeRating, 0) + 
        COALESCE(NEW.safetyRating, 0) + 
        COALESCE(NEW.complianceRating, 0)
    ) / 4.0;
END$$

CREATE TRIGGER before_driver_rating_update
BEFORE UPDATE ON DriverRatings
FOR EACH ROW
BEGIN
    SET NEW.overallRating = (
        COALESCE(NEW.punctualityRating, 0) + 
        COALESCE(NEW.attitudeRating, 0) + 
        COALESCE(NEW.safetyRating, 0) + 
        COALESCE(NEW.complianceRating, 0)
    ) / 4.0;
END$$

DELIMITER ;

-- Insert sample data (optional)
-- Sample ratings cho testing
INSERT INTO DriverRatings (tripId, driverId, customerId, punctualityRating, attitudeRating, safetyRating, complianceRating, comment, ratedBy)
SELECT 
    t.tripId,
    td.driverId,
    b.customerId,
    5, 5, 5, 5,
    'Tài xế rất tốt, lái xe an toàn',
    b.consultantId
FROM Trips t
JOIN TripDrivers td ON t.tripId = td.tripId
JOIN Bookings b ON t.bookingId = b.bookingId
WHERE t.status = 'COMPLETED'
AND NOT EXISTS (SELECT 1 FROM DriverRatings WHERE tripId = t.tripId)
LIMIT 3;

-- View: Driver rating summary (30 ngày gần nhất)
CREATE OR REPLACE VIEW DriverRatingSummary AS
SELECT 
    d.driverId,
    u.fullName as driverName,
    d.branchId,
    b.branchName,
    COUNT(dr.ratingId) as totalRatings,
    ROUND(AVG(dr.punctualityRating), 2) as avgPunctuality,
    ROUND(AVG(dr.attitudeRating), 2) as avgAttitude,
    ROUND(AVG(dr.safetyRating), 2) as avgSafety,
    ROUND(AVG(dr.complianceRating), 2) as avgCompliance,
    ROUND(AVG(dr.overallRating), 2) as avgOverall,
    MAX(dr.ratedAt) as lastRatedAt
FROM Drivers d
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
JOIN Branches b ON d.branchId = b.branchId
LEFT JOIN DriverRatings dr ON d.driverId = dr.driverId 
    AND dr.ratedAt >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY d.driverId, u.fullName, d.branchId, b.branchName;

COMMIT;
