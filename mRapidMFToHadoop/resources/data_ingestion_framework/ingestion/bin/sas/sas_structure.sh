#!/bin/bash

#####
# NAME          : sas_structure.sh
# PARAMS        : 1.Job id, 2.Job execution id, 3.Input data file, 4.Hive table name, 5.Hive table location
# PURPOSE       : Convert sas data file.
# CREATED ON    : 2016-08-09
# UPDATED ON    : 2016-08-19
# UPDATED BY    : Sumit
#####

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 5 5 $#

JOB_ID=$1
JOB_EX_ID=$2
data_infile=$3
hive_table_name=$4
hive_table_path=$5

log -i "Parameters received: data_infile= ${data_infile}, hive_table_name= ${hive_table_name}, hive_table_path= ${hive_table_path}"

hive_table_partitioning=$(getProperty HIVE_TABLE_PARTITIONING)
hive_table_partition_by=$(getProperty HIVE_TABLE_PARTITION_BY)

tmp_header_file="$APPL_BASE_PATH/tmp/sas_header_${JOB_ID}_${JOB_EX_ID}_`date +%s`.dat"
log -i "Extracting headers from data file"
python $APPL_BASE_PATH/data_ingestion_framework/ingestion/lib/sas/sas7bdat_header.py -i ${data_infile} | sed -n '/^---/ { s///; :a; n; p; ba; }' | sed -e 's/^ *//g;s/ \+/ /g' | cut -d ' ' -f2,3,4 > ${tmp_header_file}

sed -i '/^\s*$/d' ${tmp_header_file}

hql_file_tmp="$APPL_BASE_PATH/tmp/sas_${JOB_ID}_${JOB_EX_ID}_`date +%s`.hql"

num_fields=$(cat $tmp_header_file | wc -l)

log -i "Writing hql: $hql_file_tmp"
echo "CREATE EXTERNAL TABLE IF NOT EXISTS $hive_table_name (" > $hql_file_tmp
while read column type length
do
	num_fields=`expr $num_fields - 1`
	
	case $type in
		'string') datatype="STRING"
			;;
		'number') datatype="DECIMAL(20,2)"
			;;
		*) log -e "NotImplementedException: Unrecognized data type: $type"
			;;
	esac

	if [[ $num_fields == 0 ]]
	then
		echo "${column} ${datatype}" >> $hql_file_tmp
	else
		echo "${column} ${datatype}," >> $hql_file_tmp
	fi
done < ${tmp_header_file}
echo ")" >> $hql_file_tmp

if [[ "$hive_table_partitioning" == "Y" ]]
then
        echo "PARTITIONED BY ($hive_table_partition_by STRING)" >> $hql_file_tmp
fi
echo "ROW FORMAT DELIMITED FIELDS TERMINATED BY ','" >> $hql_file_tmp
echo "LOCATION '$hive_table_path'" >> $hql_file_tmp

echo $hql_file_tmp

log -i "Executing: $hql_file_tmp"
hive -S -f $hql_file_tmp
catchError $? "Failed to execute hql: $hql_file_tmp"

rm -f $hql_file_tmp
log -i "Ended Successfully: `basename $0`"
