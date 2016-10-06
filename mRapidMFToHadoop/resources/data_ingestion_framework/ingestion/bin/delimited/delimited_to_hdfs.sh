#!/bin/bash

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 4 4 $#

JOB_ID=$1
JOB_EX_ID=$2
IN_FILE=$3
OUT_FILE=$4

updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Staging"
addStageToOpsmeta ${JOB_EX_ID} "Staging" "Hdfs"

log -i "Copying file $IN_FILE to HDFS: $OUT_FILE"

updateOpsmeta $JOB_EX_ID "P" "Copying to HDFS" "Hdfs"
hadoop fs -put $IN_FILE $OUT_FILE
catchError $? "Failed to copy file $IN_FILE to HDFS: $OUT_FILE"

updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Hdfs"

log -i "Ended Successfully: `basename $0`"
