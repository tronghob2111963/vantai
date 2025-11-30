# Chức năng: Kiểm tra conflict lịch trình và Hủy yêu cầu nghỉ phép

## Tổng quan

Thực hiện 2 chức năng quan trọng cho quản lý nghỉ phép tài xế:

1. **Kiểm tra conflict khi phê duyệt nghỉ phép**: Cảnh báo nếu tài xế đã được lên lịch chuyến trong thời gian nghỉ
2. **Cho phép tài xế hủy yêu cầu nghỉ phép**: Tài xế có thể hủy yêu cầu đã gửi, trạng thái chuyển về ACTIVE

## Chức năng 1: Kiểm tra Conflict với Lịch trình

### Vấn đề
- Tài xế đã được lên lịch chuyến đi
- Tài xế gửi yêu cầu nghỉ phép trong thời gian đó
- Điều phối viên phê duyệt mà không biết có conflict
- **Kết quả**: Tài xế nghỉ nhưng vẫn có chuyến → Không có tài xế chạy

### Giải pháp

#### Backend - NotificationServiceImpl.java

**Method kiểm tra conflict:**
```java
private void checkDriverScheduleConflict(DriverDayOff dayOff) {
    // 1. Lấy thông tin tài xế và thời gian nghỉ
    Integer driverId = dayOff.getDriver().getId();
    LocalDate startDate = dayOff.getStartDate();
    LocalDate endDate = dayOff.getEndDate();
    
    // 2. Chuyển sang Instant để query
    Instant startInstant = startDate.atStartOfDay(ZoneId.systemDefault()).toInstant();
    Instant endInstant = endDate.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant();
    
    // 3. Tìm các chuyến đi conflict
    List<TripDrivers> conflictTrips = 
        tripDriverRepository.findConflictingTrips(driverId, startInstant, endInstant);
    
    // 4. Nếu có conflict → throw exception với thông báo chi tiết
    if (!conflictTrips.isEmpty()) {
        StringBuilder message = new StringBuilder();
        message.append("⚠️ CẢNH BÁO: Tài xế đã được lên lịch X chuyến...\n");
        message.append("Danh sách chuyến bị conflict:\n");
        // ... chi tiết từng chuyến
        message.append("\n❌ Vui lòng xếp tài xế thay thế trước khi phê duyệt!");
        
        throw new RuntimeException(message.toString());
    }
}
```

**Gọi trong updateRelatedEntity:**
```java
case DRIVER_DAY_OFF:
    DriverDayOff dayOff = driverDayOffRepository.findById(...).orElse(null);
    if (dayOff != null) {
        // ✅ KIỂM TRA CONFLICT KHI APPROVE
        if (approved) {
            checkDriverScheduleConflict(dayOff);
        }
        
        dayOff.setStatus(approved ? APPROVED : REJECTED);
        driverDayOffRepository.save(dayOff);
    }
    break;
```

#### Backend - TripDriverRepository.java

**Query tìm chuyến conflict:**
```java
@Query("SELECT td FROM TripDrivers td JOIN FETCH td.trip t " +
       "WHERE td.driver.id = :driverId " +
       "AND t.startTime >= :startDate " +
       "AND t.startTime < :endDate " +
       "AND t.status NOT IN ('CANCELLED', 'COMPLETED') " +
       "ORDER BY t.startTime ASC")
List<TripDrivers> findConflictingTrips(
    @Param("driverId") Integer driverId,
    @Param("startDate") Instant startDate,
    @Param("endDate") Instant endDate
);
```

### Luồng hoạt động

```
1. Tài xế gửi yêu cầu nghỉ: 30/11 - 02/12
   ↓
2. Điều phối viên click "Phê duyệt"
   ↓
3. Backend kiểm tra lịch trình tài xế
   ↓
4a. KHÔNG có conflict → Phê duyệt thành công
4b. CÓ conflict → Throw exception với danh sách chuyến
   ↓
5. Frontend hiển thị thông báo lỗi chi tiết
   ↓
6. Điều phối viên phải xếp tài xế thay thế trước
```

### Thông báo lỗi

