# 📊 PHÂN TÍCH MODULE 4: QUẢN LÝ BÁO GIÁ & ĐẶT CHUYẾN

## 🎯 TỔNG QUAN

Dự án đã **HOÀN THIỆN 100% YÊU CẦU** của Module 4 về mặt Backend API. Frontend đã có đầy đủ các màn hình UI nhưng **CHƯA TÍCH HỢP API THẬT**.

---

## ✅ CÁC YÊU CẦU ĐÃ ĐÁP ỨNG

### 1. **Dashboard Consultant (Màn hình làm việc chính)** ✅

#### Yêu cầu:
- Hiển thị các yêu cầu/đơn hàng mới (chờ báo giá)
- Danh sách các báo giá đã gửi (chờ khách xác nhận)
- Danh sách các đơn hàng đã xác nhận (chờ điều phối)
- Biểu đồ nhanh: Doanh số trong tháng, Tỷ lệ chuyển đổi
- Nút hành động nhanh: "Tạo đơn hàng mới"

#### Trạng thái:
**✅ BACKEND: HOÀN THIỆN**
- API: `GET /api/bookings/dashboard`
- Response: `ConsultantDashboardResponse` bao gồm:
  - `pendingBookings` - Chờ báo giá (PENDING)
  - `sentQuotations` - Đã gửi báo giá (QUOTATION_SENT)
  - `confirmedBookings` - Đã xác nhận (CONFIRMED)
  - `monthlyRevenue` - Doanh số trong tháng
  - `conversionRate` - Tỷ lệ chuyển đổi
  - `monthlyStatistics` - Thống kê 3 tháng gần nhất
- Authorization: ADMIN, MANAGER, CONSULTANT

**⚠️ FRONTEND: CÓ UI NHƯNG DÙNG MOCK DATA**
- File: `ConsultantDashboardPage.jsx`
- Có đầy đủ UI components (KPI cards, queue list)
- **CHƯA TÍCH HỢP API**: Đang dùng mock data trong state
- Cần thêm: API call đến `/api/bookings/dashboard`

---

### 2. **Create Order (Tạo đơn hàng mới)** ✅

#### Yêu cầu:
- **Phần 1**: Thông tin khách hàng (Tên, SĐT, Email)
  - Nếu đã có sẵn thông tin KH từ trước thì chỉ cần nhập SĐT là tự động hiện tên với email KH
  - Ngược lại sẽ tự động thêm vào CSDL để dễ quản lý tệp KH
- **Phần 2**: Thông tin chuyến đi (Điểm đi, điểm đến, thời gian, loại xe yêu cầu, số lượng khách)
- **Phần 3**: Báo giá
  - Hệ thống tự động tính giá dự kiến (cho 2 trường hợp: cao tốc và không cao tốc)
  - Cho phép tư vấn viên điều chỉnh giá thủ công
  - Thêm giảm giá
- Hành động: "Lưu nháp", "Gửi báo giá", "Xác nhận đặt chuyến"
- Tạo QR thanh toán cho khách (nếu muốn đặt cọc luôn)

#### Trạng thái:
**✅ BACKEND: HOÀN THIỆN**
- API: `POST /api/bookings`
- Request: `CreateBookingRequest` bao gồm:
  - `customer` - Thông tin KH (auto-create nếu chưa có, tìm theo phone)
  - `branchId`, `hireTypeId`, `useHighway`
  - `trips` - Danh sách chuyến đi
  - `vehicles` - Danh sách loại xe
  - `distance` - Khoảng cách (km)
  - `estimatedCost`, `discountAmount`, `totalCost`, `depositAmount`
  - `status` - PENDING (mặc định)
  - `note`
- API tính giá: `POST /api/bookings/calculate-price`
  - Params: `vehicleCategoryIds`, `quantities`, `distance`, `useHighway`
  - Công thức: `(baseFare + pricePerKm * distance + highwayFee + fixedCosts) * quantity`
- API QR Code: `POST /api/bookings/{id}/payment/qr`
  - Tạo QR code thanh toán (VietQR format)
  - Response: `QRCodeResponse` với `qrImageBase64`
- Authorization: ADMIN, MANAGER, CONSULTANT

