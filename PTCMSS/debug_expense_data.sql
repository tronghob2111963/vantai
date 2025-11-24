-- Script để kiểm tra dữ liệu expense trong database

-- 1. Kiểm tra tổng số invoices theo type
SELECT 
    type,
    COUNT(*) as total_count,
    SUM(amount) as total_amount
FROM invoices
WHERE status = 'ACTIVE'
GROUP BY type;

-- 2. Kiểm tra expense invoices chi tiết
SELECT 
    id,
    invoice_number,
    branch_id,
    type,
    amount,
    cost_type,
    invoice_date,
    created_at,
    status
FROM invoices
WHERE type = 'EXPENSE'
    AND status = 'ACTIVE'
ORDER BY invoice_date DESC
LIMIT 20;

-- 3. Kiểm tra expense trong tháng 11/2025
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

-- 4. Kiểm tra tất cả expense không phân biệt thời gian
SELECT 
    cost_type,
    COUNT(*) as count,
    SUM(amount) as total_amount,
    MIN(invoice_date) as earliest_date,
    MAX(invoice_date) as latest_date
FROM invoices
WHERE type = 'EXPENSE'
    AND status = 'ACTIVE'
GROUP BY cost_type;

-- 5. Kiểm tra expense theo branch
SELECT 
    b.branch_name,
    COUNT(i.id) as expense_count,
    SUM(i.amount) as total_expense
FROM invoices i
LEFT JOIN branches b ON i.branch_id = b.id
WHERE i.type = 'EXPENSE'
    AND i.status = 'ACTIVE'
GROUP BY b.id, b.branch_name;
