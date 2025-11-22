# WebSocket Real-time Notifications - Hướng dẫn sử dụng

## Tổng quan

Hệ thống WebSocket đã được triển khai đầy đủ từ backend (Spring Boot) đến frontend (React) để hỗ trợ thông báo real-time.

## Kiến trúc

### Backend (Spring Boot)

1. **WebSocketConfig.java** (`d:\Project\vantai\PTCMSS\ptcmss-backend\src\main\java\org\example\ptcmssbackend\config\WebSocketConfig.java`)
   - Cấu hình STOMP message broker
   - Endpoint: `/ws`
   - Destination prefixes: `/app`, `/topic`, `/queue`

2. **WebSocketNotificationService.java** (`d:\Project\vantai\PTCMSS\ptcmss-backend\src\main\java\org\example\ptcmssbackend\service\WebSocketNotificationService.java`)
   - `sendGlobalNotification()` - Gửi thông báo tới tất cả clients
   - `sendUserNotification()` - Gửi thông báo tới user cụ thể
   - `sendBookingUpdate()` - Gửi cập nhật đơn hàng
   - `sendPaymentUpdate()` - Gửi cập nhật thanh toán
   - `sendDispatchUpdate()` - Gửi cập nhật điều phối

3. **NotificationController.java** (`d:\Project\vantai\PTCMSS\ptcmss-backend\src\main\java\org\example\ptcmssbackend\controller\NotificationController.java`)
   - `POST /api/notifications/test-websocket` - Test endpoint để gửi notification thử nghiệm

### Frontend (React)

1. **WebSocketContext.jsx** (`d:\Project\vantai\PTCMSS_FRONTEND\src\contexts\WebSocketContext.jsx`)
   - Provider quản lý kết nối WebSocket
   - Tự động subscribe các topics: `/topic/notifications`, `/topic/bookings`, `/topic/payments`, `/topic/dispatches`
   - Quản lý danh sách notifications

2. **useNotifications.js** (`d:\Project\vantai\PTCMSS_FRONTEND\src\hooks\useNotifications.js`)
   - Custom hook để sử dụng WebSocket notifications
   - Cung cấp các hàm: `markAsRead()`, `clearNotification()`, `getNotificationsByType()`, etc.

3. **NotificationsWidget.jsx** (`d:\Project\vantai\PTCMSS_FRONTEND\src\components\module 5\NotificationsWidget.jsx`)
   - Widget hiển thị notifications real-time
   - Tự động refresh khi nhận WebSocket notification
   - Hiển thị trạng thái kết nối WebSocket (Live/Offline)

## Cách sử dụng

### 1. Gửi notification từ Backend

#### A. Sử dụng WebSocketNotificationService trong code

```java
@Autowired
private WebSocketNotificationService webSocketNotificationService;

// Gửi global notification
webSocketNotificationService.sendGlobalNotification(
    "Đơn hàng mới",
    "Có 1 đơn hàng mới cần xử lý",
    "INFO"
);

// Gửi notification cho user cụ thể
webSocketNotificationService.sendUserNotification(
    userId,
    "Thanh toán thành công",
    "Đơn hàng #123 đã được thanh toán",
    "SUCCESS"
);

// Gửi booking update
webSocketNotificationService.sendBookingUpdate(
    bookingId,
    "CONFIRMED",
    "Đơn hàng đã được xác nhận"
);

// Gửi payment update
webSocketNotificationService.sendPaymentUpdate(
    invoiceId,
    bookingId,
    "PAID",
    "Thanh toán đã hoàn tất"
);

// Gửi dispatch update
webSocketNotificationService.sendDispatchUpdate(
    dispatchId,
    "ASSIGNED",
    "Đã gán tài xế cho chuyến đi"
);
```

#### B. Test bằng API endpoint

