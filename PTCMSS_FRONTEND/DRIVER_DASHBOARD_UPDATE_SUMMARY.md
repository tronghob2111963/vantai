# Driver Dashboard - Customer Phone & Distance Update

## Tổng quan
Đã cập nhật backend và frontend để hiển thị **số điện thoại khách hàng** và **quãng đường (km)** trong Dashboard tài xế.

---

## Backend Changes

### 1. DriverDashboardResponse.java
**File:** `PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/dto/response/Driver/DriverDashboardResponse.java`

**Thêm 2 fields mới:**
```java
private String customerPhone;  // Số điện thoại khách hàng
private BigDecimal distance;   // Quãng đường (km)
```

**Cấu trúc đầy đủ:**
```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class DriverDashboardResponse {
    private Integer tripId;
    private String startLocation;
    private String endLocation;
    private Instant startTime;
    private Instant endTime;
    private TripStatus status;
    private String customerPhone;  // ✅ MỚI
    private BigDecimal distance;   // ✅ MỚI
}
```

---

### 2. DriverServiceImpl.java
**File:** `PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/service/impl/DriverServiceImpl.java`

**Cập nhật method `getDashboard()`:**

**Trước:**
```java
return driverTrips.stream()
    .filter(td -> td.getTrip().getStatus() == TripStatus.SCHEDULED
            || td.getTrip().getStatus() == TripStatus.ONGOING)
    .findFirst()
    .map(td -> new DriverDashboardResponse(
            td.getTrip().getId(),
            td.getTrip().getStartLocation(),
            td.getTrip().getEndLocation(),
            td.getTrip().getStartTime(),
            td.getTrip().getEndTime(),
            td.getTrip().getStatus()))
    .orElse(null);
```

**Sau:**
```java
return driverTrips.stream()
    .filter(td -> td.getTrip().getStatus() == TripStatus.SCHEDULED
            || td.getTrip().getStatus() == TripStatus.ONGOING)
    .findFirst()
    .map(td -> {
        var trip = td.getTrip();
        var booking = trip.getBooking();
        var customer = booking != null ? booking.getCustomer() : null;
        
        return new DriverDashboardResponse(
                trip.getId(),
                trip.getStartLocation(),
                trip.getEndLocation(),
                trip.getStartTime(),
                trip.getEndTime(),
                trip.getStatus(),
                customer != null ? customer.getPhone() : null,  // ✅ MỚI
                trip.getDistance()                               // ✅ MỚI
        );
    })
    .orElse(null);
```

**Logic:**
- Lấy `customerPhone` từ: `Trip → Booking → Customer → phone`
- Lấy `distance` từ: `Trip → distance` (BigDecimal)
- Xử lý null-safe với optional chaining

---

## Frontend Changes

### 3. DriverDashboard.jsx
**File:** `PTCMSS_FRONTEND/src/components/module 2/DriverDashboard.jsx`

#### 3.1. Cập nhật `fetchDashboard()` - Map response từ API
```javascript
const mapped = dash && dash.tripId
    ? {
        tripId: dash.tripId,
        pickupAddress: dash.startLocation,
        dropoffAddress: dash.endLocation ?? dash.EndLocation,
        pickupTime: dash.startTime,
        endTime: dash.endTime,
        status: dash.status || "SCHEDULED",
        customerPhone: dash.customerPhone,  // ✅ MỚI
        distance: dash.distance,            // ✅ MỚI
      }
    : null;
```

#### 3.2. Cập nhật `activeTrip` object
```javascript
const activeTrip = trip
    ? {
        trip_id: trip.tripId,
        pickup_time: trip.pickupTime,
        pickup_address: trip.pickupAddress,
        dropoff_address: trip.dropoffAddress,
        customer_name: null,
        customer_phone: trip.customerPhone,  // ✅ MỚI
        distance: trip.distance,             // ✅ MỚI
        note: null,
      }
    : null;
```

#### 3.3. Cập nhật UI - Thêm hiển thị quãng đường
**Trước:** Grid 3 cột (Điểm đón, Khách hàng, Liên hệ)

**Sau:** Grid 4 cột + thêm cột "Quãng đường"

```jsx
{/* trip details */}
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5 mb-6 text-sm text-slate-700">
  {/* Điểm đón */}
  <div className="flex items-start gap-2">
    <MapPin className="h-4 w-4 text-sky-600 shrink-0" />
    <div>
      <div className="text-slate-400 text-[11px] mb-1 uppercase tracking-wide">
        Điểm đón
      </div>
      <div className="text-slate-900 leading-snug">{t.pickup_address}</div>
    </div>
  </div>

  {/* Khách hàng */}
  <div className="flex items-start gap-2">
    <User className="h-4 w-4 text-emerald-600 shrink-0" />
    <div>
      <div className="text-slate-400 text-[11px] mb-1 uppercase tracking-wide">
        Khách hàng
      </div>
      <div className="text-slate-900 leading-snug">
        {t.customer_name || "—"}
      </div>
    </div>
  </div>

  {/* Liên hệ - ✅ CẬP NHẬT: font-medium để nổi bật SĐT */}
  <div className="flex items-start gap-2">
    <Phone className="h-4 w-4 text-emerald-600 shrink-0" />
    <div>
      <div className="text-slate-400 text-[11px] mb-1 uppercase tracking-wide">
        Liên hệ
      </div>
      <div className="text-slate-900 leading-snug font-medium">
        {t.customer_phone || "—"}
      </div>
    </div>
  </div>

  {/* ✅ MỚI: Quãng đường */}
  <div className="flex items-start gap-2">
    <MapPin className="h-4 w-4 text-amber-600 shrink-0" />
    <div>
      <div className="text-slate-400 text-[11px] mb-1 uppercase tracking-wide">
        Quãng đường
      </div>
      <div className="text-slate-900 leading-snug font-semibold">
        {t.distance ? `${Number(t.distance).toFixed(1)} km` : "—"}
      </div>
    </div>
  </div>
</div>
```

