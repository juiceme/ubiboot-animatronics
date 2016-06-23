#!/bin/sh

##
## boot selection and launcher script for ubiboot.
##
## Authors:
## Copyright 2013 by Jussi Ohenoja <juice@swagman.org>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License version 2 as
## published by the Free Software Foundation.
##


## Get the kernel configuration
## We already know this file exists because it is checked in init.
source /etc/ubiboot.conf

# Text2screen wrapper for next lines
TTSYI=0 # Where to start
TTSX=0
TTSY=TTSYI
TTS_PIX_PER_CHAR=9
TTS_SCALE=2
TTSYM=480 # Max y lines
TTSXM=830 # Max x lines
TTSCM=$(($TTSXM/($TTS_PIX_PER_CHAR*$TTS_SCALE))) # Max char/line
TTSI=$(((TTS_PIX_PER_CHAR+1)*TTS_SCALE))


ttsr()
{
  TTSY=$TTSYI
  fb_text2screen -c -B000
}


tts()
{
  fb_text2screen -s $TTS_SCALE -y $TTSY -t "$1"
  let "LINES=1+${#1}/$TTSCM"
  let "TTSY+=($TTSI*$LINES)"
  if [ $TTSY -gt $TTSYM ] ; then ttsr ; fi
}


try_to_mount()
{
  mount -t vfat $1 $2 > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    logger "Mounted $1 on $2 as VFAT"
    return 0
  fi
  mount -t exfat $1 $2 > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    logger "Mounted $1 on $2 as EXFAT"
    return 0
  fi
  mount -t ext2 $1 $2 > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    logger "Mounted $1 on $2 as EXT2"
    return 0
  fi
  mount -t ext3 $1 $2 > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    logger "Mounted $1 on $2 as EXT3"
    return 0
  fi
  mount -t ext4 $1 $2 > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    logger "Mounted $1 on $2 as EXT4"
    return 0
  fi
  logger "Could not mount $1 on $2"
  return 255
}


## Save persistent ubiboot log file
save_logfile()
{
  logger "Saving ubiboot log files"
  mount | grep "/mnt/$G_LOGFILE_PARTITION" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    logger "logfile partition is mounted to /mnt/$G_LOGFILE_PARTITION"
  else
    logger "logfile partition /mnt/$G_LOGFILE_PARTITION is not mounted"
    try_to_mount "/dev/mmcblk0p$G_LOGFILE_PARTITION" "/mnt/$G_LOGFILE_PARTITION"
  fi
  mkdir -p "/mnt/$G_LOGFILE_PARTITION/${G_LOGFILE_DIRECTORY}"
  cat /var/log/messages >> "/mnt/$G_LOGFILE_PARTITION/${G_LOGFILE_DIRECTORY}/ubiboot.log"
  echo >> "/mnt/$G_LOGFILE_PARTITION/${G_LOGFILE_DIRECTORY}/ubiboot.log"
  date >> "/mnt/$G_LOGFILE_PARTITION/${G_LOGFILE_DIRECTORY}/ubiboot.dmesg"
  dmesg >> "/mnt/$G_LOGFILE_PARTITION/${G_LOGFILE_DIRECTORY}/ubiboot.dmesg"
  echo >> "/mnt/$G_LOGFILE_PARTITION/${G_LOGFILE_DIRECTORY}/ubiboot.dmesg"
  sync
  umount "/mnt/$G_LOGFILE_PARTITION"
}


## Check that menu exists, execute it and boot to selected OS & kernel
if [ -x /boot/menu/select_os_animated.sh ]; then
  /boot/menu/select_os_animated.sh
  if [ $? -eq 0 ]; then
    logger "Restarting to selected OS"
    save_logfile
    /usr/bin/disable_pm
    # restart to the selected kernel
    kexec -e ; echo $? ; sleep 10
  else
    logger "Boot OS/kernel selection failed"
    save_logfile
    ttsr
    tts ""
    tts "Boot OS/kernel selection failed!"
    tts "Please run a maintanance boot"
  fi
else
  logger "Animated boot menu script not found!"
  save_logfile
  ttsr
  tts ""
  tts "Animated boot menu script not found!"
  tts "Please run a maintanance boot"
fi

