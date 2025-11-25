# BẢNG SO SÁNH LOGIC TÍNH GIÁ

## 📊 SO SÁNH CHI TIẾT

| Tính năng | Yêu cầu nghiệp vụ | Logic hiện tại | Trạng thái |
|-----------|------------------|---------------|------------|
| **Giá/km theo loại xe** | | | |
| - Xe 16 chỗ | 30,000đ/km | 18,000đ/km | ❌ Cần cập nhật |
| - Xe 30 chỗ | 40,000đ/km | 22,000đ/km (29 chỗ) | ❌ Cần cập nhật |
| - Xe 45 chỗ | 50,000đ/km | 28,000đ/km | ❌ Cần cập nhật |
| **Hệ số 1 chiều/2 chiều** | | | |
| - Đi 2 chiều | Hệ số = 1.0 | ❌ Chưa có | ❌ Thiếu |
| - Đi 1 chiều | Hệ số = 2/3 (0.6667) | ❌ Chưa có | ❌ Thiếu |
| **Phụ phí ngày lễ** | +20-25% | ❌ Chưa có | ❌ Thiếu |
| **Phụ phí cuối tuần** | +20-25% | ❌ Chưa có | ❌ Thiếu |
| **Phụ phí xe hạng sang** | +1-2 triệu VNĐ | ❌ Chưa có | ❌ Thiếu |
| **Phụ phí địa điểm phát sinh** | Tăng giá khi có điểm đón/trả thêm | ❌ Chưa có | ❌ Thiếu |
| **Cấu hình SystemSettings** | Có thể setup % phụ phí | ❌ Chưa có | ❌ Thiếu |
| **Phí cao tốc** | Đã bao gồm trong giá | ✅ Có (highwayFee) | ✅ OK |
| **Giá cơ bản (baseFare)** | Có trong bảng giá | ✅ Có | ✅ OK |
| **Tính theo số lượng xe** | Có | ✅ Có | ✅ OK |

---

## 🎯 VÍ DỤ TÍNH TOÁN

### Ví dụ 1: Xe 16 chỗ, 400km, 2 chiều, ngày thường

**Yêu cầu:**
```
Giá = 400km × 30,000đ/km × 1.0 = 12,000,000đ
```

**Logic hiện tại:**
```
Giá = 1,100,000 + (18,000 × 400) + 120,000 = 8,420,000đ
```

**Kết quả:** ❌ Khác nhau (thiếu 3,580,000đ)

---

### Ví dụ 2: Xe 16 chỗ, 400km, 1 chiều, ngày thường

**Yêu cầu:**
```
Giá = 400km × 30,000đ/km × 2/3 = 8,000,000đ
```

**Logic hiện tại:**
```
Giá = 1,100,000 + (18,000 × 400) + 120,000 = 8,420,000đ
(Không phân biệt 1 chiều/2 chiều)
```

**Kết quả:** ❌ Khác nhau, không có hệ số 1 chiều

---

### Ví dụ 3: Xe 16 chỗ, 400km, 2 chiều, ngày lễ (+25%)

**Yêu cầu:**
```
Giá cơ bản = 400km × 30,000đ/km × 1.0 = 12,000,000đ
Phụ phí lễ = 12,000,000đ × 25% = 3,000,000đ
Tổng = 15,000,000đ
```

**Logic hiện tại:**
```
Giá = 1,100,000 + (18,000 × 400) + 120,000 = 8,420,000đ
(Không có phụ phí lễ)
```

**Kết quả:** ❌ Thiếu phụ phí lễ

---

### Ví dụ 4: Xe 30 chỗ, 383km, 3 ngày 2 đêm, có cao tốc

**Yêu cầu:**
```
Giá cơ bản = 383km × 40,000đ/km × 1.0 = 15,320,000đ
Phụ phí cao tốc = 1,000,000đ
Tổng = 16,320,000đ (≈ 16,000,000đ như bảng)
```

**Logic hiện tại:**
```
Giá = 1,800,000 + (22,000 × 383) + 150,000 = 10,226,000đ
```

