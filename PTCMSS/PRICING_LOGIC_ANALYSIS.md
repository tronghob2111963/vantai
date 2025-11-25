# PHÂN TÍCH LOGIC BÁO GIÁ VẬN TẢI HÀNH KHÁCH

## 📋 TỔNG QUAN

Tài liệu này phân tích logic báo giá hiện tại của hệ thống và so sánh với yêu cầu nghiệp vụ được cung cấp.

---

## 🔍 PHÂN TÍCH LOGIC HIỆN TẠI

### 1. Cấu trúc dữ liệu hiện tại

**Bảng `vehicle_category_pricing`:**
- `baseFare`: Giá cơ bản (VND)
- `pricePerKm`: Giá mỗi km (VND/km)
- `highwayFee`: Phí cao tốc (VND)
- `fixedCosts`: Chi phí cố định (VND)

**Dữ liệu mẫu hiện tại:**
```
Xe 16 chỗ: baseFare=1,100,000đ, pricePerKm=18,000đ/km
Xe 29 chỗ: baseFare=1,800,000đ, pricePerKm=22,000đ/km
Xe 45 chỗ: baseFare=2,500,000đ, pricePerKm=28,000đ/km
```

### 2. Công thức tính giá hiện tại

**File:** `BookingServiceImpl.java` (dòng 477-504)

```java
Giá 1 xe = baseFare + (pricePerKm × distance) + highwayFee (nếu có) + fixedCosts
Tổng giá = Giá 1 xe × số lượng xe
```

**Ví dụ:**
- Xe 16 chỗ, 100km, có cao tốc:
  - = 1,100,000 + (18,000 × 100) + 120,000
  - = 1,100,000 + 1,800,000 + 120,000
  - = 3,020,000đ

---

## 📊 SO SÁNH VỚI YÊU CẦU NGHIỆP VỤ

### ✅ CÁC TÍNH NĂNG ĐÃ CÓ

1. ✅ **Giá cơ bản theo loại xe** - Có trong `baseFare`
2. ✅ **Giá theo km** - Có trong `pricePerKm`
3. ✅ **Phí cao tốc** - Có trong `highwayFee`
4. ✅ **Tính giá theo số lượng xe** - Đã implement

### ❌ CÁC TÍNH NĂNG THIẾU

#### 1. **Giá theo km theo yêu cầu**
- **Yêu cầu:**
  - Xe 16 chỗ: 30,000đ/km
  - Xe 30 chỗ: 40,000đ/km
  - Xe 45 chỗ: 50,000đ/km
- **Hiện tại:**
  - Xe 16 chỗ: 18,000đ/km ❌
  - Xe 29 chỗ: 22,000đ/km ❌
  - Xe 45 chỗ: 28,000đ/km ❌

#### 2. **Phụ phí ngày lễ/cuối tuần**
- **Yêu cầu:** Tăng 20-25% vào ngày lễ, cuối tuần
- **Hiện tại:** ❌ Chưa có

#### 3. **Hệ số đi 1 chiều vs 2 chiều**
- **Yêu cầu:**
  - Đi 2 chiều: hệ số = 1
  - Đi 1 chiều: hệ số = 2/3 (giá 1 chiều = 2/3 giá 2 chiều)
- **Hiện tại:** ❌ Chưa có

#### 4. **Phụ phí xe hạng sang**
- **Yêu cầu:** Xe cao cấp chênh lệch 1-2 triệu VNĐ so với xe bình thường
- **Hiện tại:** ❌ Chưa có field đánh dấu xe hạng sang

#### 5. **Phụ phí địa điểm phát sinh**
- **Yêu cầu:** Tăng giá nếu có thêm địa điểm đón/trả so với ban đầu
- **Hiện tại:** ❌ Chưa có

#### 6. **Cấu hình phụ phí lễ/cuối tuần trong SystemSettings**
- **Yêu cầu:** Có thể setup % phụ phí trong SystemSettings
- **Hiện tại:** ❌ Chưa có

#### 7. **Bảng giá theo loại thuê**
- **Yêu cầu:** Có các loại:
  - Trong ngày (HD-HN)
  - Thuê dài ngày (HD-HN)
  - Thuê một lượt (ngày thường, ngày lễ)
- **Hiện tại:** ❌ Chưa phân biệt loại thuê

---

## 📝 BẢNG BÁO GIÁ YÊU CẦU

### Bảng giá mẫu từ yêu cầu:

| STT | Loại xe | Trong ngày (HD-HN) | Thuê dài ngày (HD-HN) | Thuê một lượt |
|-----|---------|-------------------|---------------------|---------------|
|     |         |                   |                     | Ngày thường | Ngày lễ |
| 1   | 16      | 2,000,000đ        | 2,500,000đ          | 3,500,000đ | 4,000,000đ |
| 2   | 30      | 2,500,000đ        | 2.8-3tr             | 4,500,000đ | 5,000,000đ |
| 3   | 45      | 5,000,000đ        | 6,000,000đ          | -           | - |

