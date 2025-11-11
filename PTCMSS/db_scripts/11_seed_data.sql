USE ptcmss_db;

-- Roles
INSERT INTO Roles (roleId, roleName, description) VALUES
(1, 'Admin', 'Quản trị viên hệ thống'),
(2, 'Manager', 'Quản lý chi nhánh'),
(3, 'Consultant', 'Điều hành/Tư vấn'),
(4, 'Driver', 'Tài xế'),
(5, 'Accountant', 'Kế toán')
ON DUPLICATE KEY UPDATE roleName = VALUES(roleName), description = VALUES(description);

-- Vehicle categories (9+ seats only)
INSERT INTO VehicleCategoryPricing (categoryId, categoryName, description, baseFare, pricePerKm, highwayFee, fixedCosts, status) VALUES
(1, 'Xe 9 chỗ (Limousine)', 'DCar/Solati Limousine', 800000.00, 15000.00, 100000.00, 0.00, 'Active'),
(2, 'Xe 16 chỗ', 'Ford Transit, Mercedes Sprinter', 1200000.00, 18000.00, 120000.00, 0.00, 'Active'),
(3, 'Xe 29 chỗ', 'Hyundai County, Samco Isuzu', 1800000.00, 22000.00, 150000.00, 0.00, 'Active'),
(4, 'Xe 45 chỗ', 'Hyundai Universe', 2500000.00, 28000.00, 200000.00, 0.00, 'Active'),
(5, 'Xe giường nằm (40 chỗ)', 'Xe giường nằm Thaco/Hyundai', 3000000.00, 30000.00, 250000.00, 0.00, 'Active')
ON DUPLICATE KEY UPDATE categoryName = VALUES(categoryName), description = VALUES(description);

-- Hire types (includes periodic rentals)
INSERT INTO HireTypes (hireTypeId, code, name, description, isActive) VALUES
(1, 'ONE_WAY', 'Thuê 1 chiều', 'Thuê xe đi 1 chiều', TRUE),
(2, 'ROUND_TRIP', 'Thuê 2 chiều (trong ngày)', 'Thuê xe đi và về trong ngày', TRUE),
(3, 'MULTI_DAY', 'Thuê nhiều ngày', 'Thuê xe theo gói nhiều ngày', TRUE),
(4, 'PERIODIC', 'Thuê định kỳ', 'Thuê lặp lại (đưa đón nhân viên, học sinh)', TRUE),
(5, 'AIRPORT_TRANSFER', 'Đưa/đón sân bay', 'Gói đưa đón sân bay 1 chiều', TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), isActive = VALUES(isActive);

-- Branches (managerId to be updated after employees inserted)
INSERT INTO Branches (branchId, branchName, location, managerId, status) VALUES
(1, 'Chi nhánh Hà Nội', '123 Láng Hạ, Đống Đa, Hà Nội', NULL, 'Active'),
(2, 'Chi nhánh Đà Nẵng', '456 Nguyễn Văn Linh, Hải Châu, Đà Nẵng', NULL, 'Active'),
(3, 'Chi nhánh TP. HCM', '789 Võ Thị Sáu, Quận 3, TP. HCM', NULL, 'Active'),
(4, 'Chi nhánh Hải Phòng', '10 Lê Hồng Phong, Ngô Quyền, Hải Phòng', NULL, 'Inactive'),
(5, 'Chi nhánh Quảng Ninh', '55 Trần Hưng Đạo, Hạ Long, Quảng Ninh', NULL, 'Active')
ON DUPLICATE KEY UPDATE branchName = VALUES(branchName), location = VALUES(location), status = VALUES(status);

