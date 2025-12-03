-- Script kiểm tra và bổ sung System Settings còn thiếu
-- Chạy script này để đảm bảo database có đủ 19 settings cần thiết

-- ============================================
-- BƯỚC 1: Kiểm tra settings hiện có
-- ============================================
SELECT 
    '=== KIỂM TRA SETTINGS HIỆN CÓ ===' AS 'Status',
    COUNT(*) AS 'Total Settings',
    COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) AS 'Active Settings'
FROM system_settings;

-- ============================================
-- BƯỚC 2: Liệt kê các settings còn thiếu
-- ============================================
SELECT 
    '=== SETTINGS CÒN THIẾU ===' AS 'Status',
    'Cần thêm các settings sau:' AS 'Note';

-- Danh sách 19 settings bắt buộc
SET @required_settings = 'VAT_RATE,DEFAULT_HIGHWAY,MAX_DRIVING_HOURS_PER_DAY,ROUND_TRIP_MULTIPLIER,DEFAULT_DEPOSIT_PERCENT,CANCELLATION_FULL_DEPOSIT_LOSS_HOURS,CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS,CANCELLATION_PARTIAL_DEPOSIT_PERCENT,BOOKING_MAJOR_MODIFICATION_MIN_HOURS,BOOKING_MINOR_MODIFICATION_MIN_HOURS,SAME_DAY_TRIP_START_HOUR,SAME_DAY_TRIP_END_HOUR,HOLIDAY_SURCHARGE_RATE,WEEKEND_SURCHARGE_RATE,INTER_PROVINCE_DISTANCE_KM,MAX_CONTINUOUS_DRIVING_HOURS,MAX_DRIVING_HOURS_PER_WEEK,MAX_DRIVER_LEAVE_DAYS,SINGLE_DRIVER_MAX_DISTANCE_KM';

-- ============================================
-- BƯỚC 3: Thêm các settings còn thiếu
-- ============================================
-- Sử dụng INSERT IGNORE để tránh duplicate

-- Billing Settings
INSERT IGNORE INTO system_settings (settingKey, settingValue, effectiveStartDate, effectiveEndDate, valueType, category, description, updatedBy, updatedAt, status) VALUES
('VAT_RATE', '0.08', '2025-01-01', NULL, 'decimal', 'Billing', 'Tỷ lệ VAT 8%', 1, NOW(), 'ACTIVE'),
('DEFAULT_DEPOSIT_PERCENT', '0.50', '2025-01-01', NULL, 'decimal', 'Billing', 'Tỷ lệ đặt cọc mặc định (50% tổng tiền)', 1, NOW(), 'ACTIVE');

-- Booking Settings
INSERT IGNORE INTO system_settings (settingKey, settingValue, effectiveStartDate, effectiveEndDate, valueType, category, description, updatedBy, updatedAt, status) VALUES
('DEFAULT_HIGHWAY', 'true', '2025-01-01', NULL, 'boolean', 'Booking', 'Mặc định cao tốc', 1, NOW(), 'ACTIVE'),
('CANCELLATION_FULL_DEPOSIT_LOSS_HOURS', '24', '2025-01-01', NULL, 'int', 'Booking', 'Số giờ trước khi bắt đầu để mất toàn bộ tiền cọc', 1, NOW(), 'ACTIVE'),
('CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS', '48', '2025-01-01', NULL, 'int', 'Booking', 'Số giờ trước khi bắt đầu để mất một phần tiền cọc', 1, NOW(), 'ACTIVE'),
('CANCELLATION_PARTIAL_DEPOSIT_PERCENT', '0.30', '2025-01-01', NULL, 'decimal', 'Booking', 'Tỷ lệ mất cọc khi hủy trong khoảng thời gian (30%)', 1, NOW(), 'ACTIVE'),
('BOOKING_MAJOR_MODIFICATION_MIN_HOURS', '72', '2025-01-01', NULL, 'int', 'Booking', 'Số giờ tối thiểu trước khi bắt đầu để sửa đổi lớn (72h = 3 ngày)', 1, NOW(), 'ACTIVE'),
('BOOKING_MINOR_MODIFICATION_MIN_HOURS', '24', '2025-01-01', NULL, 'int', 'Booking', 'Số giờ tối thiểu trước khi bắt đầu để sửa đổi nhỏ (24h = 1 ngày)', 1, NOW(), 'ACTIVE'),
('SAME_DAY_TRIP_START_HOUR', '6', '2025-01-01', NULL, 'int', 'Booking', 'Giờ bắt đầu để tính chuyến trong ngày (6h sáng)', 1, NOW(), 'ACTIVE'),
('SAME_DAY_TRIP_END_HOUR', '23', '2025-01-01', NULL, 'int', 'Booking', 'Giờ kết thúc để tính chuyến trong ngày (23h tối)', 1, NOW(), 'ACTIVE');

-- Pricing Settings
INSERT IGNORE INTO system_settings (settingKey, settingValue, effectiveStartDate, effectiveEndDate, valueType, category, description, updatedBy, updatedAt, status) VALUES
('ROUND_TRIP_MULTIPLIER', '1.5', '2025-01-01', NULL, 'decimal', 'Pricing', 'Hệ số 2 chiều', 1, NOW(), 'ACTIVE'),
('HOLIDAY_SURCHARGE_RATE', '0.25', '2025-01-01', NULL, 'decimal', 'Pricing', 'Phụ thu ngày lễ (25%)', 1, NOW(), 'ACTIVE'),
('WEEKEND_SURCHARGE_RATE', '0.20', '2025-01-01', NULL, 'decimal', 'Pricing', 'Phụ thu cuối tuần (20%)', 1, NOW(), 'ACTIVE'),
('INTER_PROVINCE_DISTANCE_KM', '100', '2025-01-01', NULL, 'int', 'Pricing', 'Khoảng cách tối thiểu để tính liên tỉnh (km)', 1, NOW(), 'ACTIVE');

-- Driver Settings
INSERT IGNORE INTO system_settings (settingKey, settingValue, effectiveStartDate, effectiveEndDate, valueType, category, description, updatedBy, updatedAt, status) VALUES
('MAX_DRIVING_HOURS_PER_DAY', '10', '2025-01-01', NULL, 'int', 'Driver', 'Tối đa giờ lái/ngày', 1, NOW(), 'ACTIVE'),
('MAX_CONTINUOUS_DRIVING_HOURS', '4', '2025-01-01', NULL, 'int', 'Driver', 'Tối đa giờ lái liên tục (4 giờ)', 1, NOW(), 'ACTIVE'),
('MAX_DRIVING_HOURS_PER_WEEK', '48', '2025-01-01', NULL, 'int', 'Driver', 'Tối đa giờ lái/tuần (48 giờ)', 1, NOW(), 'ACTIVE'),
('MAX_DRIVER_LEAVE_DAYS', '2', '2025-01-01', NULL, 'int', 'Driver', 'Số ngày nghỉ tối đa tài xế có thể xin (2 ngày)', 1, NOW(), 'ACTIVE'),
('SINGLE_DRIVER_MAX_DISTANCE_KM', '300', '2025-01-01', NULL, 'int', 'Driver', 'Khoảng cách tối đa cho 1 tài xế (300km)', 1, NOW(), 'ACTIVE');

-- ============================================
-- BƯỚC 4: Kiểm tra kết quả
-- ============================================
SELECT 
    '=== KẾT QUẢ SAU KHI THÊM ===' AS 'Status',
    COUNT(*) AS 'Total Settings',
    COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) AS 'Active Settings'
FROM system_settings;

-- ============================================
-- BƯỚC 5: Hiển thị tất cả settings theo category
-- ============================================
SELECT 
    category AS 'Danh mục',
    settingKey AS 'Key',
    settingValue AS 'Giá trị',
    description AS 'Mô tả',
    CASE 
        WHEN status = 'ACTIVE' THEN '✓'
        ELSE '✗'
    END AS 'Trạng thái'
FROM system_settings
ORDER BY 
    CASE category
        WHEN 'Billing' THEN 1
        WHEN 'Booking' THEN 2
        WHEN 'Pricing' THEN 3
        WHEN 'Driver' THEN 4
        ELSE 5
    END,
    settingKey;

-- ============================================
-- BƯỚC 6: Cảnh báo nếu thiếu settings quan trọng
-- ============================================
SELECT 
    CASE 
        WHEN COUNT(*) < 19 THEN CONCAT('⚠️ CẢNH BÁO: Thiếu ', 19 - COUNT(*), ' settings!')
        ELSE '✅ Đủ 19 settings bắt buộc'
    END AS 'Kiểm tra'
FROM system_settings
WHERE status = 'ACTIVE'
  AND settingKey IN (
    'VAT_RATE', 'DEFAULT_HIGHWAY', 'MAX_DRIVING_HOURS_PER_DAY', 'ROUND_TRIP_MULTIPLIER',
    'DEFAULT_DEPOSIT_PERCENT', 'CANCELLATION_FULL_DEPOSIT_LOSS_HOURS', 
    'CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS', 'CANCELLATION_PARTIAL_DEPOSIT_PERCENT',
    'BOOKING_MAJOR_MODIFICATION_MIN_HOURS', 'BOOKING_MINOR_MODIFICATION_MIN_HOURS',
    'SAME_DAY_TRIP_START_HOUR', 'SAME_DAY_TRIP_END_HOUR',
    'HOLIDAY_SURCHARGE_RATE', 'WEEKEND_SURCHARGE_RATE', 'INTER_PROVINCE_DISTANCE_KM',
    'MAX_CONTINUOUS_DRIVING_HOURS', 'MAX_DRIVING_HOURS_PER_WEEK',
    'MAX_DRIVER_LEAVE_DAYS', 'SINGLE_DRIVER_MAX_DISTANCE_KM'
  );

