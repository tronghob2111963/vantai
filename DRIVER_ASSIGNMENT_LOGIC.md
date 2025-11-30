# PHÂN TÍCH LOGIC NGHIỆP VỤ: GÁN TÀI XẾ CHO CHUYẾN ĐI

## 👥 AI CÓ THỂ GÁN TÀI XẾ?

### **1. Điều phối viên (Coordinator)**
- ✅ **Quyền:** Gán tài xế/xe cho chuyến đi
- ✅ **Phạm vi:** Chỉ xem và gán cho chi nhánh mình thuộc về
- ✅ **Trang sử dụng:**
  - `/dispatch/pending` - Danh sách chuyến chờ gán
  - `/dispatch` - Timeline điều phối
  - AssignDriverDialog - Dialog gán tài xế/xe

### **2. Quản lý (Manager)**
- ✅ **Quyền:** Gán tài xế/xe cho chuyến đi
- ✅ **Phạm vi:** Chỉ xem và gán cho chi nhánh mình quản lý
- ✅ **Trang sử dụng:**
  - `/dispatch/pending` - Danh sách chuyến chờ gán
  - EditOrderPage - Sửa đơn hàng và gán tài xế/xe

### **3. Admin**
- ✅ **Quyền:** Gán tài xế/xe cho chuyến đi
- ✅ **Phạm vi:** Xem và gán cho **TẤT CẢ** chi nhánh
- ✅ **Trang sử dụng:**
  - `/dispatch/pending` - Danh sách chuyến chờ gán (có dropdown chọn chi nhánh)
  - EditOrderPage - Sửa đơn hàng và gán tài xế/xe

### **4. Tư vấn viên (Consultant)**
- ❌ **KHÔNG có quyền** gán tài xế/xe trực tiếp
- ✅ Chỉ có thể tạo đơn hàng, sau đó đơn chuyển sang trạng thái chờ điều phối gán

---

## 🔄 FLOW TỰ ĐỘNG GÁN TÀI XẾ

### **Flow 1: Gán thủ công (Manual Assignment)**

```
1. Điều phối viên/Quản lý/Admin vào trang "Đơn chưa gán chuyến"
   ↓
2. Xem danh sách chuyến chờ gán (pending trips)
   ↓
3. Click nút "Gán tài xế & xe" trên một chuyến
   ↓
4. Hệ thống mở AssignDriverDialog:
   a. Tự động gọi API: GET /api/dispatch/trips/{tripId}/suggestions
   b. Nhận về:
      - Danh sách gợi ý (suggestions): [{driver, vehicle, score, reasons[]}]
      - Danh sách tài xế khả dụng (drivers): [{id, name, eligible, tripsToday}]
      - Danh sách xe khả dụng (vehicles): [{id, plate, model, eligible, status}]
      - Recommended driver/vehicle (tự động chọn)
   ↓
5. Điều phối viên có 2 lựa chọn:

   **Option A: Chọn từ gợi ý hệ thống**
   - Click vào một dòng gợi ý → Tự động fill vào dropdown
   - Click "Xác nhận gán chuyến"
   ↓
   
   **Option B: Chọn thủ công**
   - Chọn tài xế từ dropdown (chỉ hiện tài xế rảnh & phù hợp)
   - Chọn xe từ dropdown (chỉ hiện xe rảnh & phù hợp)
   - Click "Xác nhận gán chuyến"
   ↓
6. Gọi API: POST /api/dispatch/assign
   {
     bookingId: number,
     tripIds: [number],
     driverId: number,
     vehicleId: number,
     autoAssign: false
   }
   ↓
7. Hệ thống gán tài xế và xe cho chuyến
   ↓
8. Tài xế nhận được thông báo: "Bạn có chuyến mới được gán"
```

### **Flow 2: Gán tự động (Auto Assignment)**

