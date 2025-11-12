-- ==========================================================
-- UPDATE PASSWORD HASH từ kết quả test endpoint
-- ==========================================================
-- 
-- Script này sẽ update password hash cho user 'admin' 
-- với hash mới được generate từ endpoint test
-- ==========================================================

USE ptcmss_db;

-- Update password cho admin user
UPDATE Users 
SET passwordHash = '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq',
    status = 'ACTIVE'
WHERE username = 'admin';

-- Verify kết quả
SELECT 
    username, 
    status, 
    LEFT(passwordHash, 30) as hash_preview,
    CASE 
        WHEN status = 'ACTIVE' THEN '✅ OK'
        ELSE '❌ SAI'
    END as status_check
FROM Users 
WHERE username = 'admin';

-- ==========================================================
-- SAU KHI CHẠY SCRIPT:
-- 1. Test lại endpoint: http://localhost:8080/api/test/test-password?username=admin&password=123456
-- 2. Nếu matches = true, test login: POST /api/auth/login
-- 3. Nếu vẫn false, generate hash mới và update lại
-- ==========================================================

