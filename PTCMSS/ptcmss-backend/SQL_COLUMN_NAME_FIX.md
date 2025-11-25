# SQL Column Name Fix - Vehicle Efficiency Query

## Vấn đề
Lỗi 400 Bad Request với message "bad SQL grammar" khi gọi endpoint:
```
GET /api/v1/manager/analytics/vehicle-efficiency?branchId=1&period=THIS_MONTH
```

## Root Cause
**Column name mismatch** giữa SQL query và database schema.

### SQL Query (Trước khi sửa) - camelCase
```sql
SELECT v.licensePlate, ...
FROM vehicles v
LEFT JOIN (
    SELECT tv.vehicleId, ...
    FROM trip_vehicles tv
    INNER JOIN trips t ON tv.tripId = t.tripId  -- ❌ Wrong
) trips ON v.vehicleId = trips.vehicleId  -- ❌ Wrong
WHERE v.branchId = ?  -- ❌ Wrong
```

### Database Schema - snake_case
```sql
vehicles:
  - id (not vehicleId)
  - license_plate (not licensePlate)
  - branch_id (not branchId)

trips:
  - id (not tripId)
  - start_time (not startTime)

trip_vehicles:
  - trip_id (not tripId)
  - vehicle_id (not vehicleId)

expenses:
  - vehicle_id (not vehicleId)
  - branch_id (not branchId)
  - expense_date (not expenseDate)
```

## Giải pháp

### Fixed SQL Query - snake_case
```sql
SELECT 
    v.license_plate AS licensePlate,  -- ✅ Use snake_case, alias to camelCase
    COALESCE(trips.totalKm, 0) AS totalKm,
    COALESCE(costs.totalCost, 0) AS totalCost,
    CASE
        WHEN COALESCE(trips.totalKm, 0) > 0 THEN COALESCE(costs.totalCost, 0) / COALESCE(trips.totalKm, 1)
        ELSE 0
    END AS costPerKm
FROM vehicles v
LEFT JOIN (
    SELECT 
        tv.vehicle_id AS vehicleId,  -- ✅ Fixed
        SUM(t.distance) AS totalKm
    FROM trip_vehicles tv
    INNER JOIN trips t ON tv.trip_id = t.id  -- ✅ Fixed
        AND t.status = 'COMPLETED'
        AND t.start_time BETWEEN ? AND ?  -- ✅ Fixed
    GROUP BY tv.vehicle_id  -- ✅ Fixed
) trips ON v.id = trips.vehicleId  -- ✅ Fixed
LEFT JOIN (
    SELECT 
        e.vehicle_id AS vehicleId,  -- ✅ Fixed
        SUM(e.amount) AS totalCost
    FROM expenses e
    WHERE e.vehicle_id IS NOT NULL  -- ✅ Fixed
      AND e.branch_id = ?  -- ✅ Fixed
      AND e.category IN ('FUEL', 'MAINTENANCE', 'TOLL')
      AND e.status IN ('APPROVED', 'PAID')
      AND e.expense_date BETWEEN ? AND ?  -- ✅ Fixed
    GROUP BY e.vehicle_id  -- ✅ Fixed
) costs ON v.id = costs.vehicleId  -- ✅ Fixed
WHERE v.branch_id = ?  -- ✅ Fixed
  AND v.status <> 'INACTIVE'
  AND COALESCE(trips.totalKm, 0) > 0
ORDER BY costPerKm ASC, totalKm DESC
LIMIT 10
```

## Column Mapping Table

| Entity | Java Field | Database Column | SQL Alias |
|--------|-----------|-----------------|-----------|
| Vehicle | id | id | - |
| Vehicle | licensePlate | license_plate | licensePlate |
| Vehicle | branchId | branch_id | - |
| Trip | id | id | - |
| Trip | startTime | start_time | - |
| Trip | distance | distance | - |
| TripVehicle | tripId | trip_id | - |
| TripVehicle | vehicleId | vehicle_id | vehicleId |
| Expense | vehicleId | vehicle_id | vehicleId |
| Expense | branchId | branch_id | - |
| Expense | expenseDate | expense_date | - |

## Best Practices

### 1. Always use snake_case in SQL
Database columns are snake_case, so SQL queries must use snake_case:
```sql
-- ✅ Correct
SELECT v.license_plate, v.branch_id
FROM vehicles v
WHERE v.branch_id = ?

-- ❌ Wrong
SELECT v.licensePlate, v.branchId
FROM vehicles v
WHERE v.branchId = ?
```

### 2. Use AS alias for result mapping
Alias snake_case columns to camelCase for Java mapping:
```sql
SELECT 
    v.license_plate AS licensePlate,  -- Maps to Java field
    v.branch_id AS branchId
FROM vehicles v
```

### 3. Join on actual column names
```sql
-- ✅ Correct
INNER JOIN trips t ON tv.trip_id = t.id

-- ❌ Wrong
INNER JOIN trips t ON tv.tripId = t.tripId
```

### 4. Use JPA naming strategy (Alternative)
If using JPA entities, configure naming strategy:
```java
@Entity
@Table(name = "vehicles")
public class Vehicle {
    @Id
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "license_plate")
    private String licensePlate;
    
    @Column(name = "branch_id")
    private Integer branchId;
}
```

## Testing

### Test Case 1: Query executes successfully
```bash
curl -X GET "http://localhost:8080/api/v1/manager/analytics/vehicle-efficiency?branchId=1&period=THIS_MONTH" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Expected: 200 OK with data:
```json
[
  {
    "licensePlate": "30G-123.45",
    "totalKm": 1000.0,
    "totalCost": 5000000.0,
    "costPerKm": 5000.0
  }
]
```

### Test Case 2: Empty result
If no vehicles have completed trips:
```json
[]
```

### Test Case 3: Multiple branches
```bash
curl -X GET "http://localhost:8080/api/v1/manager/analytics/vehicle-efficiency?branchId=2&period=THIS_MONTH"
```

## Related Issues

### Similar SQL errors in other queries
Check these methods for same issue:
- `getExpenseBreakdown()` - Uses `i.branchId`, `i.invoiceDate`
- `getPendingApprovals()` - Uses `ah.historyId`, `ah.branchId`
- Any other native SQL queries

### JPA vs Native SQL
- **JPA Queries:** Use Java field names (camelCase)
- **Native SQL:** Use database column names (snake_case)

```java
// JPA Query - use camelCase
@Query("SELECT v FROM Vehicle v WHERE v.branchId = :branchId")

// Native SQL - use snake_case
@Query(value = "SELECT * FROM vehicles WHERE branch_id = :branchId", nativeQuery = true)
```

## Files Changed
- `PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/service/AnalyticsService.java`
  - Fixed `getVehicleEfficiency()` SQL query
  - Changed all column names from camelCase to snake_case
  - Added AS aliases for result mapping

## Next Steps
1. ✅ Test endpoint with Postman/curl
2. ⏳ Check other native SQL queries for similar issues
3. ⏳ Consider using JPA Criteria API instead of native SQL
4. ⏳ Add integration tests for analytics endpoints
