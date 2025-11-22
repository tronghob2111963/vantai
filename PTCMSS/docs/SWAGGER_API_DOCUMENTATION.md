# 📚 Swagger API Documentation - Module 6

## 🚀 Truy cập Swagger UI

Sau khi chạy backend, truy cập Swagger UI tại:

```
http://localhost:8080/swagger-ui.html
```

hoặc

```
http://localhost:8080/swagger-ui/index.html
```

---

## 📋 Module 6 API Endpoints

### **1. Invoice Management** (`/api/invoices`)

#### ✅ **11 Endpoints:**

1. **POST `/api/invoices`** - Tạo hóa đơn mới
   - Body: `CreateInvoiceRequest`
   - Response: `InvoiceResponse`

2. **GET `/api/invoices/{invoiceId}`** - Lấy chi tiết hóa đơn
   - Path: `invoiceId` (Integer)
   - Response: `InvoiceResponse`

3. **GET `/api/invoices`** - Danh sách hóa đơn
   - Query params:
     - `branchId` (Integer, optional)
     - `type` (String: INCOME, EXPENSE, optional)
     - `status` (String: ACTIVE, CANCELLED, optional)
     - `paymentStatus` (String: UNPAID, PAID, OVERDUE, REFUNDED, optional)
     - `startDate` (LocalDate, optional)
     - `endDate` (LocalDate, optional)
     - `customerId` (Integer, optional)
     - `page` (int, default: 0)
     - `size` (int, default: 20)
     - `sortBy` (String, default: "invoiceDate")
     - `sortDir` (String: ASC, DESC, default: "DESC")
   - Response: `Page<InvoiceListResponse>`

4. **PUT `/api/invoices/{invoiceId}`** - Cập nhật hóa đơn
   - Path: `invoiceId` (Integer)
   - Body: `CreateInvoiceRequest`
   - Response: `InvoiceResponse`

5. **POST `/api/invoices/{invoiceId}/void`** - Hủy hóa đơn
   - Path: `invoiceId` (Integer)
   - Body: `VoidInvoiceRequest` (cần `cancellationReason`)
   - Response: `Void`

6. **POST `/api/invoices/{invoiceId}/send`** - Gửi hóa đơn qua email
   - Path: `invoiceId` (Integer)
   - Body: `SendInvoiceRequest` (cần `email`)
   - Response: `Void`

7. **POST `/api/invoices/{invoiceId}/payments`** - Ghi nhận thanh toán
   - Path: `invoiceId` (Integer)
   - Body: `RecordPaymentRequest`
   - Response: `PaymentHistoryResponse`

8. **GET `/api/invoices/{invoiceId}/payments`** - Lịch sử thanh toán
   - Path: `invoiceId` (Integer)
   - Response: `List<PaymentHistoryResponse>`

9. **GET `/api/invoices/{invoiceId}/balance`** - Tính số dư còn lại
   - Path: `invoiceId` (Integer)
   - Response: `BigDecimal`

10. **POST `/api/invoices/{invoiceId}/mark-paid`** - Đánh dấu đã thanh toán
    - Path: `invoiceId` (Integer)
    - Response: `Void`

11. **GET `/api/invoices/generate-number`** - Tạo số hóa đơn
    - Query params:
      - `branchId` (Integer, required)
      - `invoiceDate` (LocalDate, optional, default: today)
    - Response: `String` (invoice number)

---

### **2. Deposit Management** (`/api/deposits`)

#### ✅ **6 Endpoints:**

1. **POST `/api/deposits/bookings/{bookingId}`** - Tạo cọc cho booking
   - Path: `bookingId` (Integer, required)
   - Body: `CreateInvoiceRequest`
   - Response: `InvoiceResponse`

2. **GET `/api/deposits/bookings/{bookingId}`** - Danh sách cọc của booking
   - Path: `bookingId` (Integer, required)
   - Response: `List<InvoiceResponse>`

3. **GET `/api/deposits/bookings/{bookingId}/total-paid`** - Tổng cọc đã thu
   - Path: `bookingId` (Integer, required)
   - Response: `BigDecimal`

