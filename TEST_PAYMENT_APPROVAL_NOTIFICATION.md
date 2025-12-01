# Hướng dẫn Test: Thông báo Duyệt Payment Request cho Consultant

## Mục đích
Test chức năng: **Tư vấn viên (Consultant) nhận thông báo khi kế toán (Accountant) duyệt/từ chối payment request**

## Yêu cầu
- Backend đã được compile và chạy
- Frontend đã được build và chạy
- Database đã có dữ liệu test
- Có ít nhất 2 tài khoản:
  - 1 tài khoản **Consultant** (tư vấn viên)
  - 1 tài khoản **Accountant** (kế toán)

---

## Bước 1: Chuẩn bị dữ liệu

### 1.1. Tạo Booking và Invoice (nếu chưa có)
- Consultant đăng nhập và tạo một booking mới
- Booking phải có status = `CONFIRMED` hoặc `PENDING`
- Booking phải có invoice với payment status = `UNPAID`

### 1.2. Tạo Payment Request
- Consultant tạo payment request cho invoice đó
- Payment request có status = `PENDING`
- Ghi nhớ `paymentId` hoặc `invoiceId`

---

## Bước 2: Test Flow

### 2.1. Mở 2 trình duyệt (hoặc 2 tab)

**Tab 1: Consultant**
- Đăng nhập với tài khoản Consultant
- Mở Developer Console (F12) → Tab Console
- Mở trang bất kỳ (ví dụ: Dashboard hoặc Order List)
- Kiểm tra WebSocket connection:
  ```javascript
  // Trong Console, kiểm tra log:
  // [WebSocket] Connected
  // [WebSocket] Subscribing to user notifications for userId: {consultantUserId}
  ```

**Tab 2: Accountant**
- Đăng nhập với tài khoản Accountant
- Mở trang **Accountant Dashboard** (`/accountant/dashboard`)
- Tìm section **"Yêu cầu thanh toán chờ duyệt"** (Pending Payments)

---

## Bước 3: Consultant tạo Payment Request

### 3.1. Trong Tab Consultant:
1. Vào trang **Invoice Management** hoặc **Booking Detail**
2. Tìm invoice cần tạo payment request
3. Click **"Thêm thanh toán"** hoặc **"Record Payment"**
4. Điền thông tin:
   - **Amount**: Số tiền cần thanh toán
   - **Payment Method**: `CASH` hoặc `TRANSFER`
   - **Confirmation Status**: `PENDING` (mặc định)
   - **Note**: "Test payment request"
5. Click **"Lưu"** hoặc **"Submit"**

### 3.2. Kiểm tra:
- Payment request đã được tạo với status = `PENDING`
- Payment xuất hiện trong danh sách pending payments của Accountant

---

## Bước 4: Accountant duyệt Payment Request

### 4.1. Trong Tab Accountant:
1. Vào **Accountant Dashboard** (`/accountant/dashboard`)
2. Tìm payment request vừa tạo trong section **"Yêu cầu thanh toán chờ duyệt"**
3. Click nút **"Duyệt"** (màu xanh/amber)
4. Xác nhận duyệt trong dialog
5. Click **"Xác nhận"**

### 4.2. Kiểm tra Backend Log:
Trong backend console, bạn sẽ thấy:
```
[InvoiceService] Sent payment confirmation notification to consultant userId: {consultantUserId}
[InvoiceService] Sent payment update notification for invoice: {invoiceId}
```

---

## Bước 5: Kiểm tra Notification ở Consultant

### 5.1. Trong Tab Consultant:

#### A. Kiểm tra Toast Notification (Popup)
- **Tự động xuất hiện** ở góc trên bên phải màn hình
- Hiển thị:
  - **Title**: "Thanh toán đã được duyệt" (nếu duyệt) hoặc "Thanh toán đã bị từ chối" (nếu từ chối)
  - **Message**: "Yêu cầu thanh toán {amount} cho đơn #{bookingId} đã được duyệt"
  - **Icon**: CheckCircle (màu xanh) nếu duyệt, XCircle (màu đỏ) nếu từ chối
- **Tự động ẩn** sau 5 giây

#### B. Kiểm tra Badge Count
- Icon **chuông** (bell) ở header có **badge số** (màu đỏ)
- Badge count **tăng lên** khi có notification mới

#### C. Kiểm tra Notification Dropdown
1. Click vào icon **chuông** (bell) ở header
2. Tìm section **"Duyệt thanh toán"** (nếu có payment notifications)
3. Kiểm tra notification hiển thị:
   - **Icon**: CheckCircle (xanh) hoặc XCircle (đỏ)
   - **Title**: "Đã duyệt" hoặc "Đã từ chối"
   - **Message**: "Yêu cầu thanh toán {amount} cho đơn #{bookingId} đã được duyệt"
   - **Timestamp**: Thời gian nhận notification
4. Có thể:
   - Click **Check** để đánh dấu đã đọc
   - Click **X** để xóa notification

