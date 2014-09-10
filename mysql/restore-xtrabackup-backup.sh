#!/bin/bash
# vim: set sw=4 sts=4 et foldmethod=indent :

PREP_BACKUP_DIR=$1
INSTANCE_NAME=$2
PORT=$3
DATA_DIR=/var/lib/$INSTANCE_NAME
CONFIG_FILE=/etc/$INSTANCE_NAME/my.cnf

if [ ! -d $PREP_BACKUP_DIR];then
    echo "$PREP_BACKUP_DIR is not a prepared backup directory!"
    exit 2
fi

echo "Stopping mysql instance $INSTANCE_NAME on port $PORT..."
mysqladmin -h127.0.0.1 --port=$PORT -uroot shutdown

echo "Deleting contents from $DATA_DIR because innobackupex needs an empty datadir..."
find $DATA_DIR -mindepth 1 -delete

echo "Running backup from backup dir $PREP_BACKUP_DIR..."
innobackupex --defaults-file=$CONFIG_FILE --copy-back $PREP_BACKUP_DIR || { echo "Couldn't run innobackupex"; exit 2; }
chown -R mysql:mysql $DATA_DIR || { echo "Couldn't give permissions to mysql for the data directory $DATA_DIR"; exit 2; }

echo "Starting mysql instance $INSTANCE_NAME..."
mysqld_safe --defaults-file=$CONFIG_FILE &