4. **GET `/api/deposits/bookings/{bookingId}/remaining`** - Số tiền còn lại
   - Path: `bookingId` (Integer, required)
   - Response: `BigDecimal`

5. **POST `/api/deposits/{depositId}/cancel`** - Hủy cọc
   - Path: `depositId` (Integer, required)
   - Query param: `reason` (String, required)
   - Response: `Void`

6. **GET `/api/deposits/generate-receipt-number`** - Tạo số phiếu thu
   - Query param: `branchId` (Integer, required)
   - Response: `String` (receipt number)

---

### **3. Debt Management** (`/api/debts`)

#### ✅ **7 Endpoints:**

1. **GET `/api/debts`** - Danh sách công nợ
   - Query params:
     - `branchId` (Integer, optional)
     - `overdueOnly` (Boolean, optional)
     - `page` (int, default: 0)
     - `size` (int, default: 20)
     - `sortBy` (String, default: "dueDate")
     - `sortDir` (String: ASC, DESC, default: "ASC")
   - Response: `Page<DebtSummaryResponse>`

2. **GET `/api/debts/aging`** - Phân tích aging buckets
   - Query params:
     - `branchId` (Integer, optional)
     - `asOfDate` (LocalDate, optional, default: today)
   - Response: `AgingBucketResponse`

3. **POST `/api/debts/{invoiceId}/reminder`** - Gửi nhắc nợ
   - Path: `invoiceId` (Integer, required)
   - Body: `SendDebtReminderRequest`
   - Response: `Void`

4. **GET `/api/debts/{invoiceId}/reminders`** - Lịch sử nhắc nợ
   - Path: `invoiceId` (Integer, required)
   - Response: `List<DebtReminderHistoryResponse>`

5. **PUT `/api/debts/{invoiceId}/info`** - Cập nhật thông tin nợ
   - Path: `invoiceId` (Integer, required)
   - Body: `UpdateDebtInfoRequest`
   - Response: `Void`

6. **PUT `/api/debts/{invoiceId}/promise-to-pay`** - Đặt hẹn thanh toán
   - Path: `invoiceId` (Integer, required)
   - Query param: `promiseDate` (LocalDate, required)
   - Response: `Void`

7. **PUT `/api/debts/{invoiceId}/label`** - Đặt nhãn nợ
   - Path: `invoiceId` (Integer, required)
   - Query param: `label` (String: VIP, TRANH_CHAP, NORMAL, required)
   - Response: `Void`

---

### **4. Accounting & Reports** (`/api/accounting`)

#### ✅ **8 Endpoints:**

1. **GET `/api/accounting/dashboard`** - Accounting Dashboard
   - Query params:
     - `branchId` (Integer, optional)
     - `period` (String: TODAY, THIS_WEEK, THIS_MONTH, THIS_QUARTER, YTD, default: "THIS_MONTH")
   - Response: `AccountingDashboardResponse`

2. **GET `/api/accounting/revenue`** - Báo cáo doanh thu
   - Query params:
     - `branchId` (Integer, optional)
     - `customerId` (Integer, optional)
     - `startDate` (LocalDate, optional)
     - `endDate` (LocalDate, optional)
     - `period` (String: TODAY, 7D, 30D, MONTH, QUARTER, YTD, optional)
   - Response: `RevenueReportResponse`

3. **GET `/api/accounting/expense`** - Báo cáo chi phí
   - Query params:
     - `branchId` (Integer, optional)
     - `vehicleId` (Integer, optional)
     - `driverId` (Integer, optional)
     - `expenseType` (String: fuel, toll, maintenance, salary, etc., optional)
     - `startDate` (LocalDate, optional)
     - `endDate` (LocalDate, optional)
   - Response: `ExpenseReportResponse`

4. **GET `/api/accounting/stats/revenue`** - Tổng doanh thu
   - Query params:
     - `branchId` (Integer, optional)
     - `startDate` (LocalDate, required)
     - `endDate` (LocalDate, required)
   - Response: `BigDecimal`

