#!/bin/bash

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh

log -i "Started Executing: `basename $0`"
log -i "Getting required information"
mysql_username=$(getProperty MYSQL_USERNAME)
mysql_password=$(getProperty MYSQL_PASSWORD)
base_data_path=$(getProperty BASE_DATA_PATH)
hdfs_base_path=$(getProperty HDFS_BASE_PATH)
hive_warehouse_location=$(getProperty HIVE_WAREHOUSE_LOCATION)
hive_db=$(getProperty HIVE_DB)
staging_area=$(getProperty STAGING_AREA)

log -i "Creating local directories: $base_data_path, $APPL_BASE_PATH/tmp"
mkdir -p $base_data_path $APPL_BASE_PATH/tmp
catchError $? "Failed to create local directories"

log -i "Creating hdfs directories: $staging_area, $hdfs_base_path, $hive_warehouse_location"
hadoop fs -mkdir -p $staging_area $hdfs_base_path $hive_warehouse_location
catchError $? "Failed to create hdfs directories"

log -i "Creating hive database: $hive_db"
hive -S -e "CREATE DATABASE IF NOT EXISTS $hive_db"
catchError $? "Failed to create hive database"

#log -i "Creating technical metadata schema"
#sh $APPL_BASE_PATH/data_ingestion_framework/deployment/bin/create_tech_schema.sh $mysql_username $mysql_password
#catchError $? "Unsuccessful execution of create_tech_schema.sh"

#log -i "Creating operational metadata schema"
#sh $APPL_BASE_PATH/data_ingestion_framework/deployment/bin/create_ops_schema.sh $mysql_username $mysql_password
#catchError $? "Unsuccessful execution of create_ops_schema.sh"

log -i "Ended Successfully: `basename $0`"