#### D. Kiểm tra Console Log
Trong Developer Console (F12), bạn sẽ thấy:
```javascript
[WebSocket] Received USER notification for userId {consultantUserId}: {
  id: ...,
  title: "Thanh toán đã được duyệt",
  message: "Yêu cầu thanh toán 1,000,000đ cho đơn #123 đã được duyệt",
  type: "PAYMENT_APPROVED",
  timestamp: "...",
  read: false
}
```

---

## Bước 6: Test Case - Từ chối Payment Request

### 6.1. Lặp lại Bước 3 để tạo payment request mới

### 6.2. Trong Tab Accountant:
1. Tìm payment request mới
2. Click nút **"Từ chối"** (màu đỏ)
3. Nhập lý do từ chối (nếu có)
4. Click **"Xác nhận"**

### 6.3. Kiểm tra ở Consultant:
- Toast notification hiển thị: **"Thanh toán đã bị từ chối"**
- Badge count tăng
- Notification trong dropdown có icon **XCircle** (màu đỏ)
- Message: "Yêu cầu thanh toán {amount} cho đơn #{bookingId} đã bị từ chối"

---

## Bước 7: Kiểm tra Edge Cases

### 7.1. Consultant offline khi Accountant duyệt
- Đóng tab Consultant
- Accountant duyệt payment request
- Mở lại tab Consultant và đăng nhập
- **Kỳ vọng**: Notification vẫn được lưu trong database và hiển thị khi Consultant đăng nhập lại

### 7.2. Multiple Payment Requests
- Consultant tạo nhiều payment requests
- Accountant duyệt từng cái một
- **Kỳ vọng**: Mỗi lần duyệt, Consultant nhận 1 notification riêng biệt

### 7.3. Payment Request không có Consultant
- Tạo payment request mà `createdBy` = null hoặc không có user
- Accountant duyệt
- **Kỳ vọng**: Không có lỗi, chỉ gửi payment update qua global channel

---

## Checklist Test

- [ ] Consultant tạo payment request thành công
- [ ] Payment request xuất hiện trong Accountant Dashboard
- [ ] Accountant duyệt payment request thành công
- [ ] Consultant nhận **toast notification** (popup tự động)
- [ ] Consultant nhận **badge count** tăng
- [ ] Consultant thấy notification trong **dropdown**
- [ ] Notification có đúng **icon, màu sắc, message**
- [ ] Consultant có thể **đánh dấu đã đọc** notification
- [ ] Consultant có thể **xóa** notification
- [ ] Test case **từ chối** payment request cũng hoạt động
- [ ] Console log hiển thị WebSocket messages đúng
- [ ] Backend log hiển thị notification đã được gửi

---

## Debug nếu không hoạt động

### 1. Kiểm tra WebSocket Connection
```javascript
// Trong Console (F12)
// Kiểm tra log:
[WebSocket] Connected
[WebSocket] Subscribing to user notifications for userId: {userId}
```

### 2. Kiểm tra Backend Log
- Xem log có dòng: `[InvoiceService] Sent payment confirmation notification to consultant userId: {userId}`
- Nếu không có, kiểm tra:
  - `payment.getCreatedBy()` có null không?
  - `payment.getCreatedBy().getUser()` có null không?
  - `payment.getCreatedBy().getUser().getId()` có giá trị không?

### 3. Kiểm tra Network Tab
- Mở Developer Tools → Network tab
- Filter: **WS** (WebSocket)
- Kiểm tra connection đến `ws://localhost:8080/ws`
- Kiểm tra message đến `/topic/notifications/{userId}`

### 4. Kiểm tra Database
```sql
-- Kiểm tra payment request đã được tạo
SELECT * FROM payment_history 
WHERE confirmationStatus = 'PENDING' 
ORDER BY createdAt DESC LIMIT 5;

-- Kiểm tra notification đã được lưu (nếu có)
SELECT * FROM notifications 
WHERE userId = {consultantUserId} 
ORDER BY createdAt DESC LIMIT 5;
```

### 5. Kiểm tra Frontend Filter
- Mở `NotificationsWidget.jsx`
- Kiểm tra filter cho Consultant có đúng không:
  ```javascript
  const paymentNotificationTypes = [
    'PAYMENT_APPROVED', 'PAYMENT_REJECTED', 
    'PAYMENT_REQUEST_APPROVED', 'PAYMENT_REQUEST_REJECTED',
    'PAYMENT_UPDATE'
  ];
  ```

---

## Kết quả mong đợi

✅ **Thành công**: Consultant nhận được notification ngay lập tức khi Accountant duyệt/từ chối payment request, hiển thị đầy đủ thông tin và có thể tương tác (đánh dấu đã đọc, xóa).

❌ **Thất bại**: Consultant không nhận được notification, hoặc notification không hiển thị đúng.

---

## Ghi chú

- Notification được gửi qua **WebSocket** nên cần connection ổn định
- Nếu Consultant offline, notification sẽ được lưu trong database và hiển thị khi đăng nhập lại
- Badge count chỉ đếm notifications **chưa đọc** (read = false)
- Toast notification tự động ẩn sau 5 giây

