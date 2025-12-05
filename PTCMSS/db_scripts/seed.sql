-- PTCMSS Seed Data - 3 branches, 10 employees each, and complete related data
-- Assumes schema already created. Uses INSERT IGNORE to avoid duplicate errors.

-- Roles
INSERT IGNORE INTO roles (roleId, roleName, description, status) VALUES
(1,'Admin','Quản trị viên hệ thống','ACTIVE'),
(2,'Manager','Quản lý chi nhánh','ACTIVE'),
(3,'Consultant','Tư vấn viên','ACTIVE'),
(4,'Driver','Tài xế','ACTIVE'),
(5,'Accountant','Kế toán','ACTIVE'),
(6,'Coordinator','Điều phối viên','ACTIVE');

-- Users (Admin + 30 employees mapped to roles)
INSERT IGNORE INTO users (userId, roleId, fullName, username, passwordHash, email, phone, status, email_verified, createdAt) VALUES
(1,1,'Admin Tổng','admin','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','admin@ptcmss.com','0900000001','ACTIVE',1,NOW()),
-- Branch 1 users (10)
(2,2,'Manager HN','manager_hn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','manager.hn@ptcmss.com','0900001001','ACTIVE',1,NOW()),
(3,3,'Consultant HN 1','consultant_hn1','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c1.hn@ptcmss.com','0900001002','ACTIVE',1,NOW()),
(4,3,'Consultant HN 2','consultant_hn2','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c2.hn@ptcmss.com','0900001003','ACTIVE',1,NOW()),
(5,5,'Accountant HN','accountant_hn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','acc.hn@ptcmss.com','0900001004','ACTIVE',1,NOW()),
(6,6,'Coordinator HN','coord_hn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','coord.hn@ptcmss.com','0900001005','ACTIVE',1,NOW()),
(7,4,'Tài xế HN A','driver_hn_a','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hn.a@ptcmss.com','0912345001','ACTIVE',1,NOW()),
(8,4,'Tài xế HN B','driver_hn_b','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hn.b@ptcmss.com','0912345002','ACTIVE',1,NOW()),
(9,4,'Tài xế HN C','driver_hn_c','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hn.c@ptcmss.com','0912345003','ACTIVE',1,NOW()),
(10,4,'Tài xế HN D','driver_hn_d','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hn.d@ptcmss.com','0912345004','ACTIVE',1,NOW()),
-- Branch 2 users (10)
(11,2,'Manager DN','manager_dn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','manager.dn@ptcmss.com','0900002001','ACTIVE',1,NOW()),
(12,3,'Consultant DN 1','consultant_dn1','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c1.dn@ptcmss.com','0900002002','ACTIVE',1,NOW()),
(13,3,'Consultant DN 2','consultant_dn2','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c2.dn@ptcmss.com','0900002003','ACTIVE',1,NOW()),
(14,5,'Accountant DN','accountant_dn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','acc.dn@ptcmss.com','0900002004','ACTIVE',1,NOW()),
(15,6,'Coordinator DN','coord_dn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','coord.dn@ptcmss.com','0900002005','ACTIVE',1,NOW()),
(16,4,'Tài xế DN A','driver_dn_a','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.dn.a@ptcmss.com','0912345101','ACTIVE',1,NOW()),
(17,4,'Tài xế DN B','driver_dn_b','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.dn.b@ptcmss.com','0912345102','ACTIVE',1,NOW()),
(18,4,'Tài xế DN C','driver_dn_c','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.dn.c@ptcmss.com','0912345103','ACTIVE',1,NOW()),
(19,4,'Tài xế DN D','driver_dn_d','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.dn.d@ptcmss.com','0912345104','ACTIVE',1,NOW()),
-- Branch 3 users (10)
(20,2,'Manager HCM','manager_hcm','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','manager.hcm@ptcmss.com','0900003001','ACTIVE',1,NOW()),
(21,3,'Consultant HCM 1','consultant_hcm1','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c1.hcm@ptcmss.com','0900003002','ACTIVE',1,NOW()),
(22,3,'Consultant HCM 2','consultant_hcm2','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c2.hcm@ptcmss.com','0900003003','ACTIVE',1,NOW()),
(23,5,'Accountant HCM','accountant_hcm','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','acc.hcm@ptcmss.com','0900003004','ACTIVE',1,NOW()),
(24,6,'Coordinator HCM','coord_hcm','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','coord.hcm@ptcmss.com','0900003005','ACTIVE',1,NOW()),
(25,4,'Tài xế HCM A','driver_hcm_a','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hcm.a@ptcmss.com','0912345201','ACTIVE',1,NOW()),
(26,4,'Tài xế HCM B','driver_hcm_b','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hcm.b@ptcmss.com','0912345202','ACTIVE',1,NOW()),
(27,4,'Tài xế HCM C','driver_hcm_c','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hcm.c@ptcmss.com','0912345203','ACTIVE',1,NOW()),
(28,4,'Tài xế HCM D','driver_hcm_d','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hcm.d@ptcmss.com','0912345204','ACTIVE',1,NOW());

-- Branches (4) - Insert with NULL managerId first to avoid circular FK dependency
INSERT IGNORE INTO branches (branchId, branchName, location, managerId, status, createdAt, phone) VALUES
(1,'Chi nhánh Hà Nội','123 Láng Hạ, Đống Đa, Hà Nội',NULL,'ACTIVE',NOW(),'024-1234567'),
(2,'Chi nhánh Đà Nẵng','456 Nguyễn Văn Linh, Hải Châu, Đà Nẵng',NULL,'ACTIVE',NOW(),'0236-123456'),
(3,'Chi nhánh TP. HCM','789 Võ Thị Sáu, Quận 3, TP. HCM',NULL,'ACTIVE',NOW(),'028-12345678'),
(4,'Chi nhánh Hải Phòng','10 Lê Hồng Phong, Ngô Quyền, Hải Phòng',NULL,'INACTIVE',NOW(),'0225-123456');

