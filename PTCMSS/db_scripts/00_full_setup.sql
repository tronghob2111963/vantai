-- ==========================================================
-- PassengerTransportDB Full Setup Script
-- Includes schema creation, triggers, view, and seed data
-- ==========================================================

-- 0) Database & charset
CREATE DATABASE IF NOT EXISTS ptcmss_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE ptcmss_db;

-- ==========================================================
-- 1) Roles & Users
-- ==========================================================
CREATE TABLE IF NOT EXISTS Roles (
  roleId INT AUTO_INCREMENT PRIMARY KEY,
  roleName VARCHAR(50) NOT NULL,
  description VARCHAR(255),
  status ENUM('ACTIVE','INACTIVE','SUSPENDED') DEFAULT 'ACTIVE'
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Users (
  userId INT AUTO_INCREMENT PRIMARY KEY,
  roleId INT NOT NULL,
  fullName VARCHAR(100) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  passwordHash VARCHAR(255) NOT NULL,
  email VARCHAR(100),
  phone VARCHAR(20),
  avatar VARCHAR(255),
  address VARCHAR(255),
  status ENUM('ACTIVE','INACTIVE','SUSPENDED') DEFAULT 'ACTIVE',
  email_verified BOOLEAN DEFAULT FALSE,
  verification_token VARCHAR(64),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_role FOREIGN KEY (roleId) REFERENCES Roles(roleId)
) ENGINE=InnoDB;

CREATE INDEX IX_Users_RoleId ON Users(roleId);

-- ==========================================================
-- 2) Branches
-- ==========================================================
CREATE TABLE IF NOT EXISTS Branches (
  branchId INT AUTO_INCREMENT PRIMARY KEY,
  branchName VARCHAR(100) NOT NULL,
  location VARCHAR(255),
  managerId INT NULL,
  status ENUM('ACTIVE', 'INACTIVE', 'UNDERREVIEW', 'CLOSED') DEFAULT 'ACTIVE',
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==========================================================
-- 3) Employees & Drivers
-- ==========================================================
CREATE TABLE IF NOT EXISTS Employees (
  employeeId INT AUTO_INCREMENT PRIMARY KEY,
  userId INT NOT NULL,
  branchId INT NOT NULL,
  roleId INT NOT NULL,
  status ENUM('ACTIVE','INACTIVE','ONLEAVE') DEFAULT 'ACTIVE',
  CONSTRAINT fk_emp_user   FOREIGN KEY (userId)  REFERENCES Users(userId),
  CONSTRAINT fk_emp_branch FOREIGN KEY (branchId) REFERENCES Branches(branchId),
  CONSTRAINT fk_emp_role   FOREIGN KEY (roleId)  REFERENCES Roles(roleId)
) ENGINE=InnoDB;

CREATE INDEX IX_Employees_BranchId ON Employees(branchId);

ALTER TABLE Branches
  ADD CONSTRAINT FK_Branches_Manager
  FOREIGN KEY (managerId) REFERENCES Employees(employeeId);

CREATE TABLE IF NOT EXISTS Drivers (
  driverId INT AUTO_INCREMENT PRIMARY KEY,
  employeeId INT NOT NULL UNIQUE,
  branchId INT NOT NULL,
  licenseNumber VARCHAR(50) NOT NULL UNIQUE,
  licenseClass VARCHAR(10),
  licenseExpiry DATE,
  healthCheckDate DATE,
  rating DECIMAL(3,2) DEFAULT 5.00 CHECK (rating >= 0 AND rating <= 5),
  averageRating DECIMAL(3,2) DEFAULT 5.00,
  totalRatings INT DEFAULT 0,
  priorityLevel INT DEFAULT 1 CHECK (priorityLevel BETWEEN 1 AND 10),
  note VARCHAR(255),
  status ENUM('AVAILABLE','ONTRIP','INACTIVE') DEFAULT 'AVAILABLE',
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_drivers_emp    FOREIGN KEY (employeeId) REFERENCES Employees(employeeId),
  CONSTRAINT fk_drivers_branch FOREIGN KEY (branchId)   REFERENCES Branches(branchId)
) ENGINE=InnoDB;

CREATE INDEX IX_Drivers_BranchId ON Drivers(branchId);

CREATE TABLE IF NOT EXISTS DriverDayOff (
  dayOffId INT AUTO_INCREMENT PRIMARY KEY,
  driverId INT NOT NULL,
  startDate DATE NOT NULL,
  endDate DATE NOT NULL,
  reason VARCHAR(255),
  approvedBy INT NULL,
  status ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_doff_driver  FOREIGN KEY (driverId)  REFERENCES Drivers(driverId),
  CONSTRAINT fk_doff_approve FOREIGN KEY (approvedBy) REFERENCES Employees(employeeId),
  CHECK (startDate <= endDate)
) ENGINE=InnoDB;

CREATE INDEX IX_DriverDayOff_DriverId ON DriverDayOff(driverId);

