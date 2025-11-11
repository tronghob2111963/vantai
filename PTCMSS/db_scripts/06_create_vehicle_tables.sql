USE ptcmss_db;

CREATE TABLE IF NOT EXISTS VehicleCategoryPricing (
  categoryId INT AUTO_INCREMENT PRIMARY KEY,
  categoryName VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  baseFare DECIMAL(10,2),
  pricePerKm DECIMAL(10,2),
  highwayFee DECIMAL(10,2),
  fixedCosts DECIMAL(10,2),
  effectiveDate DATE DEFAULT (CURRENT_DATE),
  status ENUM('Active','Inactive') DEFAULT 'Active',
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Vehicles (
  vehicleId INT AUTO_INCREMENT PRIMARY KEY,
  categoryId INT NOT NULL,
  branchId INT NOT NULL,
  licensePlate VARCHAR(20) NOT NULL UNIQUE,
  model VARCHAR(100),
  capacity INT,
  productionYear INT CHECK (productionYear >= 1980),
  registrationDate DATE,
  inspectionExpiry DATE,
  status ENUM('Available','InUse','Maintenance','Inactive') DEFAULT 'Available',
  CONSTRAINT fk_veh_cat    FOREIGN KEY (categoryId) REFERENCES VehicleCategoryPricing(categoryId),
  CONSTRAINT fk_veh_branch FOREIGN KEY (branchId)   REFERENCES Branches(branchId)
) ENGINE=InnoDB;

CREATE INDEX IX_Vehicles_BranchId ON Vehicles(branchId);
