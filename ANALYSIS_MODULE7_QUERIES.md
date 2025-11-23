# MODULE 7: ANALYTICS QUERIES DESIGN

## 1. ADMIN DASHBOARD QUERIES

### KPI Metrics
```sql
-- Total Revenue (All branches)
SELECT
    COALESCE(SUM(amount), 0) as totalRevenue,
    COALESCE(SUM(CASE WHEN paymentStatus = 'PAID' THEN amount ELSE 0 END), 0) as paidRevenue,
    COALESCE(SUM(CASE WHEN paymentStatus = 'UNPAID' THEN amount ELSE 0 END), 0) as unpaidRevenue
FROM invoices
WHERE type = 'INCOME'
    AND status = 'ACTIVE'
    AND invoiceDate BETWEEN :startDate AND :endDate;

-- Total Expenses (All branches)
SELECT
    COALESCE(SUM(amount), 0) as totalExpense,
    COALESCE(SUM(CASE WHEN paymentStatus = 'PAID' THEN amount ELSE 0 END), 0) as paidExpense
FROM invoices
WHERE type = 'EXPENSE'
    AND status = 'ACTIVE'
    AND invoiceDate BETWEEN :startDate AND :endDate;

-- Fleet Utilization
SELECT
    COUNT(DISTINCT CASE WHEN v.status = 'INUSE' THEN v.vehicleId END) as inUse,
    COUNT(DISTINCT CASE WHEN v.status = 'AVAILABLE' THEN v.vehicleId END) as available,
    COUNT(DISTINCT v.vehicleId) as total,
    ROUND((COUNT(DISTINCT CASE WHEN v.status = 'INUSE' THEN v.vehicleId END) * 100.0 /
           NULLIF(COUNT(DISTINCT v.vehicleId), 0)), 2) as utilizationRate
FROM vehicles v
WHERE v.status IN ('AVAILABLE', 'INUSE');

-- Total Trips
SELECT
    COUNT(*) as totalTrips,
    COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completedTrips,
    COUNT(CASE WHEN status = 'ONGOING' THEN 1 END) as ongoingTrips,
    COUNT(CASE WHEN status = 'SCHEDULED' THEN 1 END) as scheduledTrips
FROM trips
WHERE startTime BETWEEN :startDate AND :endDate;
```

### Revenue & Expense Trend (12 months)
```sql
SELECT
    DATE_FORMAT(invoiceDate, '%Y-%m') as month,
    SUM(CASE WHEN type = 'INCOME' THEN amount ELSE 0 END) as revenue,
    SUM(CASE WHEN type = 'EXPENSE' THEN amount ELSE 0 END) as expense,
    SUM(CASE WHEN type = 'INCOME' THEN amount ELSE 0 END) -
    SUM(CASE WHEN type = 'EXPENSE' THEN amount ELSE 0 END) as netProfit
FROM invoices
WHERE status = 'ACTIVE'
    AND invoiceDate >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(invoiceDate, '%Y-%m')
ORDER BY month;
```

### Branch Performance Comparison
```sql
SELECT
    b.branchId,
    b.branchName,
    b.location,
    COALESCE(SUM(CASE WHEN i.type = 'INCOME' THEN i.amount ELSE 0 END), 0) as revenue,
    COALESCE(SUM(CASE WHEN i.type = 'EXPENSE' THEN i.amount ELSE 0 END), 0) as expense,
    COALESCE(SUM(CASE WHEN i.type = 'INCOME' THEN i.amount ELSE 0 END), 0) -
    COALESCE(SUM(CASE WHEN i.type = 'EXPENSE' THEN i.amount ELSE 0 END), 0) as netProfit,
    COUNT(DISTINCT bk.bookingId) as totalBookings,
    COUNT(DISTINCT t.tripId) as totalTrips,
    COUNT(DISTINCT v.vehicleId) as totalVehicles,
    COUNT(DISTINCT CASE WHEN v.status = 'INUSE' THEN v.vehicleId END) as vehiclesInUse,
    COUNT(DISTINCT d.driverId) as totalDrivers,
    COUNT(DISTINCT CASE WHEN d.status = 'ONTRIP' THEN d.driverId END) as driversOnTrip
FROM branches b
LEFT JOIN invoices i ON b.branchId = i.branchId
    AND i.status = 'ACTIVE'
    AND i.invoiceDate BETWEEN :startDate AND :endDate
LEFT JOIN bookings bk ON b.branchId = bk.branchId
    AND bk.bookingDate BETWEEN :startDate AND :endDate
LEFT JOIN trips t ON bk.bookingId = t.bookingId
LEFT JOIN vehicles v ON b.branchId = v.branchId
LEFT JOIN drivers d ON b.branchId = d.branchId
WHERE b.status = 'ACTIVE'
GROUP BY b.branchId, b.branchName, b.location
ORDER BY revenue DESC;
```

