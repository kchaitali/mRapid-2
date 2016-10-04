#!/bin/bash

##########
# NAME          : delimited_to_hive.sh
# PARAMS        : 1.<job_id>, 2.<job_ex_id>, 3.<in_file>, 4.<hive_table>, 5.<layout_file>, 6.<header_rows>, 7.<footer_rows>, 8.<recon_col>
# PURPOSE       :
# UPDATED ON    : 2016-03-28
# UPDATED BY    : Sumit
##########

source $APPL_BASE_PATH/data_ingestion_framework/common/bin/util.sh
log -i "Started Executing: `basename $0`"
checkParams 7 8 $#

JOB_ID=$1
JOB_EX_ID=$2
IN_FILE=$3
HIVE_TABLE=$4
LAYOUT_FILE=$5
HEADER_ROWS=$6
FOOTER_ROWS=$7
RECON_COL=$8


log -i "Parameters received: job_id= ${JOB_ID}, job_ex_id= ${JOB_EX_ID}, in_file= ${IN_FILE}, hive_table= ${HIVE_TABLE}, layout_file= ${LAYOUT_FILE}, header_rows= ${HEADER_ROWS}, footer_rows= ${FOOTER_ROWS}, recon_col= ${RECON_COL}"

tmd_db=$(getProperty TMD_DB)
SEP=$(mysql_select "SELECT column_separator FROM ${tmd_db}.job_details WHERE job_id=${JOB_ID}")
hive_table_partitioning=$(getProperty HIVE_TABLE_PARTITIONING)
hive_table_partition_by=$(getProperty HIVE_TABLE_PARTITION_BY)
HIVE_TABLE_PATH="$(getProperty HIVE_WAREHOUSE_LOCATION)/`echo $HIVE_TABLE | cut -d '.' -f1`/`echo $HIVE_TABLE | cut -d '.' -f2`"
log -i "File delimiter from meta: $SEP"

updateOpsmeta $JOB_EX_ID "P" "Creating Schema for: ${HIVE_TABLE}" "Hive"
log -i "Creating ddl from: ${LAYOUT_FILE}"

hql_tmp_file="$APPL_BASE_PATH/tmp/delimited_${JOB_ID}_${JOB_EX_ID}_`date +%s`.hql"
num_fields=$(awk -F ',' '{print NF}' ${LAYOUT_FILE} | sort | uniq)
log -i "Number of field in file: $num_fields"

echo "CREATE EXTERNAL TABLE IF NOT EXISTS ${HIVE_TABLE} (" > $hql_tmp_file
for i in $(seq 1 $num_fields)
do
	column_def=$(cat $LAYOUT_FILE | cut -d ',' -f${i} | tr '\n' ' ')
	if [[ $i -lt $num_fields ]]
	then
		echo "${column_def}," >> $hql_tmp_file
	else
		echo "${column_def}" >> $hql_tmp_file
	fi
done
echo ")" >> $hql_tmp_file
if [[ "$hive_table_partitioning" == "Y" ]]
then
	echo "PARTITIONED BY ($hive_table_partition_by STRING)" >> $hql_tmp_file
fi
echo "ROW FORMAT DELIMITED FIELDS TERMINATED BY '${SEP}'" >> $hql_tmp_file
echo "LOCATION '$HIVE_TABLE_PATH'" >> $hql_tmp_file
echo "TBLPROPERTIES ('skip.header.line.count'='$HEADER_ROWS','skip.footer.line.count'='$FOOTER_ROWS');" >> $hql_tmp_file

log -i "Executing ddl: $hql_tmp_file"
hive -S -f $hql_tmp_file
catchError $? "Failed to execute ddl: $hql_tmp_file"

rm -f $hql_tmp_file

#edit
log -i "Getting existing row count for recon"
existing_line_count=$(hive -S -e "SELECT count(1) FROM ${HIVE_TABLE}" | head -1);
log -i "Got existing record count from table: $existing_line_count"

log -i "Getting record count from file to be loaded"
data_file_tmp="$APPL_BASE_PATH/tmp/delimited_${JOB_ID}_${JOB_EX_ID}_`date +%s`.data"
r_row=`echo $RECON_COL |cut -d ':' -f1`
r_col=`echo $RECON_COL |cut -d ':' -f2`
cp $IN_FILE $data_file_tmp
line_count_from_file=`head -${r_row} $data_file_tmp | tail -1 | awk -v field="$r_col" -F "${SEP}" '{print $field}'`
#rm -f $data_file_tmp
log -i "Records in new file as per recon col: $line_count_from_file"
#/edit

#edit
#HIVE_DATA_FILE="/tmp/hive_data_${JOB_ID}_${JOB_EX_ID}_`date +%s`"
#hadoop fs -cp $IN_FILE $HIVE_DATA_FILE
#/edit

log -i "Loading data to table: ${HIVE_TABLE}"
updateOpsmeta $JOB_EX_ID "P" "Loading data to table: ${HIVE_TABLE}" "Hive"

if [[ "$hive_table_partitioning" == "Y" ]]
then
	hive -S -e "LOAD DATA LOCAL INPATH '$data_file_tmp' INTO TABLE ${HIVE_TABLE} PARTITION(${hive_table_partition_by}='`date +%Y-%m-%d`')"
	catchError $? "Failed to load data to table: ${HIVE_TABLE}"
else
	hive -S -e "LOAD DATA LOCAL INPATH '$data_file_tmp' INTO TABLE ${HIVE_TABLE}"
	catchError $? "Failed to load data to table: ${HIVE_TABLE}"
fi

rm -f $data_file_tmp

#edit
updateOpsmeta $JOB_EX_ID "P" "Recon" "Hive"
log -i "Getting updated record count from table"
updated_line_count=$(hive -S -e "SELECT count(1) FROM ${HIVE_TABLE}" | head -1);
#log -w "Updated= $updated_line_count Exitsting= $existing_line_count"
log -i "Updated record count: $updated_line_count"
line_count_from_table=`expr $updated_line_count - $existing_line_count`
log -i "Number of records loaded to table: $line_count_from_table"
if [[ $line_count_from_file == $line_count_from_table ]]
then
	log -i "Recon Successful"
else
	log -e "Recon Failed, Lines as per recon column: $line_count_from_file, Lines loaded to hive table: $line_count_from_table"
	exit 1
fi
#/edit

updateOpsmeta $JOB_EX_ID "S" "Completed Successfully" "Hive"
log -i "Ended Successfully: `basename $0`"
