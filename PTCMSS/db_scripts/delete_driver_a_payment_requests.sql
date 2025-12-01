USE ptcmss_db;

-- ============================================
-- Script xóa payment requests của tài xế driver_a
-- ============================================

-- Bước 1: Kiểm tra thông tin driver_a
SELECT 
    u.userId,
    u.username,
    u.fullName,
    e.employeeId,
    d.driverId
FROM users u
JOIN employees e ON u.userId = e.userId
JOIN drivers d ON e.employeeId = d.employeeId
WHERE u.username = 'driver_a';

-- Bước 2: Xem các payment requests của driver_a (invoices)
SELECT 
    i.invoiceId,
    i.invoiceNumber,
    i.amount,
    i.paymentMethod,
    i.paymentStatus,
    i.type,
    i.isDeposit,
    i.note,
    i.createdAt,
    i.requestedBy AS driverId,
    i.createdBy AS employeeId
FROM invoices i
JOIN drivers d ON i.requestedBy = d.driverId
JOIN employees e ON d.employeeId = e.employeeId
JOIN users u ON e.userId = u.userId
WHERE u.username = 'driver_a'
  AND i.type = 'INCOME'
  AND i.isDeposit = 0  -- Payment requests (không phải cọc)
  AND i.status = 'ACTIVE';

-- Bước 3: Xem các payment_history liên quan (qua invoices)
SELECT 
    ph.paymentId,
    ph.invoiceId,
    ph.amount,
    ph.paymentMethod,
    ph.confirmationStatus,
    ph.note,
    ph.createdAt,
    ph.createdBy AS employeeId,
    'via_invoice' AS source
FROM payment_history ph
JOIN invoices i ON ph.invoiceId = i.invoiceId
JOIN drivers d ON i.requestedBy = d.driverId
JOIN employees e ON d.employeeId = e.employeeId
JOIN users u ON e.userId = u.userId
WHERE u.username = 'driver_a'
  AND i.type = 'INCOME'
  AND i.isDeposit = 0;

-- Bước 3b: Xem các payment_history được tạo trực tiếp bởi driver_a (nếu có)
SELECT 
    ph.paymentId,
    ph.invoiceId,
    ph.amount,
    ph.paymentMethod,
    ph.confirmationStatus,
    ph.note,
    ph.createdAt,
    ph.createdBy AS employeeId,
    'via_createdBy' AS source
FROM payment_history ph
JOIN employees e ON ph.createdBy = e.employeeId
JOIN users u ON e.userId = u.userId
WHERE u.username = 'driver_a';

-- ============================================
-- BƯỚC XÓA (Chạy sau khi đã kiểm tra)
-- ============================================

-- Tắt foreign key checks tạm thời để xóa
SET FOREIGN_KEY_CHECKS = 0;

-- Xóa payment_history trước (vì có FK đến invoices)
-- Xóa tất cả payment_history liên quan đến payment requests của driver_a
DELETE ph FROM payment_history ph
INNER JOIN invoices i ON ph.invoiceId = i.invoiceId
INNER JOIN drivers d ON i.requestedBy = d.driverId
INNER JOIN employees e ON d.employeeId = e.employeeId
INNER JOIN users u ON e.userId = u.userId
WHERE u.username = 'driver_a'
  AND i.type = 'INCOME'
  AND i.isDeposit = 0
  AND i.status = 'ACTIVE';

-- Xóa invoices (payment requests)
DELETE i FROM invoices i
INNER JOIN drivers d ON i.requestedBy = d.driverId
INNER JOIN employees e ON d.employeeId = e.employeeId
INNER JOIN users u ON e.userId = u.userId
WHERE u.username = 'driver_a'
  AND i.type = 'INCOME'
  AND i.isDeposit = 0
  AND i.status = 'ACTIVE';

-- Bật lại foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- Xác nhận đã xóa
-- ============================================

-- Kiểm tra lại số lượng payment requests còn lại
SELECT 
    COUNT(*) AS remaining_payment_requests
FROM invoices i
JOIN drivers d ON i.requestedBy = d.driverId
JOIN employees e ON d.employeeId = e.employeeId
JOIN users u ON e.userId = u.userId
WHERE u.username = 'driver_a'
  AND i.type = 'INCOME'
  AND i.isDeposit = 0
  AND i.status = 'ACTIVE';

-- Kiểm tra lại số lượng payment_history còn lại
SELECT 
    COUNT(*) AS remaining_payment_history
FROM payment_history ph
JOIN invoices i ON ph.invoiceId = i.invoiceId
JOIN drivers d ON i.requestedBy = d.driverId
JOIN employees e ON d.employeeId = e.employeeId
JOIN users u ON e.userId = u.userId
WHERE u.username = 'driver_a'
  AND i.type = 'INCOME'
  AND i.isDeposit = 0;