**Lưu ý:** Giá đã bao gồm cao tốc. Với ngày lễ/cuối tuần tăng 20-25%.

---

## 🎯 CÔNG THỨC TỔNG QUÁT YÊU CẦU

### Công thức chính:
```
GIÁ THUÊ = TỔNG QUÃNG ĐƯỜNG × ĐƠN GIÁ THEO LOẠI XE × HỆ SỐ
```

**Trong đó:**
- **Đơn giá/km:**
  - Xe 16 chỗ: 30,000đ/km
  - Xe 30 chỗ: 40,000đ/km
  - Xe 45 chỗ: 50,000đ/km

- **Hệ số:**
  - Đi 2 chiều: 1.0
  - Đi 1 chiều: 2/3 = 0.6667

- **Phụ phí:**
  - Ngày lễ/cuối tuần: +20-25% (có thể config trong SystemSettings)
  - Xe hạng sang: +1,000,000đ đến 2,000,000đ
  - Địa điểm phát sinh: Tăng thêm tùy theo số điểm

### Ví dụ tính toán:

**Ví dụ 1: Xe 16 chỗ, 400km, 2 chiều, ngày thường**
```
Giá = 400km × 30,000đ/km × 1.0 = 12,000,000đ
```

**Ví dụ 2: Xe 16 chỗ, 400km, 1 chiều, ngày thường**
```
Giá = 400km × 30,000đ/km × 2/3 = 8,000,000đ
```

**Ví dụ 3: Xe 16 chỗ, 400km, 2 chiều, ngày lễ (+25%)**
```
Giá cơ bản = 400km × 30,000đ/km × 1.0 = 12,000,000đ
Phụ phí lễ = 12,000,000đ × 25% = 3,000,000đ
Tổng = 15,000,000đ
```

**Ví dụ 4: Xe 30 chỗ, 383km, 3 ngày 2 đêm, có cao tốc**
```
Giá cơ bản = 383km × 40,000đ/km × 1.0 = 15,320,000đ
Phụ phí cao tốc = 1,000,000đ (theo yêu cầu)
Tổng = 16,320,000đ (≈ 16,000,000đ như bảng)
```

---

## 🔧 ĐỀ XUẤT CẢI TIẾN

### 1. Cập nhật giá/km trong database

```sql
UPDATE vehicle_category_pricing 
SET pricePerKm = 30000 
WHERE seats = 16;

UPDATE vehicle_category_pricing 
SET pricePerKm = 40000 
WHERE seats = 30;

UPDATE vehicle_category_pricing 
SET pricePerKm = 50000 
WHERE seats = 45;
```

### 2. Thêm field mới vào bảng

**Bảng `vehicle_category_pricing`:**
- `isPremium` (boolean): Đánh dấu xe hạng sang
- `premiumSurcharge` (decimal): Phụ phí xe hạng sang (1-2 triệu)

**Bảng `bookings`:**
- `tripType` (enum): 'ONE_WAY', 'ROUND_TRIP', 'MULTI_DAY'
- `isHoliday` (boolean): Có phải ngày lễ không
- `isWeekend` (boolean): Có phải cuối tuần không
- `additionalPickupPoints` (int): Số điểm đón thêm
- `additionalDropoffPoints` (int): Số điểm trả thêm

**Bảng `system_settings`:**
- `HOLIDAY_SURCHARGE_RATE` (decimal): % phụ phí ngày lễ (0.20-0.25)
- `WEEKEND_SURCHARGE_RATE` (decimal): % phụ phí cuối tuần (0.20-0.25)
- `ONE_WAY_DISCOUNT_RATE` (decimal): Hệ số giảm 1 chiều (0.6667)

### 3. Cập nhật công thức tính giá

**File:** `BookingServiceImpl.java`

