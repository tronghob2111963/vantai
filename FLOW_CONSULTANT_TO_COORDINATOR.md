# PHÂN TÍCH FLOW: TƯ VẤN VIÊN TẠO ĐƠN → ĐIỀU PHỐI VIÊN THẤY ĐƠN

## 📋 TÓM TẮT FLOW

```
1. Tư vấn viên (Consultant) tạo đơn hàng
   ↓
2. Đơn được lưu với branchId của tư vấn viên
   ↓
3. Điều phối viên (Coordinator) xem danh sách đơn
   ↓
4. Hệ thống filter đơn theo branchId của điều phối viên
   ↓
5. Điều phối viên chỉ thấy đơn của chi nhánh mình
```

---

## 🔍 CHI TIẾT TỪNG BƯỚC

### **BƯỚC 1: Tư vấn viên tạo đơn**

**File:** `PTCMSS_FRONTEND/src/components/module 4/CreateOrderPage.jsx`

**Logic:**
1. Consultant đăng nhập → Lấy `userId` từ session
2. Gọi API: `getBranchByUserId(userId)` → Lấy `branchId` của consultant
3. Khi tạo đơn, gửi `branchId` lên backend:
   ```javascript
   const req = {
       customer: { fullName, phone, email },
       branchId: Number(branchId),  // ← BranchId của consultant
       consultantId: ..., // Backend tự set từ session
       ...
   };
   await createBooking(req);
   ```

**Code tham khảo:**
- Dòng 511: `const branchData = await getBranchByUserId(Number(userId));`
- Dòng 1017: `branchId: Number(branchId),` trong request

**Kết quả:**
- Đơn được lưu với `branchId` = branchId của consultant
- Đơn được lưu với `consultantId` = employeeId của consultant

---

### **BƯỚC 2: Backend lưu đơn**

**Database:**
- Bảng `bookings`:
  - `branchId` (NOT NULL) - Chi nhánh của đơn
  - `consultantId` (DEFAULT NULL) - Tư vấn viên tạo đơn

**Ví dụ từ database:**
```sql
INSERT INTO bookings VALUES (
    14,  -- bookingId
    8,   -- customerId
    1,   -- branchId (Chi nhánh Hà Nội)
    5,   -- consultantId (Điều Hành Viên 1 - employeeId = 5)
    ...
);
```

**Kiểm tra:**
```sql
-- Xem đơn và branchId, consultantId
SELECT 
    b.bookingId,
    b.branchId,
    br.branchName,
    b.consultantId,
    e.employeeId,
    u.fullName AS consultant_name
FROM bookings b
LEFT JOIN branches br ON b.branchId = br.branchId
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE b.bookingId = 14;
```

---

### **BƯỚC 3: Điều phối viên xem danh sách đơn**

**File:** `PTCMSS_FRONTEND/src/components/module 5/CoordinatorOrderListPage.jsx`

**Logic:**
1. Coordinator đăng nhập → Lấy `userId` từ session
2. Gọi API: `getBranchByUserId(userId)` → Lấy `branchId` của coordinator
3. Gọi API: `pageBookings({ branchId, ... })` → Filter đơn theo branchId
4. Hiển thị danh sách đơn

**Code tham khảo:**
- Dòng 56: `const resp = await getBranchByUserId(Number(userId));`
- Dòng 105: `params.branchId = Number(branchId);`
- Dòng 115: `const response = await pageBookings(params);`

**API Call:**
```javascript
GET /api/bookings?branchId=1&page=1&size=10&startDate=...&endDate=...
```

---

### **BƯỚC 4: Backend filter đơn theo branchId**

**API:** `GET /api/bookings`

**Logic backend (giả định):**
```sql
SELECT * FROM bookings 
WHERE branchId = ?  -- branchId từ query param
  AND (startDate <= ? AND endDate >= ?)  -- Date filter
  AND (hasTrip = ? OR hasTrip IS NULL)  -- Status filter
ORDER BY createdAt DESC;
```

**Điều kiện:**
- ✅ Đơn có `branchId` = branchId của coordinator → **HIỂN THỊ**
- ❌ Đơn có `branchId` ≠ branchId của coordinator → **KHÔNG HIỂN THỊ**

---

## ✅ ĐIỀU KIỆN ĐỂ COORDINATOR THẤY ĐƯỢC ĐƠN

### **Điều kiện BẮT BUỘC:**

1. **Consultant và Coordinator phải cùng branchId**
   ```
   consultant.branchId === coordinator.branchId
   ```

2. **Đơn phải có branchId đúng**
   ```
   booking.branchId === coordinator.branchId
   ```

3. **Backend API phải filter đúng theo branchId**
   ```
   WHERE bookings.branchId = :branchId
   ```

---

## 🔍 KIỂM TRA VẤN ĐỀ

### **Test Case 1: Kiểm tra branchId của Consultant và Coordinator**