-- ==========================================================
-- 4) Customers
-- ==========================================================
CREATE TABLE IF NOT EXISTS Customers (
  customerId INT AUTO_INCREMENT PRIMARY KEY,
  fullName VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  address VARCHAR(255),
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  createdBy INT NULL,
  status ENUM('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
  CONSTRAINT fk_cust_createdBy FOREIGN KEY (createdBy) REFERENCES Employees(employeeId)
) ENGINE=InnoDB;

CREATE INDEX IX_Customers_CreatedBy ON Customers(createdBy);

-- ==========================================================
-- 5) Vehicle Category & Vehicles
-- ==========================================================
CREATE TABLE IF NOT EXISTS VehicleCategoryPricing (
  categoryId INT AUTO_INCREMENT PRIMARY KEY,
  categoryName VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  baseFare DECIMAL(10,2),
  pricePerKm DECIMAL(10,2),
  highwayFee DECIMAL(10,2),
  fixedCosts DECIMAL(10,2),
  effectiveDate DATE DEFAULT (CURRENT_DATE),
  status ENUM('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Vehicles (
  vehicleId INT AUTO_INCREMENT PRIMARY KEY,
  categoryId INT NOT NULL,
  branchId INT NOT NULL,
  licensePlate VARCHAR(20) NOT NULL UNIQUE,
  model VARCHAR(100),
  brand VARCHAR(100),
  capacity INT,
  productionYear INT CHECK (productionYear >= 1980),
  registrationDate DATE,
  inspectionExpiry DATE,
  insuranceExpiry DATE,
  odometer BIGINT,
  status ENUM('AVAILABLE','INUSE','MAINTENANCE','INACTIVE') DEFAULT 'AVAILABLE',
  CONSTRAINT fk_veh_cat    FOREIGN KEY (categoryId) REFERENCES VehicleCategoryPricing(categoryId),
  CONSTRAINT fk_veh_branch FOREIGN KEY (branchId)   REFERENCES Branches(branchId)
) ENGINE=InnoDB;

CREATE INDEX IX_Vehicles_BranchId ON Vehicles(branchId);

-- ==========================================================
-- 6) Bookings & Hire Types
-- ==========================================================
CREATE TABLE IF NOT EXISTS HireTypes (
  hireTypeId INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(30) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  isActive BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Bookings (
  bookingId INT AUTO_INCREMENT PRIMARY KEY,
  customerId INT NOT NULL,
  branchId INT NOT NULL,
  consultantId INT NULL,
  hireTypeId INT NULL,
  useHighway BOOLEAN NULL,
  bookingDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  estimatedCost DECIMAL(12,2),
  depositAmount DECIMAL(12,2) DEFAULT 0,
  totalCost DECIMAL(12,2) DEFAULT 0,
  depositWaived BOOLEAN DEFAULT FALSE,
  depositWaivedBy INT NULL,
  depositWaivedReason VARCHAR(255) NULL,
  depositWaivedAt DATETIME NULL,
  status ENUM('PENDING','QUOTATION_SENT','CONFIRMED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'PENDING',
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_book_cust    FOREIGN KEY (customerId)  REFERENCES Customers(customerId),
  CONSTRAINT fk_book_branch  FOREIGN KEY (branchId)    REFERENCES Branches(branchId),
  CONSTRAINT fk_book_cons    FOREIGN KEY (consultantId)REFERENCES Employees(employeeId),
  CONSTRAINT fk_book_hire    FOREIGN KEY (hireTypeId)  REFERENCES HireTypes(hireTypeId),
  CONSTRAINT fk_book_depositWaiver FOREIGN KEY (depositWaivedBy) REFERENCES Employees(employeeId)
) ENGINE=InnoDB;

CREATE INDEX IX_Bookings_BranchId ON Bookings(branchId);
CREATE INDEX IX_Bookings_Customer_Status ON Bookings(customerId, status);
CREATE INDEX IX_Bookings_HireType ON Bookings(hireTypeId);

CREATE TABLE IF NOT EXISTS BookingVehicleDetails (
  bookingId INT NOT NULL,
  vehicleCategoryId INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (bookingId, vehicleCategoryId),
  CONSTRAINT fk_bvd_booking  FOREIGN KEY (bookingId) REFERENCES Bookings(bookingId),
  CONSTRAINT fk_bvd_category FOREIGN KEY (vehicleCategoryId) REFERENCES VehicleCategoryPricing(categoryId)
) ENGINE=InnoDB;

-- ==========================================================
-- 7) Trips
-- ==========================================================
CREATE TABLE IF NOT EXISTS Trips (
  tripId INT AUTO_INCREMENT PRIMARY KEY,
  bookingId INT NOT NULL,
  useHighway BOOLEAN NULL,
  startTime DATETIME NULL,
  endTime DATETIME NULL,
  startLocation VARCHAR(255),
  endLocation VARCHAR(255),
  incidentalCosts DECIMAL(10,2) DEFAULT 0,
  status ENUM('PENDING','ASSIGNED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'PENDING',
  CONSTRAINT fk_trip_booking FOREIGN KEY (bookingId) REFERENCES Bookings(bookingId),
  CHECK ((startTime IS NULL OR endTime IS NULL) OR (startTime < endTime))
) ENGINE=InnoDB;

CREATE INDEX IX_Trips_BookingId ON Trips(bookingId);
CREATE INDEX IX_Trips_Status_Start ON Trips(status, startTime);
CREATE INDEX IX_Trips_Branch_Status_Time ON Trips(status, startTime);

CREATE TABLE IF NOT EXISTS TripVehicles (
  tripVehicleId INT AUTO_INCREMENT PRIMARY KEY,
  tripId INT NOT NULL,
  vehicleId INT NOT NULL,
  assignedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  note VARCHAR(255),
  CONSTRAINT fk_tv_trip    FOREIGN KEY (tripId)   REFERENCES Trips(tripId),
  CONSTRAINT fk_tv_vehicle FOREIGN KEY (vehicleId) REFERENCES Vehicles(vehicleId),
  CONSTRAINT UQ_TripVehicles UNIQUE (tripId, vehicleId)
) ENGINE=InnoDB;

CREATE INDEX IX_TripVehicles_TripId ON TripVehicles(tripId);
CREATE INDEX IX_TripVehicles_Vehicle ON TripVehicles(vehicleId, tripId);

CREATE TABLE IF NOT EXISTS TripDrivers (
  tripId INT NOT NULL,
  driverId INT NOT NULL,
  driverRole VARCHAR(50) DEFAULT 'Main Driver',
  startTime DATETIME NULL,
  endTime DATETIME NULL,
  note VARCHAR(255),
  PRIMARY KEY (tripId, driverId),
  CONSTRAINT fk_td_trip   FOREIGN KEY (tripId)   REFERENCES Trips(tripId),
  CONSTRAINT fk_td_driver FOREIGN KEY (driverId) REFERENCES Drivers(driverId),
  CHECK ((startTime IS NULL OR endTime IS NULL) OR (startTime < endTime))
) ENGINE=InnoDB;

CREATE INDEX IX_TripDrivers_Driver ON TripDrivers(driverId, tripId);

-- ==========================================================
-- 8) MODULE 5 ADDITIONS - Dispatch Management
-- ==========================================================

-- 8.1) TripAssignmentHistory (Audit Log cho phân công)
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

