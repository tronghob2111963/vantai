# Admin QR Payment Settings Feature

## Tổng quan
Cho phép Admin cập nhật thông tin tài khoản ngân hàng cho thanh toán QR thông qua giao diện web, thay vì phải chỉnh sửa file cấu hình hoặc biến môi trường.

## Các trường có thể điều chỉnh

Admin chỉ có thể điều chỉnh **4 trường an toàn**:

1. **Mã ngân hàng** (`bankCode`)
   - Mã ngân hàng theo chuẩn VietQR
   - Ví dụ: `970403` (Sacombank), `970422` (MB Bank)
   - Validation: 6-10 ký tự số

2. **Số tài khoản** (`accountNumber`)
   - Số tài khoản ngân hàng nhận thanh toán
   - Validation: 8-20 ký tự số

3. **Tên tài khoản** (`accountName`)
   - Tên chủ tài khoản hiển thị trên mã QR
   - Tự động chuyển sang chữ hoa
   - Validation: 3-100 ký tự

4. **Mã mô tả** (`descriptionPrefix`)
   - Tiền tố cho nội dung chuyển khoản
   - Ví dụ: `PTCMSS` → nội dung chuyển khoản: `PTCMSS-123`
   - Validation: tối đa 20 ký tự

## Bảo mật

### Thông tin KHÔNG thể điều chỉnh qua UI
- `VIETQR_CLIENT_ID`: vẫn lưu trong biến môi trường
- `VIETQR_API_KEY`: vẫn lưu trong biến môi trường
- `provider-url`: cố định trong `application.yml`
- `template`: cố định trong `application.yml`
- `expires-in-minutes`: cố định trong `application.yml`

### Phân quyền
- Chỉ role **ADMIN** có quyền truy cập `/admin/payment-settings`
- Backend API `/api/admin/settings/qr` có annotation `@PreAuthorize("hasRole('ADMIN')")`

## Kiến trúc hệ thống

### Backend (Spring Boot)

#### 1. Database Schema
```sql
CREATE TABLE app_settings (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) NOT NULL UNIQUE,
  setting_value TEXT,
  description VARCHAR(500),
  updated_at TIMESTAMP,
  updated_by VARCHAR(100)
);
```

#### 2. Entities & Repositories
- **Entity**: `AppSetting.java`
- **Repository**: `AppSettingRepository.java`

#### 3. Service Layer
- **Service**: `AppSettingService.java`
  - Cache với TTL 60s (`@Cacheable`)
  - Fallback sang `QrPaymentProperties` nếu DB không có giá trị
  - Bulk update với cache eviction
  
#### 4. API Endpoints

**GET /api/admin/settings/qr**
- Lấy cấu hình QR hiện tại
- Response:
```json
{
  "data": {
    "bankCode": "970403",
    "accountNumber": "070122047995",
    "accountName": "NGUYEN VAN THUAN",
    "descriptionPrefix": "PTCMSS",
    "updatedAt": "2025-12-01T10:30:00Z",
    "updatedBy": "admin",
    "source": "database"
  }
}
```

**PUT /api/admin/settings/qr**
- Cập nhật cấu hình QR
- Request body:
```json
{
  "bankCode": "970403",
  "accountNumber": "070122047995",
  "accountName": "NGUYEN VAN THUAN",
  "descriptionPrefix": "PTCMSS"
}
```
- Validation:
  - `bankCode`: 6-10 ký tự số, required
  - `accountNumber`: 8-20 ký tự số, required
  - `accountName`: 3-100 ký tự, required
  - `descriptionPrefix`: tối đa 20 ký tự, optional

#### 5. Integration với QR Generation
- **File**: `PaymentServiceImpl.java`
- **Method**: `generateQRCode()`, `buildQrText()`, `buildQrImageUrl()`
- Đọc giá trị từ `AppSettingService.getValue()` thay vì trực tiếp từ `QrPaymentProperties`
- Fallback tự động sang `application.yml` nếu DB không có giá trị

### Frontend (React)

#### 1. API Client
- **File**: `src/api/settings.js`
- Functions:
  - `getQrSettings()`: GET current settings
  - `updateQrSettings(settings)`: PUT update settings

#### 2. Admin UI Component
- **File**: `src/components/common/QrPaymentSettings.jsx` (reusable component)
- **Integrated into**: `src/components/module 1/SystemSettingsPage.jsx`
- Features:
  - Form với validation client-side
  - Real-time preview
  - Loading/saving states
  - Success/error messages
  - Metadata display (source, last updated)
  - Auto-uppercase cho `accountName`
  - Disable submit nếu không có thay đổi

#### 3. Navigation & Routing
- **Location**: Tích hợp vào trang "Cấu hình hệ thống" (`/admin/settings`)
- **Component**: `QrPaymentSettings` được render dưới phần system settings table
- **Access**: Chỉ Admin role có thể truy cập trang này

## Luồng hoạt động

### 1. Admin cập nhật cấu hình
1. Admin đăng nhập và vào menu "Cấu hình thanh toán QR"
2. Form load giá trị hiện tại từ API
3. Admin chỉnh sửa các trường (STK, tên TK, mã NH, mã mô tả)
4. Click "Lưu cấu hình"
5. Frontend gửi PUT request → Backend validate → Save DB → Clear cache
6. Hiển thị thông báo thành công

### 2. Tạo mã QR thanh toán
1. Tư vấn viên/Kế toán tạo yêu cầu thanh toán QR cho đơn hàng
2. Backend gọi `PaymentServiceImpl.generateQRCode()`
3. Service đọc giá trị từ `AppSettingService`:
   - `getValue(QR_BANK_CODE)` → check cache → check DB → fallback properties
   - `getValue(QR_ACCOUNT_NUMBER)` → ...
   - `getValue(QR_ACCOUNT_NAME)` → ...
   - `getValue(QR_DESCRIPTION_PREFIX)` → ...
