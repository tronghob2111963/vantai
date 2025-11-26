# Hướng dẫn sử dụng Components

## 1. ScrollableModal - Modal với scrollbar

### Import
```jsx
import ScrollableModal from "../../components/common/ScrollableModal";
```

### Cách sử dụng
```jsx
function MyComponent() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <button onClick={() => setIsOpen(true)}>Mở Modal</button>
      
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
        <div>
          <p>Nội dung dài...</p>
        </div>
      </ScrollableModal>
    </>
  );
}
```

### Props
- `isOpen`: boolean - Trạng thái mở/đóng
- `onClose`: function - Callback khi đóng
- `title`: string - Tiêu đề modal
- `children`: ReactNode - Nội dung
- `maxWidth`: string - Chiều rộng tối đa (default: "max-w-2xl")
- `maxHeight`: string - Chiều cao tối đa (default: "max-h-[85vh]")
- `footer`: ReactNode - Nút action ở footer (optional)

### Tính năng
- Header và footer cố định
- Content tự động scrollable
- Custom scrollbar đẹp
- Responsive với mobile
- Click outside để đóng

---

## 2. Pagination - Phân trang

### Import
```jsx
import Pagination from "../../components/common/Pagination";
```

### Cách sử dụng
```jsx
function ListPage() {
  const [currentPage, setCurrentPage] = useState(1);
  const [data, setData] = useState([]);
  const itemsPerPage = 10;
  const totalItems = 100;
  const totalPages = Math.ceil(totalItems / itemsPerPage);

  return (
    <div>
      {/* Hiển thị danh sách */}
      <div>
        {data.map(item => (
          <div key={item.id}>{item.name}</div>
        ))}
      </div>

      {/* Pagination */}
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

### Props
- `currentPage`: number - Trang hiện tại (bắt đầu từ 1)
- `totalPages`: number - Tổng số trang
- `onPageChange`: function - Callback khi chuyển trang
- `itemsPerPage`: number - Số items mỗi trang (default: 10)
- `totalItems`: number - Tổng số items (default: 0)
- `maxVisible`: number - Số trang hiển thị tối đa (default: 5)

### Tính năng
- First/Last page buttons
- Previous/Next buttons
- Hiển thị info: "Hiển thị 1-10 trong tổng số 100"
- Ellipsis (...) khi có nhiều trang
- Responsive với mobile

---

## 3. BranchSelect - Dropdown chọn chi nhánh

### Import
```jsx
import BranchSelect from "../../components/common/BranchSelect";
```

### Cách sử dụng
```jsx
function CreateManagerForm() {
  const [branchId, setBranchId] = useState(null);
  const [errors, setErrors] = useState({});

  return (
    <form>
      <BranchSelect
        value={branchId}
        onChange={setBranchId}
        required
        error={errors.branch}
        label="Chi nhánh"
        placeholder="-- Chọn chi nhánh --"
      />
    </form>
  );
}
```

### Props
- `value`: number - ID chi nhánh được chọn
- `onChange`: function - Callback khi thay đổi (nhận branchId)
- `required`: boolean - Bắt buộc chọn (default: false)
- `disabled`: boolean - Disable select (default: false)
- `error`: string - Thông báo lỗi
- `label`: string - Label cho select (default: "Chi nhánh")
- `placeholder`: string - Placeholder (default: "-- Chọn chi nhánh --")
- `className`: string - Custom class cho container

### Tính năng
- Tự động load danh sách chi nhánh ACTIVE
- Loading state với spinner
- Error handling
- Validation error display
- Icon Building2 ở label
- Màu vàng #EDC531 cho focus state

---

## 4. Theme màu vàng #EDC531

### Tailwind Classes
```jsx
// Background
<div className="bg-brand-500">...</div>  // #EDC531
<div className="bg-brand-600">...</div>  // #D4AF1F (darker)

// Text
<div className="text-brand-500">...</div>

// Border
<div className="border-brand-500">...</div>

// Hover
<button className="bg-brand-500 hover:bg-brand-600">...</button>
```

### Inline Style
```jsx
const BRAND_COLOR = "#EDC531";

