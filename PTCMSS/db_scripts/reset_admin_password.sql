-- Reset Admin Password Script
-- Chạy lệnh này để reset mật khẩu admin về "123456"

-- Option 1: Reset về password "123456" (hash có sẵn)
UPDATE users 
SET passwordHash = '$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC'
WHERE username = 'admin' AND userId = 1;

-- Kiểm tra kết quả
SELECT userId, username, fullName, email, status 
FROM users 
WHERE username = 'admin';

-- ============================================
-- Nếu muốn đổi sang password khác:
-- Bạn cần generate BCrypt hash mới từ Spring Boot backend
-- 
-- Cách 1: Dùng Spring Boot Test hoặc Controller tạm thời
-- Cách 2: Dùng online BCrypt generator (https://bcrypt-generator.com/)
--         Chọn rounds = 10, nhập password mới, copy hash vào lệnh UPDATE bên dưới
--
-- UPDATE users 
-- SET passwordHash = 'PASTE_NEW_BCRYPT_HASH_HERE'
-- WHERE username = 'admin' AND userId = 1;
-- ============================================

