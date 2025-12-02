import random
from datetime import datetime, timedelta

# Constants
ROLES = {
    'Admin': 1,
    'Manager': 2,
    'Consultant': 3,
    'Driver': 4,
    'Accountant': 5,
    'Coordinator': 6
}

BRANCHES = [
    (1, 'Chi nhánh Hà Nội', '123 Láng Hạ, Đống Đa, Hà Nội'),
    (2, 'Chi nhánh Đà Nẵng', '456 Lê Duẩn, Hải Châu, Đà Nẵng'),
    (3, 'Chi nhánh TP.HCM', '789 Nguyễn Huệ, Quận 1, TP.HCM')
]

HIRE_TYPES = [
    (1, 'ONE_WAY', 'Thuê 1 chiều', 'Thuê xe đi 1 chiều', 1),
    (2, 'ROUND_TRIP', 'Thuê 2 chiều (trong ngày)', 'Thuê xe đi và về trong ngày', 1),
    (3, 'MULTI_DAY', 'Thuê nhiều ngày', 'Thuê xe theo gói nhiều ngày', 1),
    (4, 'PERIODIC', 'Thuê định kỳ', 'Thuê lặp lại (đưa đón nhân viên, học sinh)', 1),
    (5, 'AIRPORT_TRANSFER', 'Đưa/đón sân bay', 'Gói đưa đón sân bay 1 chiều', 1)
]

VEHICLE_CATEGORIES = [
    (1, 'Xe 9 chỗ (Limousine)', 9, 900000, 15000),
    (2, 'Xe 16 chỗ', 16, 1100000, 30000),
    (3, 'Xe 29 chỗ', 29, 1800000, 40000),
    (4, 'Xe 45 chỗ', 45, 2500000, 50000),
    (5, 'Xe giường nằm (40 chỗ)', 40, 3000000, 30000)
]

CUSTOMERS = [
    (1, 'Công ty TNHH ABC', '0987654321', 'contact@abc.com', 'Hà Nội'),
    (2, 'Đoàn du lịch Hướng Việt', '0987654322', 'info@huongviet.vn', 'Hà Nội'),
    (3, 'Công ty XYZ', '0987654323', 'contact@xyz.com', 'Đà Nẵng'),
    (4, 'Trường Quốc tế SIS', '0987654324', 'admin@sis.edu.vn', 'Hà Nội'),
    (5, 'Tập đoàn Viettel', '0987654325', 'contact@viettel.com.vn', 'Hà Nội'),
    (6, 'Công ty Du lịch Sài Gòn', '0987654326', 'info@saigontourist.com', 'TP.HCM'),
    (7, 'Nguyễn Văn Khách', '0912345678', 'khach.nv@gmail.com', 'Đà Nẵng'),
    (8, 'Trần Thị Khách', '0912345679', 'khach.tt@gmail.com', 'TP.HCM'),
    (9, 'Lê Văn Du', '0912345680', 'du.lv@gmail.com', 'Hà Nội'),
    (10, 'Phạm Thị Lịch', '0912345681', 'lich.pt@gmail.com', 'Hà Nội')
]

