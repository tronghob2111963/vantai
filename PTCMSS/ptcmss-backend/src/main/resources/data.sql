-- =====================================================
-- PTCMSS Database Initialization Script
-- This script will be executed automatically by Spring Boot
-- =====================================================

-- Insert Roles
INSERT IGNORE INTO roles (roleId, roleName, description, status) VALUES
(1, 'Admin', 'Quản trị viên hệ thống', 'ACTIVE'),
(2, 'Manager', 'Quản lý chi nhánh', 'ACTIVE'),
(3, 'Consultant', 'Điều hành/Tư vấn', 'ACTIVE'),
(4, 'Driver', 'Tài xế', 'ACTIVE'),
(5, 'Accountant', 'Kế toán', 'ACTIVE');

-- Insert Default Admin User
INSERT IGNORE INTO users (userId, roleId, fullName, username, passwordHash, email, phone, status, email_verified, createdAt) VALUES
(1, 1, 'Admin Tổng', 'admin', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'admin@ptcmss.com', '0900000001', 'ACTIVE', 1, NOW());

-- Insert Default Branch (needed for admin employee)
INSERT IGNORE INTO branches (branchId, branchName, location, managerId, status, createdAt) VALUES
(1, 'Chi nhánh Hà Nội', '123 Láng Hạ, Đống Đa, Hà Nội', NULL, 'ACTIVE', NOW());

-- Insert Admin Employee
INSERT IGNORE INTO employees (employeeId, userId, branchId, roleId, status) VALUES
(1, 1, 1, 1, 'ACTIVE');

-- Insert Hire Types
INSERT IGNORE INTO hire_types (hireTypeId, code, name, description, isActive) VALUES
(1, 'ONE_WAY', 'Thuê 1 chiều', 'Thuê xe đi 1 chiều', 1),
(2, 'ROUND_TRIP', 'Thuê 2 chiều (trong ngày)', 'Thuê xe đi và về trong ngày', 1),
(3, 'MULTI_DAY', 'Thuê nhiều ngày', 'Thuê xe theo gói nhiều ngày', 1),
(4, 'PERIODIC', 'Thuê định kỳ', 'Thuê lặp lại (đưa đón nhân viên, học sinh)', 1),
(5, 'AIRPORT_TRANSFER', 'Đưa/đón sân bay', 'Gói đưa đón sân bay 1 chiều', 1);

-- Insert Vehicle Categories
INSERT IGNORE INTO vehicle_category_pricing (categoryId, categoryName, seats, description, baseFare, pricePerKm, highwayFee, fixedCosts, effectiveDate, status, createdAt) VALUES
(1, 'Xe 9 chỗ (Limousine)', 9, 'DCar/Solati Limousine', 900000.00, 15000.00, 100000.00, 0.00, CURDATE(), 'ACTIVE', NOW()),
(2, 'Xe 16 chỗ', 16, 'Ford Transit, Mercedes Sprinter', 1100000.00, 18000.00, 120000.00, 0.00, CURDATE(), 'ACTIVE', NOW()),
(3, 'Xe 29 chỗ', 29, 'Hyundai County, Samco Isuzu', 1800000.00, 22000.00, 150000.00, 0.00, CURDATE(), 'ACTIVE', NOW()),
(4, 'Xe 45 chỗ', 45, 'Hyundai Universe', 2500000.00, 28000.00, 200000.00, 0.00, CURDATE(), 'ACTIVE', NOW()),
(5, 'Xe giường nằm (40 chỗ)', 40, 'Xe giường nằm Thaco/Hyundai', 3000000.00, 30000.00, 250000.00, 0.00, CURDATE(), 'ACTIVE', NOW());

-- Insert System Settings
INSERT IGNORE INTO system_settings (settingId, settingKey, settingValue, effectiveStartDate, valueType, category, description, updatedBy, updatedAt, status) VALUES
(1, 'VAT_RATE', '0.08', '2025-01-01', 'decimal', 'Billing', 'Tỷ lệ thuế VAT (8%)', 1, NOW(), 'ACTIVE'),
(2, 'DEFAULT_HIGHWAY', 'true', '2025-01-01', 'boolean', 'Booking', 'Mặc định chọn cao tốc khi tạo booking', 1, NOW(), 'ACTIVE'),
(3, 'MAX_DRIVING_HOURS_PER_DAY', '10', '2025-01-01', 'int', 'Driver', 'Số giờ lái xe tối đa của tài xế/ngày', 1, NOW(), 'ACTIVE'),
(4, 'SUPPORT_HOTLINE', '1900 1234', '2025-01-01', 'string', 'General', 'Số hotline hỗ trợ khách hàng', 1, NOW(), 'ACTIVE'),
(5, 'LATE_PAYMENT_FEE_RATE', '0.05', '2025-01-01', 'decimal', 'Billing', 'Lãi suất phạt thanh toán chậm (5%/ngày)', 1, NOW(), 'ACTIVE');
