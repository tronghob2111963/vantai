# 📝 Hướng dẫn thêm trang Đánh giá tài xế vào Menu

## 🎯 Đã tạo 2 trang mới

### 1. **RatingManagementPage.jsx** - Quản lý đánh giá
- Danh sách các chuyến COMPLETED
- Lọc: Chưa đánh giá / Đã đánh giá / Tất cả
- Tìm kiếm theo tài xế, khách hàng, mã chuyến
- Nút "Đánh giá" cho từng chuyến
- Thống kê: Số chuyến chưa đánh giá, đã đánh giá, tổng

### 2. **DriverRatingsPage.jsx** - Chi tiết đánh giá tài xế
- Thông tin tài xế
- Hiệu suất 30 ngày (DriverPerformance component)
- Danh sách tất cả đánh giá với comment

---

## 🔧 Bước 1: Thêm vào AppLayout.jsx

Mở file `src/AppLayout.jsx` và thêm vào section "Điều phối / Lịch chạy":

```jsx
{
  sectionId: "dispatch",
  icon: CalendarClock,
  label: "Điều phối / Lịch chạy",
  roles: [ROLES.ADMIN, ROLES.MANAGER, ROLES.COORDINATOR],
  items: [
    { label: "Bảng điều phối", to: "/dispatch" },
    { label: "Đơn chưa gán chuyến", to: "/dispatch/pending" },
    { label: "Cảnh báo & Chờ duyệt", to: "/dispatch/notifications-dashboard" },
    { label: "Phiếu tạm ứng tài xế", to: "/dispatch/expense-request" },
    
    // ⭐ THÊM DÒNG NÀY
    { 
      label: "Đánh giá tài xế", 
      to: "/dispatch/ratings",
      roles: [ROLES.ADMIN, ROLES.MANAGER]  // Chỉ Admin và Manager
    },
  ],
},
```

---

## 🔧 Bước 2: Thêm Routes

Trong file `AppLayout.jsx`, tìm phần `<Routes>` và thêm:

```jsx
<Routes>
  {/* ... existing routes ... */}
  
  {/* ⭐ THÊM 2 ROUTES NÀY */}
  <Route 
    path="/dispatch/ratings" 
    element={<RatingManagementPage />} 
  />
  <Route 
    path="/drivers/:driverId/ratings" 
    element={<DriverRatingsPage />} 
  />
  
  {/* ... other routes ... */}
</Routes>
```

---

## 🔧 Bước 3: Import Components

Ở đầu file `AppLayout.jsx`, thêm imports:

```jsx
// Existing imports...
import RatingManagementPage from "./components/module 5/RatingManagementPage";
import DriverRatingsPage from "./components/module 5/DriverRatingsPage";
```

---

## 📋 Code hoàn chỉnh cần thêm

### Vị trí 1: Trong SIDEBAR_SECTIONS (dòng ~50)

```jsx
{
  sectionId: "dispatch",
  icon: CalendarClock,
  label: "Điều phối / Lịch chạy",
  roles: [ROLES.ADMIN, ROLES.MANAGER, ROLES.COORDINATOR],
  items: [
    { label: "Bảng điều phối", to: "/dispatch" },
    { label: "Đơn chưa gán chuyến", to: "/dispatch/pending" },
    { label: "Cảnh báo & Chờ duyệt", to: "/dispatch/notifications-dashboard" },
    { label: "Phiếu tạm ứng tài xế", to: "/dispatch/expense-request" },
    { label: "Gán tài xế (demo)", to: "/dispatch/assign-demo" },
    { label: "Đánh giá tài xế", to: "/dispatch/ratings", roles: [ROLES.ADMIN, ROLES.MANAGER] }, // ⭐ MỚI
  ],
},
```

### Vị trí 2: Trong phần imports (đầu file)

```jsx
import RatingManagementPage from "./components/module 5/RatingManagementPage";
import DriverRatingsPage from "./components/module 5/DriverRatingsPage";
```

