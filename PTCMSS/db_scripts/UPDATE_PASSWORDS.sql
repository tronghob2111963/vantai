-- ==========================================================
-- UPDATE PASSWORDS - Cập nhật mật khẩu thật cho các user
-- ==========================================================
-- 
-- ⚠️ QUAN TRỌNG: Tất cả user đều dùng password: "123456"
-- Hash BCrypt cho password "123456" (đã verify đúng)
-- ==========================================================

USE ptcmss_db;

-- Hash BCrypt cho password "123456" (verified)
-- BCrypt hash này được generate từ Spring Security BCryptPasswordEncoder
-- Mỗi lần generate sẽ khác nhau do salt, nhưng đều match với "123456"
SET @password_hash = '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lq';

-- Cập nhật password cho TẤT CẢ users
UPDATE Users 
SET passwordHash = @password_hash,
    status = 'ACTIVE'  -- ⚠️ QUAN TRỌNG: Phải là 'ACTIVE' (chữ hoa) để match với enum UserStatus.ACTIVE
WHERE username IN (
    'admin',
    'manager_hn', 'manager_dn', 'manager_hcm',
    'consultant_hn1', 'consultant_hn2',
    'accountant_hn1',
    'driver_a', 'driver_b', 'driver_c', 'driver_d', 
    'driver_e', 'driver_f', 'driver_g'
);

-- ==========================================================
-- THÔNG TIN ĐĂNG NHẬP:
-- ==========================================================
-- Username: admin          | Password: 123456
-- Username: manager_hn     | Password: 123456
-- Username: manager_dn     | Password: 123456
-- Username: manager_hcm    | Password: 123456
-- Username: consultant_hn1 | Password: 123456
-- Username: consultant_hn2 | Password: 123456
-- Username: accountant_hn1 | Password: 123456
-- Username: driver_a       | Password: 123456
-- Username: driver_b       | Password: 123456
-- Username: driver_c       | Password: 123456
-- Username: driver_d       | Password: 123456
-- Username: driver_e       | Password: 123456
-- Username: driver_f       | Password: 123456
-- Username: driver_g       | Password: 123456
-- ==========================================================