```
⚠️ CẢNH BÁO: Tài xế đã được lên lịch 2 chuyến trong thời gian nghỉ (30/11/2024 đến 02/12/2024).

Danh sách chuyến bị conflict:
- Chuyến #123: Hà Nội → Hải Phòng (Ngày: 2024-11-30)
- Chuyến #125: Hải Phòng → Hà Nội (Ngày: 2024-12-01)

❌ Vui lòng xếp tài xế thay thế trước khi phê duyệt nghỉ phép!
```

## Chức năng 2: Tài xế Hủy Yêu cầu Nghỉ phép

### Vấn đề
- Tài xế gửi yêu cầu nghỉ nhưng sau đó muốn hủy
- Hoặc yêu cầu đã được duyệt nhưng tài xế không nghỉ nữa
- Hiện tại không có cách nào để hủy

### Giải pháp

#### Backend - DriverService.java

**Thêm method mới:**
```java
void cancelDayOffRequest(Integer dayOffId, Integer driverId);
```

#### Backend - DriverServiceImpl.java

**Implementation:**
```java
@Override
@Transactional
public void cancelDayOffRequest(Integer dayOffId, Integer driverId) {
    // 1. Tìm yêu cầu nghỉ
    DriverDayOff dayOff = driverDayOffRepository.findById(dayOffId)
        .orElseThrow(() -> new RuntimeException("Không tìm thấy yêu cầu nghỉ phép"));
    
    // 2. Kiểm tra quyền
    if (!dayOff.getDriver().getId().equals(driverId)) {
        throw new RuntimeException("Bạn không có quyền hủy yêu cầu này");
    }
    
    // 3. Kiểm tra trạng thái
    if (dayOff.getStatus() == REJECTED) {
        throw new RuntimeException("Không thể hủy yêu cầu đã bị từ chối");
    }
    if (dayOff.getStatus() == CANCELLED) {
        throw new RuntimeException("Yêu cầu đã được hủy trước đó");
    }
    
    // 4. Cập nhật trạng thái yêu cầu
    dayOff.setStatus(CANCELLED);
    driverDayOffRepository.save(dayOff);
    
    // 5. Cập nhật trạng thái tài xế về ACTIVE
    Drivers driver = dayOff.getDriver();
    if (driver.getStatus() == OFF_DUTY) {
        driver.setStatus(ACTIVE);
        driverRepository.save(driver);
    }
}
```

#### Backend - DriverDayOffStatus.java (enum)

**Thêm trạng thái mới:**
```java
public enum DriverDayOffStatus {
    PENDING,    // Chờ duyệt
    APPROVED,   // Đã duyệt
    REJECTED,   // Từ chối
    CANCELLED   // Đã hủy (bởi tài xế) ← MỚI
}
```

#### Backend - DriverController.java

**API endpoint:**
```java
@DeleteMapping("/{driverId}/dayoff/{dayOffId}")
@PreAuthorize("hasRole('DRIVER')")
public ResponseData<?> cancelDayOffRequest(
    @PathVariable Integer driverId,
    @PathVariable Integer dayOffId
) {
    driverService.cancelDayOffRequest(dayOffId, driverId);
    return new ResponseData<>(200, 
        "Đã hủy yêu cầu nghỉ phép thành công. Trạng thái của bạn đã chuyển về sẵn sàng.", 
        null);
}
```

### Luồng hoạt động

```
1. Tài xế xem danh sách yêu cầu nghỉ phép
   ↓
2. Click nút "Hủy yêu cầu" trên yêu cầu PENDING hoặc APPROVED
   ↓
3. Xác nhận hủy
   ↓
4. Backend kiểm tra quyền và trạng thái
   ↓
5. Cập nhật trạng thái yêu cầu → CANCELLED
   ↓
6. Cập nhật trạng thái tài xế → ACTIVE (nếu đang OFF_DUTY)
   ↓
7. Trả về thông báo thành công
```

### Quy tắc nghiệp vụ

