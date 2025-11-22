-- ==========================================================
-- Migration Script: Convert all table names to snake_case
-- ==========================================================
-- 
-- MỤC ĐÍCH: Đổi tên tất cả tables từ lowercase/camelCase sang snake_case
-- 
-- LƯU Ý QUAN TRỌNG:
-- 1. BACKUP DATABASE TRƯỚC KHI CHẠY SCRIPT NÀY!
-- 2. Script này sẽ đổi tên tables, nhưng KHÔNG đổi tên columns
-- 3. Foreign keys sẽ được tự động cập nhật
-- 4. Views cần được recreate sau khi đổi tên tables
--
-- CÁCH CHẠY:
-- mysql -u root -p ptcmss_db < 01_MIGRATE_TO_SNAKE_CASE.sql
--
-- ==========================================================

USE ptcmss_db;

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================================
-- 1. Đổi tên các tables từ lowercase → snake_case
-- ==========================================================

-- accountsreceivable → accounts_receivable
RENAME TABLE `accountsreceivable` TO `accounts_receivable`;

-- bookingvehicledetails → booking_vehicle_details
RENAME TABLE `bookingvehicledetails` TO `booking_vehicle_details`;

-- driverdayoff → driver_day_off
RENAME TABLE `driverdayoff` TO `driver_day_off`;

-- hiretypes → hire_types
RENAME TABLE `hiretypes` TO `hire_types`;

-- systemsettings → system_settings
RENAME TABLE `systemsettings` TO `system_settings`;

-- tripdrivers → trip_drivers
RENAME TABLE `tripdrivers` TO `trip_drivers`;

-- triproutecache → trip_route_cache
RENAME TABLE `triproutecache` TO `trip_route_cache`;

-- tripvehicles → trip_vehicles
RENAME TABLE `tripvehicles` TO `trip_vehicles`;

-- vehiclecategorypricing → vehicle_category_pricing
RENAME TABLE `vehiclecategorypricing` TO `vehicle_category_pricing`;

-- ==========================================================
-- 2. Các tables đã đúng snake_case (giữ nguyên)
-- ==========================================================
-- bookings (đã đúng - 1 từ)
-- branches (đã đúng - 1 từ)
-- customers (đã đúng - 1 từ)
-- drivers (đã đúng - 1 từ)
-- employees (đã đúng - 1 từ)
-- invoices (đã đúng - 1 từ)
-- notifications (đã đúng - 1 từ)
-- roles (đã đúng - 1 từ)
-- token (đã đúng - 1 từ)
-- trips (đã đúng - 1 từ)
-- users (đã đúng - 1 từ)
-- vehicles (đã đúng - 1 từ)

-- ==========================================================
-- 3. Các tables có thể cần thêm (nếu có trong DB nhưng chưa có trong dump)
-- ==========================================================
-- Nếu có các tables sau, cần đổi tên:
-- approval_history (đã đúng snake_case)
-- expense_requests (đã đúng snake_case)
-- system_alerts (đã đúng snake_case)
-- trip_assignment_history (đã đúng snake_case)
-- trip_incidents (đã đúng snake_case)

-- ==========================================================
-- 4. Recreate Views (vì views reference đến table names)
-- ==========================================================

-- Drop existing views
DROP VIEW IF EXISTS `v_drivermonthlyperformance`;
DROP VIEW IF EXISTS `v_popularroutes`;
DROP VIEW IF EXISTS `v_tripdistanceanalytics`;

-- Recreate v_drivermonthlyperformance với table names mới
CREATE VIEW `v_drivermonthlyperformance` AS
SELECT 
    d.driverId AS driverId,
    YEAR(t.startTime) AS year,
    MONTH(t.startTime) AS month,
    COUNT(DISTINCT td.tripId) AS tripsCount,
    SUM(
        CASE 
            WHEN td.startTime IS NOT NULL AND td.endTime IS NOT NULL 
            THEN TIMESTAMPDIFF(MINUTE, td.startTime, td.endTime) 
            ELSE 0 
        END
    ) AS minutesOnTrip
FROM trip_drivers td
JOIN drivers d ON d.driverId = td.driverId
JOIN trips t ON t.tripId = td.tripId
GROUP BY d.driverId, YEAR(t.startTime), MONTH(t.startTime);

-- Recreate v_popularroutes với table names mới
CREATE VIEW `v_popularroutes` AS
SELECT 
    trc.startLocation AS startLocation,
    trc.endLocation AS endLocation,
    COUNT(*) AS cacheEntryCount,
    AVG(trc.distance) AS avgDistance,
    AVG(trc.duration) AS avgDuration,
    SUM(trc.hitCount) AS totalCacheHits,
    MAX(trc.lastUsedAt) AS lastUsed,
    MAX(trc.createdAt) AS lastCached
FROM trip_route_cache trc
WHERE trc.createdAt >= (NOW() - INTERVAL 30 DAY)
GROUP BY trc.startLocation, trc.endLocation
HAVING SUM(trc.hitCount) > 0
ORDER BY totalCacheHits DESC, lastUsed DESC
LIMIT 100;

-- Recreate v_tripdistanceanalytics với table names mới
CREATE VIEW `v_tripdistanceanalytics` AS
SELECT 
    t.tripId AS tripId,
    t.bookingId AS bookingId,
    b.branchId AS branchId,
    br.branchName AS branchName,
    t.startLocation AS startLocation,
    t.endLocation AS endLocation,
    t.distance AS distance,
    t.estimatedDuration AS estimatedDuration,
    t.actualDuration AS actualDuration,
    CASE 
        WHEN t.actualDuration IS NOT NULL AND t.estimatedDuration IS NOT NULL 
        THEN ROUND(((t.actualDuration - t.estimatedDuration) / t.estimatedDuration) * 100, 2)
        ELSE NULL 
    END AS durationVariancePercent,
    t.trafficStatus AS trafficStatus,
    t.status AS tripStatus,
    t.startTime AS startTime,
    t.endTime AS endTime,
    TIMESTAMPDIFF(MINUTE, t.startTime, t.endTime) AS actualTripDuration
FROM trips t
JOIN bookings b ON t.bookingId = b.bookingId
JOIN branches br ON b.branchId = br.branchId
WHERE t.distance IS NOT NULL;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================================
-- 5. Verify migration
-- ==========================================================
-- Chạy các lệnh sau để kiểm tra:
-- SHOW TABLES;
-- DESCRIBE accounts_receivable;
-- DESCRIBE booking_vehicle_details;
-- DESCRIBE driver_day_off;
-- DESCRIBE hire_types;
-- DESCRIBE system_settings;
-- DESCRIBE trip_drivers;
-- DESCRIBE trip_route_cache;
-- DESCRIBE trip_vehicles;
-- DESCRIBE vehicle_category_pricing;

-- ==========================================================
-- Migration completed!
-- ==========================================================
-- Sau khi chạy script này, cần:
-- 1. Update @Table annotation trong tất cả entities
-- 2. Update native queries trong code
-- 3. Test tất cả API endpoints
-- ==========================================================

