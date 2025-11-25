# Test Branch API

## Cách test trong browser console

1. Mở trang Create Order
2. Mở Developer Tools (F12)
3. Vào tab Console
4. Chạy các lệnh sau:

### Test 1: Kiểm tra localStorage
```javascript
console.log("userId:", localStorage.getItem("userId"));
console.log("roleName:", localStorage.getItem("roleName"));
console.log("access_token:", localStorage.getItem("access_token") ? "exists" : "missing");
```

### Test 2: Test API listBranches
```javascript
fetch('http://localhost:8080/api/branches?page=0&size=100', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem("access_token")}`,
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => {
  console.log("✅ Branches API Response:", data);
  console.log("Structure check:");
  console.log("- data.data:", data.data);
  console.log("- data.content:", data.content);
  console.log("- data.data.content:", data.data?.content);
})
.catch(err => console.error("❌ Error:", err));
```

### Test 3: Test API getBranchByUserId
```javascript
const userId = localStorage.getItem("userId");
fetch(`http://localhost:8080/api/branches/by-user/${userId}`, {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem("access_token")}`,
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => {
  console.log("✅ Branch by User Response:", data);
})
.catch(err => console.error("❌ Error:", err));
```

## Expected Response Structures

### listBranches Response (từ BranchController)
```json
{
  "code": 200,
  "message": "Get all branches successfully",
  "data": {
    "content": [
      {
        "branchId": 1,
        "branchName": "Chi nhánh Hà Nội",
        "location": "123 Láng Hạ, Đống Đa, Hà Nội",
        "managerId": 2,
        "status": "ACTIVE",
        "createdAt": "2025-11-12T11:23:08"
      }
    ],
    "pageable": {...},
    "totalElements": 6,
    "totalPages": 1
  }
}
```

### getBranchByUserId Response
```json
{
  "branchId": 1,
  "branchName": "Chi nhánh Hà Nội",
  "location": "123 Láng Hạ, Đống Đa, Hà Nội",
  "managerId": 2,
  "status": "ACTIVE"
}
```

## Troubleshooting

### Nếu không thấy dropdown Admin:
1. Check `roleName` phải là "Admin" (chính xác case)
2. Check `availableBranches` phải có data
3. Check console logs có lỗi API không

### Nếu API trả về 403 Forbidden:
- Check access_token còn valid không
- Check user có quyền ADMIN/MANAGER không

### Nếu API trả về empty array:
- Check database có branches với status="ACTIVE" không
- Check API endpoint có filter theo status không
