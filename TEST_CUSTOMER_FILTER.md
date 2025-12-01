# Test Customer Filter cho Manager

## Các bước test

### 1. Kiểm tra console log trong browser
1. Mở Developer Tools (F12)
2. Vào tab Console
3. Đăng nhập với tài khoản Manager
4. Vào trang "Danh sách khách hàng"
5. Kiểm tra log:
   - `[CustomerListPage] Fetching customers with:` - Xem userId có được gửi không
   - `[customers.js] API call params:` - Xem URL có chứa userId không

### 2. Kiểm tra backend log
1. Mở terminal backend
2. Tìm log:
   - `[CustomerService] List customers` - Xem userId có được nhận không
   - `[CustomerService] Checking user role for userId=` - Xem có check role không
   - `[CustomerService] Found employee:` - Xem có tìm thấy employee không
   - `[CustomerService] User role:` - Xem role có đúng là MANAGER không
   - `[CustomerService] Manager detected - auto filtering by branchId=` - Xem có filter theo branchId không

### 3. Các vấn đề có thể gặp

#### Vấn đề 1: userId không được gửi
**Triệu chứng:** Log `[CustomerListPage]` không có userId hoặc userId = undefined
**Nguyên nhân:** localStorage không có userId
**Giải pháp:** 
- Kiểm tra localStorage trong DevTools > Application > Local Storage
- Đăng xuất và đăng nhập lại
- Kiểm tra API login có trả về userId không

#### Vấn đề 2: Backend không nhận được userId
**Triệu chứng:** Log backend không có `[CustomerService] Checking user role`
**Nguyên nhân:** userId không được gửi trong request hoặc bị null
**Giải pháp:**
- Kiểm tra Network tab trong DevTools
- Xem request URL có chứa `userId=xxx` không
- Kiểm tra backend controller có nhận được param không

#### Vấn đề 3: Không tìm thấy employee
**Triệu chứng:** Log `[CustomerService] No employee found for userId=`
**Nguyên nhân:** 
- userId không tồn tại trong database
- Quan hệ User-Employee chưa được thiết lập đúng
**Giải pháp:**
- Kiểm tra database: `SELECT * FROM employees WHERE user_id = ?`
- Kiểm tra EmployeeRepository.findByUserId()

#### Vấn đề 4: Role không đúng
**Triệu chứng:** Log `[CustomerService] User role: CONSULTANT` (không phải MANAGER)
**Nguyên nhân:** User không có role MANAGER
**Giải pháp:**
- Kiểm tra database: `SELECT role FROM users WHERE id = ?`
- Đảm bảo đăng nhập với tài khoản Manager

#### Vấn đề 5: Branch null
**Triệu chứng:** Log `[CustomerService] Found employee: id=X, branchId=null`
**Nguyên nhân:** Employee không được gán chi nhánh
**Giải pháp:**
- Kiểm tra database: `SELECT branch_id FROM employees WHERE id = ?`
- Gán chi nhánh cho employee

### 4. Test case thành công

**Expected logs:**
```
Frontend:
[CustomerListPage] Fetching customers with: { userId: "123", isManager: true, currentRole: "MANAGER", ... }
[customers.js] API call params: { userId: "123", url: "/api/customers?userId=123&page=0&size=10" }

Backend:
[CustomerService] List customers - keyword=null, branchId=null, userId=123, from=null, to=null, page=0, size=10
[CustomerService] Checking user role for userId=123
[CustomerService] Found employee: id=456, branchId=1
[CustomerService] User role: MANAGER
[CustomerService] Manager detected - auto filtering by branchId=1
```

**Expected result:**
- Chỉ hiển thị khách hàng có `branchId = 1` (chi nhánh của manager)
- Dropdown "Chi nhánh" bị ẩn
- Header hiển thị tên chi nhánh

### 5. Rebuild và restart

Nếu đã sửa code backend, cần rebuild:
```bash
cd vantai/PTCMSS/ptcmss-backend
mvn clean install -DskipTests
```

Restart backend service.

Frontend không cần rebuild, chỉ cần refresh browser.
