# Field Mapping Fix - Branch ID Issue

## Vấn đề
Backend API trả về field `id` nhưng frontend code đang tìm `branchId`, dẫn đến `branchId` luôn `undefined`.

## Root Cause

### Backend Response Structure
```json
{
  "status": 200,
  "message": "Get all branches successfully",
  "data": {
    "items": [
      {
        "id": 1,                    // ❌ Backend trả về "id"
        "branchName": "Chi nhánh Hà Nội",
        "location": "...",
        "status": "ACTIVE"
      }
    ]
  }
}
```

### Frontend Code (Trước khi sửa)
```javascript
// ❌ Tìm branchId nhưng không tồn tại
setBranchId(String(branches[0].branchId));  // undefined!
```

## Giải pháp

### 1. Normalize field names khi parse response
```javascript
const normalizedBranches = branches.map(b => ({
    branchId: b.id || b.branchId,  // ✅ Map id -> branchId
    branchName: b.branchName,
    location: b.location,
    status: b.status
}));
```

### 2. Filter chỉ lấy ACTIVE branches
```javascript
branches = branches.filter(b => b && b.id && b.status === 'ACTIVE');
```

### 3. Đúng thứ tự parse response structure
```javascript
// ✅ Đúng thứ tự: items trước, content sau
let branches = branchesData?.data?.items ||      // Backend hiện tại
               branchesData?.items ||
               branchesData?.data?.content ||    // Fallback
               branchesData?.content ||
               [];
```

## Changes Made

### File: `CreateOrderPage.jsx`

#### Admin Branch Loading
```javascript
// BEFORE
const branches = branchesData?.data?.content || ...;
setBranchId(String(branches[0].branchId));  // undefined

// AFTER
const branches = branchesData?.data?.items || ...;
const normalizedBranches = branches.map(b => ({
    branchId: b.id || b.branchId,  // ✅ Works with both
    branchName: b.branchName
}));
setBranchId(String(normalizedBranches[0].branchId));  // ✅ Has value
```

#### Manager Branch Loading
```javascript
// BEFORE
setBranchId(String(branchData.branchId));  // undefined

// AFTER
const normalizedBranchId = branchData.id || branchData.branchId;
setBranchId(String(normalizedBranchId));  // ✅ Has value
```

## Testing

### Test Case 1: Admin Login
1. Login as Admin
2. Open Create Order page
3. Check Console: `✅ Set default branch: { branchId: "1", branchName: "..." }`
4. Check Debug Panel: `branchId: 1` (not "empty")
5. Check UI: Dropdown shows all ACTIVE branches

### Test Case 2: Manager Login
1. Login as Manager
2. Open Create Order page
3. Check Console: `✅ Set user branch: { branchId: "1", branchName: "..." }`
4. Check Debug Panel: `branchId: 1` (not "empty")
5. Check UI: Badge shows branch name

### Test Case 3: Create Booking
1. Fill all required fields
2. Click "Đặt đơn"
3. Check Console: `📤 Creating booking: { branchId: 1, ... }`
4. Check Response: Success (not 400 "ID chi nhánh không được để trống")

## API Response Formats Supported

### Format 1: Current Backend (items)
```json
{
  "data": {
    "items": [{ "id": 1, "branchName": "..." }]
  }
}
```

### Format 2: Paginated (content)
```json
{
  "data": {
    "content": [{ "id": 1, "branchName": "..." }]
  }
}
```

### Format 3: Direct Array
```json
{
  "data": [{ "id": 1, "branchName": "..." }]
}
```

### Format 4: Top-level Array
```json
[{ "id": 1, "branchName": "..." }]
```

## Backward Compatibility

Code vẫn hỗ trợ cả 2 field names:
- `id` (current backend)
- `branchId` (nếu backend thay đổi sau này)

```javascript
branchId: b.id || b.branchId  // ✅ Works with both
```

## Recommendations

### Option 1: Keep current code (Recommended)
- Frontend normalize field names
- Backward compatible
- No backend changes needed

### Option 2: Update backend (Optional)
Nếu muốn consistency, backend có thể trả về cả 2 fields:
```json
{
  "id": 1,
  "branchId": 1,  // Alias for frontend
  "branchName": "..."
}
```

## Related Files
- `PTCMSS_FRONTEND/src/components/module 4/CreateOrderPage.jsx`
- `PTCMSS_FRONTEND/src/api/branches.js`
- `PTCMSS/ptcmss-backend/.../BranchController.java`
