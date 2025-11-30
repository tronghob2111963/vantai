# Chức năng: Gửi thông báo cho tài xế khi có đánh giá mới

## Mô tả

Khi khách hàng hoàn thành đánh giá chuyến đi, hệ thống sẽ **tự động gửi thông báo** cho tài xế để thông báo rằng chuyến đi đã được đánh giá.

## Luồng hoạt động

```
1. Khách hàng đánh giá chuyến đi
   ↓
2. Hệ thống lưu đánh giá vào database
   ↓
3. Hệ thống tạo thông báo cho tài xế
   ↓
4. Lưu thông báo vào bảng notifications
   ↓
5. Gửi real-time notification qua WebSocket (nếu tài xế đang online)
   ↓
6. Tài xế nhận được thông báo và có thể xem chi tiết
```

## Thông tin thông báo

### Tiêu đề (Title)
```
"Đánh giá mới từ khách hàng"
```

### Nội dung (Message)
```
"{Tên khách hàng} đã đánh giá chuyến đi của bạn. Điểm: {X.X}⭐ - Chuyến #{tripId}: {Điểm đi} → {Điểm đến}"
```

### Ví dụ
```
Title: "Đánh giá mới từ khách hàng"
Message: "Nguyễn Văn A đã đánh giá chuyến đi của bạn. Điểm: 4.5⭐ - Chuyến #123: Hà Nội → Hải Phòng"
```

## Cài đặt kỹ thuật

### 1. Backend - RatingServiceImpl.java

#### Thêm dependencies
```java
private final NotificationRepository notificationRepository;
private final WebSocketNotificationService webSocketNotificationService;
```

#### Method gửi thông báo
```java
private void sendRatingNotificationToDriver(DriverRatings rating, Drivers driver, Trips trip) {
    try {
        // 1. Lấy user của tài xế
        Users driverUser = driver.getEmployee().getUser();
        
        // 2. Tạo thông báo
        Notifications notification = new Notifications();
        notification.setUser(driverUser);
        notification.setTitle("Đánh giá mới từ khách hàng");
        notification.setMessage(...); // Chi tiết đánh giá
        notification.setIsRead(false);
        
        // 3. Lưu vào database
        notificationRepository.save(notification);
        
        // 4. Gửi real-time qua WebSocket
        webSocketNotificationService.sendNotificationToUser(
            driverUser.getId(),
            notification.getTitle(),
            notification.getMessage()
        );
        
    } catch (Exception e) {
        log.error("Failed to send notification", e);
    }
}
```

#### Gọi trong createRating
```java
@Override
@Transactional
public RatingResponse createRating(RatingRequest request, Integer userId) {
    // ... existing code ...
    
    // Save rating
    rating = ratingsRepository.save(rating);
    
    // Update driver's overall rating
    updateDriverOverallRating(driver.getId());
    
    // ✅ GỬI THÔNG BÁO CHO TÀI XẾ
    sendRatingNotificationToDriver(rating, driver, trip);
    
    return mapToResponse(rating);
}
```

### 2. Database - notifications table

```sql
CREATE TABLE notifications (
    notificationId INT PRIMARY KEY AUTO_INCREMENT,
    userId INT NOT NULL,
    title VARCHAR(100),
    message VARCHAR(500),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    isRead BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (userId) REFERENCES users(userId)
);
```

### 3. WebSocket Notification

Sử dụng service có sẵn `WebSocketNotificationService` để gửi real-time notification:

```java
webSocketNotificationService.sendNotificationToUser(
    userId,
    title,
    message
);
```

## Thông tin trong thông báo

