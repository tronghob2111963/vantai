# PHÂN TÍCH LOGIC BUSINESS vs CODEBASE HIỆN TẠI

## 📋 TỔNG QUAN

Tài liệu này phân tích so sánh các quy định business được cung cấp với logic hiện tại trong codebase.

---

## 1. QUY ĐỊNH THANH TOÁN

### 1.1. Giá thuê xe cơ bản

**Yêu cầu Business:**
- Giá thuê tùy theo loại xe (16, 30, 45 chỗ)
- Áp dụng cho chuyến đi trong ngày (6h sáng - 7-8h tối, có thể đến 10-11h đêm)
- Ví dụ:
  - Xe 16 chỗ (có cao tốc): 2,600,000đ (đã bao gồm cao tốc)
  - Xe 16 chỗ (chưa cao tốc): 2,500,000đ + 300,000đ phí cao tốc
  - Xe 30 chỗ: ~3,000,000đ

**Codebase hiện tại:**
- ✅ Có bảng `vehicle_category_pricing` với `baseFare`, `pricePerKm`, `highwayFee`
- ✅ Có logic tính giá: `baseFare + (pricePerKm × distance) + highwayFee`
- ✅ Đã cập nhật giá/km: 30k (16 chỗ), 40k (30 chỗ), 50k (45 chỗ)
- ⚠️ **THIẾU:** Logic phân biệt "chuyến đi trong ngày" vs "chuyến đi dài ngày"
- ⚠️ **THIẾU:** Giá cố định cho chuyến trong ngày (hiện tại chỉ tính theo km)

**Đánh giá:** ⚠️ **CHƯA ĐẦY ĐỦ** - Cần thêm logic giá cố định cho chuyến trong ngày

---

### 1.2. Xe cao cấp

**Yêu cầu Business:**
- Xe hạng sang chênh lệch 1-2 triệu VNĐ so với xe bình thường

**Codebase hiện tại:**
- ✅ Đã thêm field `isPremium`, `premiumSurcharge` vào `vehicle_category_pricing`
- ✅ Đã implement logic tính phụ phí xe hạng sang trong `calculatePrice()`
- ✅ Default: 1,000,000đ (có thể config)

**Đánh giá:** ✅ **ĐẦY ĐỦ**

---

### 1.3. Tiền đặt cọc

**Yêu cầu Business:**
- Mức đặt cọc: 50% hoặc 60-70% trị giá chuyến
- Thanh toán phần còn lại sau khi kết thúc chuyến
- Không chấp nhận đặt cọc bằng miệng (cần hợp đồng/biên nhận)

**Codebase hiện tại:**
- ✅ Có field `depositAmount` trong `bookings`
- ✅ Có bảng `deposits` với `depositPercent`
- ✅ Có UI `DepositModal` để ghi nhận tiền cọc
- ✅ Có API `/api/deposits/bookings/{id}` để tạo deposit
- ⚠️ **THIẾU:** Logic tự động tính % cọc (50% hoặc 60-70%)
- ⚠️ **THIẾU:** Validation yêu cầu hợp đồng/biên nhận khi đặt cọc
- ⚠️ **THIẾU:** SystemSettings để config % cọc mặc định

**Đánh giá:** ⚠️ **CHƯA ĐẦY ĐỦ** - Cần thêm logic tự động tính % và validation

---

## 2. CÁCH SẮP XẾP XE VÀ TÀI XẾ

### 2.1. Phân bổ số lượng tài xế

**Yêu cầu Business:**
- Chuyến <300km (cả đi lẫn về): 1 tài xế
- Chuyến dài (cả ngày lẫn đêm): 2 tài xế thay ca

**Codebase hiện tại:**
- ✅ Có bảng `trip_drivers` (1 trip có thể có nhiều driver)
- ✅ Có logic auto assign trong `DispatchServiceImpl`
- ✅ Có `priorityLevel` trong `drivers` (1-10)
- ❌ **THIẾU:** Logic tự động quyết định số lượng tài xế dựa trên quãng đường
- ❌ **THIẾU:** Logic tự động gán 2 tài xế cho chuyến dài

**Đánh giá:** ❌ **THIẾU** - Cần implement logic tự động phân bổ số lượng tài xế

---

### 2.2. Phân bổ thời gian nghỉ ngơi

**Yêu cầu Business:**
- **1 tài xế/chuyến:**
  - Không lái liên tục quá 4 giờ
  - Không quá 10 giờ/ngày
  - Không quá 48 giờ/tuần
- **2 tài xế:** Thay ca nhau (ví dụ: 6-7 tiếng mỗi người)

