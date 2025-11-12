# 🔍 SO SÁNH SCHEMA: Database hiện tại vs Schema mới

## ❌ VẤN ĐỀ PHÁT HIỆN

### 1. **Vehicles Table** - Schema mới THIẾU columns

**Database hiện tại** (`00_full_setup.sql` - đã được sửa):
```sql
CREATE TABLE IF NOT EXISTS Vehicles (
  vehicleId INT AUTO_INCREMENT PRIMARY KEY,
  categoryId INT NOT NULL,
  branchId INT NOT NULL,
  licensePlate VARCHAR(20) NOT NULL UNIQUE,
  model VARCHAR(100),
  brand VARCHAR(100),              -- ✅ CÓ
  capacity INT,
  productionYear INT CHECK (productionYear >= 1980),
  registrationDate DATE,
  inspectionExpiry DATE,
  insuranceExpiry DATE,           -- ✅ CÓ
  odometer BIGINT,                -- ✅ CÓ
  status ENUM('Available','InUse','Maintenance','Inactive') DEFAULT 'Available',
  ...
)
```

**Schema mới** (từ user):
```sql
CREATE TABLE Vehicles (
  ...
  model VARCHAR(100),
  -- ❌ THIẾU: brand VARCHAR(100)
  capacity INT,
  ...
  inspectionExpiry DATE,
  -- ❌ THIẾU: insuranceExpiry DATE
  -- ❌ THIẾU: odometer BIGINT
  status ENUM(...),
  ...
)
```

**⚠️ VẤN ĐỀ**: 
- Entity Java (`Vehicles.java`) đã có `brand`, `insuranceExpiry`, `odometer`
- Database hiện tại đã có (sau khi sửa)
- **Schema mới KHÔNG có** → Nếu chạy schema mới sẽ bị lỗi khi Entity cố gắng map các fields này

---

### 2. **SystemSettings Table** - ✅ ĐỒNG BỘ

Cả hai đều có:
- `effectiveStartDate DATE NOT NULL`
- `effectiveEndDate DATE NULL`

---

### 3. **Seed Data - TripVehicles** - ❌ LỖI SYNTAX trong schema mới

**Schema mới** (dòng 14):
```sql
INSERT INTO TripVehicles (tripVehicleId, tripId, vehicleId, note) VALUES
(1, 1, 3, 'Gán xe Samco 29A-333.33'),
(2, 2, 5, 'Gán xe Transit 51C-555.55'),
(3, 3, 'Gán xe 1 cho HĐ định kỳ (Sáng)'),  -- ❌ THIẾU vehicleId
(3, 6, 'Gán xe 2 cho HĐ định kỳ (Sáng)'),  -- ❌ THIẾU vehicleId
...
```

**Vấn đề**: 
- Dòng 3, 4, 5, 6, 7, 8 **THIẾU giá trị `vehicleId`** (chỉ có 3 giá trị thay vì 4)
- Sẽ bị lỗi SQL syntax error khi chạy

**Database hiện tại** (`00_full_setup.sql`):
```sql
INSERT INTO TripVehicles (tripVehicleId, tripId, vehicleId, note) VALUES
(1, 1, 3, 'Gán xe Samco 29A-333.33 cho Trip 1'),
(2, 2, 5, 'Gán xe Transit 51C-555.55 cho Trip 2'),
(3, 3, 3, 'Gán xe 29A-333.33 cho Trip 3 (sáng)'),  -- ✅ ĐÚNG
(4, 3, 6, 'Gán xe 29A-666.66 cho Trip 3 (sáng)'),  -- ✅ ĐÚNG
...
```

---

### 4. **Seed Data - TripDrivers** - ❌ LỖI LOGIC trong schema mới

**Schema mới**:
```sql
INSERT INTO TripDrivers (tripId, driverId, driverRole, note) VALUES
(3, 1, 'Main Driver', 'Tài A lái xe 1 (Sáng)'),
(3, 2, 'Main Driver', 'Tài B lái xe 2 (Sáng)'),  -- ❌ Cả 2 đều là 'Main Driver'
```

**Vấn đề**: 
- Trip 3 có 2 drivers, cả 2 đều là `'Main Driver'` → không hợp lý
- Nên có 1 `'Main Driver'` và 1 `'Support Driver'`

**Database hiện tại**:
```sql
(3, 1, 'Main Driver', 'Tài xế A lái xe Trip 3 (sáng)'),
(3, 2, 'Support Driver', 'Tài xế B hỗ trợ Trip 3 (sáng)'),  -- ✅ ĐÚNG
```

---

### 5. **Seed Data - DriverDayOff** - ❌ THIẾU dayOffId

**Schema mới**:
```sql
INSERT INTO DriverDayOff (driverId, startDate, endDate, reason, approvedBy, status) VALUES
-- ❌ THIẾU dayOffId trong INSERT
```

