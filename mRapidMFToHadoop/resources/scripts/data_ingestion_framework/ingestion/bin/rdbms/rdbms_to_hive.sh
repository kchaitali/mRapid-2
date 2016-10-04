#!/bin/bash

#####
# NAME: rdbms_to_hive.sh
# 
#####

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 7 7 $#

JOB_ID=$1
JOB_EX_ID=$2
SOURCE_DB=`echo $3 | cut -d '.' -f1`
SOURCE_TABLE=`echo $3 | cut -d '.' -f2`
HIVE_TABLE=$7

CONNECTION_URL="${6}/${SOURCE_DB}"
USERNAME=$4
PASSWORD=$5

mysql_connector="$APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/rdbms/mysql-connector-java-5.1.39-bin.jar"
export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$mysql_connector

log -i "Connecting to $CONNECTION_URL for importing $SOURCE_TABLE"
sqoop import --connect $CONNECTION_URL --driver com.mysql.jdbc.Driver --username "$USERNAME" --password "$PASSWORD" --table $SOURCE_TABLE --hive-table $HIVE_TABLE --hive-import --m 1 --outdir /tmp/sqoop
catchError $? "Failed to import table: $SOURCE_TABLE"

log -i "Ended Successfully: `basename $0`"
