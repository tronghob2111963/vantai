USE ptcmss_db;

CREATE TABLE IF NOT EXISTS SystemSettings (
  settingId INT AUTO_INCREMENT PRIMARY KEY,
  settingKey VARCHAR(100) NOT NULL UNIQUE,
  settingValue VARCHAR(255) NOT NULL,
  effectiveStartDate DATE NOT NULL,
  effectiveEndDate DATE NULL,
  valueType ENUM('string','int','decimal','boolean','json') DEFAULT 'string' NOT NULL,
  category VARCHAR(100),
  description VARCHAR(255),
  updatedBy INT NULL,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Active','Inactive') DEFAULT 'Active',
  CONSTRAINT fk_sys_updBy FOREIGN KEY (updatedBy) REFERENCES Employees(employeeId)
) ENGINE=InnoDB;

DELIMITER $$

CREATE TRIGGER trg_Bookings_SetUpdatedAt
BEFORE UPDATE ON Bookings
FOR EACH ROW
BEGIN
  SET NEW.updatedAt = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_AR_SetUpdatedAt
BEFORE UPDATE ON AccountsReceivable
FOR EACH ROW
BEGIN
  SET NEW.updatedAt = CURRENT_TIMESTAMP;
END$$

DELIMITER ;

CREATE OR REPLACE VIEW v_DriverMonthlyPerformance AS
SELECT
  d.driverId                                        AS driverId,
  YEAR(t.startTime)                                 AS `year`,
  MONTH(t.startTime)                                AS `month`,
  COUNT(DISTINCT td.tripId)                         AS tripsCount,
  SUM(
    CASE
      WHEN td.startTime IS NOT NULL AND td.endTime IS NOT NULL
      THEN TIMESTAMPDIFF(MINUTE, td.startTime, td.endTime)
      ELSE 0
    END
  )                                                 AS minutesOnTrip
FROM TripDrivers td
JOIN Drivers d ON d.driverId = td.driverId
JOIN Trips   t ON t.tripId   = td.tripId
GROUP BY d.driverId, YEAR(t.startTime), MONTH(t.startTime);
