#!/bin/bash

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh

job_code=$1

mysql_username=$(getProperty MYSQL_USERNAME)
mysql_password=$(getProperty MYSQL_PASSWORD)
mysql_hostname=$(getProperty MYSQL_HOSTNAME)
ops_db=$(getProperty OPS_DB)
tmd_db=$(getProperty TMD_DB)

row_data=$(mysql --host=$mysql_hostname --user=$mysql_username --password=$mysql_password -s --execute="SELECT job_id, file_type, target_load_type, hive_table_name FROM ${tmd_db}.job_details WHERE job_id=(SELECT job_id FROM ${tmd_db}.job_master WHERE job_code='${job_code}')")
catchError $? "Failed"

load_type=`echo $row_data | cut -d ' ' -f3 | tr '[:upper:]' '[:lower:]'`
hive_table=`echo $row_data | cut -d ' ' -f4`
job_id=`echo $row_data | cut -d ' ' -f1`
file_type=`echo $row_data | cut -d ' ' -f2 | tr '[:upper:]' '[:lower:]'`

exe_details=$(mysql --host=$mysql_hostname --user=$mysql_username --password=$mysql_password -s --execute="SELECT target_file_name, target_file_location, job_result FROM ${ops_db}.job_execution_details WHERE job_execution_id=(SELECT max(job_execution_id) FROM ${ops_db}.job_execution_master WHERE job_id=${job_id})")
catchError $? "Failed"

file_name=`echo $exe_details | cut -d ' ' -f1`
file_loc=`echo $exe_details | cut -d ' ' -f2`
job_result=`echo $exe_details | cut -d ' ' -f3 | tr '[:upper:]' '[:lower:]'`

if [[ $job_result == 'p' ]]
then
	log -w "Can't fetch result, job is in execution state"
	exit 0
fi

if [[ $job_result == 'f' ]]
then
        log -e "Can't fetch result, job is in failed state"
        exit 1
fi

if [[ $load_type == "hdfs" || $load_type == "hive" ]]
then
	#log -i "Listing file $file_name"
	#echo ""
	#hadoop fs -ls $file_loc/$file_name
	#catchError $? "Failed"
	#if [[ $file_type == "sas" ]]
	#then
	#	exit 0
	#fi
	echo ""
	if [[ $load_type == "hdfs" ]]
	then
		log -i "Listing file $file_name"
		hadoop fs -ls $file_loc/$file_name
		echo ""
		log -i "Reading first 5 lines from file $file_name"
		echo ""
		hadoop fs -cat $file_loc/$file_name | head -5
		catchError $? "Failed"
		echo ""
	fi
	if [[ $load_type == "hive" ]]
	then
		log -i "Querying 5 records from table $hive_table"
		echo ""
		hive -S -e "SELECT * FROM ${hive_table} limit 5"
		catchError $? "Failed"
		echo ""
	fi
else
	log -e "Unsupported load type"
	exit 1
fi