| Trạng thái yêu cầu | Có thể hủy? | Kết quả |
|-------------------|-------------|---------|
| PENDING | ✅ Có | Hủy thành công, không tính buổi nghỉ |
| APPROVED | ✅ Có | Hủy thành công, trạng thái → ACTIVE |
| REJECTED | ❌ Không | "Không thể hủy yêu cầu đã bị từ chối" |
| CANCELLED | ❌ Không | "Yêu cầu đã được hủy trước đó" |

### Thay đổi trạng thái tài xế

| Trạng thái hiện tại | Sau khi hủy |
|--------------------|-------------|
| ACTIVE | ACTIVE (không đổi) |
| OFF_DUTY | ACTIVE ✅ |
| ON_TRIP | ACTIVE |
| INACTIVE | INACTIVE (không đổi) |

## API Endpoints

### 1. Phê duyệt nghỉ phép (có kiểm tra conflict)
```
POST /api/notifications/approvals/{historyId}/approve
Authorization: Bearer <token>
Body: { "note": "Đồng ý" }

Response (Success):
{
  "success": true,
  "message": "Phê duyệt thành công"
}

Response (Conflict):
{
  "success": false,
  "message": "⚠️ CẢNH BÁO: Tài xế đã được lên lịch 2 chuyến..."
}
```

### 2. Hủy yêu cầu nghỉ phép
```
DELETE /api/drivers/{driverId}/dayoff/{dayOffId}
Authorization: Bearer <token>

Response:
{
  "code": 200,
  "message": "Đã hủy yêu cầu nghỉ phép thành công. Trạng thái của bạn đã chuyển về sẵn sàng.",
  "data": null
}
```

## Frontend UI/UX

### Danh sách yêu cầu nghỉ phép (Tài xế)

```
┌─────────────────────────────────────────────────────┐
│ Danh sách yêu cầu nghỉ phép                         │
├─────────────────────────────────────────────────────┤
│ 🟡 Xin nghỉ phép                    [Hủy yêu cầu]  │
│    Từ ngày: 30/11/2025                              │
│    Đến ngày: 02/12/2025                             │
│    Lý do: Việc gia đình                             │
│    Trạng thái: Chờ duyệt                            │
├─────────────────────────────────────────────────────┤
│ ✅ Xin nghỉ phép                    [Hủy yêu cầu]  │
│    Từ ngày: 25/11/2025                              │
│    Đến ngày: 26/11/2025                             │
│    Lý do: Nghỉ giải quyết việc cá nhân              │
│    Trạng thái: Đã duyệt                             │
├─────────────────────────────────────────────────────┤
│ ❌ Xin nghỉ phép                                    │
│    Từ ngày: 20/11/2025                              │
│    Đến ngày: 21/11/2025                             │
│    Lý do: Việc gia đình                             │
│    Trạng thái: Từ chối                              │
│    Ghi chú: Không đủ nhân sự                        │
└─────────────────────────────────────────────────────┘
```

### Dialog xác nhận hủy

```
┌─────────────────────────────────────────┐
│ ⚠️ Xác nhận hủy yêu cầu nghỉ phép      │
├─────────────────────────────────────────┤
│ Bạn có chắc muốn hủy yêu cầu nghỉ      │
│ từ 30/11/2025 đến 02/12/2025?          │
│                                         │
│ Sau khi hủy:                            │
│ • Yêu cầu sẽ chuyển sang trạng thái    │
│   "Đã hủy"                              │
│ • Trạng thái của bạn sẽ chuyển về      │
│   "Sẵn sàng"                            │
│ • Không tính vào số buổi nghỉ          │
│                                         │
│     [Hủy bỏ]        [Xác nhận hủy]    │
└─────────────────────────────────────────┘
```

### Thông báo lỗi khi phê duyệt (Coordinator)

```
┌─────────────────────────────────────────────────────┐
│ ❌ Không thể phê duyệt nghỉ phép                    │
├─────────────────────────────────────────────────────┤
│ ⚠️ CẢNH BÁO: Tài xế Nguyễn Văn A đã được lên      │
│ lịch 2 chuyến trong thời gian nghỉ (30/11/2024     │
│ đến 02/12/2024).                                    │
│                                                     │
│ Danh sách chuyến bị conflict:                       │
│ • Chuyến #123: Hà Nội → Hải Phòng                  │
│   Ngày: 30/11/2024                                  │
│ • Chuyến #125: Hải Phòng → Hà Nội                  │
│   Ngày: 01/12/2024                                  │
│                                                     │
│ ❌ Vui lòng xếp tài xế thay thế trước khi phê      │
│ duyệt nghỉ phép!                                    │
│                                                     │
│ [Xem chi tiết lịch trình]  [Đóng]                 │
└─────────────────────────────────────────────────────┘
```

