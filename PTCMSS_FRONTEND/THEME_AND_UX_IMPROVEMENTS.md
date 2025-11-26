# Cải tiến Theme và UX

## Tổng quan thay đổi

### 1. Đổi màu theme sang vàng #EDC531

#### Tailwind Config
Đã cập nhật `tailwind.config.js` với bảng màu vàng mới:

```javascript
brand: {
    50: "#FEF9E7",
    100: "#FDF3D0",
    200: "#FCE7A1",
    300: "#FADB72",
    400: "#F8CF43",
    500: "#EDC531",  // Màu vàng chính
    600: "#D4AF1F",
    700: "#A68818",
    800: "#786211",
    900: "#4A3C0A",
}
```

#### Cách sử dụng màu mới

**Trong JSX với inline style:**
```jsx
const BRAND_COLOR = "#EDC531";
<div style={{ backgroundColor: BRAND_COLOR }}>...</div>
```

**Với Tailwind classes:**
```jsx
<button className="bg-brand-500 hover:bg-brand-600">...</button>
<div className="text-brand-500 border-brand-500">...</div>
```

#### Script tự động thay đổi màu

Chạy script để thay đổi tất cả màu xanh sang vàng:

```powershell
cd PTCMSS_FRONTEND
.\scripts\change-theme-to-yellow.ps1
```

Script sẽ tự động thay thế:
- `#007BC7` → `#EDC531`
- `#0079BC` → `#EDC531`
- `#0069A8` → `#D4AF1F`
- `bg-blue-*` → `bg-yellow-*`
- `text-blue-*` → `text-yellow-*`
- `border-blue-*` → `border-yellow-*`

### 2. Scrollbar cho tất cả popup/modal

#### Component ScrollableModal

Đã tạo component `ScrollableModal` tại `src/components/common/ScrollableModal.jsx`

**Cách sử dụng:**

```jsx
import ScrollableModal from "../../components/common/ScrollableModal";

function MyComponent() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <ScrollableModal
      isOpen={isOpen}
      onClose={() => setIsOpen(false)}
      title="Tiêu đề Modal"
      maxWidth="max-w-4xl"  // Optional
      maxHeight="max-h-[90vh]"  // Optional
      footer={
        <>
          <button onClick={() => setIsOpen(false)}>Hủy</button>
          <button onClick={handleSave}>Lưu</button>
        </>
      }
    >
      {/* Nội dung modal - tự động có scrollbar khi quá dài */}
      <div>...</div>
    </ScrollableModal>
  );
}
```

**Props:**
- `isOpen`: boolean - Trạng thái mở/đóng
- `onClose`: function - Callback khi đóng
- `title`: string - Tiêu đề modal
- `children`: ReactNode - Nội dung
- `maxWidth`: string - Chiều rộng tối đa (default: "max-w-2xl")
- `maxHeight`: string - Chiều cao tối đa (default: "max-h-[85vh]")
- `footer`: ReactNode - Nút action ở footer (optional)

**Tính năng:**
- Header và footer cố định
- Content tự động scrollable
- Custom scrollbar đẹp (thin, màu slate)
- Responsive với mobile

#### Thêm scrollbar cho modal hiện có

Nếu bạn có modal tự viết, thêm class này vào phần content:

```jsx
<div className="overflow-y-auto max-h-[70vh] scrollbar-thin scrollbar-thumb-slate-300 scrollbar-track-slate-100">
  {/* Content */}
</div>
```

### 3. Phân trang cho tất cả danh sách

#### Component Pagination (cần tạo)

Tạo component `Pagination.jsx`:

```jsx
import React from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";

export default function Pagination({ 
  currentPage, 
  totalPages, 
  onPageChange,
  itemsPerPage = 10,
  totalItems = 0
}) {
  const pages = [];
  const maxVisible = 5;
  
  let startPage = Math.max(1, currentPage - Math.floor(maxVisible / 2));
  let endPage = Math.min(totalPages, startPage + maxVisible - 1);
  
  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1);
  }
  
  for (let i = startPage; i <= endPage; i++) {
    pages.push(i);
  }

  return (
    <div className="flex items-center justify-between px-6 py-4 border-t border-slate-200">
      <div className="text-sm text-slate-600">
        Hiển thị {Math.min((currentPage - 1) * itemsPerPage + 1, totalItems)} - {Math.min(currentPage * itemsPerPage, totalItems)} trong tổng số {totalItems}
      </div>
      
      <div className="flex items-center gap-2">
        <button
          onClick={() => onPageChange(currentPage - 1)}
          disabled={currentPage === 1}
          className="p-2 rounded-lg border border-slate-300 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <ChevronLeft className="h-4 w-4" />
        </button>
        
        {pages.map(page => (
          <button
            key={page}
            onClick={() => onPageChange(page)}
            className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${
              page === currentPage
                ? "bg-brand-500 text-white"
                : "border border-slate-300 hover:bg-slate-50"
            }`}
          >
            {page}
          </button>
        ))}
        
        <button
          onClick={() => onPageChange(currentPage + 1)}
          disabled={currentPage === totalPages}
          className="p-2 rounded-lg border border-slate-300 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <ChevronRight className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
}
```

**Cách sử dụng:**

```jsx
import Pagination from "../../components/common/Pagination";