```sql
-- Kiểm tra Consultant (employeeId = 5)
SELECT 
    e.employeeId,
    e.branchId AS consultant_branchId,
    br.branchName,
    u.fullName,
    u.username
FROM employees e
JOIN users u ON e.userId = u.userId
JOIN branches br ON e.branchId = br.branchId
WHERE e.employeeId = 5;  -- Điều Hành Viên 1

-- Kiểm tra Coordinator (tìm employee có roleId = 2 - Manager/Coordinator)
SELECT 
    e.employeeId,
    e.branchId AS coordinator_branchId,
    br.branchName,
    r.roleName,
    u.fullName,
    u.username
FROM employees e
JOIN users u ON e.userId = u.userId
JOIN roles r ON e.roleId = r.roleId
JOIN branches br ON e.branchId = br.branchId
WHERE r.roleName = 'Coordinator'  -- Hoặc roleId = 2
  AND e.branchId = 1;  -- Chi nhánh Hà Nội
```

### **Test Case 2: Kiểm tra đơn có branchId đúng không**

```sql
-- Xem đơn bookingId = 14
SELECT 
    b.bookingId,
    b.branchId,
    br.branchName,
    b.consultantId,
    e.employeeId AS consultant_employeeId,
    e.branchId AS consultant_branchId,
    u.fullName AS consultant_name
FROM bookings b
LEFT JOIN branches br ON b.branchId = br.branchId
LEFT JOIN employees e ON b.consultantId = e.employeeId
LEFT JOIN users u ON e.userId = u.userId
WHERE b.bookingId = 14;
```

### **Test Case 3: Kiểm tra API có filter đúng không**

**Frontend gửi:**
```javascript
GET /api/bookings?branchId=1&page=1&size=10
```

**Backend phải filter:**
```sql
SELECT * FROM bookings 
WHERE branchId = 1  -- ← Phải có điều kiện này
ORDER BY createdAt DESC;
```

---

## 🐛 CÁC VẤN ĐỀ CÓ THỂ XẢY RA

### **Vấn đề 1: Consultant và Coordinator khác branchId**
- **Nguyên nhân:** Consultant ở chi nhánh A, Coordinator ở chi nhánh B
- **Giải pháp:** Đảm bảo cùng chi nhánh hoặc cho phép Coordinator xem nhiều chi nhánh

### **Vấn đề 2: Backend không filter theo branchId**
- **Nguyên nhân:** API không có logic filter `WHERE branchId = ?`
- **Giải pháp:** Kiểm tra backend code, đảm bảo có filter

### **Vấn đề 3: Frontend không gửi branchId**
- **Nguyên nhân:** `getBranchByUserId()` trả về null hoặc sai format
- **Giải pháp:** Kiểm tra response format, thêm log để debug

### **Vấn đề 4: Date filter sai timezone**
- **Nguyên nhân:** Date filter dùng UTC nhưng createdAt lưu ở UTC+7
- **Giải pháp:** Đã sửa ở query SQL, cần kiểm tra backend API

---

## 📝 CHECKLIST KIỂM TRA

- [ ] Consultant và Coordinator có cùng `branchId` không?
- [ ] Đơn được tạo với `branchId` đúng không?
- [ ] Frontend gửi `branchId` trong API request không?
- [ ] Backend API có filter theo `branchId` không?
- [ ] Date filter có đúng timezone không?
- [ ] Console log có lỗi gì không?

---

## 🔧 CÁCH DEBUG

### **1. Kiểm tra Console Log (Frontend)**

Mở Developer Console và xem:
```
[CoordinatorOrderListPage] Loading branch for userId: ...
[CoordinatorOrderListPage] Branch response: ...
[CoordinatorOrderListPage] Extracted branchId: ...
[CoordinatorOrderListPage] Fetching orders with params: { branchId: 1, ... }
[CoordinatorOrderListPage] Orders response: ...
[CoordinatorOrderListPage] Total orders found: ...
```

### **2. Kiểm tra Network Tab**

Xem API request:
```
GET /api/bookings?branchId=1&page=1&size=10&startDate=...&endDate=...
```

Kiểm tra:
- ✅ `branchId` có trong query params không?
- ✅ Response có trả về đơn không?
- ✅ Đơn có `branchId` đúng không?

### **3. Kiểm tra Database**

```sql
-- Xem đơn và branchId
SELECT bookingId, branchId, consultantId, createdAt, status
FROM bookings
WHERE branchId = 1  -- BranchId của coordinator
ORDER BY createdAt DESC
LIMIT 10;
```

---

## ✅ KẾT LUẬN

**Flow đúng:**
1. Consultant tạo đơn với `branchId` của mình ✅
2. Coordinator lấy `branchId` của mình ✅
3. Coordinator filter đơn theo `branchId` ✅
4. **Điều kiện:** Consultant và Coordinator phải cùng `branchId` ✅

**Nếu Coordinator không thấy đơn:**
- Kiểm tra xem Consultant và Coordinator có cùng `branchId` không
- Kiểm tra xem đơn có `branchId` đúng không
- Kiểm tra xem backend API có filter đúng không
- Kiểm tra console log và network request

