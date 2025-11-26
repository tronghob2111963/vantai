# Sửa lỗi cập nhật thông tin và thiết lập mật khẩu

## Vấn đề

1. **Hạn chế cập nhật thông tin**: Người dùng chỉ được phép cập nhật số điện thoại, địa chỉ và avatar của chính họ
2. **Lỗi lưu mật khẩu**: Khi người dùng tự setup mật khẩu sau khi tạo tài khoản, hệ thống lại lưu mật khẩu random thay vì mật khẩu người dùng nhập

## Giải pháp

### 1. Tạo DTO mới

#### SetPasswordRequest.java
- Cho phép người dùng tự thiết lập mật khẩu sau khi xác thực email
- Validation: mật khẩu phải có ít nhất 6 ký tự, chứa chữ hoa, chữ thường và số
- Kiểm tra password và confirmPassword phải khớp

#### UpdateProfileRequest.java
- Chỉ cho phép user cập nhật phone và address
- Avatar được upload riêng qua endpoint `/users/{id}/avatar`

### 2. Thay đổi API

#### AuthController
**Thêm endpoint mới:**
- `POST /api/auth/set-password`: Cho phép người dùng tự thiết lập mật khẩu

#### UserController
**Thay đổi:**
- `PUT /users/{id}`: Chỉ Admin mới được cập nhật thông tin user (đã thay đổi từ `hasRole('ADMIN') or #id == authentication.principal.id` thành `hasRole('ADMIN')`)

**Thêm endpoint mới:**
- `PATCH /users/{id}/profile`: Cho phép user tự cập nhật phone và address của mình

### 3. Thay đổi Service

#### AuthenticationService & AuthenticationServiceImpl

**Thay đổi `verifyAccount()`:**
- Trước: Tự động tạo mật khẩu random và gửi email
- Sau: Chỉ xác thực email, chuyển hướng đến trang set password
- URL redirect: `http://localhost:5173/set-password?token={token}`

**Thêm method `setPassword()`:**
- Nhận token và password từ người dùng
- Lưu mật khẩu người dùng nhập vào (KHÔNG phải mật khẩu random)
- Kích hoạt tài khoản (status = ACTIVE)
- Xóa verification token sau khi sử dụng

**Xóa các method không cần thiết:**
- `generateRandomPassword()`
- `sendPasswordEmail()`
- `buildPasswordEmailHtml()`

#### UserService & UserServiceImpl

**Thay đổi `updateUser()`:**
- Chỉ Admin mới được gọi (đã check ở Controller)
- Admin có thể cập nhật tất cả thông tin user

**Thêm method `updateProfile()`:**
- Chỉ cho phép user tự cập nhật phone và address
- Validation: kiểm tra phone không trùng với user khác

### 4. Flow mới

#### Tạo tài khoản mới:
1. Admin tạo user → User nhận email xác thực
2. User click link trong email → Backend verify email → Redirect đến trang set password
3. User nhập mật khẩu → Backend lưu mật khẩu → Kích hoạt tài khoản
4. User đăng nhập với mật khẩu đã thiết lập

#### Cập nhật thông tin:
1. **Admin**: Có thể cập nhật tất cả thông tin user qua `PUT /users/{id}`
2. **User**: Chỉ có thể cập nhật phone và address qua `PATCH /users/{id}/profile`
3. **Avatar**: Cả Admin và User đều có thể upload avatar qua `POST /users/{id}/avatar`

## Files đã thay đổi

1. **Tạo mới:**
   - `SetPasswordRequest.java`
   - `UpdateProfileRequest.java`

2. **Cập nhật:**
   - `AuthController.java`: Thêm endpoint `/set-password`
   - `UserController.java`: Thay đổi permission và thêm endpoint `/profile`
   - `AuthenticationService.java`: Thêm method `setPassword()`
   - `AuthenticationServiceImpl.java`: Sửa `verifyAccount()`, thêm `setPassword()`, xóa các method không cần
   - `UserService.java`: Thêm method `updateProfile()`
   - `UserServiceImpl.java`: Sửa `updateUser()`, thêm `updateProfile()`

## Testing

### Test set password:
```bash
# 1. Tạo user mới (Admin)
POST /api/users/register

# 2. Click link trong email → Redirect đến frontend
GET /api/auth/verify?token={token}

# 3. User nhập mật khẩu
POST /api/auth/set-password
{
  "token": "verification-token",
  "password": "Password123",
  "confirmPassword": "Password123"
}

# 4. Đăng nhập
POST /api/auth/login
{
  "username": "username",
  "password": "Password123"
}
```

### Test update profile:
```bash
# User tự cập nhật phone và address
PATCH /api/users/{id}/profile
{
  "phone": "0987654321",
  "address": "123 New Street"
}
```

## Lưu ý

- Frontend cần tạo trang `/set-password` để nhận token và cho phép user nhập mật khẩu
- Endpoint `/set-password` không cần authentication (public)
- Token chỉ sử dụng được 1 lần, sau khi set password thành công sẽ bị xóa
