USE ptcmss_db;

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
  status ENUM('Pending','Confirmed','InProgress','Completed','Cancelled') DEFAULT 'Pending',
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_book_cust    FOREIGN KEY (customerId)  REFERENCES Customers(customerId),
  CONSTRAINT fk_book_branch  FOREIGN KEY (branchId)    REFERENCES Branches(branchId),
  CONSTRAINT fk_book_cons    FOREIGN KEY (consultantId)REFERENCES Employees(employeeId),
  CONSTRAINT fk_book_hire    FOREIGN KEY (hireTypeId)  REFERENCES HireTypes(hireTypeId)
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
