#!/usr/bin/env bash

SCRIPTDIR=$(readlink -f $0)
SCRIPTDIR=$(dirname $SCRIPTDIR)
BASEDIR=$(dirname $SCRIPTDIR)

# CONFIG PATH AND FILES
CONFIGDIR="$BASEDIR/config"
source "$CONFIGDIR/config.sh"


if [ ! -f "$LOGROTATECONFIGFILE" ] ; then
    tmp=$(printf $LOGFILE "*")
    echo "$tmp {
    daily
    missingok
    rotate 30
    nocompress
    nomail
    notifempty
}" > $LOGROTATECONFIGFILE
fi

if [ ! -d "$BACKUPDIR" ] ; then
    mkdir -p $BACKUPDIR
fi

# LOGROTATE
/usr/sbin/logrotate -s ./status.tmp $LOGROTATECONFIGFILE

# DO DUMP
for PREFIX in $PREFIXES; do
    $SCRIPTDIR/mysqldump_table_by_prefix.sh --defaults-extra-file $DATABASECONFIGFILE $DATABASE $PREFIX | gzip -9 > $(printf $LOGFILE $PREFIX)
done
