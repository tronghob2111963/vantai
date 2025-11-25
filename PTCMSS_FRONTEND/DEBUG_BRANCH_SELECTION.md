# Debug Branch Selection Issue

## Vấn đề
Dropdown chọn chi nhánh cho Admin không hiển thị trên trang Create Order.

## Các bước debug

### Bước 1: Kiểm tra Console Logs
1. Mở trang Create Order
2. Mở Developer Tools (F12) → Tab Console
3. Tìm các log sau:

```
🔍 Branch Loading Debug: { userId: "...", roleName: "...", isAdminUser: true/false }
👑 Loading branches for Admin... (nếu là Admin)
📦 Branches API Response: {...}
✅ Extracted branches: [...]
✅ Set default branch: {...}
✅ Branch loading completed
```

### Bước 2: Kiểm tra Debug Panel
Trên đầu trang sẽ có một panel màu vàng hiển thị:
- `loadingBranch`: phải là `false` sau khi load xong
- `isAdmin`: phải là `true` nếu bạn là Admin
- `branchId`: phải có giá trị
- `branchName`: phải có tên chi nhánh
- `availableBranches`: phải > 0 items nếu là Admin
- `roleName`: phải là "Admin" hoặc "ADMIN"

### Bước 3: Kiểm tra localStorage
Trong Console, chạy:
```javascript
console.log({
  userId: localStorage.getItem("userId"),
  roleName: localStorage.getItem("roleName"),
  access_token: localStorage.getItem("access_token") ? "exists" : "missing"
});
```

**Expected cho Admin:**
- `roleName`: "Admin" hoặc "ADMIN" (case-insensitive)
- `userId`: có giá trị
- `access_token`: "exists"

### Bước 4: Test API trực tiếp
Trong Console, chạy:

```javascript
// Test listBranches API
fetch('http://localhost:8080/api/branches?page=0&size=100', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem("access_token")}`,
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => {
  console.log("✅ API Response:", data);
  console.log("Content:", data.data?.content || data.content);
})
.catch(err => console.error("❌ Error:", err));
```

## Các trường hợp lỗi thường gặp

### Case 1: `isAdmin = false` nhưng bạn là Admin
**Nguyên nhân:** `roleName` trong localStorage không đúng format
**Giải pháp:** 
- Check `localStorage.getItem("roleName")` 
- Có thể là "ADMIN", "Admin", hoặc có khoảng trắng
- Code đã xử lý case-insensitive, nhưng cần trim()

### Case 2: `availableBranches = 0` items
**Nguyên nhân:** API không trả về data hoặc format không đúng
**Giải pháp:**
- Check console log "📦 Branches API Response"
- Check structure: `data.data.content` vs `data.content`
- Check database có branches với status="ACTIVE"

### Case 3: API trả về 403 Forbidden
**Nguyên nhân:** Token hết hạn hoặc không có quyền
**Giải pháp:**
- Logout và login lại
- Check role trong database

### Case 4: Dropdown không hiển thị dù `isAdmin = true`
**Nguyên nhân:** `loadingBranch` vẫn đang `true` hoặc `availableBranches` rỗng
**Giải pháp:**
- Check debug panel
- Check network tab xem API có được gọi không
- Check có lỗi trong console không

## Expected UI States

### Admin (isAdmin = true, availableBranches > 0):
```
[Building Icon] [Dropdown: Chi nhánh Hà Nội ▼]
```

### Manager (isAdmin = false):
```
[Building Icon] Chi nhánh: Chi nhánh Hà Nội
```

### Loading:
```
[Spinner Icon] Đang tải chi nhánh...
```

## Quick Fix Commands

### Nếu cần reset localStorage:
```javascript
localStorage.setItem("roleName", "Admin");
localStorage.setItem("userId", "1"); // Thay bằng userId thực
```

### Nếu cần force reload:
```javascript
window.location.reload();
```

## Contact
Nếu vẫn không hoạt động sau các bước trên, cung cấp:
1. Screenshot của Debug Panel (panel màu vàng)
2. Console logs (toàn bộ)
3. Network tab → API call `/api/branches` → Response
