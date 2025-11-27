# Province Autocomplete Feature - Chi nhánh theo Tỉnh/Thành phố

## Tổng quan

Tính năng autocomplete cho phép chọn tên chi nhánh từ danh sách 63 tỉnh/thành phố Việt Nam với gợi ý thông minh.

## Tính năng

### 1. Autocomplete với gợi ý
- Khi gõ "CẦN" → gợi ý "**Cần** Thơ" (phần đã gõ đậm, phần còn lại nhạt)
- Khi gõ "HA NOI" → gợi ý "**Hà Nội**" (bỏ qua dấu)
- Hỗ trợ tìm kiếm không dấu (gõ "ha noi" vẫn tìm được "Hà Nội")

### 2. Điều hướng bàn phím
- **Arrow Down/Up**: Di chuyển trong danh sách gợi ý
- **Enter**: Chọn tỉnh/thành phố đang highlight
- **Escape**: Đóng dropdown
- **Tab**: Chuyển sang field tiếp theo

### 3. Validation
- ✅ Chỉ cho phép chọn từ 63 tỉnh/thành phố có sẵn
- ✅ Không cho phép nhập "chi nhánh" vào tên
- ✅ Bắt buộc phải chọn (không được để trống)

### 4. UI/UX
- Icon xóa (X) để clear selection
- Icon dropdown (chevron) để mở/đóng danh sách
- Highlight khi hover hoặc dùng phím mũi tên
- Màu sắc phù hợp với theme (#0079BC)

## Cấu trúc File

### 1. Data Source
**File**: `PTCMSS_FRONTEND/src/data/provinces.json`
```json
[
  "An Giang",
  "Bà Rịa - Vũng Tàu",
  "Bạc Liêu",
  ...
  "Yên Bái"
]
```

Danh sách 63 tỉnh/thành phố Việt Nam theo thứ tự alphabet.

### 2. Component
**File**: `PTCMSS_FRONTEND/src/components/common/ProvinceAutocomplete.jsx`

**Props**:
- `value`: Giá trị hiện tại (string)
- `onChange`: Callback khi chọn tỉnh/thành phố
- `error`: Hiển thị lỗi validation (boolean)
- `placeholder`: Placeholder text (string)

**Features**:
- Tìm kiếm không dấu (removeVietnameseTones)
- Highlight text matching
- Keyboard navigation
- Click outside to close
- Clear button

### 3. Integration
**File**: `PTCMSS_FRONTEND/src/components/module 1/AdminBranchesPage.jsx`

Thay thế input text bằng ProvinceAutocomplete component.

## Cách sử dụng

### Trong form tạo chi nhánh:

```jsx
import ProvinceAutocomplete from "../common/ProvinceAutocomplete";

<ProvinceAutocomplete
  value={name}
  onChange={(value) => {
    setName(value);
    setFieldErrors((p) => ({ ...p, name: undefined }));
  }}
  error={fieldErrors.name}
  placeholder="Chọn tỉnh/thành phố (VD: Hà Nội, Cần Thơ...)"
/>
```

## Validation Rules

### Frontend
1. Tên chi nhánh phải được chọn từ danh sách (không được nhập tự do)
2. Không được chứa cụm từ "chi nhánh"
3. Không được để trống

### Backend
1. Tên chi nhánh không được trùng (case-insensitive)
2. Không được chứa "chi nhánh" (case-insensitive)

## Danh sách 63 Tỉnh/Thành phố

1. An Giang
2. Bà Rịa - Vũng Tàu
3. Bạc Liêu
4. Bắc Giang
5. Bắc Kạn
6. Bắc Ninh
7. Bến Tre
8. Bình Dương
9. Bình Định
10. Bình Phước
11. Bình Thuận
12. Cà Mau
13. Cần Thơ
14. Cao Bằng
15. Đà Nẵng
16. Đắk Lắk
17. Đắk Nông
18. Điện Biên
19. Đồng Nai
20. Đồng Tháp
21. Gia Lai
22. Hà Giang
23. Hà Nam
24. Hà Nội
25. Hà Tĩnh
26. Hải Dương
27. Hải Phòng
28. Hậu Giang
29. Hòa Bình
30. Hưng Yên
31. Khánh Hòa
32. Kiên Giang
33. Kon Tum
34. Lai Châu
35. Lâm Đồng
36. Lạng Sơn
37. Lào Cai
38. Long An
39. Nam Định
40. Nghệ An
41. Ninh Bình
42. Ninh Thuận
43. Phú Thọ
44. Phú Yên
45. Quảng Bình
46. Quảng Nam
47. Quảng Ngãi
48. Quảng Ninh
49. Quảng Trị
50. Sóc Trăng
51. Sơn La
52. Tây Ninh
53. Thái Bình
54. Thái Nguyên
55. Thanh Hóa
56. Thừa Thiên Huế
57. Tiền Giang
58. TP. Hồ Chí Minh
59. Trà Vinh
60. Tuyên Quang
61. Vĩnh Long
62. Vĩnh Phúc
63. Yên Bái

## Ví dụ sử dụng

### Tạo chi nhánh mới:
1. Click "Tạo cơ sở mới"
2. Gõ "ha" → Gợi ý: **Ha** Giang, **Hà** Nam, **Hà** Nội, **Hà** Tĩnh, **Hải** Dương, **Hải** Phòng, **Hậu** Giang
3. Gõ "ha noi" → Gợi ý: **Hà Nội**
4. Nhấn Enter hoặc click để chọn
5. Điền địa chỉ chi tiết
6. Chọn Manager (tùy chọn)
7. Lưu chi nhánh

### Lỗi thường gặp:
- ❌ Gõ "Chi nhánh Hà Nội" → Lỗi: "Tên chi nhánh không được chứa cụm từ 'chi nhánh'"
- ❌ Gõ "Ha Noi" (không chọn từ dropdown) → Lỗi: "Vui lòng chọn tỉnh/thành phố"
- ✅ Chọn "Hà Nội" từ dropdown → OK

## Technical Details

### Remove Vietnamese Tones
```javascript
const removeVietnameseTones = (str) => {
  return str
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/đ/g, "d")
    .replace(/Đ/g, "D");
};
```

Hàm này chuyển "Hà Nội" → "Ha Noi" để dễ tìm kiếm.

### Highlight Matching Text
```javascript
const getHighlightedText = (text, highlight) => {
  // Tìm vị trí match
  // Trả về JSX với phần match đậm, phần còn lại nhạt
  return (
    <>
      {beforeMatch}
      <span className="font-semibold">{match}</span>
      <span className="text-slate-400">{afterMatch}</span>
    </>
  );
};
```

### Keyboard Navigation
- Sử dụng `highlightedIndex` để track item đang được highlight
- Arrow keys để di chuyển
- Enter để chọn
- Escape để đóng

## Testing Checklist

- [ ] Gõ "can" → Hiển thị "Cần Thơ"
- [ ] Gõ "ha noi" (không dấu) → Hiển thị "Hà Nội"
- [ ] Dùng Arrow Down/Up để di chuyển
- [ ] Nhấn Enter để chọn
- [ ] Click vào item để chọn
- [ ] Click icon X để xóa
- [ ] Click bên ngoài để đóng dropdown
- [ ] Không cho phép nhập "chi nhánh"
- [ ] Validation khi submit form
- [ ] Responsive trên mobile

## Notes

- Component có thể tái sử dụng cho các form khác cần chọn tỉnh/thành phố
- Dữ liệu tỉnh/thành phố có thể cập nhật trong file JSON
- Hỗ trợ đầy đủ accessibility (keyboard navigation)
- Performance tốt với 63 items (không cần virtualization)
