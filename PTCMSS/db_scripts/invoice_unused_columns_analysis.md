# Phân Tích Các Cột Không Dùng Trong Bảng `invoices`

## Tổng Quan

Bảng `invoices` hiện tại chỉ được dùng cho **hóa đơn thu (INCOME)**. Các cột liên quan đến **hóa đơn chi (EXPENSE)** và một số tính năng nâng cao có thể không cần thiết.

---

## Các Cột Cần Xem Xét Xóa

### 1. **`costType`** (varchar(50))
**Mục đích:** Phân loại chi phí cho expense invoices (fuel, toll, maintenance, etc.)

**Sử dụng hiện tại:**
- ✅ Có trong `CreateInvoiceRequest`
- ✅ Có trong `InvoiceResponse`
- ✅ Được set trong `InvoiceServiceImpl.createInvoice()`
- ✅ Được get trong `InvoiceServiceImpl.toResponse()`

**Phân tích:**
- Chỉ có ý nghĩa với EXPENSE invoices
- Nếu chỉ dùng INCOME invoices → **CÓ THỂ XÓA**

**Recommendation:** ⚠️ **XÓA** nếu chắc chắn không dùng EXPENSE invoices

---

### 2. **`requestedBy`** (int, FK to drivers)
**Mục đích:** Driver yêu cầu tạo invoice (thường cho expense)

**Sử dụng hiện tại:**
- ✅ Có trong entity `Invoices.java`
- ✅ Được dùng trong `InvoiceServiceImpl` để lấy driver user ID cho notification (line 578-580)
- ❌ Không có trong `CreateInvoiceRequest`
- ❌ Không được set khi tạo invoice mới

**Phân tích:**
- Chỉ dùng cho notification logic (có thể thay thế bằng cách khác)
- Không được set khi tạo invoice → **CÓ THỂ XÓA**

**Recommendation:** ⚠️ **XÓA** nếu không cần track driver request

---

### 3. **`subtotal`** (decimal(18,2))
**Mục đích:** Tổng tiền trước VAT (cho hóa đơn có VAT)

**Sử dụng hiện tại:**
- ✅ Có trong `CreateInvoiceRequest`
- ✅ Có trong `InvoiceResponse`
- ✅ Được set trong `InvoiceServiceImpl.createInvoice()`
- ✅ Được get trong `InvoiceServiceImpl.toResponse()`

**Phân tích:**
- Dùng cho tính toán VAT: `amount = subtotal + vatAmount`
- Nếu không dùng VAT → có thể tính: `subtotal = amount - vatAmount`
- **CÓ THỂ XÓA** nếu không cần tách riêng subtotal

**Recommendation:** ⚠️ **XÓA** nếu không cần tính VAT riêng

---

### 4. **`vatAmount`** (decimal(18,2))
**Mục đích:** Số tiền VAT

**Sử dụng hiện tại:**
- ✅ Có trong `CreateInvoiceRequest`
- ✅ Có trong `InvoiceResponse`
- ✅ Được set trong `InvoiceServiceImpl.createInvoice()` (default = 0)
- ✅ Được get trong `InvoiceServiceImpl.toResponse()`

**Phân tích:**
- Default = 0.00
- Nếu không dùng VAT → **CÓ THỂ XÓA**

**Recommendation:** ⚠️ **XÓA** nếu không cần tính VAT

---

### 5. **`dueDate`** (date)
**Mục đích:** Ngày đáo hạn thanh toán

**Sử dụng hiện tại:**
- ✅ **ĐƯỢC DÙNG NHIỀU:**
  - Tính toán trong `InvoiceServiceImpl.createInvoice()` (line 99-104)
  - Hiển thị trong email (line 356, 365)
  - Tính overdue trong `checkOverdue()` (line 381-385)
  - Tính `daysOverdue` trong response (line 444-447, 481-484)
  - Có trong `InvoiceResponse`
  - Có trong `CreateInvoiceRequest`
  - Dùng trong `OverdueInvoiceScheduler`
  - Dùng trong `DebtServiceImpl`

**Phân tích:**
- **QUAN TRỌNG** cho debt management và overdue tracking
- **KHÔNG NÊN XÓA** nếu cần track công nợ

**Recommendation:** ✅ **GIỮ LẠI** - Cần thiết cho debt management

---

### 6. **`promiseToPayDate`** (date)
**Mục đích:** Ngày khách hứa thanh toán (debt management)

**Sử dụng hiện tại:**
- ✅ Có trong `InvoiceResponse`
- ✅ Có trong `DebtSummaryResponse`
- ✅ Có trong `UpdateDebtInfoRequest`
- ✅ Được dùng trong `DebtServiceImpl`

**Phân tích:**
- Dùng cho debt management feature
- **KHÔNG NÊN XÓA** nếu có tính năng quản lý công nợ

**Recommendation:** ✅ **GIỮ LẠI** - Cần thiết cho debt management

---

## Tóm Tắt

| Cột | Sử Dụng | Recommendation | Lý Do |
|-----|---------|----------------|-------|
| `costType` | Chỉ cho EXPENSE | ⚠️ **XÓA** | Không dùng nếu chỉ có INCOME |
| `requestedBy` | Notification logic | ⚠️ **XÓA** | Có thể thay thế, không được set |
| `subtotal` | Tính VAT | ⚠️ **XÓA** | Có thể tính từ amount - vatAmount |
| `vatAmount` | Tính VAT | ⚠️ **XÓA** | Default = 0, không dùng |
| `dueDate` | Debt management | ✅ **GIỮ** | Quan trọng cho overdue tracking |
| `promiseToPayDate` | Debt management | ✅ **GIỮ** | Cần cho debt management |

---

## Script Xóa Các Cột (Nếu Quyết Định)

```sql
-- ⚠️ BACKUP TRƯỚC KHI CHẠY!

-- 1. Xóa costType
ALTER TABLE `invoices` DROP COLUMN `costType`;

-- 2. Xóa requestedBy (cần xóa foreign key trước)
ALTER TABLE `invoices` DROP FOREIGN KEY `fk_inv_reqDriver`;
ALTER TABLE `invoices` DROP INDEX `fk_inv_reqDriver`;
ALTER TABLE `invoices` DROP COLUMN `requestedBy`;

-- 3. Xóa subtotal
ALTER TABLE `invoices` DROP COLUMN `subtotal`;

-- 4. Xóa vatAmount
ALTER TABLE `invoices` DROP COLUMN `vatAmount`;
```

---

## Lưu Ý

1. **Backup database** trước khi xóa
2. **Update entity class** `Invoices.java` - xóa các fields tương ứng
3. **Update DTOs:**
   - `CreateInvoiceRequest.java`
   - `InvoiceResponse.java`
4. **Update service:**
   - `InvoiceServiceImpl.java` - xóa logic liên quan
5. **Update frontend** nếu có dùng các fields này
6. **Test kỹ** sau khi xóa

---

## Các Cột Nên Giữ Lại

- `dueDate` - Cần cho debt management
- `promiseToPayDate` - Cần cho debt management
- `debtLabel` - Cần cho debt management
- `contactNote` - Cần cho debt management
- `paymentTerms` - Cần cho tính dueDate

