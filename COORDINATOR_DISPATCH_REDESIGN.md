# Cập nhật Bảng Điều Phối - Coordinator

## Tổng quan thay đổi

Đã thực hiện redesign hoàn toàn trang điều phối (CoordinatorTimelinePro) theo yêu cầu mới:

### Trước đây
- Khung 1: Queue (danh sách chuyến PENDING)
- Khung 2: Gantt chart timeline với lịch tài xế và xe

### Sau khi thay đổi
- **Bên trái**: Danh sách chuyến chưa được gắn lịch
  - Click vào chuyến để hiện popup gắn lịch
  - Có gợi ý tài xế và xe phù hợp
  - Tìm kiếm theo mã chuyến, tuyến đường, khách hàng
  
- **Bên phải**: Danh sách sự cố chuyến đi
  - Hiển thị các sự cố đang xảy ra
  - Click vào để xem chi tiết sự cố
  - Phân loại theo mức độ nghiêm trọng (HIGH/MEDIUM/LOW)

## Chi tiết thay đổi

### 1. Components mới

#### UnassignedTripsPanel
- Thay thế QueuePanel cũ
- Hiển thị danh sách chuyến chưa gắn lịch
- Click vào chuyến để mở dialog gán lịch
- Tìm kiếm theo mã, tuyến đường, tên khách hàng
- Hiển thị thời gian pickup và độ khẩn cấp

#### IncidentsPanel
- Component mới để hiển thị sự cố chuyến đi
- Phân loại theo mức độ: HIGH/CRITICAL, MEDIUM, LOW
- Tìm kiếm theo mã chuyến, mô tả
- Click để xem chi tiết sự cố

#### IncidentDetailModal
- Modal hiển thị chi tiết sự cố
- Thông tin: mã chuyến, mức độ, tài xế, xe, thời gian, mô tả
- Nút "Xử lý sự cố" để xử lý

### 2. Components đã loại bỏ

- TimeHeader (header timeline Gantt)
- Row (dòng timeline cho tài xế/xe)
- Tooltip
- UtilBadge
- Legend
- Modal (chi tiết block thời gian)

### 3. State changes

**Đã loại bỏ:**
- `drivers`, `vehicles` - không còn cần Gantt chart
- `zoom` - không còn zoom timeline
- `query` - đã tách riêng cho từng panel
- `showLabels`, `showBusy`, `showMaint`, `minRest` - các filter Gantt
- `active` - modal chi tiết block thời gian

**Đã thêm:**
- `incidents` - danh sách sự cố chuyến đi
- `selectedIncident` - sự cố được chọn để xem chi tiết
- `stats.incidentsCount` - số lượng sự cố

### 4. Functions đã loại bỏ

- `computeOverlapFlags()` - phát hiện xung đột lịch
- `computeRestFlags()` - phát hiện thiếu nghỉ
- `utilizationPercent()` - tính % utilization
- `normalizeScheduleWindow()`, `normalizeScheduleItems()`
- `normalizeDriverSchedules()`, `normalizeVehicleSchedules()`
- `availableDriversAt()`, `availableVehiclesAt()` - gợi ý dựa trên timeline
- `jumpTo()` - nhảy đến giờ cụ thể trên timeline
- `syncScroll()` - đồng bộ scroll header/body
- `isSameDay()` - kiểm tra cùng ngày

### 5. Constants đã loại bỏ

- `DAY_START`, `DAY_END` - giờ bắt đầu/kết thúc ngày
- `HOUR_WIDTH` - độ rộng mỗi giờ
- `TICK_MINUTES` - khoảng cách vạch lưới
- `COLORS` - màu sắc cho Gantt chart
- `toDate()`, `msBetween()`, `minutesBetween()`, `hoursBetween()`
- `xFrom()`, `wFrom()` - tính toán vị trí trên timeline
- `startOfDay()` - thời điểm bắt đầu ngày

### 6. UI Changes

