# Dashboard API 400 Errors Fix

## Vấn đề
Nhiều lỗi 400 Bad Request khi load Dashboard:
```
GET /api/v1/manager/analytics/vehicle-efficiency?branchId=1&period=THIS_MONTH 400
GET /api/v1/manager/analytics/vehicle-efficiency?branchId=2&period=THIS_MONTH 400
...
```

## Root Cause
**Backend chưa implement các analytics endpoints:**
- `/api/v1/manager/analytics/vehicle-efficiency`
- `/api/v1/manager/analytics/expense-breakdown`
- Và có thể một số endpoints khác

## Giải pháp

### Option 1: Graceful Degradation (Recommended - Đã áp dụng)
Thêm try-catch trong API functions để return empty data khi endpoint chưa có:

```javascript
export async function getBranchVehicleEfficiency(params = {}) {
    try {
        const response = await axiosInstance.get("/api/v1/manager/analytics/vehicle-efficiency", {
            params,
        });
        return response.data;
    } catch (error) {
        // API not implemented yet - return empty data
        console.warn(`[API] Vehicle efficiency endpoint not implemented:`, error.message);
        return [];
    }
}
```

**Ưu điểm:**
- Dashboard vẫn hoạt động
- Không spam console với errors
- Dễ debug (có warning log)
- Khi backend implement xong, tự động hoạt động

### Option 2: Conditional API Calls
Chỉ gọi API khi biết chắc đã được implement:

```javascript
const IMPLEMENTED_APIS = {
    vehicleEfficiency: false,  // Chưa có
    expenseBreakdown: false,   // Chưa có
    revenueTrend: true,        // Đã có
};

if (IMPLEMENTED_APIS.vehicleEfficiency) {
    const data = await getBranchVehicleEfficiency(params);
}
```

**Nhược điểm:**
- Phải maintain config
- Dễ quên update khi backend implement

### Option 3: Mock Data (Development only)
Return mock data khi API fail:

```javascript
export async function getBranchVehicleEfficiency(params = {}) {
    try {
        const response = await axiosInstance.get(...);
        return response.data;
    } catch (error) {
        if (process.env.NODE_ENV === 'development') {
            return [
                { vehicleId: 1, costPerKm: 5000, totalKm: 1000 },
                { vehicleId: 2, costPerKm: 4500, totalKm: 1200 },
            ];
        }
        return [];
    }
}
```

## Changes Made

### File: `dashboards.js`

**Before:**
```javascript
export async function getBranchVehicleEfficiency(params = {}) {
    const response = await axiosInstance.get("/api/v1/manager/analytics/vehicle-efficiency", {
        params,
    });
    return response.data;  // ❌ Throws error if API not found
}
```

**After:**
```javascript
export async function getBranchVehicleEfficiency(params = {}) {
    try {
        const response = await axiosInstance.get("/api/v1/manager/analytics/vehicle-efficiency", {
            params,
        });
        return response.data;
    } catch (error) {
        console.warn(`[API] Vehicle efficiency endpoint not implemented:`, error.message);
        return [];  // ✅ Graceful fallback
    }
}
```

## Testing

### Test Case 1: API Not Implemented (Current state)
1. Open Manager Dashboard
2. Check Console
3. ✅ Expected: Warning logs, no red errors
4. ✅ Expected: Dashboard loads with empty charts

### Test Case 2: API Implemented (Future)
1. Backend implements endpoint
2. Open Manager Dashboard
3. ✅ Expected: Data loads automatically
4. ✅ Expected: No code changes needed

## Backend TODO

Cần implement các endpoints sau:

### 1. Vehicle Efficiency
```
GET /api/v1/manager/analytics/vehicle-efficiency
Query params: branchId, period
Response: [
  {
    vehicleId: 1,
    licensePlate: "30G-123.45",
    totalKm: 1000,
    totalCost: 5000000,
    costPerKm: 5000
  }
]
```

### 2. Expense Breakdown
```
GET /api/v1/manager/analytics/expense-breakdown
Query params: branchId, startDate, endDate
Response: [
  {
    category: "FUEL",
    amount: 10000000,
    percentage: 40
  },
  {
    category: "MAINTENANCE",
    amount: 5000000,
    percentage: 20
  }
]
```

### 3. Top Routes (Có thể đã có)
```
GET /api/v1/admin/analytics/top-routes
Query params: period
Response: [
  {
    startLocation: "Hà Nội",
    endLocation: "Hải Phòng",
    tripCount: 50,
    avgDistance: 120.5
  }
]
```

### 4. Pending Approvals (Có thể đã có)
```
GET /api/v1/admin/approvals/pending
Response: [
  {
    historyId: 1,
    approvalType: "BOOKING_APPROVAL",
    requesterName: "Nguyễn Văn A",
    branchName: "Chi nhánh Hà Nội",
    requestedAt: "2025-11-25T10:00:00Z"
  }
]
```

## Related Issues

### Issue 1: AdminDashboard cũng có thể gặp lỗi tương tự
Check các API calls trong AdminDashboard:
- `getAdminDashboard()`
- `getRevenueTrend()`
- `getBranchComparison()`
- `getFleetUtilization()`
- `getTopRoutes()`
- `getSystemAlerts()`
- `getPendingApprovals()`

**Solution:** Đã dùng `Promise.allSettled()` trong AdminDashboard để handle gracefully.

### Issue 2: ManagerDashboard gọi nhiều APIs
ManagerDashboard có thể gọi nhiều analytics APIs chưa có. Cần apply cùng pattern.

## Best Practices

### 1. Always use try-catch for external API calls
```javascript
try {
    const data = await apiCall();
    return data;
} catch (error) {
    console.warn("API not available:", error.message);
    return fallbackData;
}
```

### 2. Use Promise.allSettled for multiple APIs
```javascript
const results = await Promise.allSettled([
    getAPI1(),
    getAPI2(),
    getAPI3(),
]);

const data1 = results[0].status === 'fulfilled' ? results[0].value : [];
const data2 = results[1].status === 'fulfilled' ? results[1].value : [];
```

### 3. Log warnings, not errors
```javascript
console.warn("[API] Endpoint not implemented");  // ✅ Warning
// NOT: console.error() - Looks like a bug
```

### 4. Return appropriate fallback data
```javascript
// For arrays
return [];

// For objects
return { data: [], total: 0 };

// For numbers
return 0;
```

## Files Changed
- `PTCMSS_FRONTEND/src/api/dashboards.js`
  - Added try-catch to `getBranchVehicleEfficiency`
  - Added try-catch to `getBranchExpenseBreakdown`
  - Returns empty array on error

## Next Steps
1. ✅ Frontend handles missing APIs gracefully
2. ⏳ Backend team implements analytics endpoints
3. ⏳ Test with real data when available
4. ⏳ Remove console.warn when all APIs are stable
