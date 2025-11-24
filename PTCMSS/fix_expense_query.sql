-- 1. Kiểm tra cấu trúc bảng để biết tên cột chính xác
DESCRIBE invoices;

-- 2. Chuẩn hóa type về EXPENSE (viết hoa)
UPDATE invoices 
SET type = 'EXPENSE'
WHERE type = 'Expense';

-- 3. Kiểm tra lại sau khi update
SELECT 
    COUNT(*) as total,
    SUM(amount) as sum_amount
FROM invoices 
WHERE type = 'EXPENSE' 
  AND status = 'ACTIVE';

-- 4. Kiểm tra expense trong tháng 11/2025
SELECT 
    COUNT(*) as count_nov,
    SUM(amount) as sum_nov
FROM invoices 
WHERE type = 'EXPENSE' 
  AND status = 'ACTIVE'
  AND invoice_date >= '2025-11-01'
  AND invoice_date <= '2025-11-30 23:59:59';

-- 5. Xem chi tiết các expense
SELECT 
    *
FROM invoices 
WHERE type = 'EXPENSE' 
  AND status = 'ACTIVE'
ORDER BY invoice_date DESC;
