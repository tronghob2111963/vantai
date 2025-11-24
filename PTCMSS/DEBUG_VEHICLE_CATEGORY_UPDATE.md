# Debug Vehicle Category Update Issue

## Vấn đề
Khi click button "Sửa / Xoá" trong trang Quản lý danh mục xe:
- Toast hiển thị "Cập nhật thành công"
- Nhưng giao diện không thay đổi
- Modal không mở

## Các bước debug

### 1. Kiểm tra Console Browser
Mở DevTools (F12) → Console tab và thực hiện:

1. Click button "Sửa / Xoá"
2. Xem log:
   ```
   [EDIT] Opening modal for category: {...}
   ```
3. Nếu không thấy log này → Button onClick không hoạt động
4. Nếu thấy log → Modal không render hoặc CSS ẩn modal

### 2. Kiểm tra Modal State
Trong console, sau khi click "Sửa / Xoá", kiểm tra:
- `editOpen` phải là `true`
- `editData` phải chứa data của category

### 3. Kiểm tra Network Tab
1. Mở DevTools → Network tab
2. Click "Sửa / Xoá" để mở modal
3. Thay đổi thông tin và click "Lưu thay đổi"
4. Xem request:
   - Method: PUT
   - URL: `/api/vehicle-categories/{id}`
   - Status: 200 OK
   - Response body: Phải chứa data đã update

### 4. Kiểm tra Update Logic
Sau khi click "Lưu thay đổi", xem console logs:

```
[UPDATE] Sending update request: {...}
[UPDATE] Response: {...}
[UPDATE] Mapped result: {...}
[UPDATE] Updated categories: [...]
```

**Kiểm tra**:
- Response có đúng format không?
- Mapped result có đầy đủ fields không?
- Updated categories có chứa item đã update không?

### 5. Kiểm tra Backend Response Format
Response từ backend phải có format:
```json
{
  "id": 1,
  "categoryName": "Xe 7 chỗ",
  "seats": 7,
  "description": "...",
  "baseFare": 800000,
  "pricePerKm": 15000,
  "highwayFee": 100000,
  "fixedCosts": 0,
  "status": "ACTIVE",
  "vehicles_count": 5
}
```

## Các nguyên nhân có thể

### 1. Modal không mở
**Nguyên nhân**:
- `editOpen` state không được set
- `editData` null hoặc undefined
- Modal component có bug

**Giải pháp**:
- Kiểm tra console log `[EDIT] Opening modal`
- Kiểm tra `VehicleCategoryEditModal` component
- Kiểm tra condition `if (!open || !data) return null;`

### 2. API response không đúng format
**Nguyên nhân**:
- Backend trả về format khác
- Missing fields trong response
- Field names không match

**Giải pháp**:
- Kiểm tra Network tab → Response
- So sánh với expected format
- Update `mapCat` function nếu cần

### 3. State không update
**Nguyên nhân**:
- `setCategories` không được gọi
- Map function không match ID
- React không re-render

**Giải pháp**:
- Kiểm tra console log `[UPDATE] Updated categories`
- Verify ID matching: `i.id === cat.id`
- Force re-render bằng cách thêm key prop

### 4. Toast hiển thị nhưng không có API call
**Nguyên nhân**:
- Code logic sai
- Try-catch block catch error nhưng vẫn show success toast
- Mock data đang được dùng

**Giải pháp**:
- Kiểm tra Network tab xem có request không
- Kiểm tra code trong `handleSaved`
- Xóa mock data nếu có

## Fix đã thực hiện

### 1. Thêm logging
```javascript
async function handleSaved(cat) {
    try {
        console.log("[UPDATE] Sending update request:", cat);
        const result = await updateVehicleCategory(cat.id, {...});
        
        console.log("[UPDATE] Response:", result);
        const mapped = mapCat(result);
        console.log("[UPDATE] Mapped result:", mapped);
        
        setCategories((arr) => {
            const updated = arr.map((i) => (i.id === cat.id ? mapped : i));
            console.log("[UPDATE] Updated categories:", updated);
            return updated;
        });
        
        pushToast("Cập nhật thành công", "success");
    } catch (e) {
        console.error("[UPDATE] Error:", e);
        pushToast("Cập nhật thất bại: " + (e.message || "Unknown error"), "error");
    }
}
```

