USE ptcmss_db;

-- ============================================
-- Tìm payment requests với các giá trị cụ thể
-- ============================================

-- Tìm payment requests với amount = 1759205 hoặc 1760000
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
    i.createdBy AS employeeId,
    d.driverId,
    u.username,
    u.fullName AS driverName
FROM invoices i
LEFT JOIN drivers d ON i.requestedBy = d.driverId
LEFT JOIN employees e ON d.employeeId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE i.type = 'INCOME'
  AND i.isDeposit = 0
  AND (i.amount = 1759205.00 
       OR i.amount = 1759205.55
       OR i.amount = 1760000.00
       OR i.amount = 3519205.55)
ORDER BY i.createdAt DESC;

-- Tìm payment_history với các giá trị này
SELECT 
    ph.paymentId,
    ph.invoiceId,
    ph.amount,
    ph.paymentMethod,
    ph.confirmationStatus,
    ph.note,
    ph.createdAt,
    ph.createdBy AS employeeId,
    i.invoiceNumber,
    i.requestedBy AS driverId,
    u.username AS driverUsername,
    u.fullName AS driverName
FROM payment_history ph
JOIN invoices i ON ph.invoiceId = i.invoiceId
LEFT JOIN drivers d ON i.requestedBy = d.driverId
LEFT JOIN employees e ON d.employeeId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE (ph.amount = 1759205.00 
       OR ph.amount = 1759205.55
       OR ph.amount = 1760000.00
       OR ph.amount = 3519205.55)
ORDER BY ph.createdAt DESC;

-- Tìm payment requests với note "joiuy" hoặc "ok"
SELECT 
    i.invoiceId,
    i.invoiceNumber,
    i.amount,
    i.paymentMethod,
    i.note,
    i.createdAt,
    i.requestedBy AS driverId,
    u.username AS driverUsername,
    u.fullName AS driverName
FROM invoices i
LEFT JOIN drivers d ON i.requestedBy = d.driverId
LEFT JOIN employees e ON d.employeeId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE i.type = 'INCOME'
  AND i.isDeposit = 0
  AND (i.note LIKE '%joiuy%' 
       OR i.note LIKE '%ok%')
ORDER BY i.createdAt DESC;

-- Tìm payment_history với note "joiuy" hoặc "ok"
SELECT 
    ph.paymentId,
    ph.invoiceId,
    ph.amount,
    ph.paymentMethod,
    ph.note,
    ph.confirmationStatus,
    ph.createdAt,
    i.invoiceNumber,
    u.username AS driverUsername
FROM payment_history ph
JOIN invoices i ON ph.invoiceId = i.invoiceId
LEFT JOIN drivers d ON i.requestedBy = d.driverId
LEFT JOIN employees e ON d.employeeId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE (ph.note LIKE '%joiuy%' 
       OR ph.note LIKE '%ok%')
ORDER BY ph.createdAt DESC;

-- Tìm tất cả payment requests của booking #9 (trip #9)
SELECT 
    i.invoiceId,
    i.invoiceNumber,
    i.bookingId,
    i.amount,
    i.paymentMethod,
    i.paymentStatus,
    i.type,
    i.isDeposit,
    i.note,
    i.createdAt,
    i.requestedBy AS driverId,
    u.username AS driverUsername,
    u.fullName AS driverName,
    b.bookingId,
    b.totalCost,
    b.depositAmount
FROM invoices i
LEFT JOIN bookings b ON i.bookingId = b.bookingId
LEFT JOIN drivers d ON i.requestedBy = d.driverId
LEFT JOIN employees e ON d.employeeId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE i.bookingId = 9
  AND i.type = 'INCOME'
  AND i.isDeposit = 0
ORDER BY i.createdAt DESC;

-- Tìm payment_history của booking #9
SELECT 
    ph.paymentId,
    ph.invoiceId,
    ph.amount,
    ph.paymentMethod,
    ph.confirmationStatus,
    ph.note,
    ph.createdAt,
    i.bookingId,
    i.invoiceNumber,
    u.username AS driverUsername
FROM payment_history ph
JOIN invoices i ON ph.invoiceId = i.invoiceId
LEFT JOIN drivers d ON i.requestedBy = d.driverId
LEFT JOIN employees e ON d.employeeId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE i.bookingId = 9
ORDER BY ph.createdAt DESC;

-- Tổng hợp: Tìm tất cả payment requests có thể liên quan
SELECT 
    'INVOICE' AS source_type,
    i.invoiceId AS id,
    i.amount,
    i.paymentMethod,
    i.note,
    i.createdAt,
    i.bookingId,
    u.username AS driverUsername,
    u.fullName AS driverName
FROM invoices i
LEFT JOIN drivers d ON i.requestedBy = d.driverId
LEFT JOIN employees e ON d.employeeId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE i.type = 'INCOME'
  AND i.isDeposit = 0
  AND (
    i.amount IN (1759205.00, 1759205.55, 1760000.00, 3519205.55)
    OR i.note LIKE '%joiuy%'
    OR i.note LIKE '%ok%'
    OR i.bookingId = 9
  )

UNION ALL

SELECT 
    'PAYMENT_HISTORY' AS source_type,
    ph.paymentId AS id,
    ph.amount,
    ph.paymentMethod,
    ph.note,
    ph.createdAt,
    i.bookingId,
    u.username AS driverUsername,
    u.fullName AS driverName
FROM payment_history ph
JOIN invoices i ON ph.invoiceId = i.invoiceId
LEFT JOIN drivers d ON i.requestedBy = d.driverId
LEFT JOIN employees e ON d.employeeId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE (
    ph.amount IN (1759205.00, 1759205.55, 1760000.00, 3519205.55)
    OR ph.note LIKE '%joiuy%'
    OR ph.note LIKE '%ok%'
    OR i.bookingId = 9
  )
ORDER BY createdAt DESC;

