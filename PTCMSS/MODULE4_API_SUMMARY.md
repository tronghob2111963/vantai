# 📋 TỔNG HỢP API MODULE 4: QUẢN LÝ BÁO GIÁ & ĐẶT CHUYẾN

## 🎯 TẤT CẢ API ENDPOINTS (10 endpoints)

### **1. Dashboard & Statistics**

#### `GET /api/bookings/dashboard`
- **Mô tả:** Lấy dashboard cho consultant
- **Query params:**
  - `branchId` (optional) - ID chi nhánh
- **Response:** `ConsultantDashboardResponse`
  - `pendingBookings` - Chờ báo giá
  - `sentQuotations` - Đã gửi báo giá (QUOTATION_SENT)
  - `confirmedBookings` - Đã xác nhận (CONFIRMED)
  - `monthlyRevenue` - Doanh số trong tháng
  - `conversionRate` - Tỷ lệ chuyển đổi
  - `monthlyStatistics` - Thống kê 3 tháng gần nhất
- **Roles:** `ADMIN`, `MANAGER`, `CONSULTANT`

---

### **2. Booking CRUD**

#### `POST /api/bookings`
- **Mô tả:** Tạo đơn hàng/báo giá mới
- **Request:** `CreateBookingRequest`
  - `customer` - Thông tin KH (auto-create nếu chưa có)
  - `branchId`, `hireTypeId`, `useHighway`
  - `trips` - Danh sách chuyến đi
  - `vehicles` - Danh sách loại xe
  - `distance` - Khoảng cách (km) để tính giá tự động
  - `estimatedCost`, `discountAmount`, `totalCost`, `depositAmount`
  - `status` - PENDING (mặc định)
  - `note`
- **Response:** `BookingResponse`
- **Roles:** `ADMIN`, `MANAGER`, `CONSULTANT`

#### `PUT /api/bookings/{id}`
- **Mô tả:** Cập nhật đơn hàng
- **Request:** `UpdateBookingRequest` (tương tự CreateBookingRequest)
- **Response:** `BookingResponse`
- **Lưu ý:** Chỉ cho phép khi status = PENDING hoặc CONFIRMED
- **Roles:** `ADMIN`, `MANAGER`, `CONSULTANT`

#### `GET /api/bookings/{id}`
- **Mô tả:** Lấy chi tiết đơn hàng
- **Response:** `BookingResponse`
  - Thông tin KH, lịch trình, giá cả
  - `trips` - Danh sách chuyến đi (có driver/vehicle nếu đã gán)
  - `vehicles` - Chi tiết loại xe
  - `paidAmount` - Tổng đã thanh toán (từ Invoices)
  - `remainingAmount` - Còn lại
- **Roles:** `ADMIN`, `MANAGER`, `CONSULTANT`, `ACCOUNTANT`

#### `GET /api/bookings`
- **Mô tả:** Lấy danh sách đơn hàng (với filter/search/pagination)
- **Query params:**
  - `status` - PENDING, QUOTATION_SENT, CONFIRMED, IN_PROGRESS, COMPLETED, CANCELLED
  - `branchId`, `consultantId`
  - `startDate`, `endDate` (ISO format)
  - `keyword` - Tìm theo mã đơn, SĐT, tên KH
  - `page` (default: 0) - Số trang
  - `size` (default: 20) - Số lượng/trang
  - `sortBy` - Sắp xếp (field:asc hoặc field:desc)
- **Response:** 
  - Có pagination: `PageResponse<BookingListResponse>`
  - Không pagination: `List<BookingListResponse>`
- **Roles:** `ADMIN`, `MANAGER`, `CONSULTANT`, `ACCOUNTANT`

#### `DELETE /api/bookings/{id}`
- **Mô tả:** Hủy đơn hàng (soft delete - chuyển status sang CANCELLED)
- **Response:** `ApiResponse<Void>`
- **Roles:** `ADMIN`, `MANAGER`, `CONSULTANT`

---

### **3. Pricing**

#### `POST /api/bookings/calculate-price`
- **Mô tả:** Tính giá tự động
- **Query params:**
  - `vehicleCategoryIds` - List<Integer>
  - `quantities` - List<Integer>
  - `distance` - Double (km)
  - `useHighway` - Boolean (default: false)