```
1. Điều phối viên/Quản lý/Admin mở AssignDriverDialog
   ↓
2. Hệ thống load gợi ý (tương tự flow thủ công)
   ↓
3. Điều phối viên click nút "Tự động gán (Auto-assign)"
   ↓
4. Gọi API: POST /api/dispatch/assign
   {
     bookingId: number,
     tripIds: [number],
     autoAssign: true  // ← Không cần driverId, vehicleId
   }
   ↓
5. Backend tự động:
   a. Phân tích yêu cầu chuyến (thời gian, loại xe, khoảng cách, chi nhánh)
   b. Tìm tài xế phù hợp dựa trên:
      - Tài xế rảnh trong khoảng thời gian chuyến
      - Tài xế không nghỉ phép
      - Tài xế thuộc cùng chi nhánh
      - Tài xế có bằng lái phù hợp
      - Tài xế có ít chuyến nhất trong ngày (load balancing)
   c. Tìm xe phù hợp dựa trên:
      - Xe rảnh trong khoảng thời gian chuyến
      - Xe không bảo trì
      - Xe thuộc cùng chi nhánh
      - Loại xe phù hợp với yêu cầu
      - Xe gần điểm đón nhất (nếu có)
   d. Gán tài xế và xe tốt nhất
   ↓
6. Tài xế nhận được thông báo: "Bạn có chuyến mới được gán"
```

### **Flow 3: Gán từ Edit Order Page**

```
1. Consultant/Coordinator/Manager/Admin vào trang chi tiết đơn hàng
   ↓
2. Click "Sửa đơn hàng"
   ↓
3. Trong EditOrderPage, có section "Gán tài xế / phân xe"
   ↓
4. Chọn tài xế và xe từ dropdown
   ↓
5. Click "Gán tài xế / xe"
   ↓
6. Gọi API: POST /api/bookings/{bookingId}/assign
   {
     driverId: number,
     vehicleId: number,
     tripIds: [number]
   }
   ↓
7. Gán cho tất cả chuyến trong đơn hàng
```

---

## 🧠 LOGIC GỢI Ý TÀI XẾ/XE (Suggestions Algorithm)

### **API: GET /api/dispatch/trips/{tripId}/suggestions**

Backend trả về:

```json
{
  "summary": {
    "tripDate": "2024-12-15",
    "tripTime": "14:00",
    "vehicleType": "Xe 16 chỗ",
    "branchId": 1
  },
  "suggestions": [
    {
      "id": 1,
      "driver": {
        "id": 10,
        "name": "Nguyễn Văn A",
        "phone": "0987654321",
        "licenseType": "B2",
        "tripsToday": 2
      },
      "vehicle": {
        "id": 5,
        "plate": "29A-123.45",
        "model": "Samco Isuzu",
        "type": "Xe 16 chỗ"
      },
      "score": 95,
      "reasons": [
        "Tài xế rảnh trong khoảng thời gian",
        "Xe phù hợp loại yêu cầu",
        "Cùng chi nhánh",
        "Tài xế có ít chuyến nhất"
      ]
    },
    // ... more suggestions
  ],
  "drivers": [
    {
      "id": 10,
      "name": "Nguyễn Văn A",
      "eligible": true,
      "tripsToday": 2,
      "reason": "Rảnh"
    },
    {
      "id": 11,
      "name": "Trần Văn B",
      "eligible": false,
      "tripsToday": 5,
      "reason": "Đã đủ chuyến trong ngày"
    }
  ],
  "vehicles": [
    {
      "id": 5,
      "plate": "29A-123.45",
      "model": "Samco Isuzu",
      "eligible": true,
      "status": "AVAILABLE"
    }
  ],
  "recommendedDriverId": 10,
  "recommendedVehicleId": 5
}
```

### **Tiêu chí đánh giá (Score Calculation)**

Backend tính điểm dựa trên:

1. **Tài xế rảnh** (+30 điểm)
2. **Xe rảnh** (+30 điểm)
3. **Cùng chi nhánh** (+20 điểm)
4. **Loại xe phù hợp** (+10 điểm)
5. **Tài xế có ít chuyến nhất** (+10 điểm)
6. **Xe gần điểm đón** (+5 điểm)
7. **Tài xế có kinh nghiệm tuyến đường** (+5 điểm)

