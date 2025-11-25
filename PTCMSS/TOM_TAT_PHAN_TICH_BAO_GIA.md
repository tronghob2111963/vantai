# TÓM TẮT PHÂN TÍCH LOGIC BÁO GIÁ

## 🎯 KẾT LUẬN CHÍNH

Sau khi phân tích dự án và so sánh với logic báo giá bạn đưa ra, tôi phát hiện:

### ✅ **ĐÃ CÓ:**
1. Hệ thống tính giá cơ bản (baseFare + pricePerKm × distance)
2. Phí cao tốc (highwayFee)
3. Bảng `hire_types` (ONE_WAY, ROUND_TRIP, MULTI_DAY)
4. Tính theo số lượng xe

### ❌ **THIẾU:**
1. **Giá/km không đúng:** Hiện tại 18k/22k/28k, yêu cầu 30k/40k/50k
2. **Hệ số 1 chiều/2 chiều:** Chưa có logic giảm giá 1 chiều (2/3)
3. **Phụ phí ngày lễ/cuối tuần:** Chưa có (+20-25%)
4. **Phụ phí xe hạng sang:** Chưa có (+1-2 triệu)
5. **Phụ phí địa điểm phát sinh:** Chưa có
6. **Cấu hình SystemSettings:** Chưa có để setup % phụ phí

---

## 📊 BẢNG SO SÁNH GIÁ/KM

| Loại xe | Yêu cầu | Hiện tại | Cần cập nhật |
|---------|---------|----------|--------------|
| 16 chỗ | 30,000đ/km | 18,000đ/km | ✅ Cần |
| 30 chỗ | 40,000đ/km | 22,000đ/km | ✅ Cần |
| 45 chỗ | 50,000đ/km | 28,000đ/km | ✅ Cần |

---

## 🔧 CÔNG THỨC YÊU CẦU

```
GIÁ THUÊ = TỔNG QUÃNG ĐƯỜNG × ĐƠN GIÁ THEO LOẠI XE × HỆ SỐ + PHỤ PHÍ

Trong đó:
- Đơn giá/km: 30k (16), 40k (30), 50k (45)
- Hệ số: 1.0 (2 chiều), 2/3 (1 chiều)
- Phụ phí: 
  + Lễ/cuối tuần: +20-25%
  + Xe sang: +1-2tr
  + Địa điểm phát sinh: tăng thêm
```

---

## 📝 VÍ DỤ TÍNH TOÁN

### Ví dụ 1: Xe 16 chỗ, 400km, 2 chiều, ngày thường

**Yêu cầu:**
```
400km × 30,000đ/km × 1.0 = 12,000,000đ
```

**Hiện tại:**
```
1,100,000 + (18,000 × 400) + 120,000 = 8,420,000đ
```

**Kết quả:** ❌ Thiếu 3,580,000đ

---

### Ví dụ 2: Xe 16 chỗ, 400km, 1 chiều, ngày thường

**Yêu cầu:**
```
400km × 30,000đ/km × 2/3 = 8,000,000đ
```

**Hiện tại:**
```
1,100,000 + (18,000 × 400) + 120,000 = 8,420,000đ
(Không phân biệt 1 chiều/2 chiều)
```

**Kết quả:** ❌ Không có hệ số 1 chiều

---

### Ví dụ 3: Xe 16 chỗ, 400km, 2 chiều, ngày lễ (+25%)

**Yêu cầu:**
```
Giá cơ bản: 400km × 30,000đ/km × 1.0 = 12,000,000đ
Phụ phí lễ: 12,000,000đ × 25% = 3,000,000đ
Tổng: 15,000,000đ
```

**Hiện tại:**
```
1,100,000 + (18,000 × 400) + 120,000 = 8,420,000đ
(Không có phụ phí lễ)
```

**Kết quả:** ❌ Thiếu phụ phí lễ

---

## 🎯 CẦN LÀM GÌ?

### 1. **Cập nhật Database**
```sql
-- Cập nhật giá/km
UPDATE vehicle_category_pricing SET pricePerKm = 30000 WHERE seats = 16;
UPDATE vehicle_category_pricing SET pricePerKm = 40000 WHERE seats = 30;
UPDATE vehicle_category_pricing SET pricePerKm = 50000 WHERE seats = 45;

-- Thêm field xe hạng sang
ALTER TABLE vehicle_category_pricing 
ADD COLUMN isPremium BOOLEAN DEFAULT FALSE,
ADD COLUMN premiumSurcharge DECIMAL(10,2) DEFAULT 1000000;

-- Thêm field vào bookings
ALTER TABLE bookings 
ADD COLUMN isHoliday BOOLEAN DEFAULT FALSE,
ADD COLUMN isWeekend BOOLEAN DEFAULT FALSE,
ADD COLUMN additionalPickupPoints INT DEFAULT 0,
ADD COLUMN additionalDropoffPoints INT DEFAULT 0;

-- Thêm SystemSettings
INSERT INTO system_settings (settingKey, settingValue, category, description) VALUES
('HOLIDAY_SURCHARGE_RATE', '0.25', 'Pricing', 'Phụ phí ngày lễ (25%)'),
('WEEKEND_SURCHARGE_RATE', '0.20', 'Pricing', 'Phụ phí cuối tuần (20%)'),
('ONE_WAY_DISCOUNT_RATE', '0.6667', 'Pricing', 'Hệ số giảm giá 1 chiều (2/3)');
```

### 2. **Cập nhật Backend (Java)**
- Sửa `BookingServiceImpl.calculatePrice()` để:
  - Sử dụng `hireTypeId` để xác định 1 chiều/2 chiều
  - Tính phụ phí lễ/cuối tuần từ SystemSettings
  - Tính phụ phí xe hạng sang
  - Tính phụ phí địa điểm phát sinh

### 3. **Cập nhật Frontend (React)**
- Thêm checkbox "Ngày lễ"
- Tự động detect "Cuối tuần" từ ngày
- Thêm input "Số điểm đón/trả thêm"
- Hiển thị breakdown giá (giá cơ bản, phụ phí lễ, phụ phí xe sang, etc.)

---

## 📚 TÀI LIỆU CHI TIẾT

Xem thêm:
- `PRICING_LOGIC_ANALYSIS.md` - Phân tích chi tiết
- `PRICING_LOGIC_COMPARISON_TABLE.md` - Bảng so sánh đầy đủ

---

## ✅ KẾT LUẬN

**Logic hiện tại:** Đơn giản, chưa đáp ứng đầy đủ yêu cầu.

**Cần làm:** Cập nhật công thức tính giá, thêm các phụ phí, và cấu hình trong SystemSettings.

**Ưu tiên:**
1. ⚡ Cập nhật giá/km (30k/40k/50k)
2. ⚡ Thêm hệ số 1 chiều/2 chiều
3. ⚡ Thêm phụ phí lễ/cuối tuần
4. ⚡ Thêm phụ phí xe hạng sang
5. ⚡ Thêm phụ phí địa điểm phát sinh