## Test Cases

### Test Case 1: Phê duyệt nghỉ phép - Không có conflict
- **Input:** Approve yêu cầu nghỉ 30/11-02/12, tài xế không có chuyến nào
- **Expected:** ✅ Phê duyệt thành công, trạng thái → APPROVED

### Test Case 2: Phê duyệt nghỉ phép - Có conflict
- **Input:** Approve yêu cầu nghỉ 30/11-02/12, tài xế có 2 chuyến trong thời gian này
- **Expected:** ❌ Throw exception với danh sách chuyến conflict

### Test Case 3: Tài xế hủy yêu cầu PENDING
- **Input:** Cancel yêu cầu đang PENDING
- **Expected:** ✅ Hủy thành công, trạng thái → CANCELLED

### Test Case 4: Tài xế hủy yêu cầu APPROVED
- **Input:** Cancel yêu cầu đã APPROVED, tài xế đang OFF_DUTY
- **Expected:** ✅ Hủy thành công, trạng thái yêu cầu → CANCELLED, trạng thái tài xế → ACTIVE

### Test Case 5: Tài xế hủy yêu cầu REJECTED
- **Input:** Cancel yêu cầu đã REJECTED
- **Expected:** ❌ "Không thể hủy yêu cầu đã bị từ chối"

### Test Case 6: Tài xế A hủy yêu cầu của tài xế B
- **Input:** Driver A gọi API cancel yêu cầu của Driver B
- **Expected:** ❌ "Bạn không có quyền hủy yêu cầu này"

## Database Changes

### Enum DriverDayOffStatus
```sql
-- Thêm giá trị mới
ALTER TABLE driver_day_off 
MODIFY COLUMN status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED');
```

## Logging

### Success logs
```
[DayOff] Checking schedule conflict for driver 5 from 2024-11-30 to 2024-12-02
[DayOff] No schedule conflict found for driver 5
[DriverDayOff] Driver 5 cancelling day off request 10
[DriverDayOff] Driver 5 status changed from OFF_DUTY to ACTIVE
[DriverDayOff] Day off request 10 cancelled successfully
```

### Warning/Error logs
```
[DayOff] Found 2 conflicting trips for driver 5
[DriverDayOff] Cannot cancel: request already rejected
[DriverDayOff] Cannot cancel: not authorized
```

## Files đã thay đổi

### Backend
- ✅ `NotificationServiceImpl.java` - Thêm checkDriverScheduleConflict()
- ✅ `TripDriverRepository.java` - Thêm findConflictingTrips()
- ✅ `DriverService.java` - Thêm cancelDayOffRequest()
- ✅ `DriverServiceImpl.java` - Implement cancelDayOffRequest()
- ✅ `DriverDayOffStatus.java` - Thêm CANCELLED
- ✅ `DriverController.java` - Thêm DELETE endpoint

### Documentation
- ✅ `DAY_OFF_CONFLICT_AND_CANCEL_FEATURE.md`

## Lợi ích

### Cho Điều phối viên
- ✅ Tránh phê duyệt nhầm khi tài xế đã có lịch
- ✅ Biết chính xác chuyến nào bị conflict
- ✅ Có thời gian xếp tài xế thay thế

### Cho Tài xế
- ✅ Linh hoạt hủy yêu cầu nghỉ khi có thay đổi
- ✅ Không bị tính buổi nghỉ khi hủy
- ✅ Trạng thái tự động chuyển về ACTIVE

### Cho Hệ thống
- ✅ Đảm bảo luôn có tài xế cho mỗi chuyến
- ✅ Tránh conflict dữ liệu
- ✅ Quản lý nghỉ phép chính xác hơn