### Vị trí 3: Trong <Routes> (tìm phần routing)

```jsx
{/* Dispatch Routes */}
<Route path="/dispatch" element={<div>Dispatch Dashboard</div>} />
<Route path="/dispatch/pending" element={<PendingTripsPage />} />
<Route path="/dispatch/notifications-dashboard" element={<NotificationsDashboard />} />
<Route path="/dispatch/expense-request" element={<ExpenseRequestForm />} />
<Route path="/dispatch/assign-demo" element={<DemoAssign />} />
<Route path="/dispatch/ratings" element={<RatingManagementPage />} /> {/* ⭐ MỚI */}

{/* Driver Routes */}
<Route path="/drivers/:driverId/ratings" element={<DriverRatingsPage />} /> {/* ⭐ MỚI */}
```

---

## 🎯 Kết quả

Sau khi thêm xong, trong menu sẽ xuất hiện:

```
📅 Điều phối / Lịch chạy
  ├─ Bảng điều phối
  ├─ Đơn chưa gán chuyến
  ├─ Cảnh báo & Chờ duyệt
  ├─ Phiếu tạm ứng tài xế
  └─ ⭐ Đánh giá tài xế  (MỚI - Chỉ Admin/Manager thấy)
```

---

## 🚀 Cách sử dụng

### 1. Trang Quản lý đánh giá (`/dispatch/ratings`)
- Admin/Manager vào menu → Click "Đánh giá tài xế"
- Xem danh sách các chuyến COMPLETED
- Lọc "Chưa đánh giá" để thấy các chuyến cần đánh giá
- Click nút "Đánh giá" → Popup hiện ra
- Chọn 4 tiêu chí (1-5 sao) + comment
- Submit → Đánh giá được lưu

### 2. Trang Chi tiết đánh giá tài xế (`/drivers/:driverId/ratings`)
- Từ trang quản lý, click vào tên tài xế
- Hoặc từ danh sách tài xế, thêm link "Xem đánh giá"
- Xem hiệu suất 30 ngày
- Xem tất cả đánh giá với comment

---

## 🔗 Liên kết giữa các trang

Để thêm link từ Driver List đến trang đánh giá:

```jsx
// Trong DriverList.jsx
<Link 
  to={`/drivers/${driver.driverId}/ratings`}
  className="text-blue-600 hover:underline"
>
  Xem đánh giá
</Link>
```

---

## ✅ Checklist

- [ ] Thêm import RatingManagementPage và DriverRatingsPage
- [ ] Thêm menu item "Đánh giá tài xế" vào section "Điều phối"
- [ ] Thêm route `/dispatch/ratings`
- [ ] Thêm route `/drivers/:driverId/ratings`
- [ ] Test: Vào menu → Click "Đánh giá tài xế"
- [ ] Test: Đánh giá một chuyến
- [ ] Test: Xem chi tiết đánh giá tài xế

---

## 🎨 Screenshots mô tả

### Trang Quản lý đánh giá
- 3 cards thống kê (Chưa đánh giá, Đã đánh giá, Tổng)
- Search bar + 3 nút filter
- Table với các chuyến COMPLETED
- Nút "Đánh giá" cho chuyến chưa có rating
- Nút "Xem chi tiết" cho chuyến đã có rating

### Popup đánh giá
- Header: "Đánh giá tài xế - Chuyến #123"
- 4 tiêu chí với 5 sao mỗi tiêu chí
- Textarea comment
- Nút "Hủy" và "Gửi đánh giá"

### Trang Chi tiết tài xế
- Header với avatar, tên, rating trung bình
- Section hiệu suất (DriverPerformance component)
- List tất cả đánh giá với breakdown 4 tiêu chí + comment

---

## 📞 Cần hỗ trợ?

Nếu gặp lỗi:
1. Check console log
2. Verify imports đúng path
3. Verify routes được thêm đúng
4. Check roles permission (ADMIN, MANAGER)