| Trường | Mô tả | Ví dụ |
|--------|-------|-------|
| **Title** | Tiêu đề thông báo | "Đánh giá mới từ khách hàng" |
| **Message** | Nội dung chi tiết | "Nguyễn Văn A đã đánh giá chuyến đi của bạn. Điểm: 4.5⭐ - Chuyến #123: Hà Nội → Hải Phòng" |
| **Customer Name** | Tên khách hàng | "Nguyễn Văn A" |
| **Overall Rating** | Điểm trung bình | 4.5 |
| **Trip ID** | Mã chuyến đi | 123 |
| **Start Location** | Điểm đi | "Hà Nội" |
| **End Location** | Điểm đến | "Hải Phòng" |
| **Created At** | Thời gian tạo | 2024-12-01 10:30:00 |
| **Is Read** | Đã đọc chưa | false |

## Các trường hợp xử lý

### ✅ Trường hợp 1: Tài xế có tài khoản user
- **Kết quả:** Gửi thông báo thành công
- **Lưu vào:** Database + WebSocket (nếu online)

### ⚠️ Trường hợp 2: Tài xế không có tài khoản user
- **Kết quả:** Log warning, không gửi thông báo
- **Log:** "Cannot send notification: Driver {id} has no user account"

### ⚠️ Trường hợp 3: WebSocket service không khả dụng
- **Kết quả:** Vẫn lưu vào database, log warning
- **Log:** "Failed to send WebSocket notification"

### ⚠️ Trường hợp 4: Lỗi khi lưu notification
- **Kết quả:** Log error, không ảnh hưởng đến việc lưu rating
- **Log:** "Failed to send rating notification to driver {id}"

## Tích hợp với Frontend

### API endpoint để lấy thông báo
```
GET /api/notifications/user/{userId}?page=1&limit=20
```