**Trừ điểm:**
- Tài xế đã có nhiều chuyến trong ngày (-5 điểm/chuyến)
- Xe đang bảo trì (-50 điểm)
- Tài xế nghỉ phép (-100 điểm)
- Tài xế có chuyến trùng giờ (-100 điểm)

---

## 🔄 FLOW TỰ ĐỘNG KHI CÓ SỰ KIỆN

### **1. Khi đơn hàng được tạo (Order Created)**

```
1. Consultant tạo đơn hàng mới
   ↓
2. Đơn hàng có status: PENDING hoặc CONFIRMED
   ↓
3. Hệ thống tự động:
   - Tạo các chuyến (trips) từ đơn hàng
   - Status chuyến: SCHEDULED (chưa gán)
   ↓
4. Chuyến xuất hiện trong:
   - Danh sách "Đơn chưa gán chuyến" (PendingTripsPage)
   - Timeline điều phối (CoordinatorTimelinePro)
   ↓
5. Điều phối viên nhận thông báo: "Có đơn mới cần gán tài xế"
```

### **2. Khi tài xế nghỉ phép được duyệt (Day Off Approved)**

```
1. Tài xế xin nghỉ phép
   ↓
2. Điều phối viên duyệt nghỉ phép
   ↓
3. Hệ thống kiểm tra: Tài xế có chuyến trong ngày nghỉ không?
   ↓
4a. NẾU CÓ chuyến:
   - Hiển thị dialog cảnh báo với danh sách chuyến xung đột
   - Điều phối viên chọn:
     * Hủy gán các chuyến xung đột → Duyệt nghỉ phép
     * Từ chối yêu cầu nghỉ phép
   ↓
4b. NẾU KHÔNG có chuyến:
   - Duyệt nghỉ phép bình thường
   ↓
5. Nếu đã hủy gán chuyến:
   - Chuyến chuyển về trạng thái: SCHEDULED (chưa gán)
   - Chuyến xuất hiện lại trong "Đơn chưa gán chuyến"
   - Điều phối viên cần gán lại tài xế khác
```

### **3. Khi tài xế hoàn thành chuyến sớm (Early Completion)**

```
1. Tài xế hoàn thành chuyến
   ↓
2. Hệ thống cập nhật status: COMPLETED
   ↓
3. Tài xế trở thành "rảnh" (available)
   ↓
4. Hệ thống có thể tự động gán chuyến tiếp theo (nếu có auto-assign queue)
   - Hiện tại: Chưa có auto-assign queue
   - Tương lai: Có thể thêm tính năng này
```

### **4. Khi tài xế báo sự cố (Incident Report)**

```
1. Tài xế báo sự cố xe/khách
   ↓
2. Điều phối viên xem báo cáo
   ↓
3. Nếu cần thay tài xế:
   - Điều phối viên hủy gán chuyến hiện tại
   - Gán lại tài xế khác
```

---

## 📍 CÁC TRANG/MODULE LIÊN QUAN

### **1. PendingTripsPage** (`/dispatch/pending`)
- **Mục đích:** Danh sách chuyến chờ gán tài xế/xe
- **Quyền truy cập:** Coordinator, Manager, Admin
- **Chức năng:**
  - Hiển thị danh sách chuyến chưa gán
  - Click "Gán tài xế & xe" → Mở AssignDriverDialog
  - Filter theo chi nhánh (Admin có thể chọn tất cả)

### **2. AssignDriverDialog**
- **Mục đích:** Dialog gán tài xế/xe cho chuyến
- **Chức năng:**
  - Hiển thị gợi ý hệ thống (top suggestions)
  - Cho phép chọn thủ công
  - Nút "Tự động gán" (auto-assign)
  - Nút "Xác nhận gán chuyến" (manual assign)

### **3. CoordinatorTimelinePro** (`/dispatch`)
- **Mục đích:** Timeline điều phối (Gantt chart)
- **Chức năng:**
  - Xem lịch tài xế theo thời gian
  - Phát hiện xung đột lịch
  - Gán chuyến từ timeline
  - Xem utilization của tài xế

