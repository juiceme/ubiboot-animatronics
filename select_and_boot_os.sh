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


## Save persistent ubiboot log file 
save_logfile()
{
  mount /mnt/2
  logger "Saving ubiboot log files"
  cat /var/log/messages >> /mnt/2/var/log/ubiboot.log
  date >> /mnt/2/var/log/ubiboot.dmesg
  dmesg  >> /mnt/2/var/log/ubiboot.dmesg
  echo >> /mnt/2/var/log/ubiboot.dmesg
  sync
  umount /mnt/2
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