CREATE INDEX IX_TripAssignmentHistory_TripId ON TripAssignmentHistory(tripId);
CREATE INDEX IX_TripAssignmentHistory_CreatedAt ON TripAssignmentHistory(createdAt);
CREATE INDEX IX_TripAssignmentHistory_DriverId ON TripAssignmentHistory(driverId);

-- 8.2) TripRatings (Đánh giá tài xế sau chuyến đi)
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

CREATE INDEX IX_TripRatings_DriverId ON TripRatings(driverId);
CREATE INDEX IX_TripRatings_RatedAt ON TripRatings(ratedAt);

-- 8.3) DriverWorkload (Tính toán workload và fairness score)
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

CREATE INDEX IX_DriverWorkload_Date ON DriverWorkload(date);
CREATE INDEX IX_DriverWorkload_Score ON DriverWorkload(fairnessScore);

-- 8.4) DriverShifts (Ca làm việc tài xế)
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

-- 8.5) VehicleShifts (Ca hoạt động xe)
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

-- 8.6) VehicleMaintenance (Lịch bảo trì xe)
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

-- 8.7) ScheduleConflicts (Phát hiện xung đột lịch)
CREATE TABLE IF NOT EXISTS ScheduleConflicts (
  conflictId INT AUTO_INCREMENT PRIMARY KEY,
  conflictType ENUM('DRIVER_OVERLAP','VEHICLE_OVERLAP','EXCEED_HOURS') NOT NULL,
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

-- 8.9) ExpenseAttachments (Đính kèm chứng từ chi phí)
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
-- 9) Financial Tables
-- ==========================================================
CREATE TABLE IF NOT EXISTS Invoices (
  invoiceId INT AUTO_INCREMENT PRIMARY KEY,
  branchId INT NOT NULL,
  bookingId INT NULL,
  customerId INT NULL,
  type ENUM('Income','Expense') NOT NULL,
  costType VARCHAR(50) NULL,
  isDeposit BOOLEAN NOT NULL DEFAULT FALSE,
  amount DECIMAL(18,2) NOT NULL CHECK (amount > 0),
  paymentMethod VARCHAR(50),
  paymentStatus ENUM('UNPAID','PAID','REFUNDED') DEFAULT 'UNPAID',
  status ENUM('ACTIVE','CANCELLED') DEFAULT 'ACTIVE',
  invoiceDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  img VARCHAR(255),
  note VARCHAR(255),
  requestedBy INT NULL,
  createdBy INT NULL,
  approvedBy INT NULL,
  approvedAt DATETIME NULL,
  CONSTRAINT fk_inv_branch     FOREIGN KEY (branchId)   REFERENCES Branches(branchId),
  CONSTRAINT fk_inv_booking    FOREIGN KEY (bookingId)  REFERENCES Bookings(bookingId),
  CONSTRAINT fk_inv_customer   FOREIGN KEY (customerId) REFERENCES Customers(customerId),
  CONSTRAINT fk_inv_reqDriver  FOREIGN KEY (requestedBy) REFERENCES Drivers(driverId),
  CONSTRAINT fk_inv_createdBy  FOREIGN KEY (createdBy)  REFERENCES Employees(employeeId),
  CONSTRAINT fk_inv_approvedBy FOREIGN KEY (approvedBy) REFERENCES Employees(employeeId)
) ENGINE=InnoDB;

CREATE INDEX IX_Invoices_Branch         ON Invoices(branchId, invoiceDate);
CREATE INDEX IX_Invoices_Type_Status    ON Invoices(type, status);
CREATE INDEX IX_Invoices_Booking        ON Invoices(bookingId);
CREATE INDEX IX_Invoices_Customer       ON Invoices(customerId);
CREATE INDEX IX_Invoices_PaymentStatus  ON Invoices(paymentStatus);

CREATE TABLE IF NOT EXISTS Notifications (
  notificationId INT AUTO_INCREMENT PRIMARY KEY,
  userId INT NOT NULL,
  title VARCHAR(100),
  message VARCHAR(500),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  isRead BOOLEAN DEFAULT FALSE,
  CONSTRAINT fk_notif_user FOREIGN KEY (userId) REFERENCES Users(userId)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS AccountsReceivable (
  arId INT AUTO_INCREMENT PRIMARY KEY,
  customerId INT NOT NULL,
  bookingId INT NULL,
  invoiceId INT NULL,
  totalAmount DECIMAL(18,2),
  paidAmount DECIMAL(18,2),
  remainingAmount DECIMAL(18,2) AS (totalAmount - paidAmount) STORED,
  dueDate DATE,
  lastPaymentDate DATE,
  status ENUM('UNPAID','PARTIALLYPAID','PAID') DEFAULT 'UNPAID',
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ar_customer FOREIGN KEY (customerId) REFERENCES Customers(customerId),
  CONSTRAINT fk_ar_booking  FOREIGN KEY (bookingId)  REFERENCES Bookings(bookingId),
  CONSTRAINT fk_ar_invoice  FOREIGN KEY (invoiceId)  REFERENCES Invoices(invoiceId)
) ENGINE=InnoDB;

CREATE INDEX IX_AR_Status_DueDate ON AccountsReceivable(status, dueDate);

-- ==========================================================
-- 9) System Settings, Triggers, Views
-- ==========================================================
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
  status ENUM('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
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

-- View for Driver Ratings Summary (Module 5)
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

-- View for Driver Workload Summary (Module 5)
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

-- ===========================================================
-- 11) Seed Data
-- ===========================================================
INSERT INTO Roles (roleId, roleName, description, status) VALUES
(1, 'Admin', 'Quản trị viên hệ thống', 'ACTIVE'),
(2, 'Manager', 'Quản lý chi nhánh', 'ACTIVE'),
(3, 'Consultant', 'Điều hành/Tư vấn', 'ACTIVE'),
(4, 'Driver', 'Tài xế', 'ACTIVE'),
(5, 'Accountant', 'Kế toán', 'ACTIVE')
ON DUPLICATE KEY UPDATE roleName = VALUES(roleName), description = VALUES(description), status = VALUES(status);

