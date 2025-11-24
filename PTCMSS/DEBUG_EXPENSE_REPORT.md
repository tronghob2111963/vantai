# Debug Expense Report - Hướng dẫn khắc phục

## Vấn đề
API `/api/accounting/expense` trả về tất cả giá trị = 0

## Các bước kiểm tra

### 1. Kiểm tra dữ liệu trong database

Chạy script `debug_expense_data.sql` để kiểm tra:

```bash
# Kết nối vào MySQL
mysql -u root -p ptcmss_db

# Chạy script
source debug_expense_data.sql
```

**Kết quả mong đợi:**
- Phải có ít nhất một số bản ghi với `type = 'EXPENSE'`
- `status = 'ACTIVE'`
- `invoice_date` trong khoảng thời gian bạn query

**Nếu không có dữ liệu:**
- Chạy `insert_test_expense_data.sql` để tạo dữ liệu test
- Hoặc kiểm tra xem expense có đang được tạo từ module nào khác không

### 2. Kiểm tra request parameters

Khi gọi API, đảm bảo:

```javascript
// Frontend request
const params = {
    branchId: 1,  // Có thể bỏ qua nếu muốn lấy tất cả branches
    startDate: '2025-11-01',
    endDate: '2025-11-24'
};
```

**Lưu ý:**
- Nếu không truyền `startDate`/`endDate`, backend sẽ mặc định lấy tháng hiện tại
- Kiểm tra `branchId` có tồn tại trong database không
- Nếu truyền `expenseType`, phải khớp với giá trị `cost_type` trong DB

### 3. Kiểm tra backend logs

Thêm logging vào `AccountingServiceImpl.java`:

```java
@Override
public ExpenseReportResponse getExpenseReport(ExpenseReportRequest request) {
    log.info("[DEBUG] Request: {}", request);
    log.info("[DEBUG] Date range: {} to {}", startDate, endDate);
    log.info("[DEBUG] Found {} expenses", expenses.size());
    
    // ... rest of code
}
```

Xem logs để biết:
- Request parameters có đúng không
- Date range có đúng không
- Query có tìm thấy dữ liệu không

### 4. Các nguyên nhân thường gặp

#### A. Không có dữ liệu expense
**Giải pháp:** Tạo expense từ UI hoặc chạy script insert test data

#### B. Date range không đúng
**Vấn đề:** Frontend gửi date format không đúng hoặc timezone khác nhau

**Giải pháp:**
```java
// Đảm bảo convert đúng timezone
Instant start = startDate.atStartOfDay(ZoneId.systemDefault()).toInstant();
Instant end = endDate.atTime(23, 59, 59).atZone(ZoneId.systemDefault()).toInstant();
```

#### C. Filter quá chặt
**Vấn đề:** `branchId` hoặc `expenseType` filter loại bỏ hết dữ liệu

**Giải pháp:** 
- Thử gọi API không có filter
- Kiểm tra giá trị filter có tồn tại trong DB không

#### D. Enum không khớp
**Vấn đề:** `InvoiceType.EXPENSE` hoặc `InvoiceStatus.ACTIVE` không khớp với DB

**Giải pháp:**
```sql
-- Kiểm tra giá trị enum trong DB
SELECT DISTINCT type, status FROM invoices;
```

### 5. Test API trực tiếp

Dùng Postman hoặc curl:

```bash
# Test không có filter
curl -X GET "http://localhost:8080/api/accounting/expense" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test với date range
curl -X GET "http://localhost:8080/api/accounting/expense?startDate=2025-11-01&endDate=2025-11-24" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test với branch
curl -X GET "http://localhost:8080/api/accounting/expense?branchId=1&startDate=2025-11-01&endDate=2025-11-24" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 6. Kiểm tra InvoiceRepository

Đảm bảo method `findInvoicesWithFilters` hoạt động đúng:

```java
// Test trong service
List<Invoices> allExpenses = invoiceRepository.findInvoicesWithFilters(
    null,  // no branch filter
    InvoiceType.EXPENSE,
    InvoiceStatus.ACTIVE,
    null,  // no date filter
    null,
    null,
    null
);
log.info("Total expenses in DB: {}", allExpenses.size());
```

## Giải pháp nhanh

Nếu cần test ngay, tạo expense thủ công:

```sql
INSERT INTO invoices (
    branch_id, type, amount, cost_type, invoice_number,
    invoice_date, payment_status, status, created_at, updated_at
) VALUES (
    1, 'EXPENSE', 1000000, 'FUEL', 'TEST-001',
    NOW(), 'UNPAID', 'ACTIVE', NOW(), NOW()
);
```

Sau đó gọi lại API để kiểm tra.

## Checklist

- [ ] Có dữ liệu expense trong database
- [ ] Date range đúng với dữ liệu
- [ ] Branch ID tồn tại (nếu có filter)
- [ ] Enum values khớp với DB
- [ ] Timezone được xử lý đúng
- [ ] Repository query hoạt động
- [ ] Logs hiển thị đúng số lượng records

## Liên hệ

Nếu vẫn gặp vấn đề, cung cấp:
1. Backend logs
2. Request parameters
3. Kết quả query SQL từ `debug_expense_data.sql`
