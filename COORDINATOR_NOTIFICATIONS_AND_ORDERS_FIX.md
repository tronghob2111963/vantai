# Sửa lỗi Thông báo và Danh sách đơn hàng - Coordinator

## Tổng quan

Đã thực hiện 2 sửa lỗi chính:

1. **Danh sách đơn hàng**: Sửa filter "chưa gắn/đã gắn chuyến" không hoạt động
2. **Cảnh báo chờ duyệt**: Đảm bảo chỉ hiển thị thông báo liên quan đến chi nhánh mình

---

## 1. Sửa lỗi Filter Danh sách đơn hàng

### Vấn đề
- Filter "Chưa gắn chuyến" / "Đã gắn chuyến" không hoạt động
- Backend API `pageBookings` không hỗ trợ tham số `hasTrip`

### Giải pháp
Thực hiện filter phía client sau khi nhận data từ backend:

```javascript
// Client-side filter for assigned/unassigned status
if (filterStatus === "ASSIGNED") {
    content = content.filter(order => order.tripId != null && order.tripId !== "");
} else if (filterStatus === "UNASSIGNED") {
    content = content.filter(order => order.tripId == null || order.tripId === "");
}
```

### Logic filter
- **Tất cả**: Hiển thị tất cả đơn hàng
- **Chưa gắn chuyến**: Lọc đơn có `tripId == null` hoặc `tripId === ""`
- **Đã gắn chuyến**: Lọc đơn có `tripId != null` và `tripId !== ""`

### Lưu ý
- Đây là giải pháp tạm thời filter phía client
- Nên yêu cầu backend thêm tham số `hasTrip` hoặc `assignmentStatus` để filter hiệu quả hơn
- Với filter phía client, pagination có thể không chính xác nếu số lượng đơn lớn

### Đề xuất cải tiến backend
Thêm tham số vào API `GET /api/bookings`:
```
?hasTrip=true   // Chỉ lấy đơn đã gắn chuyến
?hasTrip=false  // Chỉ lấy đơn chưa gắn chuyến
```

---

## 2. Cảnh báo chờ duyệt - Chỉ hiển thị thông báo chi nhánh mình

### Yêu cầu
Coordinator/Manager chỉ nhìn thấy:
- Cảnh báo liên quan đến xe/tài xế/chi phí của chi nhánh mình
- Yêu cầu chờ duyệt từ chi nhánh mình
- Thông báo đã duyệt do mình xử lý

### Logic hiện tại

#### Load branch của user
```javascript
// Với Manager/Coordinator, tự động load chi nhánh của họ
const branch = await getBranchByUserId(userId);
setUserBranchId(branchId);
setSelectedBranchId(branchId);
```

#### Load dashboard theo chi nhánh
```javascript
// API tự động filter theo branchId
const params = selectedBranchId ? `?branchId=${selectedBranchId}` : "";
const data = await apiFetch(`/api/notifications/dashboard${params}`);
```

#### Load thông báo đã duyệt
```javascript
// Chỉ lấy những yêu cầu do current user duyệt
const params = new URLSearchParams();
if (selectedBranchId) params.append("branchId", selectedBranchId);
if (userId) params.append("processedByUserId", userId);

const data = await apiFetch(`/api/notifications/approvals/processed?${params}`);
```

### Phân quyền duyệt

#### Coordinator
- **Được duyệt**: Nghỉ phép tài xế (`DRIVER_DAY_OFF`)
- **Không được duyệt**: Chi phí (`EXPENSE_REQUEST`), Giảm giá (`DISCOUNT_REQUEST`)

#### Manager
- **Được duyệt**: Tất cả loại yêu cầu

#### Admin
- **Được duyệt**: Tất cả loại yêu cầu
- **Có thể chọn**: Xem tất cả chi nhánh hoặc chi nhánh cụ thể

```javascript
const canApproveType = (approvalType) => {
    if (isAdmin || isManager) return true;
    if (isCoordinator && approvalType === "DRIVER_DAY_OFF") return true;
    return false;
};
```

### Các loại thông báo

#### 1. Cảnh báo hệ thống (Alerts)
- Xe sắp hết đăng kiểm
- Bằng lái tài xế hết hạn
- Xung đột lịch
- Xe cần bảo trì
- Tài xế vi phạm

**Filter**: Theo `branchId` của user

#### 2. Yêu cầu chờ duyệt (Pending Approvals)
- Nghỉ phép tài xế (`DRIVER_DAY_OFF`)
- Yêu cầu tạm ứng (`EXPENSE_REQUEST`)
- Yêu cầu giảm giá (`DISCOUNT_REQUEST`)

**Filter**: 
- Theo `branchId` của user
- Chỉ hiển thị nút duyệt nếu có quyền (`canApproveType`)

#### 3. Thông báo đã duyệt (Processed Approvals)
- Các yêu cầu đã được duyệt/từ chối
- **Chỉ hiển thị**: Những yêu cầu do current user xử lý

**Filter**:
- `branchId`: Chi nhánh của user
- `processedByUserId`: ID của user hiện tại

---

## API Requirements

### Backend cần hỗ trợ