INSERT INTO VehicleCategoryPricing (categoryId, categoryName, description, baseFare, pricePerKm, highwayFee, fixedCosts, status) VALUES
(1, 'Xe 9 chỗ (Limousine)', 'DCar/Solati Limousine', 800000.00, 15000.00, 100000.00, 0.00, 'ACTIVE'),
(2, 'Xe 16 chỗ', 'Ford Transit, Mercedes Sprinter', 1200000.00, 18000.00, 120000.00, 0.00, 'ACTIVE'),
(3, 'Xe 29 chỗ', 'Hyundai County, Samco Isuzu', 1800000.00, 22000.00, 150000.00, 0.00, 'ACTIVE'),
(4, 'Xe 45 chỗ', 'Hyundai Universe', 2500000.00, 28000.00, 200000.00, 0.00, 'ACTIVE'),
(5, 'Xe giường nằm (40 chỗ)', 'Xe giường nằm Thaco/Hyundai', 3000000.00, 30000.00, 250000.00, 0.00, 'ACTIVE')
ON DUPLICATE KEY UPDATE categoryName = VALUES(categoryName), description = VALUES(description);

INSERT INTO HireTypes (hireTypeId, code, name, description, isActive) VALUES
(1, 'ONE_WAY', 'Thuê 1 chiều', 'Thuê xe đi 1 chiều', TRUE),
(2, 'ROUND_TRIP', 'Thuê 2 chiều (trong ngày)', 'Thuê xe đi và về trong ngày', TRUE),
(3, 'MULTI_DAY', 'Thuê nhiều ngày', 'Thuê xe theo gói nhiều ngày', TRUE),
(4, 'PERIODIC', 'Thuê định kỳ', 'Thuê lặp lại (đưa đón nhân viên, học sinh)', TRUE),
(5, 'AIRPORT_TRANSFER', 'Đưa/đón sân bay', 'Gói đưa đón sân bay 1 chiều', TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), isActive = VALUES(isActive);

INSERT INTO Branches (branchId, branchName, location, managerId, status) VALUES
(1, 'Chi nhánh Hà Nội', '123 Láng Hạ, Đống Đa, Hà Nội', NULL, 'ACTIVE'),
(2, 'Chi nhánh Đà Nẵng', '456 Nguyễn Văn Linh, Hải Châu, Đà Nẵng', NULL, 'ACTIVE'),
(3, 'Chi nhánh TP. HCM', '789 Võ Thị Sáu, Quận 3, TP. HCM', NULL, 'ACTIVE'),
(4, 'Chi nhánh Hải Phòng', '10 Lê Hồng Phong, Ngô Quyền, Hải Phòng', NULL, 'INACTIVE'),
(5, 'Chi nhánh Quảng Ninh', '55 Trần Hưng Đạo, Hạ Long, Quảng Ninh', NULL, 'ACTIVE')
ON DUPLICATE KEY UPDATE branchName = VALUES(branchName), location = VALUES(location), status = VALUES(status);

INSERT INTO Users (userId, roleId, fullName, username, passwordHash, email, phone, status) VALUES
(1, 1, 'Admin Tổng', 'admin', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'admin@ptcmss.com', '0900000001', 'ACTIVE'),
(2, 2, 'Quản Lý Hà Nội', 'manager_hn', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'manager.hn@ptcmss.com', '0900000002', 'ACTIVE'),
(3, 2, 'Quản Lý Đà Nẵng', 'manager_dn', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'manager.dn@ptcmss.com', '0900000003', 'ACTIVE'),
(4, 2, 'Quản Lý HCM', 'manager_hcm', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'manager.hcm@ptcmss.com', '0900000004', 'ACTIVE'),
(5, 3, 'Điều Hành Viên 1 (HN)', 'consultant_hn1', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'c1.hn@ptcmss.com', '0900000005', 'ACTIVE'),
(6, 3, 'Điều Hành Viên 2 (HN)', 'consultant_hn2', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'c2.hn@ptcmss.com', '0900000006', 'ACTIVE'),
(7, 5, 'Kế Toán 1 (HN)', 'accountant_hn1', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'k1.hn@ptcmss.com', '0900000007', 'ACTIVE'),
(8, 4, 'Tài Xế Nguyễn Văn A', 'driver_a', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'driver.a@ptcmss.com', '0912345671', 'ACTIVE'),
(9, 4, 'Tài Xế Trần Văn B', 'driver_b', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'driver.b@ptcmss.com', '0912345672', 'ACTIVE'),
(10, 4, 'Tài Xế Lê Hữu C', 'driver_c', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'driver.c@ptcmss.com', '0912345673', 'ACTIVE'),
(11, 4, 'Tài Xế Phạm Đình D', 'driver_d', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'driver.d@ptcmss.com', '0912345674', 'ACTIVE'),
(12, 4, 'Tài Xế Huỳnh Tấn E', 'driver_e', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'driver.e@ptcmss.com', '0912345675', 'ACTIVE'),
(13, 4, 'Tài Xế Vũ Minh F', 'driver_f', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'driver.f@ptcmss.com', '0912345676', 'ACTIVE'),
(14, 4, 'Tài Xế Đặng Văn G', 'driver_g', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'driver.g@ptcmss.com', '0912345677', 'ACTIVE')
ON DUPLICATE KEY UPDATE fullName = VALUES(fullName), email = VALUES(email), phone = VALUES(phone), status = VALUES(status);

