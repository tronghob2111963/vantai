-- ============================================================================
-- Migration: Add Missing Fields for SerpAPI Integration
-- Purpose: Add only the missing fields to complete the integration
-- Date: 2025-11-20
-- Database: ptcmss_db
-- ============================================================================

USE ptcmss_db;

-- ============================================================================
-- ANALYSIS OF CURRENT DATABASE:
-- ============================================================================
-- ✅ Bookings.totalDistance - ALREADY EXISTS
-- ✅ Bookings.totalDuration - ALREADY EXISTS
-- ✅ TripRouteCache table - ALREADY EXISTS
-- ❌ Trips.distance - MISSING (CRITICAL!)
-- ❌ Trips GPS coordinates - MISSING
-- ❌ Trips.estimatedDuration - MISSING
-- ❌ Trips.actualDuration - MISSING
-- ❌ Trips.routeData - MISSING
-- ❌ Trips.trafficStatus - MISSING
-- ❌ TripRouteCache.trafficStatus - MISSING
-- ❌ TripRouteCache.lastUsedAt - MISSING
-- ============================================================================

-- ============================================================================
-- 1. UPDATE TRIPS TABLE - Add ALL missing fields
-- ============================================================================

ALTER TABLE trips
-- Critical: Distance field (required for SerpAPI integration)
ADD COLUMN distance DECIMAL(10,2) NULL COMMENT 'Distance in kilometers from SerpAPI' AFTER endLocation,

-- GPS Coordinates
ADD COLUMN startLatitude DECIMAL(10,8) NULL COMMENT 'Start location latitude' AFTER distance,
ADD COLUMN startLongitude DECIMAL(11,8) NULL COMMENT 'Start location longitude' AFTER startLatitude,
ADD COLUMN endLatitude DECIMAL(10,8) NULL COMMENT 'End location latitude' AFTER startLongitude,
ADD COLUMN endLongitude DECIMAL(11,8) NULL COMMENT 'End location longitude' AFTER endLatitude,

-- Duration tracking
ADD COLUMN estimatedDuration INT NULL COMMENT 'Estimated duration in minutes from SerpAPI' AFTER endLongitude,
ADD COLUMN actualDuration INT NULL COMMENT 'Actual duration in minutes after completed' AFTER estimatedDuration,

-- Route details
ADD COLUMN routeData JSON NULL COMMENT 'Detailed route information from SerpAPI' AFTER actualDuration,
ADD COLUMN trafficStatus ENUM('LIGHT', 'MODERATE', 'HEAVY', 'UNKNOWN') DEFAULT 'UNKNOWN' COMMENT 'Traffic status at booking time' AFTER routeData;

-- Create indexes for better performance
CREATE INDEX IX_Trips_Distance ON trips(distance);
CREATE INDEX IX_Trips_StartLocation_Coords ON trips(startLatitude, startLongitude);
CREATE INDEX IX_Trips_EndLocation_Coords ON trips(endLatitude, endLongitude);
CREATE INDEX IX_Trips_EstimatedDuration ON trips(estimatedDuration);

-- ============================================================================
-- 2. UPDATE TRIPROUTECACHE TABLE - Add missing fields
-- ============================================================================

ALTER TABLE triproutecache
ADD COLUMN trafficStatus ENUM('LIGHT', 'MODERATE', 'HEAVY', 'UNKNOWN') DEFAULT 'UNKNOWN' COMMENT 'Traffic status when cached' AFTER routeData,
ADD COLUMN lastUsedAt DATETIME NULL COMMENT 'Last time this cache was used' AFTER hitCount;

-- ============================================================================
-- 3. CREATE STORED PROCEDURE - Get/Update Cached Route
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_GetCachedRoute;

DELIMITER //

CREATE PROCEDURE sp_GetCachedRoute(
  IN p_startLocation VARCHAR(255),
  IN p_endLocation VARCHAR(255)
)
BEGIN
  DECLARE v_cacheId INT;

  -- Find valid cache entry (not expired)
  SELECT cacheId INTO v_cacheId
  FROM triproutecache
  WHERE startLocation = p_startLocation
    AND endLocation = p_endLocation
    AND expiresAt > NOW()
  ORDER BY createdAt DESC
  LIMIT 1;

  IF v_cacheId IS NOT NULL THEN
    -- Update hit count and last used time
    UPDATE triproutecache
    SET hitCount = hitCount + 1,
        lastUsedAt = NOW()
    WHERE cacheId = v_cacheId;

    -- Return cached data
    SELECT * FROM triproutecache
    WHERE cacheId = v_cacheId;
  ELSE
    -- Return NULL to indicate cache miss
    SELECT NULL AS cacheId;
  END IF;
END //

DELIMITER ;

-- ============================================================================
-- 4. CREATE STORED PROCEDURE - Save Route to Cache
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_SaveRouteCache;

DELIMITER //

