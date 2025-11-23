# 🧪 Module 6 API Test Scripts

## 📋 Tổng quan

Bộ script test tự động cho tất cả **38 endpoints** của Module 6 với authentication đầy đủ.

## 🚀 Quick Start

### 1. Cài đặt dependencies:

```bash
cd PTCMSS/scripts
npm install
```

### 2. Chạy test:

```bash
# Test với admin (mặc định)
npm test

# Hoặc
node test-module6-apis.js

# Test với user khác
node test-module6-apis.js manager_hn
node test-module6-apis.js accountant_hn1
node test-module6-apis.js consultant_hn1
```

## 👥 Available Users

Tất cả users có password: `123456`

| Username | Role | Branch | Description |
|----------|------|--------|-------------|
| `admin` | Admin | All | Quản trị viên hệ thống |
| `manager_hn` | Manager | Hà Nội | Quản lý chi nhánh Hà Nội |
| `manager_dn` | Manager | Đà Nẵng | Quản lý chi nhánh Đà Nẵng |
| `manager_hcm` | Manager | TP. HCM | Quản lý chi nhánh TP. HCM |
| `accountant_hn1` | Accountant | Hà Nội | Kế toán Hà Nội |
| `consultant_hn1` | Consultant | Hà Nội | Điều hành viên 1 |
| `consultant_hn2` | Consultant | Hà Nội | Điều hành viên 2 |

## 📊 Test Coverage

### ✅ **38 Endpoints được test:**

1. **Invoice Management** (11 endpoints)
2. **Deposit Management** (6 endpoints)
3. **Debt Management** (7 endpoints)
4. **Accounting & Reports** (8 endpoints)
5. **Export Services** (6 endpoints)

## 📈 Kết quả mẫu

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
Testing: Get Invoice by ID... ✅ PASSED
Testing: Get Invoices List... ✅ PASSED
Testing: Update Invoice... ✅ PASSED
Testing: Record Payment... ✅ PASSED
Testing: Get Payment History... ✅ PASSED
Testing: Get Invoice Balance... ✅ PASSED
Testing: Send Invoice via Email... ✅ PASSED
Testing: Mark Invoice as Paid... ✅ PASSED

💰 2. DEPOSIT MANAGEMENT
--------------------------------------------------------------------------------
Testing: Generate Receipt Number... ✅ PASSED
Testing: Create Deposit... ✅ PASSED
Testing: Get Deposits by Booking... ✅ PASSED
Testing: Get Total Deposit Paid... ✅ PASSED
Testing: Get Remaining Amount... ✅ PASSED

💳 3. DEBT MANAGEMENT
--------------------------------------------------------------------------------
Testing: Get Debts List... ✅ PASSED
Testing: Get Aging Buckets... ✅ PASSED
Testing: Send Debt Reminder... ✅ PASSED
Testing: Get Reminder History... ✅ PASSED
Testing: Update Debt Info... ✅ PASSED
Testing: Set Promise to Pay... ✅ PASSED
Testing: Set Debt Label... ✅ PASSED

📊 4. ACCOUNTING & REPORTS
--------------------------------------------------------------------------------
Testing: Get Accounting Dashboard... ✅ PASSED
Testing: Get Revenue Report... ✅ PASSED
Testing: Get Expense Report... ✅ PASSED
Testing: Get Total Revenue... ✅ PASSED
Testing: Get Total Expense... ✅ PASSED
Testing: Get AR Balance... ✅ PASSED
Testing: Get Invoices Due in 7 Days... ✅ PASSED
Testing: Get Overdue Invoices... ✅ PASSED

📥 5. EXPORT SERVICES
--------------------------------------------------------------------------------
Testing: Export Revenue Excel... ✅ PASSED
Testing: Export Expense Excel... ✅ PASSED
Testing: Export Invoices Excel... ✅ PASSED
Testing: Export Invoice PDF... ✅ PASSED
Testing: Export Revenue CSV... ✅ PASSED
Testing: Export Expense CSV... ✅ PASSED

================================================================================
📊 TEST SUMMARY
================================================================================
✅ Passed: 38
❌ Failed: 0
📈 Success Rate: 100.00%

================================================================================
✨ Test completed!
================================================================================
```

## ⚙️ Configuration

### Thay đổi Base URL:

Sửa trong `test-module6-apis.js`:

```javascript
const BASE_URL = 'http://localhost:8080'; // Đổi nếu backend chạy port khác
```

### Thay đổi Password:

```javascript
const PASSWORD = '123456'; // Password mặc định cho tất cả users
```

## 🔧 Requirements

- Node.js (v14+)
- Backend đang chạy trên `http://localhost:8080`
- Database đã có seed data
- Dependencies: `axios`

## ⚠️ Lưu ý

1. **Backend phải đang chạy** trước khi chạy script
2. **Database phải có seed data** (chạy SQL script trước)
3. **Một số test có thể fail** nếu:
   - Dữ liệu không tồn tại (bookingId, customerId, etc.)
   - Permissions không đủ (một số endpoints cần role cụ thể)
   - Validation errors

## 🐛 Troubleshooting

### Lỗi "Cannot connect":
```bash
# Kiểm tra backend có đang chạy không
curl http://localhost:8080/api/auth/login
```

### Lỗi "401 Unauthorized":
- Kiểm tra username/password
- Kiểm tra password hash trong database

### Lỗi "404 Not Found":
- Kiểm tra endpoint path
- Kiểm tra database có seed data chưa

## 📝 Files

- `test-module6-apis.js` - Main test script
- `test-module6-apis.md` - Detailed documentation
- `package.json` - Dependencies
- `README.md` - This file

## 🎯 Next Steps

1. Chạy script để test tất cả APIs
2. Xem kết quả và fix các lỗi (nếu có)
3. Test với nhiều users khác nhau
4. Integrate vào CI/CD pipeline (nếu cần)

---

**Happy Testing! 🚀**