function ListPage() {
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;
  const totalItems = 100;
  const totalPages = Math.ceil(totalItems / itemsPerPage);

  return (
    <div>
      {/* List content */}
      <Pagination
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={setCurrentPage}
        itemsPerPage={itemsPerPage}
        totalItems={totalItems}
      />
    </div>
  );
}
```

### 4. Quyền cập nhật profile

#### Backend đã sửa

Đã tạo endpoint mới trong `UserController.java`:

```java
@PatchMapping("/{id}/profile")
@PreAuthorize("#id == authentication.principal.id")
public ResponseData<?> updateProfile(
    @PathVariable Integer id,
    @RequestBody UpdateProfileRequest request
) {
    // Chỉ cho phép user tự cập nhật phone và address
}
```

#### Frontend API

File `src/api/profile.js` cần có:

```javascript
export const updateMyProfile = async (data) => {
  const userId = getCookie("userId") || localStorage.getItem("userId");
  return apiFetch(`/users/${userId}/profile`, {
    method: "PATCH",
    body: JSON.stringify(data),
  });
};
```

#### UpdateProfilePage

Đã cập nhật:
- ✅ Ẩn ID người dùng
- ✅ Cho phép tất cả role cập nhật phone và address
- ✅ Email và role chỉ xem, không sửa được
- ✅ Đổi màu theme sang vàng #EDC531

### 5. Ẩn ID người dùng

Đã xóa field "ID người dùng" khỏi trang profile (`UpdateProfilePage.jsx`).

Grid layout thay đổi từ `grid-cols-3` thành `grid-cols-2` trong phần "Thông tin tài khoản".

## Checklist áp dụng cho toàn hệ thống

### Màu sắc
- [ ] Chạy script `change-theme-to-yellow.ps1`
- [ ] Kiểm tra tất cả component có màu xanh cứng (hardcoded)
- [ ] Thay thế `#007BC7`, `#0079BC` → `#EDC531`
- [ ] Thay thế Tailwind classes `blue-*` → `yellow-*`

### Scrollbar
- [ ] Thay thế tất cả modal/dialog bằng `ScrollableModal`
- [ ] Thêm `scrollbar-thin` cho các container có overflow
- [ ] Test trên mobile để đảm bảo scrollbar hoạt động tốt

### Phân trang
- [ ] Tạo component `Pagination.jsx`
- [ ] Áp dụng cho tất cả trang danh sách:
  - [ ] AdminUsersPage
  - [ ] AdminBranchesPage
  - [ ] EmployeeManagementPage
  - [ ] VehicleListPage
  - [ ] ConsultantOrderListPage
  - [ ] PendingTripsPage
  - [ ] DebtManagementPage
  - [ ] InvoiceManagement
  - [ ] ExpenseReportPage
  - [ ] Tất cả dashboard lists

### Profile & Permissions
- [ ] Kiểm tra tất cả role có thể truy cập `/me/profile`
- [ ] Test cập nhật phone/address với từng role
- [ ] Đảm bảo không hiển thị ID người dùng ở bất kỳ đâu

## Testing

### Test màu theme
1. Mở tất cả trang trong hệ thống
2. Kiểm tra buttons, links, borders có màu vàng #EDC531
3. Hover states phải dùng màu vàng đậm hơn (#D4AF1F)

### Test scrollbar
1. Mở tất cả modal/popup
2. Thêm nhiều nội dung để test scrollbar xuất hiện
3. Kiểm tra scrollbar mượt mà, không bị giật
4. Test trên Chrome, Firefox, Safari

### Test phân trang
1. Tạo data test với > 100 items
2. Kiểm tra phân trang hoạt động đúng
3. Test các edge cases: trang đầu, trang cuối, trang giữa
4. Kiểm tra số lượng items hiển thị đúng

### Test permissions
1. Đăng nhập với từng role: ADMIN, MANAGER, COORDINATOR, CONSULTANT, DRIVER
2. Truy cập `/me/profile`
3. Thử cập nhật phone và address
4. Kiểm tra không thể sửa email, role, status

## Notes

- Màu vàng #EDC531 là màu chính, dùng cho buttons, links, highlights
- Màu vàng đậm #D4AF1F dùng cho hover states
- Scrollbar luôn hiển thị khi có overflow, không ẩn
- Phân trang mặc định 10 items/page, có thể customize
- Profile page không hiển thị ID để bảo mật
