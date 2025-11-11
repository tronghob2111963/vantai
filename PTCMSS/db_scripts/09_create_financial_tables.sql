USE ptcmss_db;

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
  paymentStatus ENUM('Unpaid','Paid','Refunded') DEFAULT 'Unpaid',
  status ENUM('Active','Cancelled') DEFAULT 'Active',
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
  status ENUM('Unpaid','PartiallyPaid','Paid') DEFAULT 'Unpaid',
  note VARCHAR(255),
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ar_customer FOREIGN KEY (customerId) REFERENCES Customers(customerId),
  CONSTRAINT fk_ar_booking  FOREIGN KEY (bookingId)  REFERENCES Bookings(bookingId),
  CONSTRAINT fk_ar_invoice  FOREIGN KEY (invoiceId)  REFERENCES Invoices(invoiceId)
) ENGINE=InnoDB;

CREATE INDEX IX_AR_Status_DueDate ON AccountsReceivable(status, dueDate);
