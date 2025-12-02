-- ============================================
-- RESTORE debt_reminder_history TABLE
-- Feature: Lưu lịch sử nhắc nợ qua EMAIL/SMS/PHONE
-- ============================================

USE ptcmss_db;

-- Tạo lại bảng debt_reminder_history
CREATE TABLE IF NOT EXISTS `debt_reminder_history` (
  `reminderId` int NOT NULL AUTO_INCREMENT,
  `invoiceId` int NOT NULL,
  `reminderDate` datetime(6) NOT NULL,
  `reminderType` varchar(20) NOT NULL COMMENT 'EMAIL, SMS, PHONE',
  `recipient` varchar(100) DEFAULT NULL,
  `message` text,
  `sentBy` int DEFAULT NULL,
  `createdAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`reminderId`),
  KEY `invoiceId` (`invoiceId`),
  KEY `sentBy` (`sentBy`),
  CONSTRAINT `debt_reminder_history_ibfk_1` FOREIGN KEY (`invoiceId`) REFERENCES `invoices` (`invoiceId`) ON DELETE CASCADE,
  CONSTRAINT `debt_reminder_history_ibfk_2` FOREIGN KEY (`sentBy`) REFERENCES `users` (`userId`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT 'debt_reminder_history table restored successfully' AS Status;
