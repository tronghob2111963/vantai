-- =====================================================
-- Script: 14_CREATE_COMPLETED_TRIPS_FOR_RATING.sql
-- Mục đích: Tạo trips với status COMPLETED để test rating
-- =====================================================

-- Update một số trips hiện có thành COMPLETED
UPDATE Trips 
SET status = 'COMPLETED',
    endTime = NOW()
WHERE tripId IN (1, 2, 3)
AND status != 'COMPLETED';

-- Verify
SELECT 
    t.tripId,
    t.bookingId,
    t.status,
    t.startTime,
    t.endTime,
    td.driverId,
    d.employeeId,
    e.userId,
    u.fullName as driverName
FROM Trips t
LEFT JOIN TripDrivers td ON t.tripId = td.tripId AND td.driverRole = 'Main Driver'
LEFT JOIN Drivers d ON td.driverId = d.driverId
LEFT JOIN Employees e ON d.employeeId = e.employeeId
LEFT JOIN Users u ON e.userId = u.userId
WHERE t.status = 'COMPLETED'
LIMIT 10;

COMMIT;
