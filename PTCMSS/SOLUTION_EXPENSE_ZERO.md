# Giải pháp cho vấn đề Expense Report trả về 0

## Tình huống
- Database có 6 expense records, tổng 12,300,000 VND
- API trả về tất cả giá trị = 0

## Nguyên nhân có thể

### 1. Invoice_date không nằm trong khoảng query

**Kiểm tra:** Chạy query này
```sql
SELECT 
    id,
    invoice_number,
    DATE(invoice_date) as date,
    amount,
    cost_type
FROM invoices 
WHERE type = 'EXPENSE' 
  AND status = 'ACTIVE'
ORDER BY invoice_date DESC;
```

**Nếu các expense có ngày < 2025-11-01 hoặc > 2025-11-24:**

Có 2 cách fix:

#### Cách 1: Update ngày của expense về tháng 11/2025
```sql
UPDATE invoices 
SET invoice_date = '2025-11-15 10:00:00'
WHERE type = 'EXPENSE' 
  AND status = 'ACTIVE';
```

#### Cách 2: Gọi API không có date filter
```javascript
// Frontend - không truyền startDate/endDate
const response = await fetch('/api/accounting/expense?branchId=1');
```

Hoặc truyền date range rộng hơn:
```javascript
const response = await fetch('/api/accounting/expense?startDate=2024-01-01&endDate=2025-12-31');
```

### 2. Branch filter không khớp

**Kiểm tra:** 
```sql
SELECT branch_id, COUNT(*), SUM(amount)
FROM invoices 
WHERE type = 'EXPENSE' 
  AND status = 'ACTIVE'
GROUP BY branch_id;
```

**Nếu expense thuộc branch khác với branchId trong request:**

#### Fix: Gọi API không có branchId filter
```javascript
// Không truyền branchId để lấy tất cả
const response = await fetch('/api/accounting/expense?startDate=2025-11-01&endDate=2025-11-24');
```

### 3. Backend xử lý date range sai

**Vấn đề:** Method `getDateRangeFromRequest` có thể trả về range không đúng

**Fix trong AccountingServiceImpl.java:**

```java
private LocalDate[] getDateRangeFromRequest(ExpenseReportRequest request) {
    // Nếu có startDate và endDate từ request, dùng luôn
    if (request.getStartDate() != null && request.getEndDate() != null) {
        log.info("[DEBUG] Using date range from request: {} to {}", 
            request.getStartDate(), request.getEndDate());
        return new LocalDate[]{request.getStartDate(), request.getEndDate()};
    }
    
    // Nếu không có, lấy toàn bộ dữ liệu (không filter date)
    // Thay vì mặc định THIS_MONTH
    log.warn("[DEBUG] No date range provided, using all-time range");
    return new LocalDate[]{
        LocalDate.of(2020, 1, 1),  // Từ năm 2020
        LocalDate.now().plusYears(1)  // Đến năm sau
    };
}
```

### 4. Timezone issue

**Vấn đề:** Convert LocalDate sang Instant bị sai timezone

**Fix:**
```java
// Đảm bảo dùng timezone của hệ thống
Instant start = startDate.atStartOfDay(ZoneId.systemDefault()).toInstant();
Instant end = endDate.atTime(23, 59, 59).atZone(ZoneId.systemDefault()).toInstant();

log.info("[DEBUG] Instant range: {} to {}", start, end);
```

## Test nhanh

### Test 1: Gọi API không có filter
```bash
curl -X GET "http://localhost:8080/api/accounting/expense" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Nếu vẫn trả về 0 → Vấn đề ở backend logic

### Test 2: Kiểm tra repository method
Thêm vào AccountingServiceImpl:
```java
// Test query without any filters
List<Invoices> allExpenses = invoiceRepository.findAll().stream()
    .filter(inv -> inv.getType() == InvoiceType.EXPENSE)
    .filter(inv -> inv.getStatus() == InvoiceStatus.ACTIVE)
    .collect(Collectors.toList());
    
log.info("[DEBUG] Total EXPENSE invoices in DB: {}", allExpenses.size());
```

### Test 3: Kiểm tra enum values
```sql
-- Xem giá trị thực tế trong DB
SELECT DISTINCT type, status FROM invoices;
```

Nếu DB lưu là `'EXPENSE'` (string) nhưng code dùng enum, có thể không khớp.

## Giải pháp tạm thời

Nếu cần demo ngay, update ngày của expense về tháng hiện tại:

```sql
-- Update tất cả expense về tháng 11/2025
UPDATE invoices 
SET invoice_date = DATE_ADD(
    '2025-11-01', 
    INTERVAL (id % 24) DAY
)
WHERE type = 'EXPENSE' 
  AND status = 'ACTIVE';

-- Kiểm tra lại
SELECT 
    DATE(invoice_date) as date,
    COUNT(*) as count,
    SUM(amount) as total
FROM invoices 
WHERE type = 'EXPENSE' 
  AND status = 'ACTIVE'
  AND invoice_date >= '2025-11-01'
  AND invoice_date <= '2025-11-24'
GROUP BY DATE(invoice_date);
```

## Checklist debug

1. [ ] Chạy `check_expense_dates.sql` để xem ngày của expense
2. [ ] Kiểm tra request parameters (branchId, startDate, endDate)
3. [ ] Xem backend logs khi gọi API
4. [ ] Test API không có filter
5. [ ] Kiểm tra enum values trong DB vs code
6. [ ] Verify timezone conversion

## Kết quả mong đợi

Sau khi fix, API response sẽ có:
```json
{
  "totalExpense": 12300000,
  "totalExpenseRequests": 6,
  "expenseByCategory": {
    "FUEL": 2500000,
    "MAINTENANCE": 5000000,
    ...
  }
}
```