**Header:**
- Đổi tiêu đề: "Coordinator (Queue + Schedule)" → "Bảng điều phối"
- Đổi mô tả: "Queue (PENDING) · Gantt 06:00–24:00..." → "Chuyến chưa gắn lịch · Sự cố chuyến đi · Gán lịch nhanh"
- Loại bỏ: Zoom+/-, các nút jump (08:00, 12:00, 18:00, Now)

**Dashboard Stats:**
- Thêm card "Sự cố" với số lượng sự cố
- Layout: 5 cards → 6 cards

**Main Layout:**
- Từ: Queue (360px) + Gantt (1fr)
- Sang: Chuyến chưa gắn lịch (1fr) + Sự cố (1fr)
- Grid: `lg:grid-cols-[360px_1fr]` → `lg:grid-cols-2`

**Loại bỏ:**
- Filter bar cho Gantt (search driver/vehicle, checkboxes, min rest)
- Legend (giải thích màu sắc)

## API Integration

### Dữ liệu cần từ backend

**Dashboard API (`/api/v1/coordinator/dashboard`):**
```javascript
{
  pendingTrips: [...],      // Chuyến chưa gắn lịch
  incidents: [...],          // Sự cố chuyến đi (MỚI)
  pendingCount: 0,
  assignedCount: 0,
  inProgressCount: 0,
  completedCount: 0,
  cancelledCount: 0
}
```

**Incident object structure:**
```javascript
{
  id: number,
  tripCode: string,
  tripId: number,
  severity: "HIGH" | "MEDIUM" | "LOW",
  description: string,
  driverName: string,
  vehiclePlate: string,
  reportedAt: string (ISO datetime),
  status: string,
  resolution: string (optional)
}
```

## Testing

### Test cases cần kiểm tra:

1. **Chuyến chưa gắn lịch:**
   - Hiển thị đúng danh sách
   - Sắp xếp theo thời gian pickup
   - Tìm kiếm hoạt động
   - Click vào chuyến mở dialog gán lịch
   - Hiển thị độ khẩn cấp (màu sắc)

2. **Sự cố chuyến đi:**
   - Hiển thị danh sách sự cố
   - Phân loại theo mức độ
   - Tìm kiếm hoạt động
   - Click vào sự cố mở modal chi tiết
   - Hiển thị "Không có sự cố" khi list rỗng

3. **Dialog gán lịch:**
   - Load danh sách tài xế/xe theo chi nhánh
   - Chọn tài xế và xe
   - Gán chuyến thành công
   - Xử lý lỗi

4. **Modal chi tiết sự cố:**
   - Hiển thị đầy đủ thông tin
   - Nút "Xử lý sự cố" (chưa implement logic)

5. **Dashboard stats:**
   - Hiển thị đúng số liệu
   - Cập nhật khi refresh

## Notes

- Đã loại bỏ hoàn toàn Gantt chart timeline vì không thể sử dụng
- Focus vào 2 chức năng chính: gán lịch nhanh và theo dõi sự cố
- UI đơn giản hơn, dễ sử dụng hơn
- Cần backend hỗ trợ API trả về danh sách incidents
- Nút "Xử lý sự cố" trong modal chi tiết chưa có logic, cần implement sau

## Files Changed

- `vantai/PTCMSS_FRONTEND/src/components/module 5/CoordinatorTimelinePro.jsx`

## Migration Guide

Nếu backend chưa có API incidents, có thể:
1. Trả về array rỗng: `incidents: []`
2. Hoặc mock data tạm thời để test UI

Ví dụ mock data:
```javascript
incidents: [
  {
    id: 1,
    tripCode: "TRIP-123",
    severity: "HIGH",
    description: "Xe hỏng giữa đường",
    driverName: "Nguyễn Văn A",
    vehiclePlate: "30G-123.45",
    reportedAt: "2024-12-01T10:30:00",
    status: "PENDING"
  }
]
```