```bash
# Test global notification
curl -X POST http://localhost:8080/api/notifications/test-websocket \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Test Notification",
    "message": "This is a test",
    "type": "INFO"
  }'

# Test user-specific notification
curl -X POST http://localhost:8080/api/notifications/test-websocket \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Test User Notification",
    "message": "Message for user 123",
    "type": "SUCCESS",
    "userId": 123
  }'
```

### 2. Sử dụng trong Frontend

#### A. Sử dụng hook trong component

```javascript
import { useNotifications } from '../../hooks/useNotifications';

function MyComponent() {
  const {
    connected,           // WebSocket connection status
    notifications,       // Array of all notifications
    unreadCount,         // Count of unread notifications
    markAsRead,          // Mark notification as read
    clearNotification,   // Remove notification
    getNotificationsByType  // Filter by type
  } = useNotifications();

  return (
    <div>
      <div>Connection: {connected ? 'Connected' : 'Disconnected'}</div>
      <div>Unread: {unreadCount}</div>

      {notifications.map(notif => (
        <div key={notif.id}>
          <h3>{notif.title}</h3>
          <p>{notif.message}</p>
          <button onClick={() => markAsRead(notif.id)}>Mark Read</button>
        </div>
      ))}
    </div>
  );
}
```

#### B. Subscribe to user-specific notifications

```javascript
import { useWebSocket } from '../contexts/WebSocketContext';
import { useEffect } from 'react';

function UserNotifications({ userId }) {
  const { subscribeToUserNotifications } = useWebSocket();

  useEffect(() => {
    if (userId) {
      const subscription = subscribeToUserNotifications(userId);
      return () => subscription?.unsubscribe();
    }
  }, [userId, subscribeToUserNotifications]);

  // Notifications will automatically appear in the notifications array
}
```

## Topics

### 1. `/topic/notifications` (Global)
Tất cả clients đều nhận được. Format:
```json
{
  "id": 1234567890,
  "title": "Notification Title",
  "message": "Notification message",
  "type": "INFO|SUCCESS|WARNING|ERROR",
  "timestamp": "2025-01-22T10:30:00Z",
  "read": false
}
```

### 2. `/topic/notifications/{userId}` (User-specific)
Chỉ user cụ thể nhận được. Format giống global.

### 3. `/topic/bookings` (Booking updates)
```json
{
  "type": "BOOKING_UPDATE",
  "bookingId": 123,
  "status": "CONFIRMED|CANCELLED|COMPLETED",
  "message": "Status update message",
  "timestamp": "2025-01-22T10:30:00Z"
}
```

### 4. `/topic/payments` (Payment updates)
```json
{
  "type": "PAYMENT_UPDATE",
  "invoiceId": 456,
  "bookingId": 123,
  "status": "PAID|UNPAID|PENDING",
  "message": "Payment status message",
  "timestamp": "2025-01-22T10:30:00Z"
}
```

### 5. `/topic/dispatches` (Dispatch updates)
```json
{
  "type": "DISPATCH_UPDATE",
  "dispatchId": 789,
  "status": "ASSIGNED|IN_PROGRESS|COMPLETED",
  "message": "Dispatch update message",
  "timestamp": "2025-01-22T10:30:00Z"
}
```

## Notification Types

- `INFO` - Thông tin chung
- `SUCCESS` - Thao tác thành công
- `WARNING` - Cảnh báo
- `ERROR` - Lỗi
- `BOOKING_UPDATE` - Cập nhật đơn hàng
- `PAYMENT_UPDATE` - Cập nhật thanh toán
- `DISPATCH_UPDATE` - Cập nhật điều phối
- `ALERT` - Cảnh báo hệ thống
- `APPROVAL_REQUEST` - Yêu cầu phê duyệt

## Testing

### 1. Khởi động Backend
```bash
cd d:\Project\vantai\PTCMSS\ptcmss-backend
mvn spring-boot:run
```

### 2. Khởi động Frontend
```bash
cd d:\Project\vantai\PTCMSS_FRONTEND
npm run dev
```

