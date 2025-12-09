# Phân Tích Bảng `invoices` - Số Cột

## Tổng Số Cột: **31 cột**

### Danh Sách Chi Tiết Các Cột:

1. `invoiceId` - int NOT NULL AUTO_INCREMENT (PRIMARY KEY)
2. `branchId` - int NOT NULL
3. `bookingId` - int DEFAULT NULL
4. `customerId` - int DEFAULT NULL
5. `type` - varchar(255) NOT NULL
6. `costType` - varchar(50) DEFAULT NULL
7. `isDeposit` - tinyint(1) NOT NULL DEFAULT '0'
8. `amount` - decimal(18,2) NOT NULL
9. `paymentStatus` - enum('UNPAID','PAID','REFUNDED','OVERDUE') DEFAULT 'UNPAID'
10. `status` - enum('ACTIVE','CANCELLED') DEFAULT 'ACTIVE'
11. `invoiceDate` - datetime DEFAULT CURRENT_TIMESTAMP
12. `createdAt` - datetime DEFAULT CURRENT_TIMESTAMP
13. `img` - varchar(255) DEFAULT NULL
14. `note` - varchar(255) DEFAULT NULL
15. `requestedBy` - int DEFAULT NULL
16. `createdBy` - int DEFAULT NULL
17. `approvedBy` - int DEFAULT NULL
18. `approvedAt` - datetime DEFAULT NULL
19. `cancellationReason` - varchar(500) DEFAULT NULL
20. `cancelledAt` - datetime(6) DEFAULT NULL
21. `contactNote` - text
22. `debtLabel` - varchar(50) DEFAULT NULL
23. `dueDate` - date DEFAULT NULL
24. `invoiceNumber` - varchar(50) DEFAULT NULL (UNIQUE)
25. `paymentTerms` - varchar(20) DEFAULT NULL
26. `promiseToPayDate` - date DEFAULT NULL
27. `sentAt` - datetime(6) DEFAULT NULL
28. `sentToEmail` - varchar(100) DEFAULT NULL
29. `subtotal` - decimal(18,2) DEFAULT NULL
30. `vatAmount` - decimal(18,2) DEFAULT '0.00'
31. `cancelledBy` - int DEFAULT NULL

---

## Phân Loại Cột:

### **Thông Tin Cơ Bản (5 cột)**
- invoiceId, branchId, bookingId, customerId, invoiceNumber

### **Thông Tin Hóa Đơn (8 cột)**
- type, costType, isDeposit, amount, subtotal, vatAmount, invoiceDate, dueDate

### **Trạng Thái (2 cột)**
- paymentStatus, status

### **Ghi Chú & Mô Tả (3 cột)**
- note, contactNote, cancellationReason

### **Thông Tin Người Dùng (5 cột)**
- requestedBy, createdBy, approvedBy, cancelledBy, sentToEmail

### **Thời Gian (5 cột)**
- createdAt, approvedAt, cancelledAt, sentAt, promiseToPayDate

### **Khác (3 cột)**
- img, debtLabel, paymentTerms

---

## Foreign Keys:

- `branchId` → `branches(branchId)`
- `bookingId` → `bookings(bookingId)`
- `customerId` → `customers(customerId)`
- `requestedBy` → `drivers(driverId)`
- `createdBy` → `employees(employeeId)`
- `approvedBy` → `employees(employeeId)`
- `cancelledBy` → `employees(employeeId)`

---

## Indexes:

1. PRIMARY KEY: `invoiceId`
2. UNIQUE: `invoiceNumber`
3. INDEX: `IX_Invoices_Branch` (branchId, invoiceDate)
4. INDEX: `IX_Invoices_Type_Status` (type, status)
5. INDEX: `IX_Invoices_Booking` (bookingId)
6. INDEX: `IX_Invoices_Customer` (customerId)
7. INDEX: `IX_Invoices_PaymentStatus` (paymentStatus)
8. INDEX: `fk_inv_reqDriver` (requestedBy)
9. INDEX: `fk_inv_createdBy` (createdBy)
10. INDEX: `fk_inv_approvedBy` (approvedBy)
11. INDEX: `FK55ebms893efmjp7rbhv14yngb` (cancelledBy)

---

## Kết Luận:

✅ **Bảng `invoices` có đúng 31 cột** như bạn đã nói.

Nếu bạn đang gặp vấn đề với số cột này, có thể do:
- Entity class trong backend không khớp với schema
- Frontend đang expect số cột khác
- Migration chưa được chạy đầy đủ

Hãy kiểm tra:
1. Entity class `Invoice.java` có đủ 31 fields không?
2. Frontend có đang map đúng tất cả các cột không?
3. Database thực tế có đúng 31 cột không? (chạy `DESCRIBE invoices;`)