**Database hiện tại**:
```sql
INSERT INTO DriverDayOff (dayOffId, driverId, startDate, endDate, reason, approvedBy, status) VALUES
(1, 1, '2025-10-30', '2025-10-30', 'Việc gia đình', 2, 'Approved'),
-- ✅ CÓ dayOffId
```

**Lưu ý**: Nếu `dayOffId` là AUTO_INCREMENT, có thể bỏ qua trong INSERT, nhưng nếu muốn control ID thì phải có.

---

### 6. **Seed Data - Invoices** - ❌ THIẾU invoiceId

**Schema mới**:
```sql
INSERT INTO Invoices (branchId, bookingId, customerId, type, ...) VALUES
-- ❌ THIẾU invoiceId trong INSERT
```

**Database hiện tại**:
```sql
INSERT INTO Invoices (invoiceId, branchId, bookingId, customerId, type, ...) VALUES
(1, 1, 1, 2, 'Income', ...),
-- ✅ CÓ invoiceId
```

---

### 7. **Seed Data - AccountsReceivable** - ❌ THIẾU arId

**Schema mới**:
```sql
INSERT INTO AccountsReceivable (customerId, bookingId, totalAmount, ...) VALUES
-- ❌ THIẾU arId trong INSERT
```

**Database hiện tại**:
```sql
INSERT INTO AccountsReceivable (arId, customerId, bookingId, totalAmount, ...) VALUES
(1, 2, 1, 3800000.00, ...),
-- ✅ CÓ arId
```

---

### 8. **Seed Data - SystemSettings** - ❌ THIẾU settingId

**Schema mới**:
```sql
INSERT INTO SystemSettings (settingKey, settingValue, effectiveStartDate, ...) VALUES
-- ❌ THIẾU settingId trong INSERT
```

**Database hiện tại**:
```sql
INSERT INTO SystemSettings (settingId, settingKey, settingValue, effectiveStartDate, ...) VALUES
(1, 'VAT_RATE', '0.08', '2025-01-01', ...),
-- ✅ CÓ settingId
```

---

### 9. **USE ptcmss;** - ❌ SAI DATABASE NAME

**Schema mới** (cuối file):
```sql
USE ptcmss;  -- ❌ SAI - phải là ptcmss_db
```

**Database hiện tại**:
```sql
USE ptcmss_db;  -- ✅ ĐÚNG
```

---

## ✅ CÁC BẢNG KHÁC - ĐỒNG BỘ

- Roles ✅
- Users ✅
- Branches ✅
- Employees ✅
- Drivers ✅
- DriverDayOff ✅
- Customers ✅
- VehicleCategoryPricing ✅
- HireTypes ✅
- Bookings ✅
- BookingVehicleDetails ✅
- Trips ✅
- TripVehicles (structure) ✅
- TripDrivers (structure) ✅
- Invoices (structure) ✅
- Notifications ✅
- AccountsReceivable (structure) ✅
- SystemSettings (structure) ✅

---

## 🔧 KHUYẾN NGHỊ

### Option 1: Sửa Schema mới (Khuyến nghị)
1. **Thêm columns vào Vehicles**:
   ```sql
   brand VARCHAR(100),
   insuranceExpiry DATE,
   odometer BIGINT,
   ```

2. **Sửa seed data TripVehicles**: Thêm `vehicleId` cho các dòng thiếu

3. **Sửa seed data TripDrivers**: Đổi một số `'Main Driver'` thành `'Support Driver'`

4. **Thêm ID vào các INSERT**: Thêm `dayOffId`, `invoiceId`, `arId`, `settingId` nếu muốn control IDs

5. **Sửa `USE ptcmss;`** thành `USE ptcmss_db;`

### Option 2: Giữ nguyên Database hiện tại
- Database hiện tại (`00_full_setup.sql`) đã đúng và đầy đủ hơn
- Entity Java đã map với database hiện tại
- Không cần thay đổi gì

---

## 📊 TỔNG KẾT

| Vấn đề | Database hiện tại | Schema mới | Trạng thái |
|--------|------------------|------------|------------|
| Vehicles columns | ✅ Đầy đủ (brand, insuranceExpiry, odometer) | ❌ Thiếu | **Database hiện tại tốt hơn** |
| SystemSettings | ✅ Đồng bộ | ✅ Đồng bộ | ✅ OK |
| TripVehicles seed | ✅ Đúng syntax | ❌ Lỗi syntax | **Database hiện tại tốt hơn** |
| TripDrivers seed | ✅ Logic đúng | ❌ Logic sai | **Database hiện tại tốt hơn** |
| USE database | ✅ ptcmss_db | ❌ ptcmss | **Database hiện tại tốt hơn** |

**KẾT LUẬN**: Database hiện tại (`00_full_setup.sql`) **TỐT HƠN** schema mới. Nên giữ nguyên database hiện tại.