**⚠️ FRONTEND: CÓ UI NHƯNG DÙNG MOCK DATA**
- File: `CreateOrderPage.jsx`
- Có đầy đủ form nhập liệu (3 phần như yêu cầu)
- Có mock auto-fill khách hàng khi nhập SĐT
- Có mock tính giá tự động
- **CHƯA TÍCH HỢP API**: Đang dùng setTimeout mock
- Cần thêm:
  - API call đến `/api/bookings` để tạo đơn
  - API call đến `/api/bookings/calculate-price` để tính giá
  - API call đến `/api/bookings/{id}/payment/qr` để tạo QR

---

### 3. **Edit Order (Chỉnh sửa đơn hàng)** ✅

#### Yêu cầu:
- Tương tự màn hình Create Order nhưng tải lại thông tin của một đơn hàng/báo giá đã có
- Cho phép chỉnh sửa mọi thông tin (lịch trình, giá cả) trước khi đơn hàng được điều phối

#### Trạng thái:
**✅ BACKEND: HOÀN THIỆN**
- API: `PUT /api/bookings/{id}`
- Request: `UpdateBookingRequest` (tương tự CreateBookingRequest)
- Validation: Chỉ cho phép khi status = PENDING hoặc CONFIRMED
- Authorization: ADMIN, MANAGER, CONSULTANT

**⚠️ FRONTEND: CÓ UI NHƯNG DÙNG MOCK DATA**
- File: `EditOrderPage.jsx`
- Có đầy đủ form chỉnh sửa
- Có logic khóa form nếu status không phải DRAFT/PENDING
- **CHƯA TÍCH HỢP API**: Đang dùng mock data
- Cần thêm:
  - API call đến `GET /api/bookings/{id}` để load data
  - API call đến `PUT /api/bookings/{id}` để update

---

### 4. **View Orders (List Orders - Danh sách đơn hàng)** ✅

#### Yêu cầu:
- Hiển thị danh sách toàn bộ các đơn hàng/báo giá dưới dạng bảng
- Các cột: Mã đơn, Tên khách hàng, Lịch trình (tóm tắt), Ngày đi, Giá trị, Trạng thái
- Bộ lọc: Lọc theo Trạng thái, Ngày, Tư vấn viên
- Tìm kiếm: Tìm theo Mã đơn hoặc SĐT khách hàng
- Cho phép tạo QR thanh toán cho khách (chưa đặt cọc)

#### Trạng thái:
**✅ BACKEND: HOÀN THIỆN**
- API: `GET /api/bookings`
- Query params:
  - `status` - PENDING, QUOTATION_SENT, CONFIRMED, IN_PROGRESS, COMPLETED, CANCELLED
  - `branchId`, `consultantId`
  - `startDate`, `endDate` (ISO format)
  - `keyword` - Tìm theo mã đơn, SĐT, tên KH
  - `page`, `size`, `sortBy` - Pagination & sorting
- Response: `PageResponse<BookingListResponse>` hoặc `List<BookingListResponse>`
- Authorization: ADMIN, MANAGER, CONSULTANT, ACCOUNTANT

**⚠️ FRONTEND: CÓ UI NHƯNG DÙNG MOCK DATA**
- File: `ConsultantOrderListPage.jsx`
- Có đầy đủ table với filter, search, pagination
- Có modal tạo đơn, xem chi tiết, chỉnh sửa
- **CHƯA TÍCH HỢP API**: Đang dùng mock data trong state
- Cần thêm:
  - API call đến `GET /api/bookings` với filter params
  - API call đến `POST /api/bookings/{id}/payment/qr` cho QR code

---

### 5. **View Order Detail (Chi tiết đơn hàng)** ✅

#### Yêu cầu:
- Hiển thị chi tiết một đơn hàng (chỉ xem)
- Thông tin khách hàng, lịch trình, chi tiết báo giá (giá gốc, giảm giá, giá cuối)
- Thông tin thanh toán: Hiển thị Deposit (Subscreen) để xem/ghi nhận tiền cọc
- Thông tin điều phối (sau khi đã gán): Tài xế, Biển số xe

#### Trạng thái:
**✅ BACKEND: HOÀN THIỆN**
- API: `GET /api/bookings/{id}`
- Response: `BookingResponse` bao gồm:
  - Thông tin KH, lịch trình, giá cả
  - `trips` - Danh sách chuyến đi (có driver/vehicle nếu đã gán)
  - `vehicles` - Chi tiết loại xe
  - `paidAmount` - Tổng đã thanh toán (từ Invoices)
  - `remainingAmount` - Còn lại
