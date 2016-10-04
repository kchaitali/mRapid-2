#!/bin/bash

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 4 4 $#

JOB_ID=$1
JOB_EX_ID=$2
IN_FILE=$3
OUT_FILE=$4

log -i "Parameters received: job_id= ${JOB_ID}, job_ex_id= ${JOB_EX_ID}, in_file= ${IN_FILE}, out_file= ${OUT_FILE}"
log -w "Expecting ${IN_FILE} in local"

addStageToOpsmeta ${JOB_EX_ID} "Staging" "Conversion"
converted_file_tmp="$APPL_BASE_PATH/tmp/sas_${JOB_ID}_${JOB_EX_ID}_`date +%s`"

updateOpsmeta $JOB_EX_ID "P" "Converting ${IN_FILE} to csv format" "Conversion"
log -i "Converting sas7bdat file: ${IN_FILE} to csv format"
python $APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/sas/sas7bdat_convert.py -i ${IN_FILE} > $converted_file_tmp
catchError $? "Unsuccessful execution of script: sas7bdat_convert.py"

log -i "Removing dump brackets"
sed -i 's/\]//g' $converted_file_tmp
sed -i 's/\[//g' $converted_file_tmp
sed -i "s/u'//g" $converted_file_tmp
sed -i "s/'//g" $converted_file_tmp
sed -i "s/ //g" $converted_file_tmp

updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Conversion"
addStageToOpsmeta ${JOB_EX_ID}  "Conversion" "Hdfs"
updateOpsmeta $JOB_EX_ID "P" "Loading file to HDFS" "Hdfs"

log -i "Loading file $converted_file_tmp to hdfs: $OUT_FILE"
hadoop fs -put $converted_file_tmp $OUT_FILE
catchError $? "Failed to load file to hdfs: $converted_file_tmp"

rm -f $converted_file_tmp

updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Hdfs"
log -i "Ended Successfully: `basename $0`"
