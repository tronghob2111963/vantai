-- ==========================================================
-- ALTER TABLE Vehicles - Thêm các columns thiếu
-- Chạy script này nếu database đã tồn tại và cần thêm columns
-- ==========================================================

USE ptcmss_db;

-- Thêm các columns mới vào bảng Vehicles
ALTER TABLE Vehicles 
  ADD COLUMN IF NOT EXISTS brand VARCHAR(100) AFTER model,
  ADD COLUMN IF NOT EXISTS insuranceExpiry DATE AFTER inspectionExpiry,
  ADD COLUMN IF NOT EXISTS odometer BIGINT AFTER insuranceExpiry;

-- Kiểm tra kết quả
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db' 
  AND TABLE_NAME = 'Vehicles'
ORDER BY ORDINAL_POSITION;

