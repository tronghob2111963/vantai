-- ==========================================================
-- MODULE 5 ADDITIONS - Dispatch Management
-- Script để cập nhật database hiện có với các bảng mới
-- Chạy script này nếu database đã tồn tại
-- ==========================================================

USE ptcmss_db;

-- ==========================================================
-- 1) Cập nhật bảng Drivers - Thêm cột rating
-- ==========================================================
ALTER TABLE Drivers 
  ADD COLUMN IF NOT EXISTS averageRating DECIMAL(3,2) DEFAULT 5.00,
  ADD COLUMN IF NOT EXISTS totalRatings INT DEFAULT 0;

-- ==========================================================
-- 2) Tạo bảng TripAssignmentHistory
-- ==========================================================
CREATE TABLE IF NOT EXISTS TripAssignmentHistory (
  historyId INT AUTO_INCREMENT PRIMARY KEY,
  tripId INT NOT NULL,
  action ENUM('ASSIGN','REASSIGN','UNASSIGN','CANCEL') NOT NULL,
  driverId INT NULL,
  vehicleId INT NULL,
  previousDriverId INT NULL,
  previousVehicleId INT NULL,
  reason VARCHAR(500),
  performedBy INT NOT NULL,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_tah_trip FOREIGN KEY (tripId) REFERENCES Trips(tripId),
  CONSTRAINT fk_tah_driver FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  CONSTRAINT fk_tah_vehicle FOREIGN KEY (vehicleId) REFERENCES Vehicles(vehicleId),
  CONSTRAINT fk_tah_prevDriver FOREIGN KEY (previousDriverId) REFERENCES Drivers(driverId),
  CONSTRAINT fk_tah_prevVehicle FOREIGN KEY (previousVehicleId) REFERENCES Vehicles(vehicleId),
  CONSTRAINT fk_tah_performer FOREIGN KEY (performedBy) REFERENCES Employees(employeeId)
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS IX_TripAssignmentHistory_TripId ON TripAssignmentHistory(tripId);
CREATE INDEX IF NOT EXISTS IX_TripAssignmentHistory_CreatedAt ON TripAssignmentHistory(createdAt);
CREATE INDEX IF NOT EXISTS IX_TripAssignmentHistory_DriverId ON TripAssignmentHistory(driverId);

-- ==========================================================
-- 3) Tạo bảng TripRatings
-- ==========================================================
CREATE TABLE IF NOT EXISTS TripRatings (
  ratingId INT AUTO_INCREMENT PRIMARY KEY,
  tripId INT NOT NULL,
  driverId INT NOT NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment VARCHAR(500),
  ratedBy INT NULL,
  ratedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_tr_trip FOREIGN KEY (tripId) REFERENCES Trips(tripId),
  CONSTRAINT fk_tr_driver FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  CONSTRAINT fk_tr_rater FOREIGN KEY (ratedBy) REFERENCES Employees(employeeId),
  UNIQUE KEY UK_TripRatings_Trip (tripId, driverId)
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS IX_TripRatings_DriverId ON TripRatings(driverId);
CREATE INDEX IF NOT EXISTS IX_TripRatings_RatedAt ON TripRatings(ratedAt);

-- ==========================================================
-- 4) Tạo bảng DriverWorkload
-- ==========================================================
CREATE TABLE IF NOT EXISTS DriverWorkload (
  workloadId INT AUTO_INCREMENT PRIMARY KEY,
  driverId INT NOT NULL,
  date DATE NOT NULL,
  totalMinutes INT DEFAULT 0,
  tripCount INT DEFAULT 0,
  fairnessScore DECIMAL(5,2) DEFAULT 0,
  lastUpdated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_dw_driver FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  UNIQUE KEY UK_DriverWorkload_Date (driverId, date)
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS IX_DriverWorkload_Date ON DriverWorkload(date);
CREATE INDEX IF NOT EXISTS IX_DriverWorkload_Score ON DriverWorkload(fairnessScore);

-- ==========================================================
-- 5) Tạo bảng TripIncidents
-- ==========================================================
CREATE TABLE IF NOT EXISTS TripIncidents (
  incidentId INT AUTO_INCREMENT PRIMARY KEY,
  tripId INT NOT NULL,
  driverId INT NOT NULL,
  incidentType VARCHAR(50) NOT NULL,
  description VARCHAR(1000),
  location VARCHAR(255),
  reportedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  severity ENUM('LOW','MEDIUM','HIGH','CRITICAL') DEFAULT 'MEDIUM',
  status ENUM('REPORTED','INVESTIGATING','RESOLVED','CLOSED') DEFAULT 'REPORTED',
  resolvedBy INT NULL,
  resolvedAt DATETIME NULL,
  note VARCHAR(500),
  CONSTRAINT fk_ti_trip FOREIGN KEY (tripId) REFERENCES Trips(tripId),
  CONSTRAINT fk_ti_driver FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  CONSTRAINT fk_ti_resolver FOREIGN KEY (resolvedBy) REFERENCES Employees(employeeId)
) ENGINE=InnoDB;