5. **GET `/api/accounting/stats/expense`** - Tổng chi phí
   - Query params:
     - `branchId` (Integer, optional)
     - `startDate` (LocalDate, required)
     - `endDate` (LocalDate, required)
   - Response: `BigDecimal`

6. **GET `/api/accounting/stats/ar-balance`** - Công nợ phải thu
   - Query param: `branchId` (Integer, optional)
   - Response: `BigDecimal`

7. **GET `/api/accounting/stats/invoices-due`** - Hóa đơn đến hạn 7 ngày
   - Query param: `branchId` (Integer, optional)
   - Response: `Integer`

8. **GET `/api/accounting/stats/overdue`** - Hóa đơn quá hạn
   - Query param: `branchId` (Integer, optional)
   - Response: `Integer`

---

### **5. Export Services** (`/api/export`)

#### ✅ **6 Endpoints:**

1. **GET `/api/export/revenue/excel`** - Export báo cáo doanh thu Excel
   - Query params: (giống `/api/accounting/revenue`)
   - Response: File download (CSV format)

2. **GET `/api/export/expense/excel`** - Export báo cáo chi phí Excel
   - Query params: (giống `/api/accounting/expense`)
   - Response: File download (CSV format)

3. **GET `/api/export/invoices/excel`** - Export danh sách invoices Excel
   - Query params:
     - `branchId` (Integer, optional)
     - `type` (String: INCOME, EXPENSE, optional)
     - `status` (String: ACTIVE, CANCELLED, optional)
   - Response: File download (CSV format)

4. **GET `/api/export/invoice/{invoiceId}/pdf`** - Export invoice PDF
   - Path: `invoiceId` (Integer, required)
   - Response: File download (PDF format)

5. **GET `/api/export/revenue/csv`** - Export báo cáo doanh thu CSV
   - Query params: (giống `/api/accounting/revenue`)
   - Response: File download (CSV format)

6. **GET `/api/export/expense/csv`** - Export báo cáo chi phí CSV
   - Query params: (giống `/api/accounting/expense`)
   - Response: File download (CSV format)

---

## 📝 Request/Response Examples

### **Create Invoice Request:**
```json
{
  "branchId": 1,
  "bookingId": 123,
  "customerId": 456,
  "type": "INCOME",
  "amount": 1000000.00,
  "paymentMethod": "BANK_TRANSFER",
  "paymentTerms": "NET_7",
  "dueDate": "2025-12-01",
  "vatRate": 0.08,
  "subtotal": 925925.93,
  "note": "Payment for booking #123"
}
```

### **Record Payment Request:**
```json
{
  "amount": 500000.00,
  "paymentMethod": "CASH",
  "paymentDate": "2025-11-22",
  "note": "Partial payment"
}
```

### **Send Debt Reminder Request:**
```json
{
  "reminderType": "EMAIL",
  "message": "Vui lòng thanh toán hóa đơn sớm nhất có thể"
}
```

---

## 🔑 Authentication

Nếu API yêu cầu authentication, thêm header:
```
Authorization: Bearer {token}
```

Trong Swagger UI, click nút **"Authorize"** ở góc trên bên phải và nhập token.

---

## 🧪 Testing Tips

1. **Test theo thứ tự:**
   - Tạo invoice → Ghi nhận thanh toán → Xem dashboard
   - Tạo deposit → Xem danh sách → Tính số dư
   - Gửi nhắc nợ → Xem lịch sử

2. **Test với dữ liệu thực:**
   - Sử dụng `branchId`, `customerId`, `bookingId` có thật trong database
   - Kiểm tra validation errors

3. **Test Export:**
   - Export endpoints trả về file, không phải JSON
   - Browser sẽ tự động download file

---

## 📊 Swagger UI Features

- ✅ **Try it out** - Test API trực tiếp
- ✅ **Schema** - Xem cấu trúc Request/Response
- ✅ **Examples** - Xem ví dụ dữ liệu
- ✅ **Parameters** - Xem tất cả query params
- ✅ **Responses** - Xem các response codes

---

**Happy Testing! 🚀**

