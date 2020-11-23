#!/bin/bash
#
# Automate Raspberry Pi Backups
#
# Kristofer Källsbo 2017 www.hackviking.com
#
# Usage: system_backup.sh {path} {days of retention}
#
# Below you can set the default values if no command line args are sent.
# The script will name the backup files {$HOSTNAME}.{YYYYmmdd}.img
# When the script deletes backups older then the specified retention
# it will only delete files with it's own $HOSTNAME.
#

# Declare vars and set standard values
backup_path=/home/pi/maria/worker11811
retention_days=14
hostname=worker11811

# Check that we are root!
if [[ ! $(whoami) =~ "root" ]]; then
echo ""
echo "**********************************"
echo "*** This needs to run as root! ***"
echo "**********************************"
echo ""
exit
fi

# Check to see if we got command line args
if [ ! -z $1 ]; then
   backup_path=$1
fi

if [ ! -z $2 ]; then
   retention_days=$2
fi

# Create trigger to force file system consistency check if image is restored
touch /boot/forcefsck

# Perform backup
dd if=/dev/mmcblk0 of=$backup_path/$hostname.$(date +%Y%m%d).img bs=1M

# Remove fsck trigger
rm /boot/forcefsck

# Delete old backups
find $backup_path/$hostname.*.img -mtime +$retention_days -type f -delete 

# Compress new backup
sudo tar -c --use-compress-program=pigz -f "$backup_path/$hostname.$(date +%Y%m%d).tar.gz" "$backup_path/$hostname.$(date +%Y%m%d).img"

# Delete new .img and .tar.gz files past retention_days
sudo rm "$backup_path/$hostname.$(date +%Y%m%d).img"
find $backup_path/$hostname.*.tar.gz -mtime +$retention_days -type f -delete
