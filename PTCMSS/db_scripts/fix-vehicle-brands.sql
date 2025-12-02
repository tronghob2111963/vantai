-- Fix missing vehicle brands
-- Run this script to update existing vehicles with proper brand names

USE ptcmss;

UPDATE vehicles SET brand = 'Ford' WHERE vehicleId = 1;
UPDATE vehicles SET brand = 'DCar' WHERE vehicleId = 2;
UPDATE vehicles SET brand = 'Samco' WHERE vehicleId = 3;
UPDATE vehicles SET brand = 'Hyundai' WHERE vehicleId = 4;
UPDATE vehicles SET brand = 'Ford' WHERE vehicleId = 5;
UPDATE vehicles SET brand = 'Hyundai' WHERE vehicleId = 6;
UPDATE vehicles SET brand = 'Thaco' WHERE vehicleId = 7;

-- Verify the update
SELECT vehicleId, licensePlate, brand, model FROM vehicles ORDER BY vehicleId;