### 2. Thêm logging cho button click
```javascript
<button
    onClick={() => {
        console.log("[EDIT] Opening modal for category:", cat);
        setEditData(cat);
        setEditOpen(true);
    }}
>
    Sửa / Xoá
</button>
```

## Testing Steps

### Test 1: Modal mở
1. Refresh trang
2. Click "Sửa / Xoá" ở bất kỳ category nào
3. **Expected**: Modal mở với thông tin category
4. **Check console**: Phải thấy log `[EDIT] Opening modal`

### Test 2: Update category
1. Mở modal (Test 1)
2. Thay đổi tên category (ví dụ: "Xe 7 chỗ" → "Xe 7 chỗ VIP")
3. Click "Lưu thay đổi"
4. **Expected**: 
   - Modal đóng
   - Toast "Cập nhật thành công"
   - Tên category trong table thay đổi
5. **Check console**: Phải thấy tất cả logs `[UPDATE]`
6. **Check Network**: Phải thấy PUT request với status 200

### Test 3: Update pricing
1. Mở modal
2. Thay đổi "Giá cơ bản" (ví dụ: 800000 → 900000)
3. Click "Lưu thay đổi"
4. **Expected**: Update thành công
5. Mở lại modal → Verify giá đã thay đổi

### Test 4: Update status
1. Mở modal
2. Đổi trạng thái từ "Đang hoạt động" → "Ngưng sử dụng"
3. Click "Lưu thay đổi"
4. **Expected**: Status pill trong table thay đổi màu

## Common Issues & Solutions

### Issue 1: Modal không mở
```javascript
// Check if modal is rendered
console.log("editOpen:", editOpen);
console.log("editData:", editData);

// If editOpen is true but modal not visible, check CSS
// Modal might be hidden by z-index or display:none
```

**Solution**: Verify modal z-index (should be 999) và không bị parent element ẩn

### Issue 2: Update thành công nhưng UI không thay đổi
```javascript
// Check if ID matching works
setCategories((arr) => {
    console.log("Current categories:", arr);
    console.log("Looking for ID:", cat.id);
    const updated = arr.map((i) => {
        console.log("Comparing:", i.id, "===", cat.id, "?", i.id === cat.id);
        return i.id === cat.id ? mapped : i;
    });
    return updated;
});
```

**Solution**: 
- Verify ID type (number vs string)
- Use `Number(i.id) === Number(cat.id)` nếu cần
- Hoặc dùng `String(i.id) === String(cat.id)`

### Issue 3: Backend response missing fields
```javascript
// Check response structure
const result = await updateVehicleCategory(...);
console.log("Response keys:", Object.keys(result));
console.log("Expected keys:", ["id", "categoryName", "seats", "status", ...]);
```

**Solution**: Update `mapCat` function để handle missing fields:
```javascript
const mapCat = (c) => ({
    id: c.id,
    name: c.categoryName || c.name || "",
    status: c.status || "ACTIVE",
    seats: c.seats ?? 0,
    vehicles_count: c.vehicles_count ?? c.vehiclesCount ?? 0,
    description: c.description || "",
    baseFare: c.baseFare ?? null,
    pricePerKm: c.pricePerKm ?? null,
    highwayFee: c.highwayFee ?? null,
    fixedCosts: c.fixedCosts ?? null,
});
```

## Next Steps

1. **Chạy lại frontend** với logging đã thêm
2. **Mở DevTools Console** trước khi test
3. **Click "Sửa / Xoá"** và quan sát logs
4. **Thực hiện update** và quan sát logs + Network tab
5. **Report kết quả**:
   - Modal có mở không?
   - API call có được gọi không?
   - Response có đúng format không?
   - State có được update không?
   - UI có re-render không?

## Files Changed
- `PTCMSS_FRONTEND/src/components/module 3/VehicleCategoryManagePage.jsx`
  - Added logging in `handleSaved()`
  - Added logging in button onClick