- **Response:** `BigDecimal` (giá ước tính)
- **Công thức:** `(baseFare + pricePerKm * distance + highwayFee + fixedCosts) * quantity`
- **Roles:** `ADMIN`, `MANAGER`, `CONSULTANT`

---

### **4. Payment & QR Code** 🆕

#### `POST /api/bookings/{id}/payment/qr`
- **Mô tả:** Tạo QR code thanh toán
- **Query params:**
  - `amount` (optional) - Số tiền (null = dùng depositAmount hoặc remainingAmount)
- **Response:** `QRCodeResponse`
  - `qrImageBase64` - QR code image (base64 PNG)
  - `bankAccount` - Thông tin tài khoản
  - `amount`, `currency`, `description`
  - `expiresAt` - Hết hạn sau 24h
- **Roles:** `ADMIN`, `MANAGER`, `CONSULTANT`, `ACCOUNTANT`

#### `POST /api/bookings/{id}/deposit`
- **Mô tả:** Ghi nhận tiền cọc/thanh toán
- **Request:** `CreateDepositRequest`
  - `amount` - Số tiền
  - `paymentMethod` - Phương thức thanh toán
  - `note` - Ghi chú
  - `referenceCode` - Mã tham chiếu giao dịch
- **Response:** `PaymentResponse`
- **Lưu ý:** 
  - Tự động tạo Invoice với type = INCOME
  - Auto-approve nếu là Accountant/Manager/Admin
  - Kiểm tra số tiền không vượt quá remainingAmount
- **Roles:** `ADMIN`, `MANAGER`, `ACCOUNTANT`

#### `GET /api/bookings/{id}/payments`
- **Mô tả:** Lấy lịch sử thanh toán
- **Response:** `List<PaymentResponse>`
  - Danh sách các Invoice với type = INCOME
  - Bao gồm: amount, paymentMethod, paymentStatus, isDeposit, note, dates, createdBy, approvedBy
- **Roles:** `ADMIN`, `MANAGER`, `CONSULTANT`, `ACCOUNTANT`

---

## 📊 STATUS FLOW

```
PENDING (Lưu nháp)
    ↓
QUOTATION_SENT (Đã gửi báo giá)
    ↓
CONFIRMED (Khách đồng ý)
    ↓
IN_PROGRESS (Đang thực hiện)
    ↓
COMPLETED (Hoàn thành)

CANCELLED (Hủy bỏ) - có thể ở bất kỳ giai đoạn nào
```

---

## 🔐 AUTHORIZATION SUMMARY

| Role | Dashboard | Create | Update | Delete | List | Detail | Calculate | QR Code | Deposit | History |
|------|-----------|--------|--------|--------|------|--------|-----------|---------|---------|---------|
| ADMIN | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| MANAGER | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| CONSULTANT | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| ACCOUNTANT | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ |

---

## 🧪 TESTING FLOW

### **1. Tạo đơn hàng mới:**
```
POST /api/bookings
→ Status: PENDING
```

### **2. Gửi báo giá:**
```
PUT /api/bookings/{id}
Body: { "status": "QUOTATION_SENT" }
→ Status: QUOTATION_SENT
```

### **3. Tạo QR code thanh toán:**
```
POST /api/bookings/{id}/payment/qr
→ Nhận QR code image
```

### **4. Khách đồng ý:**
```
PUT /api/bookings/{id}
Body: { "status": "CONFIRMED" }
→ Status: CONFIRMED
```

### **5. Ghi nhận tiền cọc:**
```
POST /api/bookings/{id}/deposit
Body: { "amount": 1500000, "paymentMethod": "BANK_TRANSFER", ... }
→ Tạo Invoice, cập nhật paidAmount
```

### **6. Xem lịch sử thanh toán:**
```
GET /api/bookings/{id}/payments
→ Danh sách các payments đã ghi nhận
```

### **7. Xem chi tiết đơn hàng:**
```
GET /api/bookings/{id}
→ Có paidAmount và remainingAmount tính từ Invoices
```

---

## ✅ HOÀN THIỆN 100%

Tất cả các API đã được implement đầy đủ với:
- ✅ Validation
- ✅ Error handling
- ✅ Authorization
- ✅ Swagger documentation
- ✅ Logging

**Sẵn sàng để test và sử dụng!**

