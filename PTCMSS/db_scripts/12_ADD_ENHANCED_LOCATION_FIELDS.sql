-- ============================================================================
-- Migration: Enhanced Location & Route Tracking
-- Purpose: Add GPS coordinates, duration, route cache for SerpAPI integration
-- Date: 2025-11-20
-- Version: 1.1
-- ============================================================================

USE ptcmss;

-- ============================================================================
-- 1. UPDATE TRIPS TABLE - Add GPS coordinates and duration
-- ============================================================================

ALTER TABLE Trips
ADD COLUMN startLatitude DECIMAL(10, 8) NULL COMMENT 'Start location latitude' AFTER distance,
ADD COLUMN startLongitude DECIMAL(11, 8) NULL COMMENT 'Start location longitude' AFTER startLatitude,
ADD COLUMN endLatitude DECIMAL(10, 8) NULL COMMENT 'End location latitude' AFTER startLongitude,
ADD COLUMN endLongitude DECIMAL(11, 8) NULL COMMENT 'End location longitude' AFTER endLatitude,
ADD COLUMN estimatedDuration INT NULL COMMENT 'Estimated duration in minutes from SerpAPI' AFTER endLongitude,
ADD COLUMN actualDuration INT NULL COMMENT 'Actual duration in minutes after completed' AFTER estimatedDuration,
ADD COLUMN routeData JSON NULL COMMENT 'Detailed route information from SerpAPI' AFTER actualDuration,
ADD COLUMN trafficStatus ENUM('LIGHT', 'MODERATE', 'HEAVY', 'UNKNOWN') DEFAULT 'UNKNOWN' COMMENT 'Traffic status at booking time' AFTER routeData;

-- Create indexes for location-based queries
CREATE INDEX IX_Trips_StartLocation_Coords ON Trips(startLatitude, startLongitude);
CREATE INDEX IX_Trips_EndLocation_Coords ON Trips(endLatitude, endLongitude);
CREATE INDEX IX_Trips_EstimatedDuration ON Trips(estimatedDuration);

-- ============================================================================
-- 2. UPDATE BOOKINGS TABLE - Add total distance and duration
-- ============================================================================

ALTER TABLE Bookings
ADD COLUMN totalDistance DECIMAL(10,2) NULL COMMENT 'Total distance of all trips (km)' AFTER totalCost,
ADD COLUMN totalDuration INT NULL COMMENT 'Total estimated duration (minutes)' AFTER totalDistance;

-- Create index for reporting
CREATE INDEX IX_Bookings_Distance ON Bookings(totalDistance);
CREATE INDEX IX_Bookings_Duration ON Bookings(totalDuration);

-- ============================================================================
-- 3. CREATE ROUTE CACHE TABLE - Reduce SerpAPI calls
-- ============================================================================

CREATE TABLE IF NOT EXISTS TripRouteCache (
  cacheId INT AUTO_INCREMENT PRIMARY KEY,
  startLocation VARCHAR(255) NOT NULL,
  endLocation VARCHAR(255) NOT NULL,
  distance DECIMAL(10,2) NOT NULL COMMENT 'Distance in kilometers',
  duration INT NOT NULL COMMENT 'Duration in minutes',
  startLatitude DECIMAL(10, 8) NULL,
  startLongitude DECIMAL(11, 8) NULL,
  endLatitude DECIMAL(10, 8) NULL,
  endLongitude DECIMAL(11, 8) NULL,
  routeData JSON NULL COMMENT 'Full SerpAPI response',
  trafficStatus ENUM('LIGHT', 'MODERATE', 'HEAVY', 'UNKNOWN') DEFAULT 'UNKNOWN',
  createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expiresAt DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL 7 DAY),
  hitCount INT DEFAULT 0 COMMENT 'Number of times this cache was used',
  lastUsedAt DATETIME NULL,
  INDEX IX_Cache_Locations (startLocation(100), endLocation(100)),
  INDEX IX_Cache_Expires (expiresAt),
  INDEX IX_Cache_HitCount (hitCount DESC)
) ENGINE=InnoDB COMMENT='Cache SerpAPI route calculations to save API quota';

-- ============================================================================
-- 4. CREATE DISTANCE-BASED PRICING TABLE (OPTIONAL)
-- ============================================================================

CREATE TABLE IF NOT EXISTS VehicleCategoryPricingRanges (
  rangeId INT AUTO_INCREMENT PRIMARY KEY,
  vehicleCategoryId INT NOT NULL,
  minDistance DECIMAL(10,2) NOT NULL COMMENT 'Min distance (km)',
  maxDistance DECIMAL(10,2) NULL COMMENT 'Max distance (km), NULL = unlimited',
  pricePerKm DECIMAL(10,2) NOT NULL COMMENT 'Price per kilometer in this range',
  baseFare DECIMAL(10,2) DEFAULT 0 COMMENT 'Base fare for this range',
  description VARCHAR(255) NULL,
  isActive BOOLEAN DEFAULT TRUE,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_range_category FOREIGN KEY (vehicleCategoryId)
    REFERENCES VehicleCategoryPricing(id) ON DELETE CASCADE,
  INDEX IX_Range_Category_Distance (vehicleCategoryId, minDistance, maxDistance)
) ENGINE=InnoDB COMMENT='Tiered pricing based on distance ranges';

