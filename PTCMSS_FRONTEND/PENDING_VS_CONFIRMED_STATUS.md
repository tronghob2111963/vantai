# Pending vs Confirmed Status Issue

## Vấn đề
Đơn hàng vừa tạo không hiển thị trong Coordinator Timeline Queue.

## Root Cause
**Mismatch giữa status khi tạo đơn và status mà Coordinator filter:**

### CreateOrderPage
- **Lưu nháp** → `status: "PENDING"` ✅
- **Đặt đơn** → `status: "CONFIRMED"` ❌

### CoordinatorTimeline
- Chỉ hiển thị đơn có `status: "PENDING"` trong Queue
- Không hiển thị đơn `CONFIRMED`

## Workflow Logic

### Current Flow (Có vấn đề)
```
1. Consultant tạo đơn → Click "Đặt đơn" → status: CONFIRMED
2. Coordinator mở Timeline → Không thấy đơn (vì filter PENDING)
3. ❌ Coordinator không thể gán tài xế/xe
```

### Expected Flow (Đúng)
```
1. Consultant tạo đơn → Click "Đặt đơn" → status: PENDING
2. Coordinator mở Timeline → Thấy đơn trong Queue
3. Coordinator gán tài xế/xe → status: CONFIRMED
4. ✅ Đơn biến mất khỏi Queue (đã được xử lý)
```

## Giải pháp

### Option 1: Sửa CreateOrderPage (Recommended)
**Thay đổi:** Khi "Đặt đơn" → Tạo `status: "PENDING"` thay vì `"CONFIRMED"`

**Lý do:**
- Đơn mới tạo chưa có tài xế/xe → Cần Coordinator gán
- PENDING = Chờ điều phối
- CONFIRMED = Đã gán xong tài xế/xe

**Code change:**
```javascript
// BEFORE
status: "CONFIRMED"

// AFTER  
status: "PENDING" // Coordinator sẽ gán driver/vehicle sau
```

**Impact:**
- ✅ Đơn mới sẽ hiện trong Coordinator Queue
- ✅ Workflow đúng: Consultant tạo → Coordinator gán → Status CONFIRMED
- ⚠️ Cần update message: "Đơn đang chờ điều phối gán xe/tài xế"

### Option 2: Sửa CoordinatorTimeline
**Thay đổi:** Hiển thị cả đơn `PENDING` và `CONFIRMED` trong Queue

**Lý do:**
- Cho phép Coordinator xem/re-assign đơn đã confirmed
- Linh hoạt hơn

**Code change:**
```javascript
// Backend: GET /api/dispatch/dashboard
// Filter: status IN ('PENDING', 'CONFIRMED') 
// Thay vì chỉ: status = 'PENDING'
```

**Impact:**
- ✅ Hiển thị nhiều đơn hơn
- ⚠️ Queue có thể đông hơn
- ⚠️ Cần phân biệt đơn nào đã gán, đơn nào chưa

### Option 3: Thêm status "AWAITING_ASSIGNMENT"
**Thay đổi:** Tạo status mới cho đơn chờ gán

**Status flow:**
```
PENDING → AWAITING_ASSIGNMENT → CONFIRMED → IN_PROGRESS → COMPLETED
```

**Impact:**
- ✅ Rõ ràng hơn
- ⚠️ Cần update nhiều chỗ (backend, frontend, database)

## Recommendation

**Chọn Option 1** - Đơn giản nhất và đúng workflow:

1. ✅ Đã sửa: `CreateOrderPage` → "Đặt đơn" tạo `status: "PENDING"`
2. Workflow:
   - Consultant tạo đơn → PENDING
   - Coordinator gán driver/vehicle → CONFIRMED
   - Driver nhận chuyến → IN_PROGRESS
   - Hoàn thành → COMPLETED

## Testing

### Test Case 1: Tạo đơn mới
1. Login as Consultant
2. Tạo đơn hàng mới cho chi nhánh TP. HCM
3. Click "Đặt đơn"
4. Check Console: `status: "PENDING"`
5. ✅ Expected: Toast "Đơn đang chờ điều phối gán xe/tài xế"

### Test Case 2: Coordinator thấy đơn
1. Login as Coordinator/Manager
2. Mở Coordinator Timeline
3. Select chi nhánh TP. HCM
4. Check Queue panel
5. ✅ Expected: Thấy đơn vừa tạo trong Queue

### Test Case 3: Gán tài xế/xe
1. Click "Gán chuyến" trên đơn
2. Chọn tài xế và xe
3. Click "Gán"
4. ✅ Expected: 
   - Đơn biến mất khỏi Queue
   - Status → CONFIRMED
   - Tài xế/xe được gán

## Status Definitions

| Status | Meaning | Who can see | Actions |
|--------|---------|-------------|---------|
| PENDING | Chờ điều phối | Coordinator | Gán driver/vehicle |
| CONFIRMED | Đã gán xong | Driver, Coordinator | Bắt đầu chuyến |
| IN_PROGRESS | Đang thực hiện | Driver, Customer | Cập nhật tiến độ |
| COMPLETED | Hoàn thành | All | Xem lịch sử |
| CANCELLED | Đã hủy | All | Xem lý do |

## Related Files
- `PTCMSS_FRONTEND/src/components/module 4/CreateOrderPage.jsx` - Tạo đơn
- `PTCMSS_FRONTEND/src/components/module 5/CoordinatorTimelinePro.jsx` - Điều phối
- Backend: `BookingController.java`, `DispatchController.java`

## Database Schema
```sql
-- Bookings table
CREATE TABLE bookings (
  id BIGINT PRIMARY KEY,
  status VARCHAR(50) NOT NULL, -- PENDING, CONFIRMED, IN_PROGRESS, COMPLETED, CANCELLED
  branch_id BIGINT NOT NULL,
  -- ...
);

-- Check current bookings
SELECT id, code, status, branch_id, created_at 
FROM bookings 
WHERE branch_id = 3 
ORDER BY created_at DESC 
LIMIT 10;
```
