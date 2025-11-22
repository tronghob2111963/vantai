-- =====================================================
-- MODULE 6: ACCOUNTING - ADDITIONAL TABLES
-- Bổ sung các bảng thiếu cho Module 6
-- Tạo ngày: 2025-11-22
-- =====================================================

USE `ptcmss_db`;

-- =====================================================
-- 1. INVOICE_ITEMS - Chi tiết dòng hóa đơn
-- =====================================================
DROP TABLE IF EXISTS `invoice_items`;
CREATE TABLE `invoice_items` (
  `itemId` int NOT NULL AUTO_INCREMENT,
  `invoiceId` int NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Mô tả dòng hóa đơn',
  `quantity` decimal(10,2) NOT NULL DEFAULT '1.00' COMMENT 'Số lượng',
  `unitPrice` decimal(18,2) NOT NULL COMMENT 'Đơn giá',
  `amount` decimal(18,2) GENERATED ALWAYS AS (`quantity` * `unitPrice`) STORED COMMENT 'Thành tiền (tự động)',
  `taxRate` decimal(5,2) DEFAULT '0.00' COMMENT 'Thuế suất (%)',
  `taxAmount` decimal(18,2) DEFAULT '0.00' COMMENT 'Tiền thuế',
  `note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`itemId`),
  KEY `FK_item_invoice` (`invoiceId`),
  KEY `IX_invoice_items_invoiceId` (`invoiceId`),
  CONSTRAINT `FK_item_invoice` FOREIGN KEY (`invoiceId`)
    REFERENCES `invoices` (`invoiceId`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Chi tiết dòng hóa đơn - Module 6';


-- =====================================================
-- 2. DEPOSITS - Quản lý tiền cọc riêng biệt
-- =====================================================
DROP TABLE IF EXISTS `deposits`;
CREATE TABLE `deposits` (
  `depositId` int NOT NULL AUTO_INCREMENT,
  `invoiceId` int DEFAULT NULL COMMENT 'Hóa đơn liên quan',
  `bookingId` int NOT NULL COMMENT 'Đơn hàng',
  `customerId` int NOT NULL COMMENT 'Khách hàng',
  `amount` decimal(18,2) NOT NULL COMMENT 'Số tiền cọc',
  `depositPercent` decimal(5,2) DEFAULT '0.00' COMMENT 'Phần trăm cọc',
  `paymentMethod` enum('CASH','BANK_TRANSFER','QR','CARD') COLLATE utf8mb4_unicode_ci DEFAULT 'CASH',
  `bankName` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bankAccount` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referenceCode` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Mã tham chiếu CK',
  `receiptNumber` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Số phiếu thu',
  `receiptUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'URL chứng từ',
  `status` enum('PENDING','CONFIRMED','USED','REFUNDED','CANCELLED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `depositedAt` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày nhận cọc',
  `usedAt` datetime DEFAULT NULL COMMENT 'Ngày sử dụng cọc',
  `cancelledAt` datetime DEFAULT NULL,
  `cancelReason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdBy` int DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`depositId`),
  UNIQUE KEY `UK_deposit_receipt` (`receiptNumber`),
  KEY `FK_dep_invoice` (`invoiceId`),
  KEY `FK_dep_booking` (`bookingId`),
  KEY `FK_dep_customer` (`customerId`),
  KEY `FK_dep_createdBy` (`createdBy`),
  KEY `IX_deposits_status` (`status`),
  KEY `IX_deposits_depositedAt` (`depositedAt`),
  CONSTRAINT `FK_dep_invoice` FOREIGN KEY (`invoiceId`)
    REFERENCES `invoices` (`invoiceId`) ON DELETE SET NULL,
  CONSTRAINT `FK_dep_booking` FOREIGN KEY (`bookingId`)
    REFERENCES `bookings` (`bookingId`) ON DELETE CASCADE,
  CONSTRAINT `FK_dep_customer` FOREIGN KEY (`customerId`)
    REFERENCES `customers` (`customerId`),
  CONSTRAINT `FK_dep_createdBy` FOREIGN KEY (`createdBy`)
    REFERENCES `users` (`userId`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Quản lý tiền cọc - Module 6';


-- =====================================================
-- 3. EXPENSES - Chi phí thực tế (riêng biệt với invoices)
-- =====================================================
DROP TABLE IF EXISTS `expenses`;
CREATE TABLE `expenses` (
  `expenseId` int NOT NULL AUTO_INCREMENT,
  `expenseCode` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Mã chi phí',
  `branchId` int NOT NULL,
  `vehicleId` int DEFAULT NULL COMMENT 'Xe liên quan',
  `driverId` int DEFAULT NULL COMMENT 'Tài xế',
  `tripId` int DEFAULT NULL COMMENT 'Chuyến đi',
  `bookingId` int DEFAULT NULL COMMENT 'Đơn hàng',
  `expenseType` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Loại chi phí',
  `category` enum('FUEL','MAINTENANCE','SALARY','PARKING','INSURANCE','TOLL','OTHER') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OTHER',
  `amount` decimal(18,2) NOT NULL COMMENT 'Số tiền',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `receiptUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Chứng từ',
  `status` enum('PENDING','APPROVED','REJECTED','PAID') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `approvedBy` int DEFAULT NULL,
  `approvedAt` datetime DEFAULT NULL,
  `rejectedReason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paidAt` datetime DEFAULT NULL,
  `expenseDate` datetime NOT NULL COMMENT 'Ngày phát sinh chi phí',
  `note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdBy` int DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`expenseId`),
  UNIQUE KEY `UK_expense_code` (`expenseCode`),
  KEY `FK_exp_branch` (`branchId`),
  KEY `FK_exp_vehicle` (`vehicleId`),
  KEY `FK_exp_driver` (`driverId`),
  KEY `FK_exp_trip` (`tripId`),
  KEY `FK_exp_booking` (`bookingId`),
  KEY `FK_exp_approvedBy` (`approvedBy`),
  KEY `FK_exp_createdBy` (`createdBy`),
  KEY `IX_expenses_status` (`status`),
  KEY `IX_expenses_category` (`category`),
  KEY `IX_expenses_expenseDate` (`expenseDate`),
  CONSTRAINT `FK_exp_branch` FOREIGN KEY (`branchId`)
    REFERENCES `branches` (`branchId`),
  CONSTRAINT `FK_exp_vehicle` FOREIGN KEY (`vehicleId`)
    REFERENCES `vehicles` (`vehicleId`) ON DELETE SET NULL,
  CONSTRAINT `FK_exp_driver` FOREIGN KEY (`driverId`)
    REFERENCES `drivers` (`driverId`) ON DELETE SET NULL,
  CONSTRAINT `FK_exp_trip` FOREIGN KEY (`tripId`)
    REFERENCES `trips` (`tripId`) ON DELETE SET NULL,
  CONSTRAINT `FK_exp_booking` FOREIGN KEY (`bookingId`)
    REFERENCES `bookings` (`bookingId`) ON DELETE SET NULL,
  CONSTRAINT `FK_exp_approvedBy` FOREIGN KEY (`approvedBy`)
    REFERENCES `users` (`userId`) ON DELETE SET NULL,
  CONSTRAINT `FK_exp_createdBy` FOREIGN KEY (`createdBy`)
    REFERENCES `users` (`userId`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Chi phí thực tế - Module 6';


-- =====================================================
-- 4. INSERT SAMPLE DATA
-- =====================================================

-- Sample invoice items cho HĐ đã có
INSERT INTO `invoice_items` (`invoiceId`, `description`, `quantity`, `unitPrice`, `taxRate`, `taxAmount`) VALUES
(2, 'Vận chuyển Hà Nội - Hải Phòng', 1.00, 3800000.00, 10.00, 380000.00),
(3, 'Vận chuyển nội thành TP.HCM', 1.00, 1200000.00, 10.00, 120000.00),
(4, 'Vận chuyển container 40ft', 1.00, 25000000.00, 10.00, 2500000.00),
(5, 'Vận chuyển Hà Nội - Đà Nẵng', 1.00, 1000000.00, 10.00, 100000.00);

-- Sample deposits
INSERT INTO `deposits` (`invoiceId`, `bookingId`, `customerId`, `amount`, `depositPercent`, `paymentMethod`, `status`, `depositedAt`, `createdBy`) VALUES
(2, 1, 2, 1140000.00, 30.00, 'BANK_TRANSFER', 'USED', '2025-10-20 08:00:00', 7),
(3, 2, 4, 600000.00, 50.00, 'CASH', 'USED', '2025-10-21 09:30:00', 7),
(4, 3, 1, 7500000.00, 30.00, 'BANK_TRANSFER', 'USED', '2025-10-22 14:00:00', 7);

-- Sample expenses
INSERT INTO `expenses` (`expenseCode`, `branchId`, `vehicleId`, `driverId`, `tripId`, `category`, `amount`, `description`, `status`, `expenseDate`, `createdBy`) VALUES
('EXP-2025-001', 1, 1, 1, 1, 'FUEL', 1500000.00, 'Xăng dầu chuyến Hà Nội - Hải Phòng', 'APPROVED', '2025-10-20 06:00:00', 8),
('EXP-2025-002', 1, 1, 1, 1, 'PARKING', 120000.00, 'Phí bến bãi container Hải Phòng', 'APPROVED', '2025-10-20 18:00:00', 8),
('EXP-2025-003', 2, 3, 3, 2, 'MAINTENANCE', 3200000.00, 'Bảo dưỡng định kỳ 50.000 km', 'APPROVED', '2025-10-21 10:00:00', 10),
('EXP-2025-004', 3, 5, 5, NULL, 'INSURANCE', 2500000.00, 'Gia hạn bảo hiểm trách nhiệm dân sự', 'APPROVED', '2025-10-22 14:00:00', 12),
('EXP-2025-005', 1, 1, 1, 3, 'FUEL', 900000.00, 'Xăng chạy nội thành', 'PENDING', '2025-10-23 08:00:00', 8);


-- =====================================================
-- 5. INDEXES FOR PERFORMANCE
-- =====================================================

-- Indexes cho báo cáo nhanh
CREATE INDEX `IX_expenses_branch_date` ON `expenses` (`branchId`, `expenseDate`);
CREATE INDEX `IX_deposits_customer_status` ON `deposits` (`customerId`, `status`);
CREATE INDEX `IX_invoice_items_invoice_desc` ON `invoice_items` (`invoiceId`, `description`(100));


-- =====================================================
-- 6. VIEWS (Tuỳ chọn - giúp query dễ hơn)
-- =====================================================

-- View: Tổng hợp deposit theo booking
CREATE OR REPLACE VIEW `v_booking_deposits` AS
SELECT
  b.bookingId,
  b.bookingCode,
  c.customerName,
  COALESCE(SUM(d.amount), 0) AS totalDeposit,
  COUNT(d.depositId) AS depositCount,
  MAX(d.depositedAt) AS lastDepositDate,
  GROUP_CONCAT(d.status ORDER BY d.depositedAt SEPARATOR ', ') AS depositStatuses
FROM bookings b
LEFT JOIN deposits d ON b.bookingId = d.bookingId
LEFT JOIN customers c ON b.customerId = c.customerId
GROUP BY b.bookingId, b.bookingCode, c.customerName;

-- View: Báo cáo chi phí theo xe
CREATE OR REPLACE VIEW `v_vehicle_expenses` AS
SELECT
  v.vehicleId,
  v.licensePlate,
  v.brand,
  v.model,
  e.category,
  COUNT(e.expenseId) AS expenseCount,
  SUM(e.amount) AS totalAmount,
  AVG(e.amount) AS avgAmount,
  MAX(e.expenseDate) AS lastExpenseDate
FROM vehicles v
LEFT JOIN expenses e ON v.vehicleId = e.vehicleId AND e.status = 'APPROVED'
GROUP BY v.vehicleId, v.licensePlate, v.brand, v.model, e.category;

-- View: Tổng hợp chi phí theo loại và tháng
CREATE OR REPLACE VIEW `v_monthly_expenses` AS
SELECT
  DATE_FORMAT(expenseDate, '%Y-%m') AS month,
  category,
  branchId,
  COUNT(expenseId) AS expenseCount,
  SUM(amount) AS totalAmount,
  AVG(amount) AS avgAmount
FROM expenses
WHERE status = 'APPROVED'
GROUP BY DATE_FORMAT(expenseDate, '%Y-%m'), category, branchId;


-- =====================================================
-- 7. STORED PROCEDURES (Tuỳ chọn - nghiệp vụ phức tạp)
-- =====================================================

DELIMITER $$

-- Procedure: Tính tổng deposit của booking
DROP PROCEDURE IF EXISTS `sp_calculate_booking_deposit`$$
CREATE PROCEDURE `sp_calculate_booking_deposit`(
  IN p_bookingId INT,
  OUT p_totalDeposit DECIMAL(18,2),
  OUT p_remainingAmount DECIMAL(18,2)
)
BEGIN
  DECLARE v_totalPrice DECIMAL(18,2);

  SELECT totalPrice INTO v_totalPrice
  FROM bookings WHERE bookingId = p_bookingId;

  SELECT COALESCE(SUM(amount), 0) INTO p_totalDeposit
  FROM deposits
  WHERE bookingId = p_bookingId AND status IN ('CONFIRMED', 'USED');

  SET p_remainingAmount = v_totalPrice - p_totalDeposit;
END$$

-- Procedure: Tự động sinh mã expense
DROP PROCEDURE IF EXISTS `sp_generate_expense_code`$$
CREATE PROCEDURE `sp_generate_expense_code`(
  OUT p_expenseCode VARCHAR(50)
)
BEGIN
  DECLARE v_year CHAR(4);
  DECLARE v_seq INT;

  SET v_year = YEAR(CURDATE());

  SELECT COALESCE(MAX(CAST(SUBSTRING(expenseCode, 10) AS UNSIGNED)), 0) + 1 INTO v_seq
  FROM expenses
  WHERE expenseCode LIKE CONCAT('EXP-', v_year, '-%');

  SET p_expenseCode = CONCAT('EXP-', v_year, '-', LPAD(v_seq, 3, '0'));
END$$

DELIMITER ;


-- =====================================================
-- 8. TRIGGERS (Tự động cập nhật)
-- =====================================================

DELIMITER $$

-- Trigger: Tự động tạo expense code khi insert
DROP TRIGGER IF EXISTS `tr_expenses_before_insert`$$
CREATE TRIGGER `tr_expenses_before_insert`
BEFORE INSERT ON `expenses`
FOR EACH ROW
BEGIN
  IF NEW.expenseCode IS NULL THEN
    CALL sp_generate_expense_code(@newCode);
    SET NEW.expenseCode = @newCode;
  END IF;
END$$

-- Trigger: Tự động sinh receipt number cho deposit
DROP TRIGGER IF EXISTS `tr_deposits_before_insert`$$
CREATE TRIGGER `tr_deposits_before_insert`
BEFORE INSERT ON `deposits`
FOR EACH ROW
BEGIN
  DECLARE v_year CHAR(4);
  DECLARE v_seq INT;

  IF NEW.receiptNumber IS NULL THEN
    SET v_year = YEAR(CURDATE());

    SELECT COALESCE(MAX(CAST(SUBSTRING(receiptNumber, 8) AS UNSIGNED)), 0) + 1 INTO v_seq
    FROM deposits
    WHERE receiptNumber LIKE CONCAT('RC-', v_year, '-%');

    SET NEW.receiptNumber = CONCAT('RC-', v_year, '-', LPAD(v_seq, 4, '0'));
  END IF;
END$$

DELIMITER ;


-- =====================================================
-- HOÀN TẤT
-- =====================================================
-- Script này tạo 3 bảng mới cho Module 6:
-- 1. invoice_items - Chi tiết dòng hóa đơn
-- 2. deposits - Quản lý tiền cọc
-- 3. expenses - Chi phí thực tế
--
-- Kèm theo:
-- - Sample data
-- - Indexes tối ưu
-- - Views báo cáo
-- - Stored procedures
-- - Triggers tự động
-- =====================================================