CREATE PROCEDURE sp_SaveRouteCache(
  IN p_startLocation VARCHAR(255),
  IN p_endLocation VARCHAR(255),
  IN p_distance DECIMAL(10,2),
  IN p_duration INT,
  IN p_startLat DECIMAL(10,8),
  IN p_startLng DECIMAL(11,8),
  IN p_endLat DECIMAL(10,8),
  IN p_endLng DECIMAL(11,8),
  IN p_routeData JSON,
  IN p_trafficStatus VARCHAR(20)
)
BEGIN
  -- Insert new cache entry
  INSERT INTO triproutecache (
    startLocation,
    endLocation,
    distance,
    duration,
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
    routeData,
    trafficStatus,
    createdAt,
    expiresAt,
    hitCount
  ) VALUES (
    p_startLocation,
    p_endLocation,
    p_distance,
    p_duration,
    p_startLat,
    p_startLng,
    p_endLat,
    p_endLng,
    p_routeData,
    p_trafficStatus,
    NOW(),
    DATE_ADD(NOW(), INTERVAL 7 DAY),
    0
  );

  -- Return the new cache ID
  SELECT LAST_INSERT_ID() AS cacheId;
END //

DELIMITER ;

-- ============================================================================
-- 5. CREATE EVENT - Auto cleanup expired cache
-- ============================================================================

-- Enable event scheduler if not already enabled
SET GLOBAL event_scheduler = ON;

-- Drop existing event if exists
DROP EVENT IF EXISTS evt_CleanupExpiredRouteCache;

-- Create event to delete expired cache entries daily at 3 AM
CREATE EVENT evt_CleanupExpiredRouteCache
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 3 HOUR)
DO
  DELETE FROM triproutecache
  WHERE expiresAt < NOW();

-- ============================================================================
-- 6. CREATE VIEW - Popular Routes (Analytics)
-- ============================================================================

DROP VIEW IF EXISTS v_PopularRoutes;

CREATE VIEW v_PopularRoutes AS
SELECT
  startLocation,
  endLocation,
  COUNT(*) AS cacheEntryCount,
  AVG(distance) AS avgDistance,
  AVG(duration) AS avgDuration,
  SUM(hitCount) AS totalCacheHits,
  MAX(lastUsedAt) AS lastUsed,
  MAX(createdAt) AS lastCached
FROM triproutecache
WHERE createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY startLocation, endLocation
HAVING SUM(hitCount) > 0
ORDER BY totalCacheHits DESC, lastUsed DESC
LIMIT 100;

-- ============================================================================
-- 7. CREATE VIEW - Trip Distance Analytics
-- ============================================================================

DROP VIEW IF EXISTS v_TripDistanceAnalytics;

CREATE VIEW v_TripDistanceAnalytics AS
SELECT
  t.tripId,
  t.bookingId,
  b.branchId,
  br.branchName,
  t.startLocation,
  t.endLocation,
  t.distance,
  t.estimatedDuration,
  t.actualDuration,
  CASE
    WHEN t.actualDuration IS NOT NULL AND t.estimatedDuration IS NOT NULL
    THEN ROUND(((t.actualDuration - t.estimatedDuration) / t.estimatedDuration) * 100, 2)
    ELSE NULL
  END AS durationVariancePercent,
  t.trafficStatus,
  t.status AS tripStatus,
  t.startTime,
  t.endTime,
  TIMESTAMPDIFF(MINUTE, t.startTime, t.endTime) AS actualTripDuration
FROM trips t
JOIN bookings b ON t.bookingId = b.bookingId
JOIN branches br ON b.branchId = br.branchId
WHERE t.distance IS NOT NULL;

-- ============================================================================
-- 8. CREATE INDEXES FOR BOOKINGS (if not exist)
-- ============================================================================

-- Check and create indexes if they don't exist
-- Note: Your dump shows these already exist, but adding for completeness

-- CREATE INDEX IF NOT EXISTS IX_Bookings_Distance ON bookings(totalDistance);
-- Already exists based on your dump

-- ============================================================================
-- 9. CREATE TRIGGER - Auto-update Booking totalDistance/totalDuration
-- ============================================================================

DROP TRIGGER IF EXISTS trg_UpdateBookingTotals_AfterTripInsert;
DROP TRIGGER IF EXISTS trg_UpdateBookingTotals_AfterTripUpdate;

DELIMITER //

-- Trigger after trip insert
CREATE TRIGGER trg_UpdateBookingTotals_AfterTripInsert
AFTER INSERT ON trips
FOR EACH ROW
BEGIN
  UPDATE bookings
  SET
    totalDistance = (
      SELECT SUM(distance)
      FROM trips
      WHERE bookingId = NEW.bookingId
        AND distance IS NOT NULL
    ),
    totalDuration = (
      SELECT SUM(estimatedDuration)
      FROM trips
      WHERE bookingId = NEW.bookingId
        AND estimatedDuration IS NOT NULL
    )
  WHERE bookingId = NEW.bookingId;
END //

