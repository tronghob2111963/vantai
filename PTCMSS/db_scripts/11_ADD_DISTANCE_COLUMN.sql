-- Migration: Add distance column to Trips table
-- Purpose: Store calculated distance from SerpAPI for automatic pricing
-- Date: 2025-11-20

USE ptcmss;

-- Add distance column to Trips table
ALTER TABLE Trips
ADD COLUMN distance DECIMAL(10,2) NULL COMMENT 'Distance in kilometers calculated from SerpAPI'
AFTER endLocation;

-- Update existing trips to have NULL distance (can be manually filled if needed)
-- No data migration needed as this is a new field

COMMIT;

-- Verification
SELECT
    'Trips table schema updated successfully' AS status,
    COUNT(*) AS total_trips
FROM Trips;
