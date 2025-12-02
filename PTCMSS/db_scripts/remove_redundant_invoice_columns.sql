-- =====================================================
-- Script: Xóa các cột dư thừa trong bảng invoices
-- Lý do: Các cột này đã có trong bảng payment_history
-- Ngày: 2025-12-02
-- =====================================================

-- Backup dữ liệu trước khi xóa (optional)
-- CREATE TABLE invoices_backup AS SELECT * FROM invoices;

-- Xóa 6 cột dư thừa
ALTER TABLE invoices DROP COLUMN paymentMethod;
ALTER TABLE invoices DROP COLUMN bankName;
ALTER TABLE invoices DROP COLUMN bankAccount;
ALTER TABLE invoices DROP COLUMN referenceNumber;
ALTER TABLE invoices DROP COLUMN cashierName;
ALTER TABLE invoices DROP COLUMN receiptNumber;

-- Kiểm tra kết quả
-- DESCRIBE invoices;