### **4. EditOrderPage**
- **Mục đích:** Sửa đơn hàng và gán tài xế/xe
- **Chức năng:**
  - Gán tài xế/xe cho tất cả chuyến trong đơn
  - Có cooldown để tránh thay đổi liên tục

---

## 🔐 RÀNG BUỘC VÀ ĐIỀU KIỆN

### **1. Điều kiện gán tài xế**
- ✅ Tài xế phải **rảnh** trong khoảng thời gian chuyến
- ✅ Tài xế **không nghỉ phép** trong ngày chuyến
- ✅ Tài xế thuộc **cùng chi nhánh** với chuyến
- ✅ Tài xế có **bằng lái phù hợp** với loại xe
- ✅ Tài xế **không có chuyến trùng giờ**

### **2. Điều kiện gán xe**
- ✅ Xe phải **rảnh** trong khoảng thời gian chuyến
- ✅ Xe **không bảo trì** (maintenance)
- ✅ Xe thuộc **cùng chi nhánh** với chuyến
- ✅ **Loại xe phù hợp** với yêu cầu đơn hàng
- ✅ Xe **không có chuyến trùng giờ**

### **3. Ràng buộc nghiệp vụ**
- ⚠️ **Cooldown:** Sau khi gán, phải đợi một khoảng thời gian mới được thay đổi (tránh spam)
- ⚠️ **Thời gian tối thiểu:** Chỉ có thể chỉnh sửa đơn hàng nếu còn >= 12 giờ trước chuyến đi
- ⚠️ **Trạng thái đơn:** Chỉ có thể gán khi đơn ở trạng thái: DRAFT, PENDING, CONFIRMED, ASSIGNED, QUOTATION_SENT

---

## 📊 API ENDPOINTS

### **1. Lấy gợi ý tài xế/xe**
```
GET /api/dispatch/trips/{tripId}/suggestions
→ Trả về: suggestions, drivers, vehicles, recommendedDriverId, recommendedVehicleId
```

### **2. Gán chuyến (thủ công)**
```
POST /api/dispatch/assign
Body: {
  bookingId: number,
  tripIds?: [number],
  driverId: number,
  vehicleId: number,
  autoAssign: false,
  note?: string
}
```

### **3. Gán chuyến (tự động)**
```
POST /api/dispatch/assign
Body: {
  bookingId: number,
  tripIds?: [number],
  autoAssign: true
}
→ Backend tự động chọn tài xế và xe tốt nhất
```

### **4. Gán lại chuyến (Reassign)**
```
POST /api/dispatch/reassign
Body: {
  tripId: number,
  driverId: number,
  vehicleId: number,
  note: string
}
→ Hủy gán cũ và gán lại tài xế/xe mới
```

### **5. Hủy gán chuyến (Unassign)**
```
POST /api/dispatch/trips/{tripId}/unassign
Body: {
  note: string (required)
}
→ Hủy gán tài xế/xe khỏi chuyến
```

### **6. Lấy danh sách chuyến chờ gán**
```
GET /api/dispatch/pending/{branchId}
→ Trả về: danh sách chuyến chưa gán tài xế/xe
```

---

## 🎯 TÓM TẮT

### **Ai có thể gán:**
- ✅ **Điều phối viên (Coordinator)** - Chi nhánh của mình
- ✅ **Quản lý (Manager)** - Chi nhánh mình quản lý
- ✅ **Admin** - Tất cả chi nhánh

### **Flow tự động:**
1. **Gán thủ công:** Chọn từ gợi ý hoặc chọn thủ công → Xác nhận
2. **Gán tự động:** Click "Tự động gán" → Backend tự chọn tài xế/xe tốt nhất
3. **Gán từ Edit Order:** Gán cho tất cả chuyến trong đơn

### **Logic gợi ý:**
- Backend tính điểm dựa trên: rảnh, cùng chi nhánh, loại xe, số chuyến, khoảng cách
- Trả về top suggestions với score cao nhất
- Tự động chọn recommended driver/vehicle

### **Ràng buộc:**
- Tài xế/xe phải rảnh, không nghỉ phép, cùng chi nhánh
- Cooldown sau khi gán
- Chỉnh sửa trước >= 12 giờ

