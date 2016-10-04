#!/bin/bash

#####
# NAME: rdbms_to_hdfs.sh
#
#####

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 7 7 $#

JOB_ID=$1
JOB_EX_ID=$2
SOURCE_DB=`echo $3 | cut -d '.' -f1`
SOURCE_TABLE=`echo $3 | cut -d '.' -f2`
HDFS_FILE=$7

CONNECTION_URL="${6}/${SOURCE_DB}"
USERNAME=$4
PASSWORD=$5

tmp_dir="/tmp/s_i_${JOB_ID}_${JOB_EX_ID}_`date +%s_%N_$RANDOM`"
mysql_connector="$APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/rdbms/mysql-connector-java-5.1.39-bin.jar"

export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$mysql_connector

log -i "Connecting to $CONNECTION_URL for importing $SOURCE_TABLE"
sqoop import --connect $CONNECTION_URL --driver com.mysql.jdbc.Driver --username "$USERNAME" --password "$PASSWORD" --table $SOURCE_TABLE --target-dir $tmp_dir --m 1 --outdir /tmp/sqoop
catchError $? "Failed to import table: $SOURCE_TABLE"

log -i "Copying imported data to hdfs file: $HDFS_FILE"
hadoop fs -cp $tmp_dir/part-m-* $HDFS_FILE
catchError $? "Failed to copy file"

log -i "Removing temporary directory"
hadoop fs -rm -r $tmp_dir

log -i "Ended Successfully: `basename $0`"
