# Xóa sidebar thanh toán cho Kế toán

## Vấn đề

Trong trang chi tiết đơn hàng, kế toán vẫn thấy sidebar bên phải hiển thị:
- Tình trạng thanh toán (Giá chốt, Đã thu, Còn lại)
- Nút "Ghi nhận thanh toán" (đã bị xóa trước đó)

Cần xóa hoàn toàn sidebar này cho kế toán.

## Giải pháp

Thêm check `isAccountant` và ẩn toàn bộ sidebar thanh toán, PaymentInfoCard, và các modal thanh toán cho role ACCOUNTANT.

## Chi tiết thay đổi

### File: `OrderDetailPage.jsx`

#### 1. Thêm check role Accountant

**Trước:**
```javascript
// Check role - ẩn phần thanh toán cho Consultant
const currentRole = React.useMemo(() => getCurrentRole(), []);
const isConsultant = currentRole === ROLES.CONSULTANT;
```

**Sau:**
```javascript
// Check role - ẩn phần thanh toán cho Consultant và Accountant
const currentRole = React.useMemo(() => getCurrentRole(), []);
const isConsultant = currentRole === ROLES.CONSULTANT;
const isAccountant = currentRole === ROLES.ACCOUNTANT;
```

#### 2. Ẩn sidebar thanh toán bên phải

**Trước:**
```javascript
{/* thanh toán summary box - ẩn với Consultant */}
{!isConsultant && (
    <div className="...">
        <div>Tình trạng thanh toán</div>
        <div>Giá chốt: {fmtVND(finalPrice)}</div>
        <div>Đã thu: {fmtVND(paid)}</div>
        <div>Còn lại: {fmtVND(remain)}</div>
    </div>
)}
```

**Sau:**
```javascript
{/* thanh toán summary box - ẩn với Consultant và Accountant */}
{!isConsultant && !isAccountant && (
    <div className="...">
        <div>Tình trạng thanh toán</div>
        <div>Giá chốt: {fmtVND(finalPrice)}</div>
        <div>Đã thu: {fmtVND(paid)}</div>
        <div>Còn lại: {fmtVND(remain)}</div>
    </div>
)}
```

#### 3. Ẩn PaymentInfoCard

**Trước:**
```javascript
<div className={`grid ${isConsultant ? 'xl:grid-cols-1' : 'xl:grid-cols-2'} gap-5 mb-5`}>
    <QuoteInfoCard quote={order.quote} />
    {!isConsultant && (
        <PaymentInfoCard
            payment={order.payment}
            history={paymentHistory}
            onOpenDeposit={openDeposit}
            onGenerateQr={openQrModal}
        />
    )}
</div>
```

**Sau:**
```javascript
<div className={`grid ${(isConsultant || isAccountant) ? 'xl:grid-cols-1' : 'xl:grid-cols-2'} gap-5 mb-5`}>
    <QuoteInfoCard quote={order.quote} />
    {!isConsultant && !isAccountant && (
        <PaymentInfoCard
            payment={order.payment}
            history={paymentHistory}
            onOpenDeposit={openDeposit}
            onGenerateQr={openQrModal}
        />
    )}
</div>
```

#### 4. Ẩn các modal thanh toán

**Trước:**
```javascript
{/* Payment modals - ẩn với Consultant */}
{!isConsultant && (
    <>
        <QrPaymentModal ... />
        <DepositModal ... />
    </>
)}
```

**Sau:**
```javascript
{/* Payment modals - ẩn với Consultant và Accountant */}
{!isConsultant && !isAccountant && (
    <>
        <QrPaymentModal ... />
        <DepositModal ... />
    </>
)}
```

## Kết quả

### Kế toán (ACCOUNTANT) xem chi tiết đơn hàng:

**Hiển thị:**
- ✅ Thông tin khách hàng
- ✅ Lịch trình (điểm đón, điểm đến, thời gian)
- ✅ Báo giá (giá gốc, giảm giá, giá cuối)
- ✅ Thông tin điều phối (tài xế, xe)
- ✅ Ghi chú nội bộ

