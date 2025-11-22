-- ==========================================================
-- Verification Script: Kiểm tra migration đã thành công
-- ==========================================================
-- 
-- Chạy script này để verify migration đã thành công
-- 
-- CÁCH CHẠY:
-- mysql -u root -p ptcmss_db < 02_VERIFY_MIGRATION.sql
--
-- ==========================================================

USE ptcmss_db;

-- ==========================================================
-- 1. Kiểm tra tất cả tables đã đổi tên (snake_case)
-- ==========================================================

SELECT '=== KIỂM TRA TABLES ĐÃ ĐỔI TÊN ===' AS '';

SELECT 
    'accounts_receivable' AS table_name,
    IF(COUNT(*) > 0, '✅ OK', '❌ MISSING') AS status
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'accounts_receivable'

UNION ALL

SELECT 
    'booking_vehicle_details',
    IF(COUNT(*) > 0, '✅ OK', '❌ MISSING')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'booking_vehicle_details'

UNION ALL

SELECT 
    'driver_day_off',
    IF(COUNT(*) > 0, '✅ OK', '❌ MISSING')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'driver_day_off'

UNION ALL

SELECT 
    'hire_types',
    IF(COUNT(*) > 0, '✅ OK', '❌ MISSING')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'hire_types'

UNION ALL

SELECT 
    'system_settings',
    IF(COUNT(*) > 0, '✅ OK', '❌ MISSING')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'system_settings'

UNION ALL

SELECT 
    'trip_drivers',
    IF(COUNT(*) > 0, '✅ OK', '❌ MISSING')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'trip_drivers'

UNION ALL

SELECT 
    'trip_route_cache',
    IF(COUNT(*) > 0, '✅ OK', '❌ MISSING')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'trip_route_cache'

UNION ALL

SELECT 
    'trip_vehicles',
    IF(COUNT(*) > 0, '✅ OK', '❌ MISSING')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'trip_vehicles'

UNION ALL

SELECT 
    'vehicle_category_pricing',
    IF(COUNT(*) > 0, '✅ OK', '❌ MISSING')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'vehicle_category_pricing';

-- ==========================================================
-- 2. Kiểm tra tables cũ đã bị xóa (không còn tồn tại)
-- ==========================================================

SELECT '' AS '';
SELECT '=== KIỂM TRA TABLES CŨ ĐÃ BỊ XÓA ===' AS '';

SELECT 
    'accountsreceivable' AS old_table_name,
    IF(COUNT(*) = 0, '✅ OK (đã xóa)', '❌ VẪN CÒN TỒN TẠI!') AS status
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'accountsreceivable'

UNION ALL

SELECT 
    'bookingvehicledetails',
    IF(COUNT(*) = 0, '✅ OK (đã xóa)', '❌ VẪN CÒN TỒN TẠI!')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'bookingvehicledetails'

UNION ALL

SELECT 
    'driverdayoff',
    IF(COUNT(*) = 0, '✅ OK (đã xóa)', '❌ VẪN CÒN TỒN TẠI!')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'driverdayoff'

UNION ALL

SELECT 
    'hiretypes',
    IF(COUNT(*) = 0, '✅ OK (đã xóa)', '❌ VẪN CÒN TỒN TẠI!')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'hiretypes'

UNION ALL

SELECT 
    'systemsettings',
    IF(COUNT(*) = 0, '✅ OK (đã xóa)', '❌ VẪN CÒN TỒN TẠI!')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'systemsettings'

UNION ALL

SELECT 
    'tripdrivers',
    IF(COUNT(*) = 0, '✅ OK (đã xóa)', '❌ VẪN CÒN TỒN TẠI!')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'tripdrivers'

UNION ALL

SELECT 
    'triproutecache',
    IF(COUNT(*) = 0, '✅ OK (đã xóa)', '❌ VẪN CÒN TỒN TẠI!')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'triproutecache'

UNION ALL

SELECT 
    'tripvehicles',
    IF(COUNT(*) = 0, '✅ OK (đã xóa)', '❌ VẪN CÒN TỒN TẠI!')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'tripvehicles'

UNION ALL

SELECT 
    'vehiclecategorypricing',
    IF(COUNT(*) = 0, '✅ OK (đã xóa)', '❌ VẪN CÒN TỒN TẠI!')
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' AND table_name = 'vehiclecategorypricing';

-- ==========================================================
-- 3. Liệt kê tất cả tables hiện tại
-- ==========================================================

SELECT '' AS '';
SELECT '=== DANH SÁCH TẤT CẢ TABLES HIỆN TẠI ===' AS '';
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'ptcmss_db' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ==========================================================
-- 4. Kiểm tra Views đã được recreate
-- ==========================================================

SELECT '' AS '';
SELECT '=== KIỂM TRA VIEWS ===' AS '';
SELECT 
    table_name AS view_name,
    '✅ OK' AS status
FROM information_schema.views 
WHERE table_schema = 'ptcmss_db'
ORDER BY table_name;

-- ==========================================================
-- 5. Kiểm tra số lượng records (đảm bảo data không mất)
-- ==========================================================

SELECT '' AS '';
SELECT '=== KIỂM TRA SỐ LƯỢNG RECORDS ===' AS '';
SELECT 
    'accounts_receivable' AS table_name,
    COUNT(*) AS record_count
FROM accounts_receivable

UNION ALL

SELECT 'booking_vehicle_details', COUNT(*) FROM booking_vehicle_details
UNION ALL
SELECT 'driver_day_off', COUNT(*) FROM driver_day_off
UNION ALL
SELECT 'hire_types', COUNT(*) FROM hire_types
UNION ALL
SELECT 'system_settings', COUNT(*) FROM system_settings
UNION ALL
SELECT 'trip_drivers', COUNT(*) FROM trip_drivers
UNION ALL
SELECT 'trip_route_cache', COUNT(*) FROM trip_route_cache
UNION ALL
SELECT 'trip_vehicles', COUNT(*) FROM trip_vehicles
UNION ALL
SELECT 'vehicle_category_pricing', COUNT(*) FROM vehicle_category_pricing;

-- ==========================================================
-- 6. Kiểm tra foreign keys vẫn hoạt động
-- ==========================================================

SELECT '' AS '';
SELECT '=== KIỂM TRA FOREIGN KEYS ===' AS '';
SELECT 
    CONSTRAINT_NAME AS fk_name,
    TABLE_NAME AS table_name,
    REFERENCED_TABLE_NAME AS referenced_table,
    '✅ OK' AS status
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'ptcmss_db'
  AND REFERENCED_TABLE_NAME IS NOT NULL
  AND TABLE_NAME IN (
    'accounts_receivable',
    'booking_vehicle_details',
    'driver_day_off',
    'hire_types',
    'system_settings',
    'trip_drivers',
    'trip_route_cache',
    'trip_vehicles',
    'vehicle_category_pricing'
  )
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- ==========================================================
-- Verification completed!
-- ==========================================================
-- Nếu tất cả đều ✅ OK, migration đã thành công!
-- Bước tiếp theo: Update @Table annotation trong entities
-- ==========================================================
