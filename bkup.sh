

#/bin/bash

LOGFILE="/home/log/backupscript.log"
echo "Starting backups for `date`" >> "$LOGFILE"

bklinux()
{
DIR="/home/linux/"
TAR="Linux.tar"
BZIP="$TAR.bz2"
SERVER="linuxbox"
RDIR="/var/www/html/"

cd "$DIR"
tar cf "$TAR" src/*.xml src/images/*.png src/images/*.eps
echo "Compressing $TAR..." >> "$LOGFILE"
bzip2 "$TAR"
echo "...done." >> "$LOGFILE"
echo "Copying to $SERVER..." >> "$LOGFILE"
scp "$BZIP" "$SERVER:$RDIR" > /dev/null 2>&1
echo "...done." >> "$LOGFILE"
echo -e "Done backing up Linux files:\nSource files, stuff.\nRubbish removed." >> "$LOGFILE"
rm "$BZIP"
}

bupbash()
{
DIR="/home/linux/db/"
TAR="Bash.tar"
BZIP="$TAR.bz2"
FILES="bash-programming/"
SERVER="linuxserver"
RDIR="/var/www/html/"

cd "$DIR"
tar cf "$TAR" "$FILES"
echo "Compressing $TAR..." >> "$LOGFILE"
bzip2 "$TAR"
echo "...done." >> "$LOGFILE"
echo "Copying to $SERVER..." >> "$LOGFILE"
scp "$BZIP" "$SERVER:$RDIR" > /dev/null 2>&1
echo "...done." >> "$LOGFILE"

echo -e "Done backing up Linux:\n$FILES\nRubbish removed." >> "$LOGFILE"
rm "$BZIP"
}

DAY=`date +%w`

if [ "$DAY" -lt "2" ]; then
  echo "It is `date +%A`, only backing up Linux." >> "$LOGFILE"
  bupbash
else
  buplinux
  bupbash
fi


echo -e "Remote backup `date` SUCCESS\n----------" >> "$LOGFILE"
