# Known Issues & Workarounds

## 1. Dashboard API 400 Errors (Non-blocking)

### Symptom
Console shows red 400 errors when loading Manager Dashboard:
```
GET /api/v1/manager/analytics/vehicle-efficiency?branchId=X 400
GET /api/v1/manager/analytics/expense-breakdown?branchId=X 400
```

### Root Cause
Backend analytics endpoints not yet implemented.

### Impact
- ❌ Red errors in Console (looks bad)
- ✅ Dashboard still works (graceful fallback)
- ✅ Charts show empty data instead of crashing

### Status
**KNOWN ISSUE - Non-blocking**

Frontend handles these errors gracefully with try-catch and returns empty arrays. The errors you see in Console are browser network logs that appear BEFORE JavaScript catches them. This is normal browser behavior and doesn't affect functionality.

### Workaround Options

#### Option 1: Ignore Console Errors (Current)
- Dashboard works fine
- Just ignore red 400s in Console
- When backend implements APIs, errors will disappear automatically

#### Option 2: Temporarily Disable API Calls
Replace API calls with `Promise.resolve([])` in ManagerDashboard.jsx:
```javascript
// Line ~463
Promise.resolve([]), // getBranchVehicleEfficiency - not implemented
Promise.resolve([]), // getBranchExpenseBreakdown - not implemented
```

#### Option 3: Implement Mock Backend Endpoints
Add stub endpoints in backend that return empty data:
```java
@GetMapping("/api/v1/manager/analytics/vehicle-efficiency")
public ResponseEntity<?> getVehicleEfficiency(@RequestParam Integer branchId) {
    // TODO: Implement actual logic
    return ResponseEntity.ok(Collections.emptyList());
}
```

### Backend TODO
Implement these endpoints:
1. `GET /api/v1/manager/analytics/vehicle-efficiency`
2. `GET /api/v1/manager/analytics/expense-breakdown`

See `DASHBOARD_API_ERRORS_FIX.md` for API specs.

---

## 2. Coordinator Queue Empty After Creating Order

### Symptom
- Create new order successfully
- WebSocket notification received
- But order doesn't appear in Coordinator Queue

### Root Cause
**Pickup date mismatch** - Order created for different date than selected in Coordinator Timeline.

### Solution
1. Check pickup date when creating order
2. Select same date in Coordinator Timeline
3. Click "Refresh" button (green button next to "Now")

See `COORDINATOR_TROUBLESHOOTING.md` for details.

---

## 3. Vehicle Update 400 Error (FIXED)

### Symptom
Error when updating vehicle status/branch.

### Root Cause
Field name mismatch: frontend sent `branch_id` but backend expected `branchId`.

### Status
✅ **FIXED** - See `VEHICLE_UPDATE_FIX.md`

---

## 4. Branch Selection Not Working (FIXED)

### Symptom
Branch dropdown empty or not loading in Create Order / Coordinator pages.

### Root Cause
Response parsing issue: backend returns `data.items` but frontend looked for `data.content`.

### Status
✅ **FIXED** - See `FIELD_MAPPING_FIX.md` and `COORDINATOR_BRANCH_FIX.md`

---

## 5. Booking Status PENDING vs CONFIRMED (FIXED)

### Symptom
Orders created with "Đặt đơn" button don't appear in Coordinator Queue.

### Root Cause
Orders created with `status: CONFIRMED` but Coordinator only shows `status: PENDING`.

### Status
✅ **FIXED** - Changed "Đặt đơn" to create `PENDING` status. See `PENDING_VS_CONFIRMED_STATUS.md`

---

## General Debugging Tips

### 1. Check Console Logs
Look for logs starting with:
- `🔍` - Debug info
- `✅` - Success
- `❌` - Error
- `⚠️` - Warning

### 2. Check Network Tab
- Filter by "XHR" to see API calls
- Check request/response for each failed call
- Look at status code and response body

### 3. Check localStorage
```javascript
console.log({
  userId: localStorage.getItem("userId"),
  roleName: localStorage.getItem("roleName"),
  branchId: localStorage.getItem("branchId"),
  access_token: localStorage.getItem("access_token") ? "exists" : "missing"
});
```

### 4. Clear Cache
If things look broken:
1. Hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
2. Clear localStorage: `localStorage.clear()` in Console
3. Re-login

### 5. Check Backend Logs
If frontend looks correct but data is wrong, check backend logs for errors.

---

## Reporting New Issues

When reporting issues, please include:
1. **What you were trying to do**
2. **What happened** (screenshot + console logs)
3. **What you expected**
4. **Steps to reproduce**
5. **User role** (Admin, Manager, Consultant, etc.)
6. **Browser** (Chrome, Firefox, etc.)

---

## Priority Levels

- 🔴 **Critical** - Blocks core functionality
- 🟡 **High** - Affects user experience but has workaround
- 🟢 **Low** - Cosmetic or minor inconvenience
- ⚪ **Info** - Not an issue, just FYI

Current issues:
- 🟢 Dashboard API 400 errors - Low (cosmetic, doesn't affect functionality)