<div style={{ backgroundColor: BRAND_COLOR }}>...</div>
<button style={{ color: BRAND_COLOR }}>...</button>
```

### Focus Ring
```jsx
<input className="focus:ring-[#EDC531]/20 focus:border-[#EDC531]/50" />
```

---

## 5. Custom Scrollbar

### Thêm scrollbar cho container
```jsx
<div className="overflow-y-auto max-h-[70vh] scrollbar-thin scrollbar-thumb-slate-300 scrollbar-track-slate-100">
  {/* Content */}
</div>
```

### Classes
- `scrollbar-thin`: Scrollbar mỏng
- `scrollbar-thumb-slate-300`: Màu thumb
- `scrollbar-track-slate-100`: Màu track

---

## Examples

### Form với BranchSelect và ScrollableModal
```jsx
import React, { useState } from 'react';
import ScrollableModal from '../../components/common/ScrollableModal';
import BranchSelect from '../../components/common/BranchSelect';

function CreateUserModal({ isOpen, onClose }) {
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    branchId: null,
  });
  const [errors, setErrors] = useState({});

  const handleSubmit = async () => {
    // Validate
    const newErrors = {};
    if (!formData.fullName) newErrors.fullName = 'Vui lòng nhập họ tên';
    if (!formData.branchId) newErrors.branch = 'Vui lòng chọn chi nhánh';
    
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    // Submit
    try {
      await createUser(formData);
      onClose();
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <ScrollableModal
      isOpen={isOpen}
      onClose={onClose}
      title="Tạo người dùng mới"
      footer={
        <>
          <button onClick={onClose} className="px-4 py-2 border rounded-lg">
            Hủy
          </button>
          <button
            onClick={handleSubmit}
            className="px-4 py-2 bg-[#EDC531] text-white rounded-lg"
          >
            Tạo
          </button>
        </>
      }
    >
      <div className="space-y-4">
        <div>
          <label>Họ và tên *</label>
          <input
            value={formData.fullName}
            onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
            className="w-full border rounded-lg px-3 py-2"
          />
          {errors.fullName && <p className="text-red-500 text-xs">{errors.fullName}</p>}
        </div>

        <BranchSelect
          value={formData.branchId}
          onChange={(branchId) => setFormData({ ...formData, branchId })}
          required
          error={errors.branch}
        />
      </div>
    </ScrollableModal>
  );
}
```

### List với Pagination
```jsx
import React, { useState, useEffect } from 'react';
import Pagination from '../../components/common/Pagination';
import { listUsers } from '../../api/users';

function UserListPage() {
  const [users, setUsers] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const itemsPerPage = 10;

  useEffect(() => {
    loadUsers();
  }, [currentPage]);

  const loadUsers = async () => {
    try {
      const response = await listUsers({
        page: currentPage - 1, // Backend bắt đầu từ 0
        size: itemsPerPage,
      });
      setUsers(response.data.content || []);
      setTotalPages(response.data.totalPages || 1);
      setTotalItems(response.data.totalElements || 0);
    } catch (error) {
      console.error('Failed to load users:', error);
    }
  };

  return (
    <div>
      <h1>Danh sách người dùng</h1>

      {/* List */}
      <div className="space-y-2">
        {users.map((user) => (
          <div key={user.id} className="border rounded-lg p-4">
            <h3>{user.fullName}</h3>
            <p>{user.email}</p>
          </div>
        ))}
      </div>

      {/* Pagination */}
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

---

## Best Practices

1. **ScrollableModal**: Dùng cho tất cả popup/dialog có nội dung dài
2. **Pagination**: Áp dụng cho tất cả trang danh sách
3. **BranchSelect**: Dùng thay vì tự viết dropdown chi nhánh
4. **Theme màu**: Luôn dùng `#EDC531` cho brand color
5. **Scrollbar**: Thêm `scrollbar-thin` cho container có overflow
6. **Validation**: Hiển thị error message rõ ràng
7. **Loading state**: Luôn có loading indicator khi fetch data
8. **Responsive**: Test trên mobile và tablet
