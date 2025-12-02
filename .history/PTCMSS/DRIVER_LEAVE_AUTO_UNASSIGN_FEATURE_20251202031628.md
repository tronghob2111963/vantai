# Driver Leave Request Auto-Unassign Feature

## Tổng Quan
Khi điều phối viên chấp nhận đơn nghỉ phép của tài xế, hệ thống tự động:
1. **Kiểm tra** các chuyến đi trong thời gian nghỉ
2. **Xóa tài xế** khỏi các chuyến đó
3. **Tạo cảnh báo** để điều phối viên sắp xếp tài xế thay thế
4. **Thông báo** cho tài xế về kết quả duyệt đơn

## Backend Changes

### 1. AlertType Enum (Thêm loại cảnh báo mới)
**File:** `AlertType.java`
```java
REASSIGNMENT_NEEDED  // Cần sắp xếp lại tài xế
```

### 2. NotificationServiceImpl (Logic chính)
**File:** `NotificationServiceImpl.java`

#### Method: `checkDriverScheduleConflict(DriverDayOff dayOff)`
**Trước:**
- Kiểm tra conflict và **throw exception** để chặn approve
- Điều phối viên phải tự xử lý conflict

**Sau:**
- Kiểm tra conflict
- **Tự động xóa** tài xế khỏi các chuyến conflict (`tripDriverRepository.delete(td)`)
- **Tạo SystemAlert** với:
  - Type: `REASSIGNMENT_NEEDED`
  - Severity: `HIGH`
  - Danh sách các chuyến bị ảnh hưởng
  - Liên kết tới DriverDayOff record
- **Không throw exception** → Approve thành công

#### Method: `updateRelatedEntity(ApprovalHistory, boolean)`
**Thêm logic thông báo cho tài xế:**
```java
// Gửi notification cho tài xế
Notification notification = new Notification();
notification.setUser(driverUser);
notification.setType(NotificationType.APPROVAL_RESULT);
notification.setTitle(approved ? "Đơn nghỉ phép được chấp nhận" : "Đơn nghỉ phép bị từ chối");
notification.setMessage(...);
notificationRepository.save(notification);
```

### 3. EmployeeServiceImpl (Fix Driver creation)
**File:** `EmployeeServiceImpl.java`

**Thêm logic tạo Driver record:**
```java
// Sau khi tạo Employee, kiểm tra role
if ("DRIVER".equalsIgnoreCase(role.getRoleName()) || "Tài xế".equalsIgnoreCase(role.getRoleName())) {
    Drivers driver = new Drivers();
    driver.setEmployee(savedEmployee);
    driver.setBranch(branch);
    driverRepository.save(driver);
}
```

**Lý do:**
- Trước đây: Tạo Employee với role DRIVER nhưng **không tạo Driver record**
- Kết quả: Tài xế login bị lỗi "RuntimeException: Không tìm thấy tài xế cho nhân viên này"
- Giờ: Tự động tạo Driver record khi tạo Employee với role DRIVER

## Frontend Changes

### NotificationsWidget.jsx
**File:** `src/components/module 5/NotificationsWidget.jsx`

#### Method: `handleApprove(historyId)`
**Trước:**
1. Kiểm tra conflict
2. Hỏi user: "Hủy gán và duyệt" hoặc "Từ chối"?
3. Nếu chọn hủy gán → Gọi `unassignTrip()` cho từng chuyến
4. Sau đó mới approve

**Sau:**
1. Kiểm tra conflict
2. Nếu có conflict → Hiển thị **cảnh báo thông tin**:
   ```
   ⚠️ CẢNH BÁO: Tài xế có N chuyến trong thời gian nghỉ.
   
   Các chuyến xung đột:
   1. Chuyến #123 - 02/12/2025
   2. Chuyến #124 - 03/12/2025
   
   ✅ Nếu bạn chấp nhận, hệ thống sẽ TỰ ĐỘNG:
      • Xóa tài xế khỏi N chuyến trên
      • Tạo cảnh báo để bạn sắp xếp tài xế khác
      • Thông báo cho tài xế về kết quả
   
   ❌ Nếu bạn từ chối, tài xế vẫn giữ nguyên lịch chuyến.
   
   Bạn có muốn CHẤP NHẬN đơn nghỉ phép này không?
   ```