### 3. Kiểm tra kết nối
- Mở browser console
- Vào trang có NotificationsWidget (ví dụ: `/dispatch/notifications`)
- Xem log `[WebSocket] Connected`
- Kiểm tra indicator "Live" màu xanh ở góc phải widget

### 4. Test gửi notification
Sử dụng Postman hoặc curl gửi request tới `/api/notifications/test-websocket`

### 5. Verify notification hiển thị
- Notification sẽ xuất hiện trong NotificationsWidget
- Unread count sẽ tăng lên
- Widget sẽ tự động refresh data

## Auto-refresh Behavior

NotificationsWidget tự động refresh khi nhận các loại notification:
- `BOOKING_UPDATE` - Làm mới dashboard
- `PAYMENT_UPDATE` - Làm mới dashboard
- `DISPATCH_UPDATE` - Làm mới dashboard
- `ALERT` - Làm mới alerts
- `APPROVAL_REQUEST` - Làm mới approvals

## ✅ Tích hợp hoàn tất vào các modules

### ✅ Module 4: Booking & Payment (ĐÃ TÍCH HỢP)

**BookingServiceImpl.java** - Đã tích hợp WebSocket notifications:

1. **Tạo đơn hàng mới** (`create()`):
```java
// Gửi global notification
webSocketNotificationService.sendGlobalNotification(
    "Đơn hàng mới",
    String.format("Đơn %s - %s (%.0f km)", bookingCode, customerName, distance),
    "INFO"
);

// Gửi booking update
webSocketNotificationService.sendBookingUpdate(
    booking.getId(),
    "CREATED",
    String.format("Đơn hàng %s đã được tạo thành công", bookingCode)
);
```

2. **Cập nhật đơn hàng** (`update()`):
```java
// Phát hiện thay đổi status
if (oldStatus != newStatus) {
    webSocketNotificationService.sendGlobalNotification(
        "Cập nhật trạng thái đơn hàng",
        String.format("Đơn %s - %s: %s → %s", bookingCode, customerName, oldStatus, newStatus),
        "INFO"
    );
}
```

3. **Hủy đơn hàng** (`delete()`):
```java
webSocketNotificationService.sendGlobalNotification(
    "Đơn hàng bị hủy",
    String.format("Đơn %s - %s đã bị hủy", bookingCode, customerName),
    "WARNING"
);
```

**PaymentServiceImpl.java** - Đã tích hợp WebSocket notifications:

1. **Tạo mã QR thanh toán** (`generateQRCode()`):
```java
webSocketNotificationService.sendGlobalNotification(
    "QR thanh toán mới",
    String.format("Đã tạo mã QR thanh toán %s cho đơn #%d - %s",
        deposit ? "cọc" : "", bookingId, customerName),
    "INFO"
);
```

2. **Ghi nhận thanh toán** (`createDeposit()`):
```java
// Global notification
webSocketNotificationService.sendGlobalNotification(
    paymentType + " thành công",
    String.format("%s %s cho đơn %s - %s", paymentType, formatAmount, bookingCode, customerName),
    "SUCCESS"
);

// Payment update
webSocketNotificationService.sendPaymentUpdate(
    invoiceId, bookingId, "PAID",
    String.format("%s đã được ghi nhận", paymentType)
);

// Booking update
webSocketNotificationService.sendBookingUpdate(
    bookingId, "PAYMENT_RECEIVED",
    String.format("Đã nhận %s %s", paymentType.toLowerCase(), formatAmount)
);
```

### ✅ Module 5: Dispatch & Schedule (ĐÃ TÍCH HỢP)

**DispatchServiceImpl.java** - Đã tích hợp WebSocket notifications:

