-- =====================================================
-- Migration: Xóa các fields không dùng trong bảng invoices
-- Date: 2025-01-09
-- Description: Xóa subtotal, vatAmount, requestedBy, costType
-- =====================================================

-- ⚠️ BACKUP DATABASE TRƯỚC KHI CHẠY!
-- ⚠️ Kiểm tra có EXPENSE invoices không:
-- SELECT COUNT(*) FROM invoices WHERE type = 'EXPENSE';

-- =====================================================
-- 1. Xóa requestedBy (rủi ro thấp)
-- =====================================================
-- Xóa foreign key constraint trước
ALTER TABLE `invoices` DROP FOREIGN KEY `fk_inv_reqDriver`;
-- Xóa index
ALTER TABLE `invoices` DROP INDEX `fk_inv_reqDriver`;
-- Xóa column
ALTER TABLE `invoices` DROP COLUMN `requestedBy`;

-- =====================================================
-- 2. Xóa subtotal (rủi ro thấp)
-- =====================================================
ALTER TABLE `invoices` DROP COLUMN `subtotal`;

-- =====================================================
-- 3. Xóa vatAmount (rủi ro thấp)
-- =====================================================
ALTER TABLE `invoices` DROP COLUMN `vatAmount`;

-- =====================================================
-- 4. Xóa costType (rủi ro medium - chỉ xóa nếu không dùng EXPENSE)
-- =====================================================
-- ⚠️ UNCOMMENT DÒNG NÀY NẾU CHẮC CHẮN KHÔNG DÙNG EXPENSE INVOICES:
-- ALTER TABLE `invoices` DROP COLUMN `costType`;

-- =====================================================
-- Verify: Kiểm tra số cột sau khi xóa
-- =====================================================
-- SELECT COUNT(*) as column_count 
-- FROM information_schema.COLUMNS 
-- WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'invoices';
-- Kết quả mong đợi: 27 cột (nếu xóa costType) hoặc 28 cột (nếu giữ costType)


