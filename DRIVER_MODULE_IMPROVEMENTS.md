# Driver Module Improvements

## Current Status & Required Changes

### 1. DriverDashboard.jsx ✅ (Mostly Complete)
**Current State:**
- ✅ Has KPI cards: Trips today, trips this month, days off used/allowed
- ✅ Shows current/upcoming trip
- ⚠️ Only shows 1 trip, needs to show list of upcoming trips

**Required Changes:**
- Add upcoming trips list below current trip card
- Each trip card should be clickable → navigate to trip detail page
- Keep KPI cards as is

### 2. DriverNotificationsPage.jsx ❌ (Remove)
**Action:** Remove this page, notifications only via bell icon in topbar

### 3. DriverSchedulePage.jsx ⚠️ (Needs Update)
**Required Changes:**
- Remove "số chuyến tháng" and "ngày nghỉ" stats
- Keep calendar view
- Click on any trip → navigate to trip detail page
- Focus on schedule visualization only

### 4. DriverTripsListPage.jsx ⚠️ (Needs Update)
**Required Changes:**
- Show list of all driver's trips (past and future)
- Display: Start/End time, Pickup/Dropoff location, Overall rating
- Click on trip → navigate to detail page
- Add pagination if not present

### 5. DriverTripDetailPage.jsx ⚠️ (Needs Major Update)
**Current Issues:**
- Need to check if it allows status updates only for today's trips
- Need to check if expense reporting is restricted to today's trips

**Required Changes:**
- Show trip info: Customer name, phone, vehicle info
- Show route: Start location, end location, booking notes
- Allow status updates ONLY for trips happening today
- Allow expense reporting ONLY for trips happening today
- After completing trip, show button to create payment request for remaining balance
- For past/future trips: Read-only mode

### 6. DriverLeaveRequestPage.jsx ✅ (Keep as is)
**Status:** Already working correctly

### 7. DriverRequestsPage.jsx ⚠️ (Needs Check)
**Required Changes:**
- Show list of driver's requests:
  - Leave requests
  - Expense requests
  - Payment requests
- Show status of each request (Pending, Approved, Rejected)
- Add pagination if not present

### 8. DriverProfilePage.jsx ✅ (Keep as is)
**Status:** Already working correctly

## Implementation Priority

1. **High Priority:**
   - Update DriverTripDetailPage - restrict actions to today's trips
   - Add payment request button after trip completion
   - Update DriverTripsListPage - add rating display

2. **Medium Priority:**
   - Update DriverDashboard - add upcoming trips list
   - Update DriverSchedulePage - remove stats, keep calendar
   - Update DriverRequestsPage - ensure all request types shown

3. **Low Priority:**
   - Remove DriverNotificationsPage from routes
   - Update sidebar navigation

## API Endpoints Needed

### For Trip Detail:
- GET `/api/drivers/{driverId}/trips/{tripId}` - Get trip details
- POST `/api/drivers/{driverId}/trips/{tripId}/start` - Start trip (today only)
- POST `/api/drivers/{driverId}/trips/{tripId}/complete` - Complete trip (today only)
- POST `/api/drivers/{driverId}/trips/{tripId}/expenses` - Report expense (today only)
- POST `/api/drivers/{driverId}/trips/{tripId}/payment-request` - Create payment request (after completion)

### For Trips List:
- GET `/api/drivers/{driverId}/trips` - Get all trips with pagination
- Should include rating info in response

### For Requests List:
- GET `/api/drivers/{driverId}/requests` - Get all requests (leave, expense, payment)

## Notes

- All date/time comparisons for "today" should use server time or consistent timezone
- Payment request should calculate remaining balance from booking total - deposits paid
- Expense reporting should support multiple expenses per trip
- Rating should be displayed as stars (1-5) with average shown