-- Users (sample passwords are placeholders)
INSERT INTO Users (userId, roleId, fullName, username, passwordHash, email, phone, status) VALUES
(1, 1, 'Admin Tổng', 'admin', '$2a$10$placeholderadminhash', 'admin@ptcmss.com', '0900000001', 'Active'),
(2, 2, 'Quản Lý Hà Nội', 'manager_hn', '$2a$10$placeholdermanager1', 'manager.hn@ptcmss.com', '0900000002', 'Active'),
(3, 2, 'Quản Lý Đà Nẵng', 'manager_dn', '$2a$10$placeholdermanager2', 'manager.dn@ptcmss.com', '0900000003', 'Active'),
(4, 2, 'Quản Lý HCM', 'manager_hcm', '$2a$10$placeholdermanager3', 'manager.hcm@ptcmss.com', '0900000004', 'Active'),
(5, 3, 'Điều Hành Viên 1 (HN)', 'consultant_hn1', '$2a$10$placeholderconsult1', 'c1.hn@ptcmss.com', '0900000005', 'Active'),
(6, 3, 'Điều Hành Viên 2 (HN)', 'consultant_hn2', '$2a$10$placeholderconsult2', 'c2.hn@ptcmss.com', '0900000006', 'Active'),
(7, 5, 'Kế Toán 1 (HN)', 'accountant_hn1', '$2a$10$placeholderacct1', 'k1.hn@ptcmss.com', '0900000007', 'Active'),
(8, 4, 'Tài Xế Nguyễn Văn A', 'driver_a', '$2a$10$placeholderdrivera', 'driver.a@ptcmss.com', '0912345671', 'Active'),
(9, 4, 'Tài Xế Trần Văn B', 'driver_b', '$2a$10$placeholderdriverb', 'driver.b@ptcmss.com', '0912345672', 'Active'),
(10, 4, 'Tài Xế Lê Hữu C', 'driver_c', '$2a$10$placeholderdriverc', 'driver.c@ptcmss.com', '0912345673', 'Active'),
(11, 4, 'Tài Xế Phạm Đình D', 'driver_d', '$2a$10$placeholderdriverd', 'driver.d@ptcmss.com', '0912345674', 'Active'),
(12, 4, 'Tài Xế Huỳnh Tấn E', 'driver_e', '$2a$10$placeholderdrivere', 'driver.e@ptcmss.com', '0912345675', 'Active'),
(13, 4, 'Tài Xế Vũ Minh F', 'driver_f', '$2a$10$placeholderdriverf', 'driver.f@ptcmss.com', '0912345676', 'Active'),
(14, 4, 'Tài Xế Đặng Văn G', 'driver_g', '$2a$10$placeholderdriverg', 'driver.g@ptcmss.com', '0912345677', 'Active')
ON DUPLICATE KEY UPDATE fullName = VALUES(fullName), email = VALUES(email), phone = VALUES(phone), status = VALUES(status);

-- Employees (ties users to branches/roles)
INSERT INTO Employees (employeeId, userId, branchId, roleId, status) VALUES
(1, 1, 1, 1, 'Active'),
(2, 2, 1, 2, 'Active'),
(3, 3, 2, 2, 'Active'),
(4, 4, 3, 2, 'Active'),
(5, 5, 1, 3, 'Active'),
(6, 6, 1, 3, 'Active'),
(7, 7, 1, 5, 'Active'),
(8, 8, 1, 4, 'Active'),
(9, 9, 1, 4, 'Active'),
(10, 10, 2, 4, 'Active'),
(11, 11, 3, 4, 'Active'),
(12, 12, 1, 4, 'Active'),
(13, 13, 2, 4, 'Active'),
(14, 14, 3, 4, 'Active')
ON DUPLICATE KEY UPDATE branchId = VALUES(branchId), roleId = VALUES(roleId), status = VALUES(status);

-- Update branch managers after employees exist
UPDATE Branches SET managerId = 2 WHERE branchId = 1;
UPDATE Branches SET managerId = 3 WHERE branchId = 2;
UPDATE Branches SET managerId = 4 WHERE branchId = 3;
UPDATE Branches SET managerId = 2 WHERE branchId = 5;

-- Drivers (link employees to driver details)
INSERT INTO Drivers (driverId, employeeId, branchId, licenseNumber, licenseClass, licenseExpiry, healthCheckDate, status) VALUES
(1, 8, 1, 'HN12345', 'D', '2028-12-31', '2025-06-01', 'Available'),
(2, 9, 1, 'HN67890', 'E', '2027-10-10', '2025-05-01', 'Available'),
(3, 10, 2, 'DN55555', 'D', '2029-01-15', '2025-07-01', 'Available'),
(4, 11, 3, 'HCM88888', 'E', '2026-05-20', '2025-03-01', 'OnTrip'),
(5, 12, 1, 'HN45678', 'D', '2028-02-14', '2025-08-01', 'Available'),
(6, 13, 2, 'DN11111', 'E', '2027-11-30', '2025-09-10', 'Inactive'),
(7, 14, 3, 'HCM22222', 'D', '2029-07-07', '2025-10-01', 'Available')
ON DUPLICATE KEY UPDATE branchId = VALUES(branchId), status = VALUES(status);

