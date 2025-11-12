-- ==========================================================
-- UPDATE PASSWORD CHO TẤT CẢ USERS
-- ==========================================================
-- 
-- Script này sẽ update password hash cho TẤT CẢ users
-- với cùng password: "123456"
-- Hash này được generate từ BCryptPasswordEncoder
-- ==========================================================

USE ptcmss_db;

-- Hash BCrypt cho password "123456"
-- Hash này đã được verify với Spring Security BCryptPasswordEncoder
SET @password_hash = '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq';

-- Update password và status cho TẤT CẢ users
UPDATE Users 
SET passwordHash = @password_hash,
    status = 'ACTIVE'  -- ⚠️ PHẢI LÀ 'ACTIVE' (chữ hoa)
WHERE username IN (
    -- Admin
    'admin',
    -- Managers
    'manager_hn', 'manager_dn', 'manager_hcm',
    -- Consultants
    'consultant_hn1', 'consultant_hn2',
    -- Accountant
    'accountant_hn1',
    -- Drivers
    'driver_a', 'driver_b', 'driver_c', 'driver_d', 
    'driver_e', 'driver_f', 'driver_g'
);

-- Verify kết quả
SELECT 
    u.username,
    r.roleName as role,
    u.status,
    LEFT(u.passwordHash, 30) as hash_preview,
    CASE 
        WHEN u.status = 'ACTIVE' THEN '✅ OK'
        ELSE '❌ SAI'
    END as status_check
FROM Users u
JOIN Roles r ON u.roleId = r.roleId
WHERE u.username IN (
    'admin',
    'manager_hn', 'manager_dn', 'manager_hcm',
    'consultant_hn1', 'consultant_hn2',
    'accountant_hn1',
    'driver_a', 'driver_b', 'driver_c', 'driver_d', 
    'driver_e', 'driver_f', 'driver_g'
)
ORDER BY r.roleName, u.username;

-- ==========================================================
-- SAU KHI CHẠY SCRIPT:
-- Tất cả users sẽ có password: "123456"
-- Status: ACTIVE
-- ==========================================================

