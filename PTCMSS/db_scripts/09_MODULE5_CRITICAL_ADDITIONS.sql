-- ==========================================================
-- MODULE 5 CRITICAL ADDITIONS
-- Bổ sung các bảng và cột THIẾU để hoàn thiện Module 5
-- Priority: P0 - CRITICAL
-- ==========================================================

USE ptcmss_db;

-- ==========================================================
-- 1) DriverShifts - Ca làm việc tài xế (CRITICAL)
-- ==========================================================
CREATE TABLE IF NOT EXISTS DriverShifts (
  shiftId INT AUTO_INCREMENT PRIMARY KEY,
  driverId INT NOT NULL,
  shiftDate DATE NOT NULL,
  shiftType ENUM('MORNING','AFTERNOON','NIGHT','FULL_DAY') NOT NULL,
  startTime TIME NOT NULL,
  endTime TIME NOT NULL,
  status ENUM('SCHEDULED','ACTIVE','COMPLETED','CANCELLED') DEFAULT 'SCHEDULED',
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_ds_driver FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  UNIQUE KEY UK_DriverShifts (driverId, shiftDate, shiftType),
  CHECK (startTime < endTime)
) ENGINE=InnoDB;

CREATE INDEX IX_DriverShifts_Date ON DriverShifts(shiftDate);
CREATE INDEX IX_DriverShifts_Driver_Date ON DriverShifts(driverId, shiftDate);
CREATE INDEX IX_DriverShifts_Status ON DriverShifts(status);

-- ==========================================================
-- 2) VehicleMaintenanceSchedule - Lịch bảo dưỡng xe (CRITICAL)
-- ==========================================================
CREATE TABLE IF NOT EXISTS VehicleMaintenanceSchedule (
  maintenanceId INT AUTO_INCREMENT PRIMARY KEY,
  vehicleId INT NOT NULL,
  maintenanceType VARCHAR(50) NOT NULL,
  scheduledStartTime DATETIME NOT NULL,
  scheduledEndTime DATETIME NOT NULL,
  actualStartTime DATETIME NULL,
  actualEndTime DATETIME NULL,
  status ENUM('SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'SCHEDULED',
  description VARCHAR(500),
  cost DECIMAL(10,2),
  performedBy VARCHAR(100),
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_vms_vehicle FOREIGN KEY (vehicleId) REFERENCES Vehicles(vehicleId),
  CHECK (scheduledStartTime < scheduledEndTime)
) ENGINE=InnoDB;

CREATE INDEX IX_VehicleMaintenance_Vehicle ON VehicleMaintenanceSchedule(vehicleId);
CREATE INDEX IX_VehicleMaintenance_Status ON VehicleMaintenanceSchedule(status);
CREATE INDEX IX_VehicleMaintenance_Time ON VehicleMaintenanceSchedule(scheduledStartTime, scheduledEndTime);

-- ==========================================================
-- 3) DepositApprovals - Duyệt cọc (CRITICAL)
-- ==========================================================
CREATE TABLE IF NOT EXISTS DepositApprovals (
  approvalId INT AUTO_INCREMENT PRIMARY KEY,
  bookingId INT NOT NULL,
  depositAmount DECIMAL(12,2) NOT NULL,
  isExempted BOOLEAN DEFAULT FALSE,
  exemptionReason VARCHAR(500),
  approvedBy INT NULL,
  approvedAt DATETIME NULL,
  status ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_da_booking FOREIGN KEY (bookingId) REFERENCES Bookings(bookingId),
  CONSTRAINT fk_da_approver FOREIGN KEY (approvedBy) REFERENCES Employees(employeeId),
  UNIQUE KEY UK_DepositApprovals (bookingId)
) ENGINE=InnoDB;

CREATE INDEX IX_DepositApprovals_Status ON DepositApprovals(status);
CREATE INDEX IX_DepositApprovals_Booking ON DepositApprovals(bookingId);

-- ==========================================================
-- 4) DispatchNotifications - Thông báo điều phối (CRITICAL)
-- ==========================================================
CREATE TABLE IF NOT EXISTS Di