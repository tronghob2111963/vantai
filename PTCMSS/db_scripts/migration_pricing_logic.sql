-- =====================================================
-- Migration Script: Cập nhật logic báo giá vận tải
-- Date: 2025-01-XX
-- Description: 
--   1. Cập nhật giá/km theo yêu cầu (30k/40k/50k)
--   2. Thêm field xe hạng sang
--   3. Thêm field vào bookings (isHoliday, isWeekend, additionalPoints)
--   4. Thêm SystemSettings cho phụ phí
-- =====================================================

-- 1. Cập nhật giá/km theo yêu cầu
-- Sử dụng categoryId (PRIMARY KEY) để tránh lỗi safe update mode
-- categoryId 2 = Xe 16 chỗ
UPDATE vehicle_category_pricing 
SET pricePerKm = 30000.00 
WHERE categoryId = 2;

-- categoryId 3 = Xe 29 chỗ (cập nhật thành 40k như xe 30 chỗ)
UPDATE vehicle_category_pricing 
SET pricePerKm = 40000.00 
WHERE categoryId = 3;

-- categoryId 4 = Xe 45 chỗ
UPDATE vehicle_category_pricing 
SET pricePerKm = 50000.00 
WHERE categoryId = 4;

-- Nếu có xe 30 chỗ khác (không phải 29 chỗ), cập nhật:
-- UPDATE vehicle_category_pricing 
-- SET pricePerKm = 40000.00 
-- WHERE seats = 30 AND categoryId NOT IN (2, 3, 4);

-- 2. Thêm field giá cố định cho chuyến trong ngày và xe hạng sang
SET @dbname = DATABASE();
SET @tablename = 'vehicle_category_pricing';

-- Kiểm tra và thêm column sameDayFixedPrice (giá cố định cho chuyến trong ngày)
SET @columnname = 'sameDayFixedPrice';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' DECIMAL(10,2) DEFAULT NULL COMMENT ''Giá cố định cho chuyến trong ngày (6h-11h đêm cùng ngày)''')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Kiểm tra và thêm column isPremium
SET @columnname = 'isPremium';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' BOOLEAN DEFAULT FALSE COMMENT ''Đánh dấu xe hạng sang''')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Kiểm tra và thêm column premiumSurcharge
SET @columnname = 'premiumSurcharge';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' DECIMAL(10,2) DEFAULT 1000000.00 COMMENT ''Phụ phí xe hạng sang (VNĐ)''')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 3. Thêm field vào bookings
ALTER TABLE bookings 
ADD COLUMN IF NOT EXISTS isHoliday BOOLEAN DEFAULT FALSE COMMENT 'Có phải ngày lễ không',
ADD COLUMN IF NOT EXISTS isWeekend BOOLEAN DEFAULT FALSE COMMENT 'Có phải cuối tuần không',
ADD COLUMN IF NOT EXISTS additionalPickupPoints INT DEFAULT 0 COMMENT 'Số điểm đón thêm so với ban đầu',
ADD COLUMN IF NOT EXISTS additionalDropoffPoints INT DEFAULT 0 COMMENT 'Số điểm trả thêm so với ban đầu';

-- 4. Thêm SystemSettings cho phụ phí
INSERT IGNORE INTO system_settings (settingKey, settingValue, effectiveStartDate, valueType, category, description, updatedBy, updatedAt, status) VALUES
('HOLIDAY_SURCHARGE_RATE', '0.25', CURDATE(), 'decimal', 'Pricing', 'Phụ phí ngày lễ (25%)', 1, NOW(), 'ACTIVE'),
('WEEKEND_SURCHARGE_RATE', '0.20', CURDATE(), 'decimal', 'Pricing', 'Phụ phí cuối tuần (20%)', 1, NOW(), 'ACTIVE'),
('ONE_WAY_DISCOUNT_RATE', '0.6667', CURDATE(), 'decimal', 'Pricing', 'Hệ số giảm giá 1 chiều (2/3)', 1, NOW(), 'ACTIVE'),
('ADDITIONAL_POINT_SURCHARGE_RATE', '0.05', CURDATE(), 'decimal', 'Pricing', 'Phụ phí mỗi điểm đón/trả thêm (5%)', 1, NOW(), 'ACTIVE');

-- 6. Cập nhật giá cố định cho chuyến trong ngày
-- Xe 16 chỗ: 2,600,000đ (có cao tốc) hoặc 2,500,000đ (chưa cao tốc)
UPDATE vehicle_category_pricing 
SET sameDayFixedPrice = 2500000.00 
WHERE categoryId = 2;

-- Xe 30 chỗ: 3,000,000đ
UPDATE vehicle_category_pricing 
SET sameDayFixedPrice = 3000000.00 
WHERE categoryId = 3;

-- 7. Thêm SystemSettings cho chuyến trong ngày, tiền cọc và hủy đơn
INSERT IGNORE INTO system_settings (settingKey, settingValue, effectiveStartDate, valueType, category, description, updatedBy, updatedAt, status) VALUES
('SAME_DAY_TRIP_START_HOUR', '6', CURDATE(), 'int', 'Pricing', 'Giờ bắt đầu chuyến trong ngày (6h sáng)', 1, NOW(), 'ACTIVE'),
('SAME_DAY_TRIP_END_HOUR', '23', CURDATE(), 'int', 'Pricing', 'Giờ kết thúc chuyến trong ngày (11h đêm)', 1, NOW(), 'ACTIVE'),
('DEFAULT_DEPOSIT_PERCENT', '0.50', CURDATE(), 'decimal', 'Booking', 'Tỷ lệ đặt cọc mặc định (50%)', 1, NOW(), 'ACTIVE'),
('MAX_DEPOSIT_PERCENT', '0.70', CURDATE(), 'decimal', 'Booking', 'Tỷ lệ đặt cọc tối đa (70%)', 1, NOW(), 'ACTIVE'),
('SINGLE_DRIVER_MAX_DISTANCE_KM', '300', CURDATE(), 'int', 'Dispatch', 'Quãng đường tối đa cho 1 tài xế (300km cả đi lẫn về)', 1, NOW(), 'ACTIVE'),
('CANCELLATION_FULL_DEPOSIT_LOSS_HOURS', '24', CURDATE(), 'int', 'Booking', 'Số giờ trước khởi hành để mất 100% tiền cọc (24h)', 1, NOW(), 'ACTIVE'),
('CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS', '48', CURDATE(), 'int', 'Booking', 'Số giờ trước khởi hành để mất một phần tiền cọc (48h)', 1, NOW(), 'ACTIVE'),
('CANCELLATION_PARTIAL_DEPOSIT_PERCENT', '0.30', CURDATE(), 'decimal', 'Booking', 'Tỷ lệ mất cọc khi hủy trong khoảng thời gian (30%)', 1, NOW(), 'ACTIVE'),
('MAX_CONTINUOUS_DRIVING_HOURS', '4', CURDATE(), 'int', 'Driver', 'Số giờ lái xe liên tục tối đa (4 giờ)', 1, NOW(), 'ACTIVE'),
('MAX_DRIVING_HOURS_PER_WEEK', '48', CURDATE(), 'int', 'Driver', 'Số giờ lái xe tối đa mỗi tuần (48 giờ)', 1, NOW(), 'ACTIVE');

-- 8. Cập nhật comment cho các field
ALTER TABLE vehicle_category_pricing 
MODIFY COLUMN pricePerKm DECIMAL(10,2) DEFAULT NULL COMMENT 'Giá mỗi km (VNĐ/km) - Xe 16: 30k, Xe 30: 40k, Xe 45: 50k';