-- Employees (28: mỗi user có 1 employee record tương ứng)
INSERT INTO employees (employeeId, userId, branchId, roleId, status) VALUES
-- Admin (userId 1)
(1,1,1,1,'ACTIVE'),
-- Branch 1 users (userId 2-10, employeeId 2-10)
(2,2,1,2,'ACTIVE'),   -- Manager HN
(3,3,1,3,'ACTIVE'),   -- Consultant HN 1
(4,4,1,3,'ACTIVE'),   -- Consultant HN 2
(5,5,1,5,'ACTIVE'),   -- Accountant HN
(6,6,1,6,'ACTIVE'),   -- Coordinator HN
(7,7,1,4,'ACTIVE'),   -- Driver HN A
(8,8,1,4,'ACTIVE'),   -- Driver HN B
(9,9,1,4,'ACTIVE'),   -- Driver HN C
(10,10,1,4,'ACTIVE'), -- Driver HN D
-- Branch 2 users (userId 11-19, employeeId 11-19)
(11,11,2,2,'ACTIVE'), -- Manager DN
(12,12,2,3,'ACTIVE'), -- Consultant DN 1
(13,13,2,3,'ACTIVE'), -- Consultant DN 2
(14,14,2,5,'ACTIVE'), -- Accountant DN
(15,15,2,6,'ACTIVE'), -- Coordinator DN
(16,16,2,4,'ACTIVE'), -- Driver DN A
(17,17,2,4,'ACTIVE'), -- Driver DN B
(18,18,2,4,'ACTIVE'), -- Driver DN C
(19,19,2,4,'ACTIVE'), -- Driver DN D
-- Branch 3 users (userId 20-28, employeeId 20-28)
(20,20,3,2,'ACTIVE'), -- Manager HCM
(21,21,3,3,'ACTIVE'), -- Consultant HCM 1
(22,22,3,3,'ACTIVE'), -- Consultant HCM 2 (userId 22 → employeeId 22)
(23,23,3,5,'ACTIVE'), -- Accountant HCM
(24,24,3,6,'ACTIVE'), -- Coordinator HCM
(25,25,3,4,'ACTIVE'), -- Driver HCM A
(26,26,3,4,'ACTIVE'), -- Driver HCM B
(27,27,3,4,'ACTIVE'), -- Driver HCM C
(28,28,3,4,'ACTIVE')  -- Driver HCM D
ON DUPLICATE KEY UPDATE
    branchId = VALUES(branchId),
    roleId = VALUES(roleId),
    status = VALUES(status);

-- Update branch managers after employees are created (to avoid circular FK dependency)
UPDATE branches SET managerId = 2 WHERE branchId = 1;  -- Manager HN
UPDATE branches SET managerId = 11 WHERE branchId = 2; -- Manager DN
UPDATE branches SET managerId = 20 WHERE branchId = 3; -- Manager HCM


-- Hire Types
INSERT IGNORE INTO hire_types (hireTypeId, code, name, description, isActive) VALUES
(1,'ONE_WAY','Thuê 1 chiều','Thuê xe đi 1 chiều',1),
(2,'ROUND_TRIP','Thuê 2 chiều (trong ngày)','Thuê xe đi và về trong ngày',1),
(3,'MULTI_DAY','Thuê nhiều ngày','Thuê xe theo gói nhiều ngày',1),
(4,'PERIODIC','Thuê định kỳ','Thuê lặp lại (đưa đón nhân viên, học sinh)',1),
(5,'AIRPORT_TRANSFER','Đưa/đón sân bay','Gói đưa đón sân bay 1 chiều',1),
(6,'DAILY','Thuê theo ngày','Thuê xe trọn ngày',1);

-- Vehicle Category Pricing
-- Updated baseFare values (2025-12-06): Reduced to reasonable levels for short trips
-- Xe 9 chỗ: 900,000 → 200,000 (-78%)
-- Xe 16 chỗ: 1,100,000 → 400,000 (-64%)
-- Xe 29 chỗ: 1,800,000 → 600,000 (-67%)
-- Xe 45 chỗ: 2,500,000 → 800,000 (-68%)
-- Xe giường nằm: 3,000,000 → 1,000,000 (-67%)
INSERT IGNORE INTO vehicle_category_pricing (categoryId, categoryName, seats, description, baseFare, pricePerKm, highwayFee, fixedCosts, sameDayFixedPrice, isPremium, premiumSurcharge, effectiveDate, status, createdAt) VALUES
(1,'Xe 9 chỗ (Limousine)',9,'DCar/Solati Limousine',200000.00,15000.00,100000.00,0.00,NULL,0,0.00,CURDATE(),'ACTIVE',NOW()),
(2,'Xe 16 chỗ',16,'Ford Transit, Mercedes Sprinter',400000.00,30000.00,300000.00,0.00,2500000.00,0,0.00,CURDATE(),'ACTIVE',NOW()),
(3,'Xe 29 chỗ',29,'Hyundai County, Samco Isuzu',600000.00,40000.00,150000.00,0.00,3000000.00,0,0.00,CURDATE(),'ACTIVE',NOW()),
(4,'Xe 45 chỗ',45,'Hyundai Universe',800000.00,50000.00,200000.00,0.00,NULL,0,0.00,CURDATE(),'ACTIVE',NOW()),
(5,'Xe giường nằm (40 chỗ)',40,'Xe giường nằm Thaco/Hyundai',1000000.00,30000.00,250000.00,0.00,NULL,0,0.00,CURDATE(),'ACTIVE',NOW());