### System Alerts (Critical)
```sql
-- Vehicles with expiring inspection
SELECT
    v.vehicleId,
    v.licensePlate,
    v.model,
    v.brand,
    b.branchName,
    v.inspectionExpiry,
    DATEDIFF(v.inspectionExpiry, CURDATE()) as daysUntilExpiry,
    'VEHICLE_INSPECTION_EXPIRING' as alertType
FROM vehicles v
INNER JOIN branches b ON v.branchId = b.branchId
WHERE v.status != 'INACTIVE'
    AND v.inspectionExpiry IS NOT NULL
    AND v.inspectionExpiry BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY v.inspectionExpiry;

-- Drivers with expiring license
SELECT
    d.driverId,
    e.employeeId,
    u.fullName,
    d.licenseNumber,
    d.licenseClass,
    d.licenseExpiry,
    b.branchName,
    DATEDIFF(d.licenseExpiry, CURDATE()) as daysUntilExpiry,
    'DRIVER_LICENSE_EXPIRING' as alertType
FROM drivers d
INNER JOIN employees e ON d.employeeId = e.employeeId
INNER JOIN users u ON e.userId = u.userId
INNER JOIN branches b ON d.branchId = b.branchId
WHERE d.status != 'INACTIVE'
    AND d.licenseExpiry IS NOT NULL
    AND d.licenseExpiry BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY d.licenseExpiry;

-- Overdue Invoices
SELECT
    i.invoiceId,
    i.invoiceNumber,
    c.fullName as customerName,
    i.amount,
    i.dueDate,
    DATEDIFF(CURDATE(), i.dueDate) as daysOverdue,
    b.branchName,
    'INVOICE_OVERDUE' as alertType
FROM invoices i
INNER JOIN branches b ON i.branchId = b.branchId
LEFT JOIN customers c ON i.customerId = c.customerId
WHERE i.paymentStatus = 'UNPAID'
    AND i.status = 'ACTIVE'
    AND i.dueDate IS NOT NULL
    AND i.dueDate < CURDATE()
ORDER BY i.dueDate;

-- Pending Approvals
SELECT
    ah.historyId,
    ah.approvalType,
    ah.relatedEntityId,
    ah.requestReason,
    ah.requestedAt,
    u.fullName as requesterName,
    b.branchName,
    'APPROVAL_PENDING' as alertType
FROM approval_history ah
INNER JOIN users u ON ah.requestedBy = u.userId
LEFT JOIN branches b ON ah.branchId = b.branchId
WHERE ah.status = 'PENDING'
ORDER BY ah.requestedAt;
```

### Top Routes
```sql
SELECT
    t.startLocation,
    t.endLocation,
    COUNT(*) as tripCount,
    AVG(t.distance) as avgDistance,
    AVG(t.estimatedDuration) as avgDuration,
    SUM(CASE WHEN t.status = 'COMPLETED' THEN 1 ELSE 0 END) as completedCount
FROM trips t
WHERE t.startTime BETWEEN :startDate AND :endDate
    AND t.startLocation IS NOT NULL
    AND t.endLocation IS NOT NULL
GROUP BY t.startLocation, t.endLocation
ORDER BY tripCount DESC
LIMIT 5;
```

---

## 2. MANAGER DASHBOARD QUERIES (Filtered by branchId)

