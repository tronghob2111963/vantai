CREATE DATABASE  IF NOT EXISTS `ptcmss_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `ptcmss_db`;
-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: ptcmss_db
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `app_settings`
--

DROP TABLE IF EXISTS `app_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_settings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `setting_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `setting_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK7p82g7l6uve2vd8l30djhxpel` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_settings`
--

LOCK TABLES `app_settings` WRITE;
/*!40000 ALTER TABLE `app_settings` DISABLE KEYS */;
INSERT INTO `app_settings` VALUES (1,'Tiền tố nội dung chuyển khoản','qr.description_prefix','2025-12-02 16:02:30.000000','admin','VANTAI'),(2,'Mã ngân hàng theo chuẩn VietQR','qr.bank_code','2025-12-02 16:02:30.000000','admin','970403'),(3,'Tên chủ tài khoản','qr.account_name','2025-12-02 16:02:30.000000','admin','CONG TY VANTAI'),(4,'Số tài khoản ngân hàng','qr.account_number','2025-12-02 16:02:30.000000','admin','070122047995');
/*!40000 ALTER TABLE `app_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `approval_history`
--

DROP TABLE IF EXISTS `approval_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `approval_history` (
  `historyId` int NOT NULL AUTO_INCREMENT,
  `approvalNote` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approvalType` enum('DISCOUNT_REQUEST','DRIVER_DAY_OFF','EXPENSE_REQUEST','OVERTIME_REQUEST','SCHEDULE_CHANGE','VEHICLE_REPAIR') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `processedAt` datetime(6) DEFAULT NULL,
  `relatedEntityId` int NOT NULL,
  `requestReason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `requestedAt` datetime(6) DEFAULT NULL,
  `status` enum('APPROVED','CANCELLED','PENDING','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `approvedBy` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `requestedBy` int NOT NULL,
  PRIMARY KEY (`historyId`),
  KEY `FK16wtf9gshfmvoylj7vgfrttwk` (`approvedBy`),
  KEY `FKly3gq7psb2v5ia1abopveqv65` (`branchId`),
  KEY `FKetd5rr5a5ragndtrnc6vgovlr` (`requestedBy`),
  CONSTRAINT `FK16wtf9gshfmvoylj7vgfrttwk` FOREIGN KEY (`approvedBy`) REFERENCES `users` (`userId`),
  CONSTRAINT `FKetd5rr5a5ragndtrnc6vgovlr` FOREIGN KEY (`requestedBy`) REFERENCES `users` (`userId`),
  CONSTRAINT `FKly3gq7psb2v5ia1abopveqv65` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `approval_history`
--

LOCK TABLES `approval_history` WRITE;
/*!40000 ALTER TABLE `approval_history` DISABLE KEYS */;
INSERT INTO `approval_history` VALUES (1,'Đồng ý','DRIVER_DAY_OFF','2025-12-02 16:02:30.000000',1,'Việc gia đình','2025-11-16 16:02:30.000000','APPROVED',2,1,7),(2,'Đồng ý','DRIVER_DAY_OFF','2025-12-02 16:02:30.000000',2,'Khám sức khỏe','2025-11-21 16:02:30.000000','APPROVED',11,2,5),(3,'Từ chối','DRIVER_DAY_OFF','2025-12-02 16:02:30.000000',3,'Nghỉ ốm','2025-11-26 16:02:30.000000','REJECTED',21,3,9),(4,NULL,'EXPENSE_REQUEST',NULL,2,'Yêu cầu tạm ứng: MAINTENANCE - 2500000.00 VNĐ','2025-12-02 09:06:46.344933','PENDING',NULL,3,11);
/*!40000 ALTER TABLE `approval_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `booking_vehicle_details`
--

DROP TABLE IF EXISTS `booking_vehicle_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_vehicle_details` (
  `bookingId` int NOT NULL,
  `vehicleCategoryId` int NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`bookingId`,`vehicleCategoryId`),
  KEY `fk_bvd_category` (`vehicleCategoryId`),
  CONSTRAINT `fk_bvd_booking` FOREIGN KEY (`bookingId`) REFERENCES `bookings` (`bookingId`),
  CONSTRAINT `fk_bvd_category` FOREIGN KEY (`vehicleCategoryId`) REFERENCES `vehicle_category_pricing` (`categoryId`),
  CONSTRAINT `booking_vehicle_details_chk_1` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_vehicle_details`
--

LOCK TABLES `booking_vehicle_details` WRITE;
/*!40000 ALTER TABLE `booking_vehicle_details` DISABLE KEYS */;
INSERT INTO `booking_vehicle_details` VALUES (1,3,1),(2,2,1),(3,1,1),(3,3,2),(4,4,1),(5,1,1),(5,3,1),(6,5,1),(7,2,1),(8,1,1),(9,1,1),(9,3,1),(10,1,1),(11,1,1),(12,2,1),(13,2,1),(14,3,1),(15,2,1),(16,3,1),(17,3,2),(18,2,1),(19,2,1);
/*!40000 ALTER TABLE `booking_vehicle_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookings` (
  `bookingId` int NOT NULL AUTO_INCREMENT,
  `customerId` int NOT NULL,
  `branchId` int NOT NULL,
  `consultantId` int DEFAULT NULL,
  `hireTypeId` int DEFAULT NULL,
  `bookingDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `estimatedCost` decimal(12,2) DEFAULT NULL,
  `depositAmount` decimal(12,2) DEFAULT '0.00',
  `totalCost` decimal(12,2) DEFAULT '0.00',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `isHoliday` tinyint(1) DEFAULT '0' COMMENT 'Có phải ngày lễ không',
  `isWeekend` tinyint(1) DEFAULT '0' COMMENT 'Có phải cuối tuần không',
  PRIMARY KEY (`bookingId`),
  KEY `fk_book_cons` (`consultantId`),
  KEY `IX_Bookings_BranchId` (`branchId`),
  KEY `IX_Bookings_Customer_Status` (`customerId`,`status`),
  KEY `IX_Bookings_HireType` (`hireTypeId`),
  CONSTRAINT `fk_book_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_book_cons` FOREIGN KEY (`consultantId`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_book_cust` FOREIGN KEY (`customerId`) REFERENCES `customers` (`customerId`),
  CONSTRAINT `fk_book_hire` FOREIGN KEY (`hireTypeId`) REFERENCES `hire_types` (`hireTypeId`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
INSERT INTO `bookings` VALUES (1,1,1,3,1,'2025-12-02 16:02:30',1200000.00,600000.00,1200000.00,'COMPLETED','HN-HP 1 chiều','2025-12-02 16:02:30','2025-12-02 16:02:30',0,0),(2,2,3,21,2,'2025-12-02 16:02:30',3000000.00,1500000.00,3000000.00,'CONFIRMED','HCM-NB 2 chiều','2025-12-02 16:02:30','2025-12-02 16:02:30',0,0),(3,3,2,12,5,'2025-12-02 16:02:30',1800000.00,900000.00,1800000.00,'PENDING','Đưa đón sân bay','2025-12-02 16:02:30','2025-12-02 16:02:30',0,1),(4,4,1,4,4,'2025-12-02 16:02:30',25000000.00,10000000.00,25000000.00,'INPROGRESS','Hợp đồng định kỳ','2025-12-02 16:02:30','2025-12-02 16:02:30',0,0),(5,5,1,3,6,'2025-12-02 16:02:30',3500000.00,1750000.00,3500000.00,'CONFIRMED','Thuê theo ngày','2025-12-02 16:02:30','2025-12-02 16:02:30',1,0),(6,6,3,22,3,'2025-12-02 16:02:30',15000000.00,5000000.00,15000000.00,'PENDING','Tour miền Tây 3N2Đ','2025-12-02 16:02:30','2025-12-02 16:02:30',0,0),(7,1,1,3,2,'2025-12-02 16:02:30',2200000.00,1000000.00,2200000.00,'CANCELLED','HN-NB 2 chiều','2025-12-02 16:02:30','2025-12-02 16:02:30',0,0),(8,2,3,21,1,'2025-12-02 16:02:30',900000.00,450000.00,900000.00,'CONFIRMED','Trong nội thành','2025-12-02 16:02:30','2025-12-02 16:02:30',0,1),(9,3,2,13,5,'2025-12-02 16:02:30',1200000.00,600000.00,1200000.00,'COMPLETED','Đón sân bay','2025-12-02 16:02:30','2025-12-02 16:02:30',0,0),(10,7,1,3,2,'2025-12-02 09:23:15',40069500.00,0.00,40069500.00,'COMPLETED',NULL,'2025-12-02 09:23:15','2025-12-02 09:29:18',0,0);
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branches` (
  `branchId` int NOT NULL AUTO_INCREMENT,
  `branchName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `managerId` int DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','UNDERREVIEW','CLOSED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`branchId`),
  KEY `FK_Branches_Manager` (`managerId`),
  CONSTRAINT `FK_Branches_Manager` FOREIGN KEY (`managerId`) REFERENCES `employees` (`employeeId`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` VALUES (1,'Chi nhánh Hà Nội','123 Láng Hạ, Đống Đa, Hà Nội',2,'ACTIVE','2025-12-02 16:02:30','024-1234567'),(2,'Chi nhánh Đà Nẵng','456 Nguyễn Văn Linh, Hải Châu, Đà Nẵng',11,'ACTIVE','2025-12-02 16:02:30','0236-123456'),(3,'Chi nhánh TP. HCM','789 Võ Thị Sáu, Quận 3, TP. HCM',20,'ACTIVE','2025-12-02 16:02:30','028-12345678'),(4,'Chi nhánh Hải Phòng','10 Lê Hồng Phong, Ngô Quyền, Hải Phòng',NULL,'INACTIVE','2025-12-02 16:02:30','0225-123456');
/*!40000 ALTER TABLE `branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customerId` int NOT NULL AUTO_INCREMENT,
  `fullName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `createdBy` int DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`customerId`),
  KEY `IX_Customers_CreatedBy` (`createdBy`),
  CONSTRAINT `fk_cust_createdBy` FOREIGN KEY (`createdBy`) REFERENCES `employees` (`employeeId`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Công ty TNHH ABC','0987654321','contact@abc.com','Hà Nội',NULL,'2025-12-02 16:02:30',3,'ACTIVE'),(2,'Đoàn du lịch Hướng Việt','0987654322','info@huongviet.vn','TP. HCM',NULL,'2025-12-02 16:02:30',22,'ACTIVE'),(3,'Công ty CP XYZ','0987654323','hr@xyz.com','Đà Nẵng',NULL,'2025-12-02 16:02:30',12,'ACTIVE'),(4,'Gia đình ông Nguyễn','0987654324','nguyen.family@gmail.com','Hà Nội',NULL,'2025-12-02 16:02:30',3,'ACTIVE'),(5,'Trường quốc tế Vinschool','0987654325','school@vinschool.edu.vn','Hà Nội',NULL,'2025-12-02 16:02:30',3,'ACTIVE'),(6,'Công ty Du lịch Mặt Trời','0987000123','tour@suntravel.vn','TP. HCM',NULL,'2025-12-02 16:02:30',21,'ACTIVE'),(7,'Nguyen van thuan','0706871283','test@gmail.com',NULL,NULL,'2025-12-02 09:23:15',3,'ACTIVE');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `driver_day_off`
--

DROP TABLE IF EXISTS `driver_day_off`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `driver_day_off` (
  `dayOffId` int NOT NULL AUTO_INCREMENT,
  `driverId` int NOT NULL,
  `startDate` date NOT NULL,
  `endDate` date NOT NULL,
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approvedBy` int DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dayOffId`),
  KEY `fk_doff_approve` (`approvedBy`),
  KEY `IX_DriverDayOff_DriverId` (`driverId`),
  CONSTRAINT `fk_doff_approve` FOREIGN KEY (`approvedBy`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_doff_driver` FOREIGN KEY (`driverId`) REFERENCES `drivers` (`driverId`),
  CONSTRAINT `driver_day_off_chk_1` CHECK ((`startDate` <= `endDate`))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driver_day_off`
--

LOCK TABLES `driver_day_off` WRITE;
/*!40000 ALTER TABLE `driver_day_off` DISABLE KEYS */;
INSERT INTO `driver_day_off` VALUES (1,1,'2025-11-17','2025-11-18','Việc gia đình',2,'APPROVED','2025-12-02 16:02:30'),(2,5,'2025-11-22','2025-11-23','Khám sức khỏe',11,'APPROVED','2025-12-02 16:02:30'),(3,9,'2025-11-27','2025-11-27','Nghỉ ốm',21,'REJECTED','2025-12-02 16:02:30');
/*!40000 ALTER TABLE `driver_day_off` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `driver_ratings`
--

DROP TABLE IF EXISTS `driver_ratings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `driver_ratings` (
  `ratingId` int NOT NULL AUTO_INCREMENT,
  `attitudeRating` int DEFAULT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `complianceRating` int DEFAULT NULL,
  `overallRating` decimal(3,2) DEFAULT NULL,
  `punctualityRating` int DEFAULT NULL,
  `ratedAt` datetime(6) DEFAULT NULL,
  `safetyRating` int DEFAULT NULL,
  `customerId` int DEFAULT NULL,
  `driverId` int NOT NULL,
  `ratedBy` int DEFAULT NULL,
  `tripId` int NOT NULL,
  PRIMARY KEY (`ratingId`),
  KEY `FK4ko1381xxvn98suy2p624lqpq` (`customerId`),
  KEY `FKgy2y4uqgr8kkyrblu305ptfux` (`driverId`),
  KEY `FK5epjsgjl1mhtxw185t7yenk5j` (`ratedBy`),
  KEY `FK7jt2kjuolog6lnw3w91o93grx` (`tripId`),
  CONSTRAINT `FK4ko1381xxvn98suy2p624lqpq` FOREIGN KEY (`customerId`) REFERENCES `customers` (`customerId`),
  CONSTRAINT `FK5epjsgjl1mhtxw185t7yenk5j` FOREIGN KEY (`ratedBy`) REFERENCES `users` (`userId`),
  CONSTRAINT `FK7jt2kjuolog6lnw3w91o93grx` FOREIGN KEY (`tripId`) REFERENCES `trips` (`tripId`),
  CONSTRAINT `FKgy2y4uqgr8kkyrblu305ptfux` FOREIGN KEY (`driverId`) REFERENCES `drivers` (`driverId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driver_ratings`
--

LOCK TABLES `driver_ratings` WRITE;
/*!40000 ALTER TABLE `driver_ratings` DISABLE KEYS */;
INSERT INTO `driver_ratings` VALUES (2,4,'Phục vụ tốt',4,4.50,4,'2025-12-02 16:02:30.000000',4,2,9,20,2);
/*!40000 ALTER TABLE `driver_ratings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `drivers`
--

DROP TABLE IF EXISTS `drivers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `drivers` (
  `driverId` int NOT NULL AUTO_INCREMENT,
  `employeeId` int NOT NULL,
  `branchId` int NOT NULL,
  `licenseNumber` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `licenseClass` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `licenseExpiry` date DEFAULT NULL,
  `healthCheckDate` date DEFAULT NULL,
  `rating` decimal(3,2) DEFAULT '5.00',
  `priorityLevel` int DEFAULT '1',
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('ACTIVE','AVAILABLE','ON_TRIP','OFF_DUTY','INACTIVE','ONTRIP') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'AVAILABLE',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`driverId`),
  UNIQUE KEY `employeeId` (`employeeId`),
  UNIQUE KEY `licenseNumber` (`licenseNumber`),
  KEY `IX_Drivers_BranchId` (`branchId`),
  CONSTRAINT `fk_drivers_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_drivers_emp` FOREIGN KEY (`employeeId`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `drivers_chk_1` CHECK (((`rating` >= 0) and (`rating` <= 5))),
  CONSTRAINT `drivers_chk_2` CHECK ((`priorityLevel` between 1 and 10))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drivers`
--

LOCK TABLES `drivers` WRITE;
/*!40000 ALTER TABLE `drivers` DISABLE KEYS */;
INSERT INTO `drivers` VALUES (1,7,1,'HN-D001','D','2028-12-31','2025-06-01',4.80,1,NULL,'AVAILABLE','2025-12-02 16:02:30'),(2,8,1,'HN-D002','E','2027-11-30','2025-07-01',4.90,2,NULL,'AVAILABLE','2025-12-02 16:02:30'),(3,9,1,'HN-D003','D','2029-01-15','2025-08-01',5.00,1,NULL,'ON_TRIP','2025-12-02 16:02:30'),(4,10,1,'HN-D004','E','2026-05-20','2025-03-01',4.70,3,NULL,'AVAILABLE','2025-12-02 16:02:30'),(5,16,2,'DN-D001','D','2028-10-10','2025-05-01',4.85,1,NULL,'AVAILABLE','2025-12-02 16:02:30'),(6,17,2,'DN-D002','E','2027-09-09','2025-04-01',4.75,2,NULL,'INACTIVE','2025-12-02 16:02:30'),(7,18,2,'DN-D003','D','2029-07-07','2025-10-01',4.95,1,NULL,'AVAILABLE','2025-12-02 16:02:30'),(8,19,2,'DN-D004','E','2026-04-04','2025-02-01',4.60,3,NULL,'AVAILABLE','2025-12-02 16:02:30'),(9,26,3,'HCM-D001','D','2028-12-12','2025-06-15',4.88,1,NULL,'AVAILABLE','2025-12-02 16:02:30'),(10,27,3,'HCM-D002','E','2027-10-10','2025-07-10',4.92,2,NULL,'AVAILABLE','2025-12-02 16:02:30'),(11,28,3,'HCM-D003','D','2029-08-08','2025-08-20',4.66,3,NULL,'ON_TRIP','2025-12-02 16:02:30');
/*!40000 ALTER TABLE `drivers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `employeeId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `branchId` int NOT NULL,
  `roleId` int NOT NULL,
  `status` enum('ACTIVE','INACTIVE','ONLEAVE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`employeeId`),
  KEY `fk_emp_user` (`userId`),
  KEY `fk_emp_role` (`roleId`),
  KEY `IX_Employees_BranchId` (`branchId`),
  CONSTRAINT `fk_emp_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_emp_role` FOREIGN KEY (`roleId`) REFERENCES `roles` (`roleId`),
  CONSTRAINT `fk_emp_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,1,1,1,'ACTIVE'),(2,2,1,2,'ACTIVE'),(3,3,1,3,'ACTIVE'),(4,4,1,3,'ACTIVE'),(5,5,1,5,'ACTIVE'),(6,6,1,6,'ACTIVE'),(7,7,1,4,'ACTIVE'),(8,8,1,4,'ACTIVE'),(9,9,1,4,'ACTIVE'),(10,10,1,4,'ACTIVE'),(11,11,2,2,'ACTIVE'),(12,12,2,3,'ACTIVE'),(13,13,2,3,'ACTIVE'),(14,14,2,5,'ACTIVE'),(15,15,2,6,'ACTIVE'),(16,16,2,4,'ACTIVE'),(17,17,2,4,'ACTIVE'),(18,18,2,4,'ACTIVE'),(19,19,2,4,'ACTIVE'),(20,20,3,2,'ACTIVE'),(21,21,3,3,'ACTIVE'),(22,22,3,3,'ACTIVE'),(23,23,3,5,'ACTIVE'),(24,24,3,6,'ACTIVE'),(25,25,3,4,'ACTIVE'),(26,26,3,4,'ACTIVE'),(27,27,3,4,'ACTIVE'),(28,28,3,4,'ACTIVE');
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expense_requests`
--

DROP TABLE IF EXISTS `expense_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expense_requests` (
  `expenseRequestId` int NOT NULL AUTO_INCREMENT,
  `amount` decimal(18,2) NOT NULL,
  `approvedAt` datetime(6) DEFAULT NULL,
  `createdAt` datetime(6) DEFAULT NULL,
  `note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rejectionReason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('APPROVED','PENDING','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expenseType` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `updatedAt` datetime(6) DEFAULT NULL,
  `approvedBy` int DEFAULT NULL,
  `branchId` int NOT NULL,
  `requesterId` int DEFAULT NULL,
  `vehicleId` int DEFAULT NULL,
  PRIMARY KEY (`expenseRequestId`),
  KEY `FK7e6xmnn0wtmbu4ojqljrhwwuu` (`approvedBy`),
  KEY `FKi50xdwp7fq4x2u1qgkmu9ssny` (`branchId`),
  KEY `FKtiu8dsnng66t861etnc0wkc6m` (`requesterId`),
  KEY `FK7khe3dqqvqxxxc3wya8ahxawu` (`vehicleId`),
  CONSTRAINT `FK7e6xmnn0wtmbu4ojqljrhwwuu` FOREIGN KEY (`approvedBy`) REFERENCES `users` (`userId`),
  CONSTRAINT `FK7khe3dqqvqxxxc3wya8ahxawu` FOREIGN KEY (`vehicleId`) REFERENCES `vehicles` (`vehicleId`),
  CONSTRAINT `FKi50xdwp7fq4x2u1qgkmu9ssny` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `FKtiu8dsnng66t861etnc0wkc6m` FOREIGN KEY (`requesterId`) REFERENCES `users` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense_requests`
--

LOCK TABLES `expense_requests` WRITE;
/*!40000 ALTER TABLE `expense_requests` DISABLE KEYS */;
INSERT INTO `expense_requests` VALUES (1,750000.00,'2025-12-02 16:02:30.000000','2025-11-30 16:02:30.000000','Xin tạm ứng phí ETC',NULL,'APPROVED','TOLL','2025-12-02 16:02:30.000000',2,1,2,2),(2,2500000.00,NULL,'2025-12-02 16:02:30.000000','Tạm ứng bảo dưỡng',NULL,'PENDING','MAINTENANCE',NULL,NULL,3,11,5);
/*!40000 ALTER TABLE `expense_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expenses`
--

DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expenses` (
  `expenseId` int NOT NULL AUTO_INCREMENT,
  `expenseCode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Mã chi phí',
  `branchId` int NOT NULL,
  `vehicleId` int DEFAULT NULL COMMENT 'Xe liên quan',
  `driverId` int DEFAULT NULL COMMENT 'Tài xế',
  `tripId` int DEFAULT NULL COMMENT 'Chuyến đi',
  `bookingId` int DEFAULT NULL COMMENT 'Đơn hàng',
  `expenseType` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Loại chi phí',
  `category` enum('FUEL','MAINTENANCE','SALARY','PARKING','INSURANCE','TOLL','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OTHER',
  `amount` decimal(18,2) NOT NULL COMMENT 'Số tiền',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `receiptUrl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Chứng từ',
  `status` enum('PENDING','APPROVED','REJECTED','PAID') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `approvedBy` int DEFAULT NULL,
  `approvedAt` datetime DEFAULT NULL,
  `rejectedReason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paidAt` datetime DEFAULT NULL,
  `expenseDate` datetime NOT NULL COMMENT 'Ngày phát sinh chi phí',
  `note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdBy` int DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`expenseId`),
  UNIQUE KEY `UK_expense_code` (`expenseCode`),
  KEY `FK_exp_branch` (`branchId`),
  KEY `FK_exp_vehicle` (`vehicleId`),
  KEY `FK_exp_driver` (`driverId`),
  KEY `FK_exp_trip` (`tripId`),
  KEY `FK_exp_booking` (`bookingId`),
  KEY `FK_exp_approvedBy` (`approvedBy`),
  KEY `FK_exp_createdBy` (`createdBy`),
  KEY `IX_expenses_status` (`status`),
  KEY `IX_expenses_category` (`category`),
  KEY `IX_expenses_expenseDate` (`expenseDate`),
  CONSTRAINT `FK_exp_approvedBy` FOREIGN KEY (`approvedBy`) REFERENCES `users` (`userId`) ON DELETE SET NULL,
  CONSTRAINT `FK_exp_booking` FOREIGN KEY (`bookingId`) REFERENCES `bookings` (`bookingId`) ON DELETE SET NULL,
  CONSTRAINT `FK_exp_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `FK_exp_createdBy` FOREIGN KEY (`createdBy`) REFERENCES `users` (`userId`) ON DELETE SET NULL,
  CONSTRAINT `FK_exp_driver` FOREIGN KEY (`driverId`) REFERENCES `drivers` (`driverId`) ON DELETE SET NULL,
  CONSTRAINT `FK_exp_trip` FOREIGN KEY (`tripId`) REFERENCES `trips` (`tripId`) ON DELETE SET NULL,
  CONSTRAINT `FK_exp_vehicle` FOREIGN KEY (`vehicleId`) REFERENCES `vehicles` (`vehicleId`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi phí thực tế - Module 6';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expenses`
--

LOCK TABLES `expenses` WRITE;
/*!40000 ALTER TABLE `expenses` DISABLE KEYS */;
INSERT INTO `expenses` VALUES (2,'EXP-2025-0002',3,8,11,8,8,'TOLL','TOLL',150000.00,'Phí cao tốc','/receipts/exp2.jpg','PAID',21,'2025-12-02 16:02:30',NULL,'2025-12-02 16:02:30','2025-12-01 16:02:30','',21,'2025-12-02 16:02:30','2025-12-02 16:02:30');
/*!40000 ALTER TABLE `expenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hire_types`
--

DROP TABLE IF EXISTS `hire_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hire_types` (
  `hireTypeId` int NOT NULL AUTO_INCREMENT,
  `code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isActive` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`hireTypeId`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hire_types`
--

LOCK TABLES `hire_types` WRITE;
/*!40000 ALTER TABLE `hire_types` DISABLE KEYS */;
INSERT INTO `hire_types` VALUES (1,'ONE_WAY','Thuê 1 chiều','Thuê xe đi 1 chiều',1),(2,'ROUND_TRIP','Thuê 2 chiều (trong ngày)','Thuê xe đi và về trong ngày',1),(3,'MULTI_DAY','Thuê nhiều ngày','Thuê xe theo gói nhiều ngày',1),(4,'PERIODIC','Thuê định kỳ','Thuê lặp lại (đưa đón nhân viên, học sinh)',1),(5,'AIRPORT_TRANSFER','Đưa/đón sân bay','Gói đưa đón sân bay 1 chiều',1),(6,'DAILY','Thuê theo ngày','Thuê xe trọn ngày',1);
/*!40000 ALTER TABLE `hire_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `invoiceId` int NOT NULL AUTO_INCREMENT,
  `branchId` int NOT NULL,
  `bookingId` int DEFAULT NULL,
  `customerId` int DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `isDeposit` tinyint(1) NOT NULL DEFAULT '0',
  `amount` decimal(18,2) NOT NULL,
  `paymentStatus` enum('UNPAID','PAID','REFUNDED','OVERDUE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'UNPAID',
  `status` enum('ACTIVE','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `invoiceDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdBy` int DEFAULT NULL,
  `invoiceNumber` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paymentTerms` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sentToEmail` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`invoiceId`),
  UNIQUE KEY `UKgwqud8ggt742y8g83ke44qvx` (`invoiceNumber`),
  KEY `fk_inv_createdBy` (`createdBy`),
  KEY `IX_Invoices_Branch` (`branchId`,`invoiceDate`),
  KEY `IX_Invoices_Type_Status` (`type`,`status`),
  KEY `IX_Invoices_Booking` (`bookingId`),
  KEY `IX_Invoices_Customer` (`customerId`),
  KEY `IX_Invoices_PaymentStatus` (`paymentStatus`),
  CONSTRAINT `fk_inv_booking` FOREIGN KEY (`bookingId`) REFERENCES `bookings` (`bookingId`),
  CONSTRAINT `fk_inv_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_inv_createdBy` FOREIGN KEY (`createdBy`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_inv_customer` FOREIGN KEY (`customerId`) REFERENCES `customers` (`customerId`),
  CONSTRAINT `invoices_chk_1` CHECK ((`amount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
INSERT INTO `invoices` VALUES (1,1,1,1,'INCOME',1,600000.00,'PAID','ACTIVE','2025-11-22 16:02:30','2025-12-02 16:02:30',NULL,'Đặt cọc Booking 1',3,'INV-HN-2025-0001','NET_7','contact@abc.com'),(2,1,1,1,'INCOME',0,600000.00,'PAID','ACTIVE','2025-11-23 16:02:30','2025-12-02 16:02:30',NULL,'Thu nốt Booking 1',3,'INV-HN-2025-0002','NET_0','contact@abc.com'),(3,3,2,2,'INCOME',1,1500000.00,'PAID','ACTIVE','2025-12-01 16:02:30','2025-12-02 16:02:30',NULL,'Cọc Booking 2',21,'INV-HCM-2025-0001','NET_7','info@huongviet.vn'),(4,3,2,2,'INCOME',0,1500000.00,'UNPAID','ACTIVE','2025-12-02 16:02:30','2025-12-02 16:02:30',NULL,'Thu nốt Booking 2',21,'INV-HCM-2025-0002','NET_7','info@huongviet.vn'),(5,2,3,3,'INCOME',1,900000.00,'PAID','ACTIVE','2025-11-30 16:02:30','2025-12-02 16:02:30',NULL,'Cọc Booking 3',12,'INV-DN-2025-0001','NET_7','hr@xyz.com'),(6,2,3,3,'INCOME',0,900000.00,'UNPAID','ACTIVE','2025-12-02 16:02:30','2025-12-02 16:02:30',NULL,'Thu nốt Booking 3',12,'INV-DN-2025-0002','NET_7','hr@xyz.com'),(7,1,4,4,'INCOME',1,10000000.00,'PAID','ACTIVE','2025-11-29 16:02:30','2025-12-02 16:02:30',NULL,'Cọc Booking 4',4,'INV-HN-2025-0003','NET_14','nguyen.family@gmail.com'),(8,1,4,4,'INCOME',0,15000000.00,'UNPAID','ACTIVE','2025-12-02 16:02:30','2025-12-02 16:02:30',NULL,'Thu nốt Booking 4',4,'INV-HN-2025-0004','NET_14','nguyen.family@gmail.com'),(9,1,5,5,'INCOME',1,1750000.00,'PAID','ACTIVE','2025-12-01 16:02:30','2025-12-02 16:02:30',NULL,'Cọc Booking 5',3,'INV-HN-2025-0005','NET_7','school@vinschool.edu.vn'),(10,3,6,6,'INCOME',1,5000000.00,'PAID','ACTIVE','2025-12-02 16:02:30','2025-12-02 16:02:30',NULL,'Cọc Booking 6',22,'INV-HCM-2025-0003','NET_7','tour@suntravel.vn'),(11,3,6,6,'INCOME',0,10000000.00,'UNPAID','ACTIVE','2025-12-02 16:02:30','2025-12-02 16:02:30',NULL,'Thu nốt Booking 6',22,'INV-HCM-2025-0004','NET_7','tour@suntravel.vn'),(12,2,9,3,'INCOME',0,600000.00,'PAID','ACTIVE','2025-11-29 16:02:30','2025-12-02 16:02:30',NULL,'Thanh toán Booking 9',13,'INV-DN-2025-0003','NET_7','hr@xyz.com'),(13,1,10,7,'INCOME',0,20035000.00,'PAID','ACTIVE','2025-12-02 09:27:53','2025-12-02 09:27:53',NULL,NULL,6,'INV-HN-2025-0006','NET_7',NULL);
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notificationId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `isRead` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`notificationId`),
  KEY `fk_notif_user` (`userId`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,2,'Yêu cầu nghỉ phép','Tài xế HN A vừa tạo yêu cầu nghỉ phép.','2025-12-02 16:02:30',0),(2,21,'Booking đã xác nhận','Booking #2 đã được xác nhận.','2025-12-02 16:02:30',0),(3,7,'Yêu cầu Nghỉ phép đã được duyệt','Yêu cầu nghỉ phép #1 đã được duyệt.','2025-12-02 16:02:30',0);
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_history`
--

DROP TABLE IF EXISTS `payment_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_history` (
  `paymentId` int NOT NULL AUTO_INCREMENT,
  `amount` decimal(18,2) NOT NULL,
  `createdAt` datetime(6) DEFAULT NULL,
  `note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paymentDate` datetime(6) NOT NULL,
  `paymentMethod` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `receiptNumber` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdBy` int DEFAULT NULL,
  `invoiceId` int NOT NULL,
  `confirmationStatus` enum('CONFIRMED','PENDING','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`paymentId`),
  KEY `FKrl36wsp0mglanfdwamk3cl9cv` (`createdBy`),
  KEY `FK585ytbhwcbntuhs3h16jih71p` (`invoiceId`),
  CONSTRAINT `FK585ytbhwcbntuhs3h16jih71p` FOREIGN KEY (`invoiceId`) REFERENCES `invoices` (`invoiceId`),
  CONSTRAINT `FKrl36wsp0mglanfdwamk3cl9cv` FOREIGN KEY (`createdBy`) REFERENCES `employees` (`employeeId`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_history`
--

LOCK TABLES `payment_history` WRITE;
/*!40000 ALTER TABLE `payment_history` DISABLE KEYS */;
INSERT INTO `payment_history` VALUES (1,600000.00,'2025-12-02 16:02:30.000000','Cọc Booking 1','2025-11-22 16:02:30.000000','BANK_TRANSFER','REC-2025-0001',5,1,'CONFIRMED'),(2,600000.00,'2025-12-02 16:02:30.000000','Thu nốt Booking 1','2025-11-23 16:02:30.000000','CASH','REC-2025-0002',5,2,'CONFIRMED'),(3,1500000.00,'2025-12-02 16:02:30.000000','Cọc Booking 2','2025-12-01 16:02:30.000000','QR','REC-2025-0003',23,3,'CONFIRMED'),(4,900000.00,'2025-12-02 16:02:30.000000','Cọc Booking 3','2025-11-30 16:02:30.000000','CASH','REC-2025-0004',14,5,'CONFIRMED'),(5,1750000.00,'2025-12-02 16:02:30.000000','Cọc Booking 5','2025-12-01 16:02:30.000000','QR','REC-2025-0005',5,9,'CONFIRMED'),(6,5000000.00,'2025-12-02 16:02:30.000000','Cọc Booking 6','2025-12-02 16:02:30.000000','QR','REC-2025-0006',23,10,'CONFIRMED'),(7,600000.00,'2025-12-02 16:02:30.000000','Thanh toán Booking 9','2025-11-29 16:02:30.000000','CASH','REC-2025-0007',14,12,'CONFIRMED'),(8,20035000.00,'2025-12-02 09:27:53.028560','[Thu tiền] ','2025-12-02 09:27:53.019516','CASH','REC-20251202-0001',6,13,'CONFIRMED');
/*!40000 ALTER TABLE `payment_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `roleId` int NOT NULL AUTO_INCREMENT,
  `roleName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','SUSPENDED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`roleId`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Admin','Quản trị viên hệ thống','ACTIVE'),(2,'Manager','Quản lý chi nhánh','ACTIVE'),(3,'Consultant','Tư vấn viên','ACTIVE'),(4,'Driver','Tài xế','ACTIVE'),(5,'Accountant','Kế toán','ACTIVE'),(6,'Coordinator','Điều phối viên','ACTIVE');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_alerts`
--

DROP TABLE IF EXISTS `system_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_alerts` (
  `alertId` int NOT NULL AUTO_INCREMENT,
  `acknowledgedAt` datetime(6) DEFAULT NULL,
  `alertType` enum('DRIVER_HEALTH_CHECK_DUE','DRIVER_LICENSE_EXPIRING','DRIVER_REST_REQUIRED','DRIVING_HOURS_EXCEEDED','REASSIGNMENT_NEEDED','SCHEDULE_CONFLICT','VEHICLE_INSPECTION_EXPIRING','VEHICLE_INSURANCE_EXPIRING','VEHICLE_MAINTENANCE_DUE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `createdAt` datetime(6) DEFAULT NULL,
  `expiresAt` datetime(6) DEFAULT NULL,
  `isAcknowledged` bit(1) DEFAULT NULL,
  `message` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `relatedEntityId` int DEFAULT NULL,
  `relatedEntityType` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `severity` enum('CRITICAL','HIGH','LOW','MEDIUM') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `acknowledgedBy` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  PRIMARY KEY (`alertId`),
  KEY `FKf30bipwvthh5w9noidsc3gmnm` (`acknowledgedBy`),
  KEY `FKfd03j9gu7v31x1unbdk6lg36o` (`branchId`),
  CONSTRAINT `FKf30bipwvthh5w9noidsc3gmnm` FOREIGN KEY (`acknowledgedBy`) REFERENCES `users` (`userId`),
  CONSTRAINT `FKfd03j9gu7v31x1unbdk6lg36o` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_alerts`
--

LOCK TABLES `system_alerts` WRITE;
/*!40000 ALTER TABLE `system_alerts` DISABLE KEYS */;
INSERT INTO `system_alerts` VALUES (1,'2025-12-02 16:02:30.000000','VEHICLE_INSPECTION_EXPIRING','2025-12-02 16:02:30.000000','2026-03-02 16:02:30.000000',_binary '','Xe 51C-333.33 sắp hết hạn đăng kiểm',9,'VEHICLE','HIGH','Xe sắp hết hạn đăng kiểm',20,3),(2,'2025-12-02 09:32:23.281552','DRIVER_LICENSE_EXPIRING','2025-12-02 16:02:30.000000','2026-01-31 16:02:30.000000',_binary '','Bằng lái HN-D004 sắp hết hạn',4,'DRIVER','MEDIUM','Bằng lái sắp hết hạn',5,1);
/*!40000 ALTER TABLE `system_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `settingId` int NOT NULL AUTO_INCREMENT,
  `settingKey` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `settingValue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `effectiveStartDate` date NOT NULL,
  `effectiveEndDate` date DEFAULT NULL,
  `valueType` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updatedBy` int DEFAULT NULL,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('ACTIVE','INACTIVE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`settingId`),
  UNIQUE KEY `settingKey` (`settingKey`),
  KEY `fk_sys_updBy` (`updatedBy`),
  CONSTRAINT `fk_sys_updBy` FOREIGN KEY (`updatedBy`) REFERENCES `employees` (`employeeId`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES (1,'VAT_RATE','0.08','2025-01-01',NULL,'decimal','Billing','Tỷ lệ VAT 8%',1,'2025-12-02 16:02:30','ACTIVE'),(2,'DEFAULT_HIGHWAY','true','2025-01-01',NULL,'boolean','Booking','Mặc định cao tốc',1,'2025-12-02 16:02:30','ACTIVE'),(3,'MAX_DRIVING_HOURS_PER_DAY','10','2025-01-01',NULL,'int','Driver','Tối đa giờ lái/ngày',1,'2025-12-02 16:02:30','ACTIVE'),(4,'ROUND_TRIP_MULTIPLIER','1.5','2025-01-01',NULL,'decimal','Pricing','Hệ số 2 chiều',1,'2025-12-02 16:02:30','ACTIVE'),(5,'DEFAULT_DEPOSIT_PERCENT','0.50','2025-01-01',NULL,'decimal','Billing','Tỷ lệ đặt cọc mặc định (50% tổng tiền)',1,'2025-12-05 14:08:21','ACTIVE'),(6,'CANCELLATION_FULL_DEPOSIT_LOSS_HOURS','24','2025-01-01',NULL,'int','Booking','Số giờ trước khi bắt đầu để mất toàn bộ tiền cọc',1,'2025-12-05 14:08:21','ACTIVE'),(7,'CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS','48','2025-01-01',NULL,'int','Booking','Số giờ trước khi bắt đầu để mất một phần tiền cọc',1,'2025-12-05 14:08:21','ACTIVE'),(8,'CANCELLATION_PARTIAL_DEPOSIT_PERCENT','0.30','2025-01-01',NULL,'decimal','Booking','Tỷ lệ mất cọc khi hủy trong khoảng thời gian (30%)',1,'2025-12-05 14:08:21','ACTIVE'),(9,'BOOKING_MAJOR_MODIFICATION_MIN_HOURS','72','2025-01-01',NULL,'int','Booking','Số giờ tối thiểu trước khi bắt đầu để sửa đổi lớn (72h = 3 ngày)',1,'2025-12-05 14:08:21','ACTIVE'),(10,'BOOKING_MINOR_MODIFICATION_MIN_HOURS','24','2025-01-01',NULL,'int','Booking','Số giờ tối thiểu trước khi bắt đầu để sửa đổi nhỏ (24h = 1 ngày)',1,'2025-12-05 14:08:21','ACTIVE'),(11,'SAME_DAY_TRIP_START_HOUR','6','2025-01-01',NULL,'int','Booking','Giờ bắt đầu để tính chuyến trong ngày (6h sáng)',1,'2025-12-05 14:08:21','ACTIVE'),(12,'SAME_DAY_TRIP_END_HOUR','23','2025-01-01',NULL,'int','Booking','Giờ kết thúc để tính chuyến trong ngày (23h tối)',1,'2025-12-05 14:08:21','ACTIVE'),(13,'HOLIDAY_SURCHARGE_RATE','0.25','2025-01-01',NULL,'decimal','Pricing','Phụ thu ngày lễ (25%)',1,'2025-12-05 14:08:21','ACTIVE'),(14,'WEEKEND_SURCHARGE_RATE','0.20','2025-01-01',NULL,'decimal','Pricing','Phụ thu cuối tuần (20%)',1,'2025-12-05 14:08:21','ACTIVE'),(15,'INTER_PROVINCE_DISTANCE_KM','100','2025-01-01',NULL,'int','Pricing','Khoảng cách tối thiểu để tính liên tỉnh (km)',1,'2025-12-05 14:08:21','ACTIVE'),(16,'MAX_CONTINUOUS_DRIVING_HOURS','4','2025-01-01',NULL,'int','Driver','Tối đa giờ lái liên tục (4 giờ)',1,'2025-12-05 14:08:21','ACTIVE'),(17,'MAX_DRIVING_HOURS_PER_WEEK','48','2025-01-01',NULL,'int','Driver','Tối đa giờ lái/tuần (48 giờ)',1,'2025-12-05 14:08:21','ACTIVE'),(18,'MAX_DRIVER_LEAVE_DAYS','2','2025-01-01',NULL,'int','Driver','Số ngày nghỉ tối đa tài xế có thể xin (2 ngày)',1,'2025-12-05 14:08:21','ACTIVE'),(19,'SINGLE_DRIVER_MAX_DISTANCE_KM','300','2025-01-01',NULL,'int','Driver','Khoảng cách tối đa cho 1 tài xế (300km)',1,'2025-12-05 14:08:21','ACTIVE');
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip_drivers`
--

DROP TABLE IF EXISTS `trip_drivers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trip_drivers` (
  `tripId` int NOT NULL,
  `driverId` int NOT NULL,
  `driverRole` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Main Driver',
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`tripId`,`driverId`),
  KEY `IX_TripDrivers_Driver` (`driverId`,`tripId`),
  CONSTRAINT `fk_td_driver` FOREIGN KEY (`driverId`) REFERENCES `drivers` (`driverId`),
  CONSTRAINT `fk_td_trip` FOREIGN KEY (`tripId`) REFERENCES `trips` (`tripId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip_drivers`
--

LOCK TABLES `trip_drivers` WRITE;
/*!40000 ALTER TABLE `trip_drivers` DISABLE KEYS */;
INSERT INTO `trip_drivers` VALUES (2,9,'Main Driver','HCM A chạy Trip #2'),(4,2,'Main Driver','HN B chạy Trip #4'),(5,1,'Main Driver','HN A chạy Trip #5'),(6,10,'Main Driver','HCM B chạy Trip #6'),(8,11,'Main Driver','HCM C chạy Trip #8'),(11,8,'Main Driver','DN D chạy Trip #11'),(12,4,'Main Driver','HN D chạy Trip #12');
/*!40000 ALTER TABLE `trip_drivers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip_vehicles`
--

DROP TABLE IF EXISTS `trip_vehicles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trip_vehicles` (
  `tripVehicleId` int NOT NULL AUTO_INCREMENT,
  `tripId` int NOT NULL,
  `vehicleId` int NOT NULL,
  `assignedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`tripVehicleId`),
  UNIQUE KEY `UQ_TripVehicles` (`tripId`,`vehicleId`),
  KEY `IX_TripVehicles_TripId` (`tripId`),
  KEY `IX_TripVehicles_Vehicle` (`vehicleId`,`tripId`),
  CONSTRAINT `fk_tv_trip` FOREIGN KEY (`tripId`) REFERENCES `trips` (`tripId`),
  CONSTRAINT `fk_tv_vehicle` FOREIGN KEY (`vehicleId`) REFERENCES `vehicles` (`vehicleId`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip_vehicles`
--

LOCK TABLES `trip_vehicles` WRITE;
/*!40000 ALTER TABLE `trip_vehicles` DISABLE KEYS */;
INSERT INTO `trip_vehicles` VALUES (2,2,7,'2025-12-02 16:02:30','Gán Limousine HCM cho Trip #2'),(4,4,3,'2025-12-02 16:02:30','Gán Samco cho Trip #4'),(5,5,1,'2025-12-02 16:02:30','Gán DCar cho Trip #5'),(6,6,9,'2025-12-02 16:02:30','Gán Mobihome cho Trip #6'),(8,8,8,'2025-12-02 16:02:30','Gán County cho Trip #8'),(10,10,7,'2025-12-02 16:02:30','Gán Limousine HCM cho Trip #10'),(11,11,6,'2025-12-02 16:02:30','Gán Universe cho Trip #11'),(12,12,1,'2025-12-02 16:02:30','Gán DCar cho Trip #12');
/*!40000 ALTER TABLE `trip_vehicles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trips`
--

DROP TABLE IF EXISTS `trips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trips` (
  `tripId` int NOT NULL AUTO_INCREMENT,
  `bookingId` int NOT NULL,
  `useHighway` tinyint(1) DEFAULT NULL,
  `startTime` datetime DEFAULT NULL,
  `endTime` datetime DEFAULT NULL,
  `startLocation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endLocation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `distance` decimal(10,2) DEFAULT NULL COMMENT 'Distance in kilometers from SerpAPI',
  `trafficStatus` enum('LIGHT','MODERATE','HEAVY','UNKNOWN') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'UNKNOWN' COMMENT 'Traffic status at booking time',
  `incidentalCosts` decimal(10,2) DEFAULT '0.00',
  `status` enum('SCHEDULED','ASSIGNED','ONGOING','COMPLETED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'SCHEDULED',
  PRIMARY KEY (`tripId`),
  KEY `IX_Trips_BookingId` (`bookingId`),
  KEY `IX_Trips_Status_Start` (`status`,`startTime`),
  KEY `IX_Trips_Distance` (`distance`),
  CONSTRAINT `fk_trip_booking` FOREIGN KEY (`bookingId`) REFERENCES `bookings` (`bookingId`),
  CONSTRAINT `trips_chk_1` CHECK (((`startTime` is null) or (`endTime` is null) or (`startTime` < `endTime`)))
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trips`
--

LOCK TABLES `trips` WRITE;
/*!40000 ALTER TABLE `trips` DISABLE KEYS */;
INSERT INTO `trips` VALUES (2,2,0,'2025-12-02 16:02:30',NULL,'Quận 1, TP. HCM','Ninh Bình',95.00,'LIGHT',0.00,'ASSIGNED'),(4,4,0,'2025-12-02 16:02:30',NULL,'KCN Thăng Long','Nội thành Hà Nội',30.00,'HEAVY',0.00,'ONGOING'),(5,5,1,'2025-12-01 16:02:30',NULL,'Times City, Hà Nội','Sân bay Nội Bài',45.00,'MODERATE',0.00,'ASSIGNED'),(6,6,1,'2025-12-02 16:02:30',NULL,'Quận 10, TP. HCM','Cần Thơ',180.00,'UNKNOWN',0.00,'SCHEDULED'),(8,8,0,'2025-12-02 16:02:30',NULL,'Quận 7, TP. HCM','Quận 1, TP. HCM',20.00,'LIGHT',0.00,'ASSIGNED'),(10,2,1,'2025-12-02 16:02:30',NULL,'TP. HCM','Ninh Bình',95.00,'MODERATE',0.00,'SCHEDULED'),(11,6,1,'2025-12-02 16:02:30',NULL,'Cần Thơ','Bến Tre',160.00,'UNKNOWN',0.00,'SCHEDULED'),(12,5,1,'2025-12-01 16:02:30',NULL,'Hà Nội','Vĩnh Phúc',75.00,'LIGHT',0.00,'ASSIGNED'),(13,10,0,'2025-12-03 09:22:00',NULL,'Hoàn Kiếm Lake, Hoàn Kiếm Lake, Hanoi, Vietnam','Trung Tâm, Trung Tâm, Lâm Đồng Province, Vietnam',NULL,'UNKNOWN',NULL,'SCHEDULED');
/*!40000 ALTER TABLE `trips` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `userId` int NOT NULL AUTO_INCREMENT,
  `roleId` int NOT NULL,
  `fullName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `passwordHash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','SUSPENDED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verified` tinyint(1) DEFAULT '0',
  `verification_token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userId`),
  UNIQUE KEY `username` (`username`),
  KEY `IX_Users_RoleId` (`roleId`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`roleId`) REFERENCES `roles` (`roleId`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,1,'Admin Tổng','admin','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','admin@ptcmss.com','0900000001',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(2,2,'Manager HN','manager_hn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','manager.hn@ptcmss.com','0900001001',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(3,3,'Consultant HN 1','consultant_hn1','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c1.hn@ptcmss.com','0900001002',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(4,3,'Consultant HN 2','consultant_hn2','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c2.hn@ptcmss.com','0900001003',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(5,5,'Accountant HN','accountant_hn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','acc.hn@ptcmss.com','0900001004',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(6,6,'Coordinator HN','coord_hn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','coord.hn@ptcmss.com','0900001005',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(7,4,'Tài xế HN A','driver_hn_a','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hn.a@ptcmss.com','0912345001',NULL,'ok sssssssA','ACTIVE',1,NULL,'2025-12-02 16:02:30'),(8,4,'Tài xế HN B','driver_hn_b','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hn.b@ptcmss.com','0912345002',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(9,4,'Tài xế HN C','driver_hn_c','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hn.c@ptcmss.com','0912345003',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(10,4,'Tài xế HN D','driver_hn_d','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hn.d@ptcmss.com','0912345004',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(11,2,'Manager DN','manager_dn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','manager.dn@ptcmss.com','0900002001',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(12,3,'Consultant DN 1','consultant_dn1','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c1.dn@ptcmss.com','0900002002',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(13,3,'Consultant DN 2','consultant_dn2','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c2.dn@ptcmss.com','0900002003',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(14,5,'Accountant DN','accountant_dn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','acc.dn@ptcmss.com','0900002004',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(15,6,'Coordinator DN','coord_dn','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','coord.dn@ptcmss.com','0900002005',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(16,4,'Tài xế DN A','driver_dn_a','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.dn.a@ptcmss.com','0912345101',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(17,4,'Tài xế DN B','driver_dn_b','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.dn.b@ptcmss.com','0912345102',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(18,4,'Tài xế DN C','driver_dn_c','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.dn.c@ptcmss.com','0912345103',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(19,4,'Tài xế DN D','driver_dn_d','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.dn.d@ptcmss.com','0912345104',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(20,2,'Manager HCM','manager_hcm','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','manager.hcm@ptcmss.com','0900003001',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(21,3,'Consultant HCM 1','consultant_hcm1','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c1.hcm@ptcmss.com','0900003002',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(22,3,'Consultant HCM 2','consultant_hcm2','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','c2.hcm@ptcmss.com','0900003003',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(23,5,'Accountant HCM','accountant_hcm','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','acc.hcm@ptcmss.com','0900003004',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(24,6,'Coordinator HCM','coord_hcm','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','coord.hcm@ptcmss.com','0900003005',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(25,4,'Tài xế HCM A','driver_hcm_a','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hcm.a@ptcmss.com','0912345201',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(26,4,'Tài xế HCM B','driver_hcm_b','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hcm.b@ptcmss.com','0912345202',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(27,4,'Tài xế HCM C','driver_hcm_c','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hcm.c@ptcmss.com','0912345203',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30'),(28,4,'Tài xế HCM D','driver_hcm_d','$2a$10$6GS3l5b0VDGXI9dm3GaPN.1uGCEbwXExR.uJEHp9KmeduOZmEq3HC','driver.hcm.d@ptcmss.com','0912345204',NULL,NULL,'ACTIVE',1,NULL,'2025-12-02 16:02:30');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_drivermonthlyperformance`
--

DROP TABLE IF EXISTS `v_drivermonthlyperformance`;
/*!50001 DROP VIEW IF EXISTS `v_drivermonthlyperformance`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_drivermonthlyperformance` AS SELECT 
 1 AS `driverId`,
 1 AS `month`,
 1 AS `trips_count`,
 1 AS `total_km`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_popularroutes`
--

DROP TABLE IF EXISTS `v_popularroutes`;
/*!50001 DROP VIEW IF EXISTS `v_popularroutes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_popularroutes` AS SELECT 
 1 AS `route_start`,
 1 AS `route_end`,
 1 AS `times`,
 1 AS `total_km`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_tripdistanceanalytics`
--

DROP TABLE IF EXISTS `v_tripdistanceanalytics`;
/*!50001 DROP VIEW IF EXISTS `v_tripdistanceanalytics`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_tripdistanceanalytics` AS SELECT 
 1 AS `tripId`,
 1 AS `distance`,
 1 AS `useHighway`,
 1 AS `startTime`,
 1 AS `endTime`,
 1 AS `hireTypeId`,
 1 AS `branchId`,
 1 AS `bookingStatus`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `vehicle_category_pricing`
--

DROP TABLE IF EXISTS `vehicle_category_pricing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicle_category_pricing` (
  `categoryId` int NOT NULL AUTO_INCREMENT,
  `categoryName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `seats` int DEFAULT NULL COMMENT 'Số ghế của danh mục xe',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `baseFare` decimal(10,2) DEFAULT NULL,
  `pricePerKm` decimal(10,2) DEFAULT NULL COMMENT 'Giá mỗi km (VNĐ/km) - Xe 16: 30k, Xe 30: 40k, Xe 45: 50k',
  `highwayFee` decimal(10,2) DEFAULT NULL,
  `fixedCosts` decimal(10,2) DEFAULT NULL,
  `effectiveDate` date DEFAULT (curdate()),
  `status` enum('ACTIVE','INACTIVE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `isPremium` tinyint(1) DEFAULT '0' COMMENT 'Đánh dấu xe hạng sang',
  `premiumSurcharge` decimal(10,2) DEFAULT '1000000.00' COMMENT 'Phụ phí xe hạng sang (VNĐ)',
  `sameDayFixedPrice` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`categoryId`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle_category_pricing`
--

LOCK TABLES `vehicle_category_pricing` WRITE;
/*!40000 ALTER TABLE `vehicle_category_pricing` DISABLE KEYS */;
INSERT INTO `vehicle_category_pricing` VALUES (1,'Xe 9 chỗ (Limousine)',9,'DCar/Solati Limousine',900000.00,15000.00,100000.00,0.00,'2025-12-02','ACTIVE','2025-12-02 16:02:30',0,0.00,NULL),(2,'Xe 16 chỗ',16,'Ford Transit, Mercedes Sprinter',1100000.00,30000.00,300000.00,0.00,'2025-12-02','ACTIVE','2025-12-02 16:02:30',0,0.00,2500000.00),(3,'Xe 29 chỗ',29,'Hyundai County, Samco Isuzu',1800000.00,40000.00,150000.00,0.00,'2025-12-02','ACTIVE','2025-12-02 16:02:30',0,0.00,3000000.00),(4,'Xe 45 chỗ',45,'Hyundai Universe',2500000.00,50000.00,200000.00,0.00,'2025-12-02','ACTIVE','2025-12-02 16:02:30',0,0.00,NULL),(5,'Xe giường nằm (40 chỗ)',40,'Xe giường nằm Thaco/Hyundai',3000000.00,30000.00,250000.00,0.00,'2025-12-02','ACTIVE','2025-12-02 16:02:30',0,0.00,NULL);
/*!40000 ALTER TABLE `vehicle_category_pricing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicles`
--

DROP TABLE IF EXISTS `vehicles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicles` (
  `vehicleId` int NOT NULL AUTO_INCREMENT,
  `categoryId` int NOT NULL,
  `branchId` int NOT NULL,
  `licensePlate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `brand` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `productionYear` int DEFAULT NULL,
  `inspectionExpiry` date DEFAULT NULL,
  `insuranceExpiry` date DEFAULT NULL,
  `status` enum('AVAILABLE','INUSE','MAINTENANCE','INACTIVE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'AVAILABLE',
  PRIMARY KEY (`vehicleId`),
  UNIQUE KEY `licensePlate` (`licensePlate`),
  KEY `fk_veh_cat` (`categoryId`),
  KEY `IX_Vehicles_BranchId` (`branchId`),
  CONSTRAINT `fk_veh_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_veh_cat` FOREIGN KEY (`categoryId`) REFERENCES `vehicle_category_pricing` (`categoryId`),
  CONSTRAINT `vehicles_chk_1` CHECK ((`productionYear` >= 1980))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicles`
--

LOCK TABLES `vehicles` WRITE;
/*!40000 ALTER TABLE `vehicles` DISABLE KEYS */;
INSERT INTO `vehicles` VALUES (1,1,1,'29A-111.11','DCar Limousine','DCar',9,2023,'2026-01-01','2029-01-01','AVAILABLE'),(2,2,1,'29A-222.22','Ford Transit','Ford',16,2022,'2026-01-01','2029-01-01','AVAILABLE'),(3,3,1,'29A-333.33','Samco Isuzu','Samco',29,2021,'2026-01-01','2029-01-01','AVAILABLE'),(4,1,2,'43A-111.11','DCar Limousine','DCar',9,2023,'2026-02-01','2029-02-01','AVAILABLE'),(5,2,2,'43B-222.22','Ford Transit','Ford',16,2022,'2026-02-01','2029-02-01','INUSE'),(6,4,2,'43C-333.33','Hyundai Universe','Hyundai',45,2021,'2026-02-01','2029-02-01','AVAILABLE'),(7,1,3,'51A-111.11','DCar Limousine','DCar',9,2023,'2026-03-01','2029-03-01','AVAILABLE'),(8,3,3,'51B-222.22','Hyundai County','Hyundai',29,2022,'2026-03-01','2029-03-01','AVAILABLE'),(9,5,3,'51C-333.33','Thaco Mobihome','Thaco',40,2021,'2026-03-01','2029-03-01','MAINTENANCE');
/*!40000 ALTER TABLE `vehicles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `v_drivermonthlyperformance`
--

/*!50001 DROP VIEW IF EXISTS `v_drivermonthlyperformance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY INVOKER */
/*!50001 VIEW `v_drivermonthlyperformance` AS select `d`.`driverId` AS `driverId`,date_format(`t`.`startTime`,'%Y-%m') AS `month`,count(`t`.`tripId`) AS `trips_count`,sum(`t`.`distance`) AS `total_km` from (((`drivers` `d` join `employees` `e` on((`e`.`employeeId` = `d`.`employeeId`))) join `bookings` `b` on((`b`.`branchId` = `d`.`branchId`))) left join `trips` `t` on((`t`.`bookingId` = `b`.`bookingId`))) group by `d`.`driverId`,date_format(`t`.`startTime`,'%Y-%m') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_popularroutes`
--

/*!50001 DROP VIEW IF EXISTS `v_popularroutes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY INVOKER */
/*!50001 VIEW `v_popularroutes` AS select `t`.`startLocation` AS `route_start`,`t`.`endLocation` AS `route_end`,count(0) AS `times`,sum(`t`.`distance`) AS `total_km` from `trips` `t` where ((`t`.`startLocation` is not null) and (`t`.`endLocation` is not null)) group by `t`.`startLocation`,`t`.`endLocation` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_tripdistanceanalytics`
--

/*!50001 DROP VIEW IF EXISTS `v_tripdistanceanalytics`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY INVOKER */
/*!50001 VIEW `v_tripdistanceanalytics` AS select `t`.`tripId` AS `tripId`,`t`.`distance` AS `distance`,`t`.`useHighway` AS `useHighway`,`t`.`startTime` AS `startTime`,`t`.`endTime` AS `endTime`,`b`.`hireTypeId` AS `hireTypeId`,`b`.`branchId` AS `branchId`,`b`.`status` AS `bookingStatus` from (`trips` `t` join `bookings` `b` on((`b`.`bookingId` = `t`.`bookingId`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-05 14:27:51
