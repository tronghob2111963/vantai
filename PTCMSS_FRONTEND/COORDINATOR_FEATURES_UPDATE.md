# Cập nhật chức năng cho Role Coordinator

## Tổng quan
Đã cập nhật và bổ sung các chức năng cho vai trò Điều phối viên (Coordinator) trong hệ thống quản lý vận tải.

## Các thay đổi chính

### 1. Sidebar mới cho Coordinator

Đã cập nhật sidebar trong `AppLayout.jsx` với các chức năng sau:

#### **Bảng điều phối**
- Route: `/dispatch`
- Component: `CoordinatorTimelinePro`
- Giữ nguyên chức năng hiện tại
- Hiển thị lịch trình tài xế và xe trong ngày

#### **Danh sách đơn** (MỚI)
- Route: `/coordinator/orders`
- Component: `CoordinatorOrderListPage`
- Filter theo đơn đã gắn/chưa gắn chuyến:
  - **Chưa gắn chuyến**: Hiển thị các đơn chưa được gán tài xế/xe
  - **Đã gắn chuyến**: Có button xem chi tiết chuyến
  - Hiển thị thông tin chung của chuyến
  - Hiển thị chi phí phụ trội / sự cố chuyến xe
- Tìm kiếm theo mã đơn, tên khách hàng, số điện thoại
- Phân trang

#### **Danh sách tài xế** (MỚI)
- Route: `/coordinator/drivers`
- Component: `CoordinatorDriverListPage`
- View list tài xế chi nhánh
- Quyền xem chi tiết và cập nhật hồ sơ tài xế:
  - Ngày hết hạn GPLX
  - Hạng GPLX
  - Thời gian khám sức khỏe mới nhất
- Hiển thị cảnh báo khi GPLX sắp hết hạn (< 30 ngày)
- Tìm kiếm theo tên, số điện thoại
- Phân trang

#### **Danh sách xe** (MỚI)
- Route: `/coordinator/vehicles`
- Component: `CoordinatorVehicleListPage`
- View list xe của chi nhánh
- Quyền xem chi tiết và cập nhật hồ sơ xe:
  - Ngày hết hạn đăng kiểm
  - Ngày hết hạn bảo hiểm
  - Trạng thái xe (Sẵn sàng, Đang sử dụng, Bảo trì, Không hoạt động)
  - Các thông tin khác chỉ view
- Hiển thị cảnh báo khi đăng kiểm/bảo hiểm sắp hết hạn (< 30 ngày)
- Tìm kiếm theo biển số, loại xe
- Phân trang

#### **Cảnh báo chờ duyệt**
- Route: `/dispatch/notifications-dashboard`
- Component: `NotificationsDashboard`
- Giữ nguyên chức năng hiện tại

#### **Tạo yêu cầu thanh toán** (ĐỔI TÊN)
- Route: `/dispatch/expense-request`
- Component: `ExpenseRequestForm`
- Đổi tên từ "Phiếu tạm ứng tài xế" thành "Tạo yêu cầu thanh toán"
- Nội dung giữ nguyên

#### **Đánh giá tài xế** (CẢI THIỆN)
- Route: `/dispatch/ratings`
- Component: `RatingManagementPage`
- Đã cải thiện:
  - ✅ Thêm phân trang (10 items/trang)
  - ✅ Căn chỉnh các cột và hàng thẳng nhau
  - ✅ Sử dụng `table-fixed` với width cố định cho mỗi cột
  - ✅ Thêm `align-top` để các cell căn đều
  - ✅ Thêm `truncate` cho text dài
  - ✅ Giữ nguyên trạng thái khi thay đổi (đã đánh giá/chưa đánh giá)
- Coordinator giờ có quyền truy cập trang này

## Các file đã tạo mới

1. **CoordinatorOrderListPage.jsx**
   - Quản lý danh sách đơn hàng
   - Filter đơn đã gắn/chưa gắn chuyến
   - Xem chi tiết chuyến và đơn hàng

