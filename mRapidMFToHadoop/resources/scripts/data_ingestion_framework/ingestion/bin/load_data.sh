#!/bin/bash

##########
# NAME		: load_data.sh
# PARAMS	: 1.<job_code>
# PURPOSE	: Entry point for ingestion framework.
# UPDATED ON	: 2016-05-20
# UPDATED BY	: Sumit
##########

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 1 1 $#

JOB_CODE=$1
log -i "Received parameter job_code= ${JOB_CODE}"

tmd_db=$(getProperty TMD_DB)
ops_db=$(getProperty OPS_DB)
log -i "Meta from framework.profile: tmd_db= $tmd_db, ops_db= $ops_db"

JOB_ID=$(mysql_select "SELECT job_id FROM ${tmd_db}.job_master WHERE job_code = '${JOB_CODE}'")
log -i "Got job_id from ${tmd_db}.job_master= ${JOB_ID}"

mysql_update "INSERT INTO ${ops_db}.job_execution_master(job_id) VALUES (${JOB_ID})"
JOB_EX_ID=$(mysql_select "SELECT max(job_execution_id) FROM ${ops_db}.job_execution_master WHERE job_id = ${JOB_ID}")
log -i "Got job_execution_id from ${ops_db}.job_execution_master= ${JOB_EX_ID}"
mysql_update "INSERT INTO ${ops_db}.job_execution_details(job_execution_id, userid, job_start, job_comments, job_command, job_result, job_stage) VALUES (${JOB_EX_ID}, '${USER}', NOW(), 'Started Execution', 'sh `basename $0` $1', 'P', 'Staging')"

jobdata_file_tmp="$APPL_BASE_PATH/tmp/jobdata_${JOB_ID}_${JOB_EX_ID}_`date +%s`"

mysql_select "SELECT file_type, target_load_type, source_data_file_name, source_data_file_location, hdfs_file_name, hdfs_file_location, source_layout_file_name, source_layout_file_location, source_file_format, record_length, hive_table_name, num_of_lines_in_header, num_of_lines_in_trailer, recon_col_pos, source_data_format from ${tmd_db}.job_details where job_id = ${JOB_ID}" $jobdata_file_tmp

if [[ -s $jobdata_file_tmp ]]
then
	FILE_TYPE=`cat $jobdata_file_tmp | cut -d '|' -f1 | tr '[:lower:]' '[:upper:]'`
	TARGET_LOAD_TYPE=`cat $jobdata_file_tmp | cut -d '|' -f2 | tr '[:lower:]' '[:upper:]'`
	SOURCE_FILE=`cat $jobdata_file_tmp | cut -d '|' -f3`
	CONN_URL="`cat $jobdata_file_tmp | cut -d '|' -f4`" #edit for rdbms job.
	SOURCE_FILE_PATH="$(getProperty BASE_DATA_PATH)/`cat $jobdata_file_tmp | cut -d '|' -f4`"
	AS_IS_PATH=`cat $jobdata_file_tmp | cut -d '|' -f4` #edit for as-is nifiS_IS_PATH
	SOURCE_FILE_PATH=$(echo ${SOURCE_FILE_PATH%/} | tr -s /)
	HDFS_FILE="`cat $jobdata_file_tmp | cut -d '|' -f5`.`date +%Y%m%d`"
	HDFS_FILE_PATH="$(getProperty HDFS_BASE_PATH)/`cat $jobdata_file_tmp | cut -d '|' -f6`"
	HDFS_FILE_PATH=$(echo ${HDFS_FILE_PATH%/} | tr -s /)
	LAYOUT_FILE=`cat $jobdata_file_tmp | cut -d '|' -f7`
	LAYOUT_FILE_PATH="$(getProperty BASE_DATA_PATH)/`cat $jobdata_file_tmp | cut -d '|' -f8`"
	LAYOUT_FILE_PATH=$(echo ${LAYOUT_FILE_PATH%/} | tr -s /)
	FILE_FORMAT=`cat $jobdata_file_tmp | cut -d '|' -f9 | tr '[:lower:]' '[:upper:]'`
	RECORD_LENGTH=`cat $jobdata_file_tmp | cut -d '|' -f10`
	HIVE_TABLE=`cat $jobdata_file_tmp | cut -d '|' -f11`
	HEADER_ROWS=`cat $jobdata_file_tmp | cut -d '|' -f12`
	FOOTER_ROWS=`cat $jobdata_file_tmp | cut -d '|' -f13`
	RECON_COL=`cat $jobdata_file_tmp | cut -d '|' -f14`
	USER_NAME=`cat $jobdata_file_tmp | cut -d '|' -f15`
	PASSWORD=`cat $jobdata_file_tmp | cut -d '|' -f9`
	STAGING_AREA=$(getProperty STAGING_AREA)
        NIFI_HOST=http://10.8.32.75:9891/nifi-api
        CLIENTID=SUMIT
        COMMAND=START
        JOB_TEMPLATE_ID=2




	rm -rf $jobdata_file_tmp
