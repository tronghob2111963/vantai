# 📊 Danh Sách Tables Trong Database

**Tổng số bảng**: **28 tables**

---

## 📋 Danh Sách Chi Tiết

### **1. Core Tables (12 tables)**
1. `users` - Người dùng hệ thống
2. `roles` - Vai trò người dùng
3. `employees` - Nhân viên
4. `branches` - Chi nhánh
5. `customers` - Khách hàng
6. `drivers` - Tài xế
7. `vehicles` - Xe
8. `bookings` - Đặt xe
9. `trips` - Chuyến đi
10. `invoices` - Hóa đơn
11. `notifications` - Thông báo
12. `token` - Token đăng nhập

### **2. Relationship Tables (5 tables)**
13. `booking_vehicle_details` - Chi tiết loại xe trong booking
14. `trip_drivers` - Tài xế gán cho chuyến đi
15. `trip_vehicles` - Xe gán cho chuyến đi
16. `expense_request_attachments` - File đính kèm yêu cầu chi phí
17. `trip_assignment_history` - Lịch sử gán chuyến đi

### **3. Configuration Tables (3 tables)**
18. `hire_types` - Loại hình thuê xe
19. `vehicle_category_pricing` - Bảng giá theo loại xe
20. `system_settings` - Cài đặt hệ thống

### **4. Financial Tables (2 tables)**
21. `accounts_receivable` - Công nợ phải thu
22. `expense_requests` - Yêu cầu chi phí

### **5. Approval & History Tables (3 tables)**
23. `approval_history` - Lịch sử duyệt
24. `driver_day_off` - Ngày nghỉ của tài xế
25. `trip_incidents` - Sự cố trong chuyến đi

### **6. System & Analytics Tables (3 tables)**
26. `system_alerts` - Cảnh báo hệ thống
27. `driver_ratings` - Đánh giá tài xế
28. `trip_route_cache` - Cache tuyến đường

---

## 📊 Phân Loại Theo Naming Convention

### **Snake_case (Multi-word) - 15 tables:**
- `accounts_receivable`
- `approval_history`
- `booking_vehicle_details`
- `driver_day_off`
- `driver_ratings`
- `expense_request_attachments`
- `expense_requests`
- `hire_types`
- `system_alerts`
- `system_settings`
- `trip_assignment_history`
- `trip_drivers`
- `trip_incidents`
- `trip_route_cache`
- `trip_vehicles`
- `vehicle_category_pricing`

### **Single-word (Lowercase) - 12 tables:**
- `bookings`
- `branches`
- `customers`
- `drivers`
- `employees`
- `invoices`
- `notifications`
- `roles`
- `token`
- `trips`
- `users`
- `vehicles`

---

## ✅ Tổng Kết

- **Tổng số bảng**: **28 tables**
- **Snake_case**: 16 tables (57%)
- **Single-word**: 12 tables (43%)
- **Views**: 3 views
  - `v_drivermonthlyperformance`
  - `v_popularroutes`
  - `v_tripdistanceanalytics`

---

**Ngày cập nhật**: 2025-11-22  
**Trạng thái**: ✅ Tất cả tables đã đúng naming convention