- API ghi nhận thanh toán: `POST /api/bookings/{id}/deposit`
  - Request: `CreateDepositRequest` (amount, paymentMethod, note, referenceCode)
  - Tự động tạo Invoice với type = INCOME
  - Auto-approve nếu là Accountant/Manager/Admin
- API lịch sử thanh toán: `GET /api/bookings/{id}/payments`
  - Response: `List<PaymentResponse>`
- Authorization: ADMIN, MANAGER, CONSULTANT, ACCOUNTANT

**⚠️ FRONTEND: CÓ UI NHƯNG DÙNG MOCK DATA**
- File: `OrderDetailPage.jsx`
- Có đầy đủ các section cards (Customer, Trip, Quote, Payment, Dispatch)
- Có tích hợp `DepositModal` từ Module 6
- **CHƯA TÍCH HỢP API**: Đang dùng mock data
- Cần thêm:
  - API call đến `GET /api/bookings/{id}` để load data
  - API call đến `POST /api/bookings/{id}/deposit` để ghi nhận thanh toán
  - API call đến `GET /api/bookings/{id}/payments` để xem lịch sử

---

## 📋 STATUS FLOW (Luồng trạng thái)

Backend đã implement đầy đủ các trạng thái:

```
PENDING (Lưu nháp / Chờ báo giá)
    ↓
QUOTATION_SENT (Đã gửi báo giá - chờ khách xác nhận)
    ↓
CONFIRMED (Khách đã đồng ý - chờ điều phối)
    ↓
IN_PROGRESS (Đang thực hiện)
    ↓
COMPLETED (Hoàn thành)

CANCELLED (Hủy bỏ) - có thể ở bất kỳ giai đoạn nào
```

**Lưu ý**: Frontend cần update để sử dụng đúng các status này thay vì mock status.

---

## 🔐 AUTHORIZATION (Phân quyền)

Backend đã implement đầy đủ phân quyền cho tất cả API:

| Chức năng | ADMIN | MANAGER | CONSULTANT | ACCOUNTANT |
|-----------|-------|---------|------------|------------|
| Dashboard | ✅ | ✅ | ✅ | ❌ |
| Create Order | ✅ | ✅ | ✅ | ❌ |
| Update Order | ✅ | ✅ | ✅ | ❌ |
| Delete Order | ✅ | ✅ | ✅ | ❌ |
| List Orders | ✅ | ✅ | ✅ | ✅ |
| View Detail | ✅ | ✅ | ✅ | ✅ |
| Calculate Price | ✅ | ✅ | ✅ | ❌ |
| Generate QR | ✅ | ✅ | ✅ | ✅ |
| Create Deposit | ✅ | ✅ | ❌ | ✅ |
| Payment History | ✅ | ✅ | ✅ | ✅ |

---

## 🆕 TÍNH NĂNG ĐẶC BIỆT ĐÃ IMPLEMENT

### 1. **Auto-create Customer** ✅
- Khi tạo đơn hàng, hệ thống tự động tìm khách hàng theo SĐT
- Nếu chưa có, tự động tạo mới customer trong database
- Giúp quản lý tệp khách hàng hiệu quả

### 2. **QR Code Payment** ✅
- Generate QR code thanh toán theo chuẩn VietQR
- Hỗ trợ cả đặt cọc và thanh toán đầy đủ
- QR code hết hạn sau 24h
- Trả về base64 PNG image, có thể hiển thị trực tiếp trong `<img>`

### 3. **Automatic Price Calculation** ✅
- Tính giá tự động dựa trên:
  - Loại xe (baseFare + pricePerKm)
  - Khoảng cách (distance)
  - Cao tốc (highwayFee)
  - Số lượng xe (quantity)
- Công thức: `(baseFare + pricePerKm * distance + highwayFee + fixedCosts) * quantity`

### 4. **Payment Tracking** ✅
- Tự động tính `paidAmount` từ Invoices thực tế
- Tính `remainingAmount` = totalCost - paidAmount
- Lịch sử thanh toán đầy đủ với thông tin:
  - Số tiền, phương thức thanh toán
  - Người tạo, người duyệt
  - Trạng thái thanh toán
  - Ghi chú, mã tham chiếu

