# BÁO CÁO KIỂM TRA HỆ THỐNG - PTCMSS
**Ngày:** 02/12/2025

## 1. TỔNG QUAN LUỒNG NGHIỆP VỤ CHÍNH

### 1.1. Luồng Đặt Đơn (Booking Flow)
```
DRAFT → PENDING → QUOTATION_SENT → CONFIRMED → INPROGRESS → COMPLETED
                                                          ↘ CANCELLED
```

**Các bước:**
1. **DRAFT**: Tư vấn viên tạo đơn nháp
2. **PENDING**: Chờ tính giá/báo giá
3. **QUOTATION_SENT**: Đã gửi báo giá cho khách
4. **CONFIRMED**: Khách xác nhận → sẵn sàng điều phối
5. **INPROGRESS**: Đang thực hiện chuyến
6. **COMPLETED**: Hoàn thành

### 1.2. Luồng Thanh Toán (Payment Flow)
```
Booking (CONFIRMED) 
    → Tạo Invoice (UNPAID)
        → Đặt cọc (Payment Request PENDING)
            → Kế toán duyệt (APPROVED) → Invoice = PARTIALLYPAID
                → Thanh toán đủ → Invoice = PAID → Booking = COMPLETED
```

**Entities liên quan:**
- `invoices`: Hóa đơn chính (amount, balance, paymentStatus)
- `payment_history`: Chi tiết các lần thanh toán/đặt cọc
- `bookings.depositAmount`: Tổng tiền đã cọc (deprecated?)
- `bookings.totalCost`: Tổng chi phí

### 1.3. Luồng Điều Phối (Dispatch Flow)
```
Booking (CONFIRMED)
    → Coordinator xem gợi ý (AssignmentSuggestion)
        → Gán tài xế + xe (TripDrivers, TripVehicles)
            → Trip (SCHEDULED → ONGOING → COMPLETED)
                → Booking = INPROGRESS → COMPLETED
```

**Entities liên quan:**
- `trips`: Chuyến đi (startTime, endTime, status)
- `trip_drivers`: Gán tài xế cho chuyến (N-N)
- `trip_vehicles`: Gán xe cho chuyến (N-N)
- `booking_vehicle_details`: Chi tiết loại xe đặt (N-N)

---

## 2. PHÂN TÍCH CÁC ENTITY & CỘT DƯ THỪA

### 2.1. Entity `Bookings`
**Cột hiện tại:**
```java
- id (bookingId) ✅
- customerId ✅
- branchId ✅
- consultantId ✅
- hireTypeId ✅
- useHighway ✅
- isHoliday ✅
- isWeekend ✅
- bookingDate ✅
- estimatedCost ✅
- depositAmount ⚠️ DƯ THỪA (duplicate với payment_history)
- totalCost ✅
- status ✅
- note ✅
- createdAt ✅
- updatedAt ✅
```

**Vấn đề:**
- `depositAmount`: Duplicate với tổng trong `payment_history` 
  - **Giải pháp**: XÓA hoặc chuyển thành computed field từ payment_history

### 2.2. Entity `Invoices`
**Cột hiện tại:**
```java
- invoiceId ✅
- bookingId ✅
- invoiceDate ✅
- amount ✅ (tổng tiền hóa đơn)
- balance ✅ (số tiền còn nợ)
- paymentStatus ✅ (UNPAID/PARTIALLYPAID/PAID)
- note ✅
- createdAt ✅
```

**Trạng thái:** ✅ KHÔNG CÓ CỘT DƯ THỪA

### 2.3. Entity `PaymentHistory`
**Cột hiện tại:**
```java
- paymentId ✅
- invoiceId ✅
- amount ✅
- paymentMethod ✅
- paymentDate ✅
- status ✅ (PENDING/APPROVED/REJECTED/PAID)
- isDeposit ✅ (phân biệt cọc/thanh toán)
- qrImageUrl ✅
- receiptNumber ✅
- cashierName ✅
- note ✅
- createdAt ✅
```

**Trạng thái:** ✅ KHÔNG CÓ CỘT DƯ THỪA

### 2.4. Entity `Trips`
**Cột hiện tại (cần kiểm tra):**
- tripId ✅
- bookingId ✅
- startLocation ✅
- endLocation ✅
- distance ✅
- estimatedDuration ✅
- actualDuration ✅
- startTime ✅
- endTime ✅
- status ✅ (SCHEDULED/ONGOING/COMPLETED/CANCELLED)
- trafficStatus ✅
- createdAt ✅

**Trạng thái:** CẦN KIỂM TRA FILE ENTITY

### 2.5. Entity `Drivers`
**Vấn đề đã biết:**
- `status` enum đã FIX: `ACTIVE, AVAILABLE, ON_TRIP, OFF_DUTY, INACTIVE, ONTRIP`
- Database và backend đã đồng bộ ✅

### 2.6. Entity `Vehicles`
**Vấn đề đã biết:**
- `brand` field đã được điền dữ liệu ✅
- Database và backend đã đồng bộ ✅

---

## 3. CÁC BẢNG DƯ THỪA / KHÔNG SỬ DỤNG

