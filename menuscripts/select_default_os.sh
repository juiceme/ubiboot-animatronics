#!/bin/sh

##
## This script is used to load the default OS & kernel image for later booting.
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


## This is the original command line given by NOLO to the 1st stage loader:
O_COMMAND_LINE=$(cat /proc/original_cmdline)


## Preload the kexec() with OS1 kernel, and set boot command line parameters
load_OS1()
{
  logger "Selecting $G_OS1_NAME OS"
  if [ -r "$G_OS1_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS1_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS1_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS1_PARTITION/")
    if [ ! -z "$G_OS1_INITSCRIPT" ]; then
		TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS1_INITSCRIPT)/")
	else
		TMP_COMMAND_LINE2=$TMP_COMMAND_LINE1
    fi
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS1_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS1_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS1_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default $G_OS1_NAME kernel $G_DEFAULT_KERNEL"
    exit 1
  fi
  logger "Loading default kernel $G_DEFAULT_KERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $G_DEFAULT_KERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## Preload the kexec() with OS2 kernel, and set boot command line parameters
load_OS2()
{
  logger "Selecting $G_OS2_NAME OS"
  if [ -r "$G_OS2_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS2_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS2_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS2_PARTITION/")
    if [ ! -z "$G_OS2_INITSCRIPT" ]; then
		TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS2_INITSCRIPT)/")
	else
		TMP_COMMAND_LINE2=$TMP_COMMAND_LINE1
    fi
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS2_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS2_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS2_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default $G_OS2_NAME kernel $G_DEFAULT_KERNEL"
    exit 1
  fi
  logger "Loading default kernel $G_DEFAULT_KERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $G_DEFAULT_KERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## Preload the kexec() with OS3 kernel, and set boot command line parameters
load_OS3()
{
  logger "Selecting $G_OS3_NAME OS"
  if [ -r "$G_OS3_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS3_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS3_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS3_PARTITION/")
    if [ ! -z "$G_OS3_INITSCRIPT" ]; then
		TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS3_INITSCRIPT)/")
	else
		TMP_COMMAND_LINE2=$TMP_COMMAND_LINE1
    fi
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS3_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS3_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS3_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default $G_OS3_NAME kernel $G_DEFAULT_KERNEL"
    exit 1
  fi
  logger "Loading default kernel $G_DEFAULT_KERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $G_DEFAULT_KERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## Preload the kexec() with OS4 kernel, and set boot command line parameters
load_OS4()
{
  logger "Selecting $G_OS4_NAME OS"
  if [ -r "$G_OS4_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS4_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS4_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS4_PARTITION/")
    if [ ! -z "$G_OS4_INITSCRIPT" ]; then
		TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS4_INITSCRIPT)/")
	else
		TMP_COMMAND_LINE2=$TMP_COMMAND_LINE1
    fi
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS4_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS4_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS4_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default $G_OS4_NAME kernel $G_DEFAULT_KERNEL"
    exit 1
  fi
  logger "Loading default kernel $G_DEFAULT_KERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $G_DEFAULT_KERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## Preload the kexec() with OS5 kernel, and set boot command line parameters
load_OS5()
{
  logger "Selecting $G_OS5_NAME OS"
  if [ -r "$G_OS5_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS5_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS5_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS5_PARTITION/")
    if [ ! -z "$G_OS5_INITSCRIPT" ]; then
		TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS5_INITSCRIPT)/")
	else
		TMP_COMMAND_LINE2=$TMP_COMMAND_LINE1
    fi
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS5_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS5_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS5_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default $G_OS5_NAME kernel $G_DEFAULT_KERNEL"
    exit 1
  fi
  logger "Loading default kernel $G_DEFAULT_KERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $G_DEFAULT_KERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


## Preload the kexec() with OS6 kernel, and set boot command line parameters
load_OS6()
{
  logger "Selecting $G_OS6_NAME OS"
  if [ -r "$G_OS6_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_OS6_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_OS6_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_OS6_PARTITION/")
    if [ ! -z "$G_OS6_INITSCRIPT" ]; then
		TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_OS6_INITSCRIPT)/")
	else
		TMP_COMMAND_LINE2=$TMP_COMMAND_LINE1
    fi
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_OS6_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_OS6_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_OS6_INIT_CMDLINE_APPENDS")
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ ! -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default $G_OS6_NAME kernel $G_DEFAULT_KERNEL"
    exit 1
  fi
  logger "Loading default kernel $G_DEFAULT_KERNEL"
  eval "kexec -l --type=zImage --command-line=$F_COMMAND_LINE $G_DEFAULT_KERNEL"
  ret=$?
  if [ $ret -eq 0 ]; then
    logger "kexec_load() successful"
    exit 0
  else
    logger "kexec_load() returned $ret"
    exit 1
  fi
}


# Load up the default OS. Usually this is OS2 but what do you know...?
#
if [ "$G_DEFAULT_OS" == "OS1" ]; then
  load_OS1
fi
if [ "$G_DEFAULT_OS" == "OS2" ]; then
  load_OS2
fi
if [ "$G_DEFAULT_OS" == "OS3" ]; then
  load_OS3
fi
if [ "$G_DEFAULT_OS" == "OS4" ]; then
  load_OS4
fi
if [ "$G_DEFAULT_OS" == "OS5" ]; then
  load_OS5
fi
if [ "$G_DEFAULT_OS" == "OS6" ]; then
  load_OS6
fi
