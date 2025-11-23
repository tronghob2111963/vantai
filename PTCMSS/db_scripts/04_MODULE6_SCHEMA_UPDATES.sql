-- ==========================================================
-- Module 6: Quản Lý Chi Phí & Tài Chính - Database Schema Updates
-- ==========================================================
-- 
-- MỤC ĐÍCH: Cập nhật schema cho Module 6
-- 
-- LƯU Ý:
-- 1. BACKUP DATABASE TRƯỚC KHI CHẠY SCRIPT NÀY!
-- 2. Chạy script này sau khi đã migrate sang snake_case
--
-- CÁCH CHẠY:
-- mysql -u root -p ptcmss_db < 04_MODULE6_SCHEMA_UPDATES.sql
--
-- ==========================================================

USE ptcmss_db;

-- ==========================================================
-- 1. Cập nhật invoices table - Thêm fields mới
-- ==========================================================

ALTER TABLE invoices
-- Invoice number (Số HĐ)
ADD COLUMN invoiceNumber VARCHAR(50) UNIQUE NULL COMMENT 'Số HĐ: INV-YYYY-{seq}' AFTER invoiceId,

-- Payment terms (Điều khoản thanh toán)
ADD COLUMN dueDate DATE NULL COMMENT 'Hạn thanh toán' AFTER invoiceDate,
ADD COLUMN paymentTerms VARCHAR(20) DEFAULT 'NET_7' COMMENT 'Điều khoản: NET_7/14/30' AFTER dueDate,

-- VAT & Subtotal (Thuế và tổng trước thuế)
ADD COLUMN vatAmount DECIMAL(18,2) DEFAULT 0 COMMENT 'Tiền thuế VAT' AFTER amount,
ADD COLUMN subtotal DECIMAL(18,2) NULL COMMENT 'Tổng trước thuế' AFTER vatAmount,

-- Bank transfer info (Thông tin chuyển khoản)
ADD COLUMN bankName VARCHAR(100) NULL COMMENT 'Tên ngân hàng' AFTER paymentMethod,
ADD COLUMN bankAccount VARCHAR(50) NULL COMMENT 'Số tài khoản' AFTER bankName,
ADD COLUMN referenceNumber VARCHAR(50) NULL COMMENT 'Mã tham chiếu' AFTER bankAccount,

-- Cash info (Thông tin tiền mặt)
ADD COLUMN cashierName VARCHAR(100) NULL COMMENT 'Người nhận/Quỹ thu' AFTER referenceNumber,
ADD COLUMN receiptNumber VARCHAR(50) NULL COMMENT 'Số phiếu thu' AFTER cashierName,

-- Cancellation (Hủy HĐ)
ADD COLUMN cancelledAt DATETIME NULL COMMENT 'Thời điểm hủy' AFTER approvedAt,
ADD COLUMN cancelledBy INT NULL COMMENT 'Người hủy' AFTER cancelledAt,
ADD COLUMN cancellationReason VARCHAR(500) NULL COMMENT 'Lý do hủy' AFTER cancelledBy,

-- Sending (Gửi HĐ)
ADD COLUMN sentAt DATETIME NULL COMMENT 'Thời điểm gửi HĐ' AFTER cancellationReason,
ADD COLUMN sentToEmail VARCHAR(100) NULL COMMENT 'Email gửi HĐ' AFTER sentAt,

-- Debt management (Quản lý nợ)
ADD COLUMN promiseToPayDate DATE NULL COMMENT 'Hẹn thanh toán' AFTER sentToEmail,
ADD COLUMN debtLabel VARCHAR(50) NULL COMMENT 'Nhãn nợ: VIP/TRANH_CHAP/NORMAL' AFTER promiseToPayDate,
ADD COLUMN contactNote TEXT NULL COMMENT 'Ghi chú liên hệ' AFTER debtLabel;

-- Foreign keys
ALTER TABLE invoices
ADD CONSTRAINT fk_inv_cancelledBy FOREIGN KEY (cancelledBy) REFERENCES employees(employeeId);

-- Indexes
CREATE INDEX IX_Invoices_InvoiceNumber ON invoices(invoiceNumber);
CREATE INDEX IX_Invoices_DueDate ON invoices(dueDate);
CREATE INDEX IX_Invoices_Overdue ON invoices(dueDate, paymentStatus);
CREATE INDEX IX_Invoices_PromiseToPay ON invoices(promiseToPayDate);
CREATE INDEX IX_Invoices_DebtLabel ON invoices(debtLabel);
CREATE INDEX IX_Invoices_Type_Date ON invoices(type, invoiceDate);

-- ==========================================================
-- 2. Tạo payment_history table (Lịch sử thanh toán)
-- ==========================================================

