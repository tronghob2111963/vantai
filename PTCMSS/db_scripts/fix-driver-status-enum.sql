-- Fix driver status ENUM to match backend DriverStatus enum
-- This adds ACTIVE, ON_TRIP, OFF_DUTY status values

USE ptcmss;

-- Step 1: Alter the enum to add new values
ALTER TABLE drivers 
MODIFY COLUMN `status` enum('ACTIVE','AVAILABLE','ON_TRIP','OFF_DUTY','INACTIVE','ONTRIP') 
COLLATE utf8mb4_unicode_ci DEFAULT 'AVAILABLE';

-- Step 2: Migrate old data (optional - convert ONTRIP to ON_TRIP if needed)
-- UPDATE drivers SET status = 'ON_TRIP' WHERE status = 'ONTRIP';

-- Step 3: Verify the change
SELECT driverId, employeeId, status FROM drivers ORDER BY driverId;

-- Show table structure
SHOW CREATE TABLE drivers;
