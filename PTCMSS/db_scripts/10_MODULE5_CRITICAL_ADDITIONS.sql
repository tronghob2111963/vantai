-- ==========================================================
-- MODULE 5 CRITICAL ADDITIONS
-- Bổ sung các bảng QUAN TRỌNG còn thiếu cho Module 5
-- ==========================================================

USE ptcmss_db;

-- ==========================================================
-- 1) DriverShifts - Ca làm việc của tài xế
-- ==========================================================
CREATE TABLE IF NOT EXISTS DriverShifts (
  shiftId INT AUTO_INCREMENT PRIMARY KEY,
  driverId INT NOT NULL,
  date DATE NOT NULL,
  shiftStart TIME NOT NULL,
  shiftEnd TIME NOT NULL,
  breakStart TIME NULL,
  breakEnd TIME NULL,
  status ENUM('SCHEDULED','ACTIVE','COMPLETED','CANCELLED') DEFAULT 'SCHEDULED',
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_dshift_driver FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  UNIQUE KEY UK_DriverShifts_Date (driverId, date),
  CHECK (shiftStart < shiftEnd),
  CHECK (breakStart IS NULL OR breakEnd IS NULL OR breakStart < breakEnd)
) ENGINE=InnoDB;

CREATE INDEX IX_DriverShifts_Date ON DriverShifts(date);
CREATE INDEX IX_DriverShifts_Status ON DriverShifts(status);

-- ==========================================================
-- 2) VehicleShifts - Ca hoạt động của xe
-- ==========================================================
CREATE TABLE IF NOT EXISTS VehicleShifts (
  shiftId INT AUTO_INCREMENT PRIMARY KEY,
  vehicleId INT NOT NULL,
  date DATE NOT NULL,
  shiftStart TIME NOT NULL,
  shiftEnd TIME NOT NULL,
  status ENUM('AVAILABLE','MAINTENANCE','INACTIVE') DEFAULT 'AVAILABLE',
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_vshift_vehicle FOREIGN KEY (vehicleId) REFERENCES Vehicles(vehicleId),
  UNIQUE KEY UK_VehicleShifts_Date (vehicleId, date),
  CHECK (shiftStart < shiftEnd)
) ENGINE=InnoDB;

CREATE INDEX IX_VehicleShifts_Date ON VehicleShifts(date);
CREATE INDEX IX_VehicleShifts_Status ON VehicleShifts(status);

-- ==========================================================
-- 3) VehicleMaintenance - Lịch bảo trì xe
-- ==========================================================
CREATE TABLE IF NOT EXISTS VehicleMaintenance (
  maintenanceId INT AUTO_INCREMENT PRIMARY KEY,
  vehicleId INT NOT NULL,
  maintenanceType VARCHAR(50) NOT NULL,
  description VARCHAR(500),
  scheduledStart DATETIME NOT NULL,
  scheduledEnd DATETIME NOT NULL,
  actualStart DATETIME NULL,
  actualEnd DATETIME NULL,
  status ENUM('SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'SCHEDULED',
  cost DECIMAL(10,2) DEFAULT 0,
  performedBy VARCHAR(100),
  note VARCHAR(500),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_vmaint_vehicle FOREIGN KEY (vehicleId) REFERENCES Vehicles(vehicleId),
  CHECK (scheduledStart < scheduledEnd),
  CHECK (actualStart IS NULL OR actualEnd IS NULL OR actualStart < actualEnd)
) ENGINE=InnoDB;

CREATE INDEX IX_VehicleMaintenance_VehicleId ON VehicleMaintenance(vehicleId);
CREATE INDEX IX_VehicleMaintenance_Status ON VehicleMaintenance(status);
CREATE INDEX IX_VehicleMaintenance_ScheduledStart ON VehicleMaintenance(scheduledStart);

-- ==========================================================
-- 4) ScheduleConflicts - Phát hiện xung đột lịch
-- ==========================================================
CREATE TABLE IF NOT EXISTS ScheduleConflicts (
  conflictId INT AUTO_INCREMENT PRIMARY KEY,
  conflictType ENUM('DRIVER_OVERLAP','VEHICLE_OVERLAP','INSUFFICIENT_REST','EXCEED_HOURS') NOT NULL,
  driverId INT NULL,
  vehicleId INT NULL,
  tripId1 INT NULL,
  tripId2 INT NULL,
  conflictTime DATETIME NOT NULL,
  description VARCHAR(500),
  detectedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  resolvedAt DATETIME NULL,
  resolvedBy INT NULL,
  status ENUM('DETECTED','ACKNOWLEDGED','RESOLVED','IGNORED') DEFAULT 'DETECTED',
  CONSTRAINT fk_sconf_driver FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  CONSTRAINT fk_sconf_vehicle FOREIGN KEY (vehicleId) REFERENCES Vehicles(vehicleId),
  CONSTRAINT fk_sconf_trip1 FOREIGN KEY (tripId1) REFERENCES Trips(tripId),
  CONSTRAINT fk_sconf_trip2 FOREIGN KEY (tripId2) REFERENCES Trips(tripId),
  CONSTRAINT fk_sconf_resolver FOREIGN KEY (resolvedBy) REFERENCES Employees(employeeId)
) ENGINE=InnoDB;

