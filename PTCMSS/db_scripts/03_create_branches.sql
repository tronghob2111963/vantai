USE ptcmss_db;

CREATE TABLE IF NOT EXISTS Branches (
  branchId INT AUTO_INCREMENT PRIMARY KEY,
  branchName VARCHAR(100) NOT NULL,
  location VARCHAR(255),
  managerId INT NULL,
  status ENUM('Active', 'Inactive', 'UnderReview', 'Closed') DEFAULT 'Active',
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
