# 📊 MODULE 5 - ENTITY RELATIONSHIP DIAGRAM

## 🗺️ Sơ đồ quan hệ các bảng mới

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         MODULE 5 - DISPATCH MANAGEMENT                   │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│     Trips        │
│ ──────────────── │
│ PK: tripId       │◄─────────┐
│     bookingId    │          │
│     startTime    │          │
│     endTime      │          │
│     status       │          │
└──────────────────┘          │
         △                    │
         │                    │
         │ FK                 │ FK
         │                    │
┌────────┴──────────────┐     │
│                       │     │
│  ┌────────────────────┴─────┴──────────┐
│  │  TripAssignmentHistory               │
│  │  ─────────────────────────────────   │
│  │  PK: historyId                       │
│  │  FK: tripId ──────────────────────┐  │
│  │  FK: driverId                     │  │
│  │  FK: vehicleId                    │  │
│  │  FK: previousDriverId             │  │
│  │  FK: previousVehicleId            │  │
│  │  FK: performedBy                  │  │
│  │      action (ASSIGN/REASSIGN...)  │  │
│  │      reason                       │  │
│  │      createdAt                    │  │
│  └───────────────────────────────────┘  │
│                                          │
│  ┌──────────────────────────────────────┤
│  │  TripRatings                         │
│  │  ──────────────────────────────────  │
│  │  PK: ratingId                        │
│  │  FK: tripId ──────────────────────┐  │
│  │  FK: driverId                     │  │
│  │  FK: ratedBy                      │  │
│  │      rating (1-5)                 │  │
│  │      comment                      │  │
│  │      ratedAt                      │  │
│  │  UK: (tripId, driverId)           │  │
│  └───────────────────────────────────┘  │
│                                          │
│  ┌──────────────────────────────────────┤
│  │  TripIncidents                       │
│  │  ──────────────────────────────────  │
│  │  PK: incidentId                      │
│  │  FK: tripId ──────────────────────┐  │
│  │  FK: driverId                     │  │
│  │  FK: resolvedBy                   │  │
│  │      incidentType                 │  │
│  │      description                  │  │
│  │      severity (LOW/MEDIUM/HIGH)   │  │
│  │      status (REPORTED/RESOLVED)   │  │
│  │      reportedAt                   │  │
│  └───────────────────────────────────┘  │
│                                          │
└──────────────────────────────────────────┘

┌──────────────────┐
│    Drivers       │
│ ──────────────── │
│ PK: driverId     │◄─────────┐
│     employeeId   │          │
│     branchId     │          │
│     rating       │          │ FK (all 4 tables)
│ ►►  averageRating│ (NEW)    │
│ ►►  totalRatings │ (NEW)    │
│     status       │          │
└──────────────────┘          │
         △                    │
         │                    │
         │ FK                 │
         │                    │
┌────────┴────────────────────┴──────────┐
│  DriverWorkload                        │
│  ────────────────────────────────────  │
│  PK: workloadId                        │
│  FK: driverId                          │
│      date                              │
│      totalMinutes                      │
│      tripCount                         │
│      fairnessScore                     │
│      lastUpdated                       │
│  UK: (driverId, date)                  │
└────────────────────────────────────────┘

┌──────────────────┐
│   Vehicles       │
│ ──────────────── │
│ PK: vehicleId    │◄───── FK (TripAssignmentHistory)
│     licensePlate │
│     status       │
└──────────────────┘

┌──────────────────┐
│   Employees      │
│ ──────────────── │
│ PK: employeeId   │◄───── FK (performedBy, ratedBy, resolvedBy)
│     userId       │
│     branchId     │
└──────────────────┘
```

---

## 🔗 Mối quan hệ chi tiết

### 1. **TripAssignmentHistory** (1:N với Trips)
```
Trips (1) ──────► (N) TripAssignmentHistory
  - Mỗi Trip có nhiều lần phân công (assign, reassign, unassign)
  - Audit trail đầy đủ

Foreign Keys:
  - tripId → Trips.tripId
  - driverId → Drivers.driverId
  - vehicleId → Vehicles.vehicleId
  - previousDriverId → Drivers.driverId
  - previousVehicleId → Vehicles.vehicleId
  - performedBy → Employees.employeeId
```

### 2. **TripRatings** (1:N với Trips, 1:N với Drivers)
```
Trips (1) ──────► (N) TripRatings
Drivers (1) ─────► (N) TripRatings
  - Mỗi Trip có thể có nhiều ratings (từ nhiều người đánh giá)
  - Mỗi Driver có nhiều ratings từ các trips khác nhau
  - UNIQUE constraint: (tripId, driverId) - mỗi driver chỉ được rate 1 lần/trip

Foreign Keys:
  - tripId → Trips.tripId
  - driverId → Drivers.driverId
  - ratedBy → Employees.employeeId
```

### 3. **DriverWorkload** (1:N với Drivers)
```
Drivers (1) ─────► (N) DriverWorkload
  - Mỗi Driver có nhiều records workload (mỗi ngày 1 record)
  - UNIQUE constraint: (driverId, date) - mỗi driver chỉ có 1 record/ngày

Foreign Keys:
  - driverId → Drivers.driverId
