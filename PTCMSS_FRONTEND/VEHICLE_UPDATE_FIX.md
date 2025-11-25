# Vehicle Update 400 Error Fix

## Vấn đề
Lỗi 400 Bad Request khi cập nhật thông tin xe.

## Root Cause
**Field name mismatch** giữa frontend và backend:

### Frontend (Trước khi sửa) - snake_case
```javascript
const payload = {
    branch_id: branchId,        // ❌
    category_id: categoryId,    // ❌
    year: Number(year),         // ❌
    reg_due_date: regDueDate,   // ❌
    ins_due_date: insDueDate,   // ❌
};
```

### Backend Expected - camelCase
```java
@Data
public class VehicleRequest {
    @NotNull
    private Integer branchId;           // ✅
    
    @NotNull
    private Integer categoryId;         // ✅
    
    private Integer productionYear;     // ✅
    private LocalDate inspectionExpiry; // ✅
    private LocalDate insuranceExpiry;  // ✅
    private String status;
    private String model;
}
```

## Giải pháp

### Sửa payload trong EditVehicleModal
```javascript
const payload = {
    branchId: Number(branchId),              // ✅ camelCase
    categoryId: Number(categoryId),          // ✅ camelCase
    status,
    model: model.trim() || null,
    productionYear: year ? Number(year) : null,     // ✅ Đổi tên field
    inspectionExpiry: regDueDate || null,           // ✅ Đổi tên field
    insuranceExpiry: insDueDate || null,            // ✅ Đổi tên field
};
```

## Field Mapping Table

| Frontend State | Old Payload Key | New Payload Key | Backend Field | Type |
|----------------|-----------------|-----------------|---------------|------|
| `branchId` | `branch_id` ❌ | `branchId` ✅ | `branchId` | Integer (required) |
| `categoryId` | `category_id` ❌ | `categoryId` ✅ | `categoryId` | Integer (required) |
| `year` | `year` ❌ | `productionYear` ✅ | `productionYear` | Integer |
| `regDueDate` | `reg_due_date` ❌ | `inspectionExpiry` ✅ | `inspectionExpiry` | LocalDate |
| `insDueDate` | `ins_due_date` ❌ | `insuranceExpiry` ✅ | `insuranceExpiry` | LocalDate |
| `status` | `status` ✅ | `status` ✅ | `status` | String |
| `model` | `model` ✅ | `model` ✅ | `model` | String |

## Changes Made

### File: `VehicleListPage.jsx`

**Before:**
```javascript
const payload = {
    branch_id: branchId,
    category_id: categoryId,
    status,
    model: model.trim(),
    year: Number(year),
    reg_due_date: regDueDate || null,
    ins_due_date: insDueDate || null,
};
```

**After:**
```javascript
const payload = {
    branchId: Number(branchId),
    categoryId: Number(categoryId),
    status,
    model: model.trim() || null,
    productionYear: year ? Number(year) : null,
    inspectionExpiry: regDueDate || null,
    insuranceExpiry: insDueDate || null,
};
```

## Testing

### Test Case 1: Update vehicle status
1. Open Vehicle List page
2. Click "Chi tiết" on any vehicle
3. Change status from "AVAILABLE" to "MAINTENANCE"
4. Click "Lưu"
5. ✅ Expected: Success toast "Lưu thay đổi cho xe X"

### Test Case 2: Update branch
1. Open edit modal
2. Change branch from "Chi nhánh Hà Nội" to "Chi nhánh TP. HCM"
3. Click "Lưu"
4. ✅ Expected: Vehicle updated successfully

### Test Case 3: Update inspection expiry
1. Open edit modal
2. Set "Hạn đăng kiểm": 2025-12-31
3. Click "Lưu"
4. ✅ Expected: Date saved correctly

### Test Case 4: Validation
1. Open edit modal
2. Clear required fields (branch, category)
3. Click "Lưu"
4. ✅ Expected: Error "Thiếu thông tin bắt buộc"

## API Endpoint

### PUT /api/vehicles/{id}

**Request Body:**
```json
{
  "branchId": 3,
  "categoryId": 1,
  "status": "MAINTENANCE",
  "model": "Toyota Hiace",
  "productionYear": 2020,
  "inspectionExpiry": "2025-12-31",
  "insuranceExpiry": "2025-11-30"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Cập nhật xe thành công",
  "data": {
    "id": 5,
    "licensePlate": "30G-123.45",
    "branchId": 3,
    "branchName": "Chi nhánh TP. HCM",
    "categoryId": 1,
    "categoryName": "Xe 4 chỗ",
    "status": "MAINTENANCE",
    ...
  }
}
```

**Response (Error - Before fix):**
```json
{
  "success": false,
  "message": "Lỗi khi cập nhật xe: Branch ID is required"
}
```

## Related Issues

### Issue 1: Similar problems in other modules
Cần kiểm tra các module khác có dùng snake_case không:
- ✅ CreateOrderPage - Đã sửa (branchId)
- ⚠️ DriverListPage - Cần kiểm tra
- ⚠️ BookingListPage - Cần kiểm tra

### Issue 2: Response mapping
Khi nhận response từ backend, cũng cần map ngược lại:
```javascript
const mapVehicle = (raw) => ({
    id: raw.id,
    license_plate: raw.licensePlate,
    branch_id: raw.branchId,
    category_id: raw.categoryId,
    year: raw.productionYear,
    reg_due_date: raw.inspectionExpiry,
    ins_due_date: raw.insuranceExpiry,
    // ...
});
```

## Best Practices

### 1. Consistent naming convention
- **Backend:** Always use camelCase (Java convention)
- **Frontend:** Use camelCase when sending to API
- **Frontend internal:** Can use snake_case for state, but convert when sending

### 2. Type conversion
```javascript
// Always convert to correct types
branchId: Number(branchId),        // String → Number
categoryId: Number(categoryId),    // String → Number
productionYear: year ? Number(year) : null,  // Handle empty
```

### 3. Null handling
```javascript
// Use null for optional fields, not empty string
model: model.trim() || null,
inspectionExpiry: regDueDate || null,
```

### 4. Validation
```javascript
// Validate before sending
if (!branchId || !categoryId) {
    setError("Thiếu thông tin bắt buộc");
    return;
}
```

## Files Changed
- `PTCMSS_FRONTEND/src/components/module 3/VehicleListPage.jsx`
  - Fixed `handleSubmit` in `EditVehicleModal`
  - Changed field names from snake_case to camelCase
  - Added proper type conversion
