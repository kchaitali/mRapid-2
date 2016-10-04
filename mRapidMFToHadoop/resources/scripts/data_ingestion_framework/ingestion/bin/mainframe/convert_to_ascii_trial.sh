#!/bin/bash

##########
# NAME          : convert_to_ascii.sh
# PARAMS        : 1.<data_file>, 2.<layout_file>, 3.<record_length>, 4.<target_file> 5.<job_execution_id>
# PURPOSE       :
# UPDATED ON    : 2016-05-24
# UPDATED BY    : Sumit
##########

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 5 5 $#

#export LIBJARS=/usr/lib/hive/lib/hive-serde-1.1.0-cdh5.5.0.jar,/usr/lib/hive/lib/hive-common-1.1.0-cdh5.5.0.jar,/usr/lib/hive/lib/hive-shims-0.23-1.1.0-cdh5.5.0.jar;
export LIBJARS=/usr/hdp/2.3.2.0-2950/hive/lib/hive-serde.jar,/usr/hdp/2.3.2.0-2950/hive/lib/hive-common.jar,/usr/hdp/2.3.2.0-2950/hive/lib/hive-shims.jar
export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:.$LIBJARS

data_file=$1
layout_file=$2
record_length=$3
hdfs_target_file=$4
JOB_EX_ID=$5

log -i "Received parameters: data_file= ${data_file}, layout_file= ${layout_file}, record_length= ${record_length}, hdfs_target_file= ${hdfs_target_file}, job_ex_id= $JOB_EX_ID"

tmp_dir="/tmp/dump_`date +%s_%N_$RANDOM`"

#updateOpsmeta $JOB_EX_ID "P" "Converting file : ${data_file}" "Conversion"

log -i "Converting file : ${data_file}"
yarn jar $APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/mf-1.jar com.mf.MainframeFBToAsciiMR \
-libjars ${LIBJARS} $data_file $tmp_dir \
-cobol.layout.url $layout_file \
-fb.length $record_length;
catchError $? "Failed to convert file: ${data_file}"

#updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Conversion"
#addStageToOpsmeta ${JOB_EX_ID} "Conversion" "Hdfs"

#log -i "Removing file if already exists: $hdfs_target_file"
#hadoop fs -rm $hdfs_target_file
log -i "Loading converted file to hdfs: $hdfs_target_file"
hadoop fs -cp $tmp_dir/part* $hdfs_target_file
catchError $? "Failed to copy file: $hdfs_target_file"

log -i "Removing temperory directory : $tmp_dir"
hadoop fs -rm -r $tmp_dir

#updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Hdfs"
log -i "Ended Successfully: `basename $0`"
