-- ==========================================================
-- Migration Script: Xóa table driverratings trùng lặp
-- ==========================================================
-- 
-- MỤC ĐÍCH: Xóa table `driverratings` (lowercase) vì đã có `driver_ratings` (snake_case)
-- 
-- LƯU Ý:
-- 1. BACKUP DATABASE TRƯỚC KHI CHẠY SCRIPT NÀY!
-- 2. Kiểm tra xem table `driverratings` có data không
-- 3. Nếu có data, cần migrate data sang `driver_ratings` trước khi xóa
--
-- CÁCH CHẠY:
-- mysql -u root -p ptcmss_db < 03_REMOVE_DUPLICATE_DRIVERRATINGS.sql
--
-- ==========================================================

USE ptcmss_db;

-- ==========================================================
-- 1. Kiểm tra xem có data trong driverratings không
-- ==========================================================

SELECT 
    'driverratings' AS table_name,
    COUNT(*) AS record_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '⚠️ CÓ DATA - CẦN MIGRATE TRƯỚC KHI XÓA!'
        ELSE '✅ KHÔNG CÓ DATA - CÓ THỂ XÓA AN TOÀN'
    END AS status
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' 
  AND table_name = 'driverratings';

-- ==========================================================
-- 2. Nếu có data, migrate sang driver_ratings
-- ==========================================================
-- UNCOMMENT phần này nếu có data cần migrate:

-- INSERT INTO driver_ratings (
--     ratingId, tripId, driverId, customerId,
--     punctualityRating, attitudeRating, safetyRating, complianceRating,
--     overallRating, comment, ratedBy, ratedAt
-- )
-- SELECT 
--     ratingId, tripId, driverId, customerId,
--     punctualityRating, attitudeRating, safetyRating, complianceRating,
--     overallRating, comment, ratedBy, ratedAt
-- FROM driverratings
-- WHERE NOT EXISTS (
--     SELECT 1 FROM driver_ratings dr 
--     WHERE dr.ratingId = driverratings.ratingId
-- );

-- ==========================================================
-- 3. Xóa table driverratings (sau khi đã migrate data nếu cần)
-- ==========================================================

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Drop table driverratings
DROP TABLE IF EXISTS `driverratings`;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================================
-- 4. Verify
-- ==========================================================

SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ OK - Table driverratings đã bị xóa'
        ELSE '❌ VẪN CÒN TỒN TẠI!'
    END AS status
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' 
  AND table_name = 'driverratings';

-- Kiểm tra driver_ratings vẫn còn
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ OK - Table driver_ratings vẫn tồn tại'
        ELSE '❌ MISSING!'
    END AS status
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' 
  AND table_name = 'driver_ratings';

-- ==========================================================
-- Migration completed!
-- ==========================================================

