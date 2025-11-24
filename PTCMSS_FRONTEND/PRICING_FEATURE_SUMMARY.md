# ✨ Feature Update: Quản Lý Giá Danh Mục Xe

## 🎯 Tổng Quan
Đã thêm chức năng quản lý giá đầy đủ vào modal **Chỉnh sửa danh mục xe**, cho phép cập nhật:
- Giá cơ bản (baseFare)
- Giá/km (pricePerKm)
- Phí cao tốc (highwayFee)
- Chi phí cố định (fixedCosts)
- Mô tả danh mục (description)

## 📝 Thay Đổi Chi Tiết

### **Frontend Changes** ([VehicleCategoryManagePage.jsx](src/components/module 3/VehicleCategoryManagePage.jsx))

#### 1. **Modal Edit - State Management**
```javascript
// Thêm các state mới cho pricing
const [description, setDescription] = React.useState("");
const [baseFare, setBaseFare] = React.useState("");
const [pricePerKm, setPricePerKm] = React.useState("");
const [highwayFee, setHighwayFee] = React.useState("");
const [fixedCosts, setFixedCosts] = React.useState("");
```

#### 2. **Utility Functions**
```javascript
// Helper để clean số thập phân (cho phép dấu chấm)
const cleanNumber = (s) => s.replace(/[^0-9.]/g, "");
```

#### 3. **UI Enhancements**
- ✅ Thêm section "💰 Thông tin giá" với border-top
- ✅ Layout grid 2 cột cho 4 pricing fields
- ✅ Thêm placeholder hợp lý (800000, 15000, v.v.)
- ✅ Modal có scroll (`max-h-[70vh] overflow-y-auto`)
- ✅ Input type `decimal` với `inputMode="decimal"`

#### 4. **Data Mapping**
```javascript
const mapCat = React.useCallback((c) => ({
    id: c.id,
    name: c.categoryName || c.name,
    seats: c.seats ?? null,
    vehicles_count: c.vehicles_count ?? 0,
    // ✅ NEW: Pricing fields
    description: c.description || "",
    baseFare: c.baseFare ?? null,
    pricePerKm: c.pricePerKm ?? null,
    highwayFee: c.highwayFee ?? null,
    fixedCosts: c.fixedCosts ?? null,
}), []);
```

#### 5. **API Integration**
```javascript
async function handleSaved(cat) {
    const result = await updateVehicleCategory(cat.id, {
        categoryName: cat.name,
        seats: cat.seats,
        description: cat.description,      // ✅ NEW
        baseFare: cat.baseFare,            // ✅ NEW
        pricePerKm: cat.pricePerKm,        // ✅ NEW
        highwayFee: cat.highwayFee,        // ✅ NEW
        fixedCosts: cat.fixedCosts,        // ✅ NEW
        status: cat.status,
    });
    // ...
}
```

### **Backend - Already Ready** ✅
Backend đã support đầy đủ các field này:
- Entity: `VehicleCategoryPricing` có tất cả pricing fields
- Request DTO: `VehicleCategoryRequest` nhận tất cả fields
- Response DTO: `VehicleCategoryResponse` trả về đầy đủ
- Service: `VehicleCategoryServiceImpl` map đúng

## 🎨 UI/UX Features

### **Modal Create (Giữ Nguyên - Đơn Giản)**
```
┌─────────────────────────────┐
│ 🚗 Tạo danh mục xe          │
├─────────────────────────────┤
│ Tên danh mục: [______]     │
│ Số ghế:       [______]     │
│                             │
│         [Hủy]  [Lưu]       │
└─────────────────────────────┘
```

### **Modal Edit (Mở Rộng - Đầy Đủ)**
```
┌─────────────────────────────────────┐
│ 🚗 Chỉnh sửa danh mục (ID #1)      │
├─────────────────────────────────────┤
│ Tên danh mục: [________________]   │
│ Số ghế:       [____]               │
│ Mô tả:        [________________]   │
│                                     │
│ ─────── 💰 Thông tin giá ────────  │
│ Giá cơ bản:    [_______] VNĐ       │
│ Giá/km:        [_______] VNĐ       │
│ Phí cao tốc:   [_______] VNĐ       │
│ Chi phí cố định:[_______] VNĐ      │
│                                     │
│ Trạng thái: [▼ Đang hoạt động]    │
│ ℹ️ Số xe đang thuộc danh mục: 7    │
│                                     │
│ [🗑️ Xoá]       [Đóng]  [💾 Lưu]   │
└─────────────────────────────────────┘
```