3. Nếu user chấp nhận → Gọi approve API
4. **Backend tự động** xóa tài xế và tạo alert
5. Frontend chỉ hiển thị thông báo thành công

**Lợi ích:**
- Logic tập trung ở backend → Dễ maintain
- Frontend đơn giản hơn
- Đồng bộ giữa approve và unassign (transaction)
- Alert được tạo ngay lập tức

## Database Impact

### Tables Modified
1. **trip_drivers** - Xóa records khi tài xế nghỉ phép
2. **driver_day_off** - Update status khi duyệt/từ chối
3. **system_alerts** - Tạo alert mới với type REASSIGNMENT_NEEDED
4. **notifications** - Tạo thông báo cho tài xế
5. **drivers** - Tự động tạo record khi tạo Employee với role DRIVER

### Cần Kiểm Tra
- Foreign key constraints trên trip_drivers (ON DELETE CASCADE?)
- Index trên trip_drivers.driver_id và trip.start_time (để query conflict nhanh)

## Testing Checklist

### Backend
- [ ] Tạo Employee với role DRIVER → Verify Drivers table có record
- [ ] Tài xế login sau khi tạo account → Dashboard load thành công
- [ ] Tài xế xin nghỉ phép (có chuyến trong thời gian nghỉ)
- [ ] Coordinator approve đơn nghỉ
- [ ] Verify: trip_drivers records bị xóa
- [ ] Verify: system_alerts có alert REASSIGNMENT_NEEDED
- [ ] Verify: notifications có thông báo cho tài xế
- [ ] Verify: driver_day_off.status = APPROVED

### Frontend
- [ ] Coordinator vào Notifications Widget
- [ ] Thấy đơn nghỉ phép PENDING
- [ ] Click Approve → Hiển thị cảnh báo với danh sách chuyến conflict
- [ ] Chấp nhận → Thành công, thông báo hiển thị
- [ ] Refresh → Alert REASSIGNMENT_NEEDED xuất hiện
- [ ] Tài xế vào Dashboard → Thấy thông báo "Đơn nghỉ phép được chấp nhận"
- [ ] Tài xế kiểm tra lịch → Không còn các chuyến trong thời gian nghỉ

## API Endpoints Affected

### Existing (Modified)
- `POST /api/notifications/approvals/{historyId}/approve`
  - Giờ tự động xóa trip assignments
  - Tạo alerts và notifications

### Unchanged
- `POST /api/notifications/approvals/{historyId}/reject` - Vẫn giữ nguyên
- `GET /api/notifications/dashboard` - Vẫn trả về dashboard data
- `GET /api/driver/schedule/{driverId}` - Frontend dùng để check conflict preview

## Migration Notes

### Build & Deploy
```bash
# Backend
cd PTCMSS/ptcmss-backend
./mvnw clean package -DskipTests

# Restart backend service
# No database migration needed - changes are code-only
```

### Frontend
```bash
cd PTCMSS_FRONTEND
npm run build
# Deploy to production
```

### Rollback Plan
Nếu có vấn đề:
1. Revert `NotificationServiceImpl.checkDriverScheduleConflict()` về throw exception
2. Revert frontend `handleApprove()` về gọi `unassignTrip()` manually
3. Redeploy cả backend và frontend

## Known Issues & Future Improvements

### Known Issues
- Nếu hệ thống fail giữa chừng (xóa 1 số trip nhưng chưa hết) → Transaction rollback
- Alert không có link trực tiếp tới trip assignment page

### Future Improvements
1. **Email notification** cho điều phối viên về conflict
2. **Suggest tài xế thay thế** dựa trên availability
3. **Undo button** trong alert để reassign driver nếu approve nhầm
4. **Bulk approval** cho nhiều đơn nghỉ cùng lúc
5. **Calendar view** hiển thị driver availability và conflicts

## Author
GitHub Copilot - Claude Sonnet 4.5
Date: December 2, 2025
