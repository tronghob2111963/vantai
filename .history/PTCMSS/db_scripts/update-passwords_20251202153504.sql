-- Update all user passwords to P@ssw0rd123
-- Run this script: mysql -u root -p ptcmss_db < update-passwords.sql

USE ptcmss_db;

-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

UPDATE users SET passwordHash = '$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC';

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Verify the update
SELECT userId, username, email, LEFT(passwordHash, 20) as passwordHash_preview FROM users LIMIT 5;