## ✅ Checklist Testing

Sau khi chạy migration SQL và restart backend:

### **1. Test Hiển Thị**
- [ ] Mở modal Edit của danh mục có sẵn
- [ ] Kiểm tra các pricing fields có data đúng
- [ ] Mô tả hiển thị đúng

### **2. Test Update**
- [ ] Sửa giá cơ bản → Save → Verify
- [ ] Sửa giá/km → Save → Verify
- [ ] Sửa phí cao tốc → Save → Verify
- [ ] Sửa mô tả → Save → Verify
- [ ] Refresh page → Data vẫn đúng

### **3. Test Create (Giữ Nguyên)**
- [ ] Tạo danh mục mới (chỉ tên + ghế)
- [ ] Sau đó Edit để thêm giá
- [ ] Verify workflow hợp lý

### **4. Test Edge Cases**
- [ ] Nhập số thập phân (15000.5)
- [ ] Xóa hết giá (để trống) → Should be null
- [ ] Số ghế = 0 → Error validation
- [ ] Tên trống → Error validation

## 🚀 Workflow Sử Dụng

1. **Tạo Danh Mục Mới**
   ```
   Click "Tạo danh mục mới"
   → Nhập tên: "Xe 7 chỗ VIP"
   → Nhập số ghế: 7
   → Click "Lưu"
   ```

2. **Cập Nhật Giá**
   ```
   Click "Sửa / Xoá" ở danh mục vừa tạo
   → Scroll xuống section "💰 Thông tin giá"
   → Nhập:
      - Giá cơ bản: 900000
      - Giá/km: 18000
      - Phí cao tốc: 120000
      - Chi phí cố định: 50000
   → Click "Lưu thay đổi"
   ```

3. **Xem Kết Quả**
   ```
   Backend response sẽ trả về đầy đủ thông tin
   Frontend hiển thị toast "Cập nhật thành công"
   ```

## 📊 Data Flow

```
┌──────────────┐    handleSaved()    ┌────────────────────┐
│ Edit Modal   │ ─────────────────→  │ API: PUT /api/...  │
│ (User Input) │                      │ vehicle-categories │
└──────────────┘                      └────────────────────┘
      ↓                                         ↓
      ↓                                         ↓
  Submit Data:                         Backend Receives:
  {                                     {
    id: 1,                                categoryName: "...",
    name: "Xe 9 chỗ",                     seats: 9,
    seats: 9,                             description: "...",
    description: "...",                   baseFare: 800000,
    baseFare: 800000,                     pricePerKm: 15000,
    pricePerKm: 15000,         ────────→  highwayFee: 100000,
    highwayFee: 100000,                   fixedCosts: 0,
    fixedCosts: 0,                        status: "ACTIVE"
    status: "ACTIVE"                    }
  }                                           ↓
      ↑                                       ↓
      │                               VehicleCategoryServiceImpl
      │                               .update(id, request)
      │                                       ↓
      │                               Save to Database
      │                                       ↓
      └───────── Response ← ─────────────────┘

Frontend updates state → Toast "Cập nhật thành công"
```

## 🎉 Benefits

1. **✅ UX Tốt Hơn:**
   - Create đơn giản, nhanh
   - Edit đầy đủ, chi tiết
   - Scroll modal cho form dài

2. **✅ Data Integrity:**
   - Không bắt buộc nhập giá khi tạo
   - Có thể cập nhật giá sau
   - Nullable fields cho linh hoạt

3. **✅ Maintainable:**
   - Code rõ ràng, dễ đọc
   - Helper functions reusable
   - Consistent với design system hiện tại

## 📝 Notes

- Modal Create GIỮ NGUYÊN (chỉ tên + ghế) để đơn giản
- Modal Edit có SCROLL nếu nội dung dài
- Pricing fields cho phép NULL (không bắt buộc)
- cleanNumber() helper cho phép số thập phân

---
**Updated:** 2025-11-24
**Author:** Claude Code Assistant
