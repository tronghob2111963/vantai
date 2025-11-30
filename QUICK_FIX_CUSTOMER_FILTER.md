# Quick Fix - Customer Filter cho Manager

## Giải pháp đơn giản

Thay vì dùng userId ở backend (phức tạp, cần parse, check role), chúng ta sử dụng cách đơn giản hơn:

### Frontend tự động set branchId cho Manager

**CustomerListPage.jsx**
- Khi Manager load trang, tự động gọi `getEmployeeByUserId()` để lấy branchId
- Tự động set `branchId` state = branchId của Manager
- Ẩn dropdown "Chi nhánh" để Manager không thể thay đổi
- Khi fetch customers, branchId đã được set sẵn nên API sẽ tự động filter

### Backend không cần thay đổi

**CustomerRepository.findWithFilters()**
- Đã có sẵn logic filter theo branchId
- Không cần thêm logic check role

## Ưu điểm

1. **Đơn giản**: Không cần parse userId, không cần check role ở backend
2. **An toàn**: Manager không thể thay đổi branchId vì dropdown bị ẩn
3. **Hiệu quả**: Sử dụng lại logic filter có sẵn

## Test

1. Đăng nhập với tài khoản Manager
2. Vào trang "Danh sách khách hàng"
3. Kiểm tra:
   - Console log: `[CustomerListPage] Manager branch loaded: { branchId: X, branchName: "..." }`
   - Dropdown "Chi nhánh" bị ẩn
   - Chỉ hiển thị khách hàng của chi nhánh X
   - Header hiển thị: "Chi nhánh: [Tên chi nhánh]"

## Rollback backend changes (Optional)

Nếu muốn đơn giản hóa backend, có thể rollback các thay đổi về userId:

1. CustomerController: Xóa param `userId`
2. CustomerService: Xóa param `userId`
3. CustomerServiceImpl: Xóa logic check role

Nhưng giữ lại cũng không sao, vì nó không ảnh hưởng gì.