CREATE INDEX IF NOT EXISTS IX_TripIncidents_TripId ON TripIncidents(tripId);
CREATE INDEX IF NOT EXISTS IX_TripIncidents_DriverId ON TripIncidents(driverId);
CREATE INDEX IF NOT EXISTS IX_TripIncidents_Status ON TripIncidents(status);
CREATE INDEX IF NOT EXISTS IX_TripIncidents_Severity ON TripIncidents(severity);

-- ==========================================================
-- 6) Thêm index mới cho bảng Trips
-- ==========================================================
CREATE INDEX IF NOT EXISTS IX_Trips_Branch_Status_Time ON Trips(status, startTime);

-- ==========================================================
-- 7) Tạo Views mới
-- ==========================================================

-- View: Driver Ratings Summary
CREATE OR REPLACE VIEW v_DriverRatingsSummary AS
SELECT
  d.driverId,
  d.averageRating,
  d.totalRatings,
  COUNT(tr.ratingId) AS calculatedTotalRatings,
  AVG(tr.rating) AS calculatedAverageRating,
  AVG(CASE WHEN tr.ratedAt >= DATE_SUB(NOW(), INTERVAL 30 DAY) 
           THEN tr.rating ELSE NULL END) AS rating30Days,
  COUNT(CASE WHEN tr.ratedAt >= DATE_SUB(NOW(), INTERVAL 30 DAY) 
             THEN 1 ELSE NULL END) AS ratings30Days
FROM Drivers d
LEFT JOIN TripRatings tr ON d.driverId = tr.driverId
GROUP BY d.driverId, d.averageRating, d.totalRatings;

-- View: Driver Workload Summary
CREATE OR REPLACE VIEW v_DriverWorkloadSummary AS
SELECT
  d.driverId,
  e.employeeId,
  u.fullName AS driverName,
  d.branchId,
  b.branchName,
  d.status AS driverStatus,
  COALESCE(SUM(dw.totalMinutes), 0) AS totalMinutesLast7Days,
  COALESCE(SUM(dw.tripCount), 0) AS totalTripsLast7Days,
  COALESCE(AVG(dw.fairnessScore), 0) AS avgFairnessScore
FROM Drivers d
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
JOIN Branches b ON d.branchId = b.branchId
LEFT JOIN DriverWorkload dw ON d.driverId = dw.driverId 
  AND dw.date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY d.driverId, e.employeeId, u.fullName, d.branchId, b.branchName, d.status;

-- ==========================================================
-- 8) Thêm System Settings cho Fairness Algorithm
-- ==========================================================
INSERT INTO SystemSettings (settingKey, settingValue, effectiveStartDate, valueType, category, description, updatedBy, status) VALUES
('FAIRNESS_WEIGHT_DAILY_HOURS', '0.4', '2025-01-01', 'decimal', 'Dispatch', 'Trọng số giờ làm việc hàng ngày trong tính fairness', 1, 'ACTIVE'),
('FAIRNESS_WEIGHT_WEEKLY_TRIPS', '0.3', '2025-01-01', 'decimal', 'Dispatch', 'Trọng số số chuyến trong tuần trong tính fairness', 1, 'ACTIVE'),
('FAIRNESS_WEIGHT_REST_TIME', '0.3', '2025-01-01', 'decimal', 'Dispatch', 'Trọng số thời gian nghỉ trong tính fairness', 1, 'ACTIVE')
ON DUPLICATE KEY UPDATE 
  settingValue = VALUES(settingValue), 
  description = VALUES(description), 
  updatedBy = VALUES(updatedBy),
  status = VALUES(status);