4. Build QR image URL với giá trị mới
5. Trả về `PaymentResponse` với `qrImageUrl` và `qrText`

### 3. Cache & Performance
- **Cache hit**: Giá trị được lấy từ memory (~0ms)
- **Cache miss**: Query DB (~10-50ms) → cache result
- **Cache eviction**: Khi admin update settings → clear cache → force reload

## Testing

### Test Case 1: Load Current Settings
1. Login với admin account
2. Vào `/admin/payment-settings`
3. **Expected**: Form hiển thị giá trị hiện tại (từ DB hoặc config)

### Test Case 2: Update Settings
1. Login admin → vào payment settings
2. Thay đổi STK: `070122047995` → `123456789012`
3. Thay đổi tên: `NGUYEN VAN THUAN` → `TRAN THI B`
4. Click "Lưu cấu hình"
5. **Expected**: Success message, form reset với giá trị mới

### Test Case 3: Validation
1. Login admin → vào payment settings
2. Nhập STK: `123` (< 8 ký tự)
3. Click "Lưu cấu hình"
4. **Expected**: Error message "Số tài khoản phải có ít nhất 8 ký tự"

### Test Case 4: QR Generation Uses New Settings
1. Admin cập nhật STK thành `999888777666`
2. Tư vấn viên tạo QR thanh toán cho đơn #123
3. **Expected**: 
   - QR image URL chứa `999888777666`
   - `qrText` chứa `999888777666`

### Test Case 5: Fallback to Config
1. Xóa toàn bộ records trong `app_settings`
2. Tạo QR thanh toán
3. **Expected**: Hệ thống vẫn hoạt động, sử dụng giá trị từ `application.yml`

### Test Case 6: Unauthorized Access
1. Login với role CONSULTANT
2. Try vào `/admin/payment-settings`
3. **Expected**: Redirect hoặc 403 Forbidden

## Rollback & Migration

### Rollback về config file
Nếu cần rollback:
1. Xóa records trong bảng `app_settings` với key bắt đầu bằng `qr.`
```sql
DELETE FROM app_settings WHERE setting_key LIKE 'qr.%';
```
2. Restart backend → hệ thống tự động fallback sang `application.yml`

### Migration từ config sang DB
Để import giá trị hiện tại từ config vào DB:
1. Admin vào `/admin/payment-settings`
2. Form sẽ hiển thị giá trị từ `application.yml` (fallback)
3. Click "Lưu cấu hình" → giá trị được lưu vào DB
4. Từ lần sau, hệ thống ưu tiên đọc từ DB

## Lưu ý kỹ thuật

### Cache Strategy
- Cache name: `appSettings`
- TTL: không giới hạn (manual eviction)
- Eviction: khi update settings → `@CacheEvict(allEntries = true)`
- Cache key: `setting_key` (ví dụ: `"qr.bank_code"`)

### Validation Rules
| Field | Min | Max | Pattern | Required |
|-------|-----|-----|---------|----------|
| bankCode | 6 | 10 | `[0-9]+` | Yes |
| accountNumber | 8 | 20 | `[0-9]+` | Yes |
| accountName | 3 | 100 | any | Yes |
| descriptionPrefix | - | 20 | any | No (default: "PTCMSS") |

### Database Indexes
```sql
CREATE UNIQUE INDEX idx_setting_key ON app_settings(setting_key);
```

### Environment Variables (vẫn cần thiết)
```env
# Bắt buộc - không thể điều chỉnh qua UI
VIETQR_CLIENT_ID=your_client_id
VIETQR_API_KEY=your_api_key

# Optional - có thể điều chỉnh qua UI
PAYMENT_BANK_CODE=970403
PAYMENT_BANK_ACCOUNT_NUMBER=070122047995
PAYMENT_BANK_ACCOUNT_NAME=NGUYEN VAN THUAN
```

## Troubleshooting

### Vấn đề: Không thể load settings
**Triệu chứng**: Spinner quay mãi, không load được form  
**Nguyên nhân**: API endpoint không khả dụng hoặc role không đúng  
**Giải pháp**:
1. Check console log
2. Verify admin role: `localStorage.getItem("roleName")`
3. Test API: `GET http://localhost:8080/api/admin/settings/qr` với Bearer token

### Vấn đề: Update thành công nhưng QR vẫn dùng giá trị cũ
**Triệu chứng**: Admin đã update STK nhưng QR vẫn hiển thị STK cũ  
**Nguyên nhân**: Cache chưa được clear  
**Giải pháp**:
1. Restart backend để clear cache
2. Hoặc đợi ~60s để cache tự hết hạn (nếu có TTL)
3. Check database xem giá trị đã update chưa:
```sql
SELECT * FROM app_settings WHERE setting_key LIKE 'qr.%';
```

### Vấn đề: Validation error không rõ ràng
**Triệu chứng**: Backend trả về 400 Bad Request  
**Nguyên nhân**: DTO validation fail  
**Giải pháp**:
1. Check request body format
2. Verify validation constraints:
   - `bankCode`: must be numeric, 6-10 digits
   - `accountNumber`: must be numeric, 8-20 digits
   - `accountName`: min 3 chars

## Tài liệu tham khảo
- [VietQR API Documentation](https://www.vietqr.io/danh-sach-api/link-tao-ma-nhanh/api-tao-ma-qr/)
- [Spring Boot Caching](https://spring.io/guides/gs/caching/)
- [React Form Validation](https://react.dev/learn/managing-state)
