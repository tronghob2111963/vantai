# Tóm tắt thay đổi Theme và UX

## Backend Changes

### 1. API cập nhật profile mới
- **Endpoint**: `PATCH /api/users/{id}/profile`
- **Permission**: Chỉ user tự cập nhật profile của mình
- **Request Body**: `UpdateProfileRequest` (chỉ phone và address)
- **Files changed**:
  - `SetPasswordRequest.java` (mới)
  - `UpdateProfileRequest.java` (mới)
  - `AuthController.java` (thêm `/set-password`)
  - `UserController.java` (thêm `/profile`)
  - `AuthenticationService.java`
  - `AuthenticationServiceImpl.java`
  - `UserService.java`
  - `UserServiceImpl.java`

### 2. Flow set password mới
- User nhận email → Click link → Redirect đến `/set-password?token=xxx`
- User nhập mật khẩu → Backend lưu mật khẩu user nhập (KHÔNG random)
- Kích hoạt tài khoản → User đăng nhập

## Frontend Changes

### 1. Theme màu vàng #EDC531
- **File**: `tailwind.config.js`
- **Màu chính**: `brand-500: #EDC531`
- **Script**: `scripts/change-theme-to-yellow.ps1` để tự động thay đổi

### 2. Components mới
- **ScrollableModal**: Modal với scrollbar tự động
  - File: `src/components/common/ScrollableModal.jsx`
  - Tự động có scrollbar khi nội dung dài
  
- **Pagination**: Component phân trang
  - File: `src/components/common/Pagination.jsx`
  - Hiển thị info, first/last/prev/next buttons

### 3. UpdateProfilePage
- **Ẩn**: ID người dùng
- **Disabled**: Họ tên, email, role, status (chỉ xem)
- **Editable**: Phone, address, avatar
- **API**: Sử dụng `PATCH /api/users/{id}/profile`
- **Màu**: Đổi sang vàng #EDC531

### 4. API profile
- **File**: `src/api/profile.js`
- **Method**: `updateMyProfile()` dùng PATCH thay vì PUT
- **Endpoint**: `/api/users/{id}/profile`

## Checklist áp dụng

### Backend
- [x] Tạo `SetPasswordRequest.java`
- [x] Tạo `UpdateProfileRequest.java`
- [x] Thêm endpoint `/set-password` trong `AuthController`
- [x] Thêm endpoint `/profile` trong `UserController`
- [x] Sửa `verifyAccount()` - không tạo password random
- [x] Thêm `setPassword()` - lưu password user nhập
- [x] Thêm `updateProfile()` - chỉ cập nhật phone/address

### Frontend
- [x] Đổi màu theme trong `tailwind.config.js`
- [x] Tạo `ScrollableModal.jsx`
- [x] Tạo `Pagination.jsx`
- [x] Cập nhật `UpdateProfilePage.jsx`:
  - [x] Ẩn ID người dùng
  - [x] Disable fullName, email, role, status
  - [x] Chỉ cho phép sửa phone, address
  - [x] Đổi màu sang vàng
- [x] Cập nhật `profile.js` API - dùng PATCH
- [ ] Chạy script `change-theme-to-yellow.ps1`
- [ ] Áp dụng `ScrollableModal` cho tất cả popup
- [ ] Áp dụng `Pagination` cho tất cả danh sách

## Testing

### Backend
```bash
# Test set password
POST /api/auth/set-password
{
  "token": "verification-token",
  "password": "Password123",
  "confirmPassword": "Password123"
}

# Test update profile
PATCH /api/users/1/profile
{
  "phone": "0987654321",
  "address": "123 New Street"
}
```

### Frontend
1. Đăng nhập với bất kỳ role nào
2. Truy cập `/me/profile`
3. Kiểm tra:
   - Không hiển thị ID
   - Họ tên, email, role, status disabled
   - Có thể sửa phone và address
   - Màu vàng #EDC531
4. Cập nhật phone/address → Lưu thành công

## Notes
- Tất cả role đều có thể cập nhật phone/address của mình
- Admin vẫn có thể cập nhật tất cả thông tin user qua `PUT /api/users/{id}`
- Profile page không hiển thị ID để bảo mật
- Màu vàng #EDC531 là màu chính, hover dùng #D4AF1F
