#!/bin/bash

##########
# NAME          : mainframe_to_hive.sh
# PARAMS        : 1.<job_id>, 2.<job_ex_id>, 3.<in_file>, 4.<hive_table>, 5.<layout_file>, 6.<file_format>, 7.[record_length]
# PURPOSE       :
# UPDATED ON    : 2016-03-28
# UPDATED BY    : Sumit
##########

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 6 7 $#

JOB_ID=$1
JOB_EX_ID=$2
IN_FILE=$3
HIVE_TABLE=$4
COPYBOOK_FILE=$5
FILE_FORMAT=`echo $6 | tr '[:lower:]' '[:upper:]'`
RECORD_LENGTH=$7

log -i "Parameters received: job_id= ${JOB_ID}, job_ex_id= ${JOB_EX_ID}, in_file= ${IN_FILE}, hive_table= ${HIVE_TABLE}, layout_file= ${COPYBOOK_FILE}, file_format= ${FILE_FORMAT}, record_length= ${RECORD_LENGTH}"
#log -i "Parameters received: job_id= ${JOB_ID}, job_ex_id= ${JOB_EX_ID}, in_file= ${IN_FILE}, hive_table= ${HIVE_TABLE}, layout_file= ${COPYBOOK_FILE}, file_format= ${FILE_FORMAT}"

ops_db=$(getProperty OPS_DB)
STAGING_LAYOUT_FILE="$(getProperty STAGING_AREA)/`basename ${COPYBOOK_FILE}`"
STAGING_DATA_FILE="$(getProperty STAGING_AREA)/`basename ${IN_FILE}`"

HIVE_TABLE_PATH="$(getProperty HIVE_WAREHOUSE_LOCATION)/`echo $HIVE_TABLE | cut -d '.' -f1`/`echo $HIVE_TABLE | cut -d '.' -f2`"

copybook_file_tmp="$APPL_BASE_PATH/tmp/copybook_${JOB_ID}_${JOB_EX_ID}_`date +%s_%N_$RANDOM`"
datafile_file_tmp="$APPL_BASE_PATH/tmp/datafile_${JOB_ID}_${JOB_EX_ID}_`date +%s_%N_$RANDOM`"

log -i "Removing comments from copybook"
cat $COPYBOOK_FILE | grep -v "*" > $copybook_file_tmp
#dos2unix -f $copybook_file_tmp

updateOpsmeta $JOB_EX_ID "P" "Creating schema for table: $HIVE_TABLE" "Hive"
log -i "Creating schema for table: $HIVE_TABLE"
#if [[ "${FILE_FORMAT}" == "FIXED" ]]
#then
#	updateOpsmeta $JOB_EX_ID "P" "Copying data file to staging dir" "Staging"

#        log -i "Removing layout file if already exists in staging: ${STAGING_LAYOUT_FILE}"
#        hadoop fs -rm "${STAGING_LAYOUT_FILE}" "${STAGING_DATA_FILE}"
#        log -i "Copying files to staging"
#        hadoop fs -put $copybook_file_tmp $STAGING_LAYOUT_FILE
#        hadoop fs -put $IN_FILE $STAGING_DATA_FILE

#        updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Staging"
#        addStageToOpsmeta ${JOB_EX_ID} "Staging" "Conversion"
	
#	datafile_file_tmp="/tmp/datafile_${JOB_ID}_${JOB_EX_ID}_`date +%s_%N_$RANDOM`"
	
#	$APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/mainframe/convert_to_ascii.sh $STAGING_DATA_FILE $STAGING_LAYOUT_FILE $RECORD_LENGTH $datafile_file_tmp $JOB_EX_ID
#       catchError $? "Failed to convert file: ${IN_FILE}"

#	$APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/mainframe/create_hive_table.sh $HIVE_TABLE "\\001" "EXTERNAL" NULL NULL "${STAGING_LAYOUT_FILE}" $RECORD_LENGTH $HIVE_TABLE_PATH
#	catchError $? "Unsuccessful execution of script: create_hive_table.sh"
	
#	updateOpsmeta $JOB_EX_ID "P" "Loading data to hive table: $HIVE_TABLE" "Hive"
#	log -i "Loading data to hive table : ${HIVE_TABLE}"
#	hive -S -e "LOAD DATA INPATH '$datafile_file_tmp' INTO TABLE ${HIVE_TABLE}"
#        catchError $? "Failed to load data file."

#else 
#	if [[ "${FILE_FORMAT}" == "VARIABLE" ]]
#	then
		datafile_file_tmp="$APPL_BASE_PATH/tmp/datafile_${JOB_ID}_${JOB_EX_ID}_`date +%s_%N_$RANDOM`"
	# hive -e "$(java -cp $APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/mRapidMFToHadoop.jar com.capgemini.mf2hadoop.Mf2HadoopHIVE ${copybook_file_tmp} ${HIVE_TABLE} ${HIVE_TABLE} DELIMITED TEXTFILE ${IN_FILE} ${datafile_file_tmp} ${HIVE_TABLE_PATH})"
	 hive -e "$(java -cp $APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/mRapidMFToHadoop.jar com.capgemini.mf2hadoop.Mf2HadoopHIVE ${copybook_file_tmp} ${HIVE_TABLE} ${HIVE_TABLE} DELIMITED TEXTFILE ${HIVE_TABLE_PATH} N)"
		catchError $? "Failed to create hive table: ${HIVE_TABLE}" 
   java -cp $APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/mRapidMFToHadoop.jar com.capgemini.mf2hadoop.Mf2HadoopHDFS ${copybook_file_tmp} ${IN_FILE} ${datafile_file_tmp}
		updateOpsmeta $JOB_EX_ID "P" "Loading data to hive table: $HIVE_TABLE" "Hive"
		log -i "Loading data to hive table : ${HIVE_TABLE}"
		hive -S -e "LOAD DATA LOCAL INPATH '$datafile_file_tmp' INTO TABLE ${HIVE_TABLE}"
        	catchError $? "Failed to load data file."
		
#		rm -rf $datafile_file_tmp
#	fi
#fi

#updateOpsmeta $JOB_EX_ID "P" "Loading data to hive table: $HIVE_TABLE" "Hive"
#log -i "Loading data to hive table : ${HIVE_TABLE}"
#edit
#HIVE_DATA_FILE="/tmp/hive_data_${JOB_ID}_${JOB_EX_ID}_`date +%s`"
#hadoop fs -cp $IN_FILE $HIVE_DATA_FILE
#/edit
#hive_table_partitioning=$(getProperty HIVE_TABLE_PARTITIONING)
#if [[ $hive_table_partitioning == "Y" ]]
#then
#	hive_table_partition_by=$(getProperty HIVE_TABLE_PARTITION_BY)
#	hive -S -e "LOAD DATA LOCAL INPATH '$datafile_file_tmp' INTO TABLE ${HIVE_TABLE}"
#	catchError $? "Failed to load data file."
#else
#	hive -S -e "LOAD DATA INPATH '$HIVE_DATA_FILE' INTO TABLE ${HIVE_TABLE}"
#	catchError $? "Failed to load data file."
#fi

rm -rf $copybook_file_tmp

updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Hive"
log -i "Ended Successfully: `basename $0`"