CREATE INDEX IX_ScheduleConflicts_Status ON ScheduleConflicts(status);
CREATE INDEX IX_ScheduleConflicts_DriverId ON ScheduleConflicts(driverId);
CREATE INDEX IX_ScheduleConflicts_VehicleId ON ScheduleConflicts(vehicleId);
CREATE INDEX IX_ScheduleConflicts_DetectedAt ON ScheduleConflicts(detectedAt);

-- ==========================================================
-- 5) DriverRestPeriods - Theo dõi thời gian nghỉ
-- ==========================================================
CREATE TABLE IF NOT EXISTS DriverRestPeriods (
  restId INT AUTO_INCREMENT PRIMARY KEY,
  driverId INT NOT NULL,
  date DATE NOT NULL,
  restStart DATETIME NOT NULL,
  restEnd DATETIME NOT NULL,
  durationMinutes INT AS (TIMESTAMPDIFF(MINUTE, restStart, restEnd)) STORED,
  isCompliant BOOLEAN AS (TIMESTAMPDIFF(MINUTE, restStart, restEnd) >= 30) STORED,
  tripIdBefore INT NULL,
  tripIdAfter INT NULL,
  CONSTRAINT fk_drest_driver FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  CONSTRAINT fk_drest_tripBefore FOREIGN KEY (tripIdBefore) REFERENCES Trips(tripId),
  CONSTRAINT fk_drest_tripAfter FOREIGN KEY (tripIdAfter) REFERENCES Trips(tripId),
  CHECK (restStart < restEnd)
) ENGINE=InnoDB;

CREATE INDEX IX_DriverRestPeriods_DriverId ON DriverRestPeriods(driverId);
CREATE INDEX IX_DriverRestPeriods_Date ON DriverRestPeriods(date);
CREATE INDEX IX_DriverRestPeriods_Compliant ON DriverRestPeriods(isCompliant);

-- ==========================================================
-- 6) ExpenseAttachments - Đính kèm chứng từ chi phí
-- ==========================================================
CREATE TABLE IF NOT EXISTS ExpenseAttachments (
  attachmentId INT AUTO_INCREMENT PRIMARY KEY,
  invoiceId INT NOT NULL,
  fileName VARCHAR(255) NOT NULL,
  filePath VARCHAR(500) NOT NULL,
  fileType VARCHAR(50),
  fileSize BIGINT,
  uploadedBy INT NULL,
  uploadedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_eatt_invoice FOREIGN KEY (invoiceId) REFERENCES Invoices(invoiceId),
  CONSTRAINT fk_eatt_uploader FOREIGN KEY (uploadedBy) REFERENCES Employees(employeeId)
) ENGINE=InnoDB;

CREATE INDEX IX_ExpenseAttachments_InvoiceId ON ExpenseAttachments(invoiceId);

-- ==========================================================
-- 7) ALTER Trips - Thêm status PENDING và ASSIGNED
-- ==========================================================
ALTER TABLE Trips 
MODIFY COLUMN status ENUM('PENDING','ASSIGNED','IN_PROGRESS','COMPLETED','CANCELLED') 
DEFAULT 'PENDING';

-- ==========================================================
-- 8) ALTER Bookings - Thêm cột miễn cọc
-- ==========================================================
ALTER TABLE Bookings 
ADD COLUMN IF NOT EXISTS depositWaived BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS depositWaivedBy INT NULL,
ADD COLUMN IF NOT EXISTS depositWaivedReason VARCHAR(255) NULL,
ADD COLUMN IF NOT EXISTS depositWaivedAt DATETIME NULL;

-- Thêm foreign key nếu chưa có
SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
                  WHERE CONSTRAINT_SCHEMA = 'ptcmss_db' 
                  AND TABLE_NAME = 'Bookings' 
                  AND CONSTRAINT_NAME = 'fk_book_depositWaiver');

