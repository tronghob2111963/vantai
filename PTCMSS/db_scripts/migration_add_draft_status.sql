-- Migration: Add DRAFT status to BookingStatus enum
-- Date: 2025-12-02
-- Description: Expand bookings.status column to support DRAFT status

-- Check current column definition
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db'
  AND TABLE_NAME = 'bookings'
  AND COLUMN_NAME = 'status';

-- Modify column to VARCHAR(20) to support longer status values
ALTER TABLE bookings 
MODIFY COLUMN status VARCHAR(20) NOT NULL DEFAULT 'PENDING';

-- Verify the change
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db'
  AND TABLE_NAME = 'bookings'
  AND COLUMN_NAME = 'status';

-- Test insert with DRAFT status
-- INSERT INTO bookings (branchId, consultantId, customerId, status, totalCost, estimatedCost, depositAmount, bookingDate, createdAt, updatedAt)
-- VALUES (1, 1, 1, 'DRAFT', 0, 0, 0, NOW(), NOW(), NOW());
