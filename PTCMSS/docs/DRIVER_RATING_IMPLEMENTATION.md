# Driver Rating & Performance - Implementation Guide

## ✅ Đã hoàn thành

### 1. Database Schema
- ✅ File: `12_CREATE_DRIVER_RATINGS.sql`
- ✅ Bảng `DriverRatings`: Lưu đánh giá từng chuyến
- ✅ Bảng `DriverPerformanceStats`: Thống kê hiệu suất
- ✅ Trigger tự động tính `overallRating`
- ✅ View `DriverRatingSummary`: Tổng hợp 30 ngày

### 2. Backend Entity
- ✅ File: `DriverRatings.java`

## 📋 Cần implement tiếp

### Backend

#### 1. Repository
```java
// DriverRatingsRepository.java
public interface DriverRatingsRepository extends JpaRepository<DriverRatings, Integer> {
    List<DriverRatings> findByDriverIdOrderByRatedAtDesc(Integer driverId);
    Optional<DriverRatings> findByTripId(Integer tripId);
    List<DriverRatings> findByDriverIdAndRatedAtAfter(Integer driverId, Instant after);
    
    @Query("SELECT AVG(dr.overallRating) FROM DriverRatings dr WHERE dr.driver.id = :driverId AND dr.ratedAt >= :since")
    BigDecimal getAverageRatingForDriver(@Param("driverId") Integer driverId, @Param("since") Instant since);
}
```

#### 2. DTO
```java
// RatingRequest.java
@Data
public class RatingRequest {
    private Integer tripId;
    private Integer punctualityRating; // 1-5
    private Integer attitudeRating;
    private Integer safetyRating;
    private Integer complianceRating;
    private String comment;
}

// RatingResponse.java
@Data
@Builder
public class RatingResponse {
    private Integer id;
    private Integer tripId;
    private Integer driverId;
    private String driverName;
    private Integer punctualityRating;
    private Integer attitudeRating;
    private Integer safetyRating;
    private Integer complianceRating;
    private BigDecimal overallRating;
    private String comment;
    private Instant ratedAt;
}

// DriverPerformanceResponse.java
@Data
@Builder
public class DriverPerformanceResponse {
    private Integer driverId;
    private String driverName;
    private Integer totalRatings;
    private BigDecimal avgPunctuality;
    private BigDecimal avgAttitude;
    private BigDecimal avgSafety;
    private BigDecimal avgCompliance;
    private BigDecimal avgOverall;
    private List<RatingResponse> recentRatings;
}
```

#### 3. Service
```java
// RatingService.java
public interface RatingService {
    RatingResponse createRating(RatingRequest request, Integer userId);
    RatingResponse getRatingByTrip(Integer tripId);
    List<RatingResponse> getDriverRatings(Integer driverId);
    DriverPerformanceResponse getDriverPerformance(Integer driverId, Integer days);
    void updateDriverOverallRating(Integer driverId);
}
```

#### 4. Controller
```java
// RatingController.java
@RestController
@RequestMapping("/api/ratings")
public class RatingController {
    
    @PostMapping
    public ResponseData<RatingResponse> createRating(@RequestBody RatingRequest request) {
        // Validate: Trip phải COMPLETED
        // Validate: Chưa có rating cho trip này
        // Create rating
        // Update driver overall rating
    }
    
    @GetMapping("/trip/{tripId}")
    public ResponseData<RatingResponse> getRatingByTrip(@PathVariable Integer tripId) {}
    
    @GetMapping("/driver/{driverId}")
    public ResponseData<List<RatingResponse>> getDriverRatings(@PathVariable Integer driverId) {}
    
    @GetMapping("/driver/{driverId}/performance")
    public ResponseData<DriverPerformanceResponse> getDriverPerformance(
        @PathVariable Integer driverId,
        @RequestParam(defaultValue = "30") Integer days
    ) {}
}
```

### Frontend

#### 1. API Service
```javascript
// ratings.js
export function createRating(data) {
  return apiFetch('/api/ratings', { method: 'POST', body: data });
}

export function getRatingByTrip(tripId) {
  return apiFetch(`/api/ratings/trip/${tripId}`);
}

export function getDriverRatings(driverId) {
  return apiFetch(`/api/ratings/driver/${driverId}`);
}

export function getDriverPerformance(driverId, days = 30) {
  return apiFetch(`/api/ratings/driver/${driverId}/performance?days=${days}`);
}
```

#### 2. Rating Form Component
```jsx
// RatingForm.jsx
export default function RatingForm({ trip, onSubmit, onClose }) {
  const [ratings, setRatings] = useState({
    punctualityRating: 5,
    attitudeRating: 5,
    safetyRating: 5,
    complianceRating: 5,
    comment: ''
  });

  return (
    <div className="rating-form">
      <h3>Đánh giá tài xế: {trip.driverName}</h3>
      
      <StarRating 
        label="Đúng giờ" 
        value={ratings.punctualityRating}
        onChange={(v) => setRatings({...ratings, punctualityRating: v})}
      />
      
      <StarRating 
        label="Thái độ" 
        value={ratings.attitudeRating}
        onChange={(v) => setRatings({...ratings, attitudeRating: v})}
      />
      
      <StarRating 
        label="An toàn" 
        value={ratings.safetyRating}
        onChange={(v) => setRatings({...ratings, safetyRating: v})}
      />
      
      <StarRating 
        label="Tuân thủ quy trình" 
        value={ratings.complianceRating}
        onChange={(v) => setRatings({...ratings, complianceRating: v})}
      />
      
      <textarea 
        placeholder="Nhận xét (tùy chọn)"
        value={ratings.comment}
        onChange={(e) => setRatings({...ratings, comment: e.target.value})}
      />
      
      <button onClick={() => onSubmit(ratings)}>Gửi đánh giá</button>
    </div>
  );
}
```