-- Vehicles (9 total, 3 per branch)
INSERT IGNORE INTO vehicles (vehicleId, categoryId, branchId, licensePlate, model, brand, capacity, productionYear, registrationDate, inspectionExpiry, insuranceExpiry, odometer, status) VALUES
(1,1,1,'29A-111.11','DCar Limousine','DCar',9,2023,'2023-01-01','2026-01-01','2029-01-01',15000,'AVAILABLE'),
(2,2,1,'29A-222.22','Ford Transit','Ford',16,2022,'2022-01-01','2026-01-01','2029-01-01',32000,'AVAILABLE'),
(3,3,1,'29A-333.33','Samco Isuzu','Samco',29,2021,'2021-01-01','2026-01-01','2029-01-01',58000,'AVAILABLE'),
(4,1,2,'43A-111.11','DCar Limousine','DCar',9,2023,'2023-02-01','2026-02-01','2029-02-01',14000,'AVAILABLE'),
(5,2,2,'43B-222.22','Ford Transit','Ford',16,2022,'2022-02-01','2026-02-01','2029-02-01',40000,'INUSE'),
(6,4,2,'43C-333.33','Hyundai Universe','Hyundai',45,2021,'2021-02-01','2026-02-01','2029-02-01',90000,'AVAILABLE'),
(7,1,3,'51A-111.11','DCar Limousine','DCar',9,2023,'2023-03-01','2026-03-01','2029-03-01',13000,'AVAILABLE'),
(8,3,3,'51B-222.22','Hyundai County','Hyundai',29,2022,'2022-03-01','2026-03-01','2029-03-01',61000,'AVAILABLE'),
(9,5,3,'51C-333.33','Thaco Mobihome','Thaco',40,2021,'2021-03-01','2026-03-01','2029-03-01',120000,'MAINTENANCE');

-- Drivers (11: 4 HN, 4 DN, 3 HCM - vì chỉ có 28 users/employees)
-- Note: HCM chỉ có 3 driver vì userId 25-28 là 4 driver nhưng employeeId 25 là Driver HCM A
INSERT IGNORE INTO drivers (driverId, employeeId, branchId, licenseNumber, licenseClass, licenseExpiry, healthCheckDate, rating, priorityLevel, note, status, createdAt) VALUES
(1,7,1,'HN-D001','D','2028-12-31','2025-06-01',4.80,1,NULL,'AVAILABLE',NOW()),
(2,8,1,'HN-D002','E','2027-11-30','2025-07-01',4.90,2,NULL,'AVAILABLE',NOW()),
(3,9,1,'HN-D003','D','2029-01-15','2025-08-01',5.00,1,NULL,'ON_TRIP',NOW()),
(4,10,1,'HN-D004','E','2026-05-20','2025-03-01',4.70,3,NULL,'AVAILABLE',NOW()),
(5,16,2,'DN-D001','D','2028-10-10','2025-05-01',4.85,1,NULL,'AVAILABLE',NOW()),
(6,17,2,'DN-D002','E','2027-09-09','2025-04-01',4.75,2,NULL,'INACTIVE',NOW()),
(7,18,2,'DN-D003','D','2029-07-07','2025-10-01',4.95,1,NULL,'AVAILABLE',NOW()),
(8,19,2,'DN-D004','E','2026-04-04','2025-02-01',4.60,3,NULL,'AVAILABLE',NOW()),
(9,25,3,'HCM-D001','D','2028-12-12','2025-06-15',4.88,1,NULL,'AVAILABLE',NOW()),
(10,26,3,'HCM-D002','E','2027-10-10','2025-07-10',4.92,2,NULL,'AVAILABLE',NOW()),
(11,27,3,'HCM-D003','D','2029-08-08','2025-08-20',4.66,3,NULL,'ON_TRIP',NOW()),
(12,28,3,'HCM-D004','E','2026-06-06','2025-03-10',4.74,2,NULL,'AVAILABLE',NOW());

-- Customers (6)
INSERT IGNORE INTO customers (customerId, fullName, phone, email, address, note, createdAt, createdBy, status) VALUES
(1,'Công ty TNHH ABC','0987654321','contact@abc.com','Hà Nội',NULL,NOW(),3,'ACTIVE'),
(2,'Đoàn du lịch Hướng Việt','0987654322','info@huongviet.vn','TP. HCM',NULL,NOW(),22,'ACTIVE'),
(3,'Công ty CP XYZ','0987654323','hr@xyz.com','Đà Nẵng',NULL,NOW(),12,'ACTIVE'),
(4,'Gia đình ông Nguyễn','0987654324','nguyen.family@gmail.com','Hà Nội',NULL,NOW(),3,'ACTIVE'),
(5,'Trường quốc tế Vinschool','0987654325','school@vinschool.edu.vn','Hà Nội',NULL,NOW(),3,'ACTIVE'),
(6,'Công ty Du lịch Mặt Trời','0987000123','tour@suntravel.vn','TP. HCM',NULL,NOW(),21,'ACTIVE');

-- Bookings (9)
INSERT IGNORE INTO bookings (bookingId, customerId, branchId, consultantId, hireTypeId, useHighway, bookingDate, estimatedCost, depositAmount, totalCost, totalDistance, totalDuration, status, note, createdAt, updatedAt, isHoliday, isWeekend) VALUES
(1,1,1,3,1,1,NOW(),1200000.00,600000.00,1200000.00,120.50,180,'COMPLETED','HN-HP 1 chiều',NOW(),NOW(),0,0),
(2,2,3,21,2,0,NOW(),3000000.00,1500000.00,3000000.00,95.00,120,'CONFIRMED','HCM-NB 2 chiều',NOW(),NOW(),0,0),
(3,3,2,12,5,1,NOW(),1800000.00,900000.00,1800000.00,35.00,60,'PENDING','Đưa đón sân bay',NOW(),NOW(),0,1),
(4,4,1,4,4,0,NOW(),25000000.00,10000000.00,25000000.00,300.00,480,'INPROGRESS','Hợp đồng định kỳ',NOW(),NOW(),0,0),
(5,5,1,3,6,1,NOW(),3500000.00,1750000.00,3500000.00,120.00,480,'CONFIRMED','Thuê theo ngày',NOW(),NOW(),1,0),
(6,6,3,22,3,1,NOW(),15000000.00,5000000.00,15000000.00,500.00,1440,'PENDING','Tour miền Tây 3N2Đ',NOW(),NOW(),0,0),
(7,1,1,3,2,1,NOW(),2200000.00,1000000.00,2200000.00,180.00,240,'CANCELLED','HN-NB 2 chiều',NOW(),NOW(),0,0),
(8,2,3,21,1,0,NOW(),900000.00,450000.00,900000.00,20.00,40,'CONFIRMED','Trong nội thành',NOW(),NOW(),0,1),
(9,3,2,13,5,1,NOW(),1200000.00,600000.00,1200000.00,40.00,60,'COMPLETED','Đón sân bay',NOW(),NOW(),0,0);