**Kết quả:** ❌ Khác nhau (thiếu 6,094,000đ)

---

## 📋 BẢNG GIÁ YÊU CẦU vs HIỆN TẠI

### Xe 16 chỗ

| Loại thuê | Yêu cầu | Logic hiện tại | Chênh lệch |
|-----------|---------|---------------|------------|
| Trong ngày (HD-HN) | 2,000,000đ | ~1,100,000đ + (18k × km) | ❌ Khác |
| Thuê dài ngày | 2,500,000đ | ~1,100,000đ + (18k × km) | ❌ Khác |
| Một lượt - Ngày thường | 3,500,000đ | ~1,100,000đ + (18k × km) | ❌ Khác |
| Một lượt - Ngày lễ | 4,000,000đ | ~1,100,000đ + (18k × km) | ❌ Khác |

### Xe 30 chỗ

| Loại thuê | Yêu cầu | Logic hiện tại | Chênh lệch |
|-----------|---------|---------------|------------|
| Trong ngày (HD-HN) | 2,500,000đ | ~1,800,000đ + (22k × km) | ❌ Khác |
| Thuê dài ngày | 2.8-3tr | ~1,800,000đ + (22k × km) | ❌ Khác |
| Một lượt - Ngày thường | 4,500,000đ | ~1,800,000đ + (22k × km) | ❌ Khác |
| Một lượt - Ngày lễ | 5,000,000đ | ~1,800,000đ + (22k × km) | ❌ Khác |

---

## 🔍 PHÂN TÍCH CHI TIẾT

### 1. Công thức hiện tại

```
Giá = baseFare + (pricePerKm × distance) + highwayFee + fixedCosts
```

**Vấn đề:**
- Không có hệ số 1 chiều/2 chiều
- Không có phụ phí ngày lễ/cuối tuần
- Không có phụ phí xe hạng sang
- Không có phụ phí địa điểm phát sinh
- Giá/km không đúng với yêu cầu

### 2. Công thức yêu cầu

```
GIÁ THUÊ = TỔNG QUÃNG ĐƯỜNG × ĐƠN GIÁ THEO LOẠI XE × HỆ SỐ + PHỤ PHÍ

Trong đó:
- Đơn giá/km: 30k (16 chỗ), 40k (30 chỗ), 50k (45 chỗ)
- Hệ số: 1.0 (2 chiều), 2/3 (1 chiều)
- Phụ phí: lễ/cuối tuần (+20-25%), xe sang (+1-2tr), địa điểm phát sinh
```

### 3. Các field cần thêm

**Bảng `vehicle_category_pricing`:**
- `isPremium` (boolean)
- `premiumSurcharge` (decimal)

**Bảng `bookings`:**
- `isHoliday` (boolean) - Tự động detect từ ngày
- `isWeekend` (boolean) - Tự động detect từ ngày
- `additionalPickupPoints` (int)
- `additionalDropoffPoints` (int)

**Bảng `system_settings`:**
- `HOLIDAY_SURCHARGE_RATE` (decimal, default 0.20-0.25)
- `WEEKEND_SURCHARGE_RATE` (decimal, default 0.20-0.25)
- `ONE_WAY_DISCOUNT_RATE` (decimal, default 0.6667)

**Lưu ý:** Bảng `hire_types` đã có sẵn (ONE_WAY, ROUND_TRIP, MULTI_DAY) - có thể sử dụng thay vì tạo field mới.

---

## ✅ KẾT LUẬN

**Logic hiện tại:** Đơn giản, chưa đáp ứng đầy đủ yêu cầu nghiệp vụ.

**Cần làm:**
1. Cập nhật giá/km trong database
2. Thêm logic hệ số 1 chiều/2 chiều
3. Thêm phụ phí ngày lễ/cuối tuần
4. Thêm phụ phí xe hạng sang
5. Thêm phụ phí địa điểm phát sinh
6. Thêm cấu hình SystemSettings
7. Cập nhật frontend để nhập các thông tin mới

