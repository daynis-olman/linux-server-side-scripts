#!/bin/bash
#
BAKDATE=$(date +"%Y-%m-%d")
ENV="prod"
PHPCMD="/usr/local/bin/php"
MYSQLDUMP="/usr/bin/mysqldump"
MYSQLUSER="DATABASE-USERNAME"
MYSQLPASS="DATABASE-PASSWORD"
MYSQLDB="DATABASE-NAME"
BIN="/home/aujennycraig/bin"
BACKUPDIR="/home/aujennycraig/aws-s3-temp-local-backup"
LOCALEXPIRE="7"
#
echo "====================================================================================================================="
NOW=$(date +"%Y-%m-%d %H:%M:%S")
echo "- $NOW: ---- Starting database backup process ($ENV)"
echo "- $NOW: ---- 1.Creating local database backup ($BACKUPDIR/$ENV-db-$BAKDATE.sql)"
$MYSQLDUMP -u$MYSQLUSER -p$MYSQLPASS $MYSQLDB -R -e --triggers --single-transaction 1>$BACKUPDIR/$ENV-db-$BAKDATE.sql 2>/dev/null
#
NOW=$(date +"%Y-%m-%d %H:%M:%S")
echo "- $NOW: ---- 2.Uploading to S3 ($ENV-db-$BAKDATE.sql) Bucket"
$PHPCMD $BIN/cjc-aws-s3-upload.php $ENV-db-$BAKDATE.sql
#
NOW=$(date +"%Y-%m-%d %H:%M:%S")
echo "- $NOW: ---- 3.Deleting old local backups older than $LOCALEXPIRE days"
find $BACKUPDIR/* -mtime +$LOCALEXPIRE -exec rm {} \;
#
NOW=$(date +"%Y-%m-%d %H:%M:%S")
echo "- $NOW: ---- Done the backup"
echo "====================================================================================================================="
