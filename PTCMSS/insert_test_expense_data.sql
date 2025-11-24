-- Script để tạo dữ liệu expense test

-- Giả sử bạn có branch_id = 1 và một số user/customer
-- Điều chỉnh các ID này theo database thực tế của bạn

-- 1. Tạo expense invoices cho tháng 11/2025
INSERT INTO invoices (
    branch_id,
    type,
    amount,
    cost_type,
    invoice_number,
    invoice_date,
    due_date,
    payment_status,
    status,
    note,
    created_at,
    updated_at
) VALUES
-- Nhiên liệu
(1, 'EXPENSE', 500000, 'FUEL', 'EXP-2025-001', '2025-11-01', '2025-11-15', 'UNPAID', 'ACTIVE', 'Tiền xăng xe tải', NOW(), NOW()),
(1, 'EXPENSE', 750000, 'FUEL', 'EXP-2025-002', '2025-11-05', '2025-11-20', 'UNPAID', 'ACTIVE', 'Tiền xăng xe container', NOW(), NOW()),
(1, 'EXPENSE', 600000, 'FUEL', 'EXP-2025-003', '2025-11-10', '2025-11-25', 'PAID', 'ACTIVE', 'Tiền xăng xe van', NOW(), NOW()),

-- Phí cầu đường
(1, 'EXPENSE', 150000, 'TOLL', 'EXP-2025-004', '2025-11-02', '2025-11-16', 'UNPAID', 'ACTIVE', 'Phí BOT tuyến HN-HP', NOW(), NOW()),
(1, 'EXPENSE', 200000, 'TOLL', 'EXP-2025-005', '2025-11-08', '2025-11-22', 'UNPAID', 'ACTIVE', 'Phí BOT tuyến HN-HCM', NOW(), NOW()),

-- Bảo trì
(1, 'EXPENSE', 2500000, 'MAINTENANCE', 'EXP-2025-006', '2025-11-03', '2025-11-17', 'UNPAID', 'ACTIVE', 'Thay dầu và bảo dưỡng định kỳ', NOW(), NOW()),
(1, 'EXPENSE', 1800000, 'MAINTENANCE', 'EXP-2025-007', '2025-11-12', '2025-11-26', 'UNPAID', 'ACTIVE', 'Sửa chữa phanh xe', NOW(), NOW()),

-- Lương tài xế
(1, 'EXPENSE', 8000000, 'SALARY', 'EXP-2025-008', '2025-11-15', '2025-11-30', 'UNPAID', 'ACTIVE', 'Lương tài xế tháng 11', NOW(), NOW()),
(1, 'EXPENSE', 7500000, 'SALARY', 'EXP-2025-009', '2025-11-15', '2025-11-30', 'UNPAID', 'ACTIVE', 'Lương tài xế tháng 11', NOW(), NOW()),

-- Chi phí khác
(1, 'EXPENSE', 300000, 'OTHER', 'EXP-2025-010', '2025-11-07', '2025-11-21', 'UNPAID', 'ACTIVE', 'Chi phí văn phòng', NOW(), NOW()),
(1, 'EXPENSE', 450000, 'PARKING', 'EXP-2025-011', '2025-11-09', '2025-11-23', 'UNPAID', 'ACTIVE', 'Phí đỗ xe', NOW(), NOW()),

-- Thêm một số expense cho tuần này
(1, 'EXPENSE', 550000, 'FUEL', 'EXP-2025-012', '2025-11-20', '2025-12-05', 'UNPAID', 'ACTIVE', 'Tiền xăng tuần này', NOW(), NOW()),
(1, 'EXPENSE', 180000, 'TOLL', 'EXP-2025-013', '2025-11-21', '2025-12-06', 'UNPAID', 'ACTIVE', 'Phí BOT tuần này', NOW(), NOW()),
(1, 'EXPENSE', 900000, 'MAINTENANCE', 'EXP-2025-014', '2025-11-22', '2025-12-07', 'UNPAID', 'ACTIVE', 'Thay lốp xe', NOW(), NOW()),

-- Expense hôm nay
(1, 'EXPENSE', 400000, 'FUEL', 'EXP-2025-015', '2025-11-24', '2025-12-09', 'UNPAID', 'ACTIVE', 'Tiền xăng hôm nay', NOW(), NOW());

-- 2. Kiểm tra dữ liệu vừa insert
SELECT 
    DATE(invoice_date) as date,
    cost_type,
    COUNT(*) as count,
    SUM(amount) as total_amount
FROM invoices
WHERE type = 'EXPENSE'
    AND status = 'ACTIVE'
    AND invoice_date >= '2025-11-01'
    AND invoice_date <= '2025-11-24'
GROUP BY DATE(invoice_date), cost_type
ORDER BY date DESC;

-- 3. Tổng hợp theo category
SELECT 
    cost_type,
    COUNT(*) as count,
    SUM(amount) as total_amount
FROM invoices
WHERE type = 'EXPENSE'
    AND status = 'ACTIVE'
    AND invoice_date >= '2025-11-01'
    AND invoice_date <= '2025-11-24'
GROUP BY cost_type
ORDER BY total_amount DESC;
