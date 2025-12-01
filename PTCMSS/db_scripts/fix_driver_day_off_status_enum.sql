-- ============================================================
-- Fix: Thêm giá trị CANCELLED vào ENUM status của bảng driver_day_off
-- ============================================================
-- Vấn đề: Database chỉ có ENUM('PENDING','APPROVED','REJECTED')
--         nhưng backend cần thêm CANCELLED để hủy yêu cầu nghỉ phép
-- ============================================================

USE ptcmss_db;

-- Kiểm tra cấu trúc hiện tại
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db'
  AND TABLE_NAME = 'driver_day_off'
  AND COLUMN_NAME = 'status';

-- ALTER TABLE để thêm giá trị CANCELLED vào ENUM
ALTER TABLE `driver_day_off` 
MODIFY COLUMN `status` ENUM('PENDING','APPROVED','REJECTED','CANCELLED') 
COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING';

-- Kiểm tra lại cấu trúc sau khi sửa
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db'
  AND TABLE_NAME = 'driver_day_off'
  AND COLUMN_NAME = 'status';

-- Kiểm tra dữ liệu hiện tại
SELECT 
    dayOffId,
    driverId,
    startDate,
    endDate,
    status,
    reason
FROM driver_day_off
ORDER BY createdAt DESC
LIMIT 10;

