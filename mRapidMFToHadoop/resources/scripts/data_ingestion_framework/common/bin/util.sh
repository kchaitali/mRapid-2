#!/bin/bash

#####
# NAME		: util.sh
# PARAMS	: <NONE>
# PURPOSE	: To provide utility functions for common use.
# UPDATED ON    : 2016-03-29
# UPDATED BY    : Sumit 
####

JEDI=0

function log(){
if [[ $# -lt 2 ]]
then
	echo "Wrong call to log function!"
	echo "Usage: log <option> <message>"
else
	case $1 in
		-i) type="INFO"
		;;
		-w) type="WARN"
		;;
		-e) type="ERROR"
		;;
		*) type="UNDEFINED"
		;;
	esac
	echo "`date '+%y/%m/%d %H:%M:%S'` ${type} $2"
fi
}

function catchError(){
if [[ $# -lt 2 ]]
then
        echo "Wrong call to catchError function!"
        echo "Usage: catchError <exit_code> <message>"
else
	if [[ $1 -ne 0 ]]
	then
        	log -e "$2"
		mysql_update "UPDATE $(getProperty OPS_DB).job_execution_details SET job_end=NOW(), job_result='F', job_comments='Failed' WHERE job_execution_details_id=$JEDI"
	        exit 1
	fi
fi
}

function checkParams(){
if [[ $# -lt 3 ]]
then
	echo "Wrong call to checkParams function!"
	echo "Usage: checkParams <min_num> <max_num> <actual_number>"
else
	if [[ $3 -lt $1 || $3 -gt $2 ]]
	then
		log -e "Invalid number of parameters, Expected minimum=$1, maximum=$2, Actually received=$3"
		exit 1
	fi
fi
}

function getProperty(){
if [[ $# -lt 1 ]]
then
        echo "Wrong call to getProperty function!"
        echo "Usage: getProperty <property>"
else
	profile_file=$APPL_BASE_PATH/data_ingestion_framework/common/conf/framework.profile
	if [[ -s $profile_file ]]
	then
		prop_val=$(awk -F '=' -v prop_name=$1 '{if($1 == prop_name) print $2}' $profile_file)
		echo $prop_val
	else
		log -e "File not found : ${profile_file}"
		exit 1
	fi
fi
}

function updateOpsmeta(){
if [[ $# -lt 4 ]]
then
        echo "Wrong call to updateOpsmeta function!"
        echo "Usage: updateOpsmeta <job_execution_id> <job_result> <job_comments> <job_stage>"
else
	job_execution_id=$1
        job_result=`echo $2 | tr '[:lower:]' '[:upper:]'`
        job_comments=$3
	job_stage=$4
        if [[ $job_result == 'S' || $job_result == 'F' ]]
	then
		mysql_update "UPDATE $(getProperty OPS_DB).job_execution_details SET job_end=NOW(), job_result='$job_result', job_comments='$job_comments' WHERE job_execution_id=$job_execution_id and job_stage='$job_stage'"
	else
		mysql_update "UPDATE $(getProperty OPS_DB).job_execution_details SET job_result='$job_result', job_comments='$job_comments' WHERE job_execution_id=$job_execution_id and job_stage='$job_stage'"
	fi
fi
}

function addStageToOpsmeta(){
if [[ $# -lt 2 ]]
then
        echo "Wrong call to addStageToOpsmeta function!"
        echo "Usage: addStageToOpsmeta <job_execution_id> <job_stage_old> <job_stage_new>"
else
        job_execution_id=$1
        job_stage_old=$2
        job_stage_new=$3
	mysql_update "INSERT INTO $(getProperty OPS_DB).job_execution_details(job_execution_id, userid, job_start, job_comments, job_command, job_result, job_stage, source_data_file_name, source_data_file_location, target_file_name, target_file_location) SELECT job_execution_id, userid, NOW(), job_comments, job_command, job_result, '${job_stage_new}', source_data_file_name, source_data_file_location, target_file_name, target_file_location FROM $(getProperty OPS_DB).job_execution_details WHERE job_execution_id=${job_execution_id} and job_stage='${job_stage_old}'"
	JEDI=$(mysql_select "SELECT max(job_execution_details_id) FROM $(getProperty OPS_DB).job_execution_details")
	updateOpsmeta ${job_execution_id} "P" "Started $job_stage_new" "$job_stage_new"
fi

}

function mysql_select(){
if [[ $# -lt 1 || $# -gt 2 ]]
then
	echo "Wrong call to mysql_select function!"
        echo "Usage: mysql_select <select_query> [<output_file>]"
else
	if [[ $# -eq 2 ]]
	then
		mysql --host=$(getProperty MYSQL_HOSTNAME) --user=$(getProperty MYSQL_USERNAME) --password=$(getProperty MYSQL_PASSWORD) -s --execute="$1" > $2
		catchError $? "Failed to execute select query: $1"
		sed -i 's/\t/|/g' $2
	else
		res=$(mysql --host=$(getProperty MYSQL_HOSTNAME) --user=$(getProperty MYSQL_USERNAME) --password=$(getProperty MYSQL_PASSWORD) -s --execute="$1")
		echo $res
	fi
fi
}

function mysql_update(){
if [[ $# -lt 1 || $# -gt 1 ]]
then
	echo "Wrong call to mysql_select function!"
        echo "Usage: mysql_update <insert/update_query>"
else
	mysql --host=$(getProperty MYSQL_HOSTNAME) --user=$(getProperty MYSQL_USERNAME) --password=$(getProperty MYSQL_PASSWORD) -s --execute="$1"
	catchError $? "Failed to execute select query: $1"
fi
}

function handleIfCompressed(){
if [[ $# -lt 2 || $# -gt 2 ]]
then
        echo "Wrong call to handleIfCompressed function!"
        echo "Usage: handleIfCompressed <filename> <filepath>"
else
        filename=$1
	filepath=$2
	extension=`echo $filename | rev | cut -d '.' -f1 | rev`
	if [[ $extension == "gz" ]]
	then
		addStageToOpsmeta ${JOB_EX_ID} "Staging" "Unzip"
		updateOpsmeta $JOB_EX_ID "P" "Unziping file: $filename" "Unzip"
		new_filename="`echo $filename | rev | cut -d '.' -f2- | rev`_uncompressed"
		gunzip -c $filepath/$filename > $filepath/$new_filename
		echo $new_filename
		updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Unzip"
	else
		echo $filename
	fi
fi
}
