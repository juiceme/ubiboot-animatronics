#!/bin/sh

##
## This script is used to display the menu animation sequences for N9 ubiboot and
## subsequently load the selected OS & kernel image for later booting.
##
## On success the script returns zero, and kexec() to the selecion is possible.
## On failure the script returns 1
##
## Authors:
## Copyright 2013 by Jussi Ohenoja <juice@swagman.org>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##
##
##


## Get the kernel configuration
## We already know this file exists because it is checked in init.
source /etc/ubiboot.conf

## Get the animation sequence data
if [ -r /boot/menu/ctrl_animation.rc ]; then
  logger "Loading animation control file"
  source /boot/menu/ctrl_animation.rc
else
  # animation control file is missing, so fail...
  logger "Failed to load animation control file!"
  exit 1
fi

## Shortcuts
EVTAP="/usr/bin/evtap"
TEXT2SCREEN="/usr/bin/text2screen"
SHOWPNG="/usr/bin/show_png"
IMAGEBASE="/boot/menu/animation"
TOPMAP="/boot/menu/animated_menu_top.map"

## Return the number as 2 digits
printindex()
{
  if [ $1 -lt 10 ]; then
    echo "0$1"
  else
    echo "$1"
  fi
 }

## Get the "Atmel mXT Touchscreen" device from proc;
touchdevice=$(cat /proc/bus/input/devices | grep  -A 4 "mXT" | grep "Handlers" | cut -b 13-18)
logger "touchdevice: /dev/input/$touchdevice"

## This is the original command line given by NOLO to the 1st stage loader:
O_COMMAND_LINE=$(cat /proc/original_cmdline)
logger "O_COMMAND_LINE: $O_COMMAND_LINE"

## Fade in the top menu icons
menu_fadein()
{
  FRAMENUM=0
  LASTFRAME=$ANIM_FX_COUNT
  while [ $FRAMENUM -lt $LASTFRAME ] ; do
    let "FRAMENUM+=1"
    INDEX=$(printindex $FRAMENUM)
    $SHOWPNG $IMAGEBASE/fx_$INDEX.png > /dev/null
  done
}


## fade out the top menu icons
menu_fadeout()
{
  FRAMENUM=$ANIM_FX_COUNT
  while [ $FRAMENUM -gt 1 ] ; do
    let "FRAMENUM-=1"
    INDEX=$(printindex $FRAMENUM)
    $SHOWPNG $IMAGEBASE/fx_$INDEX.png > /dev/null
  done
}


