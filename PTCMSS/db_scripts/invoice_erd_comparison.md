# So Sánh ERD vs Schema Hiện Tại - Bảng `invoices`

## Fields Trong ERD Diagram

Theo ERD diagram, bảng `Invoices` có các attributes sau:

1. `InvoicesID` (Primary Key)
2. `BranchID` (FK to Branches)
3. `BookingID` (FK to Bookings)
4. `CustomerID` (FK to Customers)
5. `Type`
6. `CostType`
7. `IsDeposit`
8. `Amount`
9. `PaymentStatus`
10. `InvoiceDate`
11. `CreatedAt`
12. `Img`
13. `Status`
14. `Note`
15. `RequestedBy` (FK to Users)
16. `CreatedBy` (FK to Users)
17. `ApprovedBy` (FK to Users)
18. `ApprovedAt`
19. `CancellationReason`
20. `DebtLabel`
21. `InvoiceNumber`
22. `SendAt` (trong ERD)
23. `SendToEmail` (trong ERD)

---

## Fields Trong Schema Hiện Tại (31 cột)

1. `invoiceId` ✅
2. `branchId` ✅
3. `bookingId` ✅
4. `customerId` ✅
5. `type` ✅
6. `costType` ✅
7. `isDeposit` ✅
8. `amount` ✅
9. `paymentStatus` ✅
10. `status` ✅
11. `invoiceDate` ✅
12. `createdAt` ✅
13. `img` ✅
14. `note` ✅
15. `requestedBy` ✅
16. `createdBy` ✅
17. `approvedBy` ✅
18. `approvedAt` ✅
19. `cancellationReason` ✅
20. `cancelledAt` ⚠️ (CÓ trong schema, KHÔNG có trong ERD)
21. `contactNote` ⚠️ (CÓ trong schema, KHÔNG có trong ERD)
22. `debtLabel` ✅
23. `dueDate` ⚠️ (CÓ trong schema, KHÔNG có trong ERD)
24. `invoiceNumber` ✅
25. `paymentTerms` ⚠️ (CÓ trong schema, KHÔNG có trong ERD)
26. `promiseToPayDate` ⚠️ (CÓ trong schema, KHÔNG có trong ERD)
27. `sentAt` ✅ (tương ứng `SendAt` trong ERD)
28. `sentToEmail` ✅ (tương ứng `SendToEmail` trong ERD)
29. `subtotal` ⚠️ (CÓ trong schema, KHÔNG có trong ERD)
30. `vatAmount` ⚠️ (CÓ trong schema, KHÔNG có trong ERD)
31. `cancelledBy` ⚠️ (CÓ trong schema, KHÔNG có trong ERD)

---

## So Sánh Chi Tiết

### ✅ Fields Có Trong Cả ERD và Schema (23 fields)
Tất cả các fields trong ERD đều có trong schema hiện tại.

### ⚠️ Fields Có Trong Schema Nhưng KHÔNG Có Trong ERD (8 fields)

1. **`cancelledAt`** (datetime(6))
   - Ngày hủy invoice
   - **Cần thiết** cho audit trail

2. **`contactNote`** (text)
   - Ghi chú liên hệ với khách hàng
   - **Cần thiết** cho debt management

3. **`dueDate`** (date)
   - Ngày đáo hạn thanh toán
   - **Cần thiết** cho debt management và overdue tracking

4. **`paymentTerms`** (varchar(20))
   - Điều khoản thanh toán (NET_7, NET_14, NET_30, NET_60)
   - **Cần thiết** để tính dueDate tự động

5. **`promiseToPayDate`** (date)
   - Ngày khách hứa thanh toán
   - **Cần thiết** cho debt management

6. **`subtotal`** (decimal(18,2))
   - Tổng tiền trước VAT
   - **Có thể xóa** nếu không cần tính VAT

7. **`vatAmount`** (decimal(18,2))
   - Số tiền VAT
   - **Có thể xóa** nếu không cần tính VAT

8. **`cancelledBy`** (int, FK to employees)
   - Người hủy invoice
   - **Cần thiết** cho audit trail

---

## Kết Luận

### ✅ Schema Hiện Tại ĐẦY ĐỦ Hơn ERD

Schema hiện tại có **TẤT CẢ** các fields trong ERD, **PLUS** thêm 8 fields bổ sung:

- **Fields cần thiết (6 fields):**
  - `cancelledAt` - Audit trail
  - `contactNote` - Debt management
  - `dueDate` - Debt management
  - `paymentTerms` - Tính dueDate
  - `promiseToPayDate` - Debt management
  - `cancelledBy` - Audit trail

- **Fields có thể xóa (2 fields):**
  - `subtotal` - Nếu không cần VAT
  - `vatAmount` - Nếu không cần VAT

### 📊 Tóm Tắt

| Loại | Số Lượng | Fields |
|------|----------|--------|
| **Có trong ERD** | 23 | Tất cả đều có trong schema |
| **Có trong Schema, không có ERD** | 8 | cancelledAt, contactNote, dueDate, paymentTerms, promiseToPayDate, subtotal, vatAmount, cancelledBy |
| **Thiếu trong Schema** | **0** | ✅ **KHÔNG THIẾU FIELD NÀO** |

---

## Recommendation

✅ **Schema hiện tại ĐẦY ĐỦ và TỐT HƠN ERD**

ERD có vẻ là bản thiết kế ban đầu, còn schema hiện tại đã được bổ sung thêm các fields cần thiết cho:
- Debt management (dueDate, promiseToPayDate, contactNote)
- Audit trail (cancelledAt, cancelledBy)
- Payment terms (paymentTerms)
- VAT calculation (subtotal, vatAmount) - có thể xóa nếu không cần

**KHÔNG CẦN THÊM FIELD NÀO** từ ERD vào schema hiện tại.

