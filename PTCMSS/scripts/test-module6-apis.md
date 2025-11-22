# 🧪 Module 6 API Test Script

## 📋 Mô tả

Script test tự động cho tất cả **38 endpoints** của Module 6 với authentication đầy đủ.

## 🚀 Cài đặt

### 1. Cài đặt dependencies:

```bash
cd PTCMSS/scripts
npm install axios
```

Hoặc nếu chưa có `package.json`:

```bash
npm init -y
npm install axios
```

## 📝 Sử dụng

### Chạy script:

```bash
node test-module6-apis.js
```

### Thay đổi user test:

Mở file `test-module6-apis.js` và sửa:

```javascript
const USERNAME = 'admin'; // Có thể đổi thành:
// 'manager_hn' - Manager Hà Nội
// 'manager_dn' - Manager Đà Nẵng
// 'accountant_hn1' - Kế toán Hà Nội
// 'consultant_hn1' - Điều hành viên
```

Tất cả users có password: `123456`

## 📊 Test Coverage

### ✅ **Invoice Management** (11 endpoints)
1. Generate Invoice Number
2. Create Invoice (Income)
3. Create Invoice (Expense)
4. Get Invoice by ID
5. Get Invoices List
6. Update Invoice
7. Record Payment
8. Get Payment History
9. Get Invoice Balance
10. Send Invoice via Email
11. Mark Invoice as Paid

### ✅ **Deposit Management** (6 endpoints)
1. Generate Receipt Number
2. Create Deposit
3. Get Deposits by Booking
4. Get Total Deposit Paid
5. Get Remaining Amount
6. Cancel Deposit (optional)

### ✅ **Debt Management** (7 endpoints)
1. Get Debts List
2. Get Aging Buckets
3. Send Debt Reminder
4. Get Reminder History
5. Update Debt Info
6. Set Promise to Pay
7. Set Debt Label

### ✅ **Accounting & Reports** (8 endpoints)
1. Get Accounting Dashboard
2. Get Revenue Report
3. Get Expense Report
4. Get Total Revenue
5. Get Total Expense
6. Get AR Balance
7. Get Invoices Due in 7 Days
8. Get Overdue Invoices

### ✅ **Export Services** (6 endpoints)
1. Export Revenue Excel
2. Export Expense Excel
3. Export Invoices Excel
4. Export Invoice PDF
5. Export Revenue CSV
6. Export Expense CSV

## 📈 Kết quả

Script sẽ hiển thị:
- ✅ Số lượng test passed
- ❌ Số lượng test failed
- 📊 Success rate
- ❌ Chi tiết lỗi (nếu có)

## 🔧 Configuration

### Thay đổi base URL:

```javascript
const BASE_URL = 'http://localhost:8080'; // Đổi nếu backend chạy port khác
```

### Thay đổi user:

```javascript
const USERNAME = 'admin';
const PASSWORD = '123456';
```

## ⚠️ Lưu ý

1. **Backend phải đang chạy** trên `http://localhost:8080`
2. **Database phải có seed data** (chạy SQL script trước)
3. **Một số test có thể fail** nếu:
   - Dữ liệu không tồn tại (bookingId, customerId, etc.)
   - Permissions không đủ (một số endpoints cần role cụ thể)
   - Validation errors

## 🐛 Troubleshooting

### Lỗi "Cannot connect":
- Kiểm tra backend có đang chạy không
- Kiểm tra BASE_URL có đúng không

### Lỗi "401 Unauthorized":
- Kiểm tra username/password
- Kiểm tra token có được lưu đúng không

### Lỗi "404 Not Found":
- Kiểm tra endpoint path có đúng không
- Kiểm tra database có seed data chưa

## 📝 Example Output

```
================================================================================
🧪 MODULE 6 API TEST SUITE
================================================================================

🔐 Logging in...
✅ Login successful!
   User: admin (Admin)
   User ID: 1
   Token: eyJhbGciOiJIUzI1NiIs...

================================================================================
📋 STARTING TESTS...
================================================================================

📄 1. INVOICE MANAGEMENT
--------------------------------------------------------------------------------
Testing: Generate Invoice Number... ✅ PASSED
Testing: Create Invoice (Income)... ✅ PASSED
Testing: Create Invoice (Expense)... ✅ PASSED
...

================================================================================
📊 TEST SUMMARY
================================================================================
✅ Passed: 35
❌ Failed: 3
📈 Success Rate: 92.11%

================================================================================
✨ Test completed!
================================================================================
```

## 🔄 Chạy với nhiều users

Tạo script riêng để test với nhiều users:

```javascript
const users = ['admin', 'manager_hn', 'accountant_hn1'];

for (const user of users) {
    console.log(`\n\nTesting with user: ${user}`);
    // ... run tests
}
```

---

**Happy Testing! 🚀**