-- ==========================================================
-- 9) Sample Data (Optional - Comment out nếu không cần)
-- ==========================================================

-- Sample: TripAssignmentHistory
INSERT INTO TripAssignmentHistory (historyId, tripId, action, driverId, vehicleId, previousDriverId, previousVehicleId, reason, performedBy, createdAt) VALUES
(1, 1, 'ASSIGN', 1, 3, NULL, NULL, 'Gán lần đầu cho chuyến Hà Nội - Hạ Long', 2, '2025-10-24 15:00:00'),
(2, 2, 'ASSIGN', 4, 5, NULL, NULL, 'Gán tài xế D cho chuyến đón sân bay', 4, '2025-10-27 10:00:00'),
(3, 6, 'ASSIGN', 5, 2, NULL, NULL, 'Gán tài xế E cho chuyến đi Nội Bài', 2, '2025-10-28 09:00:00')
ON DUPLICATE KEY UPDATE reason = VALUES(reason);

-- Sample: TripRatings
INSERT INTO TripRatings (ratingId, tripId, driverId, rating, comment, ratedBy, ratedAt) VALUES
(1, 1, 1, 5, 'Tài xế lái xe an toàn, đúng giờ, thái độ tốt', 2, '2025-10-25 21:00:00'),
(2, 1, 1, 4, 'Tốt nhưng có thể cải thiện giao tiếp', 5, '2025-10-25 22:00:00')
ON DUPLICATE KEY UPDATE comment = VALUES(comment);

-- Sample: DriverWorkload
INSERT INTO DriverWorkload (workloadId, driverId, date, totalMinutes, tripCount, fairnessScore) VALUES
(1, 1, '2025-10-25', 780, 1, 45.5),
(2, 2, '2025-10-25', 0, 0, 10.0),
(3, 3, '2025-10-25', 0, 0, 10.0),
(4, 4, '2025-10-28', 90, 1, 25.2),
(5, 5, '2025-10-29', 60, 1, 20.8),
(6, 1, '2025-11-01', 90, 1, 30.0),
(7, 2, '2025-11-01', 90, 1, 30.0)
ON DUPLICATE KEY UPDATE totalMinutes = VALUES(totalMinutes), tripCount = VALUES(tripCount), fairnessScore = VALUES(fairnessScore);

-- Sample: TripIncidents
INSERT INTO TripIncidents (incidentId, tripId, driverId, incidentType, description, location, severity, status) VALUES
(1, 1, 1, 'TRAFFIC_JAM', 'Kẹt xe trên cao tốc Hà Nội - Hạ Long do tai nạn', 'Km 45 cao tốc HN-HL', 'LOW', 'CLOSED'),
(2, 2, 4, 'VEHICLE_ISSUE', 'Lốp xe bị xì hơi nhẹ, đã xử lý', 'Gần sân bay TSN', 'MEDIUM', 'RESOLVED')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- ==========================================================
-- 10) Cập nhật averageRating cho tài xế hiện có (nếu có data)
-- ==========================================================
UPDATE Drivers d
SET 
  averageRating = COALESCE((
    SELECT AVG(rating) 
    FROM TripRatings tr 
    WHERE tr.driverId = d.driverId
  ), 5.00),
  totalRatings = COALESCE((
    SELECT COUNT(*) 
    FROM TripRatings tr 
    WHERE tr.driverId = d.driverId
  ), 0);

-- ==========================================================
-- End of Module 5 Additions
-- ==========================================================

SELECT 'Module 5 database additions completed successfully!' AS Status;
