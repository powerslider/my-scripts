#!/bin/bash
# vim: set sw=4 sts=4 et foldmethod=indent :

# This script will prepare the backups from a given week to a given directory.
# This will automate the procedure of rewinding our incremental backup
# procedure on weekly basis. None that this script expects some preconditions
# from the mysql_backup script that we have!

usage() {
cat << EOF
Usage is $0 <weekly-backups-dir> <destination> where
<weekly-backups-dir> is the directory containing the backups from the week you want to restore - there should be different backup directories with incremental backups
<destination> where to rewind and keep the whole backup that is ready for restoring
EOF
}

if [ $# -lt 2 ];then
    usage
    exit 1
fi

if [ ! -d $1 ];then
    echo $1 is not a directory containing weekly incremental backups
    exit 1
fi

if [ -e $2 ];then
    echo $2 already exists. Please specify a non existing path!
    exit 1
fi

# create the destination dir
echo Creating directory $2 which will contain the resulting *prepared* backup
mkdir -p $2


c=0
find $1 -mindepth 1 -maxdepth 1 -type d -printf "%P\n" | sort -n | while read backup;do

    # The procedures here are explained in
    # http://www.percona.com/doc/percona-xtrabackup/innobackupex/incremental_backups_innobackupex.html
    # in section "Preparing an Incremental Backup with innobackupex"

    # first backup should be a base backup
    if [ $c -eq 0 ];then
        echo "Applying the log from the full backup $backup"
        zcat $1/$backup/backup-$backup.xbstream.gz  | xbstream -x -C $2
        innobackupex --apply-log --redo-only $2
    else
        echo "Applying the log from an incremental backup $backup"
        temp_dir=`mktemp -d`
        zcat $1/$backup/backup-$backup.xbstream.gz | xbstream -x -C "$temp_dir"
        innobackupex --apply-log --redo-only $2 --incremental-dir="$temp_dir"
        echo "Cleaning up after the incremental backup $backup"
        rm -rf "$temp_dir"
    fi
    c=$((c + 1))
done

