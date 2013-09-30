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


## Preload the kexec() with Harmattan kernel, set boot params to /dev/mmcblk2 and /sbin/preinit_harmattan
load_harmattan()
{
  logger "Selecting Harmattan OS"
  if [ -r "$G_HARMATTAN_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_HARMATTAN_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_HARMATTAN_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_HARMATTAN_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_HARMATTAN_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_HARMATTAN_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_HARMATTAN_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_HARMATTAN_INIT_CMDLINE_APPENDS"
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default Harmattan kernel $G_DEFAULT_KERNEL"
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


## Preload the kexec() with Nitdroid kernel, set boot params to /dev/mmcblk2 and /sbin/preinit_nitdtoid
load_nitdroid()
{
  logger "Selecting Nitdroid OS"
  if [ -r "$G_NITDROID_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_NITDROID_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_NITDROID_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_NITDROID_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_NITDROID_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_NITDROID_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_NITDROID_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_NITDROID_INIT_CMDLINE_APPENDS"
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default Nitdroid kernel $G_DEFAULT_KERNEL"
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


## Preload the kexec() with Nemo kernel, set boot partiton to /dev/mmcblk4
load_nemo()
{
  logger "Selecting Nemo OS"
  if [ -r "$G_NEMO_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_NEMO_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_NEMO_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_NEMO_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_NEMO_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_NEMO_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_NEMO_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_NEMO_INIT_CMDLINE_APPENDS"
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default Nemo kernel $G_DEFAULT_KERNEL"
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


## Preload the kexec() with FirefoxOS kernel, set boot partiton to whatever given
load_firefox()
{
  logger "Selecting FirefoxOS"
  if [ -r "$G_FIREFOX_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_FIREFOX_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_FIREFOX_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_FIREFOX_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_FIREFOX_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_FIREFOX_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_FIREFOX_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_FIREFOX_INIT_CMDLINE_APPENDS"
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default FirefoxOS kernel $G_DEFAULT_KERNEL"
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


## Preload the kexec() with Ubuntu kernel, set boot partiton to whatever given
load_ubuntu()
{
  logger "Selecting Ubuntu OS"
  if [ -r "$G_UBUNTU_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_UBUNTU_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_UBUNTU_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_UBUNTU_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_UBUNTU_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_UBUNTU_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_UBUNTU_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_UBUNTU_INIT_CMDLINE_APPENDS"
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default Ubuntu kernel $G_DEFAULT_KERNEL"
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


## Preload the kexec() with SailfishOS kernel, set boot partiton to whatever given
load_sailfish()
{
  logger "Selecting SailfishOS"
  if [ -r "$G_SAILFISH_INIT_CMDLINE_FILE" ]; then
    logger "Loading CMDLINE override from $G_SAILFISH_INIT_CMDLINE_FILE"
    O_COMMAND_LINE_OVERRRIDE=$(cat "$G_SAILFISH_INIT_CMDLINE_FILE")
    F_COMMAND_LINE="\"$O_COMMAND_LINE_OVERRRIDE\""
  else
    TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_SAILFISH_PARTITION/")
    TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_SAILFISH_INITSCRIPT)/")
    F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
    if [ ! -z "$G_SAILFISH_INIT_CMDLINE_APPENDS" ]; then 
      logger "Appending options to CMDLINE: $G_SAILFISH_INIT_CMDLINE_APPENDS"
      TMP_COMMAND_LINE3=$(echo "$TMP_COMMAND_LINE2 $G_SAILFISH_INIT_CMDLINE_APPENDS"
      F_COMMAND_LINE="\"$TMP_COMMAND_LINE3\""
    fi
  fi
  if [ -r "$G_DEFAULT_KERNEL" ]; then
    logger "Cannot load default SailfishOS kernel $G_DEFAULT_KERNEL"
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



# Load up the default OS. Usually this is Harmattan but what do you know...?
#
if [ "$G_DEFAULT_OS" == "Harmattan" ]; then
  load_harmattan
fi
if [ "$G_DEFAULT_OS" == "Nitdroid" ]; then
  load_nitdroid
fi
if [ "$G_DEFAULT_OS" == "Nemo" ]; then
  load_nemo
fi
if [ "$G_DEFAULT_OS" == "Firefox" ]; then
  load_firefox
fi
if [ "$G_DEFAULT_OS" == "Ubuntu" ]; then
  load_ubuntu
fi
if [ "$G_DEFAULT_OS" == "Sailfish" ]; then
  load_sailfish
fi
