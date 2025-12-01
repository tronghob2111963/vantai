-- Migration: Add OVERDUE to paymentStatus enum in invoices table
-- Date: 2025-12-02
-- Purpose: Fix "Data truncated for column 'paymentStatus'" error when marking invoices as overdue

USE ptcmss;

-- Add OVERDUE to the paymentStatus enum
ALTER TABLE invoices 
MODIFY COLUMN paymentStatus 
ENUM('UNPAID','PAID','REFUNDED','OVERDUE') 
COLLATE utf8mb4_unicode_ci 
DEFAULT 'UNPAID';

-- Verify the change
SELECT COLUMN_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'ptcmss' 
  AND TABLE_NAME = 'invoices' 
  AND COLUMN_NAME = 'paymentStatus';
