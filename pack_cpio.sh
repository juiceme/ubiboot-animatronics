#!/bin/bash

##
## This script is used to prepare the menu animation sequences for N9 ubiboot
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


TEMPDIR="./temp"
BOOTDIR="$TEMPDIR/boot"
MENUDIR="$BOOTDIR/menu"
CPIOFILE="ubiboot-02.menus.cpio"
WORKDIR=$(pwd)

decompress_and_pack_cpio()
{
  rm -rf $TEMPDIR
  mkdir -p $MENUDIR
  ln -s /mnt/2 $BOOTDIR/Harmattan
  ln -s /mnt/2 $BOOTDIR/Nitdroid
  ln -s /mnt/4 $BOOTDIR/Nemo
  $TAR -xvf $1 -C $MENUDIR
  if [ $? -ne 0 ]; then
    echo
    echo "Error processing tarfile!"
    echo
    exit 1;
  fi
  
  cd $TEMPDIR
  find . | $CPIO -H newc -o > $WORKDIR/$CPIOFILE
  cd $WORKDIR

  echo
  echo "All Done!"
  exit 0;
}

if [ ! -z "$1" ]; then
  if [ "$1" == "--help" ]; then
    echo
    echo "pack_cpio.sh ver. 0.1"
    echo
    echo "Parameters:"
    echo "  --help               This screen"
    echo "  --clean              Delete all generated files"
    echo "  --create <tarfile>   Pack the input tarfile into cpio"
    echo
    exit 0;
  fi
  if [ "$1" == "--clean" ]; then
    rm -rf $TEMPDIR > /dev/null 2>&1
    exit 0;
  fi
  if [ "$1" == "--create" ]; then
    if [ -z "$2" ]; then
      echo
      echo "You need to specify source tarfile"
      echo
      exit 1;
    fi
    TAR=$(which tar)
    if [ $? -ne 0 ]; then
      echo
      echo "You need the tar archiving utility to run this script"
      echo
      exit 1;  
    fi
    CPIO=$(which cpio)
    if [ $? -ne 0 ]; then
      echo
      echo "You need the cpio archiving utility to run this script"
      echo
      exit 1;
    fi
    if [ ! -r $2 ]; then
      echo
      echo "Archive $2 does not exist!"
      echo
      exit 1;
    fi
    decompress_and_pack_cpio $2
  fi
fi

echo
echo "You need to specify an option to call this script"
echo
exit 1;

