# Tài liệu Yêu cầu

## Giới thiệu

Tài liệu này giải quyết các vấn đề quan trọng trong hệ thống quản lý chi nhánh: tên chi nhánh có thể bị trùng lặp và số điện thoại không được lưu vào cơ sở dữ liệu. Hiện tại hệ thống chấp nhận số điện thoại qua API nhưng thiếu cấu trúc database để lưu trữ, và không có validation để ngăn chặn tên chi nhánh trùng lặp.

## Thuật ngữ

- **Hệ thống Quản lý Chi nhánh**: Module chịu trách nhiệm tạo, cập nhật và quản lý thông tin chi nhánh/cơ sở
- **Branches Entity**: Entity JPA đại diện cho chi nhánh trong database (bảng: `branches`)
- **CreateBranchRequest**: DTO (Data Transfer Object) dùng để tạo chi nhánh mới
- **UpdateBranchRequest**: DTO dùng để cập nhật chi nhánh
- **BranchService**: Lớp service xử lý logic nghiệp vụ của chi nhánh
- **BranchesRepository**: Lớp truy cập dữ liệu cho entity chi nhánh
- **Số điện thoại**: Số liên lạc của chi nhánh, định dạng Việt Nam (10 chữ số)

## Yêu cầu

### Yêu cầu 1: Ngăn chặn Tên Chi nhánh Trùng lặp

**User Story:** Là Admin, tôi muốn hệ thống ngăn chặn việc tạo chi nhánh với tên trùng lặp, để mỗi chi nhánh có tên duy nhất và không gây nhầm lẫn trong hệ thống.

#### Tiêu chí chấp nhận

1. WHEN Admin cố gắng tạo chi nhánh với tên đã tồn tại (không phân biệt hoa thường), THEN HỆ THỐNG Quản lý Chi nhánh SHALL từ chối yêu cầu với thông báo lỗi rõ ràng
2. WHEN Admin cố gắng cập nhật chi nhánh sang tên đã tồn tại của chi nhánh khác (không phân biệt hoa thường), THEN HỆ THỐNG Quản lý Chi nhánh SHALL từ chối yêu cầu với thông báo lỗi rõ ràng
3. WHEN Admin tạo hoặc cập nhật chi nhánh với tên duy nhất, THEN HỆ THỐNG Quản lý Chi nhánh SHALL cho phép thao tác thành công
4. WHEN kiểm tra tên trùng lặp, HỆ THỐNG Quản lý Chi nhánh SHALL thực hiện so sánh không phân biệt hoa thường và loại bỏ khoảng trắng thừa
5. WHEN kiểm tra tên trùng lặp, HỆ THỐNG Quản lý Chi nhánh SHALL loại bỏ tiền tố "Chi nhánh" hoặc "Chi Nhánh" (không phân biệt hoa thường) trước khi so sánh để chỉ so sánh phần tên thực sự

### Yêu cầu 2: Lưu Số điện thoại vào Database

**User Story:** Là Admin, tôi muốn số điện thoại chi nhánh được lưu vào database, để tôi có thể duy trì thông tin liên lạc đầy đủ cho mỗi chi nhánh.

#### Tiêu chí chấp nhận

1. ENTITY Branches SHALL bao gồm trường phone để lưu số điện thoại liên lạc của chi nhánh
2. WHEN Admin tạo chi nhánh với số điện thoại, THEN HỆ THỐNG Quản lý Chi nhánh SHALL lưu số điện thoại vào database
3. WHEN Admin cập nhật số điện thoại chi nhánh, THEN HỆ THỐNG Quản lý Chi nhánh SHALL cập nhật số điện thoại trong database
4. WHEN truy xuất thông tin chi nhánh, HỆ THỐNG Quản lý Chi nhánh SHALL bao gồm số điện thoại trong response
5. ENTITY Branches SHALL cho phép trường phone có giá trị null để hỗ trợ chi nhánh không có số điện thoại

### Yêu cầu 3: Validate Định dạng Số điện thoại

**User Story:** Là Admin, tôi muốn hệ thống validate số điện thoại khi tạo hoặc cập nhật chi nhánh, để chỉ những số điện thoại đúng định dạng mới được lưu.

#### Tiêu chí chấp nhận

1. WHEN Admin cung cấp số điện thoại, HỆ THỐNG Quản lý Chi nhánh SHALL validate rằng nó chỉ chứa chữ số, khoảng trắng, gạch ngang, hoặc mã quốc gia +84
2. WHEN Admin cung cấp số điện thoại, HỆ THỐNG Quản lý Chi nhánh SHALL validate rằng nó chứa từ 9 đến 12 chữ số (không tính ký tự định dạng)
3. IF số điện thoại bắt đầu bằng +, THEN HỆ THỐNG Quản lý Chi nhánh SHALL validate rằng nó sử dụng định dạng mã quốc gia +84
4. WHEN số điện thoại không hợp lệ, THEN HỆ THỐNG Quản lý Chi nhánh SHALL từ chối yêu cầu với thông báo lỗi mô tả rõ ràng
5. HỆ THỐNG Quản lý Chi nhánh SHALL chấp nhận số điện thoại ở các định dạng: 0123456789, +84123456789, 0123 456 789, 0123-456-789

### Yêu cầu 4: Hiển thị Số điện thoại trong UI

**User Story:** Là Admin, tôi muốn xem số điện thoại chi nhánh trong danh sách và trang chi tiết, để tôi có thể truy cập thông tin liên lạc nhanh chóng.

#### Tiêu chí chấp nhận

1. WHEN xem danh sách chi nhánh, HỆ THỐNG Quản lý Chi nhánh SHALL hiển thị số điện thoại cho mỗi chi nhánh
2. WHEN xem chi tiết chi nhánh, HỆ THỐNG Quản lý Chi nhánh SHALL hiển thị số điện thoại
3. WHEN chi nhánh không có số điện thoại, HỆ THỐNG Quản lý Chi nhánh SHALL hiển thị ký hiệu placeholder (ví dụ: "—")
4. HỆ THỐNG Quản lý Chi nhánh SHALL định dạng số điện thoại nhất quán trong UI để dễ đọc
