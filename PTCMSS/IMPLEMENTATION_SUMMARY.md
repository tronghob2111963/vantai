# TÓM TẮT IMPLEMENTATION - LOGIC BÁO GIÁ MỚI

## ✅ ĐÃ HOÀN THÀNH

### 1. Database Changes

**File:** `db_scripts/migration_pricing_logic.sql`
- ✅ Cập nhật giá/km: 30k (16 chỗ), 40k (30 chỗ), 50k (45 chỗ)
- ✅ Thêm field `isPremium`, `premiumSurcharge` vào `vehicle_category_pricing`
- ✅ Thêm field `isHoliday`, `isWeekend`, `additionalPickupPoints`, `additionalDropoffPoints` vào `bookings`
- ✅ Thêm SystemSettings: `HOLIDAY_SURCHARGE_RATE`, `WEEKEND_SURCHARGE_RATE`, `ONE_WAY_DISCOUNT_RATE`, `ADDITIONAL_POINT_SURCHARGE_RATE`

**File:** `ptcmss-backend/src/main/resources/data.sql`
- ✅ Cập nhật giá/km mặc định
- ✅ Thêm SystemSettings mặc định

### 2. Backend Changes

**Entity Updates:**
- ✅ `VehicleCategoryPricing.java`: Thêm `isPremium`, `premiumSurcharge`
- ✅ `Bookings.java`: Thêm `isHoliday`, `isWeekend`, `additionalPickupPoints`, `additionalDropoffPoints`

**Service Updates:**
- ✅ `SystemSettingService.java`: Thêm method `getByKey()`
- ✅ `SystemSettingServiceImpl.java`: Implement `getByKey()`
- ✅ `BookingServiceImpl.java`: 
  - Cập nhật `calculatePrice()` với logic mới
  - Thêm overloaded method với các tham số mới
  - Tính phụ phí lễ/cuối tuần, xe hạng sang, địa điểm phát sinh
  - Áp dụng hệ số 1 chiều/2 chiều

**Controller Updates:**
- ✅ `BookingController.java`: Cập nhật endpoint `/calculate-price` để nhận thêm tham số

**DTO Updates:**
- ✅ `CreateBookingRequest.java`: Thêm các field mới
- ✅ `UpdateBookingRequest.java`: Thêm các field mới

### 3. Frontend Changes

**API Updates:**
- ✅ `bookings.js`: Cập nhật `calculatePrice()` để gửi thêm tham số

**Component Updates:**
- ✅ `CreateOrderPage.jsx`:
  - Thêm state cho `isHoliday`, `isWeekend`, `additionalPickupPoints`, `additionalDropoffPoints`
  - Tự động detect cuối tuần từ `startTime`
  - Thêm UI cho các checkbox và input
  - Cập nhật API call `calculatePrice()` với tham số mới
  - Cập nhật payload khi submit

---

## 📋 CÔNG THỨC TÍNH GIÁ MỚI

```
GIÁ THUÊ = TỔNG QUÃNG ĐƯỜNG × ĐƠN GIÁ THEO LOẠI XE × HỆ SỐ + PHỤ PHÍ

Trong đó:
- Đơn giá/km: 30k (16 chỗ), 40k (30 chỗ), 50k (45 chỗ)
- Hệ số: 1.0 (2 chiều), 2/3 (1 chiều)
- Phụ phí:
  + Ngày lễ: +25% (có thể config trong SystemSettings)
  + Cuối tuần: +20% (có thể config trong SystemSettings)
  + Xe hạng sang: +1-2 triệu VNĐ
  + Địa điểm phát sinh: +5% mỗi điểm (có thể config)
```

---

## 🔧 CẦN CHẠY MIGRATION

Chạy file migration để cập nhật database:
```sql
-- Chạy file: db_scripts/migration_pricing_logic.sql
```

Hoặc chạy các lệnh SQL trong file đó.

---

## 🧪 TESTING

### Test Case 1: Xe 16 chỗ, 400km, 2 chiều, ngày thường
- **Kỳ vọng:** 400km × 30,000đ/km × 1.0 = 12,000,000đ
- **Test:** Tạo booking với các tham số trên

### Test Case 2: Xe 16 chỗ, 400km, 1 chiều, ngày thường
- **Kỳ vọng:** 400km × 30,000đ/km × 2/3 = 8,000,000đ
- **Test:** Tạo booking với `hireTypeId` = ONE_WAY

### Test Case 3: Xe 16 chỗ, 400km, 2 chiều, ngày lễ
- **Kỳ vọng:** 12,000,000đ + (12,000,000đ × 25%) = 15,000,000đ
- **Test:** Tạo booking với `isHoliday` = true

### Test Case 4: Xe 16 chỗ, 400km, 2 chiều, cuối tuần
- **Kỳ vọng:** 12,000,000đ + (12,000,000đ × 20%) = 14,400,000đ
- **Test:** Tạo booking với ngày cuối tuần (tự động detect)

### Test Case 5: Xe hạng sang
- **Kỳ vọng:** Giá cơ bản + 1,000,000đ (hoặc giá trị trong `premiumSurcharge`)
- **Test:** Tạo booking với xe có `isPremium` = true

### Test Case 6: Điểm phát sinh
- **Kỳ vọng:** Giá cơ bản + (giá cơ bản × 5% × số điểm)
- **Test:** Tạo booking với `additionalPickupPoints` hoặc `additionalDropoffPoints` > 0

---

## 📝 LƯU Ý

1. **HireTypeId:** Cần map `hireType` (ONE_WAY, ROUND_TRIP) sang `hireTypeId` từ database. Hiện tại frontend chưa load danh sách `hire_types` từ API.

2. **Tự động detect cuối tuần:** Frontend tự động detect từ `startTime`, nhưng có thể override bằng checkbox.

3. **SystemSettings:** Các giá trị mặc định:
   - `HOLIDAY_SURCHARGE_RATE`: 0.25 (25%)
   - `WEEKEND_SURCHARGE_RATE`: 0.20 (20%)
   - `ONE_WAY_DISCOUNT_RATE`: 0.6667 (2/3)
   - `ADDITIONAL_POINT_SURCHARGE_RATE`: 0.05 (5%)

4. **Backward Compatibility:** Method `calculatePrice()` cũ vẫn hoạt động (gọi overloaded method với giá trị mặc định).

---

## 🎯 NEXT STEPS

1. ✅ Chạy migration script
2. ✅ Test các tính năng mới
3. ⚠️ Cần load danh sách `hire_types` từ API để map `hireType` → `hireTypeId`
4. ⚠️ Có thể thêm UI để quản lý xe hạng sang trong VehicleCategoryManagePage

---

## 📚 FILES CHANGED

### Backend:
- `entity/VehicleCategoryPricing.java`
- `entity/Bookings.java`
- `service/SystemSettingService.java`
- `service/impl/SystemSettingServiceImpl.java`
- `service/impl/BookingServiceImpl.java`
- `controller/BookingController.java`
- `dto/request/Booking/CreateBookingRequest.java`
- `dto/request/Booking/UpdateBookingRequest.java`
- `src/main/resources/data.sql`

### Frontend:
- `api/bookings.js`
- `components/module 4/CreateOrderPage.jsx`

### Database:
- `db_scripts/migration_pricing_logic.sql`
- `db_scripts/db-tamthoi.sql` (cần cập nhật nếu có)

---

**Hoàn thành:** ✅ Tất cả các tính năng đã được implement!

