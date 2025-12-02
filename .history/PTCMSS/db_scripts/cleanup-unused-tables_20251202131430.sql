-- Script xóa các bảng DƯ THỪA trong database
-- Chạy script này để dọn dẹp database

USE ptcmss_db;

-- ============================================
-- 1. XÓA BẢNG accounts_receivable 
-- Lý do: Duplicate với invoices + payment_history, không sử dụng
-- ============================================
DROP TABLE IF EXISTS `accounts_receivable`;

-- ============================================
-- 2. XÓA BẢNG debt_reminder_history
-- Lý do: Tính năng nhắc nợ chưa triển khai
-- ============================================
DROP TABLE IF EXISTS `debt_reminder_history`;

-- ============================================
-- 3. XÓA BẢNG deposits  
-- Lý do: Duplicate 100% với payment_history (có field isDeposit)
-- ============================================
DROP TABLE IF EXISTS `deposits`;

-- ============================================
-- 4. XÓA BẢNG trip_incidents (nếu chưa dùng)
-- Lý do: Tính năng quản lý sự cố chưa triển khai
-- Uncomment nếu muốn xóa:
-- ============================================
-- DROP TABLE IF EXISTS `trip_incidents`;

-- ============================================
-- 5. XÓA VIEW không sử dụng
-- ============================================
-- Kiểm tra xem các view này có đang dùng không
-- DROP VIEW IF EXISTS `v_popularroutes`;
-- DROP VIEW IF EXISTS `v_tripdistanceanalytics`;

-- ============================================
-- 6. VERIFY kết quả
-- ============================================
SELECT 
    TABLE_NAME, 
    TABLE_TYPE,
    CREATE_TIME,
    TABLE_ROWS
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'ptcmss_db'
ORDER BY TABLE_NAME;

-- ============================================
-- 7. THÊM CỘT depositAmount vào bookings
-- Lý do: Backend đang dùng nhưng database chưa có
-- ============================================
ALTER TABLE `bookings` 
ADD COLUMN `depositAmount` decimal(12,2) DEFAULT 0.00 
AFTER `estimatedCost`;

-- Verify
SHOW COLUMNS FROM bookings LIKE 'depositAmount';
