# Coordinator Timeline - Troubleshooting Guide

## Vấn đề: Đơn hàng không hiển thị trong Queue

### Checklist

#### 1. ✅ Đơn hàng đã được tạo thành công
**Kiểm tra:**
- WebSocket notification: "Đơn hàng ORD-XX đã được tạo thành công"
- Toast message: "Đã tạo đơn hàng #XX"
- Console log: `📤 Creating booking: { status: "PENDING", ... }`

**Ví dụ từ log:**
```
[WebSocket] Received booking update: {
  type: 'BOOKING_UPDATE', 
  message: 'Đơn hàng ORD-16 đã được tạo thành công', 
  bookingId: 16, 
  status: 'CREATED'
}
```
✅ Đơn ORD-16 đã được tạo thành công!

#### 2. ⚠️ Ngày pickup có khớp với ngày đang chọn không?
**Vấn đề phổ biến:**
- Tạo đơn với pickup time: **2025-11-26** 08:00
- Coordinator Timeline đang chọn: **2025-11-25**
- → Đơn không hiển thị!

**Giải pháp:**
1. Check ngày pickup khi tạo đơn
2. Chọn đúng ngày trong Coordinator Timeline
3. Click nút **"Refresh"** (màu xanh lá)

#### 3. ✅ Status phải đúng
**Backend filter:**
```java
// Trip status
trip.status = SCHEDULED ✅

// Booking status (một trong các status sau)
booking.status IN (
  PENDING,      ✅ Đã sửa CreateOrderPage
  CONFIRMED,
  QUOTATION_SENT,
  INPROGRESS,
  COMPLETED
)
```

#### 4. ⚠️ Trip chưa được gán driver/vehicle
**Backend logic:**
```java
// Chỉ hiển thị trips CHƯA gán
if (!tripDrivers.isEmpty() || !tripVehicles.isEmpty()) {
    continue; // Skip - đã gán rồi
}
```

**Nếu đơn đã gán driver/vehicle → Không hiển thị trong Queue nữa!**

#### 5. ✅ Chi nhánh phải khớp
**Kiểm tra:**
- Đơn ORD-16 có `branchId = 3` (TP. HCM)
- Coordinator Timeline đang chọn chi nhánh: **Chi nhánh TP. HCM**
- → Phải khớp!

## Các bước debug

### Bước 1: Kiểm tra Console Logs
```javascript
// Khi tạo đơn
📤 Creating booking: {
  status: "PENDING",
  branchId: 3,
  trips: [{
    startTime: "2025-11-25T08:00:00Z",
    ...
  }]
}

// Khi load dashboard
[CoordinatorTimelinePro] Fetching dashboard for branch: 3 date: 2025-11-25
[CoordinatorTimelinePro] Dashboard payload: {
  pendingTrips: Array(0),  // ❌ Rỗng!
  driverSchedules: Array(2),
  vehicleSchedules: Array(1)
}
```

### Bước 2: Test API trực tiếp
Chạy trong Console:
```javascript
fetch('http://localhost:8080/api/dispatch/dashboard?branchId=3&date=2025-11-25', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem("access_token")}`,
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => {
  console.log("✅ Dashboard Response:", data);
  console.log("Pending trips:", data.pendingTrips);
  
  if (!data.pendingTrips || data.pendingTrips.length === 0) {
    console.warn("⚠️ No pending trips found!");
    console.log("Possible reasons:");
    console.log("1. Trip startTime not in date range");
    console.log("2. Trip already assigned");
    console.log("3. Booking status not in DISPATCHABLE list");
  }
})
.catch(err => console.error("❌ Error:", err));
```

### Bước 3: Kiểm tra Database
```sql
-- Check booking vừa tạo
SELECT 
  b.id,
  b.code,
  b.status AS booking_status,
  b.branch_id,
  t.id AS trip_id,
  t.status AS trip_status,
  t.start_time,
  (SELECT COUNT(*) FROM trip_drivers WHERE trip_id = t.id) AS driver_count,
  (SELECT COUNT(*) FROM trip_vehicles WHERE trip_id = t.id) AS vehicle_count
