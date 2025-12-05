# Công Thức Tính Giá Booking Hiện Tại

## Tổng Quan

Công thức tính giá được thực hiện trong `BookingServiceImpl.calculatePrice()` với các tham số:
- `vehicleCategoryIds`: Danh sách ID loại xe
- `quantities`: Số lượng từng loại xe
- `distance`: Quãng đường (km)
- `useHighway`: Có dùng cao tốc không
- `hireTypeId`: ID hình thức thuê (ONE_WAY, ROUND_TRIP, DAILY, MULTI_DAY)
- `isHoliday`: Có phải ngày lễ không
- `isWeekend`: Có phải cuối tuần không
- `startTime`, `endTime`: Thời gian bắt đầu và kết thúc

## Các Hệ Số Cấu Hình (SystemSettings)

- `HOLIDAY_SURCHARGE_RATE`: 0.25 (25% phụ phí ngày lễ)
- `WEEKEND_SURCHARGE_RATE`: 0.20 (20% phụ phí cuối tuần)
- `ROUND_TRIP_MULTIPLIER`: 1.5 (Hệ số nhân cho khứ hồi cùng ngày)
- `INTER_PROVINCE_DISTANCE_KM`: 100 (Ngưỡng khoảng cách liên tỉnh)

## Công Thức Tính Giá Theo Hình Thức Thuê

### 1. THUÊ THEO NGÀY (DAILY)

**Công thức:**
```
basePrice = sameDayFixedPrice × số_ngày + baseFee
```

**Ví dụ:**
- sameDayFixedPrice = 2,000,000 VNĐ/ngày
- số_ngày = 3
- baseFee = 500,000 VNĐ
- → basePrice = 2,000,000 × 3 + 500,000 = 6,500,000 VNĐ

**Lưu ý:** Không tính theo km, chỉ tính theo số ngày.

---

### 2. THUÊ NHIỀU NGÀY (MULTI_DAY)

**Công thức:**
```
basePrice = (km × PricePerKm × 1.5) + (sameDayFixedPrice × số_ngày) + baseFee
```

**Ví dụ:**
- km = 200
- PricePerKm = 10,000 VNĐ/km
- số_ngày = 3
- sameDayFixedPrice = 2,000,000 VNĐ/ngày
- baseFee = 500,000 VNĐ
- → basePrice = (200 × 10,000 × 1.5) + (2,000,000 × 3) + 500,000
- → basePrice = 3,000,000 + 6,000,000 + 500,000 = 9,500,000 VNĐ

---

### 3. MỘT CHIỀU (ONE_WAY)

**Công thức:**
```
basePrice = (km × PricePerKm) + baseFee
```

**Ví dụ:**
- km = 100
- PricePerKm = 10,000 VNĐ/km
- baseFee = 500,000 VNĐ
- → basePrice = (100 × 10,000) + 500,000 = 1,500,000 VNĐ

---

### 4. KHỨ HỒI (ROUND_TRIP)

**Công thức:**
- **Cùng ngày:** `basePrice = (km × PricePerKm × 1.5) + baseFee`
- **Khác ngày:** `basePrice = (km × PricePerKm × 2.0) + baseFee`

**Ví dụ (cùng ngày):**
- km = 100
- PricePerKm = 10,000 VNĐ/km
- baseFee = 500,000 VNĐ
- → basePrice = (100 × 10,000 × 1.5) + 500,000 = 2,000,000 VNĐ

**Ví dụ (khác ngày):**
- km = 100
- PricePerKm = 10,000 VNĐ/km
- baseFee = 500,000 VNĐ
- → basePrice = (100 × 10,000 × 2.0) + 500,000 = 2,500,000 VNĐ

---

### 5. CHUYẾN TRONG NGÀY (Không có hireType cụ thể)

**a. Liên tỉnh (distance > 100km):**
```
basePrice = (km × PricePerKm × 1.5) + sameDayFixedPrice + baseFee
```

**b. Trong tỉnh / nội thành (distance ≤ 100km):**
```
basePrice = sameDayFixedPrice + baseFee
```