-- Booking Vehicle Details (chi tiết loại xe cho mỗi booking)
-- Schema: booking_vehicle_details(bookingId, vehicleCategoryId, quantity)
INSERT IGNORE INTO booking_vehicle_details (bookingId, vehicleCategoryId, quantity) VALUES
(1,3,1),  -- Booking 1: 1 xe 29 chỗ
(2,2,1),  -- Booking 2: 1 xe 16 chỗ
(3,1,1),  -- Booking 3: 1 xe 9 chỗ Limousine
(4,4,2),  -- Booking 4: 2 xe 45 chỗ (hợp đồng định kỳ)
(5,3,1),  -- Booking 5: 1 xe 29 chỗ
(6,5,1),  -- Booking 6: 1 xe giường nằm (tour)
(7,2,1),  -- Booking 7: 1 xe 16 chỗ
(8,1,1),  -- Booking 8: 1 xe 9 chỗ Limousine
(9,1,1);  -- Booking 9: 1 xe 9 chỗ Limousine

-- Trips (12)
INSERT IGNORE INTO trips (tripId, bookingId, useHighway, startTime, endTime, startLocation, endLocation, distance, startLatitude, startLongitude, endLatitude, endLongitude, estimatedDuration, actualDuration, routeData, trafficStatus, incidentalCosts, status) VALUES
(1,1,1,DATE_SUB(NOW(),INTERVAL 10 DAY),DATE_SUB(NOW(),INTERVAL 10 DAY),'Hoàn Kiếm, Hà Nội','Hải Phòng',120.50,NULL,NULL,NULL,NULL,180,175,NULL,'MODERATE',0.00,'COMPLETED'),
(2,2,0,NOW(),NULL,'Quận 1, TP. HCM','Ninh Bình',95.00,NULL,NULL,NULL,NULL,120,NULL,NULL,'LIGHT',0.00,'ASSIGNED'),
(3,3,1,DATE_SUB(NOW(),INTERVAL 2 DAY),DATE_SUB(NOW(),INTERVAL 2 DAY),'Sân bay Đà Nẵng','Trung tâm TP ĐN',35.00,NULL,NULL,NULL,NULL,60,58,NULL,'LIGHT',0.00,'COMPLETED'),
(4,4,0,NOW(),NULL,'KCN Thăng Long','Nội thành Hà Nội',30.00,NULL,NULL,NULL,NULL,60,NULL,NULL,'HEAVY',0.00,'ONGOING'),
(5,5,1,DATE_SUB(NOW(),INTERVAL 1 DAY),NULL,'Times City, Hà Nội','Sân bay Nội Bài',45.00,NULL,NULL,NULL,NULL,90,NULL,NULL,'MODERATE',0.00,'ASSIGNED'),
(6,6,1,NOW(),NULL,'Quận 10, TP. HCM','Cần Thơ',180.00,NULL,NULL,NULL,NULL,240,NULL,NULL,'UNKNOWN',0.00,'SCHEDULED'),
(7,7,1,DATE_SUB(NOW(),INTERVAL 5 DAY),DATE_SUB(NOW(),INTERVAL 5 DAY),'Hà Nội','Ninh Bình',180.00,NULL,NULL,NULL,NULL,240,250,NULL,'LIGHT',0.00,'CANCELLED'),
(8,8,0,NOW(),NULL,'Quận 7, TP. HCM','Quận 1, TP. HCM',20.00,NULL,NULL,NULL,NULL,40,NULL,NULL,'LIGHT',0.00,'ASSIGNED'),
(9,9,1,DATE_SUB(NOW(),INTERVAL 3 DAY),DATE_SUB(NOW(),INTERVAL 3 DAY),'Sân bay Đà Nẵng','Hải Châu, Đà Nẵng',40.00,NULL,NULL,NULL,NULL,60,62,NULL,'MODERATE',0.00,'COMPLETED'),
(10,2,1,NOW(),NULL,'TP. HCM','Ninh Bình',95.00,NULL,NULL,NULL,NULL,120,NULL,NULL,'MODERATE',0.00,'SCHEDULED'),
(11,6,1,NOW(),NULL,'Cần Thơ','Bến Tre',160.00,NULL,NULL,NULL,NULL,210,NULL,NULL,'UNKNOWN',0.00,'SCHEDULED'),
(12,5,1,DATE_SUB(NOW(),INTERVAL 1 DAY),NULL,'Hà Nội','Vĩnh Phúc',75.00,NULL,NULL,NULL,NULL,120,NULL,NULL,'LIGHT',0.00,'ASSIGNED');

