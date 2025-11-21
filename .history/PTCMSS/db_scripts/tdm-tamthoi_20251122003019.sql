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
-- Table structure for table `accountsreceivable`
--

DROP TABLE IF EXISTS `accountsreceivable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accountsreceivable` (
  `arId` int NOT NULL AUTO_INCREMENT,
  `customerId` int NOT NULL,
  `bookingId` int DEFAULT NULL,
  `invoiceId` int DEFAULT NULL,
  `totalAmount` decimal(18,2) DEFAULT NULL,
  `paidAmount` decimal(18,2) DEFAULT NULL,
  `remainingAmount` decimal(18,2) GENERATED ALWAYS AS ((`totalAmount` - `paidAmount`)) STORED,
  `dueDate` date DEFAULT NULL,
  `lastPaymentDate` date DEFAULT NULL,
  `status` enum('UNPAID','PARTIALLYPAID','PAID') COLLATE utf8mb4_unicode_ci DEFAULT 'UNPAID',
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`arId`),
  KEY `fk_ar_customer` (`customerId`),
  KEY `fk_ar_booking` (`bookingId`),
  KEY `fk_ar_invoice` (`invoiceId`),
  KEY `IX_AR_Status_DueDate` (`status`,`dueDate`),
  CONSTRAINT `fk_ar_booking` FOREIGN KEY (`bookingId`) REFERENCES `bookings` (`bookingId`),
  CONSTRAINT `fk_ar_customer` FOREIGN KEY (`customerId`) REFERENCES `customers` (`customerId`),
  CONSTRAINT `fk_ar_invoice` FOREIGN KEY (`invoiceId`) REFERENCES `invoices` (`invoiceId`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountsreceivable`
--

LOCK TABLES `accountsreceivable` WRITE;
/*!40000 ALTER TABLE `accountsreceivable` DISABLE KEYS */;
INSERT INTO `accountsreceivable` (`arId`, `customerId`, `bookingId`, `invoiceId`, `totalAmount`, `paidAmount`, `dueDate`, `lastPaymentDate`, `status`, `note`, `createdAt`, `updatedAt`) VALUES (1,2,1,2,3800000.00,3800000.00,'2025-10-25',NULL,'PAID',NULL,'2025-11-12 11:23:08','2025-11-12 11:23:08'),(2,4,2,3,1200000.00,500000.00,'2025-10-28',NULL,'PARTIALLYPAID',NULL,'2025-11-12 11:23:08','2025-11-12 11:23:08'),(3,1,3,4,25000000.00,25000000.00,'2025-11-01',NULL,'PAID',NULL,'2025-11-12 11:23:08','2025-11-12 11:23:08'),(4,3,4,NULL,15000000.00,500000.00,'2025-11-10',NULL,'PARTIALLYPAID',NULL,'2025-11-12 11:23:08','2025-11-12 11:23:08'),(5,5,5,5,1000000.00,1000000.00,'2025-10-29',NULL,'PAID',NULL,'2025-11-12 11:23:08','2025-11-12 11:23:08');
/*!40000 ALTER TABLE `accountsreceivable` ENABLE KEYS */;
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
  `status` enum('PENDING','CONFIRMED','INPROGRESS','COMPLETED','CANCELLED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bookingId`),
  KEY `fk_book_cons` (`consultantId`),
  KEY `IX_Bookings_BranchId` (`branchId`),
  KEY `IX_Bookings_Customer_Status` (`customerId`,`status`),
  KEY `IX_Bookings_HireType` (`hireTypeId`),
  KEY `IX_Bookings_Distance` (`totalDistance`),
  CONSTRAINT `fk_book_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_book_cons` FOREIGN KEY (`consultantId`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_book_cust` FOREIGN KEY (`customerId`) REFERENCES `customers` (`customerId`),
  CONSTRAINT `fk_book_hire` FOREIGN KEY (`hireTypeId`) REFERENCES `hiretypes` (`hireTypeId`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
INSERT INTO `bookings` VALUES (1,2,1,5,2,1,'2025-11-12 11:23:08',3500000.00,1000000.00,3800000.00,NULL,NULL,'COMPLETED','Đoàn 25 khách, đi Hà Nội - Hạ Long 2 chiều','2025-11-12 11:23:08','2025-11-12 11:23:08'),(2,4,3,6,5,1,'2025-11-12 11:23:08',1200000.00,500000.00,1200000.00,NULL,NULL,'CONFIRMED','Đón sân bay TSN về Quận 7 (16 chỗ)','2025-11-12 11:23:08','2025-11-12 11:23:08'),(3,1,1,5,4,0,'2025-11-12 11:23:08',25000000.00,10000000.00,0.00,NULL,NULL,'INPROGRESS','Hợp đồng đưa đón nhân viên KCN Thăng Long T11/2025','2025-11-12 11:23:08','2025-11-12 11:23:08'),(4,3,2,6,3,1,'2025-11-12 11:23:08',15000000.00,500000.00,0.00,NULL,NULL,'PENDING','Thuê xe 45 chỗ đi 3N2Đ Đà Nẵng - Huế - Hội An','2025-11-12 11:23:08','2025-11-12 11:23:08'),(5,5,1,5,1,1,'2025-11-12 11:23:08',1000000.00,1000000.00,1000000.00,NULL,NULL,'CONFIRMED','Thuê 1 chiều xe Limo (9 chỗ) đi Nội Bài','2025-11-12 11:23:08','2025-11-12 11:23:08');
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookingvehicledetails`
--

DROP TABLE IF EXISTS `bookingvehicledetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookingvehicledetails` (
  `bookingId` int NOT NULL,
  `vehicleCategoryId` int NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`bookingId`,`vehicleCategoryId`),
  KEY `fk_bvd_category` (`vehicleCategoryId`),
  CONSTRAINT `fk_bvd_booking` FOREIGN KEY (`bookingId`) REFERENCES `bookings` (`bookingId`),
  CONSTRAINT `fk_bvd_category` FOREIGN KEY (`vehicleCategoryId`) REFERENCES `vehiclecategorypricing` (`categoryId`),
  CONSTRAINT `bookingvehicledetails_chk_1` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookingvehicledetails`
--

LOCK TABLES `bookingvehicledetails` WRITE;
/*!40000 ALTER TABLE `bookingvehicledetails` DISABLE KEYS */;
INSERT INTO `bookingvehicledetails` VALUES (1,3,1),(2,2,1),(3,3,2),(4,4,1),(5,1,1);
/*!40000 ALTER TABLE `bookingvehicledetails` ENABLE KEYS */;
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
  PRIMARY KEY (`branchId`),
  KEY `FK_Branches_Manager` (`managerId`),
  CONSTRAINT `FK_Branches_Manager` FOREIGN KEY (`managerId`) REFERENCES `employees` (`employeeId`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` VALUES (1,'Chi nhánh Hà Nội','123 Láng Hạ, Đống Đa, Hà Nội',2,'ACTIVE','2025-11-12 11:23:08'),(2,'Chi nhánh Đà Nẵng','456 Nguyễn Văn Linh, Hải Châu, Đà Nẵng',3,'ACTIVE','2025-11-12 11:23:08'),(3,'Chi nhánh TP. HCM','789 Võ Thị Sáu, Quận 3, TP. HCM',4,'ACTIVE','2025-11-12 11:23:08'),(4,'Chi nhánh Hải Phòng','10 Lê Hồng Phong, Ngô Quyền, Hải Phòng',NULL,'INACTIVE','2025-11-12 11:23:08'),(5,'Chi nhánh Quảng Ninh','55 Trần Hưng Đạo, Hạ Long, Quảng Ninh',2,'ACTIVE','2025-11-12 11:23:08');
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Công ty TNHH ABC (KCN Thăng Long)','0987654321','contact@abc.com','KCN Thăng Long, Đông Anh, Hà Nội',NULL,'2025-11-12 11:23:08',5,'ACTIVE'),(2,'Đoàn du lịch Hướng Việt','0987654322','info@huongviet.vn','Hoàn Kiếm, Hà Nội',NULL,'2025-11-12 11:23:08',6,'ACTIVE'),(3,'Công ty CP XYZ (Đà Nẵng)','0987654323','hr@xyz.com','Hải Châu, Đà Nẵng',NULL,'2025-11-12 11:23:08',5,'ACTIVE'),(4,'Gia đình ông Trần Văn Hùng','0987654324','hung.tran@gmail.com','Quận 7, TP. HCM',NULL,'2025-11-12 11:23:08',6,'ACTIVE'),(5,'Trường quốc tế Vinschool','0987654325','school@vinschool.edu.vn','Times City, Hà Nội',NULL,'2025-11-12 11:23:08',5,'ACTIVE');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `driverdayoff`
--

DROP TABLE IF EXISTS `driverdayoff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `driverdayoff` (
  `dayOffId` int NOT NULL AUTO_INCREMENT,
  `driverId` int NOT NULL,
  `startDate` date NOT NULL,
  `endDate` date NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approvedBy` int DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dayOffId`),
  KEY `fk_doff_approve` (`approvedBy`),
  KEY `IX_DriverDayOff_DriverId` (`driverId`),
  CONSTRAINT `fk_doff_approve` FOREIGN KEY (`approvedBy`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_doff_driver` FOREIGN KEY (`driverId`) REFERENCES `drivers` (`driverId`),
  CONSTRAINT `driverdayoff_chk_1` CHECK ((`startDate` <= `endDate`))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driverdayoff`
--

LOCK TABLES `driverdayoff` WRITE;
/*!40000 ALTER TABLE `driverdayoff` DISABLE KEYS */;
INSERT INTO `driverdayoff` VALUES (1,1,'2025-10-30','2025-10-30','Việc gia đình',2,'APPROVED','2025-11-12 11:23:08'),(2,2,'2025-11-05','2025-11-06','Khám sức khỏe',2,'PENDING','2025-11-12 11:23:08'),(3,3,'2025-10-20','2025-10-21','Về quê',3,'APPROVED','2025-11-12 11:23:08'),(4,4,'2025-10-29','2025-10-29','Nghỉ ốm',4,'REJECTED','2025-11-12 11:23:08'),(5,6,'2025-11-01','2025-11-30','Nghỉ không lương',3,'APPROVED','2025-11-12 11:23:08');
/*!40000 ALTER TABLE `driverdayoff` ENABLE KEYS */;
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
  `status` enum('AVAILABLE','ONTRIP','INACTIVE') COLLATE utf8mb4_unicode_ci DEFAULT 'AVAILABLE',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`driverId`),
  UNIQUE KEY `employeeId` (`employeeId`),
  UNIQUE KEY `licenseNumber` (`licenseNumber`),
  KEY `IX_Drivers_BranchId` (`branchId`),
  CONSTRAINT `fk_drivers_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_drivers_emp` FOREIGN KEY (`employeeId`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `drivers_chk_1` CHECK (((`rating` >= 0) and (`rating` <= 5))),
  CONSTRAINT `drivers_chk_2` CHECK ((`priorityLevel` between 1 and 10))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drivers`
--

LOCK TABLES `drivers` WRITE;
/*!40000 ALTER TABLE `drivers` DISABLE KEYS */;
INSERT INTO `drivers` VALUES (1,8,1,'HN12345','D','2028-12-31','2025-06-01',5.00,1,NULL,'AVAILABLE','2025-11-12 11:23:08'),(2,9,1,'HN67890','E','2027-10-10','2025-05-01',5.00,1,NULL,'AVAILABLE','2025-11-12 11:23:08'),(3,10,2,'DN55555','D','2029-01-15','2025-07-01',5.00,1,NULL,'AVAILABLE','2025-11-12 11:23:08'),(4,11,3,'HCM88888','E','2026-05-20','2025-03-01',5.00,1,NULL,'ONTRIP','2025-11-12 11:23:08'),(5,12,1,'HN45678','D','2028-02-14','2025-08-01',5.00,1,NULL,'AVAILABLE','2025-11-12 11:23:08'),(6,13,2,'DN11111','E','2027-11-30','2025-09-10',5.00,1,NULL,'INACTIVE','2025-11-12 11:23:08'),(7,14,3,'HCM22222','D','2029-07-07','2025-10-01',5.00,1,NULL,'AVAILABLE','2025-11-12 11:23:08');
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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,1,1,1,'ACTIVE'),(2,2,1,2,'ACTIVE'),(3,3,2,2,'ACTIVE'),(4,4,3,2,'ACTIVE'),(5,5,1,3,'ACTIVE'),(6,6,1,3,'ACTIVE'),(7,7,1,5,'ACTIVE'),(8,8,1,4,'ACTIVE'),(9,9,1,4,'ACTIVE'),(10,10,2,4,'ACTIVE'),(11,11,3,4,'ACTIVE'),(12,12,1,4,'ACTIVE'),(13,13,2,4,'ACTIVE'),(14,14,3,4,'ACTIVE');
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hiretypes`
--

DROP TABLE IF EXISTS `hiretypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hiretypes` (
  `hireTypeId` int NOT NULL AUTO_INCREMENT,
  `code` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isActive` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`hireTypeId`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hiretypes`
--

LOCK TABLES `hiretypes` WRITE;
/*!40000 ALTER TABLE `hiretypes` DISABLE KEYS */;
INSERT INTO `hiretypes` VALUES (1,'ONE_WAY','Thuê 1 chiều','Thuê xe đi 1 chiều',1),(2,'ROUND_TRIP','Thuê 2 chiều (trong ngày)','Thuê xe đi và về trong ngày',1),(3,'MULTI_DAY','Thuê nhiều ngày','Thuê xe theo gói nhiều ngày',1),(4,'PERIODIC','Thuê định kỳ','Thuê lặp lại (đưa đón nhân viên, học sinh)',1),(5,'AIRPORT_TRANSFER','Đưa/đón sân bay','Gói đưa đón sân bay 1 chiều',1);
/*!40000 ALTER TABLE `hiretypes` ENABLE KEYS */;
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
  `type` enum('Income','Expense') COLLATE utf8mb4_unicode_ci NOT NULL,
  `costType` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isDeposit` tinyint(1) NOT NULL DEFAULT '0',
  `amount` decimal(18,2) NOT NULL,
  `paymentMethod` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paymentStatus` enum('UNPAID','PAID','REFUNDED') COLLATE utf8mb4_unicode_ci DEFAULT 'UNPAID',
  `status` enum('ACTIVE','CANCELLED') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `invoiceDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `img` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `requestedBy` int DEFAULT NULL,
  `createdBy` int DEFAULT NULL,
  `approvedBy` int DEFAULT NULL,
  `approvedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`invoiceId`),
  KEY `fk_inv_reqDriver` (`requestedBy`),
  KEY `fk_inv_createdBy` (`createdBy`),
  KEY `fk_inv_approvedBy` (`approvedBy`),
  KEY `IX_Invoices_Branch` (`branchId`,`invoiceDate`),
  KEY `IX_Invoices_Type_Status` (`type`,`status`),
  KEY `IX_Invoices_Booking` (`bookingId`),
  KEY `IX_Invoices_Customer` (`customerId`),
  KEY `IX_Invoices_PaymentStatus` (`paymentStatus`),
  CONSTRAINT `fk_inv_approvedBy` FOREIGN KEY (`approvedBy`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_inv_booking` FOREIGN KEY (`bookingId`) REFERENCES `bookings` (`bookingId`),
  CONSTRAINT `fk_inv_branch` FOREIGN KEY (`branchId`) REFERENCES `branches` (`branchId`),
  CONSTRAINT `fk_inv_createdBy` FOREIGN KEY (`createdBy`) REFERENCES `employees` (`employeeId`),
  CONSTRAINT `fk_inv_customer` FOREIGN KEY (`customerId`) REFERENCES `customers` (`customerId`),
  CONSTRAINT `fk_inv_reqDriver` FOREIGN KEY (`requestedBy`) REFERENCES `drivers` (`driverId`),
  CONSTRAINT `invoices_chk_1` CHECK ((`amount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
INSERT INTO `invoices` VALUES (1,1,1,2,'Income',NULL,1,1000000.00,'Chuyển khoản','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Đặt cọc Booking 1',NULL,5,2,'2025-11-12 11:23:08'),(2,1,1,2,'Income',NULL,0,2800000.00,'Tiền mặt','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Thu nốt Booking 1',NULL,5,2,'2025-11-12 11:23:08'),(3,3,2,4,'Income',NULL,1,500000.00,'Chuyển khoản','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Đặt cọc Booking 2',NULL,6,4,'2025-11-12 11:23:08'),(4,1,3,1,'Income',NULL,0,25000000.00,'Chuyển khoản','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Thanh toán HĐ định kỳ T11',NULL,5,2,'2025-11-12 11:23:08'),(5,1,5,5,'Income',NULL,0,1000000.00,'Chuyển khoản','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Thanh toán Booking 5',NULL,5,2,'2025-11-12 11:23:08'),(6,1,1,NULL,'Expense','fuel',0,1000000.00,'Tiền mặt','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Đổ dầu xe Trip 1',1,8,2,'2025-11-12 11:23:08'),(7,1,1,NULL,'Expense','toll',0,300000.00,'Thẻ ETC','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Phí cao tốc HN-HL Trip 1',1,8,2,'2025-11-12 11:23:08'),(8,2,NULL,NULL,'Expense','maintenance',0,5000000.00,'Chuyển khoản','PAID','ACTIVE','2025-11-12 11:23:08','2025-11-12 11:23:08',NULL,'Bảo dưỡng xe 43B-777.77',NULL,3,3,'2025-11-12 11:23:08');
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,2,'Yêu cầu nghỉ phép','Tài xế Trần Văn B vừa tạo yêu cầu nghỉ phép.','2025-11-12 11:23:08',0),(2,6,'Booking đã xác nhận','Booking #2 (Đón sân bay) đã được xác nhận.','2025-11-12 11:23:08',0),(3,11,'Giao việc mới','Bạn được gán lái Trip #2 (Đón sân bay TSN).','2025-11-12 11:23:08',0),(4,1,'Hợp đồng mới','Hợp đồng thuê định kỳ (Booking #3) vừa được kích hoạt.','2025-11-12 11:23:08',1),(5,7,'Hóa đơn đã duyệt','Hóa đơn chi phí (Xăng dầu Trip 1) đã được duyệt.','2025-11-12 11:23:08',0);
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Admin','Quản trị viên hệ thống','ACTIVE'),(2,'Manager','Quản lý chi nhánh','ACTIVE'),(3,'Consultant','Điều hành/Tư vấn','ACTIVE'),(4,'Driver','Tài xế','ACTIVE'),(5,'Accountant','Kế toán','ACTIVE');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `systemsettings`
--

DROP TABLE IF EXISTS `systemsettings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `systemsettings` (
  `settingId` int NOT NULL AUTO_INCREMENT,
  `settingKey` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `settingValue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `effectiveStartDate` date NOT NULL,
  `effectiveEndDate` date DEFAULT NULL,
  `valueType` enum('string','int','decimal','boolean','json') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'string',
  `category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updatedBy` int DEFAULT NULL,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('ACTIVE','INACTIVE') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`settingId`),
  UNIQUE KEY `settingKey` (`settingKey`),
  KEY `fk_sys_updBy` (`updatedBy`),
  CONSTRAINT `fk_sys_updBy` FOREIGN KEY (`updatedBy`) REFERENCES `employees` (`employeeId`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `systemsettings`
--

LOCK TABLES `systemsettings` WRITE;
/*!40000 ALTER TABLE `systemsettings` DISABLE KEYS */;
INSERT INTO `systemsettings` VALUES (1,'VAT_RATE','0.08','2025-01-01',NULL,'decimal','Billing','Tỷ lệ thuế VAT (8%)',1,'2025-11-12 11:23:08','ACTIVE'),(2,'DEFAULT_HIGHWAY','true','2025-01-01',NULL,'boolean','Booking','Mặc định chọn cao tốc khi tạo booking',1,'2025-11-12 11:23:08','ACTIVE'),(3,'MAX_DRIVING_HOURS_PER_DAY','10','2025-01-01',NULL,'int','Driver','Số giờ lái xe tối đa của tài xế/ngày',1,'2025-11-12 11:23:08','ACTIVE'),(4,'SUPPORT_HOTLINE','1900 1234','2025-01-01',NULL,'string','General','Số hotline hỗ trợ khách hàng',1,'2025-11-12 11:23:08','ACTIVE'),(5,'LATE_PAYMENT_FEE_RATE','0.05','2025-01-01',NULL,'decimal','Billing','Lãi suất phạt thanh toán chậm (5%/ngày)',1,'2025-11-12 11:23:08','ACTIVE');
/*!40000 ALTER TABLE `systemsettings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `token`
--

DROP TABLE IF EXISTS `token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `token` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_token` text COLLATE utf8mb4_unicode_ci,
  `refresh_token` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `IX_Token_Username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `token`
--

LOCK TABLES `token` WRITE;
/*!40000 ALTER TABLE `token` DISABLE KEYS */;
INSERT INTO `token` VALUES (1,'admin','eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6WyJST0xFX0FETUlOIl0sInVzZXJJZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsInN1YiI6ImFkbWluIiwiaWF0IjoxNzYyOTIxNDIyLCJleHAiOjE3NjMxMzc0MjJ9.B6lgYql6AAW8nE_Yn7tjYBnfSAhPHC1aErXFljdknZI','eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6WyJST0xFX0FETUlOIl0sInVzZXJJZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsInN1YiI6ImFkbWluIiwiaWF0IjoxNzYyOTIxNDIyLCJleHAiOjE3NjMzNTM0MjJ9.xOJWEaSPAFCE2zQft41ycQLksI2dnurwElI1nR0BLBU');
/*!40000 ALTER TABLE `token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tripdrivers`
--

DROP TABLE IF EXISTS `tripdrivers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tripdrivers` (
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
  CONSTRAINT `tripdrivers_chk_1` CHECK (((`startTime` is null) or (`endTime` is null) or (`startTime` < `endTime`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tripdrivers`
--

LOCK TABLES `tripdrivers` WRITE;
/*!40000 ALTER TABLE `tripdrivers` DISABLE KEYS */;
INSERT INTO `tripdrivers` VALUES (1,1,'Main Driver',NULL,NULL,'Tài xế A lái xe 29A-333.33'),(2,4,'Main Driver',NULL,NULL,'Tài xế D lái xe 51C-555.55'),(3,1,'Main Driver',NULL,NULL,'Tài xế A lái xe Trip 3 (sáng)'),(3,2,'Support Driver',NULL,NULL,'Tài xế B hỗ trợ Trip 3 (sáng)'),(4,1,'Main Driver',NULL,NULL,'Tài xế A lái xe Trip 4 (chiều)'),(4,2,'Support Driver',NULL,NULL,'Tài xế B hỗ trợ Trip 4 (chiều)'),(5,1,'Main Driver',NULL,NULL,'Tài xế A lái xe Trip 5 (sáng)'),(5,2,'Support Driver',NULL,NULL,'Tài xế B hỗ trợ Trip 5 (sáng)'),(6,5,'Main Driver',NULL,NULL,'Tài xế E lái xe Trip 6'),(7,3,'Main Driver',NULL,NULL,'Tài xế C lái xe Trip 7');
/*!40000 ALTER TABLE `tripdrivers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `triproutecache`
--

DROP TABLE IF EXISTS `triproutecache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `triproutecache` (
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
-- Dumping data for table `triproutecache`
--

LOCK TABLES `triproutecache` WRITE;
/*!40000 ALTER TABLE `triproutecache` DISABLE KEYS */;
/*!40000 ALTER TABLE `triproutecache` ENABLE KEYS */;
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
  `status` enum('SCHEDULED','ONGOING','COMPLETED','CANCELLED') COLLATE utf8mb4_unicode_ci DEFAULT 'SCHEDULED',
  PRIMARY KEY (`tripId`),
  KEY `IX_Trips_BookingId` (`bookingId`),
  KEY `IX_Trips_Status_Start` (`status`,`startTime`),
  KEY `IX_Trips_Distance` (`distance`),
  KEY `IX_Trips_StartLocation_Coords` (`startLatitude`,`startLongitude`),
  KEY `IX_Trips_EndLocation_Coords` (`endLatitude`,`endLongitude`),
  KEY `IX_Trips_EstimatedDuration` (`estimatedDuration`),
  CONSTRAINT `fk_trip_booking` FOREIGN KEY (`bookingId`) REFERENCES `bookings` (`bookingId`),
  CONSTRAINT `trips_chk_1` CHECK (((`startTime` is null) or (`endTime` is null) or (`startTime` < `endTime`)))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trips`
--

LOCK TABLES `trips` WRITE;
/*!40000 ALTER TABLE `trips` DISABLE KEYS */;
INSERT INTO `trips` VALUES (1,1,1,'2025-10-25 07:00:00','2025-10-25 20:00:00','Hoàn Kiếm, Hà Nội','Hạ Long, Quảng Ninh',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'COMPLETED'),(2,2,1,'2025-10-28 14:00:00','2025-10-28 15:30:00','Sân bay Tân Sơn Nhất','Quận 7, TP. HCM',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'SCHEDULED'),(3,3,0,'2025-11-01 07:00:00','2025-11-01 08:30:00','Nội thành Hà Nội','KCN Thăng Long',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'SCHEDULED'),(4,3,0,'2025-11-01 17:00:00','2025-11-01 18:30:00','KCN Thăng Long','Nội thành Hà Nội',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'SCHEDULED'),(5,3,0,'2025-11-02 07:00:00','2025-11-02 08:30:00','Nội thành Hà Nội','KCN Thăng Long',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'SCHEDULED'),(6,5,1,'2025-10-29 10:00:00','2025-10-29 11:00:00','Times City, Hà Nội','Sân bay Nội Bài',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'SCHEDULED'),(7,4,1,'2025-11-10 08:00:00',NULL,'Đà Nẵng','Huế',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UNKNOWN',0.00,'SCHEDULED');
/*!40000 ALTER TABLE `trips` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tripvehicles`
--

DROP TABLE IF EXISTS `tripvehicles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tripvehicles` (
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tripvehicles`
--

LOCK TABLES `tripvehicles` WRITE;
/*!40000 ALTER TABLE `tripvehicles` DISABLE KEYS */;
INSERT INTO `tripvehicles` VALUES (1,1,3,'2025-11-12 11:23:08','Gán xe Samco 29A-333.33 cho Trip 1'),(2,2,5,'2025-11-12 11:23:08','Gán xe Transit 51C-555.55 cho Trip 2'),(3,3,3,'2025-11-12 11:23:08','Gán xe 29A-333.33 cho Trip 3 (sáng)'),(4,3,6,'2025-11-12 11:23:08','Gán xe 29A-666.66 cho Trip 3 (sáng)'),(5,4,3,'2025-11-12 11:23:08','Gán xe 29A-333.33 cho Trip 4 (chiều)'),(6,4,6,'2025-11-12 11:23:08','Gán xe 29A-666.66 cho Trip 4 (chiều)'),(7,5,3,'2025-11-12 11:23:08','Gán xe 29A-333.33 cho Trip 5 (sáng)'),(8,5,6,'2025-11-12 11:23:08','Gán xe 29A-666.66 cho Trip 5 (sáng)'),(9,6,2,'2025-11-12 11:23:08','Gán xe Limousine 29A-222.22 cho Trip 6'),(10,7,4,'2025-11-12 11:23:08','Gán xe Universe 43B-444.44 cho Trip 7');
/*!40000 ALTER TABLE `tripvehicles` ENABLE KEYS */;
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
  `status` enum('ACTIVE','INACTIVE','SUSPENDED') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `email_verified` tinyint(1) DEFAULT '0',
  `verification_token` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userId`),
  UNIQUE KEY `username` (`username`),
  KEY `IX_Users_RoleId` (`roleId`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`roleId`) REFERENCES `roles` (`roleId`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,1,'Admin Tổng','admin','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','admin@ptcmss.com','0900000001',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(2,2,'Quản Lý Hà Nội','manager_hn','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','manager.hn@ptcmss.com','0900000002',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(3,2,'Quản Lý Đà Nẵng','manager_dn','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','manager.dn@ptcmss.com','0900000003',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(4,2,'Quản Lý HCM','manager_hcm','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','manager.hcm@ptcmss.com','0900000004',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(5,3,'Điều Hành Viên 1 (HN)','consultant_hn1','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','c1.hn@ptcmss.com','0900000005',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(6,3,'Điều Hành Viên 2 (HN)','consultant_hn2','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','c2.hn@ptcmss.com','0900000006',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(7,5,'Kế Toán 1 (HN)','accountant_hn1','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','k1.hn@ptcmss.com','0900000007',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(8,4,'Tài Xế Nguyễn Văn A','driver_a','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.a@ptcmss.com','0912345671',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(9,4,'Tài Xế Trần Văn B','driver_b','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.b@ptcmss.com','0912345672',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(10,4,'Tài Xế Lê Hữu C','driver_c','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.c@ptcmss.com','0912345673',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(11,4,'Tài Xế Phạm Đình D','driver_d','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.d@ptcmss.com','0912345674',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(12,4,'Tài Xế Huỳnh Tấn E','driver_e','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.e@ptcmss.com','0912345675',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(13,4,'Tài Xế Vũ Minh F','driver_f','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.f@ptcmss.com','0912345676',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08'),(14,4,'Tài Xế Đặng Văn G','driver_g','$2a$10$P2Hh.Eos8YK/MxXUXSqOjOQMdmoQay/aL7lpNv.LHjC3AdSUGODfq','driver.g@ptcmss.com','0912345677',NULL,NULL,'ACTIVE',0,NULL,'2025-11-12 11:23:08');
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
-- Table structure for table `vehiclecategorypricing`
--

DROP TABLE IF EXISTS `vehiclecategorypricing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehiclecategorypricing` (
  `categoryId` int NOT NULL AUTO_INCREMENT,
  `categoryName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `baseFare` decimal(10,2) DEFAULT NULL,
  `pricePerKm` decimal(10,2) DEFAULT NULL,
  `highwayFee` decimal(10,2) DEFAULT NULL,
  `fixedCosts` decimal(10,2) DEFAULT NULL,
  `effectiveDate` date DEFAULT (curdate()),
  `status` enum('ACTIVE','INACTIVE') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`categoryId`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehiclecategorypricing`
--

LOCK TABLES `vehiclecategorypricing` WRITE;
/*!40000 ALTER TABLE `vehiclecategorypricing` DISABLE KEYS */;
INSERT INTO `vehiclecategorypricing` VALUES (1,'Xe 9 chỗ (Limousine)','DCar/Solati Limousine',800000.00,15000.00,100000.00,0.00,'2025-11-12','ACTIVE','2025-11-12 11:23:08'),(2,'Xe 16 chỗ','Ford Transit, Mercedes Sprinter',1200000.00,18000.00,120000.00,0.00,'2025-11-12','ACTIVE','2025-11-12 11:23:08'),(3,'Xe 29 chỗ','Hyundai County, Samco Isuzu',1800000.00,22000.00,150000.00,0.00,'2025-11-12','ACTIVE','2025-11-12 11:23:08'),(4,'Xe 45 chỗ','Hyundai Universe',2500000.00,28000.00,200000.00,0.00,'2025-11-12','ACTIVE','2025-11-12 11:23:08'),(5,'Xe giường nằm (40 chỗ)','Xe giường nằm Thaco/Hyundai',3000000.00,30000.00,250000.00,0.00,'2025-11-12','ACTIVE','2025-11-12 11:23:08');
/*!40000 ALTER TABLE `vehiclecategorypricing` ENABLE KEYS */;
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
  CONSTRAINT `fk_veh_cat` FOREIGN KEY (`categoryId`) REFERENCES `vehiclecategorypricing` (`categoryId`),
  CONSTRAINT `vehicles_chk_1` CHECK ((`productionYear` >= 1980))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicles`
--

LOCK TABLES `vehicles` WRITE;
/*!40000 ALTER TABLE `vehicles` DISABLE KEYS */;
INSERT INTO `vehicles` VALUES (1,2,1,'29A-111.11','Ford Transit',NULL,16,2022,'2022-01-01','2026-06-30',NULL,NULL,'AVAILABLE'),(2,1,1,'29A-222.22','DCar Limousine',NULL,9,2023,'2023-05-01','2026-04-30',NULL,NULL,'AVAILABLE'),(3,3,1,'29A-333.33','Samco Isuzu',NULL,29,2021,'2021-03-01','2025-08-30',NULL,NULL,'AVAILABLE'),(4,4,2,'43B-444.44','Hyundai Universe',NULL,45,2023,'2023-06-01','2025-11-30',NULL,NULL,'AVAILABLE'),(5,2,3,'51C-555.55','Ford Transit',NULL,16,2022,'2022-07-01','2026-12-31',NULL,NULL,'INUSE'),(6,3,1,'29A-666.66','Hyundai County',NULL,29,2022,'2022-09-01','2026-02-28',NULL,NULL,'AVAILABLE'),(7,5,2,'43B-777.77','Thaco Mobihome',NULL,40,2023,'2023-08-15','2025-02-14',NULL,NULL,'MAINTENANCE');
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
/*!50001 VIEW `v_drivermonthlyperformance` AS select `d`.`driverId` AS `driverId`,year(`t`.`startTime`) AS `year`,month(`t`.`startTime`) AS `month`,count(distinct `td`.`tripId`) AS `tripsCount`,sum((case when ((`td`.`startTime` is not null) and (`td`.`endTime` is not null)) then timestampdiff(MINUTE,`td`.`startTime`,`td`.`endTime`) else 0 end)) AS `minutesOnTrip` from ((`tripdrivers` `td` join `drivers` `d` on((`d`.`driverId` = `td`.`driverId`))) join `trips` `t` on((`t`.`tripId` = `td`.`tripId`))) group by `d`.`driverId`,year(`t`.`startTime`),month(`t`.`startTime`) */;
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
/*!50001 VIEW `v_popularroutes` AS select `triproutecache`.`startLocation` AS `startLocation`,`triproutecache`.`endLocation` AS `endLocation`,count(0) AS `cacheEntryCount`,avg(`triproutecache`.`distance`) AS `avgDistance`,avg(`triproutecache`.`duration`) AS `avgDuration`,sum(`triproutecache`.`hitCount`) AS `totalCacheHits`,max(`triproutecache`.`lastUsedAt`) AS `lastUsed`,max(`triproutecache`.`createdAt`) AS `lastCached` from `triproutecache` where (`triproutecache`.`createdAt` >= (now() - interval 30 day)) group by `triproutecache`.`startLocation`,`triproutecache`.`endLocation` having (sum(`triproutecache`.`hitCount`) > 0) order by `totalCacheHits` desc,`lastUsed` desc limit 100 */;
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

-- Dump completed on 2025-11-22  0:29:50
