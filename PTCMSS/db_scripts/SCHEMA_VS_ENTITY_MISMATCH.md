# 🔍 BÁO CÁO SO SÁNH SCHEMA vs ENTITY

## ❌ VẤN ĐỀ PHÁT HIỆN

### 1. **SystemSettings Table** - Thiếu fields trong Entity

**Database Schema** (`00_full_setup.sql` line 322-335):
```sql
CREATE TABLE IF NOT EXISTS SystemSettings (
  settingId INT AUTO_INCREMENT PRIMARY KEY,
  settingKey VARCHAR(100) NOT NULL UNIQUE,
  settingValue VARCHAR(255) NOT NULL,
  effectiveStartDate DATE NOT NULL,        -- ⚠️ THIẾU trong Entity
  effectiveEndDate DATE NULL,             -- ⚠️ THIẾU trong Entity
  valueType ENUM('string','int','decimal','boolean','json') DEFAULT 'string' NOT NULL,
  category VARCHAR(100),
  description VARCHAR(255),
  updatedBy INT NULL,
  updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Active','Inactive') DEFAULT 'Active',
  ...
)
```

**Entity Java** (`SystemSetting.java`):
- ✅ Có: `id`, `settingKey`, `settingValue`, `valueType`, `category`, `description`, `updatedBy`, `updatedAt`, `status`
- ❌ **THIẾU**: `effectiveStartDate` (DATE NOT NULL)
- ❌ **THIẾU**: `effectiveEndDate` (DATE NULL)

**Hậu quả**: 
- Khi INSERT/UPDATE SystemSetting, sẽ bị lỗi vì `effectiveStartDate` là NOT NULL
- Seed data trong SQL có `effectiveStartDate` nhưng entity không map được

---

### 2. **Vehicles Table** - Thiếu fields trong Database Schema

**Database Schema** (`00_full_setup.sql` line 140-153):
```sql
CREATE TABLE IF NOT EXISTS Vehicles (
  vehicleId INT AUTO_INCREMENT PRIMARY KEY,
  categoryId INT NOT NULL,
  branchId INT NOT NULL,
  licensePlate VARCHAR(20) NOT NULL UNIQUE,
  model VARCHAR(100),
  capacity INT,
  productionYear INT CHECK (productionYear >= 1980),
  registrationDate DATE,
  inspectionExpiry DATE,
  status ENUM('Available','InUse','Maintenance','Inactive') DEFAULT 'Available',
  ...
)
```

**Entity Java** (`Vehicles.java`):
- ✅ Có: `id`, `category`, `branch`, `licensePlate`, `model`, `capacity`, `productionYear`, `registrationDate`, `inspectionExpiry`, `status`
- ❌ **THIẾU trong DB**: `brand` (VARCHAR(100))
- ❌ **THIẾU trong DB**: `insuranceExpiry` (DATE)
- ❌ **THIẾU trong DB**: `odometer` (BIGINT)

**Hậu quả**:
- Khi INSERT/UPDATE Vehicles với `brand`, `insuranceExpiry`, `odometer` sẽ bị lỗi vì columns không tồn tại
- Code đang sử dụng các fields này nhưng database không có

---

## ✅ CÁC BẢNG KHÁC - ĐỒNG BỘ

### Drivers Table
- ✅ Database và Entity đồng bộ hoàn toàn
- ✅ Enum values đã được sửa: `Available`, `OnTrip`, `Inactive`

### Users Table
- ✅ Database và Entity đồng bộ

### Branches Table
- ✅ Database và Entity đồng bộ

---

## 🔧 GIẢI PHÁP

### Option 1: Sửa Database Schema (Khuyến nghị)
Thêm các columns thiếu vào `Vehicles` table trong `00_full_setup.sql`:

```sql
ALTER TABLE Vehicles 
  ADD COLUMN brand VARCHAR(100) AFTER model,
  ADD COLUMN insuranceExpiry DATE AFTER inspectionExpiry,
  ADD COLUMN odometer BIGINT AFTER insuranceExpiry;
```

### Option 2: Sửa Entity
Thêm `effectiveStartDate` và `effectiveEndDate` vào `SystemSetting` entity.

---

## 📋 KHUYẾN NGHỊ

1. **Ưu tiên sửa Database Schema** vì:
   - `effectiveStartDate` là NOT NULL trong DB → bắt buộc phải có
   - `brand`, `insuranceExpiry`, `odometer` đã được sử dụng trong code
   - Seed data đã có `effectiveStartDate`

2. **Sau đó cập nhật Entity** để map đầy đủ các fields

