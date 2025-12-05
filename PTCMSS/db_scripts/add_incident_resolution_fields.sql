-- Migration script: Add resolution fields to trip_incidents table
-- This allows coordinators to specify what action they took when resolving incidents

USE ptcmss_db;

ALTER TABLE `trip_incidents`
ADD COLUMN `resolution_action` ENUM(
    'SEND_EMERGENCY_SUPPORT',    -- Gửi hỗ trợ khẩn cấp (xe cứu thương, cứu hộ)
    'CONTACT_DRIVER',             -- Liên hệ với tài xế
    'SEND_REPLACEMENT_VEHICLE',   -- Gửi xe thay thế
    'REASSIGN_TRIP',              -- Chuyển chuyến đi sang tài xế khác
    'CANCEL_TRIP',                -- Hủy chuyến đi
    'OTHER'                       -- Giải pháp khác
) NULL DEFAULT NULL AFTER `severity`,
ADD COLUMN `resolution_note` TEXT NULL DEFAULT NULL AFTER `resolution_action`,
ADD COLUMN `resolved_by` INT NULL DEFAULT NULL AFTER `resolution_note`,
ADD COLUMN `resolved_at` DATETIME(6) NULL DEFAULT NULL AFTER `resolved_by`,
ADD CONSTRAINT `FK_trip_incidents_resolved_by` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`userId`);

-- Add index for faster queries
CREATE INDEX `IX_trip_incidents_resolved_by` ON `trip_incidents` (`resolved_by`);
CREATE INDEX `IX_trip_incidents_resolved_at` ON `trip_incidents` (`resolved_at`);