-- Customers
INSERT INTO Customers (customerId, fullName, phone, email, address, createdBy, status) VALUES
(1, 'Công ty TNHH ABC (KCN Thăng Long)', '0987654321', 'contact@abc.com', 'KCN Thăng Long, Đông Anh, Hà Nội', 5, 'Active'),
(2, 'Đoàn du lịch Hướng Việt', '0987654322', 'info@huongviet.vn', 'Hoàn Kiếm, Hà Nội', 6, 'Active'),
(3, 'Công ty CP XYZ (Đà Nẵng)', '0987654323', 'hr@xyz.com', 'Hải Châu, Đà Nẵng', 5, 'Active'),
(4, 'Gia đình ông Trần Văn Hùng', '0987654324', 'hung.tran@gmail.com', 'Quận 7, TP. HCM', 6, 'Active'),
(5, 'Trường quốc tế Vinschool', '0987654325', 'school@vinschool.edu.vn', 'Times City, Hà Nội', 5, 'Active')
ON DUPLICATE KEY UPDATE phone = VALUES(phone), email = VALUES(email), address = VALUES(address), status = VALUES(status);

-- Vehicles (all 9+ seats)
INSERT INTO Vehicles (vehicleId, categoryId, branchId, licensePlate, model, capacity, productionYear, registrationDate, inspectionExpiry, status) VALUES
(1, 2, 1, '29A-111.11', 'Ford Transit', 16, 2022, '2022-01-01', '2026-06-30', 'Available'),
(2, 1, 1, '29A-222.22', 'DCar Limousine', 9, 2023, '2023-05-01', '2026-04-30', 'Available'),
(3, 3, 1, '29A-333.33', 'Samco Isuzu', 29, 2021, '2021-03-01', '2025-08-30', 'Available'),
(4, 4, 2, '43B-444.44', 'Hyundai Universe', 45, 2023, '2023-06-01', '2025-11-30', 'Available'),
(5, 2, 3, '51C-555.55', 'Ford Transit', 16, 2022, '2022-07-01', '2026-12-31', 'InUse'),
(6, 3, 1, '29A-666.66', 'Hyundai County', 29, 2022, '2022-09-01', '2026-02-28', 'Available'),
(7, 5, 2, '43B-777.77', 'Thaco Mobihome', 40, 2023, '2023-08-15', '2025-02-14', 'Maintenance')
ON DUPLICATE KEY UPDATE branchId = VALUES(branchId), status = VALUES(status);

-- Bookings (include periodic rental)
INSERT INTO Bookings (bookingId, customerId, branchId, consultantId, hireTypeId, useHighway, estimatedCost, depositAmount, totalCost, status, note) VALUES
(1, 2, 1, 5, 2, TRUE, 3500000.00, 1000000.00, 3800000.00, 'Completed', 'Đoàn 25 khách, đi Hà Nội - Hạ Long 2 chiều'),
(2, 4, 3, 6, 5, TRUE, 1200000.00, 500000.00, 1200000.00, 'Confirmed', 'Đón sân bay TSN về Quận 7 (16 chỗ)'),
(3, 1, 1, 5, 4, FALSE, 25000000.00, 10000000.00, 0.00, 'InProgress', 'Hợp đồng đưa đón nhân viên KCN Thăng Long T11/2025'),
(4, 3, 2, 6, 3, TRUE, 15000000.00, 500000.00, 0.00, 'Pending', 'Thuê xe 45 chỗ đi 3N2Đ Đà Nẵng - Huế - Hội An'),
(5, 5, 1, 5, 1, TRUE, 1000000.00, 1000000.00, 1000000.00, 'Confirmed', 'Thuê 1 chiều xe Limo (9 chỗ) đi Nội Bài')
ON DUPLICATE KEY UPDATE status = VALUES(status), note = VALUES(note);

-- Booking vehicle requirements
INSERT INTO BookingVehicleDetails (bookingId, vehicleCategoryId, quantity) VALUES
(1, 3, 1),
(2, 2, 1),
(3, 3, 2),
(4, 4, 1),
(5, 1, 1)
ON DUPLICATE KEY UPDATE quantity = VALUES(quantity);

-- Trips per booking
INSERT INTO Trips (tripId, bookingId, useHighway, startTime, endTime, startLocation, endLocation, status) VALUES
(1, 1, TRUE, '2025-10-25 07:00:00', '2025-10-25 20:00:00', 'Hoàn Kiếm, Hà Nội', 'Hạ Long, Quảng Ninh', 'Completed'),
(2, 2, TRUE, '2025-10-28 14:00:00', '2025-10-28 15:30:00', 'Sân bay Tân Sơn Nhất', 'Quận 7, TP. HCM', 'Scheduled'),
(3, 3, FALSE, '2025-11-01 07:00:00', '2025-11-01 08:30:00', 'Nội thành Hà Nội', 'KCN Thăng Long', 'Scheduled'),
(4, 3, FALSE, '2025-11-01 17:00:00', '2025-11-01 18:30:00', 'KCN Thăng Long', 'Nội thành Hà Nội', 'Scheduled'),
(5, 3, FALSE, '2025-11-02 07:00:00', '2025-11-02 08:30:00', 'Nội thành Hà Nội', 'KCN Thăng Long', 'Scheduled'),
(6, 5, TRUE, '2025-10-29 10:00:00', '2025-10-29 11:00:00', 'Times City, Hà Nội', 'Sân bay Nội Bài', 'Scheduled'),
(7, 4, TRUE, '2025-11-10 08:00:00', NULL, 'Đà Nẵng', 'Huế', 'Scheduled')
ON DUPLICATE KEY UPDATE status = VALUES(status), endTime = VALUES(endTime);

