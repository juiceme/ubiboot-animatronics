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


## Preload the kexec() with Harmattan kernel, set boot params to /dev/mmcblk2 and /sbin/preinit_harmattan
load_harmattan()
{
  BOOTKERNEL=$1
  logger "Selecting Harmattan OS, running kernel $BOOTKERNEL"
  menu_fadeout
  if [ x$(readlink /boot/Harmattan) != x/mnt/$G_HARMATTAN_PARTITION ]; then
    rm /boot/Harmattan
    ln -s /mnt/$G_HARMATTAN_PARTITION /boot/Harmattan
  fi
  TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_HARMATTAN_PARTITION/")
  TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_HARMATTAN_INITSCRIPT)/")
  F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $BOOTKERNEL"
  ret=$?
  if [ $? -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## Preload the kexec() with Nitdroid  kernel, set boot params to /dev/mmcblk2 and /sbin/preinit_nitdtoid
load_nitdroid()
{
  BOOTKERNEL=$1
  logger "Selecting Nitdroid OS, running kernel $BOOTKERNEL"
  menu_fadeout
  if [ x$(readlink /boot/Nitdroid) != x/mnt/$G_NITDROID_PARTITION ]; then
    rm /boot/Nitdroid
    ln -s /mnt/$G_NITDROID_PARTITION /boot/Nitdroid
  fi
  TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_NITDROID_PARTITION/")
  TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_NITDROID_INITSCRIPT)/")
  F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
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


## Preload the kexec() with Nemo kernel, set boot partiton to /dev/mmcblk4
load_nemo()
{
  BOOTKERNEL=$1
  logger "Selecting Nemo OS, running kernel $BOOTKERNEL"
  menu_fadeout
  if [ x$(readlink /boot/Nemo) != x/mnt/$G_NEMO_PARTITION ]; then
    rm /boot/Nemo
    ln -s /mnt/$G_NEMO_PARTITION /boot/Nemo
  fi
  TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_NEMO_PARTITION/")
  TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_NEMO_INITSCRIPT)/")
  F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $BOOTKERNEL"
  ret=$?
  if [ $? -eq 0 ]; then
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
  if [ "$G_DEFAULT_OS" == "Nitdroid" ]; then
    load_nitdroid "$G_DEFAULT_KERNEL"
  fi
  if [ "$G_DEFAULT_OS" == "Harmattan" ]; then
    load_harmattan "$G_DEFAULT_KERNEL"
  fi
  if [ "$G_DEFAULT_OS" == "Nemo" ]; then
    load_nemo "$G_DEFAULT_KERNEL"
  fi

  ## If we get here something is wrong
  logger "Failed Selecting default OS!"
  exit 1;
}


## Main menu icon clicked, so make it bounce a bit
bounce_icon()
{
  if [ "$1" == "Nitdroid" ]; then
    IFILE="pd"
  fi
  if [ "$1" == "Harmattan" ]; then
    IFILE="ph"
  fi
  if [ "$1" == "Nemo" ]; then
    IFILE="pn"
  fi
  if [ "$1" == "Backupmenu" ]; then
    IFILE="pb"
  fi
  if [ "$1" == "Info" ]; then
    IFILE="pi"
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
  if [ $maplines -gt 4 ]; then
    mapfile_line_6=$(echo -e "$X6B 0 $X6E 480 6 65 $7")
  else
     mapfile_line_6=$(echo -e "# mapfile_line_6")
  fi
  mapfile_tailer=$(echo -e "#*750 164 795 318 0 65 BACK*")
  echo -e "$mapfile_header*$mapfile_line_1*$mapfile_line_2*$mapfile_line_3*$mapfile_line_4*$mapfile_line_5*$mapfile_line_6*$mapfile_tailer"
}


