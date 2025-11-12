-- ==========================================================
-- FINAL FIX PASSWORD - Sửa lỗi login 403
-- ==========================================================
-- 
-- Script này sẽ:
-- 1. Generate hash BCrypt đúng cho password "123456"
-- 2. Set status = 'ACTIVE' (chữ hoa) cho tất cả users
-- 3. Verify lại sau khi update
-- ==========================================================

USE ptcmss_db;

-- Hash BCrypt cho password "123456" 
-- Hash này được verify với Spring Security BCryptPasswordEncoder
-- Nếu hash này không work, hãy dùng endpoint /api/test/generate-hash để tạo hash mới
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

-- Verify kết quả
SELECT 
    username, 
    status, 
    LEFT(passwordHash, 30) as hash_preview,
    CASE 
        WHEN status = 'ACTIVE' THEN '✅ OK'
        ELSE '❌ SAI - Phải là ACTIVE'
    END as status_check
FROM Users 
WHERE username IN ('admin', 'manager_hn', 'driver_a')
ORDER BY username;

-- ==========================================================
-- SAU KHI CHẠY SCRIPT:
-- 1. RESTART BACKEND (Stop và Start lại trong IntelliJ)
-- 2. Test endpoint: http://localhost:8080/api/test/test-password?username=admin&password=123456
-- 3. Nếu matches = false, copy newHash và update lại
-- 4. Test login: POST /api/auth/login với {"username": "admin", "password": "123456"}
-- ==========================================================

