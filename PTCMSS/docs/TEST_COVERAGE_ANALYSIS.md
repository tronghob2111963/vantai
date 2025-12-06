# Phân tích Test Coverage - PTCMSS

## Tổng quan
Tài liệu này phân tích các unit test hiện có và xác định các chức năng còn thiếu test.

---

## 1. BookingServiceImplTest (5 tests hiện có)

### ✅ Đã có test:
- `checkAvailability()` - 2 tests (đủ xe, thiếu xe)
- `calculatePrice()` - 3 tests (ONE_WAY, DAILY với surcharge, skip inactive categories)
- `create()` - 1 test (error case: không đủ tài xế)

### ❌ Thiếu test cho:
1. **`create()` - Success cases:**
   - Tạo booking thành công với đầy đủ thông tin
   - Tạo booking với nhiều trips
   - Tạo booking ROUND_TRIP (2 trips)
   - Tạo booking với nhiều loại xe
   - Tạo booking và tạo invoice deposit

2. **`update()` - Update booking:**
   - Update thành công
   - Update với invalid bookingId
   - Update với status không hợp lệ
   - Update trips và vehicles

3. **`getById()` - Get booking by ID:**
   - Get thành công
   - Get với bookingId không tồn tại

4. **`getAll()` - List bookings:**
   - List với pagination
   - List với filters (status, branchId, consultantId)
   - List empty

5. **`delete()` - Delete booking:**
   - Delete thành công
   - Delete với bookingId không tồn tại
   - Delete với booking đã có trips

6. **`getConsultantDashboard()` - Dashboard:**
   - Get dashboard với data
   - Get dashboard empty

7. **`getBookingList()` - List bookings:**
   - List với filters
   - List empty

8. **`addPayment()` - Add payment:**
   - Add payment thành công
   - Add payment với invalid bookingId

9. **`assign()` - Assign driver/vehicle:**
   - Assign thành công
   - Assign với invalid bookingId

---

## 2. DriverServiceImplTest (3 tests hiện có)

### ✅ Đã có test:
- `updateProfile()` - 2 tests (coordinator không được set status, admin được update)
- `requestDayOff()` - 1 test (tạo request và approval)

### ❌ Thiếu test cho:
1. **`getDashboard()` - Driver dashboard:**
   - Get dashboard với data
   - Get dashboard empty

2. **`getSchedule()` - Driver schedule:**
   - Get schedule với trips
   - Get schedule empty
   - Get schedule với date range

3. **`getProfile()` - Get driver profile:**
   - Get profile thành công
   - Get profile với driverId không tồn tại

4. **`getProfileByUserId()` - Get profile by userId:**
   - Get profile thành công
   - Get profile với userId không tồn tại

5. **`getDayOffHistory()` - Day off history:**
   - Get history với requests
   - Get history empty

6. **`cancelDayOffRequest()` - Cancel day off:**
   - Cancel thành công
   - Cancel với dayOffId không tồn tại
   - Cancel với driverId không match

7. **`startTrip()` - Start trip:**
   - Start trip thành công
   - Start trip với tripId không tồn tại
   - Start trip với driverId không match

8. **`completeTrip()` - Complete trip:**
   - Complete trip thành công
   - Complete trip với tripId không tồn tại

9. **`reportIncident()` - Report incident:**
   - Report thành công
   - Report với invalid tripId

10. **`createDriver()` - Create driver:**
    - Create thành công
    - Create với duplicate license

11. **`getDriversByBranchId()` - List drivers:**
    - List với drivers
    - List empty

---

## 3. VehicleServiceImplTest (4 tests hiện có)

### ✅ Đã có test:
- `create()` - 2 tests (success, duplicate license plate)
- `update()` - 1 test (coordinator không được set INUSE)
- `getVehicleTrips()` - 1 test (get trips)

### ❌ Thiếu test cho:
1. **`update()` - Success cases:**
   - Update thành công với admin
   - Update thành công với coordinator (không thay đổi status)
   - Update với vehicleId không tồn tại

2. **`getById()` - Get vehicle by ID:**
   - Get thành công
   - Get với vehicleId không tồn tại

3. **`getAll()` - List all vehicles:**
   - List với vehicles
   - List empty

4. **`search()` - Search by license plate:**
   - Search thành công
   - Search không tìm thấy

5. **`filter()` - Filter vehicles:**
   - Filter theo categoryId
   - Filter theo branchId
   - Filter theo status
   - Filter kết hợp

6. **`getAllWithPagination()` - Pagination:**
   - Pagination với data
   - Pagination empty
   - Pagination với filters

7. **`delete()` - Delete vehicle:**
   - Delete thành công
   - Delete với vehicleId không tồn tại
   - Delete với vehicle đang sử dụng