SET @sql = IF(@fk_exists = 0,
  'ALTER TABLE Bookings ADD CONSTRAINT fk_book_depositWaiver FOREIGN KEY (depositWaivedBy) REFERENCES Employees(employeeId)',
  'SELECT "FK already exists"');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ==========================================================
-- 9) Views mới cho Module 5
-- ==========================================================

-- View: Driver Availability (Tính %Util)
CREATE OR REPLACE VIEW v_DriverAvailability AS
SELECT
  d.driverId,
  u.fullName AS driverName,
  d.branchId,
  b.branchName,
  ds.date,
  ds.shiftStart,
  ds.shiftEnd,
  TIMESTAMPDIFF(MINUTE, ds.shiftStart, ds.shiftEnd) AS shiftMinutes,
  COALESCE(dw.totalMinutes, 0) AS busyMinutes,
  ROUND(COALESCE(dw.totalMinutes, 0) * 100.0 / TIMESTAMPDIFF(MINUTE, ds.shiftStart, ds.shiftEnd), 2) AS utilizationPercent,
  d.status AS driverStatus,
  ds.status AS shiftStatus
FROM Drivers d
JOIN Employees e ON d.employeeId = e.employeeId
JOIN Users u ON e.userId = u.userId
JOIN Branches b ON d.branchId = b.branchId
LEFT JOIN DriverShifts ds ON d.driverId = ds.driverId
LEFT JOIN DriverWorkload dw ON d.driverId = dw.driverId AND ds.date = dw.date
WHERE ds.date IS NOT NULL;

-- View: Vehicle Availability
CREATE OR REPLACE VIEW v_VehicleAvailability AS
SELECT
  v.vehicleId,
  v.licensePlate,
  v.model,
  v.branchId,
  b.branchName,
  vs.date,
  vs.shiftStart,
  vs.shiftEnd,
  v.status AS vehicleStatus,
  vs.status AS shiftStatus,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM VehicleMaintenance vm 
      WHERE vm.vehicleId = v.vehicleId 
      AND vm.status IN ('SCHEDULED','IN_PROGRESS')
      AND vs.date BETWEEN DATE(vm.scheduledStart) AND DATE(vm.scheduledEnd)
    ) THEN TRUE
    ELSE FALSE
  END AS hasMaintenance
FROM Vehicles v
JOIN Branches b ON v.branchId = b.branchId
LEFT JOIN VehicleShifts vs ON v.vehicleId = vs.vehicleId
WHERE vs.date IS NOT NULL;

-- View: Pending Trips (Chuyến chờ gán)
CREATE OR REPLACE VIEW v_PendingTrips AS
SELECT
  t.tripId,
  t.bookingId,
  b.customerId,
  c.fullName AS customerName,
  c.phone AS customerPhone,
  t.startLocation,
  t.endLocation,
  t.startTime,
  t.status AS tripStatus,
  b.status AS bookingStatus,
  b.branchId,
  br.branchName,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM Invoices i 
      WHERE i.bookingId = b.bookingId 
      AND i.isDeposit = TRUE 
      AND i.paymentStatus = 'PAID'
      AND i.approvedBy IS NOT NULL
    ) THEN 'APPROVED'
    WHEN b.depositWaived = TRUE THEN 'WAIVED'
    ELSE 'PENDING'
  END AS depositStatus,
  CASE 
    WHEN t.startTime < NOW() THEN CONCAT('Trễ ', TIMESTAMPDIFF(MINUTE, t.startTime, NOW()), 'p')
    ELSE CONCAT('Còn ', TIMESTAMPDIFF(MINUTE, NOW(), t.startTime), 'p')
  END AS timeStatus,
  CASE 
    WHEN NOT EXISTS (SELECT 1 FROM TripDrivers td WHERE td.tripId = t.tripId) THEN TRUE
    ELSE FALSE
  END AS needsAssignment
FROM Trips t
JOIN Bookings b ON t.bookingId = b.bookingId
JOIN Customers c ON b.customerId = c.customerId
JOIN Branches br ON b.branchId = br.branchId
WHERE t.status = 'PENDING'
  AND b.status IN ('CONFIRMED', 'IN_PROGRESS');

-- View: Active Conflicts (Xung đột chưa xử lý)
CREATE OR REPLACE VIEW v_ActiveConflicts AS
SELECT
  sc.conflictId,
  sc.conflictType,
  sc.driverId,
  CASE WHEN sc.driverId IS NOT NULL THEN u.fullName ELSE NULL END AS driverName,
  sc.vehicleId,
  CASE WHEN sc.vehicleId IS NOT NULL THEN v.licensePlate ELSE NULL END AS vehiclePlate,
  sc.tripId1,
  sc.tripId2,
  sc.conflictTime,
  sc.description,
  sc.detectedAt,
  sc.status
