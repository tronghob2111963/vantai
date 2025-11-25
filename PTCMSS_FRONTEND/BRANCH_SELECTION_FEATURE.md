# Branch Selection Feature - Create Order Page

## Tổng quan
Đã thêm tính năng chọn chi nhánh động dựa trên quyền người dùng trong trang Tạo đơn hàng.

## Thay đổi chính

### 1. Import API mới
```javascript
import { getBranchByUserId, listBranches } from "../../api/branches";
```

### 2. State Management mới
```javascript
// Thay vì hardcode branchId = "1"
const [branchId, setBranchId] = React.useState("");
const [branchName, setBranchName] = React.useState("");
const [availableBranches, setAvailableBranches] = React.useState([]);
const [isAdmin, setIsAdmin] = React.useState(false);
const [loadingBranch, setLoadingBranch] = React.useState(true);
```

### 3. Logic tải chi nhánh theo role
```javascript
React.useEffect(() => {
    const userId = localStorage.getItem("userId");
    const roleName = (localStorage.getItem("roleName") || "").toUpperCase();
    const isAdminUser = roleName === "ADMIN";
    
    if (isAdminUser) {
        // Admin: Load tất cả chi nhánh để chọn
        const branchesData = await listBranches({ page: 0, size: 100 });
        setAvailableBranches(branches);
        setBranchId(String(branches[0].branchId));
    } else {
        // Manager/Other: Lấy chi nhánh theo userId
        const branchData = await getBranchByUserId(Number(userId));
        setBranchId(String(branchData.branchId));
        setBranchName(branchData.branchName);
    }
}, []);
```

### 4. UI Component

#### Cho Admin (có dropdown chọn chi nhánh):
```jsx
<select
    value={branchId}
    onChange={(e) => {
        const selectedBranch = availableBranches.find(
            b => String(b.branchId) === e.target.value
        );
        setBranchId(e.target.value);
        if (selectedBranch) {
            setBranchName(selectedBranch.branchName);
        }
    }}
>
    {availableBranches.map((branch) => (
        <option key={branch.branchId} value={String(branch.branchId)}>
            {branch.branchName}
        </option>
    ))}
</select>
```

#### Cho Manager (hiển thị readonly):
```jsx
<span className="rounded-md border border-slate-300 bg-slate-100">
    Chi nhánh: {branchName || branchId}
</span>
```

## API Endpoints sử dụng

### 1. GET /api/branches/by-user/{userId}
- **Mục đích**: Lấy chi nhánh của Manager theo userId
- **Response**: 
```json
{
  "branchId": 1,
  "branchName": "Chi nhánh Hà Nội",
  "location": "123 Láng Hạ, Đống Đa, Hà Nội",
  "managerId": 2,
  "status": "ACTIVE"
}
```

### 2. GET /api/branches?page=0&size=100
- **Mục đích**: Lấy danh sách tất cả chi nhánh cho Admin
- **Response**:
```json
{
  "data": {
    "content": [
      {
        "branchId": 1,
        "branchName": "Chi nhánh Hà Nội",
        "location": "123 Láng Hạ, Đống Đa, Hà Nội",
        "status": "ACTIVE"
      },
      ...
    ]
  }
}
```

## Luồng hoạt động

1. **Khi component mount**:
   - Kiểm tra role từ `localStorage.getItem("roleName")`
   - Nếu ADMIN → Load tất cả chi nhánh
   - Nếu MANAGER → Load chi nhánh theo userId

2. **Admin chọn chi nhánh**:
   - Dropdown hiển thị tất cả chi nhánh ACTIVE
   - Khi chọn → Update `branchId` và `branchName`
   - `branchId` được dùng khi tạo đơn hàng

3. **Manager xem chi nhánh**:
   - Hiển thị readonly badge với tên chi nhánh
   - Không thể thay đổi

## Testing

### Test Case 1: Admin Login
1. Đăng nhập với tài khoản Admin
2. Vào trang Tạo đơn hàng
3. **Expected**: Thấy dropdown chọn chi nhánh với tất cả chi nhánh

### Test Case 2: Manager Login
1. Đăng nhập với tài khoản Manager (ví dụ: userId = 2, branchId = 1)
2. Vào trang Tạo đơn hàng
3. **Expected**: Thấy badge "Chi nhánh: Chi nhánh Hà Nội" (readonly)

### Test Case 3: Create Order với branch đúng
1. Admin chọn chi nhánh "Chi nhánh Đà Nẵng" (branchId = 2)
2. Điền thông tin đơn hàng và submit
3. **Expected**: API nhận `branchId: 2` trong request body

## Lưu ý

- API `getBranchByUserId` mapping: Users → Employees → Branches
- Nếu user không có branch → Hiển thị toast error
- Loading state được xử lý với spinner
- Branch selection chỉ áp dụng cho ADMIN role
- Manager/Consultant/Accountant sẽ thấy chi nhánh của họ (readonly)
