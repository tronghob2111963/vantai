-- ==========================================================
-- UPDATE BOOKING STATUS ENUM (SIMPLE VERSION)
-- ==========================================================
-- Script này sẽ cập nhật ENUM status của bảng Bookings
-- Cách đơn giản: ALTER TABLE với MODIFY COLUMN
-- ==========================================================

USE ptcmss_db;

-- Cập nhật ENUM status (MySQL 8.0+ hỗ trợ MODIFY ENUM)
ALTER TABLE Bookings 
MODIFY COLUMN status ENUM('PENDING','QUOTATION_SENT','CONFIRMED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'PENDING';

-- Cập nhật dữ liệu cũ: INPROGRESS -> IN_PROGRESS (nếu có)
UPDATE Bookings 
SET status = 'IN_PROGRESS' 
WHERE status = 'INPROGRESS';

-- Verify
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db' 
  AND TABLE_NAME = 'Bookings'
  AND COLUMN_NAME = 'status';

-- Kiểm tra dữ liệu
SELECT status, COUNT(*) as count 
FROM Bookings 
GROUP BY status;

-- ==========================================================
-- LƯU Ý:
-- - Script này sẽ thay đổi ENUM definition
-- - Dữ liệu cũ sẽ được giữ nguyên (trừ INPROGRESS -> IN_PROGRESS)
-- - Nếu MySQL version < 8.0, có thể cần dùng script phức tạp hơn
-- ==========================================================