INSERT INTO Employees (employeeId, userId, branchId, roleId, status) VALUES
(1, 1, 1, 1, 'ACTIVE'),
(2, 2, 1, 2, 'ACTIVE'),
(3, 3, 2, 2, 'ACTIVE'),
(4, 4, 3, 2, 'ACTIVE'),
(5, 5, 1, 3, 'ACTIVE'),
(6, 6, 1, 3, 'ACTIVE'),
(7, 7, 1, 5, 'ACTIVE'),
(8, 8, 1, 4, 'ACTIVE'),
(9, 9, 1, 4, 'ACTIVE'),
(10, 10, 2, 4, 'ACTIVE'),
(11, 11, 3, 4, 'ACTIVE'),
(12, 12, 1, 4, 'ACTIVE'),
(13, 13, 2, 4, 'ACTIVE'),
(14, 14, 3, 4, 'ACTIVE')
ON DUPLICATE KEY UPDATE branchId = VALUES(branchId), roleId = VALUES(roleId), status = VALUES(status);

UPDATE Branches SET managerId = 2 WHERE branchId = 1;
UPDATE Branches SET managerId = 3 WHERE branchId = 2;
UPDATE Branches SET managerId = 4 WHERE branchId = 3;
UPDATE Branches SET managerId = 2 WHERE branchId = 5;

INSERT INTO Drivers (driverId, employeeId, branchId, licenseNumber, licenseClass, licenseExpiry, healthCheckDate, status) VALUES
(1, 8, 1, 'HN12345', 'D', '2028-12-31', '2025-06-01', 'AVAILABLE'),
(2, 9, 1, 'HN67890', 'E', '2027-10-10', '2025-05-01', 'AVAILABLE'),
(3, 10, 2, 'DN55555', 'D', '2029-01-15', '2025-07-01', 'AVAILABLE'),
(4, 11, 3, 'HCM88888', 'E', '2026-05-20', '2025-03-01', 'ONTRIP'),
(5, 12, 1, 'HN45678', 'D', '2028-02-14', '2025-08-01', 'AVAILABLE'),
(6, 13, 2, 'DN11111', 'E', '2027-11-30', '2025-09-10', 'INACTIVE'),
(7, 14, 3, 'HCM22222', 'D', '2029-07-07', '2025-10-01', 'AVAILABLE')
ON DUPLICATE KEY UPDATE branchId = VALUES(branchId), status = VALUES(status);

INSERT INTO Customers (customerId, fullName, phone, email, address, createdBy, status) VALUES
(1, 'Công ty TNHH ABC (KCN Thăng Long)', '0987654321', 'contact@abc.com', 'KCN Thăng Long, Đông Anh, Hà Nội', 5, 'ACTIVE'),
(2, 'Đoàn du lịch Hướng Việt', '0987654322', 'info@huongviet.vn', 'Hoàn Kiếm, Hà Nội', 6, 'ACTIVE'),
(3, 'Công ty CP XYZ (Đà Nẵng)', '0987654323', 'hr@xyz.com', 'Hải Châu, Đà Nẵng', 5, 'ACTIVE'),
(4, 'Gia đình ông Trần Văn Hùng', '0987654324', 'hung.tran@gmail.com', 'Quận 7, TP. HCM', 6, 'ACTIVE'),
(5, 'Trường quốc tế Vinschool', '0987654325', 'school@vinschool.edu.vn', 'Times City, Hà Nội', 5, 'ACTIVE')
ON DUPLICATE KEY UPDATE phone = VALUES(phone), email = VALUES(email), address = VALUES(address), status = VALUES(status);

INSERT INTO Vehicles (vehicleId, categoryId, branchId, licensePlate, model, capacity, productionYear, registrationDate, inspectionExpiry, status) VALUES
(1, 2, 1, '29A-111.11', 'Ford Transit', 16, 2022, '2022-01-01', '2026-06-30', 'AVAILABLE'),
(2, 1, 1, '29A-222.22', 'DCar Limousine', 9, 2023, '2023-05-01', '2026-04-30', 'AVAILABLE'),
(3, 3, 1, '29A-333.33', 'Samco Isuzu', 29, 2021, '2021-03-01', '2025-08-30', 'AVAILABLE'),
(4, 4, 2, '43B-444.44', 'Hyundai Universe', 45, 2023, '2023-06-01', '2025-11-30', 'AVAILABLE'),
(5, 2, 3, '51C-555.55', 'Ford Transit', 16, 2022, '2022-07-01', '2026-12-31', 'INUSE'),
(6, 3, 1, '29A-666.66', 'Hyundai County', 29, 2022, '2022-09-01', '2026-02-28', 'AVAILABLE'),
(7, 5, 2, '43B-777.77', 'Thaco Mobihome', 40, 2023, '2023-08-15', '2025-02-14', 'MAINTENANCE')
ON DUPLICATE KEY UPDATE branchId = VALUES(branchId), status = VALUES(status);