-- Assign vehicles to trips
INSERT INTO TripVehicles (tripVehicleId, tripId, vehicleId, note) VALUES
(1, 1, 3, 'Gán xe Samco 29A-333.33 cho Trip 1'),
(2, 2, 5, 'Gán xe Transit 51C-555.55 cho Trip 2'),
(3, 3, 3, 'Gán xe 29A-333.33 cho Trip 3 (sáng)'),
(4, 3, 6, 'Gán xe 29A-666.66 cho Trip 3 (sáng)'),
(5, 4, 3, 'Gán xe 29A-333.33 cho Trip 4 (chiều)'),
(6, 4, 6, 'Gán xe 29A-666.66 cho Trip 4 (chiều)'),
(7, 5, 3, 'Gán xe 29A-333.33 cho Trip 5 (sáng)'),
(8, 5, 6, 'Gán xe 29A-666.66 cho Trip 5 (sáng)'),
(9, 6, 2, 'Gán xe Limousine 29A-222.22 cho Trip 6'),
(10, 7, 4, 'Gán xe Universe 43B-444.44 cho Trip 7')
ON DUPLICATE KEY UPDATE vehicleId = VALUES(vehicleId), note = VALUES(note);

-- Assign drivers to trips
INSERT INTO TripDrivers (tripId, driverId, driverRole, note) VALUES
(1, 1, 'Main Driver', 'Tài xế A lái xe 29A-333.33'),
(2, 4, 'Main Driver', 'Tài xế D lái xe 51C-555.55'),
(3, 1, 'Main Driver', 'Tài xế A lái xe Trip 3 (sáng)'),
(3, 2, 'Support Driver', 'Tài xế B hỗ trợ Trip 3 (sáng)'),
(4, 1, 'Main Driver', 'Tài xế A lái xe Trip 4 (chiều)'),
(4, 2, 'Support Driver', 'Tài xế B hỗ trợ Trip 4 (chiều)'),
(5, 1, 'Main Driver', 'Tài xế A lái xe Trip 5 (sáng)'),
(5, 2, 'Support Driver', 'Tài xế B hỗ trợ Trip 5 (sáng)'),
(6, 5, 'Main Driver', 'Tài xế E lái xe Trip 6'),
(7, 3, 'Main Driver', 'Tài xế C lái xe Trip 7')
ON DUPLICATE KEY UPDATE driverRole = VALUES(driverRole), note = VALUES(note);

-- Driver day off requests
INSERT INTO DriverDayOff (dayOffId, driverId, startDate, endDate, reason, approvedBy, status) VALUES
(1, 1, '2025-10-30', '2025-10-30', 'Việc gia đình', 2, 'Approved'),
(2, 2, '2025-11-05', '2025-11-06', 'Khám sức khỏe', 2, 'Pending'),
(3, 3, '2025-10-20', '2025-10-21', 'Về quê', 3, 'Approved'),
(4, 4, '2025-10-29', '2025-10-29', 'Nghỉ ốm', 4, 'Rejected'),
(5, 6, '2025-11-01', '2025-11-30', 'Nghỉ không lương', 3, 'Approved')
ON DUPLICATE KEY UPDATE status = VALUES(status), reason = VALUES(reason);