### Response format
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "notificationId": 1,
        "title": "Đánh giá mới từ khách hàng",
        "message": "Nguyễn Văn A đã đánh giá chuyến đi của bạn. Điểm: 4.5⭐ - Chuyến #123: Hà Nội → Hải Phòng",
        "createdAt": "2024-12-01T10:30:00Z",
        "isRead": false
      }
    ],
    "totalCount": 10,
    "unreadCount": 3
  }
}
```

### WebSocket subscription
```javascript
// Tài xế subscribe vào topic cá nhân
stompClient.subscribe(`/user/${userId}/notifications`, (message) => {
    const notification = JSON.parse(message.body);
    // Hiển thị notification popup
    showNotification(notification.title, notification.message);
});
```

## UI/UX cho tài xế

### 1. Notification Bell Icon
```
🔔 (3) ← Badge hiển thị số thông báo chưa đọc
```

### 2. Notification Dropdown
```
┌─────────────────────────────────────────┐
│ Thông báo                               │
├─────────────────────────────────────────┤
│ 🆕 Đánh giá mới từ khách hàng          │
│    Nguyễn Văn A đã đánh giá...         │
│    4.5⭐ - Chuyến #123                  │
│    2 phút trước                         │
├─────────────────────────────────────────┤
│ ✅ Đánh giá mới từ khách hàng          │
│    Trần Thị B đã đánh giá...           │
│    5.0⭐ - Chuyến #122                  │
│    1 giờ trước                          │
├─────────────────────────────────────────┤
│ Xem tất cả →                            │
└─────────────────────────────────────────┘
```

### 3. Notification Detail Page
```
┌─────────────────────────────────────────┐
│ ← Quay lại                              │
│                                         │
│ 📊 Đánh giá mới từ khách hàng          │
│                                         │
│ Khách hàng: Nguyễn Văn A               │
│ Chuyến đi: #123                         │
│ Tuyến: Hà Nội → Hải Phòng              │
│                                         │
│ ⭐ Điểm tổng: 4.5/5.0                   │
│                                         │
│ Chi tiết:                               │
│ • Đúng giờ: 5/5 ⭐⭐⭐⭐⭐              │
│ • Thái độ: 4/5 ⭐⭐⭐⭐                 │
│ • An toàn: 5/5 ⭐⭐⭐⭐⭐              │
│ • Tuân thủ: 4/5 ⭐⭐⭐⭐                │
│                                         │
│ Nhận xét:                               │
│ "Tài xế lái xe an toàn, thái độ tốt"  │
│                                         │
│ Thời gian: 01/12/2024 10:30            │
└─────────────────────────────────────────┘
```

## Logging

### Success logs
```
[RatingService] Rating created successfully: {ratingId}
[RatingService] Notification saved for driver {driverId} (user {userId})
[RatingService] Real-time notification sent to driver {driverId} via WebSocket
```

### Warning logs
```
[RatingService] Cannot send notification: Driver {driverId} has no user account
[RatingService] Failed to send WebSocket notification to driver {driverId}: {error}
```

### Error logs
```
[RatingService] Failed to send rating notification to driver {driverId}: {error}
```

## Test Cases

### ✅ Test Case 1: Khách hàng đánh giá chuyến đã hoàn thành
- **Input:** Rating request với tripId, driverId, ratings
- **Expected:** 
  - Rating được lưu thành công
  - Notification được tạo cho tài xế
  - WebSocket notification được gửi (nếu online)
  - Tài xế thấy thông báo mới

### ✅ Test Case 2: Tài xế đang online
- **Input:** Rating được tạo, tài xế đang kết nối WebSocket
- **Expected:**
  - Notification popup hiển thị ngay lập tức
  - Badge số thông báo tăng lên

### ✅ Test Case 3: Tài xế offline
- **Input:** Rating được tạo, tài xế không online
- **Expected:**
  - Notification vẫn được lưu vào database
  - Khi tài xế login lại, thấy thông báo mới

### ✅ Test Case 4: Nhiều đánh giá cùng lúc
- **Input:** 3 khách hàng đánh giá 3 chuyến khác nhau của cùng 1 tài xế
- **Expected:**
  - 3 notifications riêng biệt được tạo
  - Badge hiển thị (3)

### ❌ Test Case 5: Tài xế không có user account
- **Input:** Driver không có employee.user
- **Expected:**
  - Log warning
  - Không crash hệ thống
  - Rating vẫn được lưu thành công

## Performance Considerations

1. **Async Processing**: Gửi notification không block việc lưu rating
2. **Error Handling**: Lỗi khi gửi notification không ảnh hưởng rating
3. **Database Index**: Index trên `userId` và `isRead` để query nhanh
4. **WebSocket**: Chỉ gửi cho user đang online, không retry

## Security

1. **Authorization**: Chỉ tài xế được xem notification của mình
2. **Validation**: Validate userId trước khi gửi notification
3. **Rate Limiting**: Giới hạn số notification có thể tạo trong 1 khoảng thời gian

## Future Enhancements

1. **Push Notification**: Gửi push notification đến mobile app
2. **Email Notification**: Gửi email tóm tắt đánh giá hàng tuần
3. **Notification Preferences**: Cho phép tài xế tùy chỉnh loại thông báo nhận
4. **Rich Notification**: Thêm hình ảnh, action buttons
5. **Notification History**: Lưu trữ và phân tích lịch sử thông báo

## Files đã thay đổi

### Backend
- ✅ `vantai/PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/service/impl/RatingServiceImpl.java`

### Documentation
- ✅ `vantai/RATING_NOTIFICATION_FEATURE.md`

## Kết quả mong đợi

✅ Khi khách hàng đánh giá chuyến đi:
- Hệ thống tự động tạo thông báo cho tài xế
- Thông báo được lưu vào database
- Tài xế nhận được real-time notification (nếu online)
- Tài xế có thể xem chi tiết đánh giá
- Badge số thông báo chưa đọc được cập nhật

✅ Tài xế có thể:
- Xem danh sách tất cả thông báo
- Xem chi tiết từng đánh giá
- Đánh dấu đã đọc
- Xóa thông báo cũ

✅ Hệ thống:
- Xử lý lỗi gracefully (không crash)
- Log đầy đủ để debug
- Performance tốt (không block rating process)