### 5. **Status QUOTATION_SENT** ✅
- Phân biệt rõ giữa "Chờ báo giá" (PENDING) và "Đã gửi báo giá" (QUOTATION_SENT)
- Giúp tracking chính xác hơn trong dashboard

---

## ⚠️ NHỮNG GÌ CẦN LÀM TIẾP

### 1. **Frontend Integration** (QUAN TRỌNG NHẤT)

Tất cả các màn hình frontend đã có UI đầy đủ nhưng **CHƯA TÍCH HỢP API THẬT**. Cần:

#### a. Tạo API Service Layer
```javascript
// PTCMSS_FRONTEND/src/api/bookings.js
import http from './http';

export const bookingApi = {
  // Dashboard
  getDashboard: (branchId) => 
    http.get('/api/bookings/dashboard', { params: { branchId } }),
  
  // CRUD
  create: (data) => http.post('/api/bookings', data),
  update: (id, data) => http.put(`/api/bookings/${id}`, data),
  getById: (id) => http.get(`/api/bookings/${id}`),
  getAll: (params) => http.get('/api/bookings', { params }),
  delete: (id) => http.delete(`/api/bookings/${id}`),
  
  // Pricing
  calculatePrice: (params) => 
    http.post('/api/bookings/calculate-price', null, { params }),
  
  // Payment
  generateQR: (id, amount) => 
    http.post(`/api/bookings/${id}/payment/qr`, null, { params: { amount } }),
  createDeposit: (id, data) => 
    http.post(`/api/bookings/${id}/deposit`, data),
  getPaymentHistory: (id) => 
    http.get(`/api/bookings/${id}/payments`),
};
```

#### b. Update Components
Thay thế tất cả mock data và setTimeout bằng API calls thật:

**ConsultantDashboardPage.jsx:**
```javascript
// Thay vì:
const [stats] = React.useState({ pending_quotes: 4, ... });

// Dùng:
React.useEffect(() => {
  bookingApi.getDashboard().then(res => {
    setStats(res.data.data);
  });
}, []);
```

**CreateOrderPage.jsx:**
```javascript
// Thay vì:
await new Promise((r) => setTimeout(r, 500));

// Dùng:
const response = await bookingApi.create(payload);
```

**Tương tự cho**: EditOrderPage, ConsultantOrderListPage, OrderDetailPage

### 2. **Testing & Validation**

Sau khi tích hợp API, cần test:
- ✅ Tạo đơn hàng mới với customer mới
- ✅ Tạo đơn hàng với customer cũ (auto-fill)
- ✅ Tính giá tự động (có/không cao tốc)
- ✅ Tạo QR code thanh toán
- ✅ Ghi nhận tiền cọc/thanh toán
- ✅ Filter & search danh sách đơn
- ✅ Update đơn hàng (chỉ khi PENDING/CONFIRMED)
- ✅ Xem lịch sử thanh toán

### 3. **Configuration**

Cập nhật thông tin ngân hàng thật trong `application.yml`:
```yaml
payment:
  bank:
    code: "970418"  # Mã ngân hàng thật
    account:
      number: "1234567890"  # Số tài khoản thật
      name: "CONG TY PTCMSS"  # Tên chủ tài khoản thật
```

### 4. **Database Migration**

Nếu database đã có dữ liệu, chạy script:
```sql
-- PTCMSS/db_scripts/07_UPDATE_BOOKING_STATUS_SIMPLE.sql
```

Để update ENUM status với `QUOTATION_SENT` và `IN_PROGRESS`.

---

## 📊 ĐÁNH GIÁ TỔNG QUAN

### ✅ Điểm Mạnh

1. **Backend hoàn thiện 100%**
   - Tất cả API đã implement đầy đủ
   - Có validation, error handling, authorization
   - Có Swagger documentation
   - Code structure tốt, dễ maintain

2. **Frontend có UI đẹp và đầy đủ**
   - Tất cả màn hình đã được thiết kế
   - UI/UX theo light theme, responsive
   - Có đầy đủ form validation (client-side)
   - Component structure tốt

3. **Tính năng vượt yêu cầu**
   - QR Code payment
   - Auto-create customer
   - Payment tracking chi tiết
   - Dashboard với statistics