---

## Database Schema Reference

### Trips Table
```sql
CREATE TABLE Trips (
    tripId INT PRIMARY KEY AUTO_INCREMENT,
    bookingId INT NOT NULL,
    startLocation VARCHAR(255),
    endLocation VARCHAR(255),
    distance DECIMAL(10,2),  -- ✅ Đã có sẵn
    status ENUM('SCHEDULED', 'ONGOING', 'COMPLETED'),
    ...
    FOREIGN KEY (bookingId) REFERENCES Bookings(bookingId)
);
```

### Bookings Table
```sql
CREATE TABLE Bookings (
    bookingId INT PRIMARY KEY AUTO_INCREMENT,
    customerId INT NOT NULL,
    ...
    FOREIGN KEY (customerId) REFERENCES Customers(customerId)
);
```

### Customers Table
```sql
CREATE TABLE Customers (
    customerId INT PRIMARY KEY AUTO_INCREMENT,
    fullName VARCHAR(100) NOT NULL,
    phone VARCHAR(20),  -- ✅ Đã có sẵn
    email VARCHAR(100),
    address VARCHAR(255),
    ...
);
```

**Quan hệ:** `Trip → Booking → Customer → phone`

---

## API Response Example

### GET /api/drivers/{driverId}/dashboard

**Response:**
```json
{
  "code": 200,
  "message": "Get driver dashboard successfully",
  "data": {
    "tripId": 123,
    "startLocation": "Hồ Chí Minh",
    "endLocation": "Cần Thơ",
    "startTime": "2024-11-22T10:00:00Z",
    "endTime": "2024-11-22T14:00:00Z",
    "status": "SCHEDULED",
    "customerPhone": "0901234567",  // ✅ MỚI
    "distance": 169.5               // ✅ MỚI (km)
  }
}
```

---

## UI Preview

### Dashboard Card - Trip Details Section

```
┌─────────────────────────────────────────────────────────────────┐
│  📍 ĐIỂM ĐÓN          👤 KHÁCH HÀNG      📞 LIÊN HỆ      🗺️ QUÃNG ĐƯỜNG │
│  Hồ Chí Minh          —                 0901234567      169.5 km      │
└─────────────────────────────────────────────────────────────────┘
```

**Responsive:**
- Mobile: 1 cột (stack vertically)
- Tablet: 2 cột
- Desktop: 4 cột

---

## Testing Checklist

### Backend:
- [ ] Compile thành công (no errors)
- [ ] API trả về `customerPhone` và `distance`
- [ ] Xử lý null-safe khi không có booking/customer
- [ ] Distance format đúng (BigDecimal, 2 chữ số thập phân)

### Frontend:
- [ ] Hiển thị số điện thoại khách hàng
- [ ] Hiển thị quãng đường với format "X.X km"
- [ ] Hiển thị "—" khi không có dữ liệu
- [ ] Responsive trên mobile/tablet/desktop
- [ ] Font weight phù hợp (SĐT: medium, km: semibold)

### Integration:
- [ ] Tạo trip mới với customer phone → hiển thị đúng
- [ ] Tạo trip với distance → hiển thị đúng
- [ ] Trip không có customer → hiển thị "—"
- [ ] Trip không có distance → hiển thị "—"

---

## Notes

### Lý do thêm fields này:
1. **Customer Phone**: Tài xế cần liên hệ khách hàng khi đến điểm đón
2. **Distance**: Tài xế cần biết quãng đường để chuẩn bị (xăng, thời gian)

### Null Handling:
- Backend: Sử dụng optional chaining để tránh NullPointerException
- Frontend: Hiển thị "—" khi không có dữ liệu

### Format:
- Phone: Hiển thị nguyên bản (VD: 0901234567)
- Distance: Format 1 chữ số thập phân (VD: 169.5 km)

---

## Kết luận

✅ **Backend**: Đã thêm customerPhone và distance vào DriverDashboardResponse
✅ **Service**: Đã cập nhật logic lấy dữ liệu từ Trip → Booking → Customer
✅ **Frontend**: Đã hiển thị 2 thông tin mới trong Dashboard UI
✅ **Responsive**: Grid layout tự động điều chỉnh theo màn hình
✅ **Null-safe**: Xử lý đầy đủ trường hợp không có dữ liệu

**Tài xế giờ có thể:**
- Xem số điện thoại khách hàng để liên hệ
- Biết quãng đường cần di chuyển
- Chuẩn bị tốt hơn cho chuyến đi