8. **`getVehicleExpenses()` - Get expenses:**
   - Get expenses với data
   - Get expenses empty

9. **`getVehicleMaintenance()` - Get maintenance:**
   - Get maintenance với data
   - Get maintenance empty

10. **`createMaintenance()` - Create maintenance:**
    - Create thành công
    - Create với vehicleId không tồn tại

11. **`createExpense()` - Create expense:**
    - Create thành công
    - Create với vehicleId không tồn tại

12. **`getVehiclesByBranch()` - List by branch:**
    - List với vehicles
    - List empty

13. **`getVehiclesByBranchAndDriver()` - List by branch and driver:**
    - List với vehicles
    - List empty

---

## 4. DispatchServiceImplTest (1 test hiện có)

### ✅ Đã có test:
- `getPendingTrips()` - 1 test (filter pending trips)

### ❌ Thiếu test cho:
1. **`getPendingTrips()` - Additional cases:**
   - Get với from/to dates
   - Get empty

2. **`getAllPendingTrips()` - All pending trips:**
   - Get all pending
   - Get empty

3. **`getAssignmentSuggestions()` - Assignment suggestions:**
   - Get suggestions với candidates
   - Get suggestions empty
   - Get suggestions với filters

4. **`getDashboard()` - Dispatch dashboard:**
   - Get dashboard với data
   - Get dashboard empty

5. **`assign()` - Assign driver/vehicle:**
   - Assign thành công
   - Assign với invalid tripId
   - Assign với driver không available
   - Assign với vehicle không available

6. **`unassign()` - Unassign:**
   - Unassign thành công
   - Unassign với tripId không tồn tại

7. **`reassign()` - Reassign:**
   - Reassign thành công
   - Reassign với invalid tripId

8. **`driverAcceptTrip()` - Driver accept:**
   - Accept thành công
   - Accept với tripId không tồn tại

9. **`getTripDetail()` - Trip detail:**
   - Get detail thành công
   - Get detail với tripId không tồn tại

10. **`searchTrips()` - Search trips:**
    - Search với filters
    - Search empty

---

## 5. ExpenseRequestServiceImplTest (22 tests - ✅ Đầy đủ)

### ✅ Đã có test đầy đủ:
- `createExpenseRequest()` - 6 tests
- `approveRequest()` - 4 tests
- `rejectRequest()` - 3 tests
- `getPendingRequests()` - 3 tests
- `getByDriverId()` - 2 tests
- `getAllRequests()` - 4 tests

### Có thể thêm (optional):
- `updateExpenseRequest()` - nếu có method này
- `deleteExpenseRequest()` - nếu có method này
- `getExpenseRequestById()` - nếu có method này

---

## Tổng kết

### Test Coverage hiện tại:
- **BookingServiceImpl**: ~20% (5/12 methods có test)
- **DriverServiceImpl**: ~23% (3/13 methods có test)
- **VehicleServiceImpl**: ~27% (4/15 methods có test)
- **DispatchServiceImpl**: ~7% (1/14 methods có test)
- **ExpenseRequestServiceImpl**: ~100% (6/6 methods có test)

### Ưu tiên bổ sung test:
1. **Priority 1 - Critical Business Logic:**
   - `BookingServiceImpl.create()` - success cases
   - `BookingServiceImpl.update()` - update booking
   - `DispatchServiceImpl.assign()` - assign driver/vehicle
   - `DriverServiceImpl.startTrip()` / `completeTrip()` - trip lifecycle

2. **Priority 2 - Data Retrieval:**
   - `BookingServiceImpl.getById()` / `getAll()`
   - `DriverServiceImpl.getProfile()` / `getSchedule()`
   - `VehicleServiceImpl.getById()` / `getAll()`
   - `DispatchServiceImpl.getTripDetail()`

3. **Priority 3 - Supporting Functions:**
   - `BookingServiceImpl.delete()` / `addPayment()`
   - `DriverServiceImpl.getDayOffHistory()` / `cancelDayOffRequest()`
   - `VehicleServiceImpl.delete()` / `getVehicleExpenses()`
   - `DispatchServiceImpl.unassign()` / `reassign()`

---

## Kế hoạch bổ sung

### Tuần 1-2: BookingServiceImpl
- Thêm 15-20 test cases cho `create()`, `update()`, `getById()`, `getAll()`, `delete()`

### Tuần 3-4: DriverServiceImpl
- Thêm 20-25 test cases cho các methods còn thiếu

### Tuần 5-6: VehicleServiceImpl
- Thêm 20-25 test cases cho các methods còn thiếu

### Tuần 7-8: DispatchServiceImpl
- Thêm 15-20 test cases cho các methods còn thiếu

**Mục tiêu:** Đạt 70%+ coverage cho tất cả các service critical.