```java
public BigDecimal calculatePrice(List<Integer> vehicleCategoryIds, 
                                 List<Integer> quantities,
                                 Double distance,
                                 Boolean useHighway,
                                 String tripType,        // NEW
                                 Boolean isHoliday,      // NEW
                                 Boolean isWeekend,      // NEW
                                 Integer additionalPoints) { // NEW
    
    BigDecimal totalPrice = BigDecimal.ZERO;
    
    // Lấy cấu hình từ SystemSettings
    BigDecimal holidaySurchargeRate = getSystemSetting("HOLIDAY_SURCHARGE_RATE", 0.20);
    BigDecimal weekendSurchargeRate = getSystemSetting("WEEKEND_SURCHARGE_RATE", 0.20);
    BigDecimal oneWayDiscountRate = getSystemSetting("ONE_WAY_DISCOUNT_RATE", 0.6667);
    
    // Hệ số đi 1 chiều vs 2 chiều
    BigDecimal tripTypeMultiplier = "ONE_WAY".equals(tripType) 
        ? oneWayDiscountRate 
        : BigDecimal.ONE;
    
    // Hệ số phụ phí ngày lễ/cuối tuần
    BigDecimal surchargeRate = BigDecimal.ZERO;
    if (isHoliday) {
        surchargeRate = surchargeRate.add(holidaySurchargeRate);
    }
    if (isWeekend) {
        surchargeRate = surchargeRate.add(weekendSurchargeRate);
    }
    
    for (int i = 0; i < vehicleCategoryIds.size(); i++) {
        Integer categoryId = vehicleCategoryIds.get(i);
        Integer quantity = quantities.get(i);
        
        VehicleCategoryPricing category = vehicleCategoryRepository.findById(categoryId)
            .orElseThrow(() -> new RuntimeException("Vehicle category not found"));
        
        BigDecimal pricePerKm = category.getPricePerKm();
        BigDecimal highwayFee = category.getHighwayFee();
        
        // Giá cơ bản = distance × pricePerKm × hệ số loại chuyến
        BigDecimal basePrice = pricePerKm
            .multiply(BigDecimal.valueOf(distance))
            .multiply(tripTypeMultiplier);
        
        // Phụ phí cao tốc
        if (useHighway && highwayFee != null) {
            basePrice = basePrice.add(highwayFee);
        }
        
        // Phụ phí xe hạng sang
        if (category.getIsPremium() != null && category.getIsPremium()) {
            BigDecimal premiumSurcharge = category.getPremiumSurcharge() != null 
                ? category.getPremiumSurcharge() 
                : BigDecimal.valueOf(1000000);
            basePrice = basePrice.add(premiumSurcharge);
        }
        
        // Phụ phí ngày lễ/cuối tuần
        if (surchargeRate.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal surcharge = basePrice.multiply(surchargeRate);
            basePrice = basePrice.add(surcharge);
        }
        
        // Phụ phí địa điểm phát sinh (tăng 5-10% mỗi điểm)
        if (additionalPoints != null && additionalPoints > 0) {
            BigDecimal additionalPointFee = basePrice
                .multiply(BigDecimal.valueOf(0.05))
                .multiply(BigDecimal.valueOf(additionalPoints));
            basePrice = basePrice.add(additionalPointFee);
        }
        
        // Nhân với số lượng xe
        BigDecimal priceForThisCategory = basePrice.multiply(BigDecimal.valueOf(quantity));
        totalPrice = totalPrice.add(priceForThisCategory);
    }
    
    return totalPrice.setScale(2, RoundingMode.HALF_UP);
}
```

### 4. Cập nhật Frontend

**File:** `CreateOrderPage.jsx`

Cần thêm các field:
- `tripType`: Radio button (1 chiều / 2 chiều)
- `isHoliday`: Checkbox
- `isWeekend`: Checkbox (tự động detect từ ngày)
- `additionalPoints`: Input số điểm đón/trả thêm

---

## 📌 TÓM TẮT CẦN LÀM

### Backend:
1. ✅ Cập nhật giá/km trong database (30k, 40k, 50k)
2. ✅ Thêm field `isPremium`, `premiumSurcharge` vào `vehicle_category_pricing`
3. ✅ Thêm field `tripType`, `isHoliday`, `isWeekend`, `additionalPoints` vào `bookings`
4. ✅ Thêm SystemSettings cho phụ phí lễ/cuối tuần
5. ✅ Cập nhật logic `calculatePrice()` với công thức mới

### Frontend:
1. ✅ Cập nhật form tạo booking với các field mới
2. ✅ Tự động detect ngày lễ/cuối tuần
3. ✅ Hiển thị breakdown giá (giá cơ bản, phụ phí lễ, phụ phí xe sang, etc.)

### Database:
1. ✅ Migration script để thêm các field mới
2. ✅ Update dữ liệu mẫu với giá/km mới

---

## 🎯 KẾT LUẬN

**Logic hiện tại:** Đơn giản, chỉ tính baseFare + pricePerKm × distance + highwayFee

**Logic yêu cầu:** Phức tạp hơn, bao gồm:
- Hệ số 1 chiều/2 chiều
- Phụ phí ngày lễ/cuối tuần (20-25%)
- Phụ phí xe hạng sang
- Phụ phí địa điểm phát sinh
- Cấu hình linh hoạt trong SystemSettings

**Khuyến nghị:** Implement từng bước, test kỹ từng tính năng trước khi tích hợp.

