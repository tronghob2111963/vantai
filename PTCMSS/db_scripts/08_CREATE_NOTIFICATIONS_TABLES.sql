-- =====================================================
-- Script: 08_CREATE_NOTIFICATIONS_TABLES.sql
-- Mục đích: Tạo bảng cho hệ thống Notifications & Approvals
-- =====================================================

-- Bảng SystemAlerts: Cảnh báo hệ thống
CREATE TABLE IF NOT EXISTS SystemAlerts (
    alertId INT AUTO_INCREMENT PRIMARY KEY,
    alertType VARCHAR(50) NOT NULL COMMENT 'VEHICLE_INSPECTION_EXPIRING, DRIVER_LICENSE_EXPIRING, etc.',
    severity VARCHAR(20) NOT NULL COMMENT 'LOW, MEDIUM, HIGH, CRITICAL',
    title VARCHAR(200),
    message VARCHAR(1000),
    relatedEntityType VARCHAR(50) COMMENT 'DRIVER, VEHICLE, TRIP, etc.',
    relatedEntityId INT,
    branchId INT,
    isAcknowledged BOOLEAN DEFAULT FALSE,
    acknowledgedBy INT,
    acknowledgedAt TIMESTAMP NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiresAt TIMESTAMP NULL,
    
    FOREIGN KEY (branchId) REFERENCES Branches(branchId) ON DELETE SET NULL,
    FOREIGN KEY (acknowledgedBy) REFERENCES Users(userId) ON DELETE SET NULL,
    
    INDEX idx_acknowledged (isAcknowledged),
    INDEX idx_branch (branchId),
    INDEX idx_severity (severity),
    INDEX idx_type (alertType),
    INDEX idx_entity (relatedEntityType, relatedEntityId),
    INDEX idx_created (createdAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng ApprovalHistory: Lịch sử phê duyệt
CREATE TABLE IF NOT EXISTS ApprovalHistory (
    historyId INT AUTO_INCREMENT PRIMARY KEY,
    approvalType VARCHAR(50) NOT NULL COMMENT 'DRIVER_DAY_OFF, DISCOUNT_REQUEST, EXPENSE_REQUEST, etc.',
    relatedEntityId INT NOT NULL COMMENT 'ID của entity cần approve',
    status VARCHAR(20) NOT NULL COMMENT 'PENDING, APPROVED, REJECTED, CANCELLED',
    requestedBy INT NOT NULL,
    approvedBy INT,
    requestReason VARCHAR(500),
    approvalNote VARCHAR(500),
    requestedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processedAt TIMESTAMP NULL,
    branchId INT,
    
    FOREIGN KEY (requestedBy) REFERENCES Users(userId) ON DELETE CASCADE,
    FOREIGN KEY (approvedBy) REFERENCES Users(userId) ON DELETE SET NULL,
    FOREIGN KEY (branchId) REFERENCES Branches(branchId) ON DELETE SET NULL,
    
    INDEX idx_status (status),
    INDEX idx_type (approvalType),
    INDEX idx_entity (relatedEntityId),
    INDEX idx_requested_by (requestedBy),
    INDEX idx_approved_by (approvedBy),
    INDEX idx_branch (branchId),
    INDEX idx_requested_at (requestedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Thêm comment cho bảng
ALTER TABLE SystemAlerts COMMENT = 'Cảnh báo hệ thống: xe sắp hết đăng kiểm, bằng lái hết hạn, etc.';
ALTER TABLE ApprovalHistory COMMENT = 'Lịch sử phê duyệt: nghỉ phép, tạm ứng, giảm giá, etc.';

-- Insert sample data (optional)
-- Sample alerts
INSERT INTO SystemAlerts (alertType, severity, title, message, relatedEntityType, relatedEntityId, branchId, isAcknowledged)
VALUES 
('VEHICLE_INSPECTION_EXPIRING', 'HIGH', 'Xe sắp hết hạn đăng kiểm', 'Xe 29A-123.45 sẽ hết hạn đăng kiểm trong 5 ngày', 'VEHICLE', 1, 1, FALSE),
('DRIVER_LICENSE_EXPIRING', 'MEDIUM', 'Bằng lái sắp hết hạn', 'Bằng lái của tài xế Nguyễn Văn A sẽ hết hạn trong 20 ngày', 'DRIVER', 1, 1, FALSE);

-- Sample approval history (for existing driver day-off requests)
-- Note: Chỉ insert nếu đã có dữ liệu trong bảng driver_day_off
-- INSERT INTO approval_history (approvalType, relatedEntityId, status, requestedBy, requestReason, branchId)
-- SELECT 
--     'DRIVER_DAY_OFF',
--     d.dayOffId,
--     CASE 
--         WHEN d.status = 'Approved' THEN 'APPROVED'
--         WHEN d.status = 'Rejected' THEN 'REJECTED'
--         ELSE 'PENDING'
--     END,
--     dr.employeeId, -- Assuming driver's employee is the requester
--     d.reason,
--     dr.branchId
-- FROM driver_day_off d
-- JOIN drivers dr ON d.driverId = dr.driverId
-- WHERE d.status = 'Pending';

COMMIT;
