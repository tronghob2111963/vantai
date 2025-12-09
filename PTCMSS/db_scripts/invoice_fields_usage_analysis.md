# Phân Tích Sử Dụng Các Fields Có Thể Xóa - Bảng `invoices`

## Tổng Quan

Kiểm tra chi tiết các nơi sử dụng 4 fields có thể xóa:
1. `costType`
2. `requestedBy`
3. `subtotal`
4. `vatAmount`

---

## 1. `costType` - Phân Tích Sử Dụng

### Backend Files Sử Dụng (13 files):

#### ✅ **CÓ THỂ XÓA** - Chỉ dùng cho EXPENSE invoices:

1. **`InvoiceServiceImpl.java`**
   - Line 87: `invoice.setCostType(request.getCostType());`
   - Line 416: `response.setCostType(invoice.getCostType());`
   - **Impact:** Chỉ set/get, không có logic quan trọng

2. **`VehicleServiceImpl.java`**
   - Tạo expense invoices cho vehicle maintenance
   - Line 273: `invoice.setCostType("maintenance");`
   - Line 306: `invoice.setCostType("maintenance");`
   - **Impact:** Nếu không dùng vehicle expense invoices → có thể xóa

3. **`CreateInvoiceRequest.java`**
   - Line 22: `private String costType; // For expense: fuel, toll, maintenance, etc.`
   - **Impact:** Chỉ là field trong DTO

4. **`InvoiceResponse.java`**
   - Line 21: `private String costType;`
   - **Impact:** Chỉ là field trong DTO

5. **`ExpenseReportResponse.java`**
   - Dùng để group expenses by category
   - **Impact:** Có thể thay thế bằng logic khác

6. **`VehicleExpenseResponse.java`**
   - Hiển thị costType trong vehicle expenses
   - **Impact:** Có thể xóa nếu không cần

7. **`AccountingServiceImpl.java`**
   - Line 646-676: Group expenses by costType
   - **Impact:** Có thể thay thế bằng logic khác

8. **`InvoiceRepository.java`**
   - Query methods có thể filter by costType
   - **Impact:** Cần check query methods

9. **`AnalyticsService.java`**
   - Có thể dùng costType trong analytics
   - **Impact:** Cần check chi tiết

10. **Test files** - Có thể update sau

### Frontend Files Sử Dụng (6 files):

1. **`ExpenseReportPage.jsx`** - Hiển thị costType trong báo cáo
2. **`VehicleDetailPage.jsx`** - Hiển thị vehicle expenses
3. **`TripExpenseModal.jsx`** - Form tạo expense
4. **`vehicles.js`** - API calls
5. **`accounting.js`** - API calls
6. **`exports.js`** - Export functionality

### ⚠️ **KẾT LUẬN `costType`:**
- **CÓ THỂ XÓA** nếu chắc chắn không dùng EXPENSE invoices
- **CẦN UPDATE:** 13 backend files + 6 frontend files
- **RISK:** Medium - Có thể ảnh hưởng expense reporting

---

## 2. `requestedBy` - Phân Tích Sử Dụng

### Backend Files Sử Dụng (13 files):

#### ✅ **CÓ THỂ XÓA** - Chỉ dùng cho notification:

1. **`InvoiceServiceImpl.java`**
   - Line 578-580: Dùng để lấy driver user ID cho notification
   ```java
   if (invoice != null && invoice.getRequestedBy() != null && invoice.getRequestedBy().getEmployee() != null 
       && invoice.getRequestedBy().getEmployee().getUser() != null) {
       driverUserId = invoice.getRequestedBy().getEmployee().getUser().getId();
   }
   ```
   - **Impact:** Có thể thay thế bằng cách lấy từ booking hoặc payment.getCreatedBy()

2. **`Invoices.java`** (Entity)
   - Line 102-104: Field definition
   - **Impact:** Chỉ là field definition

3. **`NotificationServiceImpl.java`**
   - Có thể dùng requestedBy
   - **Impact:** Cần check chi tiết

4. **`ApprovalHistory.java`** và các file approval khác
   - Có thể có requestedBy nhưng là field khác (không phải của Invoices)
   - **Impact:** Không liên quan

5. **Test files** - Có thể update sau

### Frontend Files Sử Dụng (3 files):

1. **`NotificationsWidget.jsx`** - Hiển thị notification
2. **`NotificationsDashboard.jsx`** - Dashboard notifications
3. **`AccountantDashboard.jsx`** - Có thể hiển thị thông tin

### ⚠️ **KẾT LUẬN `requestedBy`:**
- **CÓ THỂ XÓA** - Chỉ dùng cho notification logic
- **CẦN UPDATE:** 13 backend files + 3 frontend files
- **RISK:** Low - Có thể thay thế bằng logic khác
- **ALTERNATIVE:** Lấy driver từ booking hoặc payment.getCreatedBy()

