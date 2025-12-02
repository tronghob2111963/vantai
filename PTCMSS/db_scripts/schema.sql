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
  `description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `setting_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `updated_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `setting_value` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK7p82g7l6uve2vd8l30djhxpel` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_settings`
--

LOCK TABLES `app_settings` WRITE;
/*!40000 ALTER TABLE `app_settings` DISABLE KEYS */;
INSERT INTO `app_settings` VALUES (1,'Tiền tố nội dung chuyển khoản (vd: PTCMSS)','qr.description_prefix','2025-12-01 07:41:32.370996','admin','VANTAI'),(2,'Mã ngân hàng theo chuẩn VietQR (vd: 970403 cho Sacombank)','qr.bank_code','2025-12-01 07:41:32.413959','admin','970403'),(3,'Tên chủ tài khoản (hiển thị trên QR)','qr.account_name','2025-12-01 07:41:32.419651','admin','NGUYEN VAN THUAN'),(4,'Số tài khoản ngân hàng nhận thanh toán','qr.account_number','2025-12-01 07:41:32.424190','admin','070122047995');
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
  `approvalNote` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approvalType` enum('DISCOUNT_REQUEST','DRIVER_DAY_OFF','EXPENSE_REQUEST','OVERTIME_REQUEST','SCHEDULE_CHANGE','VEHICLE_REPAIR') COLLATE utf8mb4_unicode_ci NOT NULL,
  `processedAt` datetime(6) DEFAULT NULL,
  `relatedEntityId` int NOT NULL,
  `requestReason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `requestedAt` datetime(6) DEFAULT NULL,
  `status` enum('APPROVED','CANCELLED','PENDING','REJECTED') COLLATE utf8mb4_unicode_ci NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `approval_history`
--

LOCK TABLES `approval_history` WRITE;
/*!40000 ALTER TABLE `approval_history` DISABLE KEYS */;
INSERT INTO `approval_history` VALUES (1,'ok','DRIVER_DAY_OFF','2025-11-23 17:52:33.385608',2,'Khám sức khỏe','2025-11-22 11:18:56.533556','APPROVED',1,1,9),(2,'ok','DRIVER_DAY_OFF','2025-11-25 12:23:44.503818',6,'khám sk và lo cho gđ','2025-11-24 12:25:03.394147','APPROVED',1,2,10),(3,'hf','EXPENSE_REQUEST','2025-11-26 04:36:58.529529',1,'Yêu cầu tạm ứng: TOLL - 75765.00 VNĐ','2025-11-25 18:57:39.870975','APPROVED',1,1,8),(4,'rtjs','DRIVER_DAY_OFF','2025-11-27 16:06:25.947825',7,'ốm đau quá','2025-11-27 15:13:16.085098','APPROVED',1,1,8),(5,'ok nhé','DRIVER_DAY_OFF','2025-11-27 17:07:22.605980',8,'k muốn đi làm nữa r','2025-11-27 17:06:41.780107','APPROVED',3,1,8),(6,'','DRIVER_DAY_OFF','2025-11-27 17:11:34.690171',9,'dqwDAQSDSDASD','2025-11-27 17:11:19.220663','APPROVED',3,1,8),(7,'ok','DRIVER_DAY_OFF','2025-11-27 17:32:12.461226',10,'jgjihgjhjjhjjd','2025-11-27 17:31:45.196836','APPROVED',3,2,10),(8,'đ','DRIVER_DAY_OFF','2025-11-27 18:12:56.755203',11,'zdfhebnrfsadfgrrtegg','2025-11-27 18:12:31.244296','APPROVED',4,1,8),(9,'đ','DRIVER_DAY_OFF','2025-11-27 18:19:42.942348',12,'sđsfsdfsdfsd','2025-11-27 18:19:35.233811','APPROVED',4,1,8),(10,'','DRIVER_DAY_OFF','2025-11-27 18:30:34.490412',13,'nvvsfdfasdas','2025-11-27 18:30:28.453907','APPROVED',4,1,8),(11,'s','DRIVER_DAY_OFF','2025-11-27 18:38:16.784627',14,'qdsasdasdasdas','2025-11-27 18:38:12.327991','APPROVED',4,1,8),(12,'ád','DRIVER_DAY_OFF','2025-11-27 19:10:29.650918',15,'qdsadsadsad','2025-11-27 19:10:26.130152','APPROVED',4,1,8),(13,'bjb','DRIVER_DAY_OFF','2025-12-01 02:57:21.549412',16,'ádfwsdfsdfsdfsd','2025-12-01 02:55:58.888261','APPROVED',20,1,8);
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
INSERT INTO `booking_vehicle_details` VALUES (1,3,1),(2,2,1),(3,3,2),(4,4,1),(5,1,1),(8,1,1),(9,3,1),(10,1,1),(11,1,1),(12,2,1),(13,2,1),(14,3,1),(15,2,1),(16,3,1),(17,3,2),(18,2,1),(19,2,1);
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
  `useHighway` tinyint(1) DEFAULT NULL,
  `bookingDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `estimatedCost` decimal(12,2) DEFAULT NULL,
  `depositAmount` decimal(12,2) DEFAULT '0.00',
  `totalCost` decimal(12,2) DEFAULT '0.00',
  `totalDistance` decimal(10,2) DEFAULT NULL COMMENT 'Total distance of all trips (km)',
  `totalDuration` int DEFAULT NULL COMMENT 'Total estimated duration (minutes)',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `isHoliday` tinyint(1) DEFAULT '0' COMMENT 'Có phải ngày lễ không',
  `isWeekend` tinyint(1) DEFAULT '0' COMMENT 'Có phải cuối tuần không',
  `additionalPickupPoints` int DEFAULT '0' COMMENT 'Số điểm đón thêm so với ban đầu',
  `additionalDropoffPoints` int DEFAULT '0' COMMENT 'Số điểm trả thêm so với ban đầu',
  PRIMARY KEY (`bookingId`),
  KEY `fk_book_cons` (`consultantId`),
  KEY `IX_Bookings_BranchId` (`branchId`),
  KEY `IX_Bookings_Customer_Status` (`customerId`,`status`),
  KEY `IX_Bookings_HireType` (`hireTypeId`),
  KEY `IX_Bookings_Distance` (`totalDistance`),
  CONSTRAINT `fk_book_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_book_cons` FOREIGN KEY (`consultantId`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_book_cust` FOREIGN KEY (`customerId`) REFERENCES `customers` (`customerId`),
  CONSTRAINT `fk_book_hire` FOREIGN KEY (`hireTypeId`) REFERENCES `hire_types` (`hireTypeId`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
INSERT INTO `bookings` VALUES (1,2,1,5,2,1,'2025-11-12 11:23:08',3500000.00,1000000.00,3800000.00,NULL,NULL,'COMPLETED','Đoàn 25 khách, đi Hà Nội - Hạ Long 2 chiều','2025-11-12 11:23:08','2025-11-12 11:23:08',0,0,0,0),(2,4,3,6,5,1,'2025-11-12 11:23:08',1200000.00,500000.00,1200000.00,NULL,NULL,'CONFIRMED','Đón sân bay TSN về Quận 7 (16 chỗ)','2025-11-12 11:23:08','2025-12-02 03:55:10',0,0,0,0),(3,1,1,5,4,0,'2025-11-12 11:23:08',25000000.00,10000000.00,0.00,NULL,NULL,'INPROGRESS','Hợp đồng đưa đón nhân viên KCN Thăng Long T11/2025','2025-11-12 11:23:08','2025-12-02 03:55:10',0,0,0,0),(4,3,2,6,3,1,'2025-11-12 11:23:08',15000000.00,500000.00,0.00,NULL,NULL,'PENDING','Thuê xe 45 chỗ đi 3N2Đ Đà Nẵng - Huế - Hội An','2025-11-12 11:23:08','2025-11-24 18:13:53',0,0,0,0),(5,5,1,5,1,1,'2025-11-12 11:23:08',1000000.00,1000000.00,1000000.00,NULL,NULL,'CONFIRMED','Thuê 1 chiều xe Limo (9 chỗ) đi Nội Bài','2025-11-12 11:23:08','2025-12-02 03:55:10',0,0,0,0),(8,8,1,1,NULL,0,'2025-11-21 17:35:52',811646.68,0.00,811646.68,NULL,NULL,'CONFIRMED',NULL,'2025-11-21 17:35:52','2025-11-26 16:08:14',0,0,0,0),(9,8,1,1,NULL,0,'2025-11-24 10:15:32',3519205.55,0.00,3519205.55,NULL,NULL,'COMPLETED',NULL,'2025-11-24 10:15:32','2025-12-02 01:24:19',0,0,0,0),(10,8,1,5,NULL,0,'2025-11-27 21:03:41',67741800.00,0.00,67741800.00,4516.12,NULL,'PENDING',NULL,'2025-11-27 21:03:41','2025-12-02 03:55:10',0,0,0,0),(11,8,1,5,2,0,'2025-11-27 21:19:56',30617062.50,0.00,30617062.50,NULL,NULL,'PENDING','đón ở hgj','2025-11-27 21:19:56','2025-11-28 04:19:55',1,0,0,0),(12,8,1,6,2,0,'2025-11-29 04:22:35',77808350.00,0.00,77808350.00,NULL,NULL,'PENDING',NULL,'2025-11-29 04:22:35','2025-11-29 11:22:34',0,0,0,0),(13,8,1,6,2,0,'2025-11-30 17:37:56',69181850.00,0.00,69181850.00,NULL,NULL,'CANCELLED','nhớ chạy cẩn thận','2025-11-30 17:37:56','2025-12-01 02:38:22',0,0,0,0),(14,8,1,5,1,0,'2025-11-30 18:23:46',8096000.00,0.00,8096000.00,NULL,NULL,'CANCELLED',NULL,'2025-11-30 18:23:46','2025-12-01 02:41:23',0,0,0,0),(15,8,1,6,1,0,'2025-11-30 19:45:30',17538200.00,0.00,17538200.00,NULL,NULL,'COMPLETED','222','2025-11-30 19:45:30','2025-12-02 03:55:10',0,0,0,0),(16,8,1,6,1,0,'2025-12-01 19:46:04',132847200.00,0.00,132847200.00,NULL,NULL,'PENDING','OK ','2025-12-01 19:46:04','2025-12-02 02:46:03',0,0,0,0),(17,8,1,6,1,0,'2025-12-01 19:48:26',4575200.00,0.00,4575200.00,NULL,NULL,'PENDING',NULL,'2025-12-01 19:48:26','2025-12-02 02:48:25',0,0,0,0),(18,8,1,6,1,0,'2025-12-01 19:51:44',1202000.00,0.00,1202000.00,NULL,NULL,'PENDING',NULL,'2025-12-01 19:51:44','2025-12-02 02:51:44',0,0,0,0),(19,8,1,6,1,0,'2025-12-01 19:58:01',1452800.00,0.00,1452800.00,NULL,NULL,'DRAFT',NULL,'2025-12-01 19:58:01','2025-12-02 02:58:00',0,0,0,0);
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
  `branchName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `managerId` int DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','UNDERREVIEW','CLOSED') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`branchId`),
  KEY `FK_Branches_Manager` (`managerId`),
  CONSTRAINT `FK_Branches_Manager` FOREIGN KEY (`managerId`) REFERENCES `employees` (`employeeId`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` VALUES (1,'Chi nhánh Hà Nội','123 Láng Hạ, Đống Đa, Hà Nội',2,'ACTIVE','2025-11-12 11:23:08',NULL),(2,'Chi nhánh Đà Nẵng','456 Nguyễn Văn Linh, Hải Châu, Đà Nẵng',3,'ACTIVE','2025-11-12 11:23:08',NULL),(3,'Chi nhánh TP. HCM','789 Võ Thị Sáu, Quận 3, TP. HCM',4,'ACTIVE','2025-11-12 11:23:08',NULL),(4,'Chi nhánh Hải Phòng','10 Lê Hồng Phong, Ngô Quyền, Hải Phòng',NULL,'INACTIVE','2025-11-12 11:23:08',NULL),(5,'Chi nhánh Quảng Ninh','55 Trần Hưng Đạo, Hạ Long, Quảng Ninh',2,'ACTIVE','2025-11-12 11:23:08',NULL),(6,'Bà Rịa - Vũng Tàu','st tss',NULL,'ACTIVE','2025-11-27 13:20:58',NULL),(7,'Chi nhánh Đồng Nai','test',17,'ACTIVE','2025-12-01 18:45:58',NULL);
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
  `fullName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `createdBy` int DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`customerId`),
  KEY `IX_Customers_CreatedBy` (`createdBy`),
  CONSTRAINT `fk_cust_createdBy` FOREIGN KEY (`createdBy`) REFERENCES `employees` (`employeeId`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Công ty TNHH ABC (KCN Thăng Long)','0987654321','contact@abc.com','KCN Thăng Long, Đông Anh, Hà Nội',NULL,'2025-11-12 11:23:08',5,'ACTIVE'),(2,'Đoàn du lịch Hướng Việt','0987654322','info@huongviet.vn','Hoàn Kiếm, Hà Nội',NULL,'2025-11-12 11:23:08',6,'ACTIVE'),(3,'Công ty CP XYZ (Đà Nẵng)','0987654323','hr@xyz.com','Hải Châu, Đà Nẵng',NULL,'2025-11-12 11:23:08',5,'ACTIVE'),(4,'Gia đình ông Trần Văn Hùng','0987654324','hung.tran@gmail.com','Quận 7, TP. HCM',NULL,'2025-11-12 11:23:08',6,'ACTIVE'),(5,'Trường quốc tế Vinschool','0987654325','school@vinschool.edu.vn','Times City, Hà Nội',NULL,'2025-11-12 11:23:08',5,'ACTIVE'),(8,'NGUYỄN VĂN THUẦN','0706871283','thuanhero1@gmail.com',NULL,NULL,'2025-11-21 17:35:52',1,'ACTIVE');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `debt_reminder_history`
--

DROP TABLE IF EXISTS `debt_reminder_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `debt_reminder_history` (
  `reminderId` int NOT NULL AUTO_INCREMENT,
  `invoiceId` int NOT NULL,
  `reminderDate` datetime(6) NOT NULL,
  `reminderType` varchar(20) NOT NULL COMMENT 'EMAIL, SMS, PHONE',
  `recipient` varchar(100) DEFAULT NULL,
  `message` text,
  `sentBy` int DEFAULT NULL,
  `createdAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`reminderId`),
  KEY `invoiceId` (`invoiceId`),
  KEY `sentBy` (`sentBy`),
  CONSTRAINT `debt_reminder_history_ibfk_1` FOREIGN KEY (`invoiceId`) REFERENCES `invoices` (`invoiceId`) ON DELETE CASCADE,
  CONSTRAINT `debt_reminder_history_ibfk_2` FOREIGN KEY (`sentBy`) REFERENCES `users` (`userId`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `debt_reminder_history`
--

LOCK TABLES `debt_reminder_history` WRITE;
/*!40000 ALTER TABLE `debt_reminder_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `debt_reminder_history` ENABLE KEYS */;
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
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approvedBy` int DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dayOffId`),
  KEY `fk_doff_approve` (`approvedBy`),
  KEY `IX_DriverDayOff_DriverId` (`driverId`),
  CONSTRAINT `fk_doff_approve` FOREIGN KEY (`approvedBy`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_doff_driver` FOREIGN KEY (`driverId`) REFERENCES `drivers` (`driverId`),
  CONSTRAINT `driver_day_off_chk_1` CHECK ((`startDate` <= `endDate`))
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driver_day_off`
--

LOCK TABLES `driver_day_off` WRITE;
/*!40000 ALTER TABLE `driver_day_off` DISABLE KEYS */;
INSERT INTO `driver_day_off` VALUES (1,1,'2025-10-30','2025-10-30','Việc gia đình',2,'APPROVED','2025-11-12 11:23:08'),(2,2,'2025-11-05','2025-11-06','Khám sức khỏe',NULL,'APPROVED','2025-11-12 11:23:08'),(3,3,'2025-10-20','2025-10-21','Về quê',3,'APPROVED','2025-11-12 11:23:08'),(4,4,'2025-10-29','2025-10-29','Nghỉ ốm',4,'REJECTED','2025-11-12 11:23:08'),(5,6,'2025-11-01','2025-11-30','Nghỉ không lương',3,'APPROVED','2025-11-12 11:23:08'),(6,3,'2025-11-26','2025-11-27','khám sk và lo cho gđ',NULL,'APPROVED','2025-11-24 12:23:48'),(7,1,'2025-11-28','2025-11-29','ốm đau quá',NULL,'APPROVED','2025-11-27 15:09:23'),(8,1,'2025-12-02','2025-12-03','k muốn đi làm nữa r',NULL,'APPROVED','2025-11-27 17:06:42'),(9,1,'2025-12-03','2025-12-04','dqwDAQSDSDASD',NULL,'APPROVED','2025-11-27 17:11:19'),(10,3,'2025-11-29','2025-11-30','jgjihgjhjjhjjd',NULL,'APPROVED','2025-11-27 17:31:45'),(11,1,'2025-12-05','2025-12-06','zdfhebnrfsadfgrrtegg',NULL,'APPROVED','2025-11-27 18:12:31'),(12,1,'2025-12-02','2025-12-03','sđsfsdfsdfsd',NULL,'CANCELLED','2025-11-27 18:19:35'),(13,1,'2025-11-30','2025-12-01','nvvsfdfasdas',NULL,'APPROVED','2025-11-27 18:30:28'),(14,1,'2025-12-05','2025-12-06','qdsasdasdasdas',NULL,'CANCELLED','2025-11-27 18:38:12'),(15,1,'2025-12-06','2025-12-07','qdsadsadsad',NULL,'CANCELLED','2025-11-27 19:10:26'),(16,1,'2025-12-17','2025-12-18','ádfwsdfsdfsdfsd',NULL,'CANCELLED','2025-12-01 02:55:59');
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
  `comment` text COLLATE utf8mb4_unicode_ci,
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driver_ratings`
--

LOCK TABLES `driver_ratings` WRITE;
/*!40000 ALTER TABLE `driver_ratings` DISABLE KEYS */;
INSERT INTO `driver_ratings` VALUES (1,2,'rất tuyệt',5,NULL,5,'2025-11-23 18:40:12.658397',3,2,1,1,1);
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
  `licenseNumber` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `licenseClass` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `licenseExpiry` date DEFAULT NULL,
  `healthCheckDate` date DEFAULT NULL,
  `rating` decimal(3,2) DEFAULT '5.00',
  `priorityLevel` int DEFAULT '1',
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drivers`
--

LOCK TABLES `drivers` WRITE;
/*!40000 ALTER TABLE `drivers` DISABLE KEYS */;
INSERT INTO `drivers` VALUES (1,8,1,'HN12345','D','2029-01-01','2025-06-01',5.00,1,'','ACTIVE','2025-11-12 11:23:08'),(2,9,1,'HN67890','E','2027-10-10','2025-05-01',5.00,1,NULL,'AVAILABLE','2025-11-12 11:23:08'),(3,10,2,'DN55555','D','2029-01-15','2025-07-01',5.00,1,NULL,'AVAILABLE','2025-11-12 11:23:08'),(4,11,3,'HCM88888','E','2026-05-20','2025-03-01',5.00,1,NULL,'ONTRIP','2025-11-12 11:23:08'),(5,12,1,'HN45678','D','2028-02-14','2025-08-01',5.00,1,NULL,'AVAILABLE','2025-11-12 11:23:08'),(6,13,2,'DN11111','E','2027-11-30','2025-09-10',5.00,1,NULL,'INACTIVE','2025-11-12 11:23:08'),(7,14,3,'HCM22222','D','2029-07-07','2025-10-01',5.00,1,NULL,'AVAILABLE','2025-11-12 11:23:08'),(8,33,4,'0902726372',NULL,NULL,NULL,NULL,NULL,NULL,'AVAILABLE','2025-12-02 05:21:21');
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
  `status` enum('ACTIVE','INACTIVE','ONLEAVE') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`employeeId`),
  KEY `fk_emp_user` (`userId`),
  KEY `fk_emp_role` (`roleId`),
  KEY `IX_Employees_BranchId` (`branchId`),
  CONSTRAINT `fk_emp_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_emp_role` FOREIGN KEY (`roleId`) REFERENCES `roles` (`roleId`),
  CONSTRAINT `fk_emp_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,1,1,1,'ACTIVE'),(2,2,1,2,'INACTIVE'),(3,3,2,2,'ACTIVE'),(4,4,3,2,'ACTIVE'),(5,5,1,3,'ACTIVE'),(6,6,1,3,'ACTIVE'),(7,7,1,5,'ACTIVE'),(8,8,1,4,'ACTIVE'),(9,9,1,4,'ACTIVE'),(10,10,2,4,'ACTIVE'),(11,11,3,4,'ACTIVE'),(12,12,1,4,'ACTIVE'),(13,13,2,4,'ACTIVE'),(14,14,3,4,'ACTIVE'),(15,15,3,2,'ACTIVE'),(16,16,2,2,'ACTIVE'),(17,17,1,2,'ACTIVE'),(18,18,2,2,'ACTIVE'),(19,19,1,2,'ACTIVE'),(20,20,3,6,'ACTIVE'),(21,21,1,6,'ACTIVE'),(22,22,1,2,'INACTIVE'),(33,33,4,4,'ACTIVE');
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expense_request_attachments`
--

DROP TABLE IF EXISTS `expense_request_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expense_request_attachments` (
  `expenseRequestId` int NOT NULL,
  `fileUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `FKgjxq6bf6u84jyf7k07w0vuldw` (`expenseRequestId`),
  CONSTRAINT `FKgjxq6bf6u84jyf7k07w0vuldw` FOREIGN KEY (`expenseRequestId`) REFERENCES `expense_requests` (`expenseRequestId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense_request_attachments`
--

LOCK TABLES `expense_request_attachments` WRITE;
/*!40000 ALTER TABLE `expense_request_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `expense_request_attachments` ENABLE KEYS */;
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
  `note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rejectionReason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('APPROVED','PENDING','REJECTED') COLLATE utf8mb4_unicode_ci NOT NULL,
  `expenseType` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense_requests`
--

LOCK TABLES `expense_requests` WRITE;
/*!40000 ALTER TABLE `expense_requests` DISABLE KEYS */;
INSERT INTO `expense_requests` VALUES (1,75765.00,'2025-11-26 04:36:58.531525','2025-11-25 18:55:08.135678','tại km 45',NULL,'APPROVED','TOLL','2025-11-26 04:36:58.546038',1,1,8,NULL);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi phí thực tế - Module 6';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expenses`
--

LOCK TABLES `expenses` WRITE;
/*!40000 ALTER TABLE `expenses` DISABLE KEYS */;
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
  `code` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
INSERT INTO `hire_types` VALUES (1,'ONE_WAY','Thuê 1 chiều','Thuê xe đi 1 chiều',1),(2,'ROUND_TRIP','Thuê 2 chiều (trong ngày)','Thuê xe đi và về trong ngày',1),(3,'MULTI_DAY','Thuê nhiều ngày','Thuê xe theo gói nhiều ngày',1),(4,'PERIODIC','Thuê định kỳ','Thuê lặp lại (đưa đón nhân viên, học sinh)',1),(5,'AIRPORT_TRANSFER','Đưa/đón sân bay','Gói đưa đón sân bay 1 chiều',1),(6,'DAILY','Thuê theo ngày','Thuê xe trọn ngày (tính theo ngày)',1);
/*!40000 ALTER TABLE `hire_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice_items`
--

DROP TABLE IF EXISTS `invoice_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoice_items` (
  `itemId` int NOT NULL AUTO_INCREMENT,
  `invoiceId` int NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Mô tả dòng hóa đơn',
  `quantity` decimal(10,2) NOT NULL DEFAULT '1.00' COMMENT 'Số lượng',
  `unitPrice` decimal(18,2) NOT NULL COMMENT 'Đơn giá',
  `amount` decimal(18,2) GENERATED ALWAYS AS ((`quantity` * `unitPrice`)) STORED COMMENT 'Thành tiền (tự động)',
  `taxRate` decimal(5,2) DEFAULT '0.00' COMMENT 'Thuế suất (%)',
  `taxAmount` decimal(18,2) DEFAULT '0.00' COMMENT 'Tiền thuế',
  `note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`itemId`),
  KEY `FK_item_invoice` (`invoiceId`),
  KEY `IX_invoice_items_invoiceId` (`invoiceId`),
  CONSTRAINT `FK_item_invoice` FOREIGN KEY (`invoiceId`) REFERENCES `invoices` (`invoiceId`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết dòng hóa đơn - Module 6';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice_items`
--

LOCK TABLES `invoice_items` WRITE;
/*!40000 ALTER TABLE `invoice_items` DISABLE KEYS */;
INSERT INTO `invoice_items` (`itemId`, `invoiceId`, `description`, `quantity`, `unitPrice`, `taxRate`, `taxAmount`, `note`, `createdAt`, `updatedAt`) VALUES (1,2,'Vận chuyển Hà Nội - Hải Phòng',1.00,3800000.00,10.00,380000.00,NULL,'2025-11-22 20:26:01','2025-11-22 20:26:01'),(2,3,'Vận chuyển nội thành TP.HCM',1.00,1200000.00,10.00,120000.00,NULL,'2025-11-22 20:26:01','2025-11-22 20:26:01'),(3,4,'Vận chuyển container 40ft',1.00,25000000.00,10.00,2500000.00,NULL,'2025-11-22 20:26:01','2025-11-22 20:26:01'),(4,5,'Vận chuyển Hà Nội - Đà Nẵng',1.00,1000000.00,10.00,100000.00,NULL,'2025-11-22 20:26:01','2025-11-22 20:26:01');
/*!40000 ALTER TABLE `invoice_items` ENABLE KEYS */;
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
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `costType` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isDeposit` tinyint(1) NOT NULL DEFAULT '0',
  `amount` decimal(18,2) NOT NULL,
  `paymentMethod` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paymentStatus` enum('UNPAID','PAID','REFUNDED','OVERDUE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'UNPAID',
  `status` enum('ACTIVE','CANCELLED') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `invoiceDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `img` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `requestedBy` int DEFAULT NULL,
  `createdBy` int DEFAULT NULL,
  `approvedBy` int DEFAULT NULL,
  `approvedAt` datetime DEFAULT NULL,
  `bankAccount` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bankName` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancellationReason` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancelledAt` datetime(6) DEFAULT NULL,
  `cashierName` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contactNote` text COLLATE utf8mb4_unicode_ci,
  `debtLabel` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dueDate` date DEFAULT NULL,
  `invoiceNumber` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paymentTerms` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `promiseToPayDate` date DEFAULT NULL,
  `receiptNumber` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referenceNumber` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sentAt` datetime(6) DEFAULT NULL,
  `sentToEmail` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subtotal` decimal(18,2) DEFAULT NULL,
  `vatAmount` decimal(18,2) DEFAULT '0.00',
  `cancelledBy` int DEFAULT NULL,
  PRIMARY KEY (`invoiceId`),
  UNIQUE KEY `UKgwqud8ggt742y8g83ke44qvx` (`invoiceNumber`),
  KEY `fk_inv_reqDriver` (`requestedBy`),
  KEY `fk_inv_createdBy` (`createdBy`),
  KEY `fk_inv_approvedBy` (`approvedBy`),
  KEY `IX_Invoices_Branch` (`branchId`,`invoiceDate`),
  KEY `IX_Invoices_Type_Status` (`type`,`status`),
  KEY `IX_Invoices_Booking` (`bookingId`),
  KEY `IX_Invoices_Customer` (`customerId`),
  KEY `IX_Invoices_PaymentStatus` (`paymentStatus`),
  KEY `FK55ebms893efmjp7rbhv14yngb` (`cancelledBy`),
  CONSTRAINT `FK55ebms893efmjp7rbhv14yngb` FOREIGN KEY (`cancelledBy`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_inv_approvedBy` FOREIGN KEY (`approvedBy`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_inv_booking` FOREIGN KEY (`bookingId`) REFERENCES `bookings` (`bookingId`),
  CONSTRAINT `fk_inv_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_inv_createdBy` FOREIGN KEY (`createdBy`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_inv_customer` FOREIGN KEY (`customerId`) REFERENCES `customers` (`customerId`),
  CONSTRAINT `fk_inv_reqDriver` FOREIGN KEY (`requestedBy`) REFERENCES `drivers` (`driverId`),
  CONSTRAINT `invoices_chk_1` CHECK ((`amount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
INSERT INTO `invoices` VALUES (1,1,1,2,'Income',NULL,1,1000000.00,'Chuyển khoản','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Đặt cọc Booking 1',NULL,5,2,'2025-11-12 11:23:08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(2,1,1,2,'Income',NULL,0,2800000.00,'Tiền mặt','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Thu nốt Booking 1',NULL,5,2,'2025-11-12 11:23:08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(3,3,2,4,'Income',NULL,1,500000.00,'Chuyển khoản','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Đặt cọc Booking 2',NULL,6,4,'2025-11-12 11:23:08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(4,1,3,1,'Income',NULL,0,25000000.00,'Chuyển khoản','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Thanh toán HĐ định kỳ T11',NULL,5,2,'2025-11-12 11:23:08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(5,1,5,5,'Income',NULL,0,1000000.00,'Chuyển khoản','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Thanh toán Booking 5',NULL,5,2,'2025-11-12 11:23:08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(6,1,1,NULL,'Expense','fuel',0,1000000.00,'Tiền mặt','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Đổ dầu xe Trip 1',1,8,2,'2025-11-12 11:23:08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(7,1,1,NULL,'Expense','toll',0,300000.00,'Thẻ ETC','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Phí cao tốc HN-HL Trip 1',1,8,2,'2025-11-12 11:23:08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(8,2,NULL,NULL,'Expense','maintenance',0,5000000.00,'Chuyển khoản','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Bảo dưỡng xe 43B-777.77',NULL,3,3,'2025-11-12 11:23:08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(9,1,8,8,'INCOME',NULL,1,811646.68,'QR','UNPAID','ACTIVE','2025-11-21 22:57:33','2025-11-21 22:57:33',NULL,'đơn 1',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(10,1,8,8,'INCOME',NULL,1,811646.68,'QR','UNPAID','ACTIVE','2025-11-21 23:09:30','2025-11-21 23:09:30',NULL,'Cọc đơn ORD-8 - Nguyễn Văn Thuần',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(11,1,8,8,'INCOME',NULL,1,811646.68,'QR','UNPAID','ACTIVE','2025-11-21 23:14:13','2025-11-21 23:14:13',NULL,'Cọc đơn ORD-8 - Nguyễn Văn Thuần',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(12,1,8,8,'INCOME',NULL,1,811646.68,'QR','UNPAID','ACTIVE','2025-11-21 23:16:47','2025-11-21 23:16:47',NULL,'Cọc đơn ORD-8 - Nguyễn Văn Thuần',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(13,1,8,8,'INCOME',NULL,1,811646.68,'QR','UNPAID','ACTIVE','2025-11-21 23:19:16','2025-11-21 23:19:16',NULL,'Cọc đơn ORD-8 - Nguyễn Văn Thuần',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(14,1,8,8,'INCOME',NULL,1,811646.68,'QR','UNPAID','ACTIVE','2025-11-21 23:23:20','2025-11-21 23:23:20',NULL,'Cọc đơn ORD-8 - Nguyễn Văn Thuần',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(15,1,8,8,'INCOME',NULL,1,811646.68,'QR','UNPAID','ACTIVE','2025-11-21 23:27:27','2025-11-21 23:27:27',NULL,'Cọc đơn ORD-8 - Nguyễn Văn Thuần',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-24 10:31:48.597856','thuanhero1@gmail.com',NULL,0.00,NULL),(16,1,NULL,2,'INCOME',NULL,0,5500000.00,'BANK_TRANSFER','PAID','ACTIVE','2025-11-22 11:19:08','2025-11-22 11:19:08',NULL,'Updated invoice',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Customer promised to pay by Dec 1','NORMAL',NULL,'INV-HN-2025-0001','NET_14','2025-12-15',NULL,NULL,'2025-11-24 10:31:42.436300','info@huongviet.vn',NULL,0.00,NULL),(17,1,NULL,NULL,'EXPENSE','fuel',0,2000000.00,'CASH','UNPAID','ACTIVE','2025-11-22 11:19:08','2025-11-22 11:19:08',NULL,'Test expense invoice',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INV-HN-2025-0002','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(18,1,1,2,'INCOME',NULL,1,500000.00,'CASH','OVERDUE','ACTIVE','2025-11-22 11:19:22','2025-11-22 11:19:22',NULL,'Test deposit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INV-HN-2025-0003','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(19,1,NULL,2,'INCOME',NULL,0,5500000.00,'BANK_TRANSFER','PAID','ACTIVE','2025-11-22 11:20:49','2025-11-22 11:20:49',NULL,'Updated invoice',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Customer promised to pay by Dec 1','NORMAL',NULL,'INV-HN-2025-0004','NET_14','2025-12-15',NULL,NULL,'2025-11-22 11:20:49.309207','test@example.com',NULL,0.00,NULL),(20,1,NULL,NULL,'EXPENSE','fuel',0,2000000.00,'CASH','UNPAID','ACTIVE','2025-11-22 11:20:49','2025-11-22 11:20:49',NULL,'Test expense invoice',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INV-HN-2025-0005','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(21,1,1,2,'INCOME',NULL,1,500000.00,'CASH','PAID','ACTIVE','2025-11-22 11:21:02','2025-11-22 11:21:02',NULL,'Test deposit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INV-HN-2025-0006','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(22,1,NULL,2,'INCOME',NULL,0,5500000.00,'BANK_TRANSFER','PAID','ACTIVE','2025-11-22 11:21:20','2025-11-22 11:21:20',NULL,'Updated invoice',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Customer promised to pay by Dec 1','NORMAL',NULL,'INV-HN-2025-0007','NET_14','2025-12-15',NULL,NULL,'2025-11-22 11:21:20.117962','test@example.com',NULL,0.00,NULL),(23,1,NULL,NULL,'EXPENSE','fuel',0,2000000.00,'CASH','UNPAID','ACTIVE','2025-11-22 11:21:20','2025-11-22 11:21:20',NULL,'Test expense invoice',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INV-HN-2025-0008','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(24,1,1,2,'INCOME',NULL,1,500000.00,'CASH','PAID','ACTIVE','2025-11-22 11:21:33','2025-11-22 11:21:33',NULL,'Test deposit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INV-HN-2025-0009','NET_7',NULL,NULL,NULL,'2025-11-25 18:47:32.304909','info@huongviet.vn',NULL,0.00,NULL),(25,1,9,8,'INCOME',NULL,1,1760000.00,'CASH','OVERDUE','ACTIVE','2025-11-26 04:04:09','2025-11-26 04:04:09',NULL,'ok',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-26','INV-HN-2025-0010','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(26,1,9,8,'INCOME',NULL,1,1760000.00,'CASH','PAID','ACTIVE','2025-11-26 04:04:09','2025-11-26 04:04:09',NULL,'ok',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(27,1,8,8,'INCOME',NULL,1,406000.00,'CASH','UNPAID','ACTIVE','2025-11-26 04:21:19','2025-11-26 04:21:19',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-26','INV-HN-2025-0011','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(28,3,2,4,'INCOME',NULL,1,210000.00,'CASH','UNPAID','ACTIVE','2025-11-26 04:21:40','2025-11-26 04:21:40',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-26','INV-HCM-2025-0001','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(29,3,2,4,'INCOME',NULL,1,700000.00,'CASH','UNPAID','ACTIVE','2025-11-26 04:21:51','2025-11-26 04:21:51',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-26','INV-HCM-2025-0002','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(30,3,2,4,'INCOME',NULL,1,700000.00,'CASH','UNPAID','ACTIVE','2025-11-26 04:22:02','2025-11-26 04:22:02',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-26','INV-HCM-2025-0003','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(31,3,2,4,'INCOME',NULL,1,700000.00,'CASH','UNPAID','ACTIVE','2025-11-26 04:22:12','2025-11-26 04:22:12',NULL,'ss',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-26','INV-HCM-2025-0004','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(32,3,2,4,'INCOME',NULL,1,350000.00,'CASH','PAID','ACTIVE','2025-11-26 04:22:23','2025-11-26 04:22:23',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-26','INV-HCM-2025-0005','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(33,1,9,8,'INCOME',NULL,1,1759205.00,'CASH','PAID','ACTIVE','2025-11-26 04:27:09','2025-11-26 04:27:09',NULL,'ịoiuy',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-26','INV-HN-2025-0012','NET_7',NULL,NULL,NULL,'2025-11-26 04:37:19.438393','thuanhero1@gmail.com',NULL,0.00,NULL),(34,3,2,4,'INCOME',NULL,1,350000.00,'CASH','PAID','ACTIVE','2025-11-26 04:50:29','2025-11-26 04:50:29',NULL,'jh',NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INV-HCM-2025-0006','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(35,3,2,4,'INCOME',NULL,1,175000.00,'CASH','UNPAID','ACTIVE','2025-11-26 04:50:54','2025-11-26 04:50:54',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INV-HCM-2025-0007','NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(36,1,1,2,'INCOME',NULL,0,2800000.00,'CASH','PAID','ACTIVE','2025-11-30 16:13:24','2025-11-30 16:13:24',NULL,'ss',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-30','INV-HN-2025-0013','NET_0',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(37,1,9,8,'INCOME',NULL,0,3519205.55,'QR','OVERDUE','ACTIVE','2025-12-01 05:46:24','2025-12-01 05:46:24',NULL,'Thu tiền từ khách - Chuyến #9',NULL,8,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(38,1,9,8,'INCOME',NULL,0,3519205.55,'QR','OVERDUE','ACTIVE','2025-12-01 05:51:45','2025-12-01 05:51:45',NULL,'Thu tiền từ khách - Chuyến #9',NULL,8,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(39,1,9,8,'INCOME',NULL,0,3519205.55,'QR','OVERDUE','ACTIVE','2025-12-01 05:51:47','2025-12-01 05:51:47',NULL,'Thu tiền từ khách - Chuyến #9',NULL,8,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(40,1,9,8,'INCOME',NULL,0,3519205.55,'QR','OVERDUE','ACTIVE','2025-12-01 05:51:50','2025-12-01 05:51:50',NULL,'Thu tiền từ khách - Chuyến #9',NULL,8,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(41,1,9,8,'INCOME',NULL,0,3519205.55,'QR','PAID','ACTIVE','2025-12-01 05:55:19','2025-12-01 05:55:19',NULL,'Thu tiền từ khách - Chuyến #9',NULL,8,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(42,1,15,8,'INCOME',NULL,1,17538200.00,'QR','PAID','ACTIVE','2025-12-01 18:16:31','2025-12-01 18:16:31',NULL,'Cọc đơn ORD-15 - NGUYỄN VĂN THUẦN',NULL,5,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'NET_7',NULL,NULL,NULL,NULL,NULL,NULL,0.00,NULL),(43,1,15,8,'INCOME',NULL,1,17538200.00,'QR','PAID','ACTIVE','2025-12-01 18:17:44','2025-12-01 18:17:44',NULL,'Cọc đơn ORD-15 - NGUYỄN VĂN THUẦN',NULL,5,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'NET_7',NULL,NULL,NULL,'2025-12-01 18:22:27.800427','thuanhero1@gmail.com',NULL,0.00,NULL);
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
  `title` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `isRead` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`notificationId`),
  KEY `fk_notif_user` (`userId`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,2,'Yêu cầu nghỉ phép','Tài xế Trần Văn B vừa tạo yêu cầu nghỉ phép.','2025-11-12 11:23:08',0),(2,6,'Booking đã xác nhận','Booking #2 (Đón sân bay) đã được xác nhận.','2025-11-12 11:23:08',0),(3,11,'Giao việc mới','Bạn được gán lái Trip #2 (Đón sân bay TSN).','2025-11-12 11:23:08',0),(4,1,'Hợp đồng mới','Hợp đồng thuê định kỳ (Booking #3) vừa được kích hoạt.','2025-11-12 11:23:08',1),(5,7,'Hóa đơn đã duyệt','Hóa đơn chi phí (Xăng dầu Trip 1) đã được duyệt.','2025-11-12 11:23:08',0),(6,10,'Yêu cầu Nghỉ phép đã được duyệt','Yêu cầu nghỉ phép #10 của bạn đã được duyệt.','2025-11-27 17:32:12',0),(12,8,'Yêu cầu Nghỉ phép đã được duyệt','Yêu cầu nghỉ phép #16 của bạn đã được duyệt.','2025-12-01 02:57:22',0);
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
  `bankAccount` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bankName` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cashierName` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime(6) DEFAULT NULL,
  `note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paymentDate` datetime(6) NOT NULL,
  `paymentMethod` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `receiptNumber` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referenceNumber` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdBy` int DEFAULT NULL,
  `invoiceId` int NOT NULL,
  `confirmationStatus` enum('CONFIRMED','PENDING','REJECTED') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`paymentId`),
  KEY `FKrl36wsp0mglanfdwamk3cl9cv` (`createdBy`),
  KEY `FK585ytbhwcbntuhs3h16jih71p` (`invoiceId`),
  CONSTRAINT `FK585ytbhwcbntuhs3h16jih71p` FOREIGN KEY (`invoiceId`) REFERENCES `invoices` (`invoiceId`),
  CONSTRAINT `FKrl36wsp0mglanfdwamk3cl9cv` FOREIGN KEY (`createdBy`) REFERENCES `employees` (`employeeId`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_history`
--

LOCK TABLES `payment_history` WRITE;
/*!40000 ALTER TABLE `payment_history` DISABLE KEYS */;
INSERT INTO `payment_history` VALUES (1,2000000.00,NULL,NULL,NULL,'2025-11-22 11:19:07.889259','Partial payment test','2025-11-22 11:19:07.885606','CASH',NULL,NULL,NULL,16,NULL),(2,2000000.00,NULL,NULL,NULL,'2025-11-22 11:20:49.250944','Partial payment test','2025-11-22 11:20:49.250371','CASH',NULL,NULL,NULL,19,NULL),(3,2000000.00,NULL,NULL,NULL,'2025-11-22 11:21:20.064336','Partial payment test','2025-11-22 11:21:20.064336','CASH',NULL,NULL,NULL,22,NULL),(4,500000.00,NULL,NULL,'cọc','2025-11-25 18:29:53.382435','cọc','2025-11-25 18:29:53.370353','CASH',NULL,NULL,1,24,NULL),(5,600000.00,NULL,NULL,NULL,'2025-11-25 18:44:24.011314','ok đó ','2025-11-25 18:44:24.010315','CASH',NULL,NULL,1,23,NULL),(6,880000.00,NULL,NULL,NULL,'2025-11-26 04:19:48.654375','yg','2025-11-26 04:19:48.648391','CASH',NULL,NULL,1,25,NULL),(7,350000.00,NULL,NULL,NULL,'2025-11-26 04:37:35.118254',NULL,'2025-11-26 04:37:35.109529','CASH',NULL,NULL,1,32,'CONFIRMED'),(8,2800000.00,NULL,NULL,NULL,'2025-11-30 16:36:06.174435','ok','2025-11-30 16:36:06.123032','CASH','REC-20251130-0001',NULL,NULL,21,'CONFIRMED'),(10,3519205.55,NULL,NULL,NULL,'2025-12-01 05:55:42.726130','[Thu tiền] ssss','2025-12-01 05:55:42.724131','CASH','REC-20251201-0001',NULL,NULL,41,'CONFIRMED'),(11,17538200.00,NULL,NULL,NULL,'2025-12-01 18:16:30.832861','Cọc đơn ORD-15 - NGUYỄN VĂN THUẦN','2025-12-01 18:16:30.832862','QR',NULL,NULL,5,42,'CONFIRMED'),(12,17538200.00,NULL,NULL,NULL,'2025-12-01 18:17:43.653589','Cọc đơn ORD-15 - NGUYỄN VĂN THUẦN','2025-12-01 18:17:43.651590','QR',NULL,NULL,5,43,'CONFIRMED');
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
  `roleName` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','SUSPENDED') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`roleId`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Admin','Quản trị viên hệ thống','ACTIVE'),(2,'Manager','Quản lý chi nhánh','ACTIVE'),(3,'Consultant','Điều hành/Tư vấn','ACTIVE'),(4,'Driver','Tài xế','ACTIVE'),(5,'Accountant','Kế toán','ACTIVE'),(6,'Coordinator','Điều phối viên','ACTIVE');
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
  `alertType` enum('DRIVER_HEALTH_CHECK_DUE','DRIVER_LICENSE_EXPIRING','DRIVER_REST_REQUIRED','DRIVING_HOURS_EXCEEDED','REASSIGNMENT_NEEDED','SCHEDULE_CONFLICT','VEHICLE_INSPECTION_EXPIRING','VEHICLE_INSURANCE_EXPIRING','VEHICLE_MAINTENANCE_DUE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `createdAt` datetime(6) DEFAULT NULL,
  `expiresAt` datetime(6) DEFAULT NULL,
  `isAcknowledged` bit(1) DEFAULT NULL,
  `message` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `relatedEntityId` int DEFAULT NULL,
  `relatedEntityType` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `severity` enum('CRITICAL','HIGH','LOW','MEDIUM') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `acknowledgedBy` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  PRIMARY KEY (`alertId`),
  KEY `FKf30bipwvthh5w9noidsc3gmnm` (`acknowledgedBy`),
  KEY `FKfd03j9gu7v31x1unbdk6lg36o` (`branchId`),
  CONSTRAINT `FKf30bipwvthh5w9noidsc3gmnm` FOREIGN KEY (`acknowledgedBy`) REFERENCES `users` (`userId`),
  CONSTRAINT `FKfd03j9gu7v31x1unbdk6lg36o` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_alerts`
--

LOCK TABLES `system_alerts` WRITE;
/*!40000 ALTER TABLE `system_alerts` DISABLE KEYS */;
INSERT INTO `system_alerts` VALUES (1,'2025-11-24 09:08:34.373846','VEHICLE_INSPECTION_EXPIRING','2025-11-23 23:00:00.074932','2026-02-21 23:00:00.040927',_binary '','Xe 29A-333.33 đã hết hạn đăng kiểm từ ngày 2025-08-30',3,'VEHICLE','CRITICAL','Xe đã hết hạn đăng kiểm',1,1),(2,'2025-11-24 09:08:33.621706','VEHICLE_INSPECTION_EXPIRING','2025-11-23 23:00:00.118102','2026-02-21 23:00:00.117098',_binary '','Xe 43B-444.44 sẽ hết hạn đăng kiểm trong 6 ngày (ngày 2025-11-30)',4,'VEHICLE','HIGH','Xe sắp hết hạn đăng kiểm',1,2),(3,'2025-11-24 09:08:32.554451','VEHICLE_INSPECTION_EXPIRING','2025-11-23 23:00:00.121979','2026-02-21 23:00:00.121979',_binary '','Xe 43B-777.77 đã hết hạn đăng kiểm từ ngày 2025-02-14',7,'VEHICLE','CRITICAL','Xe đã hết hạn đăng kiểm',1,2),(4,'2025-11-26 04:37:29.200164','VEHICLE_INSPECTION_EXPIRING','2025-11-25 23:09:23.811890','2026-02-23 23:09:23.743317',_binary '','Xe 29A-333.33 đã hết hạn đăng kiểm từ ngày 2025-08-30',3,'VEHICLE','CRITICAL','Xe đã hết hạn đăng kiểm',1,1),(5,'2025-11-26 04:37:06.152629','VEHICLE_INSPECTION_EXPIRING','2025-11-25 23:09:23.845441','2026-02-23 23:09:23.845442',_binary '','Xe 43B-444.44 sẽ hết hạn đăng kiểm trong 4 ngày (ngày 2025-11-30)',4,'VEHICLE','HIGH','Xe sắp hết hạn đăng kiểm',1,2),(6,'2025-11-26 04:37:28.597441','VEHICLE_INSPECTION_EXPIRING','2025-11-25 23:09:23.850443','2026-02-23 23:09:23.849442',_binary '','Xe 43B-777.77 đã hết hạn đăng kiểm từ ngày 2025-02-14',7,'VEHICLE','CRITICAL','Xe đã hết hạn đăng kiểm',1,2),(7,'2025-11-30 16:26:02.404980','VEHICLE_INSPECTION_EXPIRING','2025-11-28 23:39:12.234292','2026-02-26 23:39:12.230525',_binary '','Xe 29A-333.33 đã hết hạn đăng kiểm từ ngày 2025-08-30',3,'VEHICLE','CRITICAL','Xe đã hết hạn đăng kiểm',7,1),(8,'2025-11-30 16:26:02.077022','VEHICLE_INSPECTION_EXPIRING','2025-11-28 23:39:12.480121','2026-02-26 23:39:12.478113',_binary '','Xe 43B-444.44 sẽ hết hạn đăng kiểm trong 1 ngày (ngày 2025-11-30)',4,'VEHICLE','HIGH','Xe sắp hết hạn đăng kiểm',7,2),(9,'2025-11-30 16:26:01.740192','VEHICLE_INSPECTION_EXPIRING','2025-11-28 23:39:12.657102','2026-02-26 23:39:12.656593',_binary '','Xe 43B-777.77 đã hết hạn đăng kiểm từ ngày 2025-02-14',7,'VEHICLE','CRITICAL','Xe đã hết hạn đăng kiểm',7,2),(10,'2025-11-30 16:26:00.605288','DRIVER_HEALTH_CHECK_DUE','2025-11-28 23:39:12.699143','2026-02-26 23:39:12.697133',_binary '','Tài xế Tài Xế Nguyễn Văn A cần khám sức khỏe định kỳ trong 2 ngày',1,'DRIVER','HIGH','Sắp đến hạn khám sức khỏe',7,1),(11,'2025-11-29 03:40:23.249779','DRIVER_HEALTH_CHECK_DUE','2025-11-28 23:39:12.705178','2026-02-26 23:39:12.705178',_binary '','Tài xế Tài Xế Trần Văn B đã quá hạn khám sức khỏe định kỳ',2,'DRIVER','HIGH','Sắp đến hạn khám sức khỏe',20,1),(12,'2025-11-29 03:39:04.457313','DRIVER_HEALTH_CHECK_DUE','2025-11-28 23:39:12.713094','2026-02-26 23:39:12.711344',_binary '','Tài xế Tài Xế Phạm Đình D đã quá hạn khám sức khỏe định kỳ',4,'DRIVER','HIGH','Sắp đến hạn khám sức khỏe',20,3),(13,NULL,'VEHICLE_INSPECTION_EXPIRING','2025-11-30 23:01:19.671174','2026-02-28 23:01:19.621785',_binary '\0','Xe 29A-333.33 đã hết hạn đăng kiểm từ ngày 2025-08-30',3,'VEHICLE','CRITICAL','Xe đã hết hạn đăng kiểm',NULL,1),(14,NULL,'VEHICLE_INSPECTION_EXPIRING','2025-11-30 23:01:19.704100','2026-02-28 23:01:19.703097',_binary '\0','Xe 43B-444.44 đã hết hạn đăng kiểm từ ngày 2025-11-30',4,'VEHICLE','CRITICAL','Xe đã hết hạn đăng kiểm',NULL,2),(15,NULL,'VEHICLE_INSPECTION_EXPIRING','2025-11-30 23:01:19.708099','2026-02-28 23:01:19.707099',_binary '\0','Xe 43B-777.77 đã hết hạn đăng kiểm từ ngày 2025-02-14',7,'VEHICLE','CRITICAL','Xe đã hết hạn đăng kiểm',NULL,2),(16,NULL,'DRIVER_HEALTH_CHECK_DUE','2025-11-30 23:01:26.020710','2026-02-28 23:01:26.019711',_binary '\0','Tài xế Tài Xế Nguyễn Văn A cần khám sức khỏe định kỳ trong 0 ngày',1,'DRIVER','HIGH','Sắp đến hạn khám sức khỏe',NULL,1),(17,NULL,'DRIVER_HEALTH_CHECK_DUE','2025-11-30 23:01:26.031790','2026-02-28 23:01:26.030794',_binary '\0','Tài xế Tài Xế Trần Văn B đã quá hạn khám sức khỏe định kỳ',2,'DRIVER','HIGH','Sắp đến hạn khám sức khỏe',NULL,1),(18,'2025-12-01 08:03:06.328342','DRIVER_HEALTH_CHECK_DUE','2025-11-30 23:01:26.050029','2026-02-28 23:01:26.049522',_binary '','Tài xế Tài Xế Phạm Đình D đã quá hạn khám sức khỏe định kỳ',4,'DRIVER','HIGH','Sắp đến hạn khám sức khỏe',2,3),(19,'2025-12-01 08:03:05.729262','DRIVING_HOURS_EXCEEDED','2025-11-30 23:01:26.195841','2026-02-28 23:01:26.195324',_binary '','Tài xế Tài Xế Nguyễn Văn A đã lái 666 giờ trong tuần (vượt quá 48 giờ/tuần)',1,'DRIVER','HIGH','Vượt giới hạn giờ lái trong tuần',2,1);
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
  `settingKey` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settingValue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `effectiveStartDate` date NOT NULL,
  `effectiveEndDate` date DEFAULT NULL,
  `valueType` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updatedBy` int DEFAULT NULL,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('ACTIVE','INACTIVE') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
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
INSERT INTO `system_settings` VALUES (1,'VAT_RATE','0.08','2025-01-01',NULL,'decimal','Billing','Tỷ lệ thuế VAT (8%)',1,'2025-11-12 11:23:08','ACTIVE'),(2,'DEFAULT_HIGHWAY','true','2025-01-01',NULL,'boolean','Booking','Mặc định chọn cao tốc khi tạo booking',1,'2025-11-12 11:23:08','ACTIVE'),(3,'MAX_DRIVING_HOURS_PER_DAY','10','2025-01-01',NULL,'int','Driver','Số giờ lái xe tối đa của tài xế/ngày',1,'2025-11-12 11:23:08','ACTIVE'),(4,'SUPPORT_HOTLINE','1900 1234','2025-01-01',NULL,'string','General','Số hotline hỗ trợ khách hàng',1,'2025-11-12 11:23:08','ACTIVE'),(5,'LATE_PAYMENT_FEE_RATE','0.05','2025-01-01',NULL,'decimal','Billing','Lãi suất phạt thanh toán chậm (5%/ngày)',1,'2025-11-12 11:23:08','ACTIVE'),(6,'HOLIDAY_SURCHARGE_RATE','0.25','2025-11-25',NULL,'decimal','Pricing','Phụ phí ngày lễ (25%)',1,'2025-11-25 08:53:06','ACTIVE'),(7,'WEEKEND_SURCHARGE_RATE','0.20','2025-11-25',NULL,'decimal','Pricing','Phụ phí cuối tuần (20%)',1,'2025-11-25 08:53:06','ACTIVE'),(8,'ONE_WAY_DISCOUNT_RATE','0.6667','2025-11-25',NULL,'decimal','Pricing','Hệ số giảm giá 1 chiều (2/3)',1,'2025-11-25 08:53:06','ACTIVE'),(9,'ADDITIONAL_POINT_SURCHARGE_RATE','0.05','2025-11-25',NULL,'decimal','Pricing','Phụ phí mỗi điểm đón/trả thêm (5%)',1,'2025-11-25 08:53:06','ACTIVE'),(10,'DEFAULT_DEPOSIT_PERCENT','0.50','2025-01-01',NULL,'decimal','Booking','Tỷ lệ đặt cọc mặc định (50%)',1,'2025-11-25 15:20:00','ACTIVE'),(11,'MAX_DEPOSIT_PERCENT','0.70','2025-01-01',NULL,'decimal','Booking','Tỷ lệ đặt cọc tối đa (70%)',1,'2025-11-25 15:20:00','ACTIVE'),(12,'SINGLE_DRIVER_MAX_DISTANCE_KM','300','2025-01-01',NULL,'int','Dispatch','Quãng đường tối đa cho 1 tài xế (300km cả đi lẫn về)',1,'2025-11-25 15:20:00','ACTIVE'),(13,'CANCELLATION_FULL_DEPOSIT_LOSS_HOURS','24','2025-01-01',NULL,'int','Booking','Số giờ trước khởi hành để mất 100% tiền cọc (24h)',1,'2025-11-25 15:20:00','ACTIVE'),(14,'CANCELLATION_PARTIAL_DEPOSIT_LOSS_HOURS','48','2025-01-01',NULL,'int','Booking','Số giờ trước khởi hành để mất một phần tiền cọc (48h)',1,'2025-11-25 15:20:00','ACTIVE'),(15,'CANCELLATION_PARTIAL_DEPOSIT_PERCENT','0.30','2025-01-01',NULL,'decimal','Booking','Tỷ lệ mất cọc khi hủy trong khoảng thời gian (30%)',1,'2025-11-25 15:20:00','ACTIVE'),(16,'MAX_CONTINUOUS_DRIVING_HOURS','4','2025-01-01',NULL,'int','Driver','Số giờ lái xe liên tục tối đa (4 giờ)',1,'2025-11-25 15:20:00','ACTIVE'),(17,'MAX_DRIVING_HOURS_PER_WEEK','48','2025-01-01',NULL,'int','Driver','Số giờ lái xe tối đa mỗi tuần (48 giờ)',1,'2025-11-25 15:20:00','ACTIVE'),(18,'ROUND_TRIP_MULTIPLIER','1.5','2025-01-01',NULL,'decimal','Pricing','Hệ số nhân cho chuyến 2 chiều (1.5x)',1,'2025-11-29 11:18:58','ACTIVE'),(19,'INTER_PROVINCE_DISTANCE_KM','100','2025-01-01',NULL,'int','Pricing','Ngưỡng khoảng cách để tính liên tỉnh (100km)',1,'2025-11-29 11:18:58','ACTIVE');
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip_assignment_history`
--

DROP TABLE IF EXISTS `trip_assignment_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trip_assignment_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action` enum('ACCEPT','ASSIGN','CANCEL','REASSIGN','UNASSIGN') COLLATE utf8mb4_unicode_ci NOT NULL,
  `createdAt` datetime(6) NOT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `driverId` int DEFAULT NULL,
  `tripId` int NOT NULL,
  `vehicleId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKhwtv199ytfy4jega6nh3l1kh4` (`driverId`),
  KEY `FKae1wfffiefexi6uy5i2pfhuuw` (`tripId`),
  KEY `FKj0e2kbcuh7oib4mrkhlivdspj` (`vehicleId`),
  CONSTRAINT `FKae1wfffiefexi6uy5i2pfhuuw` FOREIGN KEY (`tripId`) REFERENCES `trips` (`tripId`),
  CONSTRAINT `FKhwtv199ytfy4jega6nh3l1kh4` FOREIGN KEY (`driverId`) REFERENCES `drivers` (`driverId`),
  CONSTRAINT `FKj0e2kbcuh7oib4mrkhlivdspj` FOREIGN KEY (`vehicleId`) REFERENCES `vehicles` (`vehicleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip_assignment_history`
--

LOCK TABLES `trip_assignment_history` WRITE;
/*!40000 ALTER TABLE `trip_assignment_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `trip_assignment_history` ENABLE KEYS */;
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
  `driverRole` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'Main Driver',
  `startTime` datetime DEFAULT NULL,
  `endTime` datetime DEFAULT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`tripId`,`driverId`),
  KEY `IX_TripDrivers_Driver` (`driverId`,`tripId`),
  CONSTRAINT `fk_td_driver` FOREIGN KEY (`driverId`) REFERENCES `drivers` (`driverId`),
  CONSTRAINT `fk_td_trip` FOREIGN KEY (`tripId`) REFERENCES `trips` (`tripId`),
  CONSTRAINT `trip_drivers_chk_1` CHECK (((`startTime` is null) or (`endTime` is null) or (`startTime` < `endTime`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip_drivers`
--

LOCK TABLES `trip_drivers` WRITE;
/*!40000 ALTER TABLE `trip_drivers` DISABLE KEYS */;
INSERT INTO `trip_drivers` VALUES (1,1,'Main Driver',NULL,NULL,'Tài xế A lái xe 29A-333.33'),(2,4,'Main Driver',NULL,NULL,'Tài xế D lái xe 51C-555.55'),(3,1,'Main Driver',NULL,NULL,'Tài xế A lái xe Trip 3 (sáng)'),(3,2,'Support Driver',NULL,NULL,'Tài xế B hỗ trợ Trip 3 (sáng)'),(4,1,'Main Driver',NULL,NULL,'Tài xế A lái xe Trip 4 (chiều)'),(4,2,'Support Driver',NULL,NULL,'Tài xế B hỗ trợ Trip 4 (chiều)'),(5,1,'Main Driver',NULL,NULL,'Tài xế A lái xe Trip 5 (sáng)'),(5,2,'Support Driver',NULL,NULL,'Tài xế B hỗ trợ Trip 5 (sáng)'),(6,5,'Main Driver',NULL,NULL,'Tài xế E lái xe Trip 6'),(7,3,'Main Driver',NULL,NULL,'Tài xế C lái xe Trip 7'),(8,1,'Main Driver',NULL,NULL,NULL),(9,1,'Main Driver',NULL,NULL,NULL),(11,1,'Main Driver',NULL,NULL,NULL),(16,1,'Main Driver',NULL,NULL,NULL);
/*!40000 ALTER TABLE `trip_drivers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip_incidents`
--

DROP TABLE IF EXISTS `trip_incidents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trip_incidents` (
  `incidentId` int NOT NULL AUTO_INCREMENT,
  `createdAt` datetime(6) DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `resolved` bit(1) NOT NULL,
  `severity` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `driverId` int NOT NULL,
  `tripId` int NOT NULL,
  PRIMARY KEY (`incidentId`),
  KEY `FKpd1vr15pph016u9lcwtkj0mol` (`driverId`),
  KEY `FKrw0wv0rtalo5l4vwis2rf4isa` (`tripId`),
  CONSTRAINT `FKpd1vr15pph016u9lcwtkj0mol` FOREIGN KEY (`driverId`) REFERENCES `drivers` (`driverId`),
  CONSTRAINT `FKrw0wv0rtalo5l4vwis2rf4isa` FOREIGN KEY (`tripId`) REFERENCES `trips` (`tripId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip_incidents`
--

LOCK TABLES `trip_incidents` WRITE;
/*!40000 ALTER TABLE `trip_incidents` DISABLE KEYS */;
/*!40000 ALTER TABLE `trip_incidents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trip_route_cache`
--

DROP TABLE IF EXISTS `trip_route_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trip_route_cache` (
  `cacheId` int NOT NULL AUTO_INCREMENT,
  `startLocation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `endLocation` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `distance` decimal(10,2) NOT NULL COMMENT 'Distance in kilometers',
  `duration` int NOT NULL COMMENT 'Duration in minutes',
  `startLatitude` decimal(10,8) DEFAULT NULL,
  `startLongitude` decimal(11,8) DEFAULT NULL,
  `endLatitude` decimal(10,8) DEFAULT NULL,
  `endLongitude` decimal(11,8) DEFAULT NULL,
  `routeData` json DEFAULT NULL,
  `trafficStatus` enum('LIGHT','MODERATE','HEAVY','UNKNOWN') COLLATE utf8mb4_unicode_ci DEFAULT 'UNKNOWN' COMMENT 'Traffic status when cached',
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expiresAt` datetime NOT NULL DEFAULT ((now() + interval 7 day)),
  `hitCount` int DEFAULT '0' COMMENT 'Number of times this cache was used',
  `lastUsedAt` datetime DEFAULT NULL COMMENT 'Last time this cache was used',
  PRIMARY KEY (`cacheId`),
  KEY `IX_Cache_Locations` (`startLocation`(100),`endLocation`(100)),
  KEY `IX_Cache_Expires` (`expiresAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cache SerpAPI route calculations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip_route_cache`
--

LOCK TABLES `trip_route_cache` WRITE;
/*!40000 ALTER TABLE `trip_route_cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `trip_route_cache` ENABLE KEYS */;
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
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`tripVehicleId`),
  UNIQUE KEY `UQ_TripVehicles` (`tripId`,`vehicleId`),
  KEY `IX_TripVehicles_TripId` (`tripId`),
  KEY `IX_TripVehicles_Vehicle` (`vehicleId`,`tripId`),
  CONSTRAINT `fk_tv_trip` FOREIGN KEY (`tripId`) REFERENCES `trips` (`tripId`),
  CONSTRAINT `fk_tv_vehicle` FOREIGN KEY (`vehicleId`) REFERENCES `vehicles` (`vehicleId`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trip_vehicles`
--

LOCK TABLES `trip_vehicles` WRITE;
/*!40000 ALTER TABLE `trip_vehicles` DISABLE KEYS */;
INSERT INTO `trip_vehicles` VALUES (1,1,3,'2025-11-12 11:23:08','Gán xe Samco 29A-333.33 cho Trip 1'),(2,2,5,'2025-11-12 11:23:08','Gán xe Transit 51C-555.55 cho Trip 2'),(3,3,3,'2025-11-12 11:23:08','Gán xe 29A-333.33 cho Trip 3 (sáng)'),(4,3,6,'2025-11-12 11:23:08','Gán xe 29A-666.66 cho Trip 3 (sáng)'),(5,4,3,'2025-11-12 11:23:08','Gán xe 29A-333.33 cho Trip 4 (chiều)'),(6,4,6,'2025-11-12 11:23:08','Gán xe 29A-666.66 cho Trip 4 (chiều)'),(7,5,3,'2025-11-12 11:23:08','Gán xe 29A-333.33 cho Trip 5 (sáng)'),(8,5,6,'2025-11-12 11:23:08','Gán xe 29A-666.66 cho Trip 5 (sáng)'),(9,6,2,'2025-11-12 11:23:08','Gán xe Limousine 29A-222.22 cho Trip 6'),(10,7,4,'2025-11-12 11:23:08','Gán xe Universe 43B-444.44 cho Trip 7'),(11,8,1,'2025-11-23 17:49:43',NULL),(12,9,1,'2025-11-25 12:23:59',NULL),(13,11,2,'2025-11-27 21:37:27',NULL),(14,16,1,'2025-12-01 20:42:18',NULL);
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
  `startLocation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endLocation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `distance` decimal(10,2) DEFAULT NULL COMMENT 'Distance in kilometers from SerpAPI',
  `startLatitude` decimal(10,8) DEFAULT NULL COMMENT 'Start location latitude',
  `startLongitude` decimal(11,8) DEFAULT NULL COMMENT 'Start location longitude',
  `endLatitude` decimal(10,8) DEFAULT NULL COMMENT 'End location latitude',
  `endLongitude` decimal(11,8) DEFAULT NULL COMMENT 'End location longitude',
  `estimatedDuration` int DEFAULT NULL COMMENT 'Estimated duration in minutes from SerpAPI',
  `actualDuration` int DEFAULT NULL COMMENT 'Actual duration in minutes after completed',
  `routeData` json DEFAULT NULL COMMENT 'Detailed route information from SerpAPI',
  `trafficStatus` enum('LIGHT','MODERATE','HEAVY','UNKNOWN') COLLATE utf8mb4_unicode_ci DEFAULT 'UNKNOWN' COMMENT 'Traffic status at booking time',
  `incidentalCosts` decimal(10,2) DEFAULT '0.00',
  `status` enum('SCHEDULED','ASSIGNED','ONGOING','COMPLETED','CANCELLED') COLLATE utf8mb4_unicode_ci DEFAULT 'SCHEDULED',
  PRIMARY KEY (`tripId`),
  KEY `IX_Trips_BookingId` (`bookingId`),
  KEY `IX_Trips_Status_Start` (`status`,`startTime`),
  KEY `IX_Trips_Distance` (`distance`),
  KEY `IX_Trips_StartLocation_Coords` (`startLatitude`,`startLongitude`),
  KEY `IX_Trips_EndLocation_Coords` (`endLatitude`,`endLongitude`),
  KEY `IX_Trips_EstimatedDuration` (`estimatedDuration`),
  CONSTRAINT `fk_trip_booking` FOREIGN KEY (`bookingId`) REFERENCES `bookings` (`bookingId`),
  CONSTRAINT `trips_chk_1` CHECK (((`startTime` is null) or (`endTime` is null) or (`startTime` < `endTime`)))
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trips`
--

LOCK TABLES `trips` WRITE;
/*!40000 ALTER TABLE `trips` DISABLE KEYS */;
INSERT INTO `trips` VALUES (1,1,1,'2025-10-25 07:00:00','2025-10-25 20:00:00','Hoàn Kiếm, Hà Nội','Hạ Long, Quảng Ninh',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'COMPLETED'),(2,2,1,'2025-10-28 14:00:00','2025-10-28 15:30:00','Sân bay Tân Sơn Nhất','Quận 7, TP. HCM',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'ASSIGNED'),(3,3,0,'2025-11-01 07:00:00','2025-11-01 08:30:00','Nội thành Hà Nội','KCN Thăng Long',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'ASSIGNED'),(4,3,0,'2025-11-01 17:00:00','2025-11-01 18:30:00','KCN Thăng Long','Nội thành Hà Nội',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'ASSIGNED'),(5,3,0,'2025-11-02 07:00:00','2025-11-02 08:30:00','Nội thành Hà Nội','KCN Thăng Long',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'ASSIGNED'),(6,5,1,'2025-10-29 10:00:00','2025-10-29 11:00:00','Times City, Hà Nội','Sân bay Nội Bài',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'ASSIGNED'),(7,4,1,'2025-11-10 08:00:00','2025-11-24 11:13:53','Đà Nẵng','Huế',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'COMPLETED'),(8,8,0,'2025-11-22 17:35:00',NULL,'Cổng A Đại học Cần Thơ, Cổng A Đại học Cần Thơ, Đường 3 Tháng 2, Cần Thơ, Vietnam','Hẻm 95 Mậu Thân, Hẻm 95 Mậu Thân, Cần Thơ, Vietnam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'ONGOING'),(9,9,0,'2025-11-25 10:15:00','2025-11-25 19:09:10','Can Tho International Airport, Can Tho International Airport, Nguyễn Chí Thanh, Cần Thơ, Vietnam','Phường Sóc Trăng, Phường Sóc Trăng, Cần Thơ, Vietnam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'COMPLETED'),(11,10,0,'2025-12-04 01:03:00','2025-12-31 19:03:00','Hanoi, Hanoi, Vietnam','hg, hg, Delhi, India',4516.12,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'ASSIGNED'),(12,11,0,'2025-12-03 21:14:00',NULL,'Hanoi, Hanoi, Le Duan Road, Hanoi, Hà Nội, Vietnam','Cần Thơ City (former), Cần Thơ City (former), Vietnam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'SCHEDULED'),(13,12,0,'2025-12-04 19:21:00',NULL,'Can Tho International Airport, Can Tho International Airport, Nguyễn Chí Thanh, Cần Thơ, Vietnam','Hạ Long Bay, Hạ Long Bay, Hạ Long, Quang Ninh Province, Vietnam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'SCHEDULED'),(14,13,0,'2026-01-08 17:37:00',NULL,'Hầm vượt Sông Sài Gòn, Hầm vượt Sông Sài Gòn, Saigon River Tunnel, Ho Chi Minh City, Vietnam','Vinhomes Times City, Vinhomes Times City, Phố Minh Khai, Hanoi, Hà Nội, Vietnam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'SCHEDULED'),(15,14,0,'2025-12-09 18:23:00',NULL,'Sacombank, Sacombank, Cách Mạng Tháng 8, Cần Thơ, Vietnam','Vietcombank Tower, Vietcombank Tower, Me Linh Square, Ho Chi Minh City, Vietnam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'SCHEDULED'),(16,15,0,'2025-12-10 19:44:00',NULL,'Hạ Long Bay, Hạ Long Bay, Quang Ninh Province, Vietnam','Phố cổ Phố Bảng, Phố cổ Phố Bảng, Phố Bảng Commune, Tuyen Quang province, Vietnam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'ASSIGNED'),(17,16,0,'2025-12-09 19:43:00',NULL,'Hanoi, Hanoi, Vietnam','Cần Thơ, Cần Thơ, Vietnam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'SCHEDULED'),(18,17,0,'2025-12-31 12:03:00',NULL,'Can Tho International Airport, Can Tho International Airport, Nguyễn Chí Thanh, Cần Thơ, Vietnam','Cổng C Đại học Cần Thơ, Cổng C Đại học Cần Thơ, Đường 3 Tháng 2, Cần Thơ, Vietnam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'SCHEDULED'),(19,18,0,'2025-12-09 19:51:00',NULL,'Hẻm 95 Mậu Thân, Hẻm 95 Mậu Thân, Cần Thơ, Vietnam','Trường Đại học Cần Thơ, Trường Đại học Cần Thơ, Đường 30 Tháng 4, Cần Thơ, Vietnam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'SCHEDULED'),(20,19,0,'2025-12-17 22:59:00',NULL,'Can Tho International Airport, Can Tho International Airport, Nguyễn Chí Thanh, Cần Thơ, Vietnam','Bến phà Ninh Kiều, Bến phà Ninh Kiều, Hai Bà Trưng, Cần Thơ, Vietnam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',NULL,'SCHEDULED');
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
  `fullName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `passwordHash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','SUSPENDED') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verified` tinyint(1) DEFAULT '0',
  `verification_token` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userId`),
  UNIQUE KEY `username` (`username`),
  KEY `IX_Users_RoleId` (`roleId`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`roleId`) REFERENCES `roles` (`roleId`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,1,'Admin Tổng','admin','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','admin@ptcmss.com','0900000001','/uploads/9eb83d91-86bb-42b2-a00f-6d6e02110f07_z7063172831772_3f76577ba5e404be620ba9d9d4b53f30.jpg',NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(2,2,'Quản Lý Hà Nội','manager_hn','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','manager.hn@ptcmss.com','0900000002',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(3,2,'Quản Lý Đà Nẵng','manager_dn','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','manager.dn@ptcmss.com','0900000003',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(4,2,'Quản Lý HCM','manager_hcm','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','manager.hcm@ptcmss.com','0900000004',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(5,3,'Điều Hành Viên 1 (HN)','consultant_hn1','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','c1.hn@ptcmss.com','0900000005',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(6,3,'Điều Hành Viên 2 (HN)','consultant_hn2','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','c2.hn@ptcmss.com','0900000006',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(7,5,'Kế Toán 1 (HN)','accountant_hn1','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','k1.hn@ptcmss.com','0900000007',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(8,4,'Tài Xế Nguyễn Văn A','driver_a','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.a@ptcmss.com','0912345671','/uploads/23bd384c-9e60-463b-a189-c0776388941f_Thuan.jpg','','ACTIVE',0,NULL,'2025-11-12 11:23:08'),(9,4,'Tài Xế Trần Văn B','driver_b','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.b@ptcmss.com','0912345672',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(10,4,'Tài Xế Lê Hữu C','driver_c','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.c@ptcmss.com','0912345673',NULL,'sóc trăng, cần thơ','ACTIVE',0,NULL,'2025-11-12 11:23:08'),(11,4,'Tài Xế Phạm Đình Thái Ngân','driver_d','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.d@ptcmss.com','0912345674',NULL,'','ACTIVE',0,NULL,'2025-11-12 11:23:08'),(12,4,'Tài Xế Huỳnh Tấn E','driver_e','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.e@ptcmss.com','0912345675',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(13,4,'Tài Xế Vũ Minh F','driver_f','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.f@ptcmss.com','0912345676',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(14,4,'Tài Xế Đặng Văn G','driver_g','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.g@ptcmss.com','0912345677',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(15,2,'Nguyenexc Văn Thuần','vt1001','TEAMP123','vthuan.dev@gmail.com','0706871283',NULL,'can tho','INACTIVE',1,'a272ffce-da0f-434c-b304-81eefa9c0e16','2025-11-23 22:08:30'),(16,2,'Nguyễn Văn AN','test','$2a$10$SHY1HlsLEs.nAmd6bR1nke2VePGDY8nosBHAwv.oBTvAJcFsIv7mG','thuanhero1@gmail.com','0904521297',NULL,'ct','ACTIVE',1,NULL,'2025-11-23 22:17:05'),(17,2,'testtt','test2','$2a$10$Jb4Noe6WBsBDD.vWi3mKSu6doDCA6Bm3TlGvQ/V41Du/e./jFrhO6','thuanb2112012@student.ctu.edu.vn','0904545454',NULL,'ss','ACTIVE',1,'c4c39222-dc35-4d72-88f9-db2fe9d1559c','2025-11-23 22:34:42'),(18,2,'Nguyễn Văn Thuần','nguyenv','$2a$10$KYSvH3HQN7B9yDNOTBLrauaSO84ub.sGDZaDxNT72dtWdwJLMyJI.','nguyenvthuanctu@gmail.com','07068712223',NULL,'ct','ACTIVE',1,NULL,'2025-11-24 08:57:07'),(19,2,'nguyen van vx','nguyena','$2a$10$i8upQ1bNJkoqulJGyOQee.xvCUovSQ1DX8w9YyyEcQfntdDD3rk0i','chinh@shopyenquynh.store','09045256162',NULL,'đ','ACTIVE',0,'04ee8777-745a-45e2-8c3d-2f05e0e26fe0','2025-11-24 10:21:53'),(20,6,'Nguyễn Văn Thuần c','nguyen.van.thuan.c','$2a$10$WUF10X1TOr/K/t35zEB.ye79Q2yMykPWM0dnty5LDD8oMCV.dsROq','tuongnguvc6@gmail.com','0706871281',NULL,'222','ACTIVE',1,NULL,'2025-11-28 20:15:21'),(21,6,'điều phối viên tphcm','dieu.phoi.vien.tphcm','$2a$10$c7do7Fz.BXAba9OGNZGaguW2BYFLv.LsYshuk4mRC5aFZCdYbhINu','thandao@shopdianguc.space','0706871222',NULL,'cần thơ','ACTIVE',1,NULL,'2025-11-30 18:03:46'),(22,2,'test','testaa','$2a$10$to2cKTLzwjM/TEn1SLT1ouNpSI1CxfnCFKLNmLXcBhuHFbiPg30dC','vthuan.devaa@gmail.com','0904521296',NULL,'222','INACTIVE',0,'c9d5312d-1124-4224-a1b9-81e47b0181fa','2025-12-01 19:26:11'),(33,4,'testus','testus','$2a$10$z6dSRTX/bk8.Y41Eccvs2eqfS6ZPY3b.yX3HyMHTSVxsQwPbTMu26','testus@gmail.com','0706871244',NULL,'ấ','INACTIVE',0,'208bda35-0030-4b67-9773-0e1a056f22a9','2025-12-02 05:21:21');
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
 1 AS `year`,
 1 AS `month`,
 1 AS `tripsCount`,
 1 AS `minutesOnTrip`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_popularroutes`
--

DROP TABLE IF EXISTS `v_popularroutes`;
/*!50001 DROP VIEW IF EXISTS `v_popularroutes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_popularroutes` AS SELECT 
 1 AS `startLocation`,
 1 AS `endLocation`,
 1 AS `cacheEntryCount`,
 1 AS `avgDistance`,
 1 AS `avgDuration`,
 1 AS `totalCacheHits`,
 1 AS `lastUsed`,
 1 AS `lastCached`*/;
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
 1 AS `bookingId`,
 1 AS `branchId`,
 1 AS `branchName`,
 1 AS `startLocation`,
 1 AS `endLocation`,
 1 AS `distance`,
 1 AS `estimatedDuration`,
 1 AS `actualDuration`,
 1 AS `durationVariancePercent`,
 1 AS `trafficStatus`,
 1 AS `tripStatus`,
 1 AS `startTime`,
 1 AS `endTime`,
 1 AS `actualTripDuration`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `vehicle_category_pricing`
--

DROP TABLE IF EXISTS `vehicle_category_pricing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicle_category_pricing` (
  `categoryId` int NOT NULL AUTO_INCREMENT,
  `categoryName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `seats` int DEFAULT NULL COMMENT 'Số ghế của danh mục xe',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `baseFare` decimal(10,2) DEFAULT NULL,
  `pricePerKm` decimal(10,2) DEFAULT NULL COMMENT 'Giá mỗi km (VNĐ/km) - Xe 16: 30k, Xe 30: 40k, Xe 45: 50k',
  `highwayFee` decimal(10,2) DEFAULT NULL,
  `fixedCosts` decimal(10,2) DEFAULT NULL,
  `effectiveDate` date DEFAULT (curdate()),
  `status` enum('ACTIVE','INACTIVE') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
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
INSERT INTO `vehicle_category_pricing` VALUES (1,'Xe 9 chỗ (Limousine)',9,'DCar/Solati Limousine',10000.00,15000.00,NULL,NULL,NULL,'ACTIVE','2025-11-12 11:23:08',NULL,NULL,20000.00),(2,'Xe 16 chỗ',16,'Ford Transit, Mercedes Sprinter',1100000.00,30000.00,120000.00,0.00,NULL,'ACTIVE','2025-11-12 11:23:08',0,1000000.00,NULL),(3,'Xe 29 chỗ',29,'Hyundai County, Samco Isuzu',1800000.00,40000.00,150000.00,0.00,'2025-11-12','ACTIVE','2025-11-12 11:23:08',0,1000000.00,NULL),(4,'Xe 45 chỗ',45,'Hyundai Universe',2500000.00,50000.00,200000.00,0.00,'2025-11-12','ACTIVE','2025-11-12 11:23:08',0,1000000.00,NULL),(5,'Xe giường nằm (40 chỗ)',40,'Xe giường nằm Thaco/Hyundai',3000000.00,30000.00,250000.00,0.00,'2025-11-12','ACTIVE','2025-11-12 11:23:08',0,1000000.00,NULL);
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
  `licensePlate` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `brand` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `productionYear` int DEFAULT NULL,
  `registrationDate` date DEFAULT NULL,
  `inspectionExpiry` date DEFAULT NULL,
  `insuranceExpiry` date DEFAULT NULL,
  `odometer` bigint DEFAULT NULL,
  `status` enum('AVAILABLE','INUSE','MAINTENANCE','INACTIVE') COLLATE utf8mb4_unicode_ci DEFAULT 'AVAILABLE',
  PRIMARY KEY (`vehicleId`),
  UNIQUE KEY `licensePlate` (`licensePlate`),
  KEY `fk_veh_cat` (`categoryId`),
  KEY `IX_Vehicles_BranchId` (`branchId`),
  CONSTRAINT `fk_veh_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_veh_cat` FOREIGN KEY (`categoryId`) REFERENCES `vehicle_category_pricing` (`categoryId`),
  CONSTRAINT `vehicles_chk_1` CHECK ((`productionYear` >= 1980))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicles`
--

LOCK TABLES `vehicles` WRITE;
/*!40000 ALTER TABLE `vehicles` DISABLE KEYS */;
INSERT INTO `vehicles` VALUES (1,2,1,'29A-111.11','Ford Transit','Ford',NULL,2022,NULL,'2026-06-30','2029-10-26',NULL,'AVAILABLE'),(2,1,1,'29A-222.22','DCar Limousine','DCar',9,2023,'2023-05-01','2026-04-30',NULL,NULL,'AVAILABLE'),(3,3,1,'29A-333.33','Samco Isuzu','Samco',29,2021,'2021-03-01','2025-08-30',NULL,NULL,'AVAILABLE'),(4,4,2,'43B-444.44','Hyundai Universe','Hyundai',45,2023,'2023-06-01','2025-11-30',NULL,NULL,'AVAILABLE'),(5,2,3,'51C-555.55','Ford Transit','Ford',16,2022,'2022-07-01','2026-12-31',NULL,NULL,'INUSE'),(6,3,1,'29A-666.66','Hyundai County','Hyundai',29,2022,'2022-09-01','2026-02-28',NULL,NULL,'AVAILABLE'),(7,5,2,'43B-777.77','Thaco Mobihome','Thaco',40,2023,'2023-08-15','2025-02-14',NULL,NULL,'MAINTENANCE');
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
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_drivermonthlyperformance` AS select `d`.`driverId` AS `driverId`,year(`t`.`startTime`) AS `year`,month(`t`.`startTime`) AS `month`,count(distinct `td`.`tripId`) AS `tripsCount`,sum((case when ((`td`.`startTime` is not null) and (`td`.`endTime` is not null)) then timestampdiff(MINUTE,`td`.`startTime`,`td`.`endTime`) else 0 end)) AS `minutesOnTrip` from ((`trip_drivers` `td` join `drivers` `d` on((`d`.`driverId` = `td`.`driverId`))) join `trips` `t` on((`t`.`tripId` = `td`.`tripId`))) group by `d`.`driverId`,year(`t`.`startTime`),month(`t`.`startTime`) */;
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
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_popularroutes` AS select `trc`.`startLocation` AS `startLocation`,`trc`.`endLocation` AS `endLocation`,count(0) AS `cacheEntryCount`,avg(`trc`.`distance`) AS `avgDistance`,avg(`trc`.`duration`) AS `avgDuration`,sum(`trc`.`hitCount`) AS `totalCacheHits`,max(`trc`.`lastUsedAt`) AS `lastUsed`,max(`trc`.`createdAt`) AS `lastCached` from `trip_route_cache` `trc` where (`trc`.`createdAt` >= (now() - interval 30 day)) group by `trc`.`startLocation`,`trc`.`endLocation` having (sum(`trc`.`hitCount`) > 0) order by `totalCacheHits` desc,`lastUsed` desc limit 100 */;
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
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_tripdistanceanalytics` AS select `t`.`tripId` AS `tripId`,`t`.`bookingId` AS `bookingId`,`b`.`branchId` AS `branchId`,`br`.`branchName` AS `branchName`,`t`.`startLocation` AS `startLocation`,`t`.`endLocation` AS `endLocation`,`t`.`distance` AS `distance`,`t`.`estimatedDuration` AS `estimatedDuration`,`t`.`actualDuration` AS `actualDuration`,(case when ((`t`.`actualDuration` is not null) and (`t`.`estimatedDuration` is not null)) then round((((`t`.`actualDuration` - `t`.`estimatedDuration`) / `t`.`estimatedDuration`) * 100),2) else NULL end) AS `durationVariancePercent`,`t`.`trafficStatus` AS `trafficStatus`,`t`.`status` AS `tripStatus`,`t`.`startTime` AS `startTime`,`t`.`endTime` AS `endTime`,timestampdiff(MINUTE,`t`.`startTime`,`t`.`endTime`) AS `actualTripDuration` from ((`trips` `t` join `bookings` `b` on((`t`.`bookingId` = `b`.`bookingId`))) join `branches` `br` on((`b`.`branchId` = `br`.`branchId`))) where (`t`.`distance` is not null) */;
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

-- Dump completed on 2025-12-02 13:57:31