-- ============================================================================
-- 5. CREATE STORED PROCEDURE - Get Cached Route
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_GetCachedRoute(
  IN p_startLocation VARCHAR(255),
  IN p_endLocation VARCHAR(255)
)
BEGIN
  DECLARE v_cacheId INT;

  -- Find valid cache entry
  SELECT cacheId INTO v_cacheId
  FROM TripRouteCache
  WHERE startLocation = p_startLocation
    AND endLocation = p_endLocation
    AND expiresAt > NOW()
  ORDER BY createdAt DESC
  LIMIT 1;

  IF v_cacheId IS NOT NULL THEN
    -- Update hit count
    UPDATE TripRouteCache
    SET hitCount = hitCount + 1,
        lastUsedAt = NOW()
    WHERE cacheId = v_cacheId;

    -- Return cached data
    SELECT * FROM TripRouteCache
    WHERE cacheId = v_cacheId;
  ELSE
    -- Return empty result
    SELECT NULL AS cacheId;
  END IF;
END //

DELIMITER ;

-- ============================================================================
-- 6. CREATE EVENT - Auto cleanup expired cache
-- ============================================================================

-- Enable event scheduler if not already enabled
SET GLOBAL event_scheduler = ON;

-- Create event to delete expired cache entries daily
CREATE EVENT IF NOT EXISTS evt_CleanupExpiredRouteCache
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
  DELETE FROM TripRouteCache
  WHERE expiresAt < NOW();

-- ============================================================================
-- 7. CREATE VIEW - Popular Routes (Analytics)
-- ============================================================================

CREATE OR REPLACE VIEW v_PopularRoutes AS
SELECT
  startLocation,
  endLocation,
  COUNT(*) AS tripCount,
  AVG(distance) AS avgDistance,
  AVG(duration) AS avgDuration,
  SUM(hitCount) AS totalCacheHits,
  MAX(lastUsedAt) AS lastUsed
FROM TripRouteCache
WHERE createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY startLocation, endLocation
ORDER BY tripCount DESC
LIMIT 100;

-- ============================================================================
-- 8. SAMPLE DATA - Pricing Ranges (Example)
-- ============================================================================

-- Example: Sedan 4 chỗ (assuming id=1)
-- INSERT INTO VehicleCategoryPricingRanges
--   (vehicleCategoryId, minDistance, maxDistance, pricePerKm, baseFare, description)
-- VALUES
--   (1, 0, 30, 15000, 50000, 'Short distance rate'),
--   (1, 30.01, 100, 12000, 50000, 'Medium distance rate'),
--   (1, 100.01, NULL, 10000, 50000, 'Long distance rate');

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check Trips table structure
SELECT
  COLUMN_NAME,
  DATA_TYPE,
  COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss'
  AND TABLE_NAME = 'Trips'
  AND COLUMN_NAME IN ('distance', 'startLatitude', 'endLatitude', 'estimatedDuration', 'routeData');

-- Check TripRouteCache table
SELECT
  TABLE_NAME,
  TABLE_COMMENT,
  CREATE_TIME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'ptcmss'
  AND TABLE_NAME = 'TripRouteCache';

-- Summary
SELECT
  'Migration completed successfully' AS status,
  (SELECT COUNT(*) FROM Trips) AS total_trips,
  (SELECT COUNT(*) FROM TripRouteCache) AS cached_routes;

COMMIT;

-- ============================================================================
-- ROLLBACK SCRIPT (if needed)
-- ============================================================================

-- Uncomment below to rollback this migration:

-- ALTER TABLE Trips
-- DROP COLUMN startLatitude,
-- DROP COLUMN startLongitude,
-- DROP COLUMN endLatitude,
-- DROP COLUMN endLongitude,
-- DROP COLUMN estimatedDuration,
-- DROP COLUMN actualDuration,
-- DROP COLUMN routeData,
-- DROP COLUMN trafficStatus;

-- ALTER TABLE Bookings
-- DROP COLUMN totalDistance,
-- DROP COLUMN totalDuration;

-- DROP TABLE IF EXISTS VehicleCategoryPricingRanges;
-- DROP TABLE IF EXISTS TripRouteCache;
-- DROP PROCEDURE IF EXISTS sp_GetCachedRoute;
-- DROP EVENT IF EXISTS evt_CleanupExpiredRouteCache;
-- DROP VIEW IF EXISTS v_PopularRoutes;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
