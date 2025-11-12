-- ==========================================================
-- UPDATE BOOKING STATUS ENUM
-- ==========================================================
-- Script này sẽ cập nhật ENUM status của bảng Bookings
-- để thêm QUOTATION_SENT và đổi INPROGRESS thành IN_PROGRESS
-- ==========================================================

USE ptcmss_db;

-- Lưu ý: MySQL không hỗ trợ ALTER ENUM trực tiếp, cần dùng cách sau:

-- 1. Tạo bảng tạm với ENUM mới
CREATE TABLE IF NOT EXISTS Bookings_temp LIKE Bookings;

-- 2. Thay đổi ENUM trong bảng tạm
ALTER TABLE Bookings_temp 
MODIFY COLUMN status ENUM('PENDING','QUOTATION_SENT','CONFIRMED','IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'PENDING';

-- 3. Copy dữ liệu (chuyển INPROGRESS -> IN_PROGRESS)
INSERT INTO Bookings_temp 
SELECT 
  bookingId, customerId, branchId, consultantId, hireTypeId, useHighway,
  bookingDate, estimatedCost, depositAmount, totalCost,
  CASE 
    WHEN status = 'INPROGRESS' THEN 'IN_PROGRESS'
    ELSE status
  END AS status,
  note, createdAt, updatedAt
FROM Bookings;

-- 4. Xóa bảng cũ và đổi tên bảng tạm
DROP TABLE Bookings;
RENAME TABLE Bookings_temp TO Bookings;

-- 5. Tạo lại các index và foreign keys
ALTER TABLE Bookings ADD PRIMARY KEY (bookingId);
ALTER TABLE Bookings ADD CONSTRAINT fk_book_cust FOREIGN KEY (customerId) REFERENCES Customers(customerId);
ALTER TABLE Bookings ADD CONSTRAINT fk_book_branch FOREIGN KEY (branchId) REFERENCES Branches(branchId);
ALTER TABLE Bookings ADD CONSTRAINT fk_book_cons FOREIGN KEY (consultantId) REFERENCES Employees(employeeId);
ALTER TABLE Bookings ADD CONSTRAINT fk_book_hire FOREIGN KEY (hireTypeId) REFERENCES HireTypes(hireTypeId);

CREATE INDEX IX_Bookings_BranchId ON Bookings(branchId);
CREATE INDEX IX_Bookings_Customer_Status ON Bookings(customerId, status);
CREATE INDEX IX_Bookings_HireType ON Bookings(hireTypeId);

-- Verify
SELECT 
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ptcmss_db' 
  AND TABLE_NAME = 'Bookings'
  AND COLUMN_NAME = 'status';

-- ==========================================================
-- LƯU Ý:
-- - Script này sẽ xóa và tạo lại bảng Bookings
-- - Đảm bảo backup dữ liệu trước khi chạy
-- - Nếu có dữ liệu quan trọng, nên test trên database test trước
-- ==========================================================

