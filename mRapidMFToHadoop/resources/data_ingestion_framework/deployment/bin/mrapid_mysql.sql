-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: mrapid_demo
-- ------------------------------------------------------
-- Server version	5.1.73

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `mrapid_demo`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `mrapid_demo` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `mrapid_demo`;

--
-- Table structure for table `job_details`
--

DROP TABLE IF EXISTS `job_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_details` (
  `job_id` int(4) unsigned NOT NULL,
  `file_type` varchar(20) NOT NULL,
  `source_data_file_name` varchar(50) DEFAULT NULL,
  `source_layout_file_name` varchar(50) DEFAULT NULL,
  `source_data_file_location` varchar(100) DEFAULT NULL,
  `source_layout_file_location` varchar(100) DEFAULT NULL,
  `source_data_format` varchar(20) DEFAULT NULL,
  `source_file_category` varchar(20) DEFAULT NULL,
  `source_file_format` varchar(20) DEFAULT NULL,
  `target_load_type` varchar(10) DEFAULT NULL,
  `hdfs_file_name` varchar(50) DEFAULT NULL,
  `hdfs_file_location` varchar(100) DEFAULT NULL,
  `hive_table_name` varchar(50) DEFAULT NULL,
  `hive_table_location` varchar(100) DEFAULT NULL,
  `record_length` int(4) DEFAULT NULL,
  `column_separator` varchar(10) DEFAULT NULL,
  `num_of_lines_in_header` int(4) DEFAULT NULL,
  `num_of_lines_in_trailer` int(4) DEFAULT NULL,
  `recon_col_pos` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`job_id`),
  KEY `FK_job_master` (`job_id`),
  CONSTRAINT `FK_job_master` FOREIGN KEY (`job_id`) REFERENCES `job_master` (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_details`
--

LOCK TABLES `job_details` WRITE;
/*!40000 ALTER TABLE `job_details` DISABLE KEYS */;
INSERT INTO `job_details` VALUES (2,'Mainframe','hguserm.txt','hgduserm.copyc.txt','landing/data','landing/layout/','EBCDIC','','Fixed','HDFS','hguserm_output.txt','/hdfs/data','','',200,NULL,NULL,NULL,NULL),(3,'Mainframe','sample_comp_data.txt','sample_comp_copyc.txt','/landing/data','/landing/layout','EBCDIC','','Fixed','HDFS','sample_comp_data.txt','/hdfs/data','','',100,NULL,NULL,NULL,NULL),(6,'As-Is','job_execution.log','','/landing/data','','EBCDIC','','Fixed','HDFS','job_execution.log','/hdfs/data','','',1000,NULL,NULL,NULL,NULL),(7,'Delimited','test_data.csv','test_layout.csv','/landing/data','/landing/layout',NULL,NULL,NULL,'Hive','test_data.csv','/hdfs/data','datalake.test_csv_tbl',NULL,NULL,',',2,1,'6:4'),(8,'Delimited','pipe_comp_test_data.txt.gz','pipe_comp_test_layout.csv','/landing/data','/landing/layout',NULL,NULL,NULL,'Hive','pipe_comp_test_data.txt','/hdfs/data','datalake.pipe_comp_test_tbl',NULL,NULL,'|',0,1,'10:1'),(12,'Mainframe','sample_cobol_file.dat','sample_cobol_copyc.txt','/landing/data','/landing/layout','EBCDIC','','Fixed','Hive','','','datalake.sample_cobol_tbl','',50,NULL,NULL,NULL,NULL),(13,'Mainframe','hgbranm.txt','hgdbran2.copyc.txt','/landing/data','/landing/layout','EBCDIC','','Variable','Hive','','','datalake.hgbranm_tbl','',0,NULL,NULL,NULL,NULL),(15,'SAS','new.sas7bdat',NULL,'/landing/data',NULL,NULL,'',NULL,'HDFS','new.sas7bdat','/hdfs/data','',NULL,NULL,NULL,NULL,NULL,NULL),(16,'SAS','new.sas7bdat',NULL,'/landing/data',NULL,NULL,'',NULL,'Hive','new.sas7bdat','/hdfs/data','datalake.sas_demo_tbl',NULL,NULL,NULL,NULL,NULL,NULL),(17,'RDBMS','bank_delta.customer_details',NULL,'jdbc:mysql://10.8.32.75',NULL,'cgfspoc1','','cgfspoc1','HDFS','customer_details.csv','/hdfs/data/','','',0,NULL,NULL,NULL,NULL),(18,'RDBMS','bank_txn.account_txn',NULL,'jdbc:mysql://10.8.32.75',NULL,'cgfspoc1','','cgfspoc1','Hive','bank_txn.account_txn','','datalake.account_txn','',0,NULL,NULL,NULL,NULL),(38,'Mainframe','GPFCGIM_POC_PARTIAL.DAT','gpdcgim.incl.txt','/landing/data','/landing/layout','EBCDIC',NULL,'Variable','Hive','','','datalake.gpfcgim_tbl',NULL,0,NULL,NULL,NULL,NULL),(39,'As-IS','nifi_test.txt',NULL,'/opt/cgfspoc1/nifi_data','/opt/cgfspoc1/nifi_put_data',NULL,NULL,NULL,NULL,NULL,'/user/cgfspoc1/nifi_asis',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(43,'As-Is','*.txt',NULL,'/opt/cgfspoc1/cap/landing/data/nifi_data','/opt/cgfspoc1/cap/landing/data/nifi_put_data',NULL,NULL,NULL,'HDFS','Null','/user/cgfspoc1/nifi_asis','',NULL,NULL,NULL,NULL,NULL,NULL),(44,'As-Is','*',NULL,'/opt/cgfspoc1/cap/landing/data/nifi_data','/opt/cgfspoc1/cap/landing/data/nifi_put_data',NULL,NULL,NULL,'HDFS','','/user/cgfspoc1/nifi_asis','',NULL,NULL,NULL,NULL,NULL,NULL),(45,'As-Is','file.txt',NULL,'/opt/cgfspoc1/cap/landing/data/nifi_data','/opt/cgfspoc1/cap/landing/data/nifi_put_data',NULL,NULL,NULL,'HDFS','file2.txt','/user/cgfspoc1/nifi_asis','',NULL,NULL,NULL,NULL,NULL,NULL),(55,'Mainframe','scb_mf_data_file.dat','scb_mf_tbl_layout.txt','/landing/data','/landing/layout','EBCDIC',NULL,'Variable','Hive','','','datalake.scb_mf_tbl',NULL,0,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `job_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_details_bkp`
--

DROP TABLE IF EXISTS `job_details_bkp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_details_bkp` (
  `job_id` int(4) unsigned NOT NULL,
  `file_type` varchar(20) CHARACTER SET utf8 NOT NULL,
  `source_data_file_name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `source_layout_file_name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `source_data_file_location` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `source_layout_file_location` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `source_data_format` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `source_file_category` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `source_file_format` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `target_load_type` varchar(10) CHARACTER SET utf8 DEFAULT NULL,
  `hdfs_file_name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `hdfs_file_location` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `hive_table_name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `hive_table_location` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `record_length` int(4) DEFAULT NULL,
  `column_separator` varchar(10) CHARACTER SET utf8 DEFAULT NULL,
  `num_of_lines_in_header` int(4) DEFAULT NULL,
  `num_of_lines_in_trailer` int(4) DEFAULT NULL,
  `recon_col_pos` varchar(10) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_details_bkp`
--

LOCK TABLES `job_details_bkp` WRITE;
/*!40000 ALTER TABLE `job_details_bkp` DISABLE KEYS */;
INSERT INTO `job_details_bkp` VALUES (3,'SAS','sas job',NULL,'sas job',NULL,NULL,'',NULL,'HDFS','sas job','sas job','df',NULL,NULL,NULL,NULL,NULL,NULL),(11,'As-Is','asis new sas',NULL,'asis new sas',NULL,NULL,'',NULL,'HDFS','asis new sas','asis new sas',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(21,'Mainframe','customer.txt','account.txt','user/lib','root/user/name','EBCDIC',NULL,'Fixed','HDFS','newcustomer.tz','cloudera/hive/traning','customer',NULL,4,NULL,NULL,NULL,NULL),(27,'Delimited','Delimited',NULL,'Delimited',NULL,NULL,NULL,NULL,'HDFS','sdfdfdf','dsf','sdf',NULL,NULL,',',4,5,'sdfd'),(32,'As-Is','as is job',NULL,'user/lib',NULL,NULL,NULL,NULL,'HDFS','dfgdfg','cloudera/hive/traning',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(33,'SAS','ssssu job',NULL,'ssssu job',NULL,NULL,NULL,NULL,'HDFS','ssssu job','cloudera/hive/traning','ertertert',NULL,NULL,NULL,NULL,NULL,NULL),(34,'Delimited','Delimited3',NULL,'user/lib2',NULL,NULL,NULL,NULL,'Hive','utyuhgj7','cloudera/hive/traning8','tyty8',NULL,NULL,'/\"',65,75,'6'),(36,'Mainframe','hgbranm.txt','hgdbran2.copyc.txt','/landing/data','/landing/layout','EBCDIC',NULL,'Fixed','Hdfs','hgbranm.txt','/hdfs/data','datalake.hgbranm',NULL,80,NULL,NULL,NULL,NULL),(37,'Mainframe','sample_comp_data.txt','sample_comp_copyc.txt','/landing/data','/landing/layout','EBCDIC',NULL,'Fixed','Hive','','','datalake.comp_sample_tbl',NULL,100,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `job_details_bkp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_details_table_list`
--

DROP TABLE IF EXISTS `job_details_table_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_details_table_list` (
  `job_id` int(11) DEFAULT NULL,
  `table_name` varchar(30) DEFAULT NULL,
  `hive_table_name` varchar(50) DEFAULT NULL,
  `hive_db_name` varchar(30) DEFAULT NULL,
  `key_column` varchar(30) DEFAULT NULL,
  `audit_column` varchar(30) DEFAULT NULL,
  `rec_status_column` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_details_table_list`
--

LOCK TABLES `job_details_table_list` WRITE;
/*!40000 ALTER TABLE `job_details_table_list` DISABLE KEYS */;
INSERT INTO `job_details_table_list` VALUES (1,'emp','emp','default','id','last_changed','status'),(1,'dept','dept','default','dept_id','last_changed','status');
/*!40000 ALTER TABLE `job_details_table_list` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_execution_details`
--

DROP TABLE IF EXISTS `job_execution_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_execution_details` (
  `job_execution_details_id` int(11) NOT NULL AUTO_INCREMENT,
  `job_execution_id` int(11) DEFAULT NULL,
  `source_data_file_name` varchar(50) DEFAULT NULL,
  `source_layout_file_name` varchar(50) DEFAULT NULL,
  `source_data_file_location` varchar(100) DEFAULT NULL,
  `source_layout_file_location` varchar(100) DEFAULT NULL,
  `target_file_name` varchar(50) DEFAULT NULL,
  `target_file_location` varchar(100) DEFAULT NULL,
  `userid` varchar(20) DEFAULT NULL,
  `job_start` datetime DEFAULT NULL,
  `job_end` datetime DEFAULT NULL,
  `job_result` char(1) DEFAULT NULL,
  `job_comments` varchar(100) DEFAULT NULL,
  `job_command` varchar(100) DEFAULT NULL,
  `job_stage` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`job_execution_details_id`),
  KEY `job_execution_details_ibfk_1` (`job_execution_id`),
  CONSTRAINT `job_execution_details_ibfk_1` FOREIGN KEY (`job_execution_id`) REFERENCES `job_execution_master` (`job_execution_id`)
) ENGINE=InnoDB AUTO_INCREMENT=848 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_execution_details`
--

LOCK TABLES `job_execution_details` WRITE;
/*!40000 ALTER TABLE `job_execution_details` DISABLE KEYS */;
INSERT INTO `job_execution_details` VALUES (825,363,'bank_txn.account_txn',NULL,'jdbc:mysql://10.8.32.75',NULL,'account_txn','datalake','cgfspoc1','2016-09-29 08:55:40','2016-09-29 08:55:40','S','Completed Successfully','sh load_data.sh CG/201605/0002','Staging'),(826,363,'bank_txn.account_txn',NULL,'jdbc:mysql://10.8.32.75',NULL,'account_txn','datalake','cgfspoc1','2016-09-29 08:55:40','2016-09-29 08:56:17','S','Completed Successfully','sh load_data.sh CG/201605/0002','Hive'),(830,365,'new.sas7bdat',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'new.sas7bdat.20160930','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-09-30 06:57:09','2016-09-30 06:57:16','S','Completed Successfully','sh load_data.sh CG/201604/000007','Staging'),(831,365,'new.sas7bdat',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'new.sas7bdat.20160930','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-09-30 06:57:16','2016-09-30 06:57:20','S','Completed Successfully','sh load_data.sh CG/201604/000007','Conversion'),(832,365,'new.sas7bdat',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'new.sas7bdat.20160930','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-09-30 06:57:20','2016-09-30 06:57:48','S','Completed Successfully','sh load_data.sh CG/201604/000007','Hive'),(833,366,'new.sas7bdat',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'new.sas7bdat.20160930','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-09-30 07:27:22','2016-09-30 07:27:29','S','Completed Successfully','sh load_data.sh CG/201604/000006','Staging'),(834,366,'new.sas7bdat',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'new.sas7bdat.20160930','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-09-30 07:27:29','2016-09-30 07:27:32','S','Completed Successfully','sh load_data.sh CG/201604/000006','Conversion'),(835,366,'new.sas7bdat',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'new.sas7bdat.20160930','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-09-30 07:27:32','2016-09-30 07:27:35','S','Completed Successfully','sh load_data.sh CG/201604/000006','Hdfs'),(836,367,'pipe_comp_test_data.txt.gz',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'pipe_comp_test_data.txt.20160930','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-09-30 07:30:00','2016-09-30 07:30:08','S','Completed Successfully','sh load_data.sh CAP/201603/0008','Staging'),(837,367,'pipe_comp_test_data.txt.gz',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'pipe_comp_test_data.txt.20160930','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-09-30 07:30:08','2016-09-30 07:30:08','S','Completed Successfully','sh load_data.sh CAP/201603/0008','Unzip'),(838,367,'pipe_comp_test_data.txt.gz',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'pipe_comp_test_data.txt.20160930','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-09-30 07:30:08','2016-09-30 07:31:21','S','Completed Successfully','sh load_data.sh CAP/201603/0008','Hive'),(841,369,'hgbranm.txt',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'.20161001','data_lake/hdfs_storage','cgfspoc1','2016-10-01 02:31:36','2016-10-01 02:31:43','S','Completed Successfully','sh load_data.sh CG/201603/000005','Staging'),(842,369,'hgbranm.txt',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'.20161001','data_lake/hdfs_storage','cgfspoc1','2016-10-01 02:31:43','2016-10-01 02:33:12','S','Completed Successfully','sh load_data.sh CG/201603/000005','Hive'),(843,370,'hgbranm.txt',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'.20161003','data_lake/hdfs_storage','cgfspoc1','2016-10-03 01:21:39','2016-10-03 01:21:46','S','Completed Successfully','sh load_data.sh CG/201603/000005','Staging'),(844,370,'hgbranm.txt',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'.20161003','data_lake/hdfs_storage','cgfspoc1','2016-10-03 01:21:46','2016-10-03 01:22:17','S','Completed Successfully','sh load_data.sh CG/201603/000005','Hive'),(845,371,'new.sas7bdat',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'new.sas7bdat.20161003','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-10-03 06:10:59','2016-10-03 06:11:06','S','Completed Successfully','sh load_data.sh CG/201604/000007','Staging'),(846,371,'new.sas7bdat',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'new.sas7bdat.20161003','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-10-03 06:11:06','2016-10-03 06:11:10','S','Completed Successfully','sh load_data.sh CG/201604/000007','Conversion'),(847,371,'new.sas7bdat',NULL,'/opt/cgfspoc1/cap/landing/data',NULL,'new.sas7bdat.20161003','data_lake/hdfs_storage/hdfs/data','cgfspoc1','2016-10-03 06:11:10','2016-10-03 06:11:37','S','Completed Successfully','sh load_data.sh CG/201604/000007','Hive');
/*!40000 ALTER TABLE `job_execution_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_execution_master`
--

DROP TABLE IF EXISTS `job_execution_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_execution_master` (
  `job_id` int(4) unsigned NOT NULL,
  `job_execution_id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`job_execution_id`),
  KEY `job_id` (`job_id`),
  CONSTRAINT `job_execution_master_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `job_master` (`job_id`)
) ENGINE=InnoDB AUTO_INCREMENT=372 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_execution_master`
--

LOCK TABLES `job_execution_master` WRITE;
/*!40000 ALTER TABLE `job_execution_master` DISABLE KEYS */;
INSERT INTO `job_execution_master` VALUES (8,367),(13,369),(13,370),(15,366),(16,365),(16,371),(18,363);
/*!40000 ALTER TABLE `job_execution_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_master`
--

DROP TABLE IF EXISTS `job_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_master` (
  `job_id` int(4) unsigned NOT NULL AUTO_INCREMENT,
  `job_code` varchar(50) NOT NULL,
  `job_name` varchar(50) DEFAULT NULL,
  `job_description` varchar(100) DEFAULT NULL,
  `job_type` varchar(10) NOT NULL,
  `job_created_date` date DEFAULT NULL,
  `job_execution_status` char(1) DEFAULT NULL,
  PRIMARY KEY (`job_id`),
  UNIQUE KEY `unique_index` (`job_code`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_master`
--

LOCK TABLES `job_master` WRITE;
/*!40000 ALTER TABLE `job_master` DISABLE KEYS */;
INSERT INTO `job_master` VALUES (2,'CAP/201603/0002','Load user details','Load user details EBCDIC file to HDFS','Mainframe','2016-03-02',NULL),(3,'CAP/201603/0003','Load comp-3 data file','Load EBCDIC file with comp-3 field to HDFS','Mainframe','2016-03-02',NULL),(6,'CAP/201603/0006','Load flat data file','','File','2016-03-04',NULL),(7,'CAP/201603/0007','Load delimited data file','Load csv file with header & footer to HIVE','File','2016-03-14',NULL),(8,'CAP/201603/0008','Load delimited data file','Load compressed pipe delimited file to HIVE','File','2016-03-16',NULL),(12,'CG/201603/000004','Load comp and comp-3 data','','Mainframe','2016-03-29',NULL),(13,'CG/201603/000005','Load Branch Master','','Mainframe','2016-03-29',NULL),(15,'CG/201604/000006','SAS_HDFS_JOB','','SAS','2016-04-21',NULL),(16,'CG/201604/000007','LOAD-SAS001','1st data set for SAS','SAS','2016-04-21',NULL),(17,'CG/201605/0001','RDBMS to HDFS Load','Imporing data from mysql to hdfs file','DBMS','2016-05-17',NULL),(18,'CG/201605/0002','RDBMS to Hive Load','Imporing data from mysql to hive table','DBMS','2016-05-17',NULL),(38,'CG/201605/0003','Mainframe variable length','Loading variable length EBCDIC file to Hive','Mainframe','2016-05-26',NULL),(39,'CG/201606/0001','ASIS','ASIS test with comprassion','FILE','2016-06-27',NULL),(40,'CG/201606/0006','ASIS','As-Is job with NiFi','File','0000-00-00',NULL),(43,'CAPG/201607/0023','As-Is','load multiple flat file using NIFI','File','2016-07-01',NULL),(44,'CAPG/201607/0024','As-Is','multiple flat file of specific extension','File','2016-07-05',NULL),(45,'CAPG/201607/0025','As-Is','large flat file','As-Is','2016-07-05',NULL),(55,'CAPG/201609/0035','Mainframe Variable length','','Mainframe','2016-09-27',NULL);
/*!40000 ALTER TABLE `job_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_master_bkp`
--

DROP TABLE IF EXISTS `job_master_bkp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_master_bkp` (
  `job_id` int(4) unsigned NOT NULL DEFAULT '0',
  `job_code` varchar(50) CHARACTER SET utf8 NOT NULL,
  `job_name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `job_description` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `job_type` varchar(10) CHARACTER SET utf8 NOT NULL,
  `job_created_date` date DEFAULT NULL,
  `job_execution_status` char(1) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_master_bkp`
--

LOCK TABLES `job_master_bkp` WRITE;
/*!40000 ALTER TABLE `job_master_bkp` DISABLE KEYS */;
INSERT INTO `job_master_bkp` VALUES (3,'HSBC/201603/000003','TERADATA','sas job','File','2016-04-25',NULL),(11,'HSBC/201603/000011','asis new sas','asis new sas','File','2016-03-22',NULL),(21,'CAPG/201604/0004','Mainframe data from UI','Mainframe data from UI','File','2016-04-21',NULL),(27,'CAPG/201604/0010','Delimited','Delimited','File','2016-04-22',NULL),(32,'CAPG/201604/0015','as is job','as is job','File','2016-04-25',NULL),(33,'CAPG/201604/0016','sa ssssu job','ssssu job','File','2016-04-25',NULL),(34,'CAPG/201604/0017','Delimited jobs1','Delimited jobs Delimited jobs Delimited jobs2','File','2016-04-25',NULL),(36,'CAPG/201604/0019','AU_SYS_001','Load mainframe EBCDIC file','File','2016-04-29',NULL),(37,'CAPG/201605/0020','GL_Comp-3_File','Load Comp-3 Sample','File','2016-05-10',NULL);
/*!40000 ALTER TABLE `job_master_bkp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_template`
--

DROP TABLE IF EXISTS `job_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_template` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `template_name` varchar(255) NOT NULL,
  `group_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_template`
--

LOCK TABLES `job_template` WRITE;
/*!40000 ALTER TABLE `job_template` DISABLE KEYS */;
INSERT INTO `job_template` VALUES (1,'TestTemplateToCompress','TestTemplateToCompress'),(2,'As-IS','As-Is');
/*!40000 ALTER TABLE `job_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `master_setup`
--

DROP TABLE IF EXISTS `master_setup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `master_setup` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `job_code_prefix` varchar(20) DEFAULT NULL,
  `add_yyyymm_with_prefix` char(1) DEFAULT 'T',
  `job_code_sequence` int(10) DEFAULT NULL,
  `left_padding_zeros` int(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `master_setup`
--

LOCK TABLES `master_setup` WRITE;
/*!40000 ALTER TABLE `master_setup` DISABLE KEYS */;
INSERT INTO `master_setup` VALUES (1,'CAPG','T',44,4);
/*!40000 ALTER TABLE `master_setup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_details`
--

DROP TABLE IF EXISTS `user_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_details` (
  `user_id` int(4) unsigned NOT NULL AUTO_INCREMENT,
  `user_name` varchar(100) NOT NULL,
  `role` varchar(100) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `password` varchar(100) NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `unique_index` (`user_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_details`
--

LOCK TABLES `user_details` WRITE;
/*!40000 ALTER TABLE `user_details` DISABLE KEYS */;
INSERT INTO `user_details` VALUES (1,'guest','guest','guest','guest','guest');
/*!40000 ALTER TABLE `user_details` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-10-06  3:33:24