1. **Gán tài xế và xe** (`assign()`):
```java
// Global notification
webSocketNotificationService.sendGlobalNotification(
    "Đã gán chuyến",
    String.format("Đơn %s - %s - TX: %s - Xe: %s",
        bookingCode, customerName, driverName, vehiclePlate),
    "SUCCESS"
);

// Dispatch update
webSocketNotificationService.sendDispatchUpdate(
    booking.getId(), "ASSIGNED",
    String.format("Đã gán %d chuyến - TX: %s - Xe: %s", tripCount, driverName, vehiclePlate)
);

// User-specific notification to driver
if (driverId != null) {
    webSocketNotificationService.sendUserNotification(
        userId,
        "Chuyến mới được gán",
        String.format("Bạn được gán %d chuyến cho đơn %s", tripCount, bookingCode),
        "INFO"
    );
}
```

2. **Hủy gán chuyến** (`unassign()`):
```java
webSocketNotificationService.sendGlobalNotification(
    "Đã hủy gán chuyến",
    String.format("Chuyến #%d (Đơn %s - %s) đã được hủy gán", tripId, bookingCode, customerName),
    "WARNING"
);

webSocketNotificationService.sendDispatchUpdate(
    booking.getId(), "UNASSIGNED",
    String.format("Đã hủy gán chuyến #%d", tripId)
);
```

## Troubleshooting

### Không kết nối được WebSocket
1. Kiểm tra backend đang chạy ở port 8080
2. Kiểm tra URL trong WebSocketContext.jsx: `http://localhost:8080/ws`
3. Xem browser console có lỗi CORS không
4. Kiểm tra firewall/antivirus

### Notification không hiển thị
1. Kiểm tra WebSocket connected (indicator "Live" màu xanh)
2. Xem browser console log `[WebSocket] Received notification:`
3. Kiểm tra topic subscribe đúng chưa
4. Verify notification format

### Auto-refresh không hoạt động
1. Kiểm tra notification type có trong danh sách auto-refresh
2. Xem console log `[NotificationsWidget] Auto-refreshing`
3. Verify fetchAll() function được gọi

## Dependencies

### Backend (pom.xml)
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
```

### Frontend (package.json)
```json
{
  "sockjs-client": "^1.6.1",
  "@stomp/stompjs": "^7.0.0"
}
```

## Files Created/Modified

### Backend
- ✅ `WebSocketConfig.java` - WebSocket configuration
- ✅ `WebSocketNotificationService.java` - Notification service
- ✅ `NotificationController.java` - Test endpoint added
- ✅ `pom.xml` - WebSocket dependency added

### Frontend
- ✅ `WebSocketContext.jsx` - WebSocket context provider
- ✅ `useNotifications.js` - Custom hook
- ✅ `NotificationsWidget.jsx` - Real-time widget
- ✅ `AppLayout.jsx` - Provider wrapped
- ✅ `package.json` - WebSocket packages installed

## 🎨 Frontend Components

### NotificationToast Component

**File**: `d:\Project\vantai\PTCMSS_FRONTEND\src\components\common\NotificationToast.jsx`

Toast notification component tự động hiển thị WebSocket notifications:

**Features**:
- ✅ Auto-dismiss sau 5 giây
- ✅ Progress bar countdown
- ✅ Smooth animations (slide-in/slide-out)
- ✅ Color-coded by notification type
- ✅ Icon cho từng loại notification
- ✅ Manual dismiss button
- ✅ Max 3 toasts đồng thời

**Usage**:
```jsx
// Đã được thêm vào AppLayout.jsx
import NotificationToast from "./components/common/NotificationToast";

