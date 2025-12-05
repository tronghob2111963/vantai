-- Script để thêm các system settings cho phụ phí ngày lễ và cuối tuần
-- Chạy script này nếu các settings này chưa có trong database

USE ptcmss_db;

-- Thêm HOLIDAY_SURCHARGE_RATE nếu chưa có
INSERT INTO system_settings (settingKey, settingValue, effectiveStartDate, effectiveEndDate, valueType, category, description, updatedBy, updatedAt, status)
SELECT 'HOLIDAY_SURCHARGE_RATE', '0.25', '2025-01-01', NULL, 'decimal', 'Pricing', 'Phụ thu ngày lễ (25%)', 1, NOW(), 'ACTIVE'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE settingKey = 'HOLIDAY_SURCHARGE_RATE'
);

-- Thêm WEEKEND_SURCHARGE_RATE nếu chưa có
INSERT INTO system_settings (settingKey, settingValue, effectiveStartDate, effectiveEndDate, valueType, category, description, updatedBy, updatedAt, status)
SELECT 'WEEKEND_SURCHARGE_RATE', '0.20', '2025-01-01', NULL, 'decimal', 'Pricing', 'Phụ thu cuối tuần (20%)', 1, NOW(), 'ACTIVE'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE settingKey = 'WEEKEND_SURCHARGE_RATE'
);

-- Kiểm tra kết quả
SELECT settingKey, settingValue, description, category 
FROM system_settings 
WHERE settingKey IN ('HOLIDAY_SURCHARGE_RATE', 'WEEKEND_SURCHARGE_RATE')
ORDER BY settingKey;

