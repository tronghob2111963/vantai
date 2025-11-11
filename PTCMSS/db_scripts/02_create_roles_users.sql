USE ptcmss_db;

CREATE TABLE IF NOT EXISTS Roles (
  roleId INT AUTO_INCREMENT PRIMARY KEY,
  roleName VARCHAR(50) NOT NULL,
  description VARCHAR(255)
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
  status ENUM('Active','Inactive','Suspended') DEFAULT 'Active',
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_role FOREIGN KEY (roleId) REFERENCES Roles(roleId)
) ENGINE=InnoDB;

CREATE INDEX IX_Users_RoleId ON Users(roleId);
