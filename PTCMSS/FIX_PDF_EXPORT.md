# Hướng dẫn Fix lỗi Export PDF

## Vấn đề
Khi click button "PDF" trong trang Invoice Management, file PDF được tải về nhưng không mở được với lỗi "Failed to load PDF document".

## Nguyên nhân
1. **Dependency iText không đúng**: Trong `pom.xml`, dependency iText có `<type>pom</type>` nên không import các module cần thiết (kernel, layout, io).
2. **Font và format chưa tối ưu**: Code cũ dùng font Helvetica cơ bản và format đơn giản.

## Giải pháp đã thực hiện

### 1. Sửa dependency trong pom.xml
Đã thay đổi từ:
```xml
<dependency>
    <groupId>com.itextpdf</groupId>
    <artifactId>itext7-core</artifactId>
    <version>7.2.5</version>
    <type>pom</type>
</dependency>
```

Thành:
```xml
<dependency>
    <groupId>com.itextpdf</groupId>
    <artifactId>kernel</artifactId>
    <version>7.2.5</version>
</dependency>
<dependency>
    <groupId>com.itextpdf</groupId>
    <artifactId>layout</artifactId>
    <version>7.2.5</version>
</dependency>
<dependency>
    <groupId>com.itextpdf</groupId>
    <artifactId>io</artifactId>
    <version>7.2.5</version>
</dependency>
```

### 2. Cải thiện code export PDF
Đã cập nhật `ExportServiceImpl.exportInvoiceToPDF()` với:
- Format PDF chuyên nghiệp hơn
- Thêm thông tin chi tiết (booking reference, due date)
- Table layout đẹp hơn với header có background
- Thêm payment status rõ ràng
- Footer thông tin

## Các bước để áp dụng fix

### Bước 1: Rebuild backend
Mở terminal trong thư mục `PTCMSS/ptcmss-backend` và chạy:

```bash
mvn clean install -DskipTests
```

Hoặc nếu dùng Maven wrapper:
```bash
./mvnw clean install -DskipTests
```

### Bước 2: Restart backend server
Sau khi build xong, restart Spring Boot application:

```bash
mvn spring-boot:run
```

Hoặc nếu đang chạy trong IDE (IntelliJ/Eclipse), restart application từ IDE.

### Bước 3: Test chức năng
1. Mở frontend: http://localhost:5173 (hoặc port của bạn)
2. Đăng nhập với tài khoản có quyền ACCOUNTANT/MANAGER/ADMIN
3. Vào trang "Invoice Management" (Module 6)
4. Click button "PDF" ở bất kỳ invoice nào
5. File PDF sẽ được tải về và có thể mở được

## Kết quả mong đợi
- File PDF được tạo thành công
- Có thể mở file PDF bằng bất kỳ PDF reader nào (Adobe Reader, Chrome, Edge, etc.)
- Nội dung hiển thị đầy đủ thông tin invoice:
  - Invoice number, date, customer name
  - Booking reference (nếu có)
  - Service description
  - Amount, paid amount, balance
  - Payment status
  - Professional layout với table và formatting

## Troubleshooting

### Nếu vẫn gặp lỗi "Failed to load PDF document"
1. Kiểm tra log backend xem có exception không
2. Verify rằng Maven đã download đúng dependencies:
   ```bash
   mvn dependency:tree | grep itext
   ```
   Phải thấy: kernel-7.2.5, layout-7.2.5, io-7.2.5

### Nếu PDF mở được nhưng không có nội dung
1. Kiểm tra invoice data có đầy đủ không (invoiceNumber, amount, customerName)
2. Xem log backend để debug

### Nếu Maven build fail
1. Xóa cache Maven: `rm -rf ~/.m2/repository/com/itextpdf`
2. Build lại: `mvn clean install -DskipTests`

## Files đã thay đổi
1. `PTCMSS/ptcmss-backend/pom.xml` - Sửa iText dependencies
2. `PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/service/impl/ExportServiceImpl.java` - Cải thiện logic export PDF

## Ghi chú
- iText 7.2.5 là phiên bản stable và tương thích với Java 21
- Font Helvetica được sử dụng vì nó là standard font có sẵn trong PDF, không cần embed
- Nếu cần hỗ trợ tiếng Việt đầy đủ (dấu thanh), cần thêm font Unicode như Arial hoặc DejaVu