**Codebase hiện tại:**
- ✅ Có SystemSettings: `MAX_DRIVING_HOURS_PER_DAY = 10`
- ✅ Có AlertType: `DRIVING_HOURS_EXCEEDED`, `DRIVER_REST_REQUIRED`
- ✅ Có logic check trong `NotificationServiceImpl`
- ❌ **THIẾU:** SystemSettings cho:
  - `MAX_CONTINUOUS_DRIVING_HOURS = 4` (4 giờ liên tục)
  - `MAX_DRIVING_HOURS_PER_WEEK = 48` (48 giờ/tuần)
- ❌ **THIẾU:** Logic tự động check và cảnh báo khi vi phạm
- ❌ **THIẾU:** Logic tự động tính toán thời gian nghỉ giữa các chuyến

**Đánh giá:** ⚠️ **CHƯA ĐẦY ĐỦ** - Cần thêm SystemSettings và logic check đầy đủ

---

### 2.3. Auto assign với độ ưu tiên

**Yêu cầu Business:**
- Cần nghiên cứu độ ưu tiên để phục vụ auto assign

**Codebase hiện tại:**
- ✅ Có field `priorityLevel` (1-10) trong `drivers`
- ✅ Có `autoAssign` flag trong `AssignRequest`
- ✅ Có logic auto assign trong `DispatchServiceImpl`
- ⚠️ **CHƯA RÕ:** Logic ưu tiên hiện tại như thế nào (cần xem code chi tiết)

**Đánh giá:** ⚠️ **CẦN KIỂM TRA** - Cần xem logic auto assign có dùng `priorityLevel` không

---

## 3. QUY ĐỊNH VỀ HỦY/SỬA ĐỔI ĐƠN

### 3.1. Cho phép hủy/sửa đổi

**Yêu cầu Business:**
- Cho phép hủy/sửa đổi trước thời điểm khởi hành
- Quy định trong hợp đồng

**Codebase hiện tại:**
- ✅ Có status `CANCELLED` trong `bookings`
- ✅ Có API `DELETE /api/bookings/{id}` để hủy
- ✅ Có validation: chỉ cho phép update khi status là `PENDING` hoặc `CONFIRMED`
- ⚠️ **THIẾU:** Validation check "trước thời điểm khởi hành"
- ⚠️ **THIẾU:** Field lưu thời điểm khởi hành để so sánh

**Đánh giá:** ⚠️ **CHƯA ĐẦY ĐỦ** - Cần thêm validation thời điểm

---

### 3.2. Xử lý tiền cọc khi hủy

**Yêu cầu Business:**
- Nếu hủy gần ngày khởi hành:
  - Mất hoàn toàn tiền cọc (50%)
  - Hoặc mất một phần (30%)
- Tùy thuộc thỏa thuận trong hợp đồng

**Codebase hiện tại:**
- ✅ Có bảng `deposits` với status `REFUNDED`, `CANCELLED`
- ✅ Có API cancel deposit: `/api/deposits/{id}/cancel`
- ❌ **THIẾU:** Logic tự động tính % mất cọc dựa trên:
  - Thời gian hủy (trước bao nhiêu ngày/giờ)
  - Quy định trong hợp đồng
- ❌ **THIẾU:** SystemSettings để config:
  - `CANCELLATION_FULL_DEPOSIT_LOSS_HOURS` (ví dụ: hủy <24h = mất 100%)
  - `CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS` (ví dụ: hủy <48h = mất 30%)
  - `CANCELLATION_PARTIAL_DEPOSIT_PERCENT` (ví dụ: 30%)

**Đánh giá:** ❌ **THIẾU** - Cần implement logic tính % mất cọc tự động

---

## 4. XỬ LÝ CHI PHÍ PHÁT SINH TRONG CHUYẾN ĐI

**Yêu cầu Business:**
- Có 2 cách:
  1. Công ty chuyển khoản trực tiếp
  2. Tài xế ứng trước → Kế toán thanh toán lại sau

**Codebase hiện tại:**
- ✅ Có bảng `expense_requests` (yêu cầu chi phí)
- ✅ Có UI `ExpenseRequestForm` để tài xế gửi yêu cầu
- ✅ Có workflow: PENDING → APPROVED → PAID
- ✅ Có field `requestedBy`, `approvedBy`, `paidBy`
- ⚠️ **CHƯA RÕ:** Có phân biệt 2 cách xử lý không (công ty trả trực tiếp vs tài xế ứng trước)

**Đánh giá:** ⚠️ **CẦN KIỂM TRA** - Cần xem logic xử lý expense có đủ 2 cách không

---

## 5. XỬ LÝ CÔNG NỢ THUÊ XE ĐỊNH KỲ

### 5.1. Người quản lý công nợ

**Yêu cầu Business:**
- Kế toán chịu trách nhiệm chính
- Báo cáo tình hình công nợ với giám đốc

