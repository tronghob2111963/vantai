# Danh Sách Files Đã Update - Xóa Fields Không Dùng

## ✅ Đã Update (Backend)

### 1. Entity & DTOs
- ✅ `Invoices.java` - Xóa: costType, vatAmount, subtotal, requestedBy
- ✅ `CreateInvoiceRequest.java` - Xóa: costType, subtotal, vatAmount
- ✅ `InvoiceResponse.java` - Xóa: costType, subtotal, vatAmount

### 2. Services
- ✅ `InvoiceServiceImpl.java` - Xóa logic set/get các fields, update notification logic
- ✅ `VehicleServiceImpl.java` - Comment/remove costType usage
- ✅ `AccountingServiceImpl.java` - Update getExpenseByCategoryMap() để không dùng costType

## ⚠️ Cần Update Thêm (Backend)

### 1. DTOs khác
- `VehicleExpenseResponse.java` - Có thể giữ costType field nhưng set null
- `ExpenseReportResponse.java` - Có thể cần update logic grouping

### 2. Repository
- `InvoiceRepository.java` - Kiểm tra query methods có filter by costType không

### 3. Tests
- Tất cả test files cần update

## ⚠️ Cần Update (Frontend)

### Files sử dụng costType:
1. `ExpenseReportPage.jsx` - Filter và hiển thị costType
2. `VehicleDetailPage.jsx` - Hiển thị vehicle expenses
3. `TripExpenseModal.jsx` - Form tạo expense
4. `vehicles.js` - API calls
5. `accounting.js` - API calls
6. `exports.js` - Export functionality

### Files sử dụng requestedBy:
1. `NotificationsWidget.jsx`
2. `NotificationsDashboard.jsx`
3. `AccountantDashboard.jsx`

## Migration Script

Đã tạo: `migration_remove_unused_invoice_fields.sql`

**Chạy migration sau khi:**
1. ✅ Update tất cả backend files
2. ⚠️ Update frontend files (hoặc để null/undefined)
3. ⚠️ Test kỹ

## Rủi Ro

- **LOW:** subtotal, vatAmount - Không có logic phụ thuộc
- **LOW:** requestedBy - Đã thay thế bằng logic khác
- **MEDIUM:** costType - Đang dùng trong expense reports, cần update frontend


