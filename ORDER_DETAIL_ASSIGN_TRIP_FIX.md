# Sửa lỗi Gán chuyến từ Chi tiết Đơn hàng

## Vấn đề

Khi click "Gán chuyến" từ trang chi tiết đơn hàng và bấm "Tự động gán", gặp lỗi:

```
Error: Không tìm thấy chuyến đi để phân công tự động
RuntimeException at DispatchServiceImpl.java:572
```

## Nguyên nhân

1. **Thiếu tripId**: Hàm `mapBookingToOrder` không map `trip.id` từ backend
2. **Thiếu branch_name**: Không có thông tin chi nhánh để hiển thị trong dialog
3. **Backend cần tripId**: API gán chuyến cần `tripId` để phân công, nhưng frontend không truyền

## Giải pháp đã thực hiện

### 1. Thêm tripId vào mapping

**File**: `vantai/PTCMSS_FRONTEND/src/components/module 4/OrderDetailPage.jsx`

```javascript
trip: {
    id: firstTrip.id || firstTrip.tripId || null,  // ✅ THÊM DÒNG NÀY
    pickup: firstTrip.startLocation || '',
    dropoff: firstTrip.endLocation || '',
    pickup_time: firstTrip.startTime || '',
    dropoff_eta: firstTrip.endTime || '',
    pax_count: 0,
    vehicle_category: vehicleCategory,
    vehicle_count: vehicleCount,
},
```

### 2. Thêm branch_name vào mapping

```javascript
notes_internal: b.note || '',
branch_name: b.branchName || b.branch?.name || '',  // ✅ THÊM DÒNG NÀY
```

### 3. Sử dụng AssignDriverDialog có sẵn

Thay thế component đơn giản bằng `AssignDriverDialog` từ module 5:

```javascript
import AssignDriverDialog from "../module 5/AssignDriverDialog";

// Trong render:
<AssignDriverDialog
    open={assignDialogOpen}
    order={{
        id: order.id,
        bookingId: order.id,
        tripId: order.trip?.id,  // ✅ Giờ có giá trị
        code: order.code,
        pickup_time: order.trip?.pickup_time,
        vehicle_type: order.trip?.vehicle_category,
        branch_name: order.branch_name,  // ✅ Giờ có giá trị
    }}
    onClose={() => setAssignDialogOpen(false)}
    onAssigned={handleAssignSuccess}
/>
```

## Lưu ý quan trọng

### Trường hợp đơn hàng chưa có trip

Nếu đơn hàng mới tạo chưa có trip (chưa confirm), `tripId` sẽ là `null`. Trong trường hợp này:

1. **Tự động gán** sẽ KHÔNG hoạt động (cần có tripId)
2. **Gán thủ công** có thể hoạt động nếu backend hỗ trợ gán trực tiếp cho booking

### Backend cần hỗ trợ

Backend cần có 2 flow:

**Flow 1: Gán cho trip đã tồn tại**
```
POST /api/v1/dispatch/assign
{
  "bookingId": 21,
  "tripIds": [123],  // Trip đã tồn tại
  "driverId": 5,
  "vehicleId": 10,
  "autoAssign": false
}
```

**Flow 2: Tạo trip và gán (nếu chưa có trip)**
```
POST /api/v1/dispatch/assign
{
  "bookingId": 21,
  "tripIds": null,  // Tự động tạo trip
  "driverId": 5,
  "vehicleId": 10,
  "autoAssign": false
}
```

## Kiểm tra

### 1. Kiểm tra tripId có được truyền không

Mở Console (F12) và xem log khi mở dialog:
```javascript
console.log("Order data:", order);
console.log("Trip ID:", order.trip?.id);
```

### 2. Kiểm tra API request

Trong Network tab, xem request body của API `/api/v1/dispatch/assign`:
```json
{
  "bookingId": 21,
  "tripIds": [123],  // ✅ Phải có giá trị
  "autoAssign": true
}
```

### 3. Test cases

**Case 1: Đơn hàng đã có trip**
- ✅ Tự động gán hoạt động
- ✅ Gán thủ công hoạt động
- ✅ Hiển thị gợi ý từ hệ thống

**Case 2: Đơn hàng chưa có trip**
- ❌ Tự động gán KHÔNG hoạt động (hiển thị lỗi rõ ràng)
- ⚠️ Gán thủ công: Tùy backend có hỗ trợ không
- ⚠️ Gợi ý: Có thể không có (vì chưa có trip)

## Cải tiến đề xuất

### 1. Hiển thị warning khi chưa có trip

```javascript
{!order.trip?.id && (
    <div className="rounded-lg border border-amber-200 bg-amber-50 p-3 text-amber-700 text-sm">
        ⚠️ Đơn hàng chưa có chuyến đi. Vui lòng xác nhận đơn hàng trước khi gán tài xế.
    </div>
)}
```

### 2. Disable button "Gán chuyến" khi chưa có trip

```javascript
<button
    onClick={openAssignDialog}
    disabled={!order.trip?.id}
    className="..."
>
    Gán chuyến
</button>
```

### 3. Tạo trip tự động khi gán

Backend có thể tự động tạo trip từ booking khi gán lần đầu:

```java
// DispatchServiceImpl.java
if (tripIds == null || tripIds.isEmpty()) {
    // Tự động tạo trip từ booking
    Trip trip = createTripFromBooking(bookingId);
    tripIds = List.of(trip.getId());
}
```

## Files Changed

- `vantai/PTCMSS_FRONTEND/src/components/module 4/OrderDetailPage.jsx`
  - Thêm `trip.id` vào mapping
  - Thêm `branch_name` vào mapping
  - Sử dụng `AssignDriverDialog` thay vì component đơn giản

## Kết quả

✅ Gán chuyến hoạt động khi đơn hàng đã có trip
✅ Hiển thị popup với gợi ý tự động
✅ Có 2 nút: "Tự động gán" và "Xác nhận gán chuyến"
✅ Hiển thị đầy đủ thông tin: thời gian, loại xe, chi nhánh
