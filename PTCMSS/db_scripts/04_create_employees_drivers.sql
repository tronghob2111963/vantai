USE ptcmss_db;

CREATE TABLE IF NOT EXISTS Employees (
  employeeId INT AUTO_INCREMENT PRIMARY KEY,
  userId INT NOT NULL,
  branchId INT NOT NULL,
  roleId INT NOT NULL,
  status ENUM('Active','Inactive','OnLeave') DEFAULT 'Active',
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
  priorityLevel INT DEFAULT 1 CHECK (priorityLevel BETWEEN 1 AND 10),
  note VARCHAR(255),
  status ENUM('Available','OnTrip','Inactive') DEFAULT 'Available',
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
  status ENUM('Pending','Approved','Rejected') DEFAULT 'Pending',
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_doff_driver  FOREIGN KEY (driverId)  REFERENCES Drivers(driverId),
  CONSTRAINT fk_doff_approve FOREIGN KEY (approvedBy) REFERENCES Employees(employeeId),
  CHECK (startDate <= endDate)
) ENGINE=InnoDB;

CREATE INDEX IX_DriverDayOff_DriverId ON DriverDayOff(driverId);