-- Trip Drivers
INSERT IGNORE INTO trip_drivers (tripId, driverId, driverRole, startTime, endTime, note) VALUES
(1,1,'Main Driver',NULL,NULL,'HN A chạy Trip #1'),
(2,9,'Main Driver',NULL,NULL,'HCM A chạy Trip #2'),
(3,5,'Main Driver',NULL,NULL,'DN A chạy Trip #3'),
(4,2,'Main Driver',NULL,NULL,'HN B chạy Trip #4'),
(5,1,'Main Driver',NULL,NULL,'HN A chạy Trip #5'),
(6,10,'Main Driver',NULL,NULL,'HCM B chạy Trip #6'),
(7,3,'Main Driver',NULL,NULL,'HN C chạy Trip #7'),
(8,11,'Main Driver',NULL,NULL,'HCM C chạy Trip #8'),
(9,7,'Main Driver',NULL,NULL,'DN C chạy Trip #9'),
(10,12,'Main Driver',NULL,NULL,'HCM D chạy Trip #10'),
(11,8,'Main Driver',NULL,NULL,'DN D chạy Trip #11'),
(12,4,'Main Driver',NULL,NULL,'HN D chạy Trip #12');

-- Trip Vehicles
INSERT IGNORE INTO trip_vehicles (tripVehicleId, tripId, vehicleId, assignedAt, note) VALUES
(1,1,2,NOW(),'Gán Transit cho Trip #1'),
(2,2,7,NOW(),'Gán Limousine HCM cho Trip #2'),
(3,3,4,NOW(),'Gán Limousine DN cho Trip #3'),
(4,4,3,NOW(),'Gán Samco cho Trip #4'),
(5,5,1,NOW(),'Gán DCar cho Trip #5'),
(6,6,9,NOW(),'Gán Mobihome cho Trip #6'),
(7,7,2,NOW(),'Gán Transit cho Trip #7'),
(8,8,8,NOW(),'Gán County cho Trip #8'),
(9,9,5,NOW(),'Gán Transit DN cho Trip #9'),
(10,10,7,NOW(),'Gán Limousine HCM cho Trip #10'),
(11,11,6,NOW(),'Gán Universe cho Trip #11'),
(12,12,1,NOW(),'Gán DCar cho Trip #12');

-- Driver Day Off
INSERT IGNORE INTO driver_day_off (dayOffId, driverId, startDate, endDate, reason, approvedBy, status, createdAt) VALUES
(1,1,DATE_SUB(CURDATE(),INTERVAL 15 DAY),DATE_SUB(CURDATE(),INTERVAL 14 DAY),'Việc gia đình',2,'APPROVED',NOW()),
(2,5,DATE_SUB(CURDATE(),INTERVAL 10 DAY),DATE_SUB(CURDATE(),INTERVAL 9 DAY),'Khám sức khỏe',11,'APPROVED',NOW()),
(3,9,DATE_SUB(CURDATE(),INTERVAL 5 DAY),DATE_SUB(CURDATE(),INTERVAL 5 DAY),'Nghỉ ốm',21,'REJECTED',NOW());

-- Driver Ratings
INSERT IGNORE INTO driver_ratings (ratingId, attitudeRating, comment, complianceRating, overallRating, punctualityRating, ratedAt, safetyRating, customerId, driverId, ratedBy, tripId) VALUES
(1,5,'Lái xe an toàn, đúng giờ',5,4.80,5,NOW(),5,1,1,1,1),
(2,4,'Phục vụ tốt',4,4.50,4,NOW(),4,2,9,20,2);

-- System Settings (19 settings đầy đủ)
INSERT IGNORE INTO system_settings (settingId, settingKey, settingValue, effectiveStartDate, effectiveEndDate, valueType, category, description, updatedBy, updatedAt, status) VALUES
-- Billing Settings
(1,'VAT_RATE','0.08','2025-01-01',NULL,'decimal','Billing','Tỷ lệ VAT 8%',1,NOW(),'ACTIVE'),
(5,'DEFAULT_DEPOSIT_PERCENT','0.50','2025-01-01',NULL,'decimal','Billing','Tỷ lệ đặt cọc mặc định (50% tổng tiền)',1,NOW(),'ACTIVE'),

-- Booking Settings
(2,'DEFAULT_HIGHWAY','true','2025-01-01',NULL,'boolean','Booking','Mặc định cao tốc',1,NOW(),'ACTIVE'),
(6,'CANCELLATION_FULL_DEPOSIT_LOSS_HOURS','24','2025-01-01',NULL,'int','Booking','Số giờ trước khi bắt đầu để mất toàn bộ tiền cọc',1,NOW(),'ACTIVE'),
(7,'CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS','48','2025-01-01',NULL,'int','Booking','Số giờ trước khi bắt đầu để mất một phần tiền cọc',1,NOW(),'ACTIVE'),
(8,'CANCELLATION_PARTIAL_DEPOSIT_PERCENT','0.30','2025-01-01',NULL,'decimal','Booking','Tỷ lệ mất cọc khi hủy trong khoảng thời gian (30%)',1,NOW(),'ACTIVE'),
(9,'BOOKING_MAJOR_MODIFICATION_MIN_HOURS','72','2025-01-01',NULL,'int','Booking','Số giờ tối thiểu trước khi bắt đầu để sửa đổi lớn (72h = 3 ngày)',1,NOW(),'ACTIVE'),
(10,'BOOKING_MINOR_MODIFICATION_MIN_HOURS','24','2025-01-01',NULL,'int','Booking','Số giờ tối thiểu trước khi bắt đầu để sửa đổi nhỏ (24h = 1 ngày)',1,NOW(),'ACTIVE'),
(11,'SAME_DAY_TRIP_START_HOUR','6','2025-01-01',NULL,'int','Booking','Giờ bắt đầu để tính chuyến trong ngày (6h sáng)',1,NOW(),'ACTIVE'),
(12,'SAME_DAY_TRIP_END_HOUR','23','2025-01-01',NULL,'int','Booking','Giờ kết thúc để tính chuyến trong ngày (23h tối)',1,NOW(),'ACTIVE'),

