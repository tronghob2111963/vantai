# 🧪 Hướng Dẫn Test - Vehicle Category Pricing Feature

## ✅ Trạng Thái Hệ Thống

### Backend
- **Status**: ✅ Đang chạy
- **URL**: http://localhost:8080
- **Port**: 8080
- **Started**: Successfully với Tomcat

### Frontend
- **Status**: ✅ Đang chạy
- **URL**: http://localhost:5173 (Vite default)
- **Build Tool**: Vite v7.1.12

## 📋 Checklist Test - Cần Làm Trước

### 1. **Chạy Migration SQL** (QUAN TRỌNG!)

**File**: `d:\Project\vantai\PTCMSS\db_scripts\migration_add_seats_to_vehicle_category.sql`

**Cách 1: MySQL Workbench**
```
1. Mở MySQL Workbench
2. Connect vào database ptcmss_db
3. File → Open SQL Script
4. Chọn file migration_add_seats_to_vehicle_category.sql
5. Click Execute (⚡)
```

**Cách 2: Command Line**
```bash
mysql -u root -p1001 ptcmss_db < "d:\Project\vantai\PTCMSS\db_scripts\migration_add_seats_to_vehicle_category.sql"
```

**Verify Migration**
```sql
SELECT categoryId, categoryName, seats, baseFare, pricePerKm
FROM vehicle_category_pricing
ORDER BY categoryId;
```

Kết quả mong đợi:
```
+------------+-------------------------+-------+-----------+------------+
| categoryId | categoryName            | seats | baseFare  | pricePerKm |
+------------+-------------------------+-------+-----------+------------+
|          1 | Xe 9 chỗ (Limousine)   |     9 | 800000.00 | 15000.00   |
|          2 | Xe 16 chỗ              |    16 | 600000.00 | 12000.00   |
|          3 | Xe 29 chỗ              |    29 | 500000.00 | 10000.00   |
|          4 | Xe 45 chỗ              |    45 | 400000.00 | 8000.00    |
|          5 | Xe giường nằm (40 chỗ) |    40 | 700000.00 | 13000.00   |
+------------+-------------------------+-------+-----------+------------+
```

## 🧪 Test Cases

### Test 1: Hiển Thị Danh Sách Danh Mục

**Steps:**
1. Mở trình duyệt: http://localhost:5173
2. Đăng nhập vào hệ thống (nếu cần)
3. Navigate đến trang "Quản lý danh mục xe"

**Expected:**
- ✅ Hiển thị đúng số ghế cho mỗi danh mục (9, 16, 29, 45, 40)
- ✅ Hiển thị số xe đang thuộc danh mục (không còn là 0)
- ✅ Dữ liệu load từ API thật

**Screenshot Checklist:**
- [ ] Cột "Số ghế" hiển thị đúng
- [ ] Cột "Số xe" > 0 cho các danh mục có xe
- [ ] Layout table gọn gàng

---

### Test 2: Modal Create (Đơn Giản)

**Steps:**
1. Click button "Tạo danh mục mới"
2. Kiểm tra modal

**Expected:**
- ✅ Modal chỉ có 2 field: Tên danh mục + Số ghế
- ✅ Không có pricing fields (baseFare, pricePerKm, etc.)
- ✅ Form đơn giản, nhanh gọn

**Test Create:**
1. Nhập tên: "Xe 7 chỗ VIP"
2. Nhập số ghế: 7
3. Click "Lưu"

**Expected:**
- ✅ Toast "Tạo danh mục thành công"
- ✅ Danh mục mới xuất hiện trong bảng
- ✅ Số ghế = 7
- ✅ Pricing fields = NULL (sẽ cập nhật sau)

---

### Test 3: Validation - Touched State

**Steps:**
1. Click "Tạo danh mục mới"
2. **KHÔNG nhập gì**, chỉ click vào field rồi click ra ngoài

**Expected:**
- ✅ **KHÔNG** hiển thị lỗi đỏ ngay lập tức khi mở modal
- ✅ Chỉ hiển thị lỗi SAU KHI blur (rời khỏi field)
- ✅ Message: "Tên danh mục không được để trống."
- ✅ Message: "Số ghế phải lớn hơn 0."

**Test Valid Input:**
1. Nhập tên: "Test"
2. Nhập số ghế: 5
3. Lỗi phải biến mất

---

### Test 4: Modal Edit (Đầy Đủ)

**Steps:**
1. Click "Sửa / Xoá" ở danh mục ID #1 (Xe 9 chỗ)
2. Kiểm tra modal

**Expected:**
- ✅ Field "Tên danh mục": "Xe 9 chỗ (Limousine)"
- ✅ Field "Số ghế": 9
- ✅ Field "Mô tả": (có thể trống)
- ✅ **Section mới**: "💰 Thông tin giá"
- ✅ Field "Giá cơ bản": 800000
- ✅ Field "Giá/km": 15000
- ✅ Field "Phí cao tốc": 100000 (hoặc NULL)
- ✅ Field "Chi phí cố định": 0 (hoặc NULL)
- ✅ Dropdown "Trạng thái": ACTIVE
- ✅ Text: "ℹ️ Số xe đang thuộc danh mục: X"

**UI Checklist:**
- [ ] Modal có scroll (max-h-[70vh])
- [ ] Pricing section có border-top
- [ ] Grid 2 cột cho 4 pricing fields
- [ ] Placeholder đúng (VD: 800000)

---

### Test 5: Update Pricing

**Steps:**
1. Mở modal Edit danh mục #1
2. Scroll xuống section "💰 Thông tin giá"
3. Sửa các giá trị:
   - Giá cơ bản: 900000
   - Giá/km: 18000
   - Phí cao tốc: 120000
   - Chi phí cố định: 50000
