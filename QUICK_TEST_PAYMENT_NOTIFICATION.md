# Quick Test Guide: Payment Approval Notification

## Test nhanh trong 5 phút

### Bước 1: Chuẩn bị
1. **Mở 2 trình duyệt** (hoặc 2 tab):
   - Tab 1: Đăng nhập với **Consultant**
   - Tab 2: Đăng nhập với **Accountant**

2. **Mở Console** (F12) ở Tab Consultant để xem WebSocket logs

### Bước 2: Tạo Payment Request
**Trong Tab Consultant:**
- Vào trang Invoice/Booking có invoice chưa thanh toán
- Click "Thêm thanh toán" → Điền amount → Chọn "PENDING" → Submit

### Bước 3: Duyệt Payment Request
**Trong Tab Accountant:**
- Vào `/accountant/dashboard`
- Tìm payment request vừa tạo → Click **"Duyệt"** → Xác nhận

### Bước 4: Kiểm tra Notification
**Trong Tab Consultant:**
- ✅ **Toast popup** xuất hiện ở góc trên phải: "Thanh toán đã được duyệt"
- ✅ **Badge count** trên icon chuông tăng
- ✅ Click icon chuông → Thấy notification trong section "Duyệt thanh toán"
- ✅ Console log: `[WebSocket] Received USER notification`

---

## Checklist nhanh

- [ ] Consultant tạo payment request → Status = PENDING
- [ ] Accountant thấy payment trong dashboard
- [ ] Accountant duyệt → Backend log: "Sent payment confirmation notification"
- [ ] Consultant nhận toast notification
- [ ] Consultant thấy notification trong dropdown
- [ ] Badge count tăng

---

## Nếu không hoạt động

1. **Kiểm tra WebSocket connection:**
   - Console có log: `[WebSocket] Connected`?
   - Console có log: `Subscribing to user notifications`?

2. **Kiểm tra Backend log:**
   - Có log: `[InvoiceService] Sent payment confirmation notification`?
   - Nếu không có → Kiểm tra `payment.getCreatedBy()` có null không?

3. **Kiểm tra Network:**
   - F12 → Network → Filter: WS
   - Có connection đến `ws://localhost:8080/ws`?
   - Có message đến `/topic/notifications/{userId}`?

---

## SQL để kiểm tra nhanh

```sql
-- Xem payment requests đang PENDING
SELECT ph.*, u.fullName AS createdByName 
FROM payment_history ph
LEFT JOIN employees e ON ph.createdBy = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE ph.confirmationStatus = 'PENDING'
ORDER BY ph.createdAt DESC LIMIT 5;

-- Xem notifications của Consultant
SELECT * FROM notifications n
JOIN users u ON n.userId = u.userId
JOIN roles r ON u.roleId = r.roleId
WHERE r.roleName = 'Consultant'
ORDER BY n.createdAt DESC LIMIT 5;
```