-- Pricing Settings
(4,'ROUND_TRIP_MULTIPLIER','1.5','2025-01-01',NULL,'decimal','Pricing','Hệ số 2 chiều',1,NOW(),'ACTIVE'),
(13,'HOLIDAY_SURCHARGE_RATE','0.25','2025-01-01',NULL,'decimal','Pricing','Phụ thu ngày lễ (25%)',1,NOW(),'ACTIVE'),
(14,'WEEKEND_SURCHARGE_RATE','0.20','2025-01-01',NULL,'decimal','Pricing','Phụ thu cuối tuần (20%)',1,NOW(),'ACTIVE'),
(15,'INTER_PROVINCE_DISTANCE_KM','100','2025-01-01',NULL,'int','Pricing','Khoảng cách tối thiểu để tính liên tỉnh (km)',1,NOW(),'ACTIVE'),

-- Driver Settings
(3,'MAX_DRIVING_HOURS_PER_DAY','10','2025-01-01',NULL,'int','Driver','Tối đa giờ lái/ngày',1,NOW(),'ACTIVE'),
(16,'MAX_CONTINUOUS_DRIVING_HOURS','4','2025-01-01',NULL,'int','Driver','Tối đa giờ lái liên tục (4 giờ)',1,NOW(),'ACTIVE'),
(17,'MAX_DRIVING_HOURS_PER_WEEK','48','2025-01-01',NULL,'int','Driver','Tối đa giờ lái/tuần (48 giờ)',1,NOW(),'ACTIVE'),
(18,'MAX_DRIVER_LEAVE_DAYS','2','2025-01-01',NULL,'int','Driver','Số ngày nghỉ tối đa tài xế có thể xin (2 ngày)',1,NOW(),'ACTIVE'),
(19,'SINGLE_DRIVER_MAX_DISTANCE_KM','300','2025-01-01',NULL,'int','Driver','Khoảng cách tối đa cho 1 tài xế (300km)',1,NOW(),'ACTIVE');

-- App Settings (for VietQR)
INSERT IGNORE INTO app_settings (id, description, setting_key, updated_at, updated_by, setting_value) VALUES
(1,'Tiền tố nội dung chuyển khoản','qr.description_prefix',NOW(),'admin','VANTAI'),
(2,'Mã ngân hàng theo chuẩn VietQR','qr.bank_code',NOW(),'admin','970403'),
(3,'Tên chủ tài khoản','qr.account_name',NOW(),'admin','CONG TY VANTAI'),
(4,'Số tài khoản ngân hàng','qr.account_number',NOW(),'admin','070122047995');

-- Approval History
INSERT IGNORE INTO approval_history (historyId, approvalNote, approvalType, processedAt, relatedEntityId, requestReason, requestedAt, status, approvedBy, branchId, requestedBy) VALUES
(1,'Đồng ý','DRIVER_DAY_OFF',NOW(),1,'Việc gia đình',DATE_SUB(NOW(),INTERVAL 16 DAY),'APPROVED',2,1,7),
(2,'Đồng ý','DRIVER_DAY_OFF',NOW(),2,'Khám sức khỏe',DATE_SUB(NOW(),INTERVAL 11 DAY),'APPROVED',11,2,5),
(3,'Từ chối','DRIVER_DAY_OFF',NOW(),3,'Nghỉ ốm',DATE_SUB(NOW(),INTERVAL 6 DAY),'REJECTED',21,3,9);

-- Expenses (empty but present)
-- Example expenses
INSERT IGNORE INTO expenses (expenseId, expenseCode, branchId, vehicleId, driverId, tripId, bookingId, expenseType, category, amount, description, receiptUrl, status, approvedBy, approvedAt, rejectedReason, paidAt, expenseDate, note, createdBy, createdAt, updatedAt) VALUES
(1,'EXP-2025-0001',1,2,1,1,1,'FUEL','FUEL',1000000.00,'Đổ dầu','/receipts/exp1.jpg','APPROVED',2,NOW(),NULL,NOW(),DATE_SUB(NOW(),INTERVAL 10 DAY),'',1,NOW(),NOW()),
(2,'EXP-2025-0002',3,8,11,8,8,'TOLL','TOLL',150000.00,'Phí cao tốc','/receipts/exp2.jpg','PAID',21,NOW(),NULL,NOW(),DATE_SUB(NOW(),INTERVAL 1 DAY),'',21,NOW(),NOW());

-- Expense Requests
INSERT IGNORE INTO expense_requests (expenseRequestId, amount, approvedAt, createdAt, note, rejectionReason, status, expenseType, updatedAt, approvedBy, branchId, requesterId, vehicleId) VALUES
(1,750000.00,NOW(),DATE_SUB(NOW(),INTERVAL 2 DAY),'Xin tạm ứng phí ETC',NULL,'APPROVED','TOLL',NOW(),2,1,2,2),
(2,2500000.00,NULL,NOW(),'Tạm ứng bảo dưỡng',NULL,'PENDING','MAINTENANCE',NULL,NULL,3,11,5);

-- Notifications
INSERT IGNORE INTO notifications (notificationId, userId, title, message, createdAt, isRead) VALUES
(1,2,'Yêu cầu nghỉ phép','Tài xế HN A vừa tạo yêu cầu nghỉ phép.',NOW(),0),
(2,21,'Booking đã xác nhận','Booking #2 đã được xác nhận.',NOW(),0);