-- Trigger after trip update
CREATE TRIGGER trg_UpdateBookingTotals_AfterTripUpdate
AFTER UPDATE ON trips
FOR EACH ROW
BEGIN
  UPDATE bookings
  SET
    totalDistance = (
      SELECT SUM(distance)
      FROM trips
      WHERE bookingId = NEW.bookingId
        AND distance IS NOT NULL
    ),
    totalDuration = (
      SELECT SUM(estimatedDuration)
      FROM trips
      WHERE bookingId = NEW.bookingId
        AND estimatedDuration IS NOT NULL
    )
  WHERE bookingId = NEW.bookingId;
END //

DELIMITER ;

-- ============================================================================
-- 10. VERIFICATION QUERIES
-- ============================================================================

-- Verify Trips table structure
SELECT
  'Trips columns' AS table_name,
  COLUMN_NAME,
  DATA_TYPE,
  COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db'
  AND TABLE_NAME = 'trips'
  AND COLUMN_NAME IN (
    'distance',
    'startLatitude',
    'startLongitude',
    'endLatitude',
    'endLongitude',
    'estimatedDuration',
    'actualDuration',
    'routeData',
    'trafficStatus'
  )
ORDER BY ORDINAL_POSITION;

-- Verify TripRouteCache updates
SELECT
  'TripRouteCache columns' AS table_name,
  COLUMN_NAME,
  DATA_TYPE,
  COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db'
  AND TABLE_NAME = 'triproutecache'
  AND COLUMN_NAME IN ('trafficStatus', 'lastUsedAt')
ORDER BY ORDINAL_POSITION;

-- Verify indexes
SELECT
  TABLE_NAME,
  INDEX_NAME,
  COLUMN_NAME,
  SEQ_IN_INDEX
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'ptcmss_db'
  AND TABLE_NAME = 'trips'
  AND INDEX_NAME LIKE 'IX_Trips_%'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- Verify stored procedures
SELECT
  ROUTINE_NAME,
  ROUTINE_TYPE,
  CREATED
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'ptcmss_db'
  AND ROUTINE_NAME LIKE 'sp_%Route%'
ORDER BY ROUTINE_NAME;

-- Verify event scheduler
SELECT
  EVENT_NAME,
  STATUS,
  EVENT_TYPE,
  EXECUTE_AT,
  INTERVAL_VALUE,
  INTERVAL_FIELD,
  LAST_EXECUTED
FROM INFORMATION_SCHEMA.EVENTS
WHERE EVENT_SCHEMA = 'ptcmss_db'
  AND EVENT_NAME LIKE '%RouteCache%';

-- Verify views
SELECT
  TABLE_NAME,
  VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'ptcmss_db'
  AND TABLE_NAME LIKE 'v_%Route%' OR TABLE_NAME LIKE 'v_%Distance%'
ORDER BY TABLE_NAME;

-- Final summary
SELECT
  'Migration completed successfully!' AS status,
  (SELECT COUNT(*) FROM trips) AS total_trips,
  (SELECT COUNT(*) FROM triproutecache) AS cached_routes,
  (SELECT COUNT(*) FROM bookings WHERE totalDistance IS NOT NULL) AS bookings_with_distance;

COMMIT;

-- ============================================================================
-- ROLLBACK SCRIPT (if needed - USE WITH CAUTION!)
-- ============================================================================
/*
USE ptcmss_db;

-- Drop triggers
DROP TRIGGER IF EXISTS trg_UpdateBookingTotals_AfterTripInsert;
DROP TRIGGER IF EXISTS trg_UpdateBookingTotals_AfterTripUpdate;

-- Drop views
DROP VIEW IF EXISTS v_PopularRoutes;
DROP VIEW IF EXISTS v_TripDistanceAnalytics;

-- Drop procedures
DROP PROCEDURE IF EXISTS sp_GetCachedRoute;
DROP PROCEDURE IF EXISTS sp_SaveRouteCache;

-- Drop event
DROP EVENT IF EXISTS evt_CleanupExpiredRouteCache;

-- Remove columns from triproutecache
ALTER TABLE triproutecache
DROP COLUMN trafficStatus,
DROP COLUMN lastUsedAt;

-- Remove columns from trips
ALTER TABLE trips
DROP COLUMN distance,
DROP COLUMN startLatitude,
DROP COLUMN startLongitude,
DROP COLUMN endLatitude,
DROP COLUMN endLongitude,
DROP COLUMN estimatedDuration,
DROP COLUMN actualDuration,
DROP COLUMN routeData,
DROP COLUMN trafficStatus;

-- Drop indexes
DROP INDEX IF EXISTS IX_Trips_Distance ON trips;
DROP INDEX IF EXISTS IX_Trips_StartLocation_Coords ON trips;
DROP INDEX IF EXISTS IX_Trips_EndLocation_Coords ON trips;
DROP INDEX IF EXISTS IX_Trips_EstimatedDuration ON trips;

COMMIT;
*/

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
