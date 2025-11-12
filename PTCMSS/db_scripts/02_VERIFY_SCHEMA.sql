-- ==========================================================
-- Script kiểm tra schema đồng bộ với Entity
-- ==========================================================

USE ptcmss_db;

-- 1. Kiểm tra Vehicles table
SELECT 'Vehicles Table Columns:' AS CheckType;
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db' 
  AND TABLE_NAME = 'Vehicles'
ORDER BY ORDINAL_POSITION;

-- 2. Kiểm tra SystemSettings table
SELECT 'SystemSettings Table Columns:' AS CheckType;
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db' 
  AND TABLE_NAME = 'SystemSettings'
ORDER BY ORDINAL_POSITION;

-- 3. Kiểm tra Drivers table
SELECT 'Drivers Table Columns:' AS CheckType;
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db' 
  AND TABLE_NAME = 'Drivers'
ORDER BY ORDINAL_POSITION;