-- Invoices (12)
-- Chỉ sử dụng các field có trong schema, loại bỏ: paymentMethod, bankAccount, bankName, cashierName, receiptNumber, referenceNumber
INSERT IGNORE INTO invoices (invoiceId, branchId, bookingId, customerId, type, costType, isDeposit, amount, paymentStatus, status, invoiceDate, createdAt, img, note, requestedBy, createdBy, approvedBy, approvedAt, cancellationReason, cancelledAt, contactNote, debtLabel, dueDate, invoiceNumber, paymentTerms, promiseToPayDate, sentAt, sentToEmail, subtotal, vatAmount, cancelledBy) VALUES
(1,1,1,1,'INCOME',NULL,1,600000.00,'PAID','ACTIVE',DATE_SUB(NOW(),INTERVAL 10 DAY),NOW(),NULL,'Đặt cọc Booking 1',NULL,3,2,NOW(),NULL,NULL,NULL,'NORMAL',DATE_ADD(CURDATE(),INTERVAL 7 DAY),'INV-HN-2025-0001','NET_7',NULL,NOW(),'contact@abc.com',NULL,0.00,NULL),
(2,1,1,1,'INCOME',NULL,0,600000.00,'PAID','ACTIVE',DATE_SUB(NOW(),INTERVAL 9 DAY),NOW(),NULL,'Thu nốt Booking 1',NULL,3,2,NOW(),NULL,NULL,NULL,NULL,DATE_ADD(CURDATE(),INTERVAL 0 DAY),'INV-HN-2025-0002','NET_0',NULL,NOW(),'contact@abc.com',NULL,0.00,NULL),
(3,3,2,2,'INCOME',NULL,1,1500000.00,'PAID','ACTIVE',DATE_SUB(NOW(),INTERVAL 1 DAY),NOW(),NULL,'Cọc Booking 2',NULL,21,23,NOW(),NULL,NULL,NULL,'NORMAL',DATE_ADD(CURDATE(),INTERVAL 7 DAY),'INV-HCM-2025-0001','NET_7',NULL,NOW(),'info@huongviet.vn',NULL,0.00,NULL),
(4,3,2,2,'INCOME',NULL,0,1500000.00,'UNPAID','ACTIVE',NOW(),NOW(),NULL,'Thu nốt Booking 2',NULL,21,NULL,NULL,NULL,NULL,NULL,'OVERDUE',DATE_ADD(CURDATE(),INTERVAL 7 DAY),'INV-HCM-2025-0002','NET_7',NULL,NULL,'info@huongviet.vn',NULL,0.00,NULL),
(5,2,3,3,'INCOME',NULL,1,900000.00,'PAID','ACTIVE',DATE_SUB(NOW(),INTERVAL 2 DAY),NOW(),NULL,'Cọc Booking 3',NULL,12,14,NOW(),NULL,NULL,NULL,NULL,DATE_ADD(CURDATE(),INTERVAL 7 DAY),'INV-DN-2025-0001','NET_7',NULL,NULL,'hr@xyz.com',NULL,0.00,NULL),
(6,2,3,3,'INCOME',NULL,0,900000.00,'UNPAID','ACTIVE',NOW(),NOW(),NULL,'Thu nốt Booking 3',NULL,12,NULL,NULL,NULL,NULL,NULL,'NORMAL',DATE_ADD(CURDATE(),INTERVAL 7 DAY),'INV-DN-2025-0002','NET_7',NULL,NULL,'hr@xyz.com',NULL,0.00,NULL),
(7,1,4,4,'INCOME',NULL,1,10000000.00,'PAID','ACTIVE',DATE_SUB(NOW(),INTERVAL 3 DAY),NOW(),NULL,'Cọc Booking 4',NULL,4,5,NOW(),NULL,NULL,NULL,'NORMAL',DATE_ADD(CURDATE(),INTERVAL 14 DAY),'INV-HN-2025-0003','NET_14',NULL,NULL,'nguyen.family@gmail.com',NULL,0.00,NULL),
(8,1,4,4,'INCOME',NULL,0,15000000.00,'UNPAID','ACTIVE',NOW(),NOW(),NULL,'Thu nốt Booking 4',NULL,4,NULL,NULL,NULL,NULL,NULL,'NORMAL',DATE_ADD(CURDATE(),INTERVAL 14 DAY),'INV-HN-2025-0004','NET_14',NULL,NULL,'nguyen.family@gmail.com',NULL,0.00,NULL),
(9,1,5,5,'INCOME',NULL,1,1750000.00,'PAID','ACTIVE',DATE_SUB(NOW(),INTERVAL 1 DAY),NOW(),NULL,'Cọc Booking 5',NULL,3,5,NOW(),NULL,NULL,NULL,'NORMAL',DATE_ADD(CURDATE(),INTERVAL 7 DAY),'INV-HN-2025-0005','NET_7',NULL,NULL,'school@vinschool.edu.vn',NULL,0.00,NULL),
(10,3,6,6,'INCOME',NULL,1,5000000.00,'PAID','ACTIVE',NOW(),NOW(),NULL,'Cọc Booking 6',NULL,22,23,NOW(),NULL,NULL,NULL,'NORMAL',DATE_ADD(CURDATE(),INTERVAL 7 DAY),'INV-HCM-2025-0003','NET_7',NULL,NOW(),'tour@suntravel.vn',NULL,0.00,NULL),
(11,3,6,6,'INCOME',NULL,0,10000000.00,'UNPAID','ACTIVE',NOW(),NOW(),NULL,'Thu nốt Booking 6',NULL,22,NULL,NULL,NULL,NULL,NULL,'OVERDUE',DATE_ADD(CURDATE(),INTERVAL 7 DAY),'INV-HCM-2025-0004','NET_7',NULL,NULL,'tour@suntravel.vn',NULL,0.00,NULL),
(12,2,9,3,'INCOME',NULL,0,600000.00,'PAID','ACTIVE',DATE_SUB(NOW(),INTERVAL 3 DAY),NOW(),NULL,'Thanh toán Booking 9',NULL,13,14,NOW(),NULL,NULL,NULL,'NORMAL',DATE_ADD(CURDATE(),INTERVAL 7 DAY),'INV-DN-2025-0003','NET_7',NULL,NULL,'hr@xyz.com',NULL,0.00,NULL);

