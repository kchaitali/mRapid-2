#!/bin/bash

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh

log -i "Started Executing: `basename $0`"
log -i "Getting required information"
mysql_hostname=$(getProperty MYSQL_HOSTNAME)
mysql_username=$(getProperty MYSQL_USERNAME)
mysql_password=$(getProperty MYSQL_PASSWORD)
ops_db=$(getProperty OPS_DB)
hive_db=$(getProperty HIVE_DB)
hdfs_path=$(getProperty HDFS_BASE_PATH)
hive_warehouse_location=$(getProperty HIVE_WAREHOUSE_LOCATION)
staging_area=$(getProperty STAGING_AREA)

log -i "Cleaning operational metadata tables: ${ops_db}.job_execution_details, ${ops_db}.job_execution_master"
mysql --host=$mysql_hostname --user=$mysql_username --password=$mysql_password --execute="delete from ${ops_db}.job_execution_details; delete from ${ops_db}.job_execution_master"
catchError $? "Failed to clean operational metadata tables"

log -i "Dropping hive database: $hive_db"
hive -S -e "DROP DATABASE IF EXISTS $hive_db CASCADE"
catchError $? "Failed to drop hive database"

log -i "Deleting hdfs directories: $hdfs_path, $hive_warehouse_location, $staging_area"
hadoop fs -rm -r -skipTrash $hdfs_path $hive_warehouse_location $staging_area
#catchError $? "Failed"

log -i "Removing temperory data: $APPL_BASE_PATH/tmp/*"
rm -rf $APPL_BASE_PATH/tmp/*
#catchError $? "Failed"

log -i "Removing failed jobs leftover if any: /tmp/dump_*"
hadoop fs -rm -r -skipTrash /tmp/dump_*

log -i "Ended Successfully: `basename $0`"
