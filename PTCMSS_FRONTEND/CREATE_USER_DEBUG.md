# 🐛 Debug Create User Issue

## Vấn đề
API tạo user không được gọi, không thấy log ở backend.

## Các nguyên nhân có thể

### 1. **403 Forbidden - Không có quyền ADMIN**
Backend yêu cầu: `@PreAuthorize("hasRole('ADMIN')")`

**Kiểm tra:**
- Mở DevTools → Console
- Xem có log "Create user error" không
- Nếu có `status: 403` → Bạn đang login với role khác ADMIN

**Giải pháp:**
- Login lại với tài khoản Admin
- Hoặc sửa backend để cho phép MANAGER tạo user

### 2. **Request không được gửi**
**Kiểm tra:**
- Mở DevTools → Network tab
- Click nút "Lưu"
- Xem có request POST `/api/users/register` không
- Nếu không có → Validation đang block

**Giải pháp:**
- Check console log "Creating user with data"
- Nếu không thấy log này → Validation fail
- Điền đầy đủ tất cả trường bắt buộc

### 3. **CORS Issue**
**Kiểm tra:**
- Network tab có request màu đỏ
- Console có lỗi CORS

**Giải pháp:**
- Check backend CORS config
- Verify frontend đang gọi đúng URL

### 4. **Request body sai format**
**Kiểm tra:**
- Network tab → Request payload
- So sánh với backend `CreateUserRequest`

**Backend expects:**
```java
{
  "fullName": "string",
  "username": "string",
  "email": "string",
  "phone": "string",
  "address": "string",
  "roleId": number
}
```

## 🔍 Cách debug

### Bước 1: Mở DevTools
```
F12 hoặc Right-click → Inspect
```

### Bước 2: Vào tab Console
Khi click "Lưu", bạn sẽ thấy:
```
Creating user with data: { fullName: "...", ... }
```

Nếu không thấy → Validation fail, check lỗi trên UI

### Bước 3: Vào tab Network
Filter: `register`

Khi click "Lưu", bạn sẽ thấy:
```
POST /api/users/register
Status: 200 (success) hoặc 403 (forbidden) hoặc 400 (bad request)
```

### Bước 4: Click vào request
- **Headers tab**: Xem Authorization header có token không
- **Payload tab**: Xem data gửi đi có đúng không
- **Response tab**: Xem lỗi từ backend

## ✅ Test cases

### Test 1: Validation
1. Để trống tất cả fields
2. Click "Lưu"
3. **Expect**: Hiển thị lỗi "Vui lòng nhập họ tên"

### Test 2: Phone validation
1. Nhập phone: "123" (không đủ 10 số)
2. **Expect**: Hiển thị lỗi "Số điện thoại phải gồm 10 chữ số"

### Test 3: Email validation
1. Nhập email: "invalid"
2. **Expect**: Hiển thị lỗi "Email không đúng định dạng"

### Test 4: Create success
1. Điền đầy đủ thông tin hợp lệ
2. Click "Lưu"
3. **Expect**: 
   - Console log "Creating user with data"
   - Network có request POST
   - Hiển thị toast "Thành công!"
   - Chuyển về trang /admin/users

### Test 5: Duplicate username
1. Tạo user với username đã tồn tại
2. **Expect**: Hiển thị lỗi "Username đã được sử dụng"

## 🔧 Quick fixes

### Fix 1: Nếu 403 Forbidden
```javascript
// Sửa backend UserController.java
@PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")  // Cho phép cả Manager
```

### Fix 2: Nếu validation không hoạt động
```javascript
// Check console có log này không:
"Creating user with data: ..."

// Nếu không có → validation đang block
// Check tất cả fields đã điền chưa
```

### Fix 3: Nếu request không gửi
```javascript
// Check apiFetch trong http.js
// Verify Authorization header
```

## 📞 Cần hỗ trợ?

1. Chụp màn hình Console tab
2. Chụp màn hình Network tab (request detail)
3. Copy error message
4. Gửi cho dev team

## 🎯 Expected behavior

**Khi tạo user thành công:**
1. Console log: "Creating user with data"
2. Console log: "Create user response"
3. Network: POST /api/users/register → Status 200
4. UI: Toast màu xanh "Thành công!"
5. Redirect về /admin/users sau 1.5s

**Khi có lỗi:**
1. Console log: "Create user error"
2. UI: Alert box màu đỏ với message lỗi
3. Không redirect
4. User có thể sửa và thử lại
