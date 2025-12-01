-- Migration: Update trip status to ASSIGNED for trips that have both driver and vehicle
-- Date: 2025-12-02
-- Description: Fix trips that were assigned before the ASSIGNED status was implemented

-- Step 1: Check current state (optional - for verification)
SELECT 
    t.tripId,
    t.status as current_status,
    COUNT(DISTINCT td.driverId) as driver_count,
    COUNT(DISTINCT tv.vehicleId) as vehicle_count
FROM trips t
LEFT JOIN trip_drivers td ON t.tripId = td.tripId
LEFT JOIN trip_vehicles tv ON t.tripId = tv.tripId
WHERE t.status IN ('SCHEDULED', 'ONGOING')
GROUP BY t.tripId, t.status
HAVING driver_count > 0 AND vehicle_count > 0;

-- Step 2: Update trip status to ASSIGNED
UPDATE trips t
SET t.status = 'ASSIGNED'
WHERE t.status = 'SCHEDULED'
AND EXISTS (
    SELECT 1 FROM trip_drivers td WHERE td.tripId = t.tripId
)
AND EXISTS (
    SELECT 1 FROM trip_vehicles tv WHERE tv.tripId = t.tripId
);

-- Step 3: Verify changes
SELECT 
    status,
    COUNT(*) as count
FROM trips
GROUP BY status;

-- Expected result: Trips with both driver and vehicle should now have status = 'ASSIGNED'
