-- ============================================
-- SCRIPT TẠO DATABASE CHO PTCMSS BACKEND
-- ============================================

-- Tạo database
CREATE DATABASE IF NOT EXISTS ptcmss_db 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

-- Sử dụng database
USE ptcmss_db;

-- Kiểm tra database đã tạo
SHOW DATABASES LIKE 'ptcmss_db';

-- Lưu ý: 
-- - Database sẽ được tự động tạo schema bởi Hibernate (ddl-auto: update)
-- - Không cần tạo tables thủ công
-- - Chỉ cần tạo database trống là đủ

-- Nếu muốn xóa và tạo lại database:
-- DROP DATABASE IF EXISTS ptcmss_db;
-- CREATE DATABASE ptcmss_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