2. **CoordinatorDriverListPage.jsx**
   - Quản lý danh sách tài xế
   - Xem và cập nhật hồ sơ tài xế
   - Cảnh báo GPLX hết hạn

3. **CoordinatorVehicleListPage.jsx**
   - Quản lý danh sách xe
   - Xem và cập nhật hồ sơ xe
   - Cảnh báo đăng kiểm/bảo hiểm hết hạn

## Các file đã cập nhật

1. **AppLayout.jsx**
   - Cập nhật SIDEBAR_SECTIONS cho Coordinator
   - Thêm import các component mới
   - Thêm routes mới cho Coordinator
   - Cập nhật quyền truy cập cho các route

2. **RatingManagementPage.jsx**
   - Thêm phân trang với Pagination component
   - Cải thiện layout table với `table-fixed`
   - Căn chỉnh các cột với width cố định
   - Thêm `align-top` và `truncate` cho text
   - Giảm padding từ `px-6` xuống `px-4` để tối ưu không gian

## Yêu cầu Backend

Để các chức năng hoạt động đầy đủ, cần đảm bảo backend có:

1. **API cho Coordinator**
   - GET `/api/drivers` - Lấy danh sách tài xế theo chi nhánh
   - GET `/api/drivers/{id}` - Xem chi tiết tài xế
   - PUT `/api/drivers/{id}` - Cập nhật hồ sơ tài xế (GPLX, khám sức khỏe)
   - GET `/api/vehicles` - Lấy danh sách xe theo chi nhánh
   - GET `/api/vehicles/{id}` - Xem chi tiết xe
   - PUT `/api/vehicles/{id}` - Cập nhật hồ sơ xe (đăng kiểm, bảo hiểm, trạng thái)
   - GET `/api/bookings` - Lấy danh sách đơn với filter `hasTrip`
   - GET `/api/bookings/{id}/trip` - Xem chi tiết chuyến của đơn

2. **Quyền truy cập**
   - Coordinator cần có quyền:
     - Xem và cập nhật hồ sơ tài xế (giới hạn: GPLX, khám sức khỏe)
     - Xem và cập nhật hồ sơ xe (giới hạn: đăng kiểm, bảo hiểm, trạng thái)
     - Xem danh sách đơn và chi tiết chuyến
     - Truy cập trang đánh giá tài xế

## Ghi chú

- Tất cả các component mới đều sử dụng design system hiện tại với màu chủ đạo `#0079BC`
- Các component có responsive design và hoạt động tốt trên mobile
- Sử dụng Pagination component có sẵn để đồng nhất UI
- Các cảnh báo hết hạn được highlight bằng màu:
  - Đỏ: Đã hết hạn
  - Cam: Còn < 30 ngày
  - Xanh: Còn > 30 ngày

## Kiểm tra

Để kiểm tra các chức năng mới:

1. Đăng nhập với tài khoản có role COORDINATOR
2. Kiểm tra sidebar có đầy đủ các menu mới
3. Truy cập từng trang và kiểm tra:
   - Danh sách hiển thị đúng
   - Filter hoạt động
   - Tìm kiếm hoạt động
   - Phân trang hoạt động
   - Button xem chi tiết và cập nhật hoạt động
   - Cảnh báo hết hạn hiển thị đúng màu

## Các bước tiếp theo

1. Tạo các trang chi tiết và form cập nhật cho:
   - `/coordinator/drivers/{id}` - Chi tiết tài xế
   - `/coordinator/drivers/{id}/edit` - Cập nhật hồ sơ tài xế
   - `/coordinator/vehicles/{id}` - Chi tiết xe
   - `/coordinator/vehicles/{id}/edit` - Cập nhật hồ sơ xe
   - `/orders/{orderId}/trip/{tripId}` - Chi tiết chuyến

2. Cập nhật backend để hỗ trợ các API mới

3. Test tích hợp với backend thực tế