#### 3. Driver Performance Dashboard
```jsx
// DriverPerformanceDashboard.jsx
export default function DriverPerformanceDashboard({ driverId }) {
  const [performance, setPerformance] = useState(null);
  
  useEffect(() => {
    async function load() {
      const data = await getDriverPerformance(driverId, 30);
      setPerformance(data);
    }
    load();
  }, [driverId]);
  
  return (
    <div className="driver-performance">
      <h2>{performance?.driverName}</h2>
      
      <div className="stats-grid">
        <StatCard label="Tổng đánh giá" value={performance?.totalRatings} />
        <StatCard label="Điểm TB" value={performance?.avgOverall} />
        <StatCard label="Đúng giờ" value={performance?.avgPunctuality} />
        <StatCard label="Thái độ" value={performance?.avgAttitude} />
        <StatCard label="An toàn" value={performance?.avgSafety} />
        <StatCard label="Tuân thủ" value={performance?.avgCompliance} />
      </div>
      
      <h3>Đánh giá gần đây</h3>
      <RatingList ratings={performance?.recentRatings} />
    </div>
  );
}
```

## 🔄 Workflow

### 1. Sau khi chuyến COMPLETED
```
Trip status = COMPLETED
  ↓
Hiển thị nút "Đánh giá tài xế"
  ↓
User click → Mở RatingForm
  ↓
User chọn sao (1-5) cho 4 tiêu chí + comment
  ↓
Submit → POST /api/ratings
  ↓
Backend:
  - Validate trip COMPLETED
  - Validate chưa có rating
  - Create DriverRatings
  - Trigger tự động tính overallRating
  - Update Drivers.rating (trung bình 30 ngày)
  ↓
Success → Hiển thị "Cảm ơn đánh giá"
```

### 2. Xem performance tài xế
```
Vào trang Driver Detail
  ↓
GET /api/ratings/driver/{id}/performance?days=30
  ↓
Backend:
  - Query DriverRatings trong 30 ngày
  - Tính AVG cho từng tiêu chí
  - Lấy recent ratings
  ↓
Frontend hiển thị:
  - Stats cards (điểm TB)
  - Chart xu hướng
  - List đánh giá gần đây
```

## 📊 Scheduled Job: Update Performance Stats

```java
@Scheduled(cron = "0 0 2 * * *") // 2h sáng mỗi ngày
public void updateDriverPerformanceStats() {
    List<Drivers> drivers = driverRepository.findAll();
    LocalDate today = LocalDate.now();
    
    for (Drivers driver : drivers) {
        // Calculate last 30 days
        Instant since = today.minusDays(30).atStartOfDay(ZoneId.systemDefault()).toInstant();
        
        List<DriverRatings> ratings = ratingsRepository
            .findByDriverIdAndRatedAtAfter(driver.getId(), since);
        
        if (!ratings.isEmpty()) {
            BigDecimal avgOverall = ratings.stream()
                .map(DriverRatings::getOverallRating)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(ratings.size()), 2, RoundingMode.HALF_UP);
            
            // Update driver overall rating
            driver.setRating(avgOverall);
            driverRepository.save(driver);
        }
    }
}
```

## 🎨 UI Components

### StarRating Component
```jsx
function StarRating({ label, value, onChange, readonly = false }) {
  return (
    <div className="star-rating">
      <label>{label}</label>
      <div className="stars">
        {[1, 2, 3, 4, 5].map(star => (
          <Star
            key={star}
            filled={star <= value}
            onClick={() => !readonly && onChange(star)}
          />
        ))}
      </div>
      <span className="rating-value">{value}/5</span>
    </div>
  );
}
```

## 🧪 Testing

### Test Data
```sql
-- Insert test ratings
INSERT INTO DriverRatings (tripId, driverId, customerId, punctualityRating, attitudeRating, safetyRating, complianceRating, comment, ratedBy)
VALUES 
(1, 1, 1, 5, 5, 4, 5, 'Tài xế rất tốt', 1),
(2, 1, 1, 4, 5, 5, 4, 'Lái xe an toàn', 1),
(3, 2, 2, 3, 4, 4, 3, 'Bình thường', 2);

-- Check average
SELECT * FROM DriverRatingSummary;
```

## 📝 Next Steps

1. ✅ Chạy migration: `12_CREATE_DRIVER_RATINGS.sql`
2. ⏳ Tạo Repository, Service, Controller
3. ⏳ Tạo Frontend components
4. ⏳ Integrate vào Trip detail page
5. ⏳ Tạo Driver performance dashboard
6. ⏳ Add scheduled job update stats

## 🔗 Integration Points

- **Trip Detail Page**: Thêm nút "Đánh giá" khi status = COMPLETED
- **Driver List**: Hiển thị rating stars
- **Driver Detail**: Tab "Performance" với stats 30 ngày
- **Dashboard**: Widget "Top Rated Drivers"