---

### 6. MẶC ĐỊNH (Không xác định được hình thức thuê)

**Công thức:**
```
basePrice = (km × PricePerKm × 1.5) + baseFee
```

---

## Phụ Phí Bổ Sung

Sau khi tính `basePrice`, hệ thống sẽ cộng thêm các phụ phí sau:

### 1. Phụ Phí Cao Tốc (Highway Fee)
```
if (useHighway == true) {
    basePrice = basePrice + highwayFee
}
```

### 2. Phụ Phí Xe Hạng Sang (Premium Surcharge)
```
if (category.isPremium == true) {
    basePrice = basePrice + premiumSurcharge  // Mặc định: 1,000,000 VNĐ
}
```

### 3. Phụ Phí Ngày Lễ / Cuối Tuần
```
surchargeRate = 0
if (isHoliday == true) {
    surchargeRate = surchargeRate + 0.25  // +25%
}
if (isWeekend == true) {
    surchargeRate = surchargeRate + 0.20  // +20%
}

if (surchargeRate > 0) {
    surcharge = basePrice × surchargeRate
    basePrice = basePrice + surcharge
}
```

**Lưu ý:** Phụ phí ngày lễ và cuối tuần có thể cộng dồn (nếu cả hai đều true thì +45%).

---

## Tính Tổng Giá

Sau khi tính `basePrice` cho từng loại xe (đã bao gồm tất cả phụ phí):

```
priceForThisCategory = basePrice × quantity
totalPrice = tổng của tất cả priceForThisCategory
```

**Ví dụ:**
- Xe 9 chỗ: basePrice = 2,000,000 VNĐ, quantity = 2 → 4,000,000 VNĐ
- Xe 29 chỗ: basePrice = 5,000,000 VNĐ, quantity = 1 → 5,000,000 VNĐ
- → totalPrice = 4,000,000 + 5,000,000 = 9,000,000 VNĐ

---

## So Sánh Giá: DAILY vs ROUND_TRIP

### Ví dụ: Chuyến 100km, 1 ngày

**DAILY:**
```
basePrice = sameDayFixedPrice × 1 + baseFee
         = 2,000,000 + 500,000
         = 2,500,000 VNĐ
```

**ROUND_TRIP (cùng ngày):**
```
basePrice = (km × PricePerKm × 1.5) + baseFee
         = (100 × 10,000 × 1.5) + 500,000
         = 1,500,000 + 500,000
         = 2,000,000 VNĐ
```

**Kết luận:** Với cùng khoảng cách và thời gian, **DAILY đắt hơn ROUND_TRIP** nếu `sameDayFixedPrice` lớn hơn `(km × PricePerKm × 1.5)`.

**Vấn đề:** Người dùng báo ROUND_TRIP đắt gấp đôi DAILY, có thể do:
1. `sameDayFixedPrice` được set quá thấp
2. Logic tính ROUND_TRIP đang nhân 2 lần (có thể do backend tự động nhân thêm)
3. Cần kiểm tra lại giá trị `sameDayFixedPrice` và `PricePerKm` trong database

---

## Các Tham Số Từ VehicleCategory

Mỗi loại xe có các tham số sau:
- `pricePerKm`: Giá/km
- `baseFare`: Phí cơ bản
- `highwayFee`: Phí cao tốc
- `sameDayFixedPrice`: Giá cố định cho chuyến trong ngày
- `isPremium`: Có phải xe hạng sang không
- `premiumSurcharge`: Phụ phí xe hạng sang

---

## Ghi Chú

1. **Số ngày** được tính từ `startTime` đến `endTime`, tối thiểu 1 ngày.
2. **Chuyến cùng ngày** được xác định nếu `startTime` và `endTime` cùng một ngày.
3. **Liên tỉnh** được xác định nếu `distance > INTER_PROVINCE_DISTANCE_KM` (mặc định 100km).
4. Nếu không có `hireTypeId`, hệ thống sẽ tự động detect dựa trên số ngày và khoảng cách.
5. Giá cuối cùng được làm tròn 2 chữ số thập phân.