-- Invoices (combined ledger)
INSERT INTO Invoices (invoiceId, branchId, bookingId, customerId, type, costType, isDeposit, amount, paymentMethod, paymentStatus, status, note, requestedBy, createdBy, approvedBy, approvedAt) VALUES
(1, 1, 1, 2, 'Income', NULL, TRUE, 1000000.00, 'Chuyển khoản', 'Paid', 'Active', 'Đặt cọc Booking 1', NULL, 5, 2, NOW()),
(2, 1, 1, 2, 'Income', NULL, FALSE, 2800000.00, 'Tiền mặt', 'Paid', 'Active', 'Thu nốt Booking 1', NULL, 5, 2, NOW()),
(3, 3, 2, 4, 'Income', NULL, TRUE, 500000.00, 'Chuyển khoản', 'Paid', 'Active', 'Đặt cọc Booking 2', NULL, 6, 4, NOW()),
(4, 1, 3, 1, 'Income', NULL, FALSE, 25000000.00, 'Chuyển khoản', 'Paid', 'Active', 'Thanh toán HĐ định kỳ T11', NULL, 5, 2, NOW()),
(5, 1, 5, 5, 'Income', NULL, FALSE, 1000000.00, 'Chuyển khoản', 'Paid', 'Active', 'Thanh toán Booking 5', NULL, 5, 2, NOW()),
(6, 1, 1, NULL, 'Expense', 'fuel', FALSE, 1000000.00, 'Tiền mặt', 'Paid', 'Active', 'Đổ dầu xe Trip 1', 1, 8, 2, NOW()),
(7, 1, 1, NULL, 'Expense', 'toll', FALSE, 300000.00, 'Thẻ ETC', 'Paid', 'Active', 'Phí cao tốc HN-HL Trip 1', 1, 8, 2, NOW()),
(8, 2, NULL, NULL, 'Expense', 'maintenance', FALSE, 5000000.00, 'Chuyển khoản', 'Paid', 'Active', 'Bảo dưỡng xe 43B-777.77', NULL, 3, 3, NOW())
ON DUPLICATE KEY UPDATE amount = VALUES(amount), note = VALUES(note), paymentStatus = VALUES(paymentStatus);

-- Accounts receivable
INSERT INTO AccountsReceivable (arId, customerId, bookingId, invoiceId, totalAmount, paidAmount, dueDate, status) VALUES
(1, 2, 1, 2, 3800000.00, 3800000.00, '2025-10-25', 'Paid'),
(2, 4, 2, 3, 1200000.00, 500000.00, '2025-10-28', 'PartiallyPaid'),
(3, 1, 3, 4, 25000000.00, 25000000.00, '2025-11-01', 'Paid'),
(4, 3, 4, NULL, 15000000.00, 500000.00, '2025-11-10', 'PartiallyPaid'),
(5, 5, 5, 5, 1000000.00, 1000000.00, '2025-10-29', 'Paid')
ON DUPLICATE KEY UPDATE totalAmount = VALUES(totalAmount), paidAmount = VALUES(paidAmount), dueDate = VALUES(dueDate), status = VALUES(status);

-- Notifications
INSERT INTO Notifications (notificationId, userId, title, message, isRead) VALUES
(1, 2, 'Yêu cầu nghỉ phép', 'Tài xế Trần Văn B vừa tạo yêu cầu nghỉ phép.', FALSE),
(2, 6, 'Booking đã xác nhận', 'Booking #2 (Đón sân bay) đã được xác nhận.', FALSE),
(3, 11, 'Giao việc mới', 'Bạn được gán lái Trip #2 (Đón sân bay TSN).', FALSE),
(4, 1, 'Hợp đồng mới', 'Hợp đồng thuê định kỳ (Booking #3) vừa được kích hoạt.', TRUE),
(5, 7, 'Hóa đơn đã duyệt', 'Hóa đơn chi phí (Xăng dầu Trip 1) đã được duyệt.', FALSE)
ON DUPLICATE KEY UPDATE title = VALUES(title), message = VALUES(message), isRead = VALUES(isRead);

-- System settings
INSERT INTO SystemSettings (settingId, settingKey, settingValue, effectiveStartDate, valueType, category, description, updatedBy) VALUES
(1, 'VAT_RATE', '0.08', '2025-01-01', 'decimal', 'Billing', 'Tỷ lệ thuế VAT (8%)', 1),
(2, 'DEFAULT_HIGHWAY', 'true', '2025-01-01', 'boolean', 'Booking', 'Mặc định chọn cao tốc khi tạo booking', 1),
(3, 'MAX_DRIVING_HOURS_PER_DAY', '10', '2025-01-01', 'int', 'Driver', 'Số giờ lái xe tối đa của tài xế/ngày', 1),
(4, 'SUPPORT_HOTLINE', '1900 1234', '2025-01-01', 'string', 'General', 'Số hotline hỗ trợ khách hàng', 1),
(5, 'LATE_PAYMENT_FEE_RATE', '0.05', '2025-01-01', 'decimal', 'Billing', 'Lãi suất phạt thanh toán chậm (5%/ngày)', 1)
ON DUPLICATE KEY UPDATE settingValue = VALUES(settingValue), description = VALUES(description), updatedBy = VALUES(updatedBy);
