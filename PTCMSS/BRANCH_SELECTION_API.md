# API lấy danh sách chi nhánh cho dropdown

## Endpoint mới

### GET /api/branches/all

**Mô tả**: Lấy danh sách tất cả chi nhánh đang hoạt động (ACTIVE) để hiển thị trong dropdown/select.

**Permission**: ADMIN, MANAGER

**Response**:
```json
{
  "status": 200,
  "message": "Get all branches for selection successfully",
  "data": [
    {
      "id": 1,
      "branchName": "Chi nhánh Hà Nội",
      "address": "123 Đường ABC, Hà Nội",
      "phone": "0987654321",
      "status": "ACTIVE"
    },
    {
      "id": 2,
      "branchName": "Chi nhánh TP.HCM",
      "address": "456 Đường XYZ, TP.HCM",
      "phone": "0912345678",
      "status": "ACTIVE"
    }
  ]
}
```

## Sử dụng trong Frontend

### API Call

```javascript
// src/api/branches.js
export const getAllBranchesForSelection = async () => {
  return apiFetch('/api/branches/all');
};
```

### Component Example

```jsx
import React, { useState, useEffect } from 'react';
import { getAllBranchesForSelection } from '../../api/branches';

function CreateManagerForm() {
  const [branches, setBranches] = useState([]);
  const [selectedBranch, setSelectedBranch] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadBranches();
  }, []);

  const loadBranches = async () => {
    setLoading(true);
    try {
      const response = await getAllBranchesForSelection();
      setBranches(response.data || []);
    } catch (error) {
      console.error('Failed to load branches:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <label>Chi nhánh *</label>
      <select
        value={selectedBranch}
        onChange={(e) => setSelectedBranch(e.target.value)}
        disabled={loading}
        className="w-full border rounded-lg px-3 py-2"
      >
        <option value="">-- Chọn chi nhánh --</option>
        {branches.map((branch) => (
          <option key={branch.id} value={branch.id}>
            {branch.branchName}
          </option>
        ))}
      </select>
    </div>
  );
}
```

## So sánh với API cũ

### API cũ: GET /api/branches
- **Có phân trang**: page, size, sortBy
- **Có tìm kiếm**: keyword
- **Response**: PageResponse với content, totalPages, totalElements, etc.
- **Dùng cho**: Trang danh sách chi nhánh với phân trang

### API mới: GET /api/branches/all
- **Không phân trang**: Trả về tất cả
- **Không tìm kiếm**: Chỉ lấy ACTIVE branches
- **Response**: List đơn giản
- **Dùng cho**: Dropdown/select trong form

## Files đã thay đổi

1. **BranchController.java**
   - Thêm endpoint `GET /api/branches/all`
   - Permission: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER')")`

2. **BranchService.java**
   - Thêm method: `List<BranchResponse> getAllBranchesForSelection()`

3. **BranchServiceImpl.java**
   - Implementation: Lấy tất cả branches với status = ACTIVE
   - Map sang BranchResponse

## Testing

### Postman/cURL

```bash
curl -X GET "http://localhost:8080/api/branches/all" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Expected Response

```json
{
  "status": 200,
  "message": "Get all branches for selection successfully",
  "data": [
    {
      "id": 1,
      "branchName": "Chi nhánh Hà Nội",
      "address": "123 Đường ABC, Hà Nội",
      "phone": "0987654321",
      "status": "ACTIVE"
    }
  ]
}
```

## Use Cases

1. **Tạo Manager mới**: Admin chọn chi nhánh cho Manager
2. **Tạo Employee**: Admin/Manager chọn chi nhánh cho nhân viên
3. **Tạo Booking**: Consultant chọn chi nhánh xuất phát
4. **Filter**: Lọc dữ liệu theo chi nhánh
5. **Report**: Chọn chi nhánh để xem báo cáo

## Notes

- API chỉ trả về chi nhánh ACTIVE (đang hoạt động)
- Không có phân trang vì số lượng chi nhánh thường ít (< 50)
- Response nhẹ, chỉ chứa thông tin cần thiết cho dropdown
- Cache được khuyến nghị ở frontend (5-10 phút)
