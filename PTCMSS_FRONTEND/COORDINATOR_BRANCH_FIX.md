# Fix Branch Loading in CoordinatorTimelinePro

## Vấn đề
Không tải được đơn hàng của chi nhánh TP. HCM mặc dù vừa mới tạo xong.

## Root Cause
Hàm `extractBranchItems` parse response không đúng thứ tự, dẫn đến không extract được branches từ API response.

### Backend Response Structure
```json
{
  "status": 200,
  "message": "Get all branches successfully",
  "data": {
    "items": [
      {
        "id": 3,
        "branchName": "Chi nhánh TP. HCM",
        "location": "...",
        "status": "ACTIVE"
      }
    ]
  }
}
```

### Code Issue (Trước khi sửa)
```javascript
const extractBranchItems = (payload) => {
    if (!payload) return [];
    if (Array.isArray(payload.items)) return payload.items;  // ❌ Tìm items trước
    if (Array.isArray(payload.data)) return payload.data;    // ❌ Tìm data sau
    // ...
};
```

**Vấn đề:** Code tìm `payload.items` trước, nhưng data nằm trong `payload.data.items`.

## Giải pháp

### 1. Sửa thứ tự parse trong `extractBranchItems`
```javascript
const extractBranchItems = (payload) => {
    if (!payload) return [];
    // ✅ Try data.items first (current backend format)
    if (payload.data?.items && Array.isArray(payload.data.items)) 
        return payload.data.items;
    // Then try other formats
    if (Array.isArray(payload.items)) return payload.items;
    if (payload.data?.content && Array.isArray(payload.data.content)) 
        return payload.data.content;
    // ...
};
```

### 2. Thêm console.log để debug
```javascript
console.log("[CoordinatorTimelinePro] Branches API response:", res);
console.log("[CoordinatorTimelinePro] Extracted raw items:", rawItems);
console.log("[CoordinatorTimelinePro] Mapped branch options:", options);
```

## Testing

### Test Case 1: Admin Login
1. Login as Admin
2. Open Coordinator Timeline page
3. Check Console logs:
   ```
   [CoordinatorTimelinePro] Loading all branches for Admin...
   [CoordinatorTimelinePro] Branches API response: { data: { items: [...] } }
   [CoordinatorTimelinePro] Extracted raw items: [{ id: 1, ... }, { id: 3, ... }]
   [CoordinatorTimelinePro] Mapped branch options: [{ id: "1", name: "..." }, { id: "3", name: "Chi nhánh TP. HCM" }]
   ```
4. Check UI: Dropdown hiển thị tất cả chi nhánh bao gồm "Chi nhánh TP. HCM"

### Test Case 2: Manager Login (Chi nhánh TP. HCM)
1. Login as Manager của chi nhánh TP. HCM
2. Open Coordinator Timeline page
3. Check Console: `[CoordinatorTimelinePro] Branch response: { id: 3, branchName: "Chi nhánh TP. HCM" }`
4. Check UI: Hiển thị "Chi nhánh TP. HCM" (readonly)

### Test Case 3: Load Dashboard Data
1. Select "Chi nhánh TP. HCM" from dropdown
2. Check Console: `[CoordinatorTimelinePro] Fetching dashboard for branch: 3`
3. Check UI: Hiển thị đơn hàng, tài xế, xe của chi nhánh TP. HCM

## Related Issues

### Issue 1: Đơn hàng mới tạo không hiển thị
**Nguyên nhân:** Đơn hàng có `status != "PENDING"` hoặc `branchId` không khớp

**Kiểm tra:**
```sql
SELECT id, code, status, branchId, pickupTime 
FROM bookings 
WHERE branchId = 3 AND status = 'PENDING';
```

### Issue 2: Dashboard trả về empty
**Nguyên nhân:** 
- Không có tài xế/xe được gán cho chi nhánh TP. HCM
- Không có đơn PENDING trong ngày được chọn

**Kiểm tra:**
```sql
-- Check drivers
SELECT * FROM drivers WHERE branchId = 3;

-- Check vehicles  
SELECT * FROM vehicles WHERE branchId = 3;

-- Check pending trips
SELECT * FROM trips WHERE branchId = 3 AND status = 'PENDING';
```

## API Endpoints

### GET /api/branches?page=0&size=100
**Response:**
```json
{
  "status": 200,
  "data": {
    "items": [
      { "id": 1, "branchName": "Chi nhánh Hà Nội", "status": "ACTIVE" },
      { "id": 3, "branchName": "Chi nhánh TP. HCM", "status": "ACTIVE" }
    ]
  }
}
```

### GET /api/branches/by-user/{userId}
**Response:**
```json
{
  "id": 3,
  "branchName": "Chi nhánh TP. HCM",
  "location": "...",
  "managerId": 4,
  "status": "ACTIVE"
}
```

### GET /api/dispatch/dashboard?branchId=3&date=2025-11-25
**Response:**
```json
{
  "pendingTrips": [...],
  "driverSchedules": [...],
  "vehicleSchedules": [...]
}
```

## Recommendations

1. **Reload trang sau khi sửa** - Clear cache nếu cần
2. **Check Console logs** - Xem data có được parse đúng không
3. **Verify database** - Đảm bảo đơn hàng có `branchId = 3` và `status = 'PENDING'`
4. **Check user permissions** - Manager phải được gán đúng chi nhánh

## Files Changed
- `PTCMSS_FRONTEND/src/components/module 5/CoordinatorTimelinePro.jsx`
  - Fixed `extractBranchItems` function
  - Added debug console.logs
