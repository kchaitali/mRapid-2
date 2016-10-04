#!/bin/sh

##########
# NAME          : mainframe_to_hive.sh
# PARAMS        : 1.<table_name>, 2.<delimiter>, 3.<table_type>, 4.<input_format>, 5.<output_format>, 6.<layout_file>, 7.<record_length>, 8.<table_location>
# PURPOSE       :
# UPDATED ON    : 2016-05-25
# UPDATED BY    : Sumit
##########

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"

#export LIBJARS=/usr/lib/hive/lib/hive-serde-1.1.0-cdh5.5.0.jar:/usr/lib/hive/lib/hive-common-1.1.0-cdh5.5.0.jar:/usr/lib/hive/lib/hive-shims-0.23-1.1.0-cdh5.5.0.jar
export LIBJARS="/usr/hdp/2.3.2.0-2950/hive/lib/hive-serde.jar:/usr/hdp/2.3.2.0-2950/hive/lib/hive-common.jar:/usr/hdp/2.3.2.0-2950/hive/lib/hive-shims.jar"

export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$LIBJARS

table_name=$1
delimiter=$2
table_type=$3
input_format=$4
output_format=$5
layout_file=$6
record_length=$7
table_location=$8
hive_table_partitioning=$(getProperty HIVE_TABLE_PARTITIONING)
hive_table_partition_by=$(getProperty HIVE_TABLE_PARTITION_BY)

log -i "Received parameters: table_name= ${table_name}, delimiter= ${delimiter}, table_type=${table_type}, input_format=${input_format},\
output_format= ${output_format}, layout_file= ${layout_file}, record_length= ${record_length}, table_location=${table_location}"

log -i "Creating ddl..."
if [[ $hive_table_partitioning == "Y" ]]
then
	result=`hadoop jar $APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/mf-1.jar com.mf.HiveTableCreator ${table_name} ${delimiter} ${table_type} ${input_format} ${output_format} ${layout_file} ${record_length} ${table_location} "Y" "${hive_table_partition_by} STRING"`
catchError $? "Failed to generate ddl"
else
	result=`hadoop jar $APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/mf-1.jar com.mf.HiveTableCreator ${table_name} ${delimiter} ${table_type} ${input_format} ${output_format} ${layout_file} ${record_length} ${table_location} "N"`
catchError $? "Failed to generate ddl"
fi

#echo $result
#echo "***************************"
#echo $table_location
hadoop fs -mkdir -p $table_location

log -i "Executing ddl..."
hive -S -e "${result}"
catchError $? "Failed to execute ddl"

log -i "Ended Successfully: `basename $0`"