### 3.1. Bảng cần XEM XÉT XÓA
1. **`accounts_receivable`** - Nếu không dùng kế toán công nợ chi tiết
2. **`debt_reminder_history`** - Nếu chưa triển khai tính năng nhắc nợ
3. **`approval_history`** - Có thể merge với payment_history
4. **`trip_incidents`** - Nếu chưa dùng quản lý sự cố
5. **`system_alerts`** - Nếu chưa dùng hệ thống cảnh báo

### 3.2. Views DƯ THỪA
Hiện có 3 views:
- `v_drivermonthlyperformance` ✅ (dùng cho báo cáo tài xế)
- `v_popularroutes` ⚠️ (cần kiểm tra có dùng không)
- `v_tripdistanceanalytics` ⚠️ (cần kiểm tra có dùng không)

---

## 4. KIỂM TRA TÍNH TOÀN VẸN DỮ LIỆU

### 4.1. Booking → Invoice
```sql
-- Kiểm tra booking không có invoice
SELECT b.bookingId, b.status 
FROM bookings b 
LEFT JOIN invoices i ON b.bookingId = i.bookingId 
WHERE i.invoiceId IS NULL 
  AND b.status IN ('CONFIRMED', 'INPROGRESS', 'COMPLETED');
```

### 4.2. Invoice → Payment Balance
```sql
-- Kiểm tra invoice.balance = invoice.amount - SUM(payments.amount)
SELECT 
    i.invoiceId,
    i.amount as invoiceAmount,
    i.balance as currentBalance,
    i.amount - COALESCE(SUM(ph.amount), 0) as calculatedBalance
FROM invoices i
LEFT JOIN payment_history ph ON i.invoiceId = ph.invoiceId 
    AND ph.status = 'APPROVED'
GROUP BY i.invoiceId
HAVING currentBalance != calculatedBalance;
```

### 4.3. Booking Status vs Trip Status
```sql
-- Kiểm tra booking INPROGRESS nhưng không có trip ONGOING
SELECT b.bookingId, b.status, t.tripId, t.status as tripStatus
FROM bookings b
LEFT JOIN trips t ON b.bookingId = t.bookingId
WHERE b.status = 'INPROGRESS'
  AND (t.tripId IS NULL OR t.status NOT IN ('SCHEDULED', 'ONGOING'));
```

---

## 5. KHUYẾN NGHỊ

### 5.1. CẦN XÓA NGAY
1. **`bookings.depositAmount`** 
   - Lý do: Duplicate với `payment_history`, gây inconsistency
   - Migration: 
     ```sql
     ALTER TABLE bookings DROP COLUMN depositAmount;
     ```

### 5.2. CẦN XEM XÉT
1. **Các bảng chưa dùng**: accounts_receivable, debt_reminder_history, approval_history
2. **Views không dùng**: v_popularroutes, v_tripdistanceanalytics

### 5.3. CẦN REFACTOR
1. **Tính toán balance**: Nên dùng computed field thay vì lưu trữ
2. **Booking status**: Cần thêm trigger để tự động update khi trip completed
3. **Payment workflow**: Cần rõ ràng hơn flow PENDING → APPROVED → PAID

---

## 6. CHECKLIST KIỂM TRA HOÀN THÀNH

### ✅ Luồng Đặt Đơn
- [x] Tạo booking DRAFT
- [x] Chuyển sang PENDING
- [x] Gửi báo giá → QUOTATION_SENT
- [x] Khách xác nhận → CONFIRMED
- [x] Điều phối → INPROGRESS
- [x] Hoàn thành → COMPLETED

### ✅ Luồng Đặt Cọc
- [x] Tạo invoice từ booking
- [x] Tạo payment request (PENDING)
- [x] Kế toán duyệt (APPROVED)
- [x] Update invoice balance
- [x] Update invoice paymentStatus

### ✅ Luồng Xếp Xe
- [x] Hiển thị danh sách chuyến CONFIRMED
- [x] Tính toán gợi ý tài xế/xe
- [x] Gán tài xế + xe vào trip
- [x] Update booking status → INPROGRESS
- [x] Update driver/vehicle status

### ✅ Luồng Hoàn Thành Chuyến
- [x] Tài xế kết thúc chuyến
- [x] Trip status → COMPLETED
- [x] Update driver/vehicle status về AVAILABLE
- [ ] ⚠️ Auto update booking status? (cần kiểm tra)

### ✅ Luồng Hoàn Thành Tiền
- [x] Thanh toán đủ
- [x] Invoice balance = 0
- [x] Invoice paymentStatus = PAID
- [x] Booking status → COMPLETED

---

## 7. KẾT LUẬN

**Tình trạng hệ thống:** ✅ CƠ BẢN ỔN ĐỊNH

**Vấn đề nghiêm trọng:** 
- ❌ `bookings.depositAmount` cần XÓA ngay

**Vấn đề cần theo dõi:**
- ⚠️ Các bảng chưa sử dụng (5 tables)
- ⚠️ Tính toàn vẹn dữ liệu giữa booking/invoice/payment
- ⚠️ Auto-update booking status khi trip completed

**Khuyến nghị tiếp theo:**
1. Chạy các query kiểm tra tính toàn vẹn (section 4)
2. Xóa `depositAmount` column
3. Review và xóa các entity không dùng
4. Thêm unit tests cho core workflows