INSERT INTO Bookings (bookingId, customerId, branchId, consultantId, hireTypeId, useHighway, estimatedCost, depositAmount, totalCost, status, note) VALUES
(1, 2, 1, 5, 2, TRUE, 3500000.00, 1000000.00, 3800000.00, 'COMPLETED', 'Đoàn 25 khách, đi Hà Nội - Hạ Long 2 chiều'),
(2, 4, 3, 6, 5, TRUE, 1200000.00, 500000.00, 1200000.00, 'CONFIRMED', 'Đón sân bay TSN về Quận 7 (16 chỗ)'),
(3, 1, 1, 5, 4, FALSE, 25000000.00, 10000000.00, 0.00, 'INPROGRESS', 'Hợp đồng đưa đón nhân viên KCN Thăng Long T11/2025'),
(4, 3, 2, 6, 3, TRUE, 15000000.00, 500000.00, 0.00, 'PENDING', 'Thuê xe 45 chỗ đi 3N2Đ Đà Nẵng - Huế - Hội An'),
(5, 5, 1, 5, 1, TRUE, 1000000.00, 1000000.00, 1000000.00, 'CONFIRMED', 'Thuê 1 chiều xe Limo (9 chỗ) đi Nội Bài')
ON DUPLICATE KEY UPDATE status = VALUES(status), note = VALUES(note);

INSERT INTO BookingVehicleDetails (bookingId, vehicleCategoryId, quantity) VALUES
(1, 3, 1),
(2, 2, 1),
(3, 3, 2),
(4, 4, 1),
(5, 1, 1)
ON DUPLICATE KEY UPDATE quantity = VALUES(quantity);

INSERT INTO Trips (tripId, bookingId, useHighway, startTime, endTime, startLocation, endLocation, status) VALUES
(1, 1, TRUE, '2025-10-25 07:00:00', '2025-10-25 20:00:00', 'Hoàn Kiếm, Hà Nội', 'Hạ Long, Quảng Ninh', 'COMPLETED'),
(2, 2, TRUE, '2025-10-28 14:00:00', '2025-10-28 15:30:00', 'Sân bay Tân Sơn Nhất', 'Quận 7, TP. HCM', 'SCHEDULED'),
(3, 3, FALSE, '2025-11-01 07:00:00', '2025-11-01 08:30:00', 'Nội thành Hà Nội', 'KCN Thăng Long', 'SCHEDULED'),
(4, 3, FALSE, '2025-11-01 17:00:00', '2025-11-01 18:30:00', 'KCN Thăng Long', 'Nội thành Hà Nội', 'SCHEDULED'),
(5, 3, FALSE, '2025-11-02 07:00:00', '2025-11-02 08:30:00', 'Nội thành Hà Nội', 'KCN Thăng Long', 'SCHEDULED'),
(6, 5, TRUE, '2025-10-29 10:00:00', '2025-10-29 11:00:00', 'Times City, Hà Nội', 'Sân bay Nội Bài', 'SCHEDULED'),
(7, 4, TRUE, '2025-11-10 08:00:00', NULL, 'Đà Nẵng', 'Huế', 'SCHEDULED')
ON DUPLICATE KEY UPDATE status = VALUES(status), endTime = VALUES(endTime);

INSERT INTO TripVehicles (tripVehicleId, tripId, vehicleId, note) VALUES
(1, 1, 3, 'Gán xe Samco 29A-333.33 cho Trip 1'),
(2, 2, 5, 'Gán xe Transit 51C-555.55 cho Trip 2'),
(3, 3, 3, 'Gán xe 29A-333.33 cho Trip 3 (sáng)'),
(4, 3, 6, 'Gán xe 29A-666.66 cho Trip 3 (sáng)'),
(5, 4, 3, 'Gán xe 29A-333.33 cho Trip 4 (chiều)'),
(6, 4, 6, 'Gán xe 29A-666.66 cho Trip 4 (chiều)'),
(7, 5, 3, 'Gán xe 29A-333.33 cho Trip 5 (sáng)'),
(8, 5, 6, 'Gán xe 29A-666.66 cho Trip 5 (sáng)'),
(9, 6, 2, 'Gán xe Limousine 29A-222.22 cho Trip 6'),
(10, 7, 4, 'Gán xe Universe 43B-444.44 cho Trip 7')
ON DUPLICATE KEY UPDATE vehicleId = VALUES(vehicleId), note = VALUES(note);

INSERT INTO TripDrivers (tripId, driverId, driverRole, note) VALUES
(1, 1, 'Main Driver', 'Tài xế A lái xe 29A-333.33'),
(2, 4, 'Main Driver', 'Tài xế D lái xe 51C-555.55'),
(3, 1, 'Main Driver', 'Tài xế A lái xe Trip 3 (sáng)'),
(3, 2, 'Support Driver', 'Tài xế B hỗ trợ Trip 3 (sáng)'),
(4, 1, 'Main Driver', 'Tài xế A lái xe Trip 4 (chiều)'),
(4, 2, 'Support Driver', 'Tài xế B hỗ trợ Trip 4 (chiều)'),
(5, 1, 'Main Driver', 'Tài xế A lái xe Trip 5 (sáng)'),
(5, 2, 'Support Driver', 'Tài xế B hỗ trợ Trip 5 (sáng)'),
(6, 5, 'Main Driver', 'Tài xế E lái xe Trip 6'),
(7, 3, 'Main Driver', 'Tài xế C lái xe Trip 7')
ON DUPLICATE KEY UPDATE driverRole = VALUES(driverRole), note = VALUES(note);

