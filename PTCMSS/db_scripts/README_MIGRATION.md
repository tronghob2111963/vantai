# Hướng Dẫn Chạy Migration - Thêm Field Seats

## 🎯 Mục Đích
Thêm field `seats` (số ghế) vào bảng `vehicle_category_pricing` và populate data từ tên danh mục hiện có.

## 📋 Các Bước Thực Hiện

### Bước 1: Backup Database (Quan Trọng!)
```bash
# Sử dụng MySQL Workbench hoặc command line
mysqldump -u root -p ptcmss_db > backup_before_migration_$(date +%Y%m%d).sql
```

### Bước 2: Chạy Migration SQL

**Cách 1: Sử dụng MySQL Command Line**
```bash
mysql -u root -p1001 ptcmss_db < migration_add_seats_to_vehicle_category.sql
```

**Cách 2: Sử dụng MySQL Workbench**
1. Mở MySQL Workbench
2. Connect vào database `ptcmss_db`
3. File → Open SQL Script → Chọn file `migration_add_seats_to_vehicle_category.sql`
4. Nhấn Execute (⚡ icon)

**Cách 3: Copy-Paste Query**
```sql
USE ptcmss_db;

-- Add seats column
ALTER TABLE vehicle_category_pricing
ADD COLUMN seats INT NULL COMMENT 'Số ghế của danh mục xe'
AFTER categoryName;

-- Update data
UPDATE vehicle_category_pricing SET seats = 9 WHERE categoryId = 1;
UPDATE vehicle_category_pricing SET seats = 16 WHERE categoryId = 2;
UPDATE vehicle_category_pricing SET seats = 29 WHERE categoryId = 3;
UPDATE vehicle_category_pricing SET seats = 45 WHERE categoryId = 4;
UPDATE vehicle_category_pricing SET seats = 40 WHERE categoryId = 5;

-- Verify
SELECT categoryId, categoryName, seats, status
FROM vehicle_category_pricing
ORDER BY categoryId;
```

### Bước 3: Verify Migration
Kiểm tra kết quả:
```sql
SELECT categoryId, categoryName, seats, status
FROM vehicle_category_pricing;
```

**Kết quả mong đợi:**
```
+------------+-----------------------------+-------+--------+
| categoryId | categoryName                | seats | status |
+------------+-----------------------------+-------+--------+
|          1 | Xe 9 chỗ (Limousine)       |     9 | ACTIVE |
|          2 | Xe 16 chỗ                  |    16 | ACTIVE |
|          3 | Xe 29 chỗ                  |    29 | ACTIVE |
|          4 | Xe 45 chỗ                  |    45 | ACTIVE |
|          5 | Xe giường nằm (40 chỗ)     |    40 | ACTIVE |
+------------+-----------------------------+-------+--------+
```

### Bước 4: Restart Backend
```bash
cd d:\Project\vantai\PTCMSS\ptcmss-backend
mvn spring-boot:run
```

### Bước 5: Test API
```bash
# GET - Lấy danh sách danh mục
curl http://localhost:8080/api/vehicle-categories

# Kết quả mong đợi có thêm fields: seats và vehiclesCount
```

## ✅ Checklist

- [ ] Đã backup database
- [ ] Chạy migration SQL thành công
- [ ] Verify data đúng (5 danh mục có seats)
- [ ] Backend build thành công
- [ ] API trả về đúng seats và vehiclesCount
- [ ] Frontend hiển thị đúng thông tin

## 🔄 Rollback (Nếu Cần)

Nếu có vấn đề, chạy query sau để xóa column:
```sql
USE ptcmss_db;
ALTER TABLE vehicle_category_pricing DROP COLUMN seats;
```

Hoặc restore từ backup:
```bash
mysql -u root -p1001 ptcmss_db < backup_before_migration_YYYYMMDD.sql
```

## 📝 Notes

- Migration này an toàn vì column `seats` có thể NULL
- Hibernate sẽ tự động nhận field mới khi restart
- Frontend đã được update sẵn, chỉ cần backend trả đúng data
- Nếu tạo danh mục mới, cần nhập seats trong form

## 🐛 Troubleshooting

**Lỗi: Column already exists**
→ Migration đã chạy rồi, kiểm tra bằng:
```sql
DESCRIBE vehicle_category_pricing;
```

**Backend không compile**
→ Kiểm tra Maven build log, có thể cần clean:
```bash
mvn clean compile
```

**API không trả về seats/vehiclesCount**
→ Kiểm tra:
1. Backend đã restart chưa?
2. Database có column seats chưa?
3. Check console log có error không?
