USE ptcmss_db;

CREATE TABLE IF NOT EXISTS Customers (
  customerId INT AUTO_INCREMENT PRIMARY KEY,
  fullName VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  address VARCHAR(255),
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  createdBy INT NULL,
  status ENUM('Active','Inactive') DEFAULT 'Active',
  CONSTRAINT fk_cust_createdBy FOREIGN KEY (createdBy) REFERENCES Employees(employeeId)
) ENGINE=InnoDB;

CREATE INDEX IX_Customers_CreatedBy ON Customers(createdBy);