4. Click "Lưu thay đổi"

**Expected:**
- ✅ Toast "Cập nhật thành công"
- ✅ Modal đóng
- ✅ Refresh trang → Giá vẫn đúng

**Backend Verification:**
```sql
SELECT categoryId, categoryName, baseFare, pricePerKm, highwayFee, fixedCosts
FROM vehicle_category_pricing
WHERE categoryId = 1;
```

Kết quả mong đợi:
```
baseFare: 900000.00
pricePerKm: 18000.00
highwayFee: 120000.00
fixedCosts: 50000.00
```

---

### Test 6: Edge Cases

**Test 6.1: Decimal Numbers**
1. Edit danh mục
2. Nhập giá/km: 15000.5
3. Save

**Expected:**
- ✅ Cho phép nhập số thập phân
- ✅ Lưu đúng vào database

**Test 6.2: Empty Pricing**
1. Edit danh mục
2. Xóa hết giá cơ bản (để trống)
3. Save

**Expected:**
- ✅ Backend nhận NULL
- ✅ Không báo lỗi (pricing là optional)

**Test 6.3: Invalid Seats**
1. Create/Edit danh mục
2. Nhập số ghế = 0
3. Try Save

**Expected:**
- ✅ Validation error: "Số ghế phải lớn hơn 0."

---

### Test 7: Browser Console Check

**Steps:**
1. Mở DevTools (F12)
2. Tab "Network"
3. Click "Sửa / Xoá" ở danh mục
4. Xem API request

**Expected:**
- ✅ Request: `GET /api/vehicle-categories/{id}`
- ✅ Response có đầy đủ fields:
  ```json
  {
    "id": 1,
    "categoryName": "Xe 9 chỗ (Limousine)",
    "seats": 9,
    "vehiclesCount": 7,
    "description": "...",
    "baseFare": 800000.00,
    "pricePerKm": 15000.00,
    "highwayFee": 100000.00,
    "fixedCosts": 0.00,
    "effectiveDate": null,
    "status": "ACTIVE"
  }
  ```

**Update Test:**
1. Sửa giá
2. Click "Lưu"
3. Xem API request

**Expected:**
- ✅ Request: `PUT /api/vehicle-categories/{id}`
- ✅ Request Body có pricing:
  ```json
  {
    "categoryName": "Xe 9 chỗ (Limousine)",
    "seats": 9,
    "description": "...",
    "baseFare": 900000,
    "pricePerKm": 18000,
    "highwayFee": 120000,
    "fixedCosts": 50000,
    "status": "ACTIVE"
  }
  ```

---

## 🐛 Troubleshooting

### Lỗi: Vehicle count vẫn = 0

**Nguyên nhân:**
- Migration chưa chạy
- Backend chưa restart sau khi compile

**Fix:**
1. Chạy migration SQL
2. Restart backend:
   - Stop: Ctrl+C trong terminal backend
   - Start: `mvn spring-boot:run`

---

### Lỗi: Pricing fields không hiển thị

**Nguyên nhân:**
- Code frontend cũ chưa update
- Browser cache

**Fix:**
1. Hard refresh: Ctrl+Shift+R
2. Clear browser cache
3. Verify file [VehicleCategoryManagePage.jsx](d:\Project\vantai\PTCMSS_FRONTEND\src\components\module 3\VehicleCategoryManagePage.jsx) có code mới

---

### Lỗi: Backend trả 403 Forbidden

**Nguyên nhân:**
- Chưa đăng nhập
- Token hết hạn

**Fix:**
1. Logout và login lại
2. Check cookie `access_token` trong DevTools

---

### Lỗi: Validation hiển thị ngay khi mở modal

**Nguyên nhân:**
- Code cũ không có touched state

**Fix:**
Verify code có đoạn này:
```javascript
const [touchedName, setTouchedName] = React.useState(false);
const [touchedSeats, setTouchedSeats] = React.useState(false);

React.useEffect(() => {
    if (open) {
        // ...
        setTouchedName(false);
        setTouchedSeats(false);
    }
}, [open]);
```

---

## 📊 Summary Report Template

Sau khi test xong, điền checklist này:

```
# Test Summary Report

## Test 1: Hiển Thị Danh Sách
- [ ] Số ghế hiển thị đúng
- [ ] Số xe > 0
- [ ] Data từ API

## Test 2: Modal Create
- [ ] Chỉ có tên + ghế
- [ ] Tạo mới thành công

## Test 3: Validation
- [ ] Không hiển thị lỗi khi mở
- [ ] Hiển thị lỗi sau blur

## Test 4: Modal Edit
- [ ] Hiển thị đầy đủ pricing fields
- [ ] Section "💰 Thông tin giá"
- [ ] Modal scroll được

## Test 5: Update Pricing
- [ ] Update thành công
- [ ] Data đúng sau refresh
- [ ] Database verify OK

## Test 6: Edge Cases
- [ ] Số thập phân OK
- [ ] Empty pricing OK
- [ ] Validation seats = 0

## Test 7: API Verification
- [ ] GET response đúng
- [ ] PUT request đúng
```

---

## 🎉 Success Criteria

Tính năng đạt khi:

1. ✅ Tất cả test cases PASS
2. ✅ Không có validation lỗi khi mở modal
3. ✅ Pricing update thành công và persist
4. ✅ Số xe hiển thị đúng (không còn 0)
5. ✅ Modal Edit có scroll smooth
6. ✅ Backend trả đúng tất cả fields
7. ✅ Database có seats và pricing đầy đủ

---

**Prepared by**: Claude Code Assistant
**Date**: 2025-11-24
**Version**: 1.0
