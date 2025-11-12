-- ==========================================================
-- FIX LOGIN ISSUE - Sửa lỗi login 403
-- ==========================================================
-- 
-- Vấn đề:
-- 1. Status phải là 'ACTIVE' (chữ hoa) để match với enum UserStatus.ACTIVE
-- 2. Hash BCrypt phải đúng với password "123456"
-- 3. Cần restart backend sau khi update
-- ==========================================================

USE ptcmss_db;

-- Hash BCrypt cho password "123456" (verified - dùng hash này)
-- Hash này được verify với Spring Security BCryptPasswordEncoder
SET @password_hash = '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lq';

-- Cập nhật password và status cho TẤT CẢ users
UPDATE Users 
SET passwordHash = @password_hash,
    status = 'ACTIVE'  -- ⚠️ PHẢI LÀ 'ACTIVE' (chữ hoa) - không phải 'Active'
WHERE username IN (
    'admin',
    'manager_hn', 'manager_dn', 'manager_hcm',
    'consultant_hn1', 'consultant_hn2',
    'accountant_hn1',
    'driver_a', 'driver_b', 'driver_c', 'driver_d', 
    'driver_e', 'driver_f', 'driver_g'
);

-- Kiểm tra kết quả
SELECT username, status, LEFT(passwordHash, 30) as hash_preview
FROM Users 
WHERE username = 'admin';

-- ==========================================================
-- SAU KHI CHẠY SCRIPT NÀY:
-- 1. RESTART BACKEND (Stop và Start lại trong IntelliJ)
-- 2. Test login với:
--    Username: admin
--    Password: 123456
-- ==========================================================