INSERT INTO DriverDayOff (dayOffId, driverId, startDate, endDate, reason, approvedBy, status) VALUES
(1, 1, '2025-10-30', '2025-10-30', 'Việc gia đình', 2, 'APPROVED'),
(2, 2, '2025-11-05', '2025-11-06', 'Khám sức khỏe', 2, 'PENDING'),
(3, 3, '2025-10-20', '2025-10-21', 'Về quê', 3, 'APPROVED'),
(4, 4, '2025-10-29', '2025-10-29', 'Nghỉ ốm', 4, 'REJECTED'),
(5, 6, '2025-11-01', '2025-11-30', 'Nghỉ không lương', 3, 'APPROVED')
ON DUPLICATE KEY UPDATE status = VALUES(status), reason = VALUES(reason);

INSERT INTO Invoices (invoiceId, branchId, bookingId, customerId, type, costType, isDeposit, amount, paymentMethod, paymentStatus, status, note, requestedBy, createdBy, approvedBy, approvedAt) VALUES
(1, 1, 1, 2, 'Income', NULL, TRUE, 1000000.00, 'Chuyển khoản', 'PAID', 'ACTIVE', 'Đặt cọc Booking 1', NULL, 5, 2, NOW()),
(2, 1, 1, 2, 'Income', NULL, FALSE, 2800000.00, 'Tiền mặt', 'PAID', 'ACTIVE', 'Thu nốt Booking 1', NULL, 5, 2, NOW()),
(3, 3, 2, 4, 'Income', NULL, TRUE, 500000.00, 'Chuyển khoản', 'PAID', 'ACTIVE', 'Đặt cọc Booking 2', NULL, 6, 4, NOW()),
(4, 1, 3, 1, 'Income', NULL, FALSE, 25000000.00, 'Chuyển khoản', 'PAID', 'ACTIVE', 'Thanh toán HĐ định kỳ T11', NULL, 5, 2, NOW()),
(5, 1, 5, 5, 'Income', NULL, FALSE, 1000000.00, 'Chuyển khoản', 'PAID', 'ACTIVE', 'Thanh toán Booking 5', NULL, 5, 2, NOW()),
(6, 1, 1, NULL, 'Expense', 'fuel', FALSE, 1000000.00, 'Tiền mặt', 'PAID', 'ACTIVE', 'Đổ dầu xe Trip 1', 1, 8, 2, NOW()),
(7, 1, 1, NULL, 'Expense', 'toll', FALSE, 300000.00, 'Thẻ ETC', 'PAID', 'ACTIVE', 'Phí cao tốc HN-HL Trip 1', 1, 8, 2, NOW()),
(8, 2, NULL, NULL, 'Expense', 'maintenance', FALSE, 5000000.00, 'Chuyển khoản', 'PAID', 'ACTIVE', 'Bảo dưỡng xe 43B-777.77', NULL, 3, 3, NOW())
ON DUPLICATE KEY UPDATE amount = VALUES(amount), note = VALUES(note), paymentStatus = VALUES(paymentStatus);

INSERT INTO AccountsReceivable (arId, customerId, bookingId, invoiceId, totalAmount, paidAmount, dueDate, status) VALUES
(1, 2, 1, 2, 3800000.00, 3800000.00, '2025-10-25', 'PAID'),
(2, 4, 2, 3, 1200000.00, 500000.00, '2025-10-28', 'PARTIALLYPAID'),
(3, 1, 3, 4, 25000000.00, 25000000.00, '2025-11-01', 'PAID'),
(4, 3, 4, NULL, 15000000.00, 500000.00, '2025-11-10', 'PARTIALLYPAID'),
(5, 5, 5, 5, 1000000.00, 1000000.00, '2025-10-29', 'PAID')
ON DUPLICATE KEY UPDATE totalAmount = VALUES(totalAmount), paidAmount = VALUES(paidAmount), dueDate = VALUES(dueDate), status = VALUES(status);

INSERT INTO Notifications (notificationId, userId, title, message, isRead) VALUES
(1, 2, 'Yêu cầu nghỉ phép', 'Tài xế Trần Văn B vừa tạo yêu cầu nghỉ phép.', FALSE),
(2, 6, 'Booking đã xác nhận', 'Booking #2 (Đón sân bay) đã được xác nhận.', FALSE),
(3, 11, 'Giao việc mới', 'Bạn được gán lái Trip #2 (Đón sân bay TSN).', FALSE),
(4, 1, 'Hợp đồng mới', 'Hợp đồng thuê định kỳ (Booking #3) vừa được kích hoạt.', TRUE),
(5, 7, 'Hóa đơn đã duyệt', 'Hóa đơn chi phí (Xăng dầu Trip 1) đã được duyệt.', FALSE)
ON DUPLICATE KEY UPDATE title = VALUES(title), message = VALUES(message), isRead = VALUES(isRead);

INSERT INTO SystemSettings (settingId, settingKey, settingValue, effectiveStartDate, valueType, category, description, updatedBy) VALUES
(1, 'VAT_RATE', '0.08', '2025-01-01', 'decimal', 'Billing', 'Tỷ lệ thuế VAT (8%)', 1),
(2, 'DEFAULT_HIGHWAY', 'true', '2025-01-01', 'boolean', 'Booking', 'Mặc định chọn cao tốc khi tạo booking', 1),
(3, 'MAX_DRIVING_HOURS_PER_DAY', '10', '2025-01-01', 'int', 'Driver', 'Số giờ lái xe tối đa của tài xế/ngày', 1),
(4, 'SUPPORT_HOTLINE', '1900 1234', '2025-01-01', 'string', 'General', 'Số hotline hỗ trợ khách hàng', 1),
(5, 'LATE_PAYMENT_FEE_RATE', '0.05', '2025-01-01', 'decimal', 'Billing', 'Lãi suất phạt thanh toán chậm (5%/ngày)', 1),
(6, 'FAIRNESS_WEIGHT_DAILY_HOURS', '0.4', '2025-01-01', 'decimal', 'Dispatch', 'Trọng số giờ làm việc hàng ngày trong tính fairness', 1),
(7, 'FAIRNESS_WEIGHT_WEEKLY_TRIPS', '0.3', '2025-01-01', 'decimal', 'Dispatch', 'Trọng số số chuyến trong tuần trong tính fairness', 1),
(8, 'FAIRNESS_WEIGHT_REST_TIME', '0.3', '2025-01-01', 'decimal', 'Dispatch', 'Trọng số thời gian nghỉ trong tính fairness', 1)
ON DUPLICATE KEY UPDATE settingValue = VALUES(settingValue), description = VALUES(description), updatedBy = VALUES(updatedBy);