#### 1. GET /api/notifications/dashboard
```
Query params:
- branchId: number (required for Manager/Coordinator)

Response:
{
  stats: {
    totalAlerts: number,
    criticalAlerts: number,
    totalPendingApprovals: number,
    driverDayOffRequests: number
  },
  alerts: [
    {
      id: number,
      title: string,
      message: string,
      severity: "CRITICAL" | "HIGH" | "MEDIUM" | "LOW",
      branchId: number,
      branchName: string,
      createdAt: string,
      isAcknowledged: boolean
    }
  ],
  pendingApprovals: [
    {
      id: number,
      approvalType: "DRIVER_DAY_OFF" | "EXPENSE_REQUEST" | "DISCOUNT_REQUEST",
      requestedByName: string,
      requestedAt: string,
      requestReason: string,
      branchId: number,
      details: {
        // Tùy theo loại
        driverName?: string,
        startDate?: string,
        endDate?: string,
        amount?: number,
        type?: string
      }
    }
  ]
}
```

#### 2. GET /api/notifications/approvals/processed
```
Query params:
- branchId: number (optional)
- processedByUserId: number (required) - Chỉ lấy yêu cầu do user này duyệt
- limit: number (default: 50)

Response: Array of processed approvals
[
  {
    id: number,
    approvalType: string,
    status: "APPROVED" | "REJECTED",
    requestedByName: string,
    requestedAt: string,
    processedAt: string,
    approvedByName: string,
    approvalNote: string,
    branchId: number,
    details: {...}
  }
]
```

#### 3. POST /api/notifications/approvals/{id}/approve
```
Body:
{
  userId: number,
  note: string (optional)
}

Response: Success message
```

#### 4. POST /api/notifications/approvals/{id}/reject
```
Body:
{
  userId: number,
  note: string (required)
}

Response: Success message
```

#### 5. POST /api/notifications/alerts/{id}/acknowledge
```
Body:
{
  userId: number
}

Response: Success message
```

---

## Testing

### Test cases cho Danh sách đơn hàng

1. **Filter "Tất cả"**
   - Hiển thị tất cả đơn hàng của chi nhánh
   - Bao gồm cả đã gắn và chưa gắn chuyến

2. **Filter "Chưa gắn chuyến"**
   - Chỉ hiển thị đơn có `tripId == null` hoặc `tripId === ""`
   - Badge hiển thị "Chưa gắn" màu cam

3. **Filter "Đã gắn chuyến"**
   - Chỉ hiển thị đơn có `tripId != null` và `tripId !== ""`
   - Nút "Xem chuyến" màu xanh

4. **Tìm kiếm**
   - Hoạt động với cả 3 filter
   - Tìm theo mã đơn, tên khách hàng, số điện thoại

5. **Phân trang**
   - Pagination hoạt động đúng với filter
   - Reset về trang 1 khi đổi filter

### Test cases cho Cảnh báo chờ duyệt

1. **Coordinator**
   - Chỉ thấy cảnh báo/yêu cầu của chi nhánh mình
   - Chỉ được duyệt nghỉ phép tài xế
   - Không thấy nút duyệt cho chi phí/giảm giá
   - Thông báo đã duyệt chỉ hiển thị những yêu cầu do mình xử lý

2. **Manager**
   - Chỉ thấy cảnh báo/yêu cầu của chi nhánh mình
   - Được duyệt tất cả loại yêu cầu
   - Thông báo đã duyệt chỉ hiển thị những yêu cầu do mình xử lý

3. **Admin**
   - Có thể chọn xem tất cả chi nhánh
   - Được duyệt tất cả loại yêu cầu
   - Thông báo đã duyệt chỉ hiển thị những yêu cầu do mình xử lý

4. **Duyệt yêu cầu**
   - Duyệt: Có thể để trống ghi chú
   - Từ chối: Bắt buộc nhập lý do
   - Sau khi duyệt/từ chối, card hiển thị trạng thái và note
   - Refresh tự động sau khi xử lý

5. **Xác nhận cảnh báo**
   - Click "Xác nhận" để đánh dấu đã biết
   - Cảnh báo biến mất khỏi danh sách sau khi xác nhận

---

## Files Changed

1. `vantai/PTCMSS_FRONTEND/src/components/module 5/CoordinatorOrderListPage.jsx`
   - Thêm client-side filter cho assigned/unassigned status

2. `vantai/PTCMSS_FRONTEND/src/components/module 5/NotificationsDashboard.jsx`
   - Đã có logic filter theo chi nhánh
   - Đã có logic phân quyền duyệt
   - Đã có logic chỉ hiển thị thông báo đã duyệt do mình xử lý

---

## Notes

### Danh sách đơn hàng
- Filter hiện tại hoạt động phía client
- Nên yêu cầu backend hỗ trợ tham số `hasTrip` để filter hiệu quả hơn
- Với số lượng đơn lớn, nên filter phía server

### Cảnh báo chờ duyệt
- Logic đã đúng, chỉ cần đảm bảo backend API trả về đúng data
- Backend phải filter theo `branchId` khi user không phải Admin
- Backend phải filter theo `processedByUserId` cho thông báo đã duyệt
- Coordinator chỉ được duyệt nghỉ phép, không được duyệt chi phí

### Bảo mật
- Backend phải validate quyền duyệt trước khi xử lý
- Không cho phép Coordinator duyệt chi phí/giảm giá
- Chỉ cho phép xem/duyệt yêu cầu của chi nhánh mình (trừ Admin)