### ⚠️ Điểm Cần Cải Thiện

1. **Frontend chưa tích hợp API**
   - Tất cả đang dùng mock data
   - Cần tạo API service layer
   - Cần replace setTimeout bằng API calls

2. **Thiếu error handling ở frontend**
   - Chưa có loading states đầy đủ
   - Chưa có error boundaries
   - Cần thêm retry logic cho failed requests

3. **Thiếu real-time updates**
   - Dashboard không tự động refresh
   - Cần thêm WebSocket hoặc polling cho notifications

---

## 🎯 KẾT LUẬN

### Trả lời câu hỏi: "Đã đủ yêu cầu cho Module 4 chưa?"

**✅ BACKEND: ĐÃ ĐỦ 100%**
- Tất cả API đã implement đầy đủ
- Đáp ứng tất cả yêu cầu nghiệp vụ
- Có thêm nhiều tính năng vượt yêu cầu

**⚠️ FRONTEND: ĐÃ ĐỦ UI NHƯNG CHƯA HOÀN THIỆN**
- Có đầy đủ màn hình theo yêu cầu
- UI/UX đẹp và đầy đủ chức năng
- **NHƯNG**: Chưa tích hợp API thật, đang dùng mock data

### Công việc còn lại:

**Ưu tiên cao (Bắt buộc):**
1. ✅ Tạo file `PTCMSS_FRONTEND/src/api/bookings.js`
2. ✅ Tích hợp API vào 5 màn hình chính
3. ✅ Test end-to-end flow
4. ✅ Update config ngân hàng thật

**Ưu tiên trung bình (Nên có):**
5. ⚠️ Thêm error handling & loading states
6. ⚠️ Thêm form validation với backend errors
7. ⚠️ Optimize performance (caching, debounce)

**Ưu tiên thấp (Nice to have):**
8. 💡 Real-time notifications
9. 💡 Export/Print đơn hàng
10. 💡 Bulk operations

### Thời gian ước tính:
- **Tích hợp API cơ bản**: 1-2 ngày
- **Testing & bug fixes**: 1 ngày
- **Polish & optimization**: 1 ngày
- **Tổng**: 3-4 ngày làm việc

---

## 📝 CHECKLIST HOÀN THIỆN MODULE 4

### Backend ✅
- [x] Dashboard API
- [x] Create Order API
- [x] Update Order API
- [x] List Orders API (với filter & pagination)
- [x] View Order Detail API
- [x] Delete Order API
- [x] Calculate Price API
- [x] Generate QR Code API
- [x] Create Deposit API
- [x] Payment History API
- [x] Authorization cho tất cả endpoints
- [x] Validation & Error handling
- [x] Swagger documentation

### Frontend UI ✅
- [x] Dashboard Consultant Page
- [x] Create Order Page
- [x] Edit Order Page
- [x] Order List Page
- [x] Order Detail Page
- [x] Deposit Modal (từ Module 6)

### Frontend Integration ⚠️
- [ ] Tạo API service layer (`bookings.js`)
- [ ] Tích hợp Dashboard API
- [ ] Tích hợp Create Order API
- [ ] Tích hợp Edit Order API
- [ ] Tích hợp List Orders API
- [ ] Tích hợp Order Detail API
- [ ] Tích hợp Calculate Price API
- [ ] Tích hợp QR Code API
- [ ] Tích hợp Deposit API
- [ ] Tích hợp Payment History API

### Testing ⚠️
- [ ] Test tạo đơn với customer mới
- [ ] Test tạo đơn với customer cũ
- [ ] Test tính giá tự động
- [ ] Test QR code generation
- [ ] Test ghi nhận thanh toán
- [ ] Test filter & search
- [ ] Test pagination
- [ ] Test update đơn hàng
- [ ] Test authorization
- [ ] Test error cases

### Configuration ⚠️
- [ ] Update bank account info
- [ ] Run database migration script
- [ ] Update environment variables
- [ ] Test payment flow end-to-end

---

**Tóm lại**: Module 4 đã hoàn thiện về mặt nghiệp vụ và backend API. Công việc chính còn lại là **tích hợp API vào frontend** để thay thế mock data. Đây là công việc straightforward và có thể hoàn thành trong 3-4 ngày.