```

### 4. **TripIncidents** (1:N với Trips, 1:N với Drivers)
```
Trips (1) ──────► (N) TripIncidents
Drivers (1) ─────► (N) TripIncidents
  - Mỗi Trip có thể có nhiều incidents
  - Mỗi Driver có thể có nhiều incidents từ các trips khác nhau

Foreign Keys:
  - tripId → Trips.tripId
  - driverId → Drivers.driverId
  - resolvedBy → Employees.employeeId
```

---

## 📈 Data Flow - Quy trình hoạt động

### 🔄 Quy trình phân công (Assignment Flow)

```
1. Tạo Trip mới
   └─► Trips table

2. Phân công tài xế & xe
   ├─► TripDrivers table (existing)
   ├─► TripVehicles table (existing)
   └─► TripAssignmentHistory (NEW - log action: ASSIGN)

3. Nếu cần thay đổi phân công
   ├─► Update TripDrivers/TripVehicles
   └─► TripAssignmentHistory (NEW - log action: REASSIGN)
       ├─ previousDriverId
       ├─ previousVehicleId
       └─ reason

4. Hoàn thành chuyến đi
   └─► Update Trip.status = 'COMPLETED'

5. Đánh giá tài xế
   ├─► TripRatings (NEW - insert rating)
   └─► Update Drivers.averageRating, totalRatings

6. Cập nhật workload
   └─► DriverWorkload (NEW - daily job)
       ├─ totalMinutes
       ├─ tripCount
       └─ fairnessScore
```

### 🚨 Quy trình báo cáo sự cố (Incident Flow)

```
1. Sự cố xảy ra trong chuyến đi
   └─► TripIncidents (NEW)
       ├─ status: REPORTED
       ├─ severity: LOW/MEDIUM/HIGH/CRITICAL
       └─ description

2. Điều tra sự cố
   └─► Update TripIncidents.status = 'INVESTIGATING'

3. Xử lý xong
   └─► Update TripIncidents
       ├─ status = 'RESOLVED'
       ├─ resolvedBy
       └─ resolvedAt

4. Đóng case
   └─► Update TripIncidents.status = 'CLOSED'
```

---

## 🎯 Indexes Strategy

### Performance Optimization

```sql
-- TripAssignmentHistory
IX_TripAssignmentHistory_TripId      -- Query by trip
IX_TripAssignmentHistory_CreatedAt   -- Timeline queries
IX_TripAssignmentHistory_DriverId    -- Query by driver

-- TripRatings
IX_TripRatings_DriverId              -- Query ratings by driver
IX_TripRatings_RatedAt               -- Recent ratings

-- DriverWorkload
IX_DriverWorkload_Date               -- Query by date range
IX_DriverWorkload_Score              -- Sort by fairness score
UK_DriverWorkload_Date               -- Unique (driverId, date)

-- TripIncidents
IX_TripIncidents_TripId              -- Query by trip
IX_TripIncidents_DriverId            -- Query by driver
IX_TripIncidents_Status              -- Filter by status
IX_TripIncidents_Severity            -- Filter by severity
```

---

## 📊 Views Summary

### v_DriverRatingsSummary
```sql
Purpose: Tổng hợp rating của tài xế
Columns:
  - driverId
  - averageRating (cached)
  - totalRatings (cached)
  - calculatedAverageRating (real-time)
  - rating30Days (last 30 days)
  - ratings30Days (count last 30 days)

Use case: Dashboard, Driver performance report
```

### v_DriverWorkloadSummary
```sql
Purpose: Tổng hợp workload 7 ngày gần nhất
Columns:
  - driverId, driverName, branchId, branchName
  - totalMinutesLast7Days
  - totalTripsLast7Days
  - avgFairnessScore

Use case: Auto-dispatch algorithm, Workload balancing
```

---

## 🔐 Constraints Summary

### Primary Keys
- TripAssignmentHistory: historyId
- TripRatings: ratingId
- DriverWorkload: workloadId
- TripIncidents: incidentId

### Unique Constraints
- TripRatings: (tripId, driverId)
- DriverWorkload: (driverId, date)

### Foreign Keys
- All tables có FK đến Trips, Drivers
- TripAssignmentHistory có FK đến Vehicles, Employees
- TripRatings, TripIncidents có FK đến Employees (ratedBy, resolvedBy)

### Check Constraints
- TripRatings.rating: BETWEEN 1 AND 5
- TripIncidents.severity: ENUM('LOW','MEDIUM','HIGH','CRITICAL')
- TripIncidents.status: ENUM('REPORTED','INVESTIGATING','RESOLVED','CLOSED')

---

## 💡 Best Practices

### 1. Luôn log assignment changes
```java
// Mỗi khi assign/reassign driver hoặc vehicle
logAssignmentHistory(trip, driver, vehicle, action, reason, performedBy);
```

### 2. Update rating cache sau khi insert TripRatings
```java
// Trigger hoặc Service method
updateDriverAverageRating(driverId);
```

### 3. Scheduled job cập nhật workload
```java
@Scheduled(cron = "0 0 0 * * *") // Daily at 00:00
calculateDailyWorkload(yesterday);
```

### 4. Validate incident severity
```java
// Critical incidents cần notify ngay
if (incident.getSeverity() == Severity.CRITICAL) {
    notifyManagement(incident);
}
```

---

**Diagram này giúp hiểu rõ cấu trúc và mối quan hệ giữa các bảng Module 5! 📊**