-- Sample data for Module 5 tables
INSERT INTO TripAssignmentHistory (historyId, tripId, action, driverId, vehicleId, previousDriverId, previousVehicleId, reason, performedBy, createdAt) VALUES
(1, 1, 'ASSIGN', 1, 3, NULL, NULL, 'Gán lần đầu cho chuyến Hà Nội - Hạ Long', 2, '2025-10-24 15:00:00'),
(2, 2, 'ASSIGN', 4, 5, NULL, NULL, 'Gán tài xế D cho chuyến đón sân bay', 4, '2025-10-27 10:00:00'),
(3, 6, 'ASSIGN', 5, 2, NULL, NULL, 'Gán tài xế E cho chuyến đi Nội Bài', 2, '2025-10-28 09:00:00')
ON DUPLICATE KEY UPDATE reason = VALUES(reason);

INSERT INTO TripRatings (ratingId, tripId, driverId, rating, comment, ratedBy, ratedAt) VALUES
(1, 1, 1, 5, 'Tài xế lái xe an toàn, đúng giờ, thái độ tốt', 2, '2025-10-25 21:00:00'),
(2, 1, 1, 4, 'Tốt nhưng có thể cải thiện giao tiếp', 5, '2025-10-25 22:00:00')
ON DUPLICATE KEY UPDATE comment = VALUES(comment);

INSERT INTO DriverWorkload (workloadId, driverId, date, totalMinutes, tripCount, fairnessScore) VALUES
(1, 1, '2025-10-25', 780, 1, 45.5),
(2, 2, '2025-10-25', 0, 0, 10.0),
(3, 3, '2025-10-25', 0, 0, 10.0),
(4, 4, '2025-10-28', 90, 1, 25.2),
(5, 5, '2025-10-29', 60, 1, 20.8),
(6, 1, '2025-11-01', 90, 1, 30.0),
(7, 2, '2025-11-01', 90, 1, 30.0)
ON DUPLICATE KEY UPDATE totalMinutes = VALUES(totalMinutes), tripCount = VALUES(tripCount), fairnessScore = VALUES(fairnessScore);

-- Sample: DriverShifts (Ca làm việc mẫu)
INSERT INTO DriverShifts (shiftId, driverId, date, shiftStart, shiftEnd, breakStart, breakEnd, status) VALUES
(1, 1, CURDATE(), '08:00:00', '17:00:00', '12:00:00', '13:00:00', 'SCHEDULED'),
(2, 2, CURDATE(), '08:00:00', '17:00:00', '12:00:00', '13:00:00', 'SCHEDULED'),
(3, 3, CURDATE(), '08:00:00', '17:00:00', '12:00:00', '13:00:00', 'SCHEDULED'),
(4, 4, CURDATE(), '13:00:00', '22:00:00', '17:00:00', '18:00:00', 'SCHEDULED'),
(5, 5, CURDATE(), '08:00:00', '17:00:00', '12:00:00', '13:00:00', 'SCHEDULED')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- Sample: VehicleShifts
INSERT INTO VehicleShifts (shiftId, vehicleId, date, shiftStart, shiftEnd, status) VALUES
(1, 1, CURDATE(), '07:00:00', '22:00:00', 'AVAILABLE'),
(2, 2, CURDATE(), '07:00:00', '22:00:00', 'AVAILABLE'),
(3, 3, CURDATE(), '07:00:00', '22:00:00', 'AVAILABLE'),
(4, 4, CURDATE(), '07:00:00', '22:00:00', 'AVAILABLE'),
(5, 5, CURDATE(), '07:00:00', '22:00:00', 'AVAILABLE'),
(6, 7, CURDATE(), '07:00:00', '22:00:00', 'MAINTENANCE')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- Sample: VehicleMaintenance
INSERT INTO VehicleMaintenance (maintenanceId, vehicleId, maintenanceType, description, scheduledStart, scheduledEnd, status, cost) VALUES
(1, 7, 'PERIODIC_MAINTENANCE', 'Bảo dưỡng định kỳ 10,000km', CONCAT(CURDATE(), ' 08:00:00'), CONCAT(CURDATE(), ' 17:00:00'), 'IN_PROGRESS', 5000000.00),
(2, 3, 'INSPECTION', 'Đăng kiểm định kỳ', CONCAT(DATE_ADD(CURDATE(), INTERVAL 6 DAY), ' 08:00:00'), CONCAT(DATE_ADD(CURDATE(), INTERVAL 6 DAY), ' 12:00:00'), 'SCHEDULED', 500000.00)
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- Sample: ScheduleConflicts (Optional - có thể bỏ comment nếu cần test)
-- INSERT INTO ScheduleConflicts (conflictId, conflictType, driverId, tripId1, tripId2, conflictTime, description, status) VALUES
-- (1, 'DRIVER_OVERLAP', 1, 1, 3, '2025-11-01 08:30:00', 'Tài xế A có 2 chuyến trùng giờ', 'DETECTED')
-- ON DUPLICATE KEY UPDATE status = VALUES(status);

-- ==========================================================
-- End of Script
-- ==========================================================
