#!/bin/bash
# A shell script to backup MySQL database and directories to a nas server.
 
###############################
#  	     Variables        #
###############################

### SETUP BIN PATHS ###
MKDIR=/bin/mkdir
CP=/bin/cp
GTAR=/bin/tar
RSYNC=/usr/bin/rsync
MOUNT=/bin/mount
UMOUNT=/bin/umount
GREP=/bin/grep
AWK=/bin/awk
SED=/bin/sed
CUT=/bin/cut
MYSQL=/usr/bin/mysql
MYSQLADMIN=/usr/bin/mysqladmin
MYSQLDUMP=/usr/bin/mysqldump
GZIP=/bin/gzip
LOGGER=/usr/bin/logger
MAILCMD=/bin/mail
DU=/usr/bin/du
RM=/bin/rm

### SETUP NAS LOGIN ###
NASUSER=user
NASPASSWORD=MyPassWord
NASSERVER=nas10.server.com
NASMNT=/nas10

### ADMIN Notification Email Ids ###
WARN_ADMIN_EMAIL_IDS="user@example.com,user@example.net"

### SETUP MYSQL LOGIN/Password ###
MUSER='root'
MPASS='mySqlLoginPassword'
MHOST="127.0.0.1"

### SETUP MYSQL BACKUP PATHS ###
MBAKPATH=${NASMNT}/mysql

### SETUP TAR BALL BACKUP PATHS ###
TBAKPATH=${NASMNT}/tarballs

### Setup file system dirs to backup ###
TAR_SRC_DIRS='/etc /var/named/chroot /root /home /var/www/html /usr/local/mailboxes'
 
### Date format dd-mm-yyyy ###
NOW=$(date +"%d-%m-%Y")

### Time format hh_mm_ssAM|PM ###
TIME_FORMAT='%H_%M_%S%P'

###############################
#  User Defined Functions    #
###############################

#
# Purpose: Send warning email.
#
tar_warn_email(){
        $LOGGER "$(basename $0) GNU/tar: *** Failed at $(date) ***"
        $MAILCMD -s "GNU/TAR Backup Failed" "${WARN_ADMIN_EMAIL_IDS}"<<EOF
GNU/Tar backup failed @ $(date) for $(hostname)
EOF
}

#
# Purpose: Backup file system directories.
# 
backup_tar(){
        $LOGGER "$(basename $0) GNU/tar: Started at $(date)"
        # call function to mount nas device 
        mount_nas
        [ ! -d ${TBAKPATH}/$NOW/ ] && $MKDIR -p ${TBAKPATH}/$NOW/
        local path="${TBAKPATH}/$NOW/fs-$(date +"${TIME_FORMAT}").tar.gz"
        $GTAR --exclude "*/proc/*" --exclude "*/dev/*" --exclude '*/cache/*' -zcvf $path $TAR_SRC_DIRS
        [ $? -ne 0 ] && tar_warn_email
        # call function to unmount nas device
        umount_nas
        $LOGGER "$(basename $0) GNU/tar: Ended at $(date)"
}
#
# Purpose: Mount backup nas device.
# 
mount_nas(){
        [ ! -d $NASMNT ] && $MKDIR -p $NASMNT
        $MOUNT | $GREP $NASMNT >/dev/null
        [ $? -eq 0 ] || $MOUNT -t cifs //$NASSERVER/$NASUSER -o username=$NASUSER,password=$NASPASSWORD $NASMNT
}
#
# Purpose: Unmount backup nas device.
# 
umount_nas(){
        $MOUNT | $GREP $NASMNT >/dev/null
        [ $? -eq 0 ] && $UMOUNT $NASMNT 
}
#
# Purpose: Backup mysql database.
# 
mysql(){
        $LOGGER "$(basename $0) mysql: Started at $(date)"
        local DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
        local db=""
        local linkname=""
        [ ! -d $MBAKPATH/$NOW ] && $MKDIR -p $MBAKPATH/$NOW
        for db in $DBS
        do
                [ "$db" == "sgopenxadserver"  ] && continue 
                local tTime=$(date +"${TIME_FORMAT}")
                local FILE="${MBAKPATH}/$NOW/${db}.${tTime}.gz"
                $MYSQLDUMP -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE
                #create latest file link
                linkname="${MBAKPATH}/$NOW/${db}.latest"
                [ -L $linkname ] && /bin/rm $linkname
                /bin/ln -s $FILE $linkname
        done
        $LOGGER "$(basename $0) mysql: Ended at $(date)"
}

#
# Purpose: Wrapper function to call other functions.
#
backup_mysql(){
        mount_nas         # call function to mount nas device
        mysql
        umount_nas        # call function to unmount nas device
}

###################################
# Main Script Logic Starts Here   #
###################################
case "$1" in
        mysql)
                backup_mysql
                ;;
        fsbak)
                backup_tar
                ;;
        mount)
                mount_nas
                ;;
        umount)
                umount_nas
                ;;
        *)
                echo "Usage: $0 {mysql|fsbak|mount|umount}"
                echo ""
                echo "Use this shell script to backup mysql database and directories to backup nas server."
esac