#	SOURCE_FILE=$(handleIfCompressed $SOURCE_FILE $SOURCE_FILE_PATH)

	mysql_update "UPDATE ${ops_db}.job_execution_details SET source_data_file_name='${SOURCE_FILE}', source_data_file_location='${SOURCE_FILE_PATH}',target_file_name='${HDFS_FILE}', target_file_location='${HDFS_FILE_PATH}' WHERE job_execution_id=${JOB_EX_ID} and job_stage='Staging'"

#	SOURCE_FILE=$(handleIfCompressed $SOURCE_FILE $SOURCE_FILE_PATH)
	
	if [[ "$FILE_TYPE" == "RDBMS" ]]
	then
		if [[ "$TARGET_LOAD_TYPE" == "HDFS" ]]
		then
			mysql_update "UPDATE ${ops_db}.job_execution_details SET source_data_file_name='${SOURCE_FILE}', source_data_file_location='${CONN_URL}',target_file_name='${HDFS_FILE}', target_file_location='${HDFS_FILE_PATH}' WHERE job_execution_id=${JOB_EX_ID} and job_stage='Staging'"
		fi
		if [[ "$TARGET_LOAD_TYPE" == "HIVE" ]]
                then
                        mysql_update "UPDATE ${ops_db}.job_execution_details SET source_data_file_name='${SOURCE_FILE}', source_data_file_location='${CONN_URL}',target_file_name='`echo ${HIVE_TABLE} | cut -d '.' -f2`', target_file_location='`echo ${HIVE_TABLE} | cut -d '.' -f1`' WHERE job_execution_id=${JOB_EX_ID} and job_stage='Staging'"
                fi
		updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Staging"
	else	
		updateOpsmeta $JOB_EX_ID "P" "Copying data file to staging dir" "Staging"
		log -i "Removing files if exists already"
		hadoop fs -rm "${STAGING_AREA}/${SOURCE_FILE}" "${HDFS_FILE_PATH}/${HDFS_FILE}"

		log -i "Copying source file to staging area: ${STAGING_AREA}/${SOURCE_FILE}"
		hadoop fs -put "${SOURCE_FILE_PATH}/${SOURCE_FILE}" "${STAGING_AREA}"
	
		log -i "Creating HDFS directory: ${HDFS_FILE_PATH}"
		hadoop fs -mkdir -p "${HDFS_FILE_PATH}"
	fi

	case "$FILE_TYPE" in
		"MAINFRAME") log -i "File type= Mainframe"
			if [[ $TARGET_LOAD_TYPE == "HDFS" ]]
			then
				log -i "Target type= Hdfs"
				$APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/mainframe/mainframe_to_hdfs.sh "${JOB_ID}" "${JOB_EX_ID}" "${SOURCE_FILE_PATH}/${SOURCE_FILE}" "${HDFS_FILE_PATH}/${HDFS_FILE}" "${LAYOUT_FILE_PATH}/${LAYOUT_FILE}" "${FILE_FORMAT}" "${RECORD_LENGTH}"
				catchError $? "Unsuccessful execution of script: mainframe_to_hdfs.sh"
			fi
			if [[ $TARGET_LOAD_TYPE == "HIVE" ]]
			then
				updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Staging"
				addStageToOpsmeta ${JOB_EX_ID} "Staging" "Hive"
				log -i "Target type= Hive"
				$APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/mainframe/mainframe_to_hive.sh "${JOB_ID}" "${JOB_EX_ID}" "${SOURCE_FILE_PATH}/${SOURCE_FILE}" "$HIVE_TABLE" "${LAYOUT_FILE_PATH}/${LAYOUT_FILE}" "${FILE_FORMAT}" "${RECORD_LENGTH}"
				catchError $? "Unsuccessful execution of script: mainframe_to_hive.sh"
			fi
		;;
		"DELIMITED") 	log -i "File type= Delimited"
			SOURCE_FILE=$(handleIfCompressed $SOURCE_FILE $SOURCE_FILE_PATH)
			if [[ $TARGET_LOAD_TYPE == "HDFS" ]]
			then
				$APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/delimited/delimited_to_hdfs.sh "${JOB_ID}" "${JOB_EX_ID}" "${SOURCE_FILE_PATH}/${SOURCE_FILE}" "${HDFS_FILE_PATH}/${HDFS_FILE}"
				catchError $? "Unsuccessful execution of script: delimited_to_hdfs.sh"
			fi
			if [[ $TARGET_LOAD_TYPE == "HIVE" ]]
                        then
				updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Staging"
                                addStageToOpsmeta ${JOB_EX_ID} "Staging" "Hive"
                                log -i "Target type= Hive"
                                $APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/delimited/delimited_to_hive.sh "${JOB_ID}" "${JOB_EX_ID}" "${SOURCE_FILE_PATH}/${SOURCE_FILE}" "$HIVE_TABLE" "${LAYOUT_FILE_PATH}/${LAYOUT_FILE}" "${HEADER_ROWS}" "${FOOTER_ROWS}" "${RECON_COL}"
                                catchError $? "Unsuccessful execution of script: delimited_to_hive.sh"
                        fi
		;;
		"SAS")	log -i "File type= SAS"
			if [[ $TARGET_LOAD_TYPE == "HDFS" ]]
			then
				updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Staging"
				$APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/sas/sas_to_hdfs.sh "${JOB_ID}" "${JOB_EX_ID}" "${SOURCE_FILE_PATH}/${SOURCE_FILE}" "${HDFS_FILE_PATH}/${HDFS_FILE}"
				catchError $? "Unsuccessful execution of script: sas_to_hdfs.sh"
			fi
			if [[ $TARGET_LOAD_TYPE == "HIVE" ]]
                        then
				updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Staging"
                                addStageToOpsmeta ${JOB_EX_ID} "Staging" "Conversion"
                                log -i "Target type= Hive"
                                $APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/sas/sas_to_hive.sh "${JOB_ID}" "${JOB_EX_ID}" "${SOURCE_FILE_PATH}/${SOURCE_FILE}" "$HIVE_TABLE"
                                catchError $? "Unsuccessful execution of script: sas_to_hive.sh"
                        fi
		;;
		"AS-IS") log -i "File type= Passthrough"
			updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Staging"
			addStageToOpsmeta ${JOB_EX_ID} "Staging" "Hdfs"
			log -i "Loading file to HDFS : ${AS_IS_PATH}/${SOURCE_FILE}"
                       # log -i "Loading file to HDFS : ${HDFS_FILE_PATH}/${HDFS_FILE}"
			updateOpsmeta $JOB_EX_ID "P" "Loading file to HDFS" "Hdfs"
			cp ${AS_IS_PATH}/${SOURCE_FILE} ${AS_IS_PATH}/tmp/
                  #       hadoop fs -cp "${STAGING_AREA}/${SOURCE_FILE}" "${HDFS_FILE_PATH}/${HDFS_FILE}"
                        java -jar $APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/mRapidNiFi.jar "${JOB_ID}" "${NIFI_HOST}" "${CLIENTID}" "${JOB_TEMPLATE_ID}"
			catchError $? "Failed to load file: ${SOURCE_FILE_PATH}/${SOURCE_FILE}"
			updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Hdfs"
		;;

		"RDBMS") log -i "Job type = RDBMS"
			if [[ $TARGET_LOAD_TYPE == "HDFS" ]]
			then
				addStageToOpsmeta ${JOB_EX_ID} "Staging" "Hdfs"
				log -i "Removing file if exists already"
				hadoop fs -rm "${HDFS_FILE_PATH}/${HDFS_FILE}"
				log -i "Creating HDFS directory: ${HDFS_FILE_PATH}"
                		hadoop fs -mkdir -p "${HDFS_FILE_PATH}"
				$APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/rdbms/rdbms_to_hdfs.sh "${JOB_ID}" "${JOB_EX_ID}" "${SOURCE_FILE}" "${USER_NAME}" "${PASSWORD}" "${CONN_URL}" "${HDFS_FILE_PATH}/${HDFS_FILE}"
				catchError $? "Unsuccessful execution of script: rdbms_to_hdfs.sh"
				updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Hdfs"
			fi
			if [[ $TARGET_LOAD_TYPE == "HIVE" ]]
			then
				addStageToOpsmeta ${JOB_EX_ID} "Staging" "Hive"
				$APPL_BASE_PATH/data_ingestion_framework/ingestion/bin/rdbms/rdbms_to_hive.sh "${JOB_ID}" "${JOB_EX_ID}" "${SOURCE_FILE}" "${USER_NAME}" "${PASSWORD}" "${CONN_URL}" "${HIVE_TABLE}"
				catchError $? "Unsuccessful execution of script: rdbms_to_hive.sh"
				updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Hive"
			fi
		;;
		*) 	log -e "Unsupported file type $FILE_TYPE"
			exit 1
		;;
	esac
else
	log -w "Job meta not found for job_code= ${JOB_CODE}"
fi
if [[ $SOURCE_FILE == *_uncompressed ]]
then
	rm -f $SOURCE_FILE_PATH/$SOURCE_FILE
fi
log -i "Ended Successfully: `basename $0`"
