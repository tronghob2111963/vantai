-- =====================================================
-- PTCMSS Database Initialization Script
-- This script will be executed automatically by Spring Boot
-- =====================================================

-- Insert Roles
INSERT IGNORE INTO roles (roleId, roleName, description, status) VALUES
(1, 'Admin', 'Quản trị viên hệ thống', 'ACTIVE'),
(2, 'Manager', 'Quản lý chi nhánh', 'ACTIVE'),
(3, 'Consultant', 'Tư vấn viên', 'ACTIVE'),
(4, 'Driver', 'Tài xế', 'ACTIVE'),
(5, 'Accountant', 'Kế toán', 'ACTIVE'),
(6, 'Coordinator', 'Điều phối viên', 'ACTIVE');

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
-- Giá/km theo yêu cầu: Xe 16 chỗ = 30k, Xe 30 chỗ = 40k, Xe 45 chỗ = 50k
-- Giá cố định chuyến trong ngày: Xe 16 = 2,500,000đ (chưa cao tốc), Xe 30 = 3,000,000đ
INSERT IGNORE INTO vehicle_category_pricing (categoryId, categoryName, seats, description, baseFare, pricePerKm, highwayFee, fixedCosts, sameDayFixedPrice, isPremium, premiumSurcharge, effectiveDate, status, createdAt) VALUES
(1, 'Xe 9 chỗ (Limousine)', 9, 'DCar/Solati Limousine', 900000.00, 15000.00, 100000.00, 0.00, NULL, FALSE, 0.00, CURDATE(), 'ACTIVE', NOW()),
(2, 'Xe 16 chỗ', 16, 'Ford Transit, Mercedes Sprinter', 1100000.00, 30000.00, 300000.00, 0.00, 2500000.00, FALSE, 0.00, CURDATE(), 'ACTIVE', NOW()),
(3, 'Xe 29 chỗ', 29, 'Hyundai County, Samco Isuzu', 1800000.00, 40000.00, 150000.00, 0.00, 3000000.00, FALSE, 0.00, CURDATE(), 'ACTIVE', NOW()),
(4, 'Xe 45 chỗ', 45, 'Hyundai Universe', 2500000.00, 50000.00, 200000.00, 0.00, NULL, FALSE, 0.00, CURDATE(), 'ACTIVE', NOW()),
(5, 'Xe giường nằm (40 chỗ)', 40, 'Xe giường nằm Thaco/Hyundai', 3000000.00, 30000.00, 250000.00, 0.00, NULL, FALSE, 0.00, CURDATE(), 'ACTIVE', NOW());

-- Insert System Settings
INSERT IGNORE INTO system_settings (settingId, settingKey, settingValue, effectiveStartDate, valueType, category, description, updatedBy, updatedAt, status) VALUES
(1, 'VAT_RATE', '0.08', '2025-01-01', 'decimal', 'Billing', 'Tỷ lệ thuế VAT (8%)', 1, NOW(), 'ACTIVE'),
(2, 'DEFAULT_HIGHWAY', 'true', '2025-01-01', 'boolean', 'Booking', 'Mặc định chọn cao tốc khi tạo booking', 1, NOW(), 'ACTIVE'),
(3, 'MAX_DRIVING_HOURS_PER_DAY', '10', '2025-01-01', 'int', 'Driver', 'Số giờ lái xe tối đa của tài xế/ngày', 1, NOW(), 'ACTIVE'),
(4, 'SUPPORT_HOTLINE', '1900 1234', '2025-01-01', 'string', 'General', 'Số hotline hỗ trợ khách hàng', 1, NOW(), 'ACTIVE'),
(5, 'LATE_PAYMENT_FEE_RATE', '0.05', '2025-01-01', 'decimal', 'Billing', 'Lãi suất phạt thanh toán chậm (5%/ngày)', 1, NOW(), 'ACTIVE'),
(6, 'HOLIDAY_SURCHARGE_RATE', '0.25', '2025-01-01', 'decimal', 'Pricing', 'Phụ phí ngày lễ (25%)', 1, NOW(), 'ACTIVE'),
(7, 'WEEKEND_SURCHARGE_RATE', '0.20', '2025-01-01', 'decimal', 'Pricing', 'Phụ phí cuối tuần (20%)', 1, NOW(), 'ACTIVE'),
(8, 'ONE_WAY_DISCOUNT_RATE', '0.6667', '2025-01-01', 'decimal', 'Pricing', 'Hệ số giảm giá 1 chiều (2/3)', 1, NOW(), 'ACTIVE'),
(9, 'ADDITIONAL_POINT_SURCHARGE_RATE', '0.05', '2025-01-01', 'decimal', 'Pricing', 'Phụ phí mỗi điểm đón/trả thêm (5%)', 1, NOW(), 'ACTIVE'),
(10, 'DEFAULT_DEPOSIT_PERCENT', '0.50', '2025-01-01', 'decimal', 'Booking', 'Tỷ lệ đặt cọc mặc định (50%)', 1, NOW(), 'ACTIVE'),
(11, 'MAX_DEPOSIT_PERCENT', '0.70', '2025-01-01', 'decimal', 'Booking', 'Tỷ lệ đặt cọc tối đa (70%)', 1, NOW(), 'ACTIVE'),
(12, 'SINGLE_DRIVER_MAX_DISTANCE_KM', '300', '2025-01-01', 'int', 'Dispatch', 'Quãng đường tối đa cho 1 tài xế (300km cả đi lẫn về)', 1, NOW(), 'ACTIVE'),
(13, 'CANCELLATION_FULL_DEPOSIT_LOSS_HOURS', '24', '2025-01-01', 'int', 'Booking', 'Số giờ trước khởi hành để mất 100% tiền cọc (24h)', 1, NOW(), 'ACTIVE'),
(14, 'CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS', '48', '2025-01-01', 'int', 'Booking', 'Số giờ trước khởi hành để mất một phần tiền cọc (48h)', 1, NOW(), 'ACTIVE'),
(15, 'CANCELLATION_PARTIAL_DEPOSIT_PERCENT', '0.30', '2025-01-01', 'decimal', 'Booking', 'Tỷ lệ mất cọc khi hủy trong khoảng thời gian (30%)', 1, NOW(), 'ACTIVE'),
(16, 'MAX_CONTINUOUS_DRIVING_HOURS', '4', '2025-01-01', 'int', 'Driver', 'Số giờ lái xe liên tục tối đa (4 giờ)', 1, NOW(), 'ACTIVE'),
(17, 'MAX_DRIVING_HOURS_PER_WEEK', '48', '2025-01-01', 'int', 'Driver', 'Số giờ lái xe tối đa mỗi tuần (48 giờ)', 1, NOW(), 'ACTIVE');

