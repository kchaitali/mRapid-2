#!/bin/bash

##########
# NAME          : sas_to_hive.sh
# PARAMS        : 1.<job_id>, 2.<job_ex_id>, 3.<in_file>, 4.<hive_table>
# PURPOSE       :
# UPDATED ON    : 2016-03-28
# UPDATED BY    : Sumit
##########


source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 4 4 $#

JOB_ID=$1
JOB_EX_ID=$2
IN_FILE=$3
HIVE_TABLE=$4

log -i "Parameters received: job_id= ${JOB_ID}, job_ex_id= ${JOB_EX_ID}, in_file= ${IN_FILE}, hive_table= ${HIVE_TABLE}"

HIVE_TABLE_PATH="$(getProperty HIVE_WAREHOUSE_LOCATION)/`echo $HIVE_TABLE | cut -d '.' -f1`/`echo $HIVE_TABLE | cut -d '.' -f2`"
hive_table_partitioning=$(getProperty HIVE_TABLE_PARTITIONING)
hive_table_partition_by=$(getProperty HIVE_TABLE_PARTITION_BY)
header_tmp_file="$APPL_BASE_PATH/tmp/sas_${JOB_ID}_${JOB_EX_ID}_`date +%s`.header"

#addStageToOpsmeta ${JOB_EX_ID} "Staging" "Conversion"
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
addStageToOpsmeta ${JOB_EX_ID} "Conversion" "Hive"
log -i "Extracting header from file: ${IN_FILE}"
cat ${converted_file_tmp} | head -1 > $header_tmp_file

updateOpsmeta $JOB_EX_ID "P" "Creating hive table: ${HIVE_TABLE}" "Hive"

log -i "Creating hive table: ${HIVE_TABLE}"
$APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/sas/create_hive_table.sh $JOB_ID $JOB_EX_ID $header_tmp_file $HIVE_TABLE $HIVE_TABLE_PATH
catchError $? "Unsuccessful execution of script: create_hive_table.sh"

rm -f $header_tmp_file

#edit
#HIVE_DATA_FILE="/tmp/hive_data_${JOB_ID}_${JOB_EX_ID}_`date +%s`"
#hadoop fs -cp $IN_FILE $HIVE_DATA_FILE
#/edit

updateOpsmeta $JOB_EX_ID "P" "Loading data to table: ${HIVE_TABLE}" "Hive"
log -i "Loading data to table: ${HIVE_TABLE}"

if [[ "$hive_table_partitioning" == "Y" ]]
then
        hive -S -e "LOAD DATA LOCAL INPATH '$converted_file_tmp' INTO TABLE ${HIVE_TABLE} PARTITION(${hive_table_partition_by}='`date +%Y-%m-%d`')"
        catchError $? "Failed to load data to table: ${HIVE_TABLE}"
else
        hive -S -e "LOAD DATA LOCAL INPATH '$converted_file_tmp' INTO TABLE ${HIVE_TABLE}"
        catchError $? "Failed to load data to table: ${HIVE_TABLE}"
fi

updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Hive"

log -i "Ended Successfully: `basename $0`"