# Helper to generate SQL
def generate_sql():
    sql = []
    
    sql.append("-- =====================================================")
    sql.append("-- PTCMSS Database Initialization Script (Generated)")
    sql.append("-- =====================================================")
    sql.append("")

    # Roles
    sql.append("-- Insert Roles")
    sql.append("INSERT IGNORE INTO roles (roleId, roleName, description, status) VALUES")
    sql.append("(1, 'Admin', 'Quản trị viên hệ thống', 'ACTIVE'),")
    sql.append("(2, 'Manager', 'Quản lý chi nhánh', 'ACTIVE'),")
    sql.append("(3, 'Consultant', 'Tư vấn viên', 'ACTIVE'),")
    sql.append("(4, 'Driver', 'Tài xế', 'ACTIVE'),")
    sql.append("(5, 'Accountant', 'Kế toán', 'ACTIVE'),")
    sql.append("(6, 'Coordinator', 'Điều phối viên', 'ACTIVE');")
    sql.append("")

    # Admin User
    sql.append("-- Insert Default Admin User")
    sql.append("INSERT IGNORE INTO users (userId, roleId, fullName, username, passwordHash, email, phone, status, email_verified, createdAt) VALUES")
    sql.append("(1, 1, 'Admin Tổng', 'admin', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', 'admin@ptcmss.com', '0900000001', 'ACTIVE', 1, NOW());")
    sql.append("")

    # Branches
    sql.append("-- Insert Branches")
    sql.append("INSERT IGNORE INTO branches (branchId, branchName, location, managerId, status, createdAt) VALUES")
    for b in BRANCHES:
        sql.append(f"({b[0]}, '{b[1]}', '{b[2]}', NULL, 'ACTIVE', NOW()),")
    sql[-1] = sql[-1][:-1] + ";"
    sql.append("")

    # Admin Employee
    sql.append("-- Insert Admin Employee")
    sql.append("INSERT IGNORE INTO employees (employeeId, userId, branchId, roleId, status) VALUES")
    sql.append("(1, 1, 1, 1, 'ACTIVE');")
    sql.append("")

    # Hire Types
    sql.append("-- Insert Hire Types")
    sql.append("INSERT IGNORE INTO hire_types (hireTypeId, code, name, description, isActive) VALUES")
    for h in HIRE_TYPES:
        sql.append(f"({h[0]}, '{h[1]}', '{h[2]}', '{h[3]}', {h[4]}),")
    sql[-1] = sql[-1][:-1] + ";"
    sql.append("")

    # Vehicle Categories
    sql.append("-- Insert Vehicle Categories")
    sql.append("INSERT IGNORE INTO vehicle_category_pricing (categoryId, categoryName, seats, description, baseFare, pricePerKm, highwayFee, fixedCosts, sameDayFixedPrice, isPremium, premiumSurcharge, effectiveDate, status, createdAt) VALUES")
    for v in VEHICLE_CATEGORIES:
        fixed_price = 'NULL'
        if v[2] in [16, 29]:
            fixed_price = f"{v[3] * 2.5}" # Example logic
        sql.append(f"({v[0]}, '{v[1]}', {v[2]}, 'Mô tả {v[1]}', {v[3]}, {v[4]}, 100000, 0, {fixed_price}, FALSE, 0, CURDATE(), 'ACTIVE', NOW()),")
    sql[-1] = sql[-1][:-1] + ";"
    sql.append("")

    # System Settings (Keep existing)
    sql.append("-- Insert System Settings")
    sql.append("INSERT IGNORE INTO system_settings (settingId, settingKey, settingValue, effectiveStartDate, valueType, category, description, updatedBy, updatedAt, status) VALUES")
    settings = [
        (1, 'VAT_RATE', '0.08', 'Billing', 'Tỷ lệ thuế VAT (8%)'),
        (2, 'DEFAULT_HIGHWAY', 'true', 'Booking', 'Mặc định chọn cao tốc'),
        (3, 'MAX_DRIVING_HOURS_PER_DAY', '10', 'Driver', 'Số giờ lái xe tối đa/ngày'),
        (4, 'SUPPORT_HOTLINE', '1900 1234', 'General', 'Hotline'),
        (5, 'LATE_PAYMENT_FEE_RATE', '0.05', 'Billing', 'Phạt chậm thanh toán'),
        (6, 'HOLIDAY_SURCHARGE_RATE', '0.25', 'Pricing', 'Phụ phí ngày lễ'),
        (7, 'WEEKEND_SURCHARGE_RATE', '0.20', 'Pricing', 'Phụ phí cuối tuần'),
        (8, 'ONE_WAY_DISCOUNT_RATE', '0.6667', 'Pricing', 'Giảm giá 1 chiều'),
        (9, 'ADDITIONAL_POINT_SURCHARGE_RATE', '0.05', 'Pricing', 'Phụ phí điểm đón thêm'),
        (10, 'DEFAULT_DEPOSIT_PERCENT', '0.50', 'Booking', 'Tỷ lệ cọc mặc định'),
        (11, 'MAX_DEPOSIT_PERCENT', '0.70', 'Booking', 'Tỷ lệ cọc tối đa'),
        (12, 'SINGLE_DRIVER_MAX_DISTANCE_KM', '300', 'Dispatch', 'Max km 1 tài xế'),
        (13, 'CANCELLATION_FULL_DEPOSIT_LOSS_HOURS', '24', 'Booking', 'Giờ mất 100% cọc'),
        (14, 'CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS', '48', 'Booking', 'Giờ mất một phần cọc'),
        (15, 'CANCELLATION_PARTIAL_DEPOSIT_PERCENT', '0.30', 'Booking', 'Tỷ lệ mất cọc'),
        (16, 'MAX_CONTINUOUS_DRIVING_HOURS', '4', 'Driver', 'Max giờ lái liên tục'),
        (17, 'MAX_DRIVING_HOURS_PER_WEEK', '48', 'Driver', 'Max giờ lái tuần'),
        (18, 'ROUND_TRIP_MULTIPLIER', '1.5', 'Pricing', 'Hệ số 2 chiều'),
        (19, 'INTER_PROVINCE_DISTANCE_KM', '100', 'Pricing', 'Ngưỡng liên tỉnh')
    ]
    for s in settings:
        val_type = 'decimal' if '.' in s[2] else ('boolean' if s[2] in ['true', 'false'] else ('int' if s[2].isdigit() else 'string'))
        sql.append(f"({s[0]}, '{s[1]}', '{s[2]}', '2025-01-01', '{val_type}', '{s[3]}', '{s[4]}', 1, NOW(), 'ACTIVE'),")
    sql[-1] = sql[-1][:-1] + ";"
    sql.append("")

    # Generate Users and Employees
    sql.append("-- Insert Users and Employees")
    user_id_counter = 2 # Start from 2 (1 is admin)
    employee_id_counter = 2 # Start from 2 (1 is admin)
    driver_id_counter = 1
    
    users_sql = []
    employees_sql = []
    drivers_sql = []
    
    # Role distribution per branch: 1 Manager, 1 Accountant, 1 Coordinator, 2 Consultants, 5 Drivers
    roles_dist = [
        ('Manager', 1), ('Accountant', 1), ('Coordinator', 1), ('Consultant', 2), ('Driver', 5)
    ]
    
    branch_managers = {} # branch_id -> user_id

    for branch in BRANCHES:
        branch_id = branch[0]
        branch_code = branch[1].split()[-1] # Hà Nội -> Nội (simplified)
        if branch_id == 1: branch_code = "HN"
        elif branch_id == 2: branch_code = "DN"
        elif branch_id == 3: branch_code = "HCM"
        
        for role_name, count in roles_dist:
            for i in range(count):
                role_id = ROLES[role_name]
                username = f"{role_name.lower()}_{branch_code.lower()}_{i+1}"
                email = f"{username}@ptcmss.com"
                full_name = f"{role_name} {branch_code} {i+1}"
                phone = f"09{branch_id:02d}{role_id:02d}{i:04d}"
                
                users_sql.append(f"({user_id_counter}, {role_id}, '{full_name}', '{username}', '$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq', '{email}', '{phone}', 'ACTIVE', 1, NOW())")
                employees_sql.append(f"({employee_id_counter}, {user_id_counter}, {branch_id}, {role_id}, 'ACTIVE')")
                
                if role_name == 'Manager':
                    branch_managers[branch_id] = employee_id_counter # Store employee ID for manager update
                
                if role_name == 'Driver':
                    license_num = f"{branch_code}{driver_id_counter:05d}"
                    drivers_sql.append(f"({driver_id_counter}, {employee_id_counter}, {branch_id}, '{license_num}', 'D', '2030-01-01', '2025-06-01', 5.0, 1, 'AVAILABLE', NOW())")
                    driver_id_counter += 1
                
                user_id_counter += 1
                employee_id_counter += 1

    sql.append("INSERT IGNORE INTO users (userId, roleId, fullName, username, passwordHash, email, phone, status, email_verified, createdAt) VALUES")
    sql.append(",\n".join(users_sql) + ";")
    sql.append("")
    
    sql.append("INSERT IGNORE INTO employees (employeeId, userId, branchId, roleId, status) VALUES")
    sql.append(",\n".join(employees_sql) + ";")
    sql.append("")
    
    sql.append("-- Insert Drivers")
    sql.append("INSERT IGNORE INTO drivers (driverId, employeeId, branchId, licenseNumber, licenseClass, licenseExpiry, healthCheckDate, rating, priorityLevel, status, createdAt) VALUES")
    sql.append(",\n".join(drivers_sql) + ";")
    sql.append("")

    # Update Branch Managers
    sql.append("-- Update Branch Managers")
    for b_id, mgr_id in branch_managers.items():
        sql.append(f"UPDATE branches SET managerId = {mgr_id} WHERE branchId = {b_id};")
    sql.append("")

    # Vehicles
    sql.append("-- Insert Vehicles")
    vehicles_sql = []
    vehicle_id_counter = 1
    for branch in BRANCHES:
        branch_id = branch[0]
        branch_code = "29" if branch_id == 1 else ("43" if branch_id == 2 else "51") # License plate prefix
        
        for cat in VEHICLE_CATEGORIES:
            # 2 vehicles per category per branch
            for i in range(2):
                plate = f"{branch_code}A-{vehicle_id_counter:03d}.{i:02d}"
                vehicles_sql.append(f"({vehicle_id_counter}, {cat[0]}, {branch_id}, '{plate}', '{cat[1]}', 'BrandX', {cat[2]}, 2022, '2022-01-01', '2026-01-01', 'AVAILABLE')")
                vehicle_id_counter += 1
    
    sql.append("INSERT IGNORE INTO vehicles (vehicleId, categoryId, branchId, licensePlate, model, brand, capacity, productionYear, registrationDate, inspectionExpiry, status) VALUES")
    sql.append(",\n".join(vehicles_sql) + ";")
    sql.append("")

    # Customers
    sql.append("-- Insert Customers")
    customers_sql = []
    for c in CUSTOMERS:
        customers_sql.append(f"({c[0]}, '{c[1]}', '{c[2]}', '{c[3]}', '{c[4]}', NOW(), 1, 'ACTIVE')")
    
    sql.append("INSERT IGNORE INTO customers (customerId, fullName, phone, email, address, createdAt, createdBy, status) VALUES")
    sql.append(",\n".join(customers_sql) + ";")
    sql.append("")

    # Bookings, Trips, Invoices
    sql.append("-- Insert Bookings, Trips, Invoices")
    bookings_sql = []
    trips_sql = []
    invoices_sql = []
    
    booking_id = 1
    trip_id = 1
    invoice_id = 1
    
    # Generate some bookings
    for i in range(20):
        cust = CUSTOMERS[i % len(CUSTOMERS)]
        branch = BRANCHES[i % len(BRANCHES)]
        hire_type = HIRE_TYPES[i % len(HIRE_TYPES)]
        
        status = 'COMPLETED' if i < 10 else 'CONFIRMED'
        booking_date = 'NOW()'
        
        est_cost = 1000000 * (i + 1)
        deposit = est_cost * 0.3
        
        bookings_sql.append(f"({booking_id}, {cust[0]}, {branch[0]}, 3, {hire_type[0]}, 1, {booking_date}, {est_cost}, {deposit}, {est_cost}, '{status}', 'Booking auto {booking_id}', NOW())")
        
        # Trip
        trip_status = 'COMPLETED' if status == 'COMPLETED' else 'SCHEDULED'
        start_time = f"DATE_SUB(NOW(), INTERVAL {20-i} DAY)" if status == 'COMPLETED' else "DATE_ADD(NOW(), INTERVAL 2 DAY)"
        end_time = f"DATE_ADD({start_time}, INTERVAL 1 DAY)" if status == 'COMPLETED' else "NULL"
        
        trips_sql.append(f"({trip_id}, {booking_id}, 1, {start_time}, {end_time}, '{branch[2]}', 'Destination {i}', 100.0, '{trip_status}')")
        
        # Invoice
        payment_status = 'PAID' if status == 'COMPLETED' else 'UNPAID'
        invoices_sql.append(f"({invoice_id}, {branch[0]}, {booking_id}, {cust[0]}, 'INCOME', {est_cost}, 'BANK_TRANSFER', '{payment_status}', 'ACTIVE', NOW(), NOW())")
        
        booking_id += 1
        trip_id += 1
        invoice_id += 1

    sql.append("INSERT IGNORE INTO bookings (bookingId, customerId, branchId, consultantId, hireTypeId, useHighway, bookingDate, estimatedCost, depositAmount, totalCost, status, note, createdAt) VALUES")
    sql.append(",\n".join(bookings_sql) + ";")
    sql.append("")
    
    sql.append("INSERT IGNORE INTO trips (tripId, bookingId, useHighway, startTime, endTime, startLocation, endLocation, distance, status) VALUES")
    sql.append(",\n".join(trips_sql) + ";")
    sql.append("")
    
    sql.append("INSERT IGNORE INTO invoices (invoiceId, branchId, bookingId, customerId, type, amount, paymentMethod, paymentStatus, status, invoiceDate, createdAt) VALUES")
    sql.append(",\n".join(invoices_sql) + ";")
    sql.append("")

    return "\n".join(sql)

if __name__ == "__main__":
    print(generate_sql())