### Branch KPIs
```sql
-- Branch Revenue & Expense
SELECT
    b.branchId,
    b.branchName,
    COALESCE(SUM(CASE WHEN i.type = 'INCOME' AND i.paymentStatus = 'PAID' THEN i.amount ELSE 0 END), 0) as paidRevenue,
    COALESCE(SUM(CASE WHEN i.type = 'INCOME' AND i.paymentStatus = 'UNPAID' THEN i.amount ELSE 0 END), 0) as unpaidRevenue,
    COALESCE(SUM(CASE WHEN i.type = 'INCOME' THEN i.amount ELSE 0 END), 0) as totalRevenue,
    COALESCE(SUM(CASE WHEN i.type = 'EXPENSE' THEN i.amount ELSE 0 END), 0) as totalExpense,
    COALESCE(SUM(CASE WHEN i.type = 'INCOME' THEN i.amount ELSE 0 END), 0) -
    COALESCE(SUM(CASE WHEN i.type = 'EXPENSE' THEN i.amount ELSE 0 END), 0) as netProfit
FROM branches b
LEFT JOIN invoices i ON b.branchId = i.branchId
    AND i.status = 'ACTIVE'
    AND i.invoiceDate BETWEEN :startDate AND :endDate
WHERE b.branchId = :branchId
GROUP BY b.branchId, b.branchName;

-- Branch Driver Status
SELECT
    COUNT(DISTINCT d.driverId) as totalDrivers,
    COUNT(DISTINCT CASE WHEN d.status = 'AVAILABLE' THEN d.driverId END) as availableDrivers,
    COUNT(DISTINCT CASE WHEN d.status = 'ONTRIP' THEN d.driverId END) as driversOnTrip,
    COUNT(DISTINCT CASE WHEN d.status = 'INACTIVE' THEN d.driverId END) as inactiveDrivers,
    COUNT(DISTINCT CASE WHEN ddo.status = 'APPROVED' AND ddo.startDate <= CURDATE() AND ddo.endDate >= CURDATE() THEN d.driverId END) as driversOnLeave
FROM drivers d
LEFT JOIN driver_day_off ddo ON d.driverId = ddo.driverId
WHERE d.branchId = :branchId;

-- Branch Vehicle Status
SELECT
    COUNT(DISTINCT v.vehicleId) as totalVehicles,
    COUNT(DISTINCT CASE WHEN v.status = 'AVAILABLE' THEN v.vehicleId END) as availableVehicles,
    COUNT(DISTINCT CASE WHEN v.status = 'INUSE' THEN v.vehicleId END) as vehiclesInUse,
    COUNT(DISTINCT CASE WHEN v.status = 'MAINTENANCE' THEN v.vehicleId END) as vehiclesInMaintenance,
    COUNT(DISTINCT CASE WHEN v.status = 'INACTIVE' THEN v.vehicleId END) as inactiveVehicles,
    ROUND((COUNT(DISTINCT CASE WHEN v.status = 'INUSE' THEN v.vehicleId END) * 100.0 /
           NULLIF(COUNT(DISTINCT CASE WHEN v.status IN ('AVAILABLE', 'INUSE') THEN v.vehicleId END), 0)), 2) as utilizationRate
FROM vehicles v
WHERE v.branchId = :branchId;
```

### Branch Revenue Trend
```sql
SELECT
    DATE_FORMAT(i.invoiceDate, '%Y-%m') as month,
    SUM(CASE WHEN i.type = 'INCOME' THEN i.amount ELSE 0 END) as revenue,
    SUM(CASE WHEN i.type = 'EXPENSE' THEN i.amount ELSE 0 END) as expense,
    SUM(CASE WHEN i.type = 'INCOME' THEN i.amount ELSE 0 END) -
    SUM(CASE WHEN i.type = 'EXPENSE' THEN i.amount ELSE 0 END) as netProfit
FROM invoices i
WHERE i.branchId = :branchId
    AND i.status = 'ACTIVE'
    AND i.invoiceDate >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(i.invoiceDate, '%Y-%m')
ORDER BY month;
```

### Top Drivers Performance
```sql
SELECT
    d.driverId,
    u.fullName as driverName,
    d.licenseNumber,
    d.rating,
    COUNT(DISTINCT td.tripId) as totalTrips,
    COUNT(DISTINCT CASE WHEN t.status = 'COMPLETED' THEN td.tripId END) as completedTrips,
    COALESCE(SUM(CASE WHEN t.status = 'COMPLETED' THEN t.actualDuration END), 0) as totalMinutes
FROM drivers d
INNER JOIN employees e ON d.employeeId = e.employeeId
INNER JOIN users u ON e.userId = u.userId
LEFT JOIN trip_drivers td ON d.driverId = td.driverId
LEFT JOIN trips t ON td.tripId = t.tripId
    AND t.startTime BETWEEN :startDate AND :endDate
WHERE d.branchId = :branchId
    AND d.status != 'INACTIVE'
GROUP BY d.driverId, u.fullName, d.licenseNumber, d.rating
ORDER BY completedTrips DESC, totalMinutes DESC
LIMIT 5;
```