CREATE TABLE IF NOT EXISTS payment_history (
  paymentId INT AUTO_INCREMENT PRIMARY KEY,
  invoiceId INT NOT NULL,
  paymentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  amount DECIMAL(18,2) NOT NULL CHECK (amount > 0),
  paymentMethod VARCHAR(50) NOT NULL,
  
  -- Bank transfer fields
  bankName VARCHAR(100) NULL,
  bankAccount VARCHAR(50) NULL,
  referenceNumber VARCHAR(50) NULL,
  
  -- Cash fields
  cashierName VARCHAR(100) NULL,
  receiptNumber VARCHAR(50) NULL,
  
  note VARCHAR(500) NULL,
  createdBy INT NULL,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_ph_invoice FOREIGN KEY (invoiceId) REFERENCES invoices(invoiceId),
  CONSTRAINT fk_ph_createdBy FOREIGN KEY (createdBy) REFERENCES employees(employeeId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IX_PaymentHistory_Invoice ON payment_history(invoiceId);
CREATE INDEX IX_PaymentHistory_Date ON payment_history(paymentDate);
CREATE INDEX IX_PaymentHistory_Method ON payment_history(paymentMethod);

-- ==========================================================
-- 3. Tạo debt_reminder_history table (Lịch sử nhắc nợ)
-- ==========================================================

CREATE TABLE IF NOT EXISTS debt_reminder_history (
  reminderId INT AUTO_INCREMENT PRIMARY KEY,
  invoiceId INT NOT NULL,
  reminderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reminderType VARCHAR(20) NOT NULL,
  recipient VARCHAR(100) NULL,
  message TEXT NULL,
  sentBy INT NULL,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_drh_invoice FOREIGN KEY (invoiceId) REFERENCES invoices(invoiceId),
  CONSTRAINT fk_drh_sentBy FOREIGN KEY (sentBy) REFERENCES users(userId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IX_DebtReminder_Invoice ON debt_reminder_history(invoiceId);
CREATE INDEX IX_DebtReminder_Date ON debt_reminder_history(reminderDate);
CREATE INDEX IX_DebtReminder_Type ON debt_reminder_history(reminderType);

-- ==========================================================
-- 4. Tạo Views cho Module 6
-- ==========================================================

-- View: Accounting Dashboard Summary
DROP VIEW IF EXISTS v_accounting_dashboard;

CREATE VIEW v_accounting_dashboard AS
SELECT 
    b.branchId,
    b.branchName,
    DATE(i.invoiceDate) AS date,
    
    -- Revenue (Doanh thu)
    SUM(CASE 
        WHEN i.type = 'Income' AND i.paymentStatus = 'PAID' 
        THEN i.amount ELSE 0 
    END) AS revenue,
    
    -- Expense (Chi phí)
    SUM(CASE 
        WHEN i.type = 'Expense' AND i.paymentStatus = 'PAID' 
        THEN i.amount ELSE 0 
    END) AS expense,
    
    -- AR Balance (Công nợ phải thu)
    SUM(CASE 
        WHEN i.type = 'Income' AND i.paymentStatus IN ('UNPAID', 'OVERDUE')
        THEN (i.amount - COALESCE(ph.totalPaid, 0)) ELSE 0 
    END) AS arBalance,
    
    -- Invoices due in 7 days
    COUNT(CASE 
        WHEN i.type = 'Income' 
        AND i.paymentStatus = 'UNPAID'
        AND i.dueDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
        THEN 1 END
    ) AS invoicesDueIn7Days,
    
    -- Overdue invoices
    COUNT(CASE 
        WHEN i.type = 'Income' 
        AND i.paymentStatus = 'OVERDUE'
        THEN 1 END
    ) AS overdueInvoices,
    
    -- Collection rate (Tỷ lệ thu hồi)
    CASE 
        WHEN SUM(CASE WHEN i.type = 'Income' THEN i.amount ELSE 0 END) > 0
        THEN ROUND(
            (SUM(CASE WHEN i.type = 'Income' AND i.paymentStatus = 'PAID' THEN i.amount ELSE 0 END) * 100.0) /
            SUM(CASE WHEN i.type = 'Income' THEN i.amount ELSE 0 END),
            2
        )
        ELSE 0
    END AS collectionRate,
    
    -- Expense to Revenue ratio
    CASE 
        WHEN SUM(CASE WHEN i.type = 'Income' AND i.paymentStatus = 'PAID' THEN i.amount ELSE 0 END) > 0
        THEN ROUND(
            (SUM(CASE WHEN i.type = 'Expense' AND i.paymentStatus = 'PAID' THEN i.amount ELSE 0 END) * 100.0) /
            SUM(CASE WHEN i.type = 'Income' AND i.paymentStatus = 'PAID' THEN i.amount ELSE 0 END),
            2
        )
        ELSE 0
    END AS expenseToRevenueRatio

FROM invoices i
JOIN branches b ON i.branchId = b.branchId
LEFT JOIN (
    SELECT invoiceId, SUM(amount) AS totalPaid
    FROM payment_history
    GROUP BY invoiceId
) ph ON i.invoiceId = ph.invoiceId
WHERE i.status = 'ACTIVE'
GROUP BY b.branchId, b.branchName, DATE(i.invoiceDate);

-- View: Revenue Report
DROP VIEW IF EXISTS v_revenue_report;

CREATE VIEW v_revenue_report AS
SELECT 
    i.invoiceId,
    i.invoiceNumber,
    i.invoiceDate,
    i.amount,
    i.paymentStatus,
    i.paymentMethod,
    i.dueDate,
    i.paymentTerms,
    i.vatAmount,
    i.subtotal,
    b.branchId,
    b.branchName,
    c.customerId,
    c.fullName AS customerName,
    c.phone AS customerPhone,
    c.email AS customerEmail,
    bk.bookingId,
    COALESCE(ph.totalPaid, 0) AS paidAmount,
    (i.amount - COALESCE(ph.totalPaid, 0)) AS balance,
    CASE 
        WHEN i.dueDate < CURDATE() AND i.paymentStatus = 'UNPAID' 
        THEN DATEDIFF(CURDATE(), i.dueDate)
        ELSE NULL
    END AS daysOverdue
FROM invoices i
JOIN branches b ON i.branchId = b.branchId
LEFT JOIN customers c ON i.customerId = c.customerId
LEFT JOIN bookings bk ON i.bookingId = bk.bookingId
LEFT JOIN (
    SELECT invoiceId, SUM(amount) AS totalPaid
    FROM payment_history
    GROUP BY invoiceId
) ph ON i.invoiceId = ph.invoiceId
WHERE i.type = 'Income' AND i.status = 'ACTIVE';

-- View: Expense Report
DROP VIEW IF EXISTS v_expense_report;

CREATE VIEW v_expense_report AS
SELECT 
    i.invoiceId,
    i.invoiceNumber,
    i.invoiceDate,
    i.amount,
    i.costType,
    i.paymentStatus,
    i.paymentMethod,
    b.branchId,
    b.branchName,
    v.vehicleId,
    v.licensePlate,
    d.driverId,
    u.fullName AS driverName,
    i.note,
    i.createdAt
FROM invoices i
JOIN branches b ON i.branchId = b.branchId
LEFT JOIN trips t ON i.bookingId = t.bookingId
LEFT JOIN trip_vehicles tv ON t.tripId = tv.tripId
LEFT JOIN vehicles v ON tv.vehicleId = v.vehicleId
LEFT JOIN trip_drivers td ON t.tripId = td.tripId
LEFT JOIN drivers d ON td.driverId = d.driverId
LEFT JOIN employees e ON d.employeeId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE i.type = 'Expense' AND i.status = 'ACTIVE';

-- ==========================================================
-- 5. Trigger: Auto-update payment status to OVERDUE
-- ==========================================================

DELIMITER $$

DROP TRIGGER IF EXISTS trg_check_overdue_invoices$$

CREATE TRIGGER trg_check_overdue_invoices
BEFORE UPDATE ON invoices
FOR EACH ROW
BEGIN
    -- Nếu dueDate đã qua và paymentStatus vẫn là UNPAID, chuyển sang OVERDUE
    -- Note: Trigger này sẽ chạy khi update, nhưng tốt hơn là dùng scheduled job
    -- IF NEW.dueDate IS NOT NULL 
    --    AND NEW.dueDate < CURDATE() 
    --    AND NEW.paymentStatus = 'UNPAID' 
    --    AND OLD.paymentStatus = 'UNPAID' THEN
    --     SET NEW.paymentStatus = 'OVERDUE';
    -- END IF;
END$$

DELIMITER ;

-- ==========================================================
-- 6. Function: Generate Invoice Number
-- ==========================================================

DELIMITER $$

DROP FUNCTION IF EXISTS generate_invoice_number$$

CREATE FUNCTION generate_invoice_number(branch_id INT, invoice_date DATE)
RETURNS VARCHAR(50)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE branch_code VARCHAR(10);
    DECLARE year_str VARCHAR(4);
    DECLARE sequence_num INT;
    
    -- Lấy mã chi nhánh (từ branchName hoặc branchId)
    SELECT 
        CASE branch_id
            WHEN 1 THEN 'HN'
            WHEN 2 THEN 'DN'
            WHEN 3 THEN 'HCM'
            WHEN 4 THEN 'HP'
            WHEN 5 THEN 'QN'
            ELSE CONCAT('B', branch_id)
        END INTO branch_code;
    
    SET year_str = YEAR(invoice_date);
    
    -- Lấy sequence number tiếp theo
    SELECT COALESCE(MAX(CAST(SUBSTRING_INDEX(invoiceNumber, '-', -1) AS UNSIGNED)), 0) + 1
    INTO sequence_num
    FROM invoices
    WHERE branchId = branch_id
      AND YEAR(invoiceDate) = YEAR(invoice_date)
      AND invoiceNumber IS NOT NULL
      AND invoiceNumber LIKE CONCAT('INV-', branch_code, '-', year_str, '-%');
    
    RETURN CONCAT('INV-', branch_code, '-', year_str, '-', LPAD(sequence_num, 4, '0'));
END$$

DELIMITER ;

-- ==========================================================
-- Migration completed!
-- ==========================================================