---

## 3. `subtotal` - Phân Tích Sử Dụng

### Backend Files Sử Dụng (6 files):

#### ✅ **CÓ THỂ XÓA** - Chỉ dùng cho VAT calculation:

1. **`InvoiceServiceImpl.java`**
   - Line 90: `invoice.setSubtotal(request.getSubtotal());`
   - Line 419: `response.setSubtotal(invoice.getSubtotal());`
   - **Impact:** Chỉ set/get, không có logic tính toán quan trọng

2. **`CreateInvoiceRequest.java`**
   - Line 30: `private BigDecimal subtotal;`
   - **Impact:** Chỉ là field trong DTO

3. **`InvoiceResponse.java`**
   - Line 24: `private BigDecimal subtotal;`
   - **Impact:** Chỉ là field trong DTO

4. **`Invoices.java`** (Entity)
   - Line 68-69: Field definition
   - **Impact:** Chỉ là field definition

5. **Test files** - Có thể update sau

### Frontend Files Sử Dụng:
- **KHÔNG TÌM THẤY** - Không có file nào sử dụng

### ⚠️ **KẾT LUẬN `subtotal`:**
- **CÓ THỂ XÓA** - Không có logic quan trọng
- **CẦN UPDATE:** 6 backend files
- **RISK:** Low - Có thể tính từ amount - vatAmount nếu cần

---

## 4. `vatAmount` - Phân Tích Sử Dụng

### Backend Files Sử Dụng (6 files):

#### ✅ **CÓ THỂ XÓA** - Default = 0, không dùng:

1. **`InvoiceServiceImpl.java`**
   - Line 91: `invoice.setVatAmount(request.getVatAmount() != null ? request.getVatAmount() : BigDecimal.ZERO);`
   - Line 420: `response.setVatAmount(invoice.getVatAmount());`
   - **Impact:** Luôn default = 0, không có logic tính toán

2. **`CreateInvoiceRequest.java`**
   - Line 32: `private BigDecimal vatAmount;`
   - **Impact:** Chỉ là field trong DTO

3. **`InvoiceResponse.java`**
   - Line 25: `private BigDecimal vatAmount;`
   - **Impact:** Chỉ là field trong DTO

4. **`Invoices.java`** (Entity)
   - Line 64-66: Field definition với default = 0
   - **Impact:** Chỉ là field definition

5. **Test files** - Có thể update sau

### Frontend Files Sử Dụng:
- **KHÔNG TÌM THẤY** - Không có file nào sử dụng

### ⚠️ **KẾT LUẬN `vatAmount`:**
- **CÓ THỂ XÓA** - Luôn = 0, không dùng
- **CẦN UPDATE:** 6 backend files
- **RISK:** Low - Không có logic phụ thuộc

---

## Tổng Kết

| Field | Backend Files | Frontend Files | Risk | Có Thể Xóa? |
|-------|---------------|----------------|------|-------------|
| `costType` | 13 files | 6 files | Medium | ✅ Có thể (nếu không dùng EXPENSE) |
| `requestedBy` | 13 files | 3 files | Low | ✅ Có thể (có thể thay thế) |
| `subtotal` | 6 files | 0 files | Low | ✅ Có thể |
| `vatAmount` | 6 files | 0 files | Low | ✅ Có thể |

---

## Checklist Trước Khi Xóa

### 1. `costType`
- [ ] Kiểm tra có invoice nào type = EXPENSE không
- [ ] Update `VehicleServiceImpl.java` - xóa logic tạo expense invoices
- [ ] Update `AccountingServiceImpl.java` - xóa group by costType
- [ ] Update `ExpenseReportResponse.java` - xóa costType grouping
- [ ] Update frontend expense reports

### 2. `requestedBy`
- [ ] Update `InvoiceServiceImpl.java` - thay thế notification logic
- [ ] Update notification services
- [ ] Update frontend notifications

### 3. `subtotal`
- [ ] Update DTOs (CreateInvoiceRequest, InvoiceResponse)
- [ ] Update entity (Invoices.java)
- [ ] Update service (InvoiceServiceImpl.java)
- [ ] Update tests

### 4. `vatAmount`
- [ ] Update DTOs (CreateInvoiceRequest, InvoiceResponse)
- [ ] Update entity (Invoices.java)
- [ ] Update service (InvoiceServiceImpl.java)
- [ ] Update tests

---

## Script Migration

```sql
-- ⚠️ BACKUP DATABASE TRƯỚC KHI CHẠY!

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

## Lưu Ý Quan Trọng

1. **Backup database** trước khi chạy migration
2. **Test kỹ** sau khi xóa
3. **Update tất cả files** được liệt kê ở trên
4. **Kiểm tra EXPENSE invoices** - Nếu có dùng thì KHÔNG xóa `costType`
5. **Thay thế notification logic** cho `requestedBy` trước khi xóa