**Codebase hiện tại:**
- ✅ Có bảng `accounts_receivable` (công nợ phải thu)
- ✅ Có bảng `debt_reminder_history` (lịch sử nhắc nợ)
- ✅ Có role `ACCOUNTANT` (kế toán)
- ✅ Có UI `DebtManagementPage` cho kế toán
- ✅ Có chức năng nhắc nợ tự động
- ✅ Có báo cáo công nợ

**Đánh giá:** ✅ **ĐẦY ĐỦ**

---

### 5.2. Quy định/Hợp đồng

**Yêu cầu Business:**
- Dựa trên quy định công ty và hợp đồng đã ký
- Kế toán sử dụng để giải quyết công nợ

**Codebase hiện tại:**
- ✅ Có field `note`, `description` trong `accounts_receivable`
- ⚠️ **THIẾU:** Field lưu trữ hợp đồng/thỏa thuận
- ⚠️ **THIẾU:** Link đến file hợp đồng (nếu có)

**Đánh giá:** ⚠️ **CHƯA ĐẦY ĐỦ** - Có thể cần thêm field lưu hợp đồng

---

## 6. TÀI XẾ

**Yêu cầu Business:**
- 6 tháng khám sức khỏe một lần
- Báo trước 1 tuần

**Codebase hiện tại:**
- ✅ Có field `healthCheckDate` trong `drivers`
- ✅ Có AlertType: `DRIVER_HEALTH_CHECK_DUE`
- ✅ Có logic check trong `NotificationServiceImpl`
- ⚠️ **THIẾU:** SystemSettings để config:
  - `DRIVER_HEALTH_CHECK_INTERVAL_MONTHS = 6` (6 tháng)
  - `DRIVER_HEALTH_CHECK_REMINDER_DAYS = 7` (báo trước 7 ngày)
- ⚠️ **THIẾU:** Logic hiện tại check 1 năm/lần (cần sửa thành 6 tháng)

**Đánh giá:** ⚠️ **CHƯA ĐẦY ĐỦ** - Cần sửa logic từ 1 năm → 6 tháng và thêm config

---

## 📊 TÓM TẮT ĐÁNH GIÁ

| Tính năng | Trạng thái | Ghi chú |
|-----------|------------|---------|
| **1. Giá thuê xe cơ bản** | ⚠️ Chưa đầy đủ | Thiếu logic giá cố định cho chuyến trong ngày |
| **2. Xe cao cấp** | ✅ Đầy đủ | Đã implement |
| **3. Tiền đặt cọc** | ⚠️ Chưa đầy đủ | Thiếu logic tự động tính % và validation |
| **4. Phân bổ số lượng tài xế** | ❌ Thiếu | Cần logic tự động quyết định 1-2 tài xế |
| **5. Thời gian nghỉ ngơi** | ⚠️ Chưa đầy đủ | Thiếu config 4h liên tục, 48h/tuần |
| **6. Auto assign** | ⚠️ Cần kiểm tra | Cần xem logic ưu tiên |
| **7. Hủy/sửa đổi đơn** | ⚠️ Chưa đầy đủ | Thiếu validation thời điểm |
| **8. Mất tiền cọc khi hủy** | ❌ Thiếu | Cần logic tính % tự động |
| **9. Chi phí phát sinh** | ⚠️ Cần kiểm tra | Cần xem có đủ 2 cách xử lý |
| **10. Công nợ định kỳ** | ✅ Đầy đủ | Đã implement |
| **11. Khám sức khỏe tài xế** | ⚠️ Chưa đầy đủ | Cần sửa 1 năm → 6 tháng |

---

## 🎯 KHUYẾN NGHỊ ƯU TIÊN

### Priority 1 (Quan trọng - Ảnh hưởng trực tiếp đến business):
1. **Logic tính giá cố định cho chuyến trong ngày** - Ảnh hưởng đến báo giá
2. **Logic tự động tính % tiền cọc** - Ảnh hưởng đến thanh toán
3. **Logic tự động phân bổ số lượng tài xế** - Ảnh hưởng đến an toàn và chi phí

### Priority 2 (Quan trọng - Cải thiện quy trình):
4. **Logic tính % mất cọc khi hủy** - Ảnh hưởng đến chính sách hủy
5. **Validation thời điểm hủy/sửa đổi** - Tránh hủy sau khi đã khởi hành
6. **SystemSettings cho thời gian lái xe** - Đảm bảo tuân thủ quy định

### Priority 3 (Cải thiện):
7. **Sửa logic khám sức khỏe 6 tháng** - Đảm bảo tuân thủ quy định
8. **Kiểm tra và cải thiện auto assign** - Tối ưu phân bổ tài xế

---

## 📝 NEXT STEPS

1. ✅ Review và xác nhận các điểm thiếu với team
2. ✅ Tạo task list chi tiết cho từng tính năng
3. ✅ Implement theo thứ tự ưu tiên
4. ✅ Test kỹ từng tính năng trước khi deploy

