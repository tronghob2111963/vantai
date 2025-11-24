-- Kiểm tra cấu trúc bảng invoices
DESCRIBE invoices;

-- Hoặc
SHOW COLUMNS FROM invoices;

-- Xem tất cả dữ liệu expense (không chỉ định cột cụ thể)
SELECT * 
FROM invoices 
WHERE type = 'EXPENSE' 
  AND status = 'ACTIVE'
LIMIT 5;
