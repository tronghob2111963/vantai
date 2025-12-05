-- =====================================================
-- Script cập nhật giá hợp lý cho các loại xe
-- Ngày: 2025-12-06
-- Mục đích: Điều chỉnh PHÍ MỞ CỬA (baseFare) cho phù hợp với chuyến ngắn
-- =====================================================

USE `ptcmss_db`;

-- =====================================================
-- 1. XE 9 CHỖ (LIMOUSINE)
-- =====================================================
-- Hiện tại: baseFare = 900,000 (quá cao cho chuyến ngắn)
-- Đề xuất: baseFare = 200,000 (hợp lý cho chuyến 1-5 km)
-- Lý do: Với chuyến 1.23 km, nếu baseFee = 200,000:
--   - kmCost = 1.23 × 15,000 = 18,450
--   - basePrice = 18,450 + 200,000 = 218,450
--   - Sau phụ phí cuối tuần (+20%) = 262,140 (hợp lý)
UPDATE `vehicle_category_pricing`
SET 
    `baseFare` = 200000.00
WHERE `categoryId` = 1 AND `categoryName` = 'Xe 9 chỗ (Limousine)';

-- =====================================================
-- 2. XE 16 CHỖ
-- =====================================================
-- Hiện tại: baseFare = 1,100,000
-- Đề xuất: baseFare = 400,000 (giảm 64%)
-- Lý do: Xe lớn hơn nhưng vẫn cần hợp lý cho chuyến ngắn
UPDATE `vehicle_category_pricing`
SET 
    `baseFare` = 400000.00
WHERE `categoryId` = 2 AND `categoryName` = 'Xe 16 chỗ';

-- =====================================================
-- 3. XE 29 CHỖ
-- =====================================================
-- Hiện tại: baseFare = 1,800,000
-- Đề xuất: baseFare = 600,000 (giảm 67%)
-- Lý do: Xe lớn, nhưng cần cân bằng với giá theo km
UPDATE `vehicle_category_pricing`
SET 
    `baseFare` = 600000.00
WHERE `categoryId` = 3 AND `categoryName` = 'Xe 29 chỗ';

-- =====================================================
-- 4. XE 45 CHỖ
-- =====================================================
-- Hiện tại: baseFare = 2,500,000
-- Đề xuất: baseFare = 800,000 (giảm 68%)
-- Lý do: Xe rất lớn, nhưng vẫn cần hợp lý
UPDATE `vehicle_category_pricing`
SET 
    `baseFare` = 800000.00
WHERE `categoryId` = 4 AND `categoryName` = 'Xe 45 chỗ';

-- =====================================================
-- 5. XE GIƯỜNG NẰM (40 CHỖ)
-- =====================================================
-- Hiện tại: baseFare = 3,000,000
-- Đề xuất: baseFare = 1,000,000 (giảm 67%)
-- Lý do: Xe đặc biệt, nhưng cần hợp lý cho chuyến ngắn
UPDATE `vehicle_category_pricing`
SET 
    `baseFare` = 1000000.00
WHERE `categoryId` = 5 AND `categoryName` = 'Xe giường nằm (40 chỗ)';

-- =====================================================
-- XÁC NHẬN KẾT QUẢ
-- =====================================================
SELECT 
    `categoryId`,
    `categoryName`,
    `baseFare` AS `Phí_Mở_Cửa_Mới`,
    `pricePerKm` AS `Giá_Theo_KM`,
    `sameDayFixedPrice` AS `Giá_Cố_Định_Ngày`
FROM `vehicle_category_pricing`
WHERE `status` = 'ACTIVE'
ORDER BY `categoryId`;

-- =====================================================
-- VÍ DỤ TÍNH GIÁ SAU KHI CẬP NHẬT
-- =====================================================
-- Xe 9 chỗ, chuyến 1.23 km, cuối tuần:
--   kmCost = 1.23 × 15,000 = 18,450
--   baseFee = 200,000 (mới)
--   basePrice = 218,450
--   Phụ phí cuối tuần (+20%) = 43,690
--   TỔNG = 262,140 VNĐ (thay vì 1,102,140 VNĐ)
-- =====================================================

