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


## Preload the kexec() with default kernel, set boot params to /dev/mmcblk2 and /sbin/preinit_harmattan
load_harmattan()
{
  logger "Selecting Harmattan OS, loading defaul kernel $G_DEFAULT_KERNEL"
  TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_HARMATTAN_PARTITION/")
  TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_HARMATTAN_INITSCRIPT)/")
  F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
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


## Preload the kexec() with Nitdroid  kernel, set boot params to /dev/mmcblk2 and /sbin/preinit_nitdtoid
load_nitdroid()
{
  logger "Selecting Nitdroid OS, loading defaul kernel $G_DEFAULT_KERNEL"
  TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_NITDROID_PARTITION/")
  TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_NITDROID_INITSCRIPT)/")
  F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
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
  logger "Selecting Nemo OS, loading defaul kernel $G_DEFAULT_KERNEL"
  TMP_COMMAND_LINE1=$(echo "$O_COMMAND_LINE" | sed -e "s/root\=\/dev\/mmcblk0p2/root\=\/dev\/mmcblk0p$G_NEMO_PARTITION/")
  TMP_COMMAND_LINE2=$(echo "$TMP_COMMAND_LINE1" | sed -e "s/ init\=\/sbin\/preinit/init\=$(echo $G_NEMO_INITSCRIPT)/")
  F_COMMAND_LINE="\"$TMP_COMMAND_LINE2\""
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