FROM ScheduleConflicts sc
LEFT JOIN Drivers d ON sc.driverId = d.driverId
LEFT JOIN Employees e ON d.employeeId = e.employeeId
LEFT JOIN Users u ON e.userId = u.userId
LEFT JOIN Vehicles v ON sc.vehicleId = v.vehicleId
WHERE sc.status IN ('DETECTED', 'ACKNOWLEDGED');

-- ==========================================================
-- 10) Sample Data
-- ==========================================================

-- Sample: DriverShifts (Ca làm việc mẫu)
INSERT INTO DriverShifts (shiftId, driverId, date, shiftStart, shiftEnd, breakStart, breakEnd, status) VALUES
(1, 1, '2025-11-19', '08:00:00', '17:00:00', '12:00:00', '13:00:00', 'SCHEDULED'),
(2, 2, '2025-11-19', '08:00:00', '17:00:00', '12:00:00', '13:00:00', 'SCHEDULED'),
(3, 3, '2025-11-19', '08:00:00', '17:00:00', '12:00:00', '13:00:00', 'SCHEDULED'),
(4, 4, '2025-11-19', '13:00:00', '22:00:00', '17:00:00', '18:00:00', 'SCHEDULED'),
(5, 5, '2025-11-19', '08:00:00', '17:00:00', '12:00:00', '13:00:00', 'SCHEDULED')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- Sample: VehicleShifts
INSERT INTO VehicleShifts (shiftId, vehicleId, date, shiftStart, shiftEnd, status) VALUES
(1, 1, '2025-11-19', '07:00:00', '22:00:00', 'AVAILABLE'),
(2, 2, '2025-11-19', '07:00:00', '22:00:00', 'AVAILABLE'),
(3, 3, '2025-11-19', '07:00:00', '22:00:00', 'AVAILABLE'),
(4, 4, '2025-11-19', '07:00:00', '22:00:00', 'AVAILABLE'),
(5, 5, '2025-11-19', '07:00:00', '22:00:00', 'AVAILABLE'),
(6, 7, '2025-11-19', '07:00:00', '22:00:00', 'MAINTENANCE')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- Sample: VehicleMaintenance
INSERT INTO VehicleMaintenance (maintenanceId, vehicleId, maintenanceType, description, scheduledStart, scheduledEnd, status, cost) VALUES
(1, 7, 'PERIODIC_MAINTENANCE', 'Bảo dưỡng định kỳ 10,000km', '2025-11-19 08:00:00', '2025-11-19 17:00:00', 'IN_PROGRESS', 5000000.00),
(2, 3, 'INSPECTION', 'Đăng kiểm định kỳ', '2025-11-25 08:00:00', '2025-11-25 12:00:00', 'SCHEDULED', 500000.00)
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- Sample: ScheduleConflicts
INSERT INTO ScheduleConflicts (conflictId, conflictType, driverId, tripId1, tripId2, conflictTime, description, status) VALUES
(1, 'INSUFFICIENT_REST', 1, 1, 3, '2025-11-01 08:30:00', 'Tài xế A có khoảng nghỉ < 30 phút giữa Trip 1 và Trip 3', 'DETECTED')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- ==========================================================
-- 11) Cập nhật Trip status hiện có
-- ==========================================================
-- Cập nhật các trip chưa gán thành PENDING
UPDATE Trips t
SET t.status = 'PENDING'
WHERE t.status = 'SCHEDULED'
  AND NOT EXISTS (SELECT 1 FROM TripDrivers td WHERE td.tripId = t.tripId);

-- Cập nhật các trip đã gán thành ASSIGNED
UPDATE Trips t
SET t.status = 'ASSIGNED'
WHERE t.status = 'SCHEDULED'
  AND EXISTS (SELECT 1 FROM TripDrivers td WHERE td.tripId = t.tripId)
  AND t.startTime > NOW();

-- Cập nhật các trip đang chạy thành IN_PROGRESS
UPDATE Trips t
SET t.status = 'IN_PROGRESS'
WHERE t.status IN ('SCHEDULED', 'ONGOING', 'ASSIGNED')
  AND t.startTime <= NOW()
  AND (t.endTime IS NULL OR t.endTime > NOW());

-- ==========================================================
-- End of Critical Additions
-- ==========================================================

SELECT 'Module 5 Critical Additions completed successfully!' AS Status;
