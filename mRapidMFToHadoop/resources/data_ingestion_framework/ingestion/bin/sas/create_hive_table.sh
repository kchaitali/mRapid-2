#!/bin/bash

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 5 5 $#

JOB_ID=$1
JOB_EX_ID=$2
header_file=$3
hive_table_name=$4
hive_table_path=$5

log -i "Parameters received: job_id= ${JOB_ID}, job_ex_id= ${JOB_EX_ID}, header_file= ${header_file}, hive_table_name= ${hive_table_name}, hive_table_path= ${hive_table_path}"

hive_table_partitioning=$(getProperty HIVE_TABLE_PARTITIONING)
hive_table_partition_by=$(getProperty HIVE_TABLE_PARTITION_BY)

log -i "Cleaning header data"
sed -i 's/,/\n/g' ${header_file}
sed -i 's/ //g' ${header_file}
#sed -i 's/^u//g' ${header_file}
#sed -i "s/'//g" ${header_file}

#cat ${header_file}
hql_file_tmp="$APPL_BASE_PATH/tmp/sas_${JOB_ID}_${JOB_EX_ID}_`date +%s`.hql"

num_fields=$(cat $header_file | wc -l)

log -i "Writing hql: $hql_file_tmp"
echo "CREATE EXTERNAL TABLE IF NOT EXISTS $hive_table_name (" > $hql_file_tmp
while read line
do
	num_fields=`expr $num_fields - 1`
	if [[ $num_fields == 0 ]]
	then
		echo "${line} STRING" >> $hql_file_tmp
	else
		echo "${line} STRING," >> $hql_file_tmp
	fi
done < ${header_file}
echo ")" >> $hql_file_tmp
if [[ "$hive_table_partitioning" == "Y" ]]
then
        echo "PARTITIONED BY ($hive_table_partition_by STRING)" >> $hql_file_tmp
fi
echo "ROW FORMAT DELIMITED FIELDS TERMINATED BY ','" >> $hql_file_tmp
echo "LOCATION '$hive_table_path'" >> $hql_file_tmp
echo "TBLPROPERTIES ('skip.header.line.count'='1');" >> $hql_file_tmp

log -i "Executing: $hql_file_tmp"
hive -S -f $hql_file_tmp
catchError $? "Failed to execute hql: $hql_file_tmp"

rm -f $hql_file_tmp
log -i "Ended Successfully: `basename $0`"
