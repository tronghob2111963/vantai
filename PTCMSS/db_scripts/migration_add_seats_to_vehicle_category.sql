-- Migration: Add seats field to vehicle_category_pricing table
-- Date: 2025-11-24
-- Description: Add seats column and populate with data from categoryName

USE ptcmss_db;

-- Step 1: Add seats column
ALTER TABLE vehicle_category_pricing
ADD COLUMN seats INT NULL COMMENT 'Số ghế của danh mục xe'
AFTER categoryName;

-- Step 2: Update existing data with seats based on categoryName
UPDATE vehicle_category_pricing SET seats = 9 WHERE categoryId = 1;   -- Xe 9 chỗ (Limousine)
UPDATE vehicle_category_pricing SET seats = 16 WHERE categoryId = 2;  -- Xe 16 chỗ
UPDATE vehicle_category_pricing SET seats = 29 WHERE categoryId = 3;  -- Xe 29 chỗ
UPDATE vehicle_category_pricing SET seats = 45 WHERE categoryId = 4;  -- Xe 45 chỗ
UPDATE vehicle_category_pricing SET seats = 40 WHERE categoryId = 5;  -- Xe giường nằm (40 chỗ)

-- Step 3: Make seats NOT NULL after populating data (optional - recommended for data integrity)
-- ALTER TABLE vehicle_category_pricing
-- MODIFY COLUMN seats INT NOT NULL COMMENT 'Số ghế của danh mục xe';

-- Verify the changes
SELECT categoryId, categoryName, seats, status
FROM vehicle_category_pricing
ORDER BY categoryId;