## Preload the kexec() with OS1 kernel and set command line parameters
load_OS1()
{
  BOOTKERNEL=$1
  logger "Selecting $G_OS1_NAME OS, running kernel $BOOTKERNEL"
  menu_fadeout
  if [ -r "$G_OS1_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS1_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS1_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS1_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS1_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS1_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS1_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS1_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$BOOTKERNEL" ]; then
    logger "Cannot load $G_OS1_NAME kernel $BOOTKERNEL"
    exit 1
  fi
  logger "Loading kernel $BOOTKERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $BOOTKERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## Preload the kexec() with OS2 kernel and set command line parameters
load_OS2()
{
  BOOTKERNEL=$1
  logger "Selecting $G_OS2_NAME OS, running kernel $BOOTKERNEL"
  menu_fadeout
  if [ -r "$G_OS2_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS2_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS2_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS2_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS2_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS2_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS2_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS2_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$BOOTKERNEL" ]; then
    logger "Cannot load $G_OS2_NAME kernel $BOOTKERNEL"
    exit 1
  fi
  logger "Loading kernel $BOOTKERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $BOOTKERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## Preload the kexec() with OS3 kernel and set command line parameters
load_OS3()
{
  BOOTKERNEL=$1
  logger "Selecting $G_OS3_NAME OS, running kernel $BOOTKERNEL"
  menu_fadeout
  if [ -r "$G_OS3_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS3_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS3_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS3_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS3_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS3_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS3_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS3_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$BOOTKERNEL" ]; then
    logger "Cannot load $G_OS3_NAME kernel $BOOTKERNEL"
    exit 1
  fi
  logger "Loadin kernel $BOOTKERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $BOOTKERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## Preload the kexec() with OS4 kernel and set command line parameters
load_OS4()
{
  BOOTKERNEL=$1
  logger "Selecting $G_OS4_NAME OS, running kernel $BOOTKERNEL"
  menu_fadeout
  if [ -r "$G_OS4_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS4_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS4_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS4_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS4_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS4_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS4_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS4_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$BOOTKERNEL" ]; then
    logger "Cannot load $G_OS4_NAME kernel $BOOTKERNEL"
    exit 1
  fi
  logger "Loading kernel $BOOTKERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $BOOTKERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## Preload the kexec() with OS5 kernel and set command line parameters
load_OS5()
{
  BOOTKERNEL=$1
  logger "Selecting $G_OS5_NAME OS, running kernel $BOOTKERNEL"
  menu_fadeout
  if [ -r "$G_OS5_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS5_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS5_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS5_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS5_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS5_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS5_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS5_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$BOOTKERNEL" ]; then
    logger "Cannot load $G_OS5_NAME kernel $BOOTKERNEL"
    exit 1
  fi
  logger "Loading kernel $BOOTKERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $BOOTKERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## Preload the kexec() with OS6 kernel and set command line parameters
load_OS6()
{
  BOOTKERNEL=$1
  logger "Selecting $G_OS6_NAME OS, running kernel $BOOTKERNEL"
  menu_fadeout
  if [ -r "$G_OS6_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS6_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS6_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS6_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS6_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS6_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS6_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS6_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$BOOTKERNEL" ]; then
    logger "Cannot load $G_OS6_NAME kernel $BOOTKERNEL"
    exit 1
  fi
  logger "Loading kernel $BOOTKERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $BOOTKERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## If the main menu timeouts, load the default kernel and OS
load_default_os()
{
  logger "Selecting defaults due to timeout in main menu"
  if [ "$G_DEFAULT_OS" == "OS1" ]; then
    load_OS1 "$G_DEFAULT_KERNEL"
  fi
  if [ "$G_DEFAULT_OS" == "OS2" ]; then
    load_OS2 "$G_DEFAULT_KERNEL"
  fi
  if [ "$G_DEFAULT_OS" == "OS3" ]; then
    load_OS3 "$G_DEFAULT_KERNEL"
  fi
  if [ "$G_DEFAULT_OS" == "OS4" ]; then
    load_OS4 "$G_DEFAULT_KERNEL"
  fi
  if [ "$G_DEFAULT_OS" == "OS5" ]; then
    load_OS5 "$G_DEFAULT_KERNEL"
  fi
  if [ "$G_DEFAULT_OS" == "OS6" ]; then
    load_OS6 "$G_DEFAULT_KERNEL"
  fi

  ## If we get here something is wrong
  logger "Failed Selecting default OS!"
  exit 1;
}


## Main menu icon clicked, so make it bounce a bit
bounce_icon()
{
  if [ "$1" == "OS1" ]; then
    IFILE="pi1"
  fi
  if [ "$1" == "OS2" ]; then
    IFILE="pi2"
  fi
  if [ "$1" == "OS3" ]; then
    IFILE="pi3"
  fi
  if [ "$1" == "OS4" ]; then
    IFILE="pi5"
  fi
  if [ "$1" == "OS5" ]; then
    IFILE="pi6"
  fi
  if [ "$1" == "OS6" ]; then
    IFILE="pi7"
  fi
  if [ "$1" == "Toolsmenu" ]; then
    IFILE="pi4"
  fi
  if [ "$1" == "Info" ]; then
    IFILE="pi8"
  fi

  FRAMENUM=0
  LASTFRAME=$ANIM_BP_COUNT
  while [ $FRAMENUM -lt $LASTFRAME ] ; do
    let "FRAMENUM+=1"
    INDEX=$(printindex $FRAMENUM)
    $SHOWPNG $IMAGEBASE/${IFILE}_$INDEX.png > /dev/null
  done
  let "FRAMENUM-=1"
  while [ $FRAMENUM -gt 1 ] ; do
    let "FRAMENUM-=1"
    INDEX=$(printindex $FRAMENUM)
    $SHOWPNG $IMAGEBASE/${IFILE}_$INDEX.png > /dev/null
  done
}


## Output a map file for evtap, containing 0..6 kernel lines and "back" button line
generate_temporary_mapfile()
{
  maplines=$1
  X1B=213
  X1E=287
  X2B=288
  X2E=362
  X3B=363
  X3E=437
  X4B=438
  X4E=512
  X5B=513
  X5E=587
  X6B=588
  X6E=662
  mapfile_header=$(echo -e "# This is a generated map file for evtap.*#*#")
  if [ $maplines -gt 0 ]; then
    mapfile_line_1=$(echo -e "$X1B 0 $X1E 480 1 65 $2")
  else
    mapfile_line_1=$(echo -e "# mapfile_line_1")
  fi
  if [ $maplines -gt 1 ]; then
    mapfile_line_2=$(echo -e "$X2B 0 $X2E 480 2 65 $3")
  else
    mapfile_line_2=$(echo -e "# mapfile_line_2")
  fi
  if [ $maplines -gt 2 ]; then
    mapfile_line_3=$(echo -e "$X3B 0 $X3E 480 3 65 $4")
  else
    mapfile_line_3=$(echo -e "# mapfile_line_3")
  fi
  if [ $maplines -gt 3 ]; then
    mapfile_line_4=$(echo -e "$X4B 0 $X4E 480 4 65 $5")
  else
     mapfile_line_4=$(echo -e "# mapfile_line_4")
  fi
  if [ $maplines -gt 4 ]; then
    mapfile_line_5=$(echo -e "$X5B 0 $X5E 480 5 65 $6")
  else
    mapfile_line_5=$(echo -e "# mapfile_line_5")
  fi
  if [ $maplines -gt 5 ]; then
    mapfile_line_6=$(echo -e "$X6B 0 $X6E 480 6 65 $7")
  else
     mapfile_line_6=$(echo -e "# mapfile_line_6")
  fi
  mapfile_tailer=$(echo -e "#*750 164 795 318 0 65 BACK*")
  echo -e "$mapfile_header*$mapfile_line_1*$mapfile_line_2*$mapfile_line_3*$mapfile_line_4*$mapfile_line_5*$mapfile_line_6*$mapfile_tailer"
}


## Output the kernel list to screen.
## If highlight is specified, the given line is highlighted and the rest are dimmed, otherwice use the given colour for all lines.
draw_kernel_list()
{
  mode=$1
  textcolor=$2
  highlighted=$3

  if [ $highlighted -gt 6 ]; then
     highlighted=6
  fi

  if [ "$highlighted" != "0" ]; then
    textcolor="0x001200"
  fi

  highcolor="0x001700"
  X1=250
  X2=325
  X3=400
  X4=475
  X5=550
  X6=625
  I=0
  if [ "$mode" == "OS1" ]; then
    if [ $G_OS1_NUM -gt 6 ]; then
      G_OS1_NUM=6
    fi
    if [ $G_OS1_NUM -ge 1 -a "$G_OS1_1_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS1_1_LABEL" -T "$textcolor"
      if [ "$highlighted" == "1" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS1_1_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS1_NUM -ge 2 -a "$G_OS1_2_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS1_2_LABEL" -T "$textcolor"
      if [ "$highlighted" == "2" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS1_2_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS1_NUM -ge 3 -a "$G_OS1_3_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS1_3_LABEL" -T "$textcolor"
      if [ "$highlighted" == "3" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS1_3_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS1_NUM -ge 4 -a "$G_OS1_4_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS1_4_LABEL" -T "$textcolor"
      if [ "$highlighted" == "4" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS1_4_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS1_NUM -ge 5 -a "$G_OS1_5_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS1_5_LABEL" -T "$textcolor"
      if [ "$highlighted" == "5" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS1_5_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS1_NUM -ge 6 -a "$G_OS1_6_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS1_6_LABEL" -T "$textcolor"
      if [ "$highlighted" == "6" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS1_6_LABEL" -T "$highcolor"
      fi
    fi
    echo $G_OS1_NUM
  fi

  if [ "$mode" == "OS2" ]; then
    if [ $G_OS2_NUM -gt 6 ]; then
      G_OS2_NUM=6
    fi
    if [ $G_OS2_NUM -ge 1 -a "$G_OS2_1_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS2_1_LABEL" -T "$textcolor"
      if [ "$highlighted" == "1" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS2_1_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS2_NUM -ge 2 -a "$G_OS2_2_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS2_2_LABEL" -T "$textcolor"
      if [ "$highlighted" == "2" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS2_2_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS2_NUM -ge 3 -a "$G_OS2_3_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS2_3_LABEL" -T "$textcolor"
      if [ "$highlighted" == "3" ]; then
         $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS2_3_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS2_NUM -ge 4 -a "$G_OS2_4_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS2_4_LABEL" -T "$textcolor"
      if [ "$highlighted" == "4" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS2_4_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS2_NUM -ge 5 -a "$G_OS2_5_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS2_5_LABEL" -T "$textcolor"
      if [ "$highlighted" == "5" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS2_5_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS2_NUM -ge 6 -a "$G_OS2_6_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS2_6_LABEL" -T "$textcolor"
      if [ "$highlighted" == "6" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS2_6_LABEL" -T "$highcolor"
      fi
    fi
    echo $G_OS2_NUM
  fi

  if [ "$mode" == "OS3" ]; then
    if [ $G_OS3_NUM -gt 6 ]; then
      G_OS3_NUM=6
    fi
    if [ $G_OS3_NUM -ge 1 -a "$G_OS3_1_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS3_1_LABEL" -T "$textcolor"
      if [ "$highlighted" == "1" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS3_1_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS3_NUM -ge 2 -a "$G_OS3_2_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS3_2_LABEL" -T "$textcolor"
      if [ "$highlighted" == "2" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS3_2_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS3_NUM -ge 3 -a "$G_OS3_3_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS3_3_LABEL" -T "$textcolor"
      if [ "$highlighted" == "3" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS3_3_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS3_NUM -ge 4 -a "$G_OS3_4_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS3_4_LABEL" -T "$textcolor"
      if [ "$highlighted" == "4" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS3_4_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS3_NUM -ge 5 -a "$G_OS3_5_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS3_5_LABEL" -T "$textcolor"
      if [ "$highlighted" == "5" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS3_5_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS3_NUM -ge 6 -a "$G_OS3_6_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS3_6_LABEL" -T "$textcolor"
      if [ "$highlighted" == "6" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS3_6_LABEL" -T "$highcolor"
      fi
    fi
    echo $G_OS3_NUM
  fi

  if [ "$mode" == "OS4" ]; then
    if [ $G_OS4_NUM -gt 6 ]; then
      G_OS4_NUM=6
    fi
    if [ $G_OS4_NUM -ge 1 -a "$G_OS4_1_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS4_1_LABEL" -T "$textcolor"
      if [ "$highlighted" == "1" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS4_1_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS4_NUM -ge 2 -a "$G_OS4_2_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS4_2_LABEL" -T "$textcolor"
      if [ "$highlighted" == "2" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS4_2_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS4_NUM -ge 3 -a "$G_OS4_3_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS4_3_LABEL" -T "$textcolor"
      if [ "$highlighted" == "3" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS4_3_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS4_NUM -ge 4 -a "$G_OS4_4_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS4_4_LABEL" -T "$textcolor"
      if [ "$highlighted" == "4" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS4_4_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS4_NUM -ge 5 -a "$G_OS4_5_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS4_5_LABEL" -T "$textcolor"
      if [ "$highlighted" == "5" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS4_5_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS4_NUM -ge 6 -a "$G_OS4_6_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS4_6_LABEL" -T "$textcolor"
      if [ "$highlighted" == "6" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS4_6_LABEL" -T "$highcolor"
      fi
    fi
    echo $G_OS4_NUM
  fi

  if [ "$mode" == "OS5" ]; then
    if [ $G_OS5_NUM -gt 6 ]; then
      G_OS5_NUM=6
    fi
    if [ $G_OS5_NUM -ge 1 -a "$G_OS5_1_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS5_1_LABEL" -T "$textcolor"
      if [ "$highlighted" == "1" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS5_1_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS5_NUM -ge 2 -a "$G_OS5_2_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS5_2_LABEL" -T "$textcolor"
      if [ "$highlighted" == "2" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS5_2_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS5_NUM -ge 3 -a "$G_OS5_3_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS5_3_LABEL" -T "$textcolor"
      if [ "$highlighted" == "3" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS5_3_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS5_NUM -ge 4 -a "$G_OS5_4_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS5_4_LABEL" -T "$textcolor"
      if [ "$highlighted" == "4" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS5_4_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS5_NUM -ge 5 -a "$G_OS5_5_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS5_5_LABEL" -T "$textcolor"
      if [ "$highlighted" == "5" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS5_5_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS5_NUM -ge 6 -a "$G_OS5_6_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS5_6_LABEL" -T "$textcolor"
      if [ "$highlighted" == "6" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS5_6_LABEL" -T "$highcolor"
      fi
    fi
    echo $G_OS5_NUM
  fi

  if [ "$mode" == "OS6" ]; then
    if [ $G_OS6_NUM -gt 6 ]; then
      G_OS6_NUM=6
    fi
    if [ $G_OS6_NUM -ge 1 -a "$G_OS6_1_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS6_1_LABEL" -T "$textcolor"
      if [ "$highlighted" == "1" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_OS6_1_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS6_NUM -ge 2 -a "$G_OS6_2_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS6_2_LABEL" -T "$textcolor"
      if [ "$highlighted" == "2" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_OS6_2_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS6_NUM -ge 3 -a "$G_OS6_3_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS6_3_LABEL" -T "$textcolor"
      if [ "$highlighted" == "3" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_OS6_3_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS6_NUM -ge 4 -a "$G_OS6_4_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS6_4_LABEL" -T "$textcolor"
      if [ "$highlighted" == "4" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_OS6_4_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS6_NUM -ge 5 -a "$G_OS6_5_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS6_5_LABEL" -T "$textcolor"
      if [ "$highlighted" == "5" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_OS6_5_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_OS6_NUM -ge 6 -a "$G_OS6_6_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS6_6_LABEL" -T "$textcolor"
      if [ "$highlighted" == "6" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_OS6_6_LABEL" -T "$highcolor"
      fi
    fi
    echo $G_OS6_NUM
  fi

  return "0"
}


## Get the kernels in the defined directory and format the output as a selection list.
## If highlight is specified, the given line is highlighted and the rest are dimmed, otherwice use the given colour for all lines.
draw_kernel_autolist()
{
  kerneldir=$1
  textcolor=$2
  highlighted=$3

  if [ $highlighted -gt 6 ]; then
     highlighted=6
  fi

  TMP_SHORTNAME_1=""
  TMP_SHORTNAME_2=""
  TMP_SHORTNAME_3=""
  TMP_SHORTNAME_4=""
  TMP_SHORTNAME_5=""
  TMP_SHORTNAME_6=""

  let linecount=0                                                                  
  IFS=$'\n'                                                                        
  for longfilename in $(find "$kerneldir" -maxdepth 1 -name "zImage*" | sort ) ; do
    let linecount=$linecount+1                            
    filename=$(basename "$longfilename")                  
    shortname=$(echo "$filename" | cut -c 8- | cut -c -29)
    if [ "$linecount" -eq 1 ]; then 
      TMP_SHORTNAME_1="$shortname"  
    fi                              
    if [ "$linecount" -eq 2 ]; then 
      TMP_SHORTNAME_2="$shortname"  
    fi                              
    if [ "$linecount" -eq 3 ]; then 
      TMP_SHORTNAME_3="$shortname"  
    fi                              
    if [ "$linecount" -eq 4 ]; then 
      TMP_SHORTNAME_4="$shortname"  
    fi                              
    if [ "$linecount" -eq 5 ]; then 
      TMP_SHORTNAME_5="$shortname"  
    fi                              
    if [ "$linecount" -eq 6 ]; then 
      TMP_SHORTNAME_6="$shortname"
    fi                           
  done                           

  if [ "$linecount" -gt 6 ]; then
    linecount=6          
  fi                 

  highcolor="0x001700"
  X1=250
  X2=325
  X3=400
  X4=475
  X5=550
  X6=625

  if [ "$linecount" -ge 1 -a "$TMP_SHORTNAME_1" != "" ]; then
    $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$TMP_SHORTNAME_1" -T "$textcolor"
    if [ "$highlighted" == "1" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$TMP_SHORTNAME_1" -T "$highcolor"
    fi
  fi
  if [ "$linecount" -ge 2 -a "$TMP_SHORTNAME_2" != "" ]; then
    $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$TMP_SHORTNAME_2" -T "$textcolor"
    if [ "$highlighted" == "1" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$TMP_SHORTNAME_2" -T "$highcolor"
    fi
  fi
  if [ "$linecount" -ge 3 -a "$TMP_SHORTNAME_3" != "" ]; then
    $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$TMP_SHORTNAME_3" -T "$textcolor"
    if [ "$highlighted" == "1" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$TMP_SHORTNAME_3" -T "$highcolor"
    fi
  fi
  if [ "$linecount" -ge 4 -a "$TMP_SHORTNAME_3" != "" ]; then
    $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$TMP_SHORTNAME_4" -T "$textcolor"
    if [ "$highlighted" == "1" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$TMP_SHORTNAME_4" -T "$highcolor"
    fi
  fi
  if [ "$linecount" -ge 5 -a "$TMP_SHORTNAME_4" != "" ]; then
    $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$TMP_SHORTNAME_5" -T "$textcolor"
    if [ "$highlighted" == "1" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$TMP_SHORTNAME_5" -T "$highcolor"
    fi
  fi
  if [ "$linecount" -ge 6 -a "$TMP_SHORTNAME_5" != "" ]; then
    $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$TMP_SHORTNAME_6" -T "$textcolor"
    if [ "$highlighted" == "1" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$TMP_SHORTNAME_6" -T "$highcolor"
    fi
  fi

  echo "$linecount"

  return "0"
}


## Use a on-the-fly mapfile with evtap to get the selected kernel line
get_menuitem()
{
  mode=$1
  menulines=$2

  logger "Get menuitem for $mode ($menulines lines)"

  if [ "$mode" == "OS1" ]; then
    maplines=$(generate_temporary_mapfile $menulines "$G_OS1_1_FILE" "$G_OS1_2_FILE" "$G_OS1_3_FILE" "$G_OS1_4_FILE" "$G_OS1_5_FILE" "$G_OS1_6_FILE")
  fi
  if [ "$mode" == "OS2" ]; then
    maplines=$(generate_temporary_mapfile $menulines "$G_OS2_1_FILE" "$G_OS2_2_FILE" "$G_OS2_3_FILE" "$G_OS2_4_FILE" "$G_OS2_5_FILE" "$G_OS2_6_FILE")
  fi
  if [ "$mode" == "OS3" ]; then
    maplines=$(generate_temporary_mapfile $menulines "$G_OS3_1_FILE" "$G_OS3_2_FILE" "$G_OS3_3_FILE" "$G_OS3_4_FILE" "$G_OS3_5_FILE" "$G_OS3_6_FILE")
  fi
  if [ "$mode" == "OS4" ]; then
    maplines=$(generate_temporary_mapfile $menulines "$G_OS4_1_FILE" "$G_OS4_2_FILE" "$G_OS4_3_FILE" "$G_OS4_4_FILE" "$G_OS4_5_FILE" "$G_OS4_6_FILE")
  fi
  if [ "$mode" == "OS5" ]; then
    maplines=$(generate_temporary_mapfile $menulines "$G_OS5_1_FILE" "$G_OS5_2_FILE" "$G_OS5_3_FILE" "$G_OS5_4_FILE" "$G_OS5_5_FILE" "$G_OS5_6_FILE")
  fi
  if [ "$mode" == "OS6" ]; then
    maplines=$(generate_temporary_mapfile $menulines "$G_OS6_1_FILE" "$G_OS6_2_FILE" "$G_OS6_3_FILE" "$G_OS6_4_FILE" "$G_OS6_5_FILE" "$G_OS6_6_FILE")
  fi
  if [ "$mode" == "toolsmenu" ]; then
    maplines=$(generate_temporary_mapfile $menulines)
  fi
  if [ "$mode" == "info" ]; then
    maplines=$(generate_temporary_mapfile $menulines)
  fi

  maplines=$(echo -e "$maplines" | sed s/\*/\\n/g)

  CI=12
  II=0
  while [ 1 -gt 0 ]; do
    INDEX=$(printindex $CI)
    textcolor="0x00${INDEX}00"
    dummy=$(draw_kernel_list $mode $textcolor 0)
    if [ "$II" == "0" ]; then
      let "CI+=1"
      if [ "$CI" -ge "15" ]; then
        II=1
      fi
    else
      let "CI-=1"
      if [ "$CI" -le "12" ]; then
        II=0
      fi
    fi

    selection=$(echo -e "$maplines" | $EVTAP -t /dev/input/$touchdevice -i -d 200 -s)
    ret=$?
    highlightline=$ret
    if [ $ret -eq 255 ]; then
      continue
    fi
    if [ $ret -eq 254 ]; then
      continue
    fi
    dummy=$(draw_kernel_list $mode $textcolor $highlightline)
    sleep 1
    echo -e "$selection"
    if [ "$ret" -eq "0" ]; then
      return 1
    else
      return 0
    fi
  done

  # we should not ever get here..
  echo "BACK"
  return 1
}


## Use a on-the-fly mapfile with evtap to get the selected kernel line based on the directory listing.
get_autolist_menuitem()
{
  kerneldir=$1

  logger "Get menuitem for "$kerneldir" ($menulines lines)"

  TMP_FILENAME_1=""
  TMP_FILENAME_2=""
  TMP_FILENAME_3=""
  TMP_FILENAME_4=""
  TMP_FILENAME_5=""
  TMP_FILENAME_6=""

  let linecount=0                                                                  
  IFS=$'\n'                                                                        
  for longfilename in $(find "$kerneldir" -maxdepth 1 -name "zImage*" | sort ) ; do
    let linecount=$linecount+1                            
    filename=$(basename "$longfilename")                  
    if [ "$linecount" -eq 1 ]; then 
      TMP_FILENAME_1="$longfilename"
    fi                              
    if [ "$linecount" -eq 2 ]; then 
      TMP_FILENAME_2="$longfilename"
    fi                              
    if [ "$linecount" -eq 3 ]; then 
      TMP_FILENAME_3="$longfilename"
    fi                              
    if [ "$linecount" -eq 4 ]; then 
      TMP_FILENAME_4="$longfilename"
    fi                              
    if [ "$linecount" -eq 5 ]; then 
      TMP_FILENAME_5="$longfilename"
    fi                              
    if [ "$linecount" -eq 6 ]; then 
      TMP_FILENAME_6="$longfilename"
    fi                           
  done                           

  if [ "$linecount" -gt 6 ]; then
    linecount=6          
  fi                 

  maplines=$(generate_temporary_mapfile $linecount "$TMP_FILENAME_1"  "$TMP_FILENAME_2" "$TMP_FILENAME_3" "$TMP_FILENAME_4" "$TMP_FILENAME_5" "$TMP_FILENAME_6")
  maplines=$(echo -e "$maplines" | sed s/\*/\\n/g)

  CI=12
  II=0
  while [ 1 -gt 0 ]; do
    INDEX=$(printindex $CI)
    textcolor="0x00${INDEX}00"
    dummy=$(draw_kernel_autolist "$kerneldir" $textcolor 0)
    if [ "$II" == "0" ]; then
      let "CI+=1"
      if [ "$CI" -ge "15" ]; then
        II=1
      fi
    else
      let "CI-=1"
      if [ "$CI" -le "12" ]; then
        II=0
      fi
    fi

    selection=$(echo -e "$maplines" | $EVTAP -t /dev/input/$touchdevice -i -d 200 -s)
    ret=$?
    highlightline=$ret
    if [ $ret -eq 255 ]; then
      continue
    fi
    if [ $ret -eq 254 ]; then
      continue
    fi
    dummy=$(draw_kernel_autolist "$kerneldir" $textcolor $highlightline)
    sleep 1
    echo -e "$selection"
    if [ "$ret" -eq "0" ]; then
      return 1
    else
      return 0
    fi
  done

  # we should not ever get here..
  echo "BACK"
  return 1
}


# used to get the correct kernel to autoboot to
get_kernel_line()
{
  mode=$1
  bootline=$2

  if [ "$mode" == "OS1" ]; then
    if [ "$bootline" -eq 1 ]; then
      echo "$G_OS1_1_FILE"
    fi
    if [ "$bootline" -eq 2 ]; then
      echo "$G_OS1_2_FILE"
    fi
    if [ "$bootline" -eq 3 ]; then
      echo "$G_OS1_3_FILE"
    fi
    if [ "$bootline" -eq 4 ]; then
      echo "$G_OS1_4_FILE"
    fi
    if [ "$bootline" -eq 5 ]; then
      echo "$G_OS1_5_FILE"
    fi
    if [ "$bootline" -eq 6 ]; then
      echo "$G_OS1_6_FILE"
    fi
  fi
  if [ "$mode" == "OS2" ]; then
    if [ "$bootline" -eq 1 ]; then
      echo "$G_OS2_1_FILE"
    fi
    if [ "$bootline" -eq 2 ]; then
      echo "$G_OS2_2_FILE"
    fi
    if [ "$bootline" -eq 3 ]; then
      echo "$G_OS2_3_FILE"
    fi
    if [ "$bootline" -eq 4 ]; then
      echo "$G_OS2_4_FILE"
    fi
    if [ "$bootline" -eq 5 ]; then
      echo "$G_OS2_5_FILE"
    fi
    if [ "$bootline" -eq 6 ]; then
      echo "$G_OS2_6_FILE"
    fi
  fi
  if [ "$mode" == "OS3" ]; then
    if [ "$bootline" -eq 1 ]; then
      echo "$G_OS3_1_FILE"
    fi
    if [ "$bootline" -eq 2 ]; then
      echo "$G_OS3_2_FILE"
    fi
    if [ "$bootline" -eq 3 ]; then
      echo "$G_OS3_3_FILE"
    fi
    if [ "$bootline" -eq 4 ]; then
      echo "$G_OS3_4_FILE"
    fi
    if [ "$bootline" -eq 5 ]; then
      echo "$G_OS3_5_FILE"
    fi
    if [ "$bootline" -eq 6 ]; then
      echo "$G_OS3_6_FILE"
    fi
  fi
  if [ "$mode" == "OS4" ]; then
    if [ "$bootline" -eq 1 ]; then
      echo "$G_OS4_1_FILE"
    fi
    if [ "$bootline" -eq 2 ]; then
      echo "$G_OS4_2_FILE"
    fi
    if [ "$bootline" -eq 3 ]; then
      echo "$G_OS4_3_FILE"
    fi
    if [ "$bootline" -eq 4 ]; then
      echo "$G_OS4_4_FILE"
    fi
    if [ "$bootline" -eq 5 ]; then
      echo "$G_OS4_5_FILE"
    fi
    if [ "$bootline" -eq 6 ]; then
      echo "$G_OS4_6_FILE"
    fi
  fi
  if [ "$mode" == "OS5" ]; then
    if [ "$bootline" -eq 1 ]; then
      echo "$G_OS5_1_FILE"
    fi
    if [ "$bootline" -eq 2 ]; then
      echo "$G_OS5_2_FILE"
    fi
    if [ "$bootline" -eq 3 ]; then
      echo "$G_OS5_3_FILE"
    fi
    if [ "$bootline" -eq 4 ]; then
      echo "$G_OS5_4_FILE"
    fi
    if [ "$bootline" -eq 5 ]; then
      echo "$G_OS5_5_FILE"
    fi
    if [ "$bootline" -eq 6 ]; then
      echo "$G_OS5_6_FILE"
    fi
  fi
  if [ "$mode" == "OS6" ]; then
    if [ "$bootline" -eq 1 ]; then
      echo "$G_OS6_1_FILE"
    fi
    if [ "$bootline" -eq 2 ]; then
      echo "$G_OS6_2_FILE"
    fi
    if [ "$bootline" -eq 3 ]; then
      echo "$G_OS6_3_FILE"
    fi
    if [ "$bootline" -eq 4 ]; then
      echo "$G_OS6_4_FILE"
    fi
    if [ "$bootline" -eq 5 ]; then
      echo "$G_OS6_5_FILE"
    fi
    if [ "$bootline" -eq 6 ]; then
      echo "$G_OS6_6_FILE"
    fi
  fi

  return 0
}


## Draw kernel menu and wait for kernel selection
second_level_menu()
{
  callmode=$1
  selection=0
  ret=1

  if [ "$callmode" == "OS1" ]; then
    IFILE="mui1"
    LASTFRAME="$ANIM_M1_COUNT"
    if [ "$G_OS1_AUTOBOOT" -ne 0 -a "$G_OS1_AUTOLOCATION" == "" ]; then
      logger "Autobooting OS1 with kernel line $G_OS1_AUTOBOOT"
      selection=$(get_kernel_line $callmode $G_OS1_AUTOBOOT)
      echo -e "$selection"
      return 0
    fi
  fi
  if [ "$callmode" == "OS2" ]; then
    IFILE="mui2"
    LASTFRAME="$ANIM_M2_COUNT"
    if [ "$G_OS2_AUTOBOOT" -ne 0 -a "$G_OS2_AUTOLOCATION" == "" ]; then
      logger "Autobooting OS2 with kernel line $G_OS2_AUTOBOOT"
      selection=$(get_kernel_line $callmode $G_OS2_AUTOBOOT)
      echo -e "$selection"
      return 0
    fi
  fi
  if [ "$callmode" == "OS3" ]; then
    IFILE="mui3"
    LASTFRAME="$ANIM_M3_COUNT"
    if [ "$G_OS3_AUTOBOOT" -ne 0 -a "$G_OS3_AUTOLOCATION" == "" ]; then
      logger "Autobooting OS3 with kernel line $G_OS3_AUTOBOOT"
      selection=$(get_kernel_line $callmode $G_OS3_AUTOBOOT)
      echo -e "$selection"
      return 0
    fi
  fi
  if [ "$callmode" == "toolsmenu" ]; then
    IFILE="mui4"
    LASTFRAME="$ANIM_M4_COUNT"
  fi
  if [ "$callmode" == "OS4" ]; then
    IFILE="mui5"
    LASTFRAME="$ANIM_M5_COUNT"
    if [ "$G_OS4_AUTOBOOT" -ne 0 -a "$G_OS4_AUTOLOCATION" == "" ]; then
      logger "Autobooting OS4 with kernel line $G_OS4_AUTOBOOT"
      selection=$(get_kernel_line $callmode $G_OS4_AUTOBOOT)
      echo -e "$selection"
      return 0
    fi
  fi
  if [ "$callmode" == "OS5" ]; then
    IFILE="mui6"
    LASTFRAME="$ANIM_M6_COUNT"
    if [ "$G_OS5_AUTOBOOT" -ne 0 -a "$G_OS5_AUTOLOCATION" == "" ]; then
      logger "Autobooting OS5 with kernel line $G_OS5_AUTOBOOT"
      selection=$(get_kernel_line $callmode $G_OS5_AUTOBOOT)
      echo -e "$selection"
      return 0
    fi
  fi
  if [ "$callmode" == "OS6" ]; then
    IFILE="mui7"
    LASTFRAME="$ANIM_M7_COUNT"
    if [ "$G_OS6_AUTOBOOT" -ne 0 -a "$G_OS6_AUTOLOCATION" == "" ]; then
      logger "Autobooting OS6 with kernel line $G_OS6_AUTOBOOT"
      selection=$(get_kernel_line $callmode $G_OS6_AUTOBOOT)
      echo -e "$selection"
      return 0
    fi
  fi
  if [ "$callmode" == "info" ]; then
    IFILE="mui8"
    LASTFRAME="$ANIM_M8_COUNT"
  fi

  while [ $FRAMENUM -lt $LASTFRAME ] ; do
    let "FRAMENUM+=1"
    IND=$(printindex $FRAMENUM)
    $SHOWPNG "$IMAGEBASE/${IFILE}_$IND.png" > /dev/null
  done
  if [ "$callmode" == "OS1" ]; then
    if [ "$G_OS1_AUTOLOCATION" == "" ]; then
      logger "Drawing second level menu items for OS1"
      items=$(draw_kernel_list $callmode "0x001200" 0)
      selection=$(get_menuitem $callmode $items)
      ret=$?
    else
      logger "Autobuilding second level menu items for OS1"
      items=$(draw_kernel_autolist "$G_OS1_AUTOLOCATION" "0x001200" 0)
      selection=$(get_autolist_menuitem "$G_OS1_AUTOLOCATION")
      ret=$?
    fi
  fi
  if [ "$callmode" == "OS2" ]; then
    if [ "$G_OS2_AUTOLOCATION" == "" ]; then
      logger "Drawing second level menu items for OS2"
      items=$(draw_kernel_list $callmode "0x001200" 0)
      selection=$(get_menuitem $callmode $items)
      ret=$?
    else
      logger "Autobuilding second level menu items for OS2"
      items=$(draw_kernel_autolist "$G_OS2_AUTOLOCATION" "0x001200" 0)
      selection=$(get_autolist_menuitem "$G_OS2_AUTOLOCATION")
      ret=$?
    fi
  fi
  if [ "$callmode" == "OS3" ]; then
    if [ "$G_OS3_AUTOLOCATION" == "" ]; then
      logger "Drawing second level menu items for OS3"
      items=$(draw_kernel_list $callmode "0x001200" 0)
      selection=$(get_menuitem $callmode $items)
      ret=$?
    else
      logger "Autobuilding second level menu items for OS3"
      items=$(draw_kernel_autolist "$G_OS3_AUTOLOCATION" "0x001200" 0)
      selection=$(get_autolist_menuitem "$G_OS3_AUTOLOCATION")
      ret=$?
    fi
  fi
  if [ "$callmode" == "OS4" ]; then
    if [ "$G_OS4_AUTOLOCATION" == "" ]; then
      logger "Drawing second level menu items for OS4"
      items=$(draw_kernel_list $callmode "0x001200" 0)
      selection=$(get_menuitem $callmode $items)
      ret=$?
    else
      logger "Autobuilding second level menu items for OS4"
      items=$(draw_kernel_autolist "$G_OS4_AUTOLOCATION" "0x001200" 0)
      selection=$(get_autolist_menuitem "$G_OS4_AUTOLOCATION")
      ret=$?
    fi
  fi
  if [ "$callmode" == "OS5" ]; then
    if [ "$G_OS5_AUTOLOCATION" == "" ]; then
      logger "Drawing second level menu items for OS5"
      items=$(draw_kernel_list $callmode "0x001200" 0)
      selection=$(get_menuitem $callmode $items)
      ret=$?
    else
      logger "Autobuilding second level menu items for OS5"
      items=$(draw_kernel_autolist "$G_OS5_AUTOLOCATION" "0x001200" 0)
      selection=$(get_autolist_menuitem "$G_OS5_AUTOLOCATION")
      ret=$?
    fi
  fi
  if [ "$callmode" == "OS6" ]; then
    if [ "$G_OS6_AUTOLOCATION" == "" ]; then
      logger "Drawing second level menu items for OS6"
      items=$(draw_kernel_list $callmode "0x001200" 0)
      selection=$(get_menuitem $callmode $items)
      ret=$?
    else
      logger "Autobuilding second level menu items for OS6"
      items=$(draw_kernel_autolist "$G_OS6_AUTOLOCATION" "0x001200" 0)
      selection=$(get_autolist_menuitem "$G_OS6_AUTOLOCATION")
      ret=$?
    fi
  fi
  if [ "$callmode" == "toolsmenu" ]; then
    logger "Drawing second level menu items for Tools menu"
    # Here goes all kinds of random tools, like the stuff of backupmenu etc...
    # This just gets the "back" button press currently:
    selection=$(get_menuitem $callmode 0)
    ret=1
  fi 
  if [ "$callmode" == "info" ]; then
    logger "Drawing second level menu items for Info menu"
    # no need to draw anything for info, just get the "back" button press
    selection=$(get_menuitem $callmode 0)
    ret=1
  fi
  while [ $FRAMENUM -gt 1 ] ; do
    let "FRAMENUM-=1"
    IND=$(printindex $FRAMENUM)
    $SHOWPNG "$IMAGEBASE/${IFILE}_$IND.png" > /dev/null
  done

  # output the selected menuline, or 0 on "back" button press
  echo -e "$selection"

  return $ret
}


## Get OS selection in main menu
get_selection()
{
  SELECTED_OS=0
  SELECTED_KERNEL=0
  selection=$($EVTAP -t /dev/input/$touchdevice -m $TOPMAP -d 200 -s)
  ret=$?
  if [ "$ret" == "1" ]; then
    logger "Selected second level menu for OS1"
    bounce_icon "OS1"
    SELECTED_OS=$ret
    SELECTED_KERNEL=$(second_level_menu "OS1")
    ret=$?
  fi
  if [ "$ret" == "2" ]; then
    logger "Selected second level menu for OS2"
    bounce_icon "OS2"
    SELECTED_OS=$ret
    SELECTED_KERNEL=$(second_level_menu "OS2")
    ret=$?
  fi
  if [ "$ret" == "3" ]; then
    logger "Selected second level menu for OS3"
    bounce_icon "OS3"
    SELECTED_OS=$ret
    SELECTED_KERNEL=$(second_level_menu "OS3")
    ret=$?
  fi
  if [ "$ret" == "4" ]; then
    logger "Selected second level menu for OS4"
    bounce_icon "OS4"
    SELECTED_OS=$ret
    SELECTED_KERNEL=$(second_level_menu "OS4")
    ret=$?
  fi
  if [ "$ret" == "5" ]; then
    logger "Selected second level menu for OS5"
    bounce_icon "OS5"
    SELECTED_OS=$ret
    SELECTED_KERNEL=$(second_level_menu "OS5")
    ret=$?
  fi
  if [ "$ret" == "6" ]; then
    logger "Selected second level menu for OS6"
    bounce_icon "OS6"
    SELECTED_OS=$ret
    SELECTED_KERNEL=$(second_level_menu "OS6")
    ret=$?
  fi
  if [ "$ret" == "7" ]; then
    logger "Selected second level menu for Tools"
    bounce_icon "Toolsmenu"
    SELECTED_OS=0
    SELECTED_KERNEL=0
    second_level_menu "toolsmenu"
    ret=1
  fi
  if [ "$ret" == "8" ]; then
    logger "Selected second level menu for Info"
    bounce_icon "Info"
    SELECTED_OS=0
    SELECTED_KERNEL=0
    second_level_menu "info"
    ret=1
  fi
  if [ "$ret" == "255" ]; then
    SELECTED_OS=255
    SELECTED_KERNEL=0
  fi
  if [ "$ret" == "254" ]; then
    SELECTED_OS=255
    SELECTED_KERNEL=0
  fi
  if [ "$ret" == "1" ]; then
    SELECTED_OS=0
    SELECTED_KERNEL=0
  fi

  echo -e "$SELECTED_KERNEL"
  return "$SELECTED_OS"
}


## This is called repeatedly until a valid selection has been made or in case a timeout occurs without
## any user action occurring
main_menu()
{
  SELECTED_OS=0
  SELECTED_KERNEL=0
  if [ "$G_MENU_TIMEOUT" == "1" -a "$FIRST_SELECTION_DONE" == "0" ]; then
    FIRST_SELECTION_DONE=1
    NO_USERINPUT=1
    ii=49
    LIMIT=1
    yy=480
    while [ "$LIMIT" -le "$ii" ]; do
      let "ii-=1"
      let "yy=yy-10"
      $TEXT2SCREEN -t "x" -s 1 -x 840 -y $yy -T 0xffffff -B 0xffffff
      SELECTED_KERNEL=$(get_selection)
      SELECTED_OS=$?
      if [ "$SELECTED_OS" != "255" ]; then
         NO_USERINPUT=0
         break;
      fi
    done
    if [ "$NO_USERINPUT" == "1" ]; then
      # Timeout occured, no user interaction whatsoever. Boot to default OS/Kernel
      load_default_os
    fi
  else
    SELECTED_KERNEL=$(get_selection)
    SELECTED_OS=$?
  fi
  if [ "$SELECTED_OS" == "0" -o "$SELECTED_KERNEL" == "0" ]; then
    # No boot selection, return to make another round
    return
  fi

  # There was some valid selection because we got to this point
  if [ "$SELECTED_OS" == "1" ]; then
    load_OS1 $SELECTED_KERNEL
  fi
  if [ "$SELECTED_OS" == "2" ]; then
    load_OS2 $SELECTED_KERNEL
  fi
  if [ "$SELECTED_OS" == "3" ]; then
    load_OS3 $SELECTED_KERNEL
  fi
  if [ "$SELECTED_OS" == "4" ]; then
    load_OS4 $SELECTED_KERNEL
  fi
  if [ "$SELECTED_OS" == "5" ]; then
    load_OS5 $SELECTED_KERNEL
  fi
  if [ "$SELECTED_OS" == "6" ]; then
    load_OS6 $SELECTED_KERNEL
  fi

  # Should not ever reach this point...
  logger "Failed OS selection in main_menu!"
  exit 1;
}


## The script starts executing here.

## Show the boot menu
logger "Started animated OS selection menu"
menu_fadein
$SHOWPNG "$IMAGEBASE/topmenu.png" > /dev/null

## This is the main loop. If any selection is executed, the script will bail out inside the main menu.
FIRST_SELECTION_DONE=0
while [ 1 -gt 0 ]; do
  main_menu $FIRST_SELECTION_DONE
done

## we will never get here