export default function AppLayout() {
  return (
    <WebSocketProvider>
      <NotificationToast />
      {/* ... */}
    </WebSocketProvider>
  );
}
```

Toast sẽ tự động hiển thị khi có notification mới từ WebSocket!

### NotificationsWidget Component

**File**: `d:\Project\vantai\PTCMSS_FRONTEND\src\components\module 5\NotificationsWidget.jsx`

Widget hiển thị dashboard notifications với:
- ✅ WebSocket connection status (Live/Offline)
- ✅ Unread count badge
- ✅ Auto-refresh khi nhận notification
- ✅ Real-time alerts và approvals

## 🎯 Integration Summary

### ✅ Backend Integrations (HOÀN TẤT)

| Service | Notifications | Status |
|---------|---------------|--------|
| **PaymentService** | QR generation, Payment received | ✅ |
| **BookingService** | Create, Update, Cancel | ✅ |
| **DispatchService** | Assign, Unassign, Driver notifications | ✅ |

### ✅ Frontend Components (HOÀN TẤT)

| Component | Purpose | Status |
|-----------|---------|--------|
| **WebSocketContext** | WebSocket connection management | ✅ |
| **useNotifications** | Custom hook for notifications | ✅ |
| **NotificationToast** | Toast popup notifications | ✅ |
| **NotificationsWidget** | Dashboard widget | ✅ |

## 📊 Real-time Events

Hệ thống hiện đã gửi real-time notifications cho các sự kiện sau:

### 📦 Booking Events
- ✅ Tạo đơn hàng mới
- ✅ Cập nhật đơn hàng
- ✅ Thay đổi trạng thái đơn hàng
- ✅ Hủy đơn hàng

### 💰 Payment Events
- ✅ Tạo mã QR thanh toán
- ✅ Ghi nhận thanh toán (cọc/full)
- ✅ Cập nhật trạng thái thanh toán

### 🚗 Dispatch Events
- ✅ Gán tài xế và xe cho chuyến
- ✅ Hủy gán chuyến
- ✅ Thông báo cá nhân cho tài xế

## 🔔 Notification Types & Colors

| Type | Color | Icon | Usage |
|------|-------|------|-------|
| INFO | Sky Blue | Info | General information |
| SUCCESS | Emerald Green | CheckCircle | Successful operations |
| WARNING | Amber Yellow | AlertTriangle | Warnings, cancellations |
| ERROR | Red | AlertCircle | Errors |
| BOOKING_UPDATE | Blue | Info | Booking changes |
| PAYMENT_UPDATE | Emerald | CheckCircle | Payment updates |
| DISPATCH_UPDATE | Purple | Info | Dispatch changes |

## 🎬 Demo Scenarios

### Scenario 1: Tạo đơn hàng mới
1. User tạo đơn hàng mới
2. Backend gửi notification
3. Toast hiển thị: "Đơn hàng mới - Đơn ORD-123 - Nguyễn Văn A (50 km)"
4. NotificationsWidget auto-refresh
5. Toast tự động dismiss sau 5s

### Scenario 2: Thanh toán
1. Accountant ghi nhận thanh toán
2. Backend gửi 3 notifications (global, payment update, booking update)
3. Toast hiển thị: "Thanh toán thành công - 500.000đ cho đơn ORD-123"
4. Tất cả clients nhận update
5. Dashboard refresh automatically

### Scenario 3: Gán tài xế
1. Coordinator gán tài xế cho chuyến
2. Backend gửi global notification + user notification
3. Toast hiển thị cho coordinator: "Đã gán chuyến - TX: Nguyễn Văn B - Xe: 29A-12345"
4. Driver nhận notification riêng: "Chuyến mới được gán - Bạn được gán 2 chuyến cho đơn ORD-123"
5. Dispatch board auto-refresh

## 🚀 Next Steps (Optional Enhancements)

1. **Browser Notifications**:
   - Request notification permission
   - Send browser push notifications

2. **Notification Persistence**:
   - Save notifications to database
   - Mark as read/unread
   - Notification history page

3. **Sound Alerts**:
   - Play sound on important notifications
   - User preference for sound on/off

4. **Advanced Filtering**:
   - Filter notifications by type
   - Search in notification history
   - Group notifications by booking

5. **Monitoring Dashboard**:
   - WebSocket connection health
   - Notification delivery metrics
   - Active connections count

---

**Hoàn thành**: 2025-01-22
**Version**: 2.0.0 - Full Integration
**Status**: ✅ PRODUCTION READY
