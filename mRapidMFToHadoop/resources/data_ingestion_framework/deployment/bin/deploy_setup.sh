#!/bin/bash
if [ $# -ne 1 ]
then
echo "Usage : $0 <server_name:aws or gateway or sandbox>"
exit 1
fi

env=$1
server=aws
sql_file=mrapid_mysql.sql

if [ $server == "aws" ]
then
	mysql_user=cgfspoc1
	mysql_password=cgfspoc1
	APPL_BASE_PATH=/opt/cgfspoc1/demo_20161013/$env
elif [ $server == "gateway" ]
then
	mysql_user=root
	mysql_password=root
elif [ $server == "sandbox" ]
then
        mysql_user=root
        mysql_password=root
else
	echo "ERROR Unexpected server name"
	exit 2
fi

#Creating and loading ops and temp mysql DB
mysql -u $mysql_user -p$mysql_password < $sql_file
if [ $? -ne 0 ]
then
	echo "ERROR Failed to create ops tables in mysql"
	exit 1;
else
	echo "INFO Successfully created ops tables in mysql"
fi

#Set APPL_BASE_PATH 
export APPL_BASE_PATH=$APPL_BASE_PATH

#Setup git code to application path
cp -R $APPL_BASE_PATH/../git_repos_$env/mrapid-scripts/* $APPL_BASE_PATH/
if [ $? -ne 0 ]
then
        echo "ERROR Failed to deploy code to target application path"
        exit 1;
else
        echo "INFO Successfully deployed code to target application path"
fi

#Change framework.profile file
echo -e "MYSQL_HOSTNAME=10.8.32.75
MYSQL_USERNAME=cgfspoc1
MYSQL_PASSWORD=cgfspoc1
TMD_DB=mrapid_demo
OPS_DB=mrapid_demo
HIVE_DB=datalake
BASE_DATA_PATH=$APPL_BASE_PATH
HDFS_BASE_PATH=data_lake/hdfs_storage
HIVE_WAREHOUSE_LOCATION=/user/cgfspoc1/data_lake/hive_warehouse
STAGING_AREA=data_lake/.staging
HIVE_TABLE_PARTITIONING=N
HIVE_TABLE_PARTITION_BY=dt" > $APPL_BASE_PATH/data_ingestion_framework/common/conf/framework.profile
