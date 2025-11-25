-- Migration: Thêm trường confirmationStatus vào payment_history
-- Để kế toán xác nhận thanh toán (PENDING, CONFIRMED, REJECTED)

-- Kiểm tra và thêm column nếu chưa có
SET @dbname = DATABASE();
SET @tablename = "payment_history";
SET @columnname = "confirmationStatus";
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  "SELECT 1",
  CONCAT("ALTER TABLE ", @tablename, " ADD COLUMN ", @columnname, " VARCHAR(20) DEFAULT 'PENDING' COMMENT 'Trạng thái xác nhận: PENDING, CONFIRMED, REJECTED'")
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Cập nhật các payment hiện có: nếu invoice đã PAID thì set CONFIRMED, còn lại PENDING
UPDATE payment_history ph
INNER JOIN invoices i ON ph.invoiceId = i.id
SET ph.confirmationStatus = CASE 
    WHEN i.paymentStatus = 'PAID' THEN 'CONFIRMED'
    ELSE 'PENDING'
END
WHERE ph.confirmationStatus IS NULL OR ph.confirmationStatus = '';

-- Thêm index để tối ưu query
CREATE INDEX IF NOT EXISTS idx_payment_confirmation_status ON payment_history(confirmationStatus);