## Output the kernel list to screen. If highlight is specified, the given line is highlighted and the
## rest are dimmed, otherwice use the given colour for all lines.
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
  if [ "$mode" == "nitdroid" ]; then
    if [ $G_NITDROID_NUM -gt 6 ]; then
      G_NITDROID_NUM=6
    fi
    if [ $G_NITDROID_NUM -ge 1 -a "$G_NITDROID_1_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_NITDROID_1_LABEL" -T "$textcolor"
      if [ "$highlighted" == "1" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_NITDROID_1_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_NITDROID_NUM -ge 2 -a "$G_NITDROID_2_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_NITDROID_2_LABEL" -T "$textcolor"
      if [ "$highlighted" == "2" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_NITDROID_2_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_NITDROID_NUM -ge 3 -a "$G_NITDROID_3_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_NITDROID_3_LABEL" -T "$textcolor"
      if [ "$highlighted" == "3" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_NITDROID_3_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_NITDROID_NUM -ge 4 -a "$G_NITDROID_4_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_NITDROID_4_LABEL" -T "$textcolor"
      if [ "$highlighted" == "4" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_NITDROID_4_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_NITDROID_NUM -ge 5 -a "$G_NITDROID_5_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_NITDROID_5_LABEL" -T "$textcolor"
      if [ "$highlighted" == "5" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_NITDROID_5_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_NITDROID_NUM -ge 6 -a "$G_NITDROID_6_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_NITDROID_6_LABEL" -T "$textcolor"
      if [ "$highlighted" == "6" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_NITDROID_6_LABEL" -T "$highcolor"
      fi
    fi
    echo $G_NITDROID_NUM
  fi

  if [ "$mode" == "harmattan" ]; then
    if [ $G_HARMATTAN_NUM -gt 6 ]; then
      G_HARMATTAN_NUM=6
    fi
    if [ $G_HARMATTAN_NUM -ge 1 -a "$G_HARMATTAN_1_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_HARMATTAN_1_LABEL" -T "$textcolor"
      if [ "$highlighted" == "1" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_HARMATTAN_1_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_HARMATTAN_NUM -ge 2 -a "$G_HARMATTAN_2_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_HARMATTAN_2_LABEL" -T "$textcolor"
      if [ "$highlighted" == "2" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_HARMATTAN_2_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_HARMATTAN_NUM -ge 3 -a "$G_HARMATTAN_3_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_HARMATTAN_3_LABEL" -T "$textcolor"
      if [ "$highlighted" == "3" ]; then
         $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_HARMATTAN_3_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_HARMATTAN_NUM -ge 4 -a "$G_HARMATTAN_4_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_HARMATTAN_4_LABEL" -T "$textcolor"
      if [ "$highlighted" == "4" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_HARMATTAN_4_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_HARMATTAN_NUM -ge 5 -a "$G_HARMATTAN_5_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_HARMATTAN_5_LABEL" -T "$textcolor"
      if [ "$highlighted" == "5" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_HARMATTAN_5_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_HARMATTAN_NUM -ge 6 -a "$G_HARMATTAN_6_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_HARMATTAN_6_LABEL" -T "$textcolor"
      if [ "$highlighted" == "6" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_HARMATTAN_6_LABEL" -T "$highcolor"
      fi
    fi
    echo $G_HARMATTAN_NUM
  fi

  if [ "$mode" == "nemo" ]; then
    if [ $G_NEMO_NUM -gt 6 ]; then
      G_NEMO_NUM=6
    fi
    if [ $G_NEMO_NUM -ge 1 -a "$G_NEMO_1_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_NEMO_1_LABEL" -T "$textcolor"
      if [ "$highlighted" == "1" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X1 -t "$G_NEMO_1_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_NEMO_NUM -ge 2 -a "$G_NEMO_2_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_NEMO_2_LABEL" -T "$textcolor"
      if [ "$highlighted" == "2" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X2 -t "$G_NEMO_2_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_NEMO_NUM -ge 3 -a "$G_NEMO_3_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_NEMO_3_LABEL" -T "$textcolor"
      if [ "$highlighted" == "3" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X3 -t "$G_NEMO_3_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_NEMO_NUM -ge 4 -a "$G_NEMO_4_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_NEMO_4_LABEL" -T "$textcolor"
      if [ "$highlighted" == "4" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X4 -t "$G_NEMO_4_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_NEMO_NUM -ge 5 -a "$G_NEMO_5_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_NEMO_5_LABEL" -T "$textcolor"
      if [ "$highlighted" == "5" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X5 -t "$G_NEMO_5_LABEL" -T "$highcolor"
      fi
    fi
    if [ $G_NEMO_NUM -ge 6 -a "$G_NEMO_6_LABEL" != "" ]; then
      $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_NEMO_6_LABEL" -T "$textcolor"
      if [ "$highlighted" == "6" ]; then
        $TEXT2SCREEN -p -s 2 -x 0 -y $X6 -t "$G_NEMO_6_LABEL" -T "$highcolor"
      fi
    fi
    echo $G_NEMO_NUM
  fi

  return "0"
}


## Use a on-the-fly mapfile with evtap to get the selected kernel line
get_menuitem()
{
  mode=$1
  menulines=$2

  if [ "$mode" == "nitdroid" ]; then
    maplines=$(generate_temporary_mapfile $menulines "$G_NITDROID_1_FILE" "$G_NITDROID_2_FILE" "$G_NITDROID_3_FILE" "$G_NITDROID_4_FILE" "$G_NITDROID_5_FILE" "$G_NITDROID_6_FILE")
  fi
  if [ "$mode" == "harmattan" ]; then
    maplines=$(generate_temporary_mapfile $menulines "$G_HARMATTAN_1_FILE" "$G_HARMATTAN_2_FILE" "$G_HARMATTAN_3_FILE" "$G_HARMATTAN_4_FILE" "$G_HARMATTAN_5_FILE" "$G_HARMATTAN_6_FILE")
  fi
  if [ "$mode" == "nemo" ]; then
    maplines=$(generate_temporary_mapfile $menulines "$G_NEMO_1_FILE" "$G_NEMO_2_FILE" "$G_NEMO_3_FILE" "$G_NEMO_4_FILE" "$G_NEMO_5_FILE" "$G_NEMO_6_FILE")
  fi
  if [ "$mode" == "backupmenu" ]; then
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

# used to get the correct kernel to autoboot to
get_kernel_line()
{
  mode=$1
  bootline=$2

  if [ "$mode" == "nitdroid" ]; then
    if [ "$bootline" -eq 1 ]; then
      echo "$G_NITDROID_1_FILE"
    fi
    if [ "$bootline" -eq 2 ]; then
      echo "$G_NITDROID_2_FILE"
    fi
    if [ "$bootline" -eq 3 ]; then
      echo "$G_NITDROID_3_FILE"
    fi
    if [ "$bootline" -eq 4 ]; then
      echo "$G_NITDROID_4_FILE"
    fi
    if [ "$bootline" -eq 5 ]; then
      echo "$G_NITDROID_5_FILE"
    fi
    if [ "$bootline" -eq 6 ]; then
      echo "$G_NITDROID_7_FILE"
    fi
  fi
  if [ "$mode" == "harmattan" ]; then
    if [ "$bootline" -eq 1 ]; then
      echo "$G_HARMATTAN_1_FILE"
    fi
    if [ "$bootline" -eq 2 ]; then
      echo "$G_HARMATTAN_2_FILE"
    fi
    if [ "$bootline" -eq 3 ]; then
      echo "$G_HARMATTAN_3_FILE"
    fi
    if [ "$bootline" -eq 4 ]; then
      echo "$G_HARMATTAN_4_FILE"
    fi
    if [ "$bootline" -eq 5 ]; then
      echo "$G_HARMATTAN_5_FILE"
    fi
    if [ "$bootline" -eq 6 ]; then
      echo "$G_HARMATTAN_6_FILE"
    fi
  fi
  if [ "$mode" == "nemo" ]; then
    if [ "$bootline" -eq 1 ]; then
      echo "$G_NEMO_1_FILE"
    fi
    if [ "$bootline" -eq 2 ]; then
      echo "$G_NEMO_2_FILE"
    fi
    if [ "$bootline" -eq 3 ]; then
      echo "$G_NEMO_3_FILE"
    fi
    if [ "$bootline" -eq 4 ]; then
      echo "$G_NEMO_4_FILE"
    fi
    if [ "$bootline" -eq 5 ]; then
      echo "$G_NEMO_5_FILE"
    fi
    if [ "$bootline" -eq 6 ]; then
      echo "$G_NEMO_6_FILE"
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

  if [ "$callmode" == "nitdroid" ]; then
    IFILE="md"
    LASTFRAME="$ANIM_MD_COUNT"
    if [ "$G_NITDROID_AUTOBOOT" -ne 0 ]; then
      selection=$(get_kernel_line $callmode $G_NITDROID_AUTOBOOT)
      echo -e "$selection"
      return 0
    fi
  fi
  if [ "$callmode" == "harmattan" ]; then
    IFILE="mh"
    LASTFRAME="$ANIM_MH_COUNT"
    if [ "$G_HARMATTAN_AUTOBOOT" -ne 0 ]; then
      selection=$(get_kernel_line $callmode $G_HARMATTAN_AUTOBOOT)
      echo -e "$selection"
      return 0
    fi
  fi
  if [ "$callmode" == "nemo" ]; then
    IFILE="mn"
    LASTFRAME="$ANIM_MN_COUNT"
    if [ "$G_NEMO_AUTOBOOT" -ne 0 ]; then
      selection=$(get_kernel_line $callmode $G_NEMO_AUTOBOOT)
      echo -e "$selection"
      return 0
    fi
  fi
  if [ "$callmode" == "backupmenu" ]; then
    IFILE="mb"
    LASTFRAME="$ANIM_MB_COUNT"
  fi
  if [ "$callmode" == "info" ]; then
    IFILE="mi"
    LASTFRAME="$ANIM_MI_COUNT"
  fi

  while [ $FRAMENUM -lt $LASTFRAME ] ; do
    let "FRAMENUM+=1"
    IND=$(printindex $FRAMENUM)
    $SHOWPNG "$IMAGEBASE/${IFILE}_$IND.png" > /dev/null
  done
  if [ "$callmode" == "nitdroid" ]; then
    items=$(draw_kernel_list $callmode "0x001200" 0)
    selection=$(get_menuitem $callmode $items)
    ret=$?
  fi
  if [ "$callmode" == "harmattan" ]; then
    items=$(draw_kernel_list $callmode "0x001200" 0)
    selection=$(get_menuitem $callmode $items)
    ret=$?
  fi
  if [ "$callmode" == "nemo" ]; then
    items=$(draw_kernel_list $callmode "0x001200" 0)
    selection=$(get_menuitem $callmode $items)
    ret=$?
  fi
  if [ "$callmode" == "info" ]; then
    # no need to draw anything for info, just get the "back" button press
    selection=$(get_menuitem $callmode 0)
    ret=1
  fi
  if [ "$callmode" == "backupmenu" ]; then
    # Here goes the stuff of backup menu.
    # This just gets the "back" button press currently:
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
    bounce_icon "Nitdroid"
    SELECTED_OS=$ret
    SELECTED_KERNEL=$(second_level_menu "nitdroid")
    ret=$?
  fi
  if [ "$ret" == "2" ]; then
    bounce_icon "Harmattan"
    SELECTED_OS=$ret
    SELECTED_KERNEL=$(second_level_menu "harmattan")
    ret=$?
  fi
  if [ "$ret" == "3" ]; then
    bounce_icon "Nemo"
    SELECTED_OS=$ret
    SELECTED_KERNEL=$(second_level_menu "nemo")
    ret=$?
  fi
  if [ "$ret" == "4" ]; then
    bounce_icon "Backupmenu"
    SELECTED_OS=0
    SELECTED_KERNEL=0
    second_level_menu "info"
    ret=1
  fi
  if [ "$ret" == "5" ]; then
    bounce_icon "Info"
    SELECTED_OS=0
    SELECTED_KERNEL=0
    second_level_menu "backupmenu"
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
    load_nitdroid $SELECTED_KERNEL
  fi
  if [ "$SELECTED_OS" == "2" ]; then
    load_harmattan $SELECTED_KERNEL
  fi
  if [ "$SELECTED_OS" == "3" ]; then
    load_nemo $SELECTED_KERNEL
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

