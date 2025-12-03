# System Settings Checklist - Kiểm tra đầy đủ

## Tất cả System Settings được sử dụng trong code:

### 1. BookingServiceImpl.java

#### Billing & Deposit:
- ✅ `DEFAULT_DEPOSIT_PERCENT` = 0.50 (Line 151)
- ✅ `VAT_RATE` = 0.08 (từ schema.sql ban đầu)

#### Cancellation:
- ✅ `CANCELLATION_FULL_DEPOSIT_LOSS_HOURS` = 24 (Line 666)
- ✅ `CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS` = 48 (Line 667)
- ✅ `CANCELLATION_PARTIAL_DEPOSIT_PERCENT` = 0.30 (Line 668)

#### Pricing:
- ✅ `HOLIDAY_SURCHARGE_RATE` = 0.25 (Line 743)
- ✅ `WEEKEND_SURCHARGE_RATE` = 0.20 (Line 744)
- ✅ `ROUND_TRIP_MULTIPLIER` = 1.5 (Line 745)
- ✅ `INTER_PROVINCE_DISTANCE_KM` = 100 (Line 746)

#### Trip Timing:
- ✅ `SAME_DAY_TRIP_START_HOUR` = 6 (Line 964)
- ✅ `SAME_DAY_TRIP_END_HOUR` = 23 (Line 965)

#### Booking Modification:
- ✅ `BOOKING_MAJOR_MODIFICATION_MIN_HOURS` = 72 (Line 1132)
- ✅ `BOOKING_MINOR_MODIFICATION_MIN_HOURS` = 24 (Line 1141)

#### Booking Default:
- ✅ `DEFAULT_HIGHWAY` = true (từ schema.sql ban đầu)

### 2. DispatchServiceImpl.java

#### Auto Assign:
- ✅ `SINGLE_DRIVER_MAX_DISTANCE_KM` = 300 (Line 721)

### 3. NotificationServiceImpl.java

#### Driver Hours:
- ✅ `MAX_CONTINUOUS_DRIVING_HOURS` = 4 (Line 695)
- ✅ `MAX_DRIVING_HOURS_PER_DAY` = 10 (Line 696)
- ✅ `MAX_DRIVING_HOURS_PER_WEEK` = 48 (Line 697)

#### Driver Leave:
- ✅ `MAX_DRIVER_LEAVE_DAYS` = 2 (Line 1124)

---

## Tổng kết: 19 Settings

Tất cả 19 settings đã được thêm vào seed.sql:
1. VAT_RATE
2. DEFAULT_HIGHWAY
3. MAX_DRIVING_HOURS_PER_DAY
4. ROUND_TRIP_MULTIPLIER
5. DEFAULT_DEPOSIT_PERCENT
6. CANCELLATION_FULL_DEPOSIT_LOSS_HOURS
7. CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS
8. CANCELLATION_PARTIAL_DEPOSIT_PERCENT
9. BOOKING_MAJOR_MODIFICATION_MIN_HOURS
10. BOOKING_MINOR_MODIFICATION_MIN_HOURS
11. SAME_DAY_TRIP_START_HOUR
12. SAME_DAY_TRIP_END_HOUR
13. HOLIDAY_SURCHARGE_RATE
14. WEEKEND_SURCHARGE_RATE
15. INTER_PROVINCE_DISTANCE_KM
16. MAX_CONTINUOUS_DRIVING_HOURS
17. MAX_DRIVING_HOURS_PER_WEEK
18. MAX_DRIVER_LEAVE_DAYS
19. SINGLE_DRIVER_MAX_DISTANCE_KM

---

## Các chức năng bị ảnh hưởng nếu thiếu settings:

### Auto Assign (DispatchService):
- ❌ Thiếu `SINGLE_DRIVER_MAX_DISTANCE_KM` → Không thể quyết định 1 hay 2 tài xế

### Tính tiền (BookingService):
- ❌ Thiếu `DEFAULT_DEPOSIT_PERCENT` → Không tính được tiền cọc mặc định
- ❌ Thiếu `HOLIDAY_SURCHARGE_RATE` → Không tính phụ thu ngày lễ
- ❌ Thiếu `WEEKEND_SURCHARGE_RATE` → Không tính phụ thu cuối tuần
- ❌ Thiếu `ROUND_TRIP_MULTIPLIER` → Không tính hệ số 2 chiều
- ❌ Thiếu `INTER_PROVINCE_DISTANCE_KM` → Không phân biệt liên tỉnh
- ❌ Thiếu `VAT_RATE` → Không tính VAT

### Hủy đơn (BookingService):
- ❌ Thiếu `CANCELLATION_FULL_DEPOSIT_LOSS_HOURS` → Không tính mất cọc
- ❌ Thiếu `CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS` → Không tính mất cọc một phần
- ❌ Thiếu `CANCELLATION_PARTIAL_DEPOSIT_PERCENT` → Không tính % mất cọc

### Sửa đổi booking (BookingService):
- ❌ Thiếu `BOOKING_MAJOR_MODIFICATION_MIN_HOURS` → Không kiểm tra thời gian sửa lớn
- ❌ Thiếu `BOOKING_MINOR_MODIFICATION_MIN_HOURS` → Không kiểm tra thời gian sửa nhỏ

### Chuyến trong ngày (BookingService):
- ❌ Thiếu `SAME_DAY_TRIP_START_HOUR` → Không xác định chuyến trong ngày
- ❌ Thiếu `SAME_DAY_TRIP_END_HOUR` → Không xác định chuyến trong ngày

### Giới hạn tài xế (NotificationService):
- ❌ Thiếu `MAX_CONTINUOUS_DRIVING_HOURS` → Không kiểm tra giờ lái liên tục
- ❌ Thiếu `MAX_DRIVING_HOURS_PER_DAY` → Không kiểm tra giờ lái/ngày
- ❌ Thiếu `MAX_DRIVING_HOURS_PER_WEEK` → Không kiểm tra giờ lái/tuần
- ❌ Thiếu `MAX_DRIVER_LEAVE_DAYS` → Không kiểm tra ngày nghỉ tối đa