-- =====================================================
-- SAMPLE DATA FOR TESTING
-- =====================================================

-- Insert more users
INSERT IGNORE INTO users (userId, roleId, fullName, username, passwordHash, email, phone, status, email_verified, createdAt) VALUES
(2, 2, 'Quản Lý Hà Nội', 'manager_hn', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'manager.hn@ptcmss.com', '0900000002', 'ACTIVE', 1, NOW()),
(3, 3, 'Điều Hành Viên 1', 'consultant1', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'consultant1@ptcmss.com', '0900000003', 'ACTIVE', 1, NOW()),
(4, 4, 'Tài Xế Nguyễn Văn A', 'driver_a', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'driver.a@ptcmss.com', '0912345671', 'ACTIVE', 1, NOW()),
(5, 5, 'Kế Toán 1', 'accountant1', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'accountant1@ptcmss.com', '0900000005', 'ACTIVE', 1, NOW());

-- Insert more employees
INSERT IGNORE INTO employees (employeeId, userId, branchId, roleId, status) VALUES
(2, 2, 1, 2, 'ACTIVE'),
(3, 3, 1, 3, 'ACTIVE'),
(4, 4, 1, 4, 'ACTIVE'),
(5, 5, 1, 5, 'ACTIVE');

-- Insert drivers
INSERT IGNORE INTO drivers (driverId, employeeId, branchId, licenseNumber, licenseClass, licenseExpiry, healthCheckDate, rating, priorityLevel, status, createdAt) VALUES
(1, 4, 1, 'HN12345', 'D', '2028-12-31', '2025-06-01', 5.00, 1, 'AVAILABLE', NOW());

-- Insert vehicles
INSERT IGNORE INTO vehicles (vehicleId, categoryId, branchId, licensePlate, model, brand, capacity, productionYear, registrationDate, inspectionExpiry, status) VALUES
(1, 1, 1, '29A-111.11', 'DCar Limousine', 'DCar', 9, 2023, '2023-01-01', '2026-01-01', 'AVAILABLE'),
(2, 2, 1, '29A-222.22', 'Ford Transit', 'Ford', 16, 2022, '2022-01-01', '2026-01-01', 'AVAILABLE'),
(3, 3, 1, '29A-333.33', 'Samco Isuzu', 'Samco', 29, 2021, '2021-01-01', '2026-01-01', 'AVAILABLE');

-- Insert customers
INSERT IGNORE INTO customers (customerId, fullName, phone, email, address, createdAt, createdBy, status) VALUES
(1, 'Công ty TNHH ABC', '0987654321', 'contact@abc.com', 'Hà Nội', NOW(), 3, 'ACTIVE'),
(2, 'Đoàn du lịch Hướng Việt', '0987654322', 'info@huongviet.vn', 'Hà Nội', NOW(), 3, 'ACTIVE');

-- Insert bookings
INSERT IGNORE INTO bookings (bookingId, customerId, branchId, consultantId, hireTypeId, useHighway, bookingDate, estimatedCost, depositAmount, totalCost, status, note, createdAt) VALUES
(1, 1, 1, 3, 1, 1, NOW(), 1000000.00, 300000.00, 1000000.00, 'COMPLETED', 'Booking mẫu 1', NOW()),
(2, 2, 1, 3, 2, 0, NOW(), 2000000.00, 500000.00, 2000000.00, 'CONFIRMED', 'Booking mẫu 2', NOW());

-- Insert trips
INSERT IGNORE INTO trips (tripId, bookingId, useHighway, startTime, endTime, startLocation, endLocation, distance, status) VALUES
(1, 1, 1, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY), 'Hà Nội', 'Hải Phòng', 120.5, 'COMPLETED'),
(2, 2, 0, NOW(), NULL, 'Hà Nội', 'Ninh Bình', 95.0, 'SCHEDULED');

-- Insert invoices
INSERT IGNORE INTO invoices (invoiceId, branchId, bookingId, customerId, type, amount, paymentMethod, paymentStatus, status, invoiceDate, createdAt) VALUES
(1, 1, 1, 1, 'INCOME', 1000000.00, 'BANK_TRANSFER', 'PAID', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW()),
(2, 1, 2, 2, 'INCOME', 2000000.00, 'CASH', 'UNPAID', 'ACTIVE', NOW(), NOW());
