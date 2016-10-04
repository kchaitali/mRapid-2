#!/bin/bash

##########
# NAME          : mainframe_to_hdfs.sh
# PARAMS        : 1.<job_id>, 2.<job_ex_id>, 3.<in_file>, 4.<out_file>, 5.<layout_file>, 6.<file_format>, 7.[record_length]
# PURPOSE       :
# UPDATED ON    : 2016-05-25
# UPDATED BY    : Sumit
##########

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 5 7 $#

JOB_ID=$1
JOB_EX_ID=$2
IN_FILE=$3
OUT_FILE=$4
COPYBOOK_FILE=$5
FILE_FORMAT=`echo $6 | tr '[:lower:]' '[:upper:]'`
RECORD_LENGTH=$7

log -i "Parameters received: job_id= ${JOB_ID}, job_ex_id= ${JOB_EX_ID}, in_file= ${IN_FILE}, out_file= ${OUT_FILE}, layout_file= ${COPYBOOK_FILE}, file_format= ${FILE_FORMAT}, record_length= ${RECORD_LENGTH}"
#log -i "Parameters received: job_id= ${JOB_ID}, job_ex_id= ${JOB_EX_ID}, in_file= ${IN_FILE}, out_file= ${OUT_FILE}, layout_file= ${COPYBOOK_FILE}, file_format= ${FILE_FORMAT}"

ops_db=$(getProperty OPS_DB)
STAGING_LAYOUT_FILE="$(getProperty STAGING_AREA)/`basename ${COPYBOOK_FILE}`"
STAGING_DATA_FILE="$(getProperty STAGING_AREA)/`basename ${IN_FILE}`"
#log -i "Staging layout file: $STAGING_LAYOUT_FILE"

copybook_file_tmp="$APPL_BASE_PATH/tmp/copybook_${JOB_ID}_${JOB_EX_ID}_`date +%s_%N_$RANDOM`"
datafile_file_tmp="$APPL_BASE_PATH/tmp/datafile_${JOB_ID}_${JOB_EX_ID}_`date +%s_%N_$RANDOM`"

log -i "Removing comments from copybook"
cat $COPYBOOK_FILE | grep -v "*" > $copybook_file_tmp
#dos2unix -f $copybook_file_tmp

#if [[ "${FILE_FORMAT}" == "FIXED" ]]
#then
#	updateOpsmeta $JOB_EX_ID "P" "Copying data file to staging dir" "Staging"

#	log -i "Removing layout file if already exists in staging: ${STAGING_LAYOUT_FILE}"
#	hadoop fs -rm "${STAGING_LAYOUT_FILE}" "${STAGING_DATA_FILE}"
#	log -i "Copying files to staging"
#	hadoop fs -put $copybook_file_tmp $STAGING_LAYOUT_FILE
#	hadoop fs -put $IN_FILE $STAGING_DATA_FILE

#	updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Staging"
#	addStageToOpsmeta ${JOB_EX_ID} "Staging" "Conversion"

#if [[ $FILE_FORMAT == "FIXED" ]]
#then
#	$APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/mainframe/convert_to_ascii.sh $STAGING_DATA_FILE $STAGING_LAYOUT_FILE $RECORD_LENGTH $OUT_FILE $JOB_EX_ID
#	catchError $? "Failed to convert file: ${IN_FILE}"
#	updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Conversion"
#	addStageToOpsmeta ${JOB_EX_ID} "Conversion" "Hdfs"

#else
#	if [[ "${FILE_FORMAT}" == "VARIABLE" ]]
#	then
		updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Staging"
		addStageToOpsmeta ${JOB_EX_ID} "Staging" "Conversion"
		java -cp $APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/mRapidMFToHadoop.jar com.capgemini.mf2hadoop.Mf2HadoopHDFS ${copybook_file_tmp} ${IN_FILE} ${datafile_file_tmp}
		catchError $? "Failed to convert file: ${IN_FILE}"
		updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Conversion"
		addStageToOpsmeta ${JOB_EX_ID} "Conversion" "Hdfs"
		log -i "Copying converted file to HDFS: ${OUT_FILE}"

        	hadoop fs -put ${datafile_file_tmp} ${OUT_FILE}
        	catchError $? "Failed to copy file to HDFS"
#	fi
#fi
	
#updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Conversion"
#addStageToOpsmeta ${JOB_EX_ID} "Conversion" "Hdfs"
#	log -i "Copying converted file to HDFS: ${OUT_FILE}"
	
#	hadoop fs -put ${datafile_file_tmp} ${OUT_FILE}
#	catchError $? "Failed to copy file to HDFS"
updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Hdfs"
#else
#	log -e "File format not supported: $FILE_FORMAT"
#	exit 1
#fi

log -i "Removing temp files"
rm -rf $copybook_file_tmp $datafile_file_tmp

log -i "Ended Successfully: `basename $0`"
