-- ============================================
-- XÓA 2 BẢNG TRỐNG KHÔNG SỬ DỤNG
-- ============================================

USE ptcmss_db;

-- 1. XÓA expense_request_attachments (không có entity, không có data)
DROP TABLE IF EXISTS `expense_request_attachments`;

-- 2. XÓA trip_route_cache (cache table, không có entity)
DROP TABLE IF EXISTS `trip_route_cache`;

-- ============================================
-- GIỮ LẠI 2 BẢNG SAU (ĐANG DÙNG):
-- - expenses: Dùng trong AnalyticsService (báo cáo chi phí)
-- - invoice_items: Có 5 records data (line items của invoice)
-- ============================================

SELECT 'Đã xóa 2 bảng trống: expense_request_attachments, trip_route_cache' AS Status;
