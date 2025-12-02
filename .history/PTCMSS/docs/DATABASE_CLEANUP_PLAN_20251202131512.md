# DANH SÁCH CÁC BẢNG/CỘT DƯ THỪA - CẦN XÓA

## 1. CÁC BẢNG CẦN XÓA HOÀN TOÀN

### ❌ accounts_receivable
**Lý do:** Duplicate hoàn toàn với `invoices` + `payment_history`
- Bảng này lưu công nợ khách hàng
- Nhưng đã có `invoices.balance` để tracking số tiền còn nợ
- Và `payment_history` để tracking các lần thanh toán
- **KHÔNG có Repository/Service/Controller nào sử dụng**

**Actions trong schema.sql:**
- Xóa lines 20-64: DROP TABLE + CREATE TABLE + INSERT DATA

---

### ❌ deposits  
**Lý do:** Duplicate 100% với `payment_history`
- Bảng này lưu thông tin đặt cọc
- Nhưng `payment_history` đã có field `isDeposit = true/false`
- **KHÔNG cần bảng riêng**

**Actions trong schema.sql:**
- Xóa lines 312-365: DROP TABLE + CREATE TABLE + INSERT DATA

---

### ❌ debt_reminder_history
**Lý do:** Tính năng chưa triển khai
- Repository có nhưng không Service/Controller nào gọi
- Tính năng nhắc nợ tự động chưa implement

**Actions trong schema.sql:**
- Xóa lines 278-311: DROP TABLE + CREATE TABLE + INSERT DATA

---

## 2. BẢNG CẦN XEM XÉT (KHÔNG XÓA NGAY)

### ⚠️ approval_history
**Trạng thái:** ĐANG SỬ DỤNG
- ✅ Có Repository
- ✅ Có Service (NotificationServiceImpl)
- ✅ Có Controller (ManagerDashboardController)
- **GIỮ LẠI**

---

### ⚠️ trip_incidents
**Trạng thái:** Chưa sử dụng NHƯNG có thể cần sau
- Bảng lưu sự cố trong chuyến đi
- Tính năng tốt để tracking vấn đề
- **KHUYẾN NGHỊ:** Giữ lại cho tương lai

---

## 3. CỘT CẦN THÊM VÀO

### ✅ bookings.depositAmount
**Vấn đề:** Backend entity có nhưng database CHƯA có cột này!
- Entity Bookings.java có field `depositAmount`
- Được sử dụng trong 5+ service classes
- **CẦN THÊM NGAY:**

```sql
ALTER TABLE `bookings` 
ADD COLUMN `depositAmount` decimal(12,2) DEFAULT 0.00 
AFTER `estimatedCost`;
```

---

## 4. VIEWS CẦN KIỂM TRA

### v_popularroutes
**Trạng thái:** Không rõ có dùng không
- View tính toán tuyến đường phổ biến
- Cần kiểm tra frontend có query không

### v_tripdistanceanalytics  
**Trạng thái:** Không rõ có dùng không
- View phân tích khoảng cách chuyến đi
- Cần kiểm tra dashboard có dùng không

### v_drivermonthlyperformance
**Trạng thái:** CÓ THỂ ĐANG DÙNG
- View tính hiệu suất tài xế theo tháng
- **GIỮ LẠI**

---

## 5. TÓM TẮT ACTIONS

### NGAY LẬP TỨC:
1. **ADD column** `bookings.depositAmount`
2. **DROP tables:**
   - accounts_receivable
   - deposits  
   - debt_reminder_history

### SAU KHI XÁC NHẬN:
3. **DROP views** (nếu không dùng):
   - v_popularroutes
   - v_tripdistanceanalytics

### GIỮ LẠI:
- approval_history (đang dùng)
- trip_incidents (có thể dùng sau)
- v_drivermonthlyperformance (có thể đang dùng)

---

## 6. SCRIPT THỰC HIỆN

Đã tạo file: `cleanup-unused-tables.sql`

Chạy script đó để:
1. Xóa 3 bảng dư thừa
2. Thêm cột depositAmount
3. Verify kết quả

---

## 7. CẬP NHẬT ENTITIES

Sau khi chạy script, cần xóa các Entity/Repository không dùng:

### Xóa khỏi backend:
```
ptcmss-backend/src/main/java/org/example/ptcmssbackend/
├── entity/
│   ├── AccountsReceivable.java ❌ XÓA (nếu có)
│   └── DebtReminderHistory.java ⚠️ GIỮ (có Repository nhưng ko dùng)
└── repository/
    ├── AccountsReceivableRepository.java ❌ XÓA (nếu có)
    └── DebtReminderHistoryRepository.java ⚠️ GIỮ (có thể dùng sau)
```

---

## 8. KẾT LUẬN

**Tác động:**
- ✅ Giảm 3 bảng không cần thiết
- ✅ Fix lỗi thiếu cột depositAmount
- ✅ Database clean hơn, dễ maintain

**Rủi ro:**
- ⚠️ Nếu có code cũ reference đến bảng xóa → sẽ lỗi (nhưng không tìm thấy)
- ✅ Safe để xóa vì không có code nào sử dụng