FROM bookings b
LEFT JOIN trips t ON t.booking_id = b.id
WHERE b.code = 'ORD-16';
```

**Expected result:**
```
| id | code    | booking_status | branch_id | trip_id | trip_status | start_time          | driver_count | vehicle_count |
|----|---------|----------------|-----------|---------|-------------|---------------------|--------------|---------------|
| 16 | ORD-16  | PENDING        | 3         | 25      | SCHEDULED   | 2025-11-25 08:00:00 | 0            | 0             |
```

**Nếu:**
- `booking_status != PENDING` → ❌ Sửa CreateOrderPage
- `trip_status != SCHEDULED` → ❌ Bug backend
- `start_time` không phải 2025-11-25 → ⚠️ Chọn đúng ngày
- `driver_count > 0` hoặc `vehicle_count > 0` → ⚠️ Đã gán rồi

### Bước 4: Check Backend Logs
```
[Dispatch] Loading pending trips for branch 3 from 2025-11-25T00:00:00Z to 2025-11-26T00:00:00Z
[Dispatch] Found 0 pending trips
```

Nếu thấy "Found 0 pending trips" → Backend filter đang loại bỏ trip.

## Giải pháp nhanh

### 1. Click nút "Refresh" (Đã thêm)
- Nút màu xanh lá bên cạnh "Now"
- Reload dashboard mà không cần refresh trang

### 2. Chọn đúng ngày
- Kiểm tra ngày pickup khi tạo đơn
- Chọn đúng ngày trong date picker

### 3. Kiểm tra chi nhánh
- Đảm bảo đang chọn đúng chi nhánh
- Manager chỉ thấy chi nhánh của mình

### 4. WebSocket auto-refresh (Future enhancement)
Thêm listener để tự động refresh khi có đơn mới:
```javascript
// In CoordinatorTimelinePro
React.useEffect(() => {
  const handleBookingUpdate = (event) => {
    if (event.type === 'BOOKING_UPDATE' && event.status === 'CREATED') {
      // Auto refresh dashboard
      if (branchId) {
        fetchData(branchId, date);
      }
    }
  };
  
  window.addEventListener('booking-update', handleBookingUpdate);
  return () => window.removeEventListener('booking-update', handleBookingUpdate);
}, [branchId, date, fetchData]);
```

## Common Scenarios

### Scenario 1: Đơn hiển thị rồi biến mất
**Nguyên nhân:** Đã gán driver/vehicle
**Giải pháp:** Đúng behavior - đơn đã được xử lý

### Scenario 2: Đơn không bao giờ hiển thị
**Nguyên nhân:** 
- Ngày pickup khác ngày đang chọn
- Status không đúng
- Chi nhánh không khớp

**Giải pháp:** Check database và logs

### Scenario 3: Đơn hiển thị nhưng không gán được
**Nguyên nhân:** 
- Không có driver/vehicle available
- Conflict với chuyến khác

**Giải pháp:** Check availability trong suggestions

## Testing Workflow

1. **Tạo đơn mới:**
   - Branch: Chi nhánh TP. HCM (ID: 3)
   - Pickup: 2025-11-25 08:00
   - Status: PENDING

2. **Mở Coordinator Timeline:**
   - Select: Chi nhánh TP. HCM
   - Date: 2025-11-25
   - Click "Refresh"

3. **Expected:**
   - Queue panel: "1 đơn"
   - Thấy ORD-16 trong danh sách
   - Click "Gán chuyến" → Chọn driver/vehicle → Success

4. **After assign:**
   - Đơn biến mất khỏi Queue
   - Hiển thị trong Gantt timeline
   - Status → CONFIRMED

## Files Changed
- `PTCMSS_FRONTEND/src/components/module 5/CoordinatorTimelinePro.jsx` - Added Refresh button
- `PTCMSS_FRONTEND/src/components/module 4/CreateOrderPage.jsx` - Changed status to PENDING
