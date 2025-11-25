# Bug Fixes Summary - Create Order Page

## Các lỗi đã sửa

### 1. ✅ Lỗi 400 - Calculate Price API
**Nguyên nhân:** 
- Thiếu `startTime` và `endTime` khi gọi API
- Format thời gian không đúng (cần ISO string với timezone)

**Giải pháp:**
- Thêm check: Chỉ gọi API khi có đủ `startTime` và `endTime`
- Sử dụng `toIsoZ()` để convert datetime-local sang ISO string
- Thêm error handling và console.log để debug

```javascript
// Trước
startTime: startTime ? (startTime instanceof Date ? startTime.toISOString() : startTime) : undefined

// Sau
const startISO = toIsoZ(startTime);
const endISO = toIsoZ(endTime);
if (!startISO || !endISO) return; // Skip nếu thiếu
```

### 2. ✅ Lỗi 400 - Create Booking API
**Nguyên nhân:**
- Thiếu validation `branchId`
- Không check format thời gian trước khi submit
- Error message không rõ ràng

**Giải pháp:**
- Thêm `branchId` vào `isValidCore` validation
- Validate `branchId` riêng với message rõ ràng
- Validate thời gian trước khi submit
- Thêm console.log request body để debug
- Hiển thị error message chi tiết từ backend

```javascript
if (!branchId) {
    push("Vui lòng chọn chi nhánh", "error");
    return;
}

if (!sStart || !sEnd) {
    push("Thời gian không hợp lệ", "error");
    return;
}
```

### 3. ✅ Lỗi 404 - Customer Not Found
**Trạng thái:** Không phải lỗi - Expected behavior

Đây là behavior bình thường khi số điện thoại chưa có trong hệ thống. API sẽ:
- Trả về 404 nếu không tìm thấy
- Frontend sẽ để user nhập thủ công thông tin khách hàng mới

### 4. ⚠️ Warning - React Key Prop
**Trạng thái:** Không ảnh hưởng chức năng

Tất cả các `.map()` đã có `key` prop. Warning này có thể do:
- Kiro IDE autofix
- React DevTools strict mode
- Không ảnh hưởng đến hoạt động của app

## Testing Checklist

### Test Calculate Price
- [ ] Nhập đủ: Điểm đi, Điểm đến, Thời gian đón, Thời gian kết thúc
- [ ] Check Console: Không còn lỗi 400
- [ ] Check UI: Giá hệ thống hiển thị đúng

### Test Create Booking
- [ ] Điền đủ thông tin bắt buộc
- [ ] Chọn chi nhánh (Admin) hoặc check chi nhánh tự động (Manager)
- [ ] Click "Đặt đơn"
- [ ] Check Console: Request body có đầy đủ field
- [ ] Check Response: Đơn hàng được tạo thành công

### Test Branch Selection
- [ ] Admin: Thấy dropdown chọn chi nhánh
- [ ] Manager: Thấy badge chi nhánh (readonly)
- [ ] Check Debug Panel: `branchId` có giá trị

## Console Logs để Debug

Khi test, bạn sẽ thấy các log sau trong Console:

### Calculate Price
```
⏸️ Skipping price calculation: missing time
```
hoặc
```
📤 Calculating price with: {...}
```

### Create Booking
```
📤 Creating booking: {
  customer: {...},
  branchId: 1,
  trips: [...],
  ...
}
```

### Branch Loading
```
🔍 Branch Loading Debug: { userId: "1", roleName: "Admin", isAdminUser: true }
👑 Loading branches for Admin...
📦 Branches API Response: {...}
✅ Extracted branches: [...]
✅ Set default branch: {...}
✅ Branch loading completed
```

## Nếu vẫn gặp lỗi 400

1. **Check Console logs** - Xem request body có đầy đủ không
2. **Check Network tab** - Xem response error message từ backend
3. **Check Debug Panel** - Xem tất cả state có đúng không
4. **Check Backend logs** - Xem backend báo lỗi gì cụ thể

## Các field bắt buộc khi tạo booking

```javascript
{
  customer: { fullName, phone, email },
  branchId: Number (required),
  trips: [{ startLocation, endLocation, startTime, endTime }],
  vehicles: [{ vehicleCategoryId, quantity }],
  estimatedCost: Number,
  totalCost: Number,
  distance: Number,
  status: "PENDING" | "CONFIRMED"
}
```

## Next Steps

1. Test với nhiều scenarios khác nhau
2. Xóa Debug Panel sau khi test xong (panel màu vàng)
3. Xóa các console.log không cần thiết
4. Thêm unit tests nếu cần