-- Invoice Items
INSERT IGNORE INTO invoice_items (itemId, invoiceId, description, quantity, unitPrice, taxRate, taxAmount, note, createdAt, updatedAt) VALUES
(1,1,'Vận chuyển HN-HP (đặt cọc)',1.00,600000.00,8.00,48000.00,NULL,NOW(),NOW()),
(2,2,'Vận chuyển HN-HP (thu nốt)',1.00,600000.00,8.00,48000.00,NULL,NOW(),NOW()),
(3,3,'Vận chuyển HCM-NB (cọc)',1.00,1500000.00,8.00,120000.00,NULL,NOW(),NOW()),
(4,4,'Vận chuyển HCM-NB (thu nốt)',1.00,1500000.00,8.00,120000.00,NULL,NOW(),NOW()),
(5,5,'Đưa/đón sân bay (cọc)',1.00,900000.00,8.00,72000.00,NULL,NOW(),NOW()),
(6,6,'Đưa/đón sân bay (thu nốt)',1.00,900000.00,8.00,72000.00,NULL,NOW(),NOW()),
(7,7,'Hợp đồng định kỳ (cọc)',1.00,10000000.00,8.00,800000.00,NULL,NOW(),NOW()),
(8,8,'Hợp đồng định kỳ (thu nốt)',1.00,15000000.00,8.00,1200000.00,NULL,NOW(),NOW()),
(9,9,'Thuê theo ngày (cọc)',1.00,1750000.00,8.00,140000.00,NULL,NOW(),NOW()),
(10,10,'Tour miền Tây (cọc)',1.00,5000000.00,8.00,400000.00,NULL,NOW(),NOW()),
(11,11,'Tour miền Tây (thu nốt)',1.00,10000000.00,8.00,800000.00,NULL,NOW(),NOW()),
(12,12,'Đón sân bay',1.00,600000.00,8.00,48000.00,NULL,NOW(),NOW());
    
-- Payment History
INSERT IGNORE INTO payment_history (paymentId, amount, bankAccount, bankName, cashierName, createdAt, note, paymentDate, paymentMethod, receiptNumber, referenceNumber, createdBy, invoiceId, confirmationStatus) VALUES
(1,600000.00,'070122047995','Sacombank','Kế toán HN',NOW(),'Cọc Booking 1',DATE_SUB(NOW(),INTERVAL 10 DAY),'BANK_TRANSFER','REC-2025-0001',NULL,5,1,'CONFIRMED'),
(2,600000.00,NULL,NULL,'Kế toán HN',NOW(),'Thu nốt Booking 1',DATE_SUB(NOW(),INTERVAL 9 DAY),'CASH','REC-2025-0002',NULL,5,2,'CONFIRMED'),
(3,1500000.00,'070122047995','Sacombank','Kế toán HCM',NOW(),'Cọc Booking 2',DATE_SUB(NOW(),INTERVAL 1 DAY),'QR','REC-2025-0003',NULL,23,3,'CONFIRMED'),
(4,900000.00,NULL,NULL,'Kế toán DN',NOW(),'Cọc Booking 3',DATE_SUB(NOW(),INTERVAL 2 DAY),'CASH','REC-2025-0004',NULL,14,5,'CONFIRMED'),
(5,1750000.00,NULL,NULL,'Kế toán HN',NOW(),'Cọc Booking 5',DATE_SUB(NOW(),INTERVAL 1 DAY),'QR','REC-2025-0005',NULL,5,9,'CONFIRMED'),
(6,5000000.00,NULL,NULL,'Kế toán HCM',NOW(),'Cọc Booking 6',NOW(),'QR','REC-2025-0006',NULL,23,10,'CONFIRMED'),
(7,600000.00,NULL,NULL,'Kế toán DN',NOW(),'Thanh toán Booking 9',DATE_SUB(NOW(),INTERVAL 3 DAY),'CASH','REC-2025-0007',NULL,14,12,'CONFIRMED');

-- System Alerts
INSERT IGNORE INTO system_alerts (alertId, acknowledgedAt, alertType, createdAt, expiresAt, isAcknowledged, message, relatedEntityId, relatedEntityType, severity, title, acknowledgedBy, branchId) VALUES
(1,NOW(),'VEHICLE_INSPECTION_EXPIRING',NOW(),DATE_ADD(NOW(),INTERVAL 90 DAY),b'1','Xe 51C-333.33 sắp hết hạn đăng kiểm',9,'VEHICLE','HIGH','Xe sắp hết hạn đăng kiểm',20,3),
(2,NULL,'DRIVER_LICENSE_EXPIRING',NOW(),DATE_ADD(NOW(),INTERVAL 60 DAY),b'0','Bằng lái HN-D004 sắp hết hạn',4,'DRIVER','MEDIUM','Bằng lái sắp hết hạn',NULL,1);

-- Debt Reminder History (linked to unpaid invoice #4)
INSERT IGNORE INTO debt_reminder_history (reminderId, invoiceId, reminderDate, reminderType, recipient, message, sentBy, createdAt) VALUES
(1,4,NOW(),'EMAIL','info@huongviet.vn','Nhắc thanh toán hóa đơn INV-HCM-2025-0002',1,NOW());

-- Trip Incidents
INSERT IGNORE INTO trip_incidents (incidentId, createdAt, description, resolved, severity, driverId, tripId) VALUES
(1,NOW(),'Va chạm nhẹ, không thương tích',b'1','LOW',2,4);

-- Trip Assignment History
INSERT IGNORE INTO trip_assignment_history (id, action, createdAt, note, driverId, tripId, vehicleId) VALUES
(1,'ASSIGN',NOW(),'Gán tài xế HN B',2,4,3),
(2,'ACCEPT',NOW(),'Tài xế chấp nhận chuyến',2,4,3);

-- Notifications for approvals
INSERT IGNORE INTO notifications (notificationId, userId, title, message, createdAt, isRead) VALUES
(3,7,'Yêu cầu Nghỉ phép đã được duyệt','Yêu cầu nghỉ phép #1 đã được duyệt.',NOW(),0);

-- App completion
-- End of seed
select * from users;