**Không hiển thị:**
- ❌ Sidebar "Tình trạng thanh toán" bên phải
- ❌ Card "Thanh toán / Cọc" (PaymentInfoCard)
- ❌ Nút "Ghi nhận thanh toán"
- ❌ Nút "Tạo QR"
- ❌ Modal thanh toán
- ❌ Modal QR

### Các role khác (ADMIN, COORDINATOR):

**Vẫn hiển thị đầy đủ:**
- ✅ Sidebar thanh toán bên phải
- ✅ PaymentInfoCard với lịch sử thanh toán
- ✅ Nút "Ghi nhận thanh toán"
- ✅ Nút "Tạo QR"
- ✅ Các modal thanh toán

### Consultant (CONSULTANT):

**Cũng bị ẩn tương tự Accountant:**
- ❌ Không có sidebar thanh toán
- ❌ Không có PaymentInfoCard
- ❌ Không có các nút thanh toán

## Layout thay đổi

### Trước (có sidebar):
```
┌─────────────────────────────────────┬──────────────┐
│ Header (Đơn hàng ORD-4)             │ Sidebar      │
│                                     │ Thanh toán   │
├─────────────────────────────────────┤              │
│ Thông tin khách hàng | Lịch trình  │ Giá chốt     │
│                                     │ Đã thu       │
│ Báo giá | Thanh toán/Cọc           │ Còn lại      │
│                                     │              │
│ Điều phối | Ghi chú                 │ [Ghi nhận]   │
└─────────────────────────────────────┴──────────────┘
```

### Sau (không có sidebar cho Accountant):
```
┌─────────────────────────────────────┐
│ Header (Đơn hàng ORD-4)             │
│                                     │
├─────────────────────────────────────┤
│ Thông tin khách hàng | Lịch trình  │
│                                     │
│ Báo giá (full width)                │
│                                     │
│ Điều phối | Ghi chú                 │
└─────────────────────────────────────┘
```

## Testing

### Test Case 1: Kế toán xem chi tiết đơn hàng
1. Đăng nhập với tài khoản Kế toán
2. Vào "Danh sách đơn hàng" → Click "Chi tiết" một đơn
3. Kiểm tra:
   - ✅ Không có sidebar thanh toán bên phải
   - ✅ Không có card "Thanh toán / Cọc"
   - ✅ Card "Báo giá" hiển thị full width
   - ✅ Vẫn xem được thông tin khách hàng, lịch trình, điều phối
   - ❌ Không có nút "Ghi nhận thanh toán"
   - ❌ Không có nút "Tạo QR"

### Test Case 2: Coordinator vẫn có đầy đủ chức năng
1. Đăng nhập với tài khoản Coordinator
2. Vào chi tiết đơn hàng
3. Kiểm tra:
   - ✅ Có sidebar thanh toán bên phải
   - ✅ Có card "Thanh toán / Cọc" với lịch sử
   - ✅ Có nút "Ghi nhận thanh toán"
   - ✅ Có nút "Tạo QR"
   - ✅ Click được và mở modal

## Files đã thay đổi

1. `vantai/PTCMSS_FRONTEND/src/components/module 4/OrderDetailPage.jsx`
   - Thêm `isAccountant` check
   - Cập nhật điều kiện hiển thị sidebar: `{!isConsultant && !isAccountant && ...}`
   - Cập nhật điều kiện hiển thị PaymentInfoCard
   - Cập nhật điều kiện hiển thị modal thanh toán
   - Cập nhật grid layout để full width khi ẩn PaymentInfoCard

## Lưu ý

- Kế toán vẫn có thể xem thông tin báo giá (giá gốc, giảm giá, giá cuối) trong card "Báo giá"
- Nếu cần hiển thị thông tin thanh toán cho Kế toán nhưng không cho phép thao tác, có thể tạo một card riêng chỉ hiển thị thông tin (read-only)
- Hiện tại Consultant cũng bị ẩn các phần thanh toán tương tự Accountant
