-- ============================================================
-- Script Test: Payment Approval Notification cho Consultant
-- ============================================================
-- Mục đích: Tạo dữ liệu test để verify notification flow
-- ============================================================

-- 1. Kiểm tra có Consultant và Accountant không
SELECT 
    u.userId,
    u.fullName,
    u.username,
    r.roleName,
    e.employeeId,
    e.branchId
FROM users u
JOIN roles r ON u.roleId = r.roleId
LEFT JOIN employees e ON u.userId = e.userId
WHERE r.roleName IN ('Consultant', 'Accountant')
ORDER BY r.roleName, u.fullName;

-- 2. Tạo Payment Request để test (nếu chưa có)
-- Lưu ý: Thay {consultantEmployeeId}, {invoiceId}, {amount} bằng giá trị thực tế

-- Bước 1: Tìm invoice có status UNPAID
SELECT 
    i.invoiceId,
    i.bookingId,
    i.amount,
    i.paymentStatus,
    b.bookingId,
    b.status AS bookingStatus,
    b.consultantId
FROM invoices i
LEFT JOIN bookings b ON i.bookingId = b.bookingId
WHERE i.paymentStatus = 'UNPAID'
  AND i.type = 'INCOME'
  AND b.consultantId IS NOT NULL
LIMIT 5;

-- Bước 2: Tạo payment request (PENDING)
-- INSERT INTO payment_history (
--     invoiceId,
--     paymentDate,
--     amount,
--     paymentMethod,
--     confirmationStatus,
--     createdBy,
--     createdAt
-- )
-- VALUES (
--     {invoiceId},                    -- Thay bằng invoiceId từ query trên
--     NOW(),
--     {amount},                       -- Số tiền (ví dụ: 1000000)
--     'CASH',
--     'PENDING',
--     {consultantEmployeeId},         -- Thay bằng employeeId của Consultant
--     NOW()
-- );

-- 3. Kiểm tra Payment Requests đang PENDING
SELECT 
    ph.paymentId,
    ph.invoiceId,
    ph.amount,
    ph.paymentMethod,
    ph.confirmationStatus,
    ph.createdBy,
    e.userId AS createdByUserId,
    u.fullName AS createdByName,
    i.bookingId,
    b.bookingId AS bookingCode
FROM payment_history ph
JOIN invoices i ON ph.invoiceId = i.invoiceId
LEFT JOIN bookings b ON i.bookingId = b.bookingId
LEFT JOIN employees e ON ph.createdBy = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE ph.confirmationStatus = 'PENDING'
ORDER BY ph.createdAt DESC
LIMIT 10;

-- 4. Kiểm tra Notifications đã được gửi cho Consultant
SELECT 
    n.notificationId,
    n.userId,
    u.fullName AS userName,
    n.title,
    n.message,
    n.createdAt,
    n.isRead
FROM notifications n
JOIN users u ON n.userId = u.userId
JOIN roles r ON u.roleId = r.roleId
WHERE r.roleName = 'Consultant'
ORDER BY n.createdAt DESC
LIMIT 10;

-- 5. Test: Simulate Accountant approve payment (chạy sau khi Accountant duyệt)
-- UPDATE payment_history 
-- SET confirmationStatus = 'CONFIRMED',
--     updatedAt = NOW()
-- WHERE paymentId = {paymentId};

-- Sau đó kiểm tra notification:
-- SELECT * FROM notifications 
-- WHERE userId = {consultantUserId}
-- ORDER BY createdAt DESC LIMIT 1;

-- 6. Cleanup (xóa dữ liệu test nếu cần)
-- DELETE FROM notifications WHERE title LIKE '%Test%';
-- DELETE FROM payment_history WHERE note LIKE '%Test%';