### Expense Breakdown by Category
```sql
SELECT
    i.costType as category,
    COUNT(*) as expenseCount,
    SUM(i.amount) as totalAmount,
    AVG(i.amount) as avgAmount
FROM invoices i
WHERE i.branchId = :branchId
    AND i.type = 'EXPENSE'
    AND i.status = 'ACTIVE'
    AND i.invoiceDate BETWEEN :startDate AND :endDate
    AND i.costType IS NOT NULL
GROUP BY i.costType
ORDER BY totalAmount DESC;
```

### Pending Approvals for Manager
```sql
-- Day Off Requests
SELECT
    ddo.dayOffId,
    ddo.driverId,
    u.fullName as driverName,
    ddo.startDate,
    ddo.endDate,
    ddo.reason,
    ddo.status,
    ddo.createdAt,
    'DRIVER_DAY_OFF' as approvalType
FROM driver_day_off ddo
INNER JOIN drivers d ON ddo.driverId = d.driverId
INNER JOIN employees e ON d.employeeId = e.employeeId
INNER JOIN users u ON e.userId = u.userId
WHERE d.branchId = :branchId
    AND ddo.status = 'PENDING'
ORDER BY ddo.createdAt;

-- Expense Requests
SELECT
    er.expenseRequestId,
    er.expenseType,
    er.amount,
    er.note,
    er.status,
    er.createdAt,
    u.fullName as requesterName,
    v.licensePlate,
    'EXPENSE_REQUEST' as approvalType
FROM expense_requests er
INNER JOIN users u ON er.requesterId = u.userId
LEFT JOIN vehicles v ON er.vehicleId = v.vehicleId
WHERE er.branchId = :branchId
    AND er.status = 'PENDING'
ORDER BY er.createdAt;

-- Other Approvals
SELECT
    ah.historyId,
    ah.approvalType,
    ah.relatedEntityId,
    ah.requestReason,
    ah.requestedAt,
    u.fullName as requesterName,
    'APPROVAL_HISTORY' as approvalType
FROM approval_history ah
INNER JOIN users u ON ah.requestedBy = u.userId
WHERE ah.branchId = :branchId
    AND ah.status = 'PENDING'
ORDER BY ah.requestedAt;
```

---

## 3. ADDITIONAL ANALYTICS

### Vehicle Utilization by Category
```sql
SELECT
    vcp.categoryName,
    COUNT(DISTINCT v.vehicleId) as totalVehicles,
    COUNT(DISTINCT CASE WHEN v.status = 'INUSE' THEN v.vehicleId END) as inUse,
    COUNT(DISTINCT CASE WHEN v.status = 'AVAILABLE' THEN v.vehicleId END) as available,
    ROUND((COUNT(DISTINCT CASE WHEN v.status = 'INUSE' THEN v.vehicleId END) * 100.0 /
           NULLIF(COUNT(DISTINCT v.vehicleId), 0)), 2) as utilizationRate
FROM vehicle_category_pricing vcp
LEFT JOIN vehicles v ON vcp.categoryId = v.categoryId
    AND v.status IN ('AVAILABLE', 'INUSE')
WHERE (:branchId IS NULL OR v.branchId = :branchId)
GROUP BY vcp.categoryId, vcp.categoryName
ORDER BY utilizationRate DESC;
```

### Customer Booking Statistics
```sql
SELECT
    c.customerId,
    c.fullName as customerName,
    c.phone,
    c.email,
    COUNT(DISTINCT b.bookingId) as totalBookings,
    COUNT(DISTINCT CASE WHEN b.status = 'COMPLETED' THEN b.bookingId END) as completedBookings,
    COALESCE(SUM(b.totalCost), 0) as totalRevenue,
    COALESCE(AVG(b.totalCost), 0) as avgOrderValue
FROM customers c
LEFT JOIN bookings b ON c.customerId = b.customerId
    AND b.bookingDate BETWEEN :startDate AND :endDate
WHERE c.status = 'ACTIVE'
    AND (:branchId IS NULL OR b.branchId = :branchId)
GROUP BY c.customerId, c.fullName, c.phone, c.email
HAVING COUNT(DISTINCT b.bookingId) > 0
ORDER BY totalRevenue DESC
LIMIT 10;
```
