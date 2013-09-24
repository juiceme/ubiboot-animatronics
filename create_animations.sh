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


IBASE="./imagebase"
BUTTONIMAGE="$IBASE/backbutton.png"
OWNERPANEL="$IBASE/ownerpanel.png"

# there are 8 images, in 2 columns of 4
ICONIMAGE_1="$IBASE/nitdroid_200x200.png"
ICONIMAGE_2="$IBASE/meego_200x200.png"
ICONIMAGE_3="$IBASE/nemo_200x200.png"
ICONIMAGE_4="$IBASE/backupmenu_200x200.png"
ICONIMAGE_5="$IBASE/firefox_200x200.png"
ICONIMAGE_6="$IBASE/ubuntu_200x200.png"
ICONIMAGE_7="$IBASE/sailfish_200x200.png"
ICONIMAGE_8="$IBASE/info_200x200.png"

TEMPIMAGES="./temp"
FINIMAGES="./menu"
ANIMIMAGES="./menu/animation"
GENERATE_VIDEOS=0
VIDEOS="./debug"
CTRLFILE="$FINIMAGES/ctrl_animation.rc"

if [ ! -z "$1" ]; then
  if [ "$1" == "--help" ]; then
    echo
    echo "create_animations.sh ver. 0.2"
    echo
    echo "Parameters:"
    echo "  --help    This screen"
    echo "  --debug   Generate additional short .mpeg sequences from animations"
    echo "  --clean   Delete all generated files"
    echo
    exit 0;
  fi
  if [ "$1" == "--debug" ]; then
    AVCONV=$(which avconv)
    if [ $? -ne 0 ]; then
      echo
      echo "You need the Libav "avconv" utility to generate debug videos"
      echo
      exit 1;
    fi
    GENERATE_VIDEOS=1
  fi
  if [ "$1" == "--clean" ]; then
    rm -rf $TEMPIMAGES > /dev/null 2>&1
    rm -rf $FINIMAGES > /dev/null 2>&1
    rm -rf $VIDEOS > /dev/null 2>&1
    exit 0;
  fi
fi

TAR=$(which tar)
if [ $? -ne 0 ]; then
  echo
  echo "You need the tar archiving utility to run this script"
  echo
  exit 1;  
fi

CONVERT=$(which convert)
if [ $? -ne 0 ]; then
  echo
  echo "You need the ImageMagic "convert" utility to run this script"
  echo
  exit 1;  
fi


## use bc to calculate accurate values in script
calculate()
{
  echo $(bc <<< "scale = 10; $1")
}


## round the accurate value to integer
round()
{
  echo $(bc <<< "scale = 0; $1/1")
}


## helper to enumerate sequences correctly
printindex()
{
  if [ $1 -lt 10 ]; then
    echo "0$1"
  else
    echo "$1"
  fi
}


## clean up and prepare the image directories
echo "Setting up directories"
if [ ! -d $TEMPIMAGES ]; then
  echo "Creating $TEMPIMAGES directory..."
  mkdir $TEMPIMAGES
fi
if [ ! -d $FINIMAGES ]; then
  echo "Creating $FINIMAGES directory..."
  mkdir $FINIMAGES
fi
if [ ! -d $ANIMIMAGES ]; then
  echo "Creating $ANIMIMAGES directory..."
  mkdir $ANIMIMAGES
fi
if [ "$GENERATE_VIDEOS" == "1" ]; then
  if [ ! -d $VIDEOS ]; then
    echo "Creating $VIDEOS directory..."
    mkdir $VIDEOS
  fi
fi

rm -f $TEMPIMAGES/* > /dev/null 2>&1
rm -f $FINIMAGES/* > /dev/null 2>&1
rm -f $ANIMIMAGES/* > /dev/null 2>&1
rm -f $VIDEOS/* > /dev/null 2>&1
cp ./select_and_boot_os.sh $FINIMAGES
cp ./select_default_os.sh $FINIMAGES
cp ./select_os_animated.sh $FINIMAGES
cp ./animated_menu_top.map $FINIMAGES
cp ./test_animate.sh $FINIMAGES


## create the animated backbutton sequence
echo "Creating back button sequence..."
XS=54
YS=170
CI=0
while [ $XS -gt 3 ]; do
  let "CI+=1"
  let "XS-=2"
  YS=$(calculate $YS-6)
  echo -n "."
  $CONVERT -resize $YSx$XS $BUTTONIMAGE $TEMPIMAGES/bim_$CI.png
done

let "ANIM_BB_COUNT=CI+1"
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/bim_$ANIM_BB_COUNT.png

X1B=800
Y1B=325
DX=54
DY=170
CI=0
NI=$ANIM_BB_COUNT
echo
while [ $CI -lt $ANIM_BB_COUNT ]; do
  let "CI+=1"
  let "DX-=1"
  DY=$(calculate $DY-3)
  CXB=$(calculate $X1B-$DX)
  CYB=$(calculate $Y1B-$DY)
  let "NI-=1"
  INDF=$(printindex $NI)
  echo -n "[$CI] "
  $CONVERT -size 854x480 xc:black \
           -page +$CXB+$CYB $TEMPIMAGES/bim_$CI.png \
           -flatten $TEMPIMAGES/bom_$INDF.png
done


## create the fade in / fade out main menu sequence
echo
echo "Creating fade in/out sequence..."
XS=200
YS=200
CI=0
while [ $XS -gt 3 ]; do
  let "CI+=1"
  let "XS-=6"
  let "YS=XS"
  echo -n "."

#  $CONVERT -resize $YSx$XS $DROIDIMAGE $TEMPIMAGES/dim_$CI.png
#  $CONVERT -resize $YSx$XS $HARMIMAGE $TEMPIMAGES/him_$CI.png
#  $CONVERT -resize $YSx$XS $NEMOIMAGE $TEMPIMAGES/nim_$CI.png
#  $CONVERT -resize $YSx$XS $INFOIMAGE $TEMPIMAGES/iim_$CI.png
#  $CONVERT -resize $YSx$XS $BUMENUIMAGE $TEMPIMAGES/bim_$CI.png

  $CONVERT -resize $YSx$XS $ICONIMAGE_1 $TEMPIMAGES/iim1_$CI.png
  $CONVERT -resize $YSx$XS $ICONIMAGE_2 $TEMPIMAGES/iim2_$CI.png
  $CONVERT -resize $YSx$XS $ICONIMAGE_3 $TEMPIMAGES/iim3_$CI.png
  $CONVERT -resize $YSx$XS $ICONIMAGE_4 $TEMPIMAGES/iim4_$CI.png
  $CONVERT -resize $YSx$XS $ICONIMAGE_5 $TEMPIMAGES/iim5_$CI.png
  $CONVERT -resize $YSx$XS $ICONIMAGE_6 $TEMPIMAGES/iim6_$CI.png
  $CONVERT -resize $YSx$XS $ICONIMAGE_7 $TEMPIMAGES/iim7_$CI.png
  $CONVERT -resize $YSx$XS $ICONIMAGE_8 $TEMPIMAGES/iim8_$CI.png

done

let "ANIM_FX_COUNT=CI+1"
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/iim1_$ANIM_FX_COUNT.png
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/iim2_$ANIM_FX_COUNT.png
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/iim3_$ANIM_FX_COUNT.png
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/iim4_$ANIM_FX_COUNT.png
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/iim5_$ANIM_FX_COUNT.png
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/iim6_$ANIM_FX_COUNT.png
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/iim7_$ANIM_FX_COUNT.png
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/iim8_$ANIM_FX_COUNT.png


YPLACE1=450 # leftmost column of icons
YPLACE2=230 # rightmost column of icons
XSTART=260 # the topmost icon
XSTEP=180  # x-spacing between icons
YSTEP=180  # y-spacing between icons
XDYN1=$XSTART
YDYN1=$YPLACE1
XDYN2=$(calculate $XDYN1+$XSTEP)
YDYN2=$YPLACE1
XDYN3=$(calculate $XDYN2+$XSTEP)
YDYN3=$YPLACE1
XDYN4=$(calculate $XDYN3+$XSTEP)
YDYN4=$YPLACE1
XDYN5=$XSTART
YDYN5=$YPLACE2
XDYN6=$(calculate $XDYN1+$XSTEP)
YDYN6=$YPLACE2
XDYN7=$(calculate $XDYN2+$XSTEP)
YDYN7=$YPLACE2
XDYN8=$(calculate $XDYN3+$XSTEP)
YDYN8=$YPLACE2
DX=200
DY=200
CI=0
NI=$ANIM_FX_COUNT
echo
while [ $CI -lt $ANIM_FX_COUNT ]; do
  let "CI+=1"
  let "DX-=3"
  let "DY=DX"
  CXD1=$(calculate $XDYN1-$DX)
  CYD1=$(calculate $YDYN1-$DY)
  CXD2=$(calculate $XDYN2-$DX)
  CYD2=$(calculate $YDYN2-$DY)
  CXD3=$(calculate $XDYN3-$DX)
  CYD3=$(calculate $YDYN3-$DY)
  CXD4=$(calculate $XDYN4-$DX)
  CYD4=$(calculate $YDYN4-$DY)
  CXD5=$(calculate $XDYN5-$DX)
  CYD5=$(calculate $YDYN5-$DY)
  CXD6=$(calculate $XDYN6-$DX)
  CYD6=$(calculate $YDYN6-$DY)
  CXD7=$(calculate $XDYN7-$DX)
  CYD7=$(calculate $YDYN7-$DY)
  CXD8=$(calculate $XDYN8-$DX)
  CYD8=$(calculate $YDYN8-$DY)
  let "NI-=1"
  INDF=$(printindex $NI)
  echo -n "[$CI] "
  $CONVERT -size 854x480 xc:black \
           -page +$CXD1+$CYD1 $TEMPIMAGES/iim1_$CI.png \
           -page +$CXD2+$CYD2 $TEMPIMAGES/iim2_$CI.png \
           -page +$CXD3+$CYD3 $TEMPIMAGES/iim3_$CI.png \
           -page +$CXD4+$CYD4 $TEMPIMAGES/iim4_$CI.png \
           -page +$CXD5+$CYD5 $TEMPIMAGES/iim5_$CI.png \
           -page +$CXD6+$CYD6 $TEMPIMAGES/iim6_$CI.png \
           -page +$CXD7+$CYD7 $TEMPIMAGES/iim7_$CI.png \
           -page +$CXD8+$CYD8 $TEMPIMAGES/iim8_$CI.png \
           -flatten $TEMPIMAGES/fom_$INDF.png
done


## This is the main menu png, copy it to the final images directory
let "IND=ANIM_FX_COUNT-1"
cp $TEMPIMAGES/fom_$IND.png $ANIMIMAGES/topmenu.png
CI=0
echo
## Copy rest of the fadeout sequences to final images directory
while [ $CI -lt $ANIM_FX_COUNT ]; do
  let "CI+=1"
  let "CJ=CI-1"
  INDI=$(printindex $CI)
  INDJ=$(printindex $CJ)
  echo -n "."
  cp $TEMPIMAGES/fom_$INDJ.png $ANIMIMAGES/fx_$INDI.png
done


## create the button press sequences
echo
echo "Creating button presses..."
XDYN1=$XSTART
YDYN1=$YPLACE1
XDYN2=$(calculate $XDYN1+$XSTEP)
YDYN2=$YPLACE1
XDYN3=$(calculate $XDYN2+$XSTEP)
YDYN3=$YPLACE1
XDYN4=$(calculate $XDYN3+$XSTEP)
YDYN4=$YPLACE1
XDYN5=$XSTART
YDYN5=$YPLACE2
XDYN6=$(calculate $XDYN1+$XSTEP)
YDYN6=$YPLACE2
XDYN7=$(calculate $XDYN2+$XSTEP)
YDYN7=$YPLACE2
XDYN8=$(calculate $XDYN3+$XSTEP)
YDYN8=$YPLACE2
DX=200
DY=200

FSTATICX1=$(calculate $XDYN1-$DX+3)
FSTATICY1=$(calculate $YDYN1-$DY+3)
FSTATICX2=$(calculate $XDYN2-$DX+3)
FSTATICY2=$(calculate $YDYN2-$DY+3)
FSTATICX3=$(calculate $XDYN3-$DX+3)
FSTATICY3=$(calculate $YDYN3-$DY+3)
FSTATICX4=$(calculate $XDYN4-$DX+3)
FSTATICY4=$(calculate $YDYN4-$DY+3)
FSTATICX5=$(calculate $XDYN5-$DX+3)
FSTATICY5=$(calculate $YDYN5-$DY+3)
FSTATICX6=$(calculate $XDYN6-$DX+3)
FSTATICY6=$(calculate $YDYN6-$DY+3)
FSTATICX7=$(calculate $XDYN7-$DX+3)
FSTATICY7=$(calculate $YDYN7-$DY+3)
FSTATICX8=$(calculate $XDYN8-$DX+3)
FSTATICY8=$(calculate $YDYN8-$DY+3)

CI=0
while [ $CI -lt 4 ]; do
  let "CI+=1"
  let "DX-=3"
  let "DY=DX"
  CXD1=$(calculate $XDYN1-$DX)
  CYD1=$(calculate $YDYN1-$DY)
  CXD2=$(calculate $XDYN2-$DX)
  CYD2=$(calculate $YDYN2-$DY)
  CXD3=$(calculate $XDYN3-$DX)
  CYD3=$(calculate $YDYN3-$DY)
  CXD4=$(calculate $XDYN4-$DX)
  CYD4=$(calculate $YDYN4-$DY)
  CXD5=$(calculate $XDYN5-$DX)
  CYD5=$(calculate $YDYN5-$DY)
  CXD6=$(calculate $XDYN6-$DX)
  CYD6=$(calculate $YDYN6-$DY)
  CXD7=$(calculate $XDYN7-$DX)
  CYD7=$(calculate $YDYN7-$DY)
  CXD8=$(calculate $XDYN8-$DX)
  CYD8=$(calculate $YDYN8-$DY)
  INDF=$(printindex $CI)
  echo -n "[$CI] "
  $CONVERT -size 854x480 xc:black \
           -page +$CXD1+$CYD1 $TEMPIMAGES/iim1_$CI.png \
           -page +$FSTATICX2+$FSTATICY2 $TEMPIMAGES/iim2_1.png \
           -page +$FSTATICX3+$FSTATICY3 $TEMPIMAGES/iim3_1.png \
           -page +$FSTATICX4+$FSTATICY4 $TEMPIMAGES/iim4_1.png \
           -page +$FSTATICX5+$FSTATICY5 $TEMPIMAGES/iim5_1.png \
           -page +$FSTATICX6+$FSTATICY6 $TEMPIMAGES/iim6_1.png \
           -page +$FSTATICX7+$FSTATICY7 $TEMPIMAGES/iim7_1.png \
           -page +$FSTATICX8+$FSTATICY8 $TEMPIMAGES/iim8_1.png \
           -flatten $ANIMIMAGES/pi1_$INDF.png
  $CONVERT -size 854x480 xc:black \
           -page +$FSTATICX1+$FSTATICY1 $TEMPIMAGES/iim1_1.png \
           -page +$CXD2+$CYD2 $TEMPIMAGES/iim2_$CI.png \
           -page +$FSTATICX3+$FSTATICY3 $TEMPIMAGES/iim3_1.png \
           -page +$FSTATICX4+$FSTATICY4 $TEMPIMAGES/iim4_1.png \
           -page +$FSTATICX5+$FSTATICY5 $TEMPIMAGES/iim5_1.png \
           -page +$FSTATICX6+$FSTATICY6 $TEMPIMAGES/iim6_1.png \
           -page +$FSTATICX7+$FSTATICY7 $TEMPIMAGES/iim7_1.png \
           -page +$FSTATICX8+$FSTATICY8 $TEMPIMAGES/iim8_1.png \
           -flatten $ANIMIMAGES/pi2_$INDF.png
  $CONVERT -size 854x480 xc:black \
           -page +$FSTATICX1+$FSTATICY1 $TEMPIMAGES/iim1_1.png \
           -page +$FSTATICX2+$FSTATICY2 $TEMPIMAGES/iim2_1.png \
           -page +$CXD3+$CYD3 $TEMPIMAGES/iim3_$CI.png \
           -page +$FSTATICX4+$FSTATICY4 $TEMPIMAGES/iim4_1.png \
           -page +$FSTATICX5+$FSTATICY5 $TEMPIMAGES/iim5_1.png \
           -page +$FSTATICX6+$FSTATICY6 $TEMPIMAGES/iim6_1.png \
           -page +$FSTATICX7+$FSTATICY7 $TEMPIMAGES/iim7_1.png \
           -page +$FSTATICX8+$FSTATICY8 $TEMPIMAGES/iim8_1.png \
           -flatten $ANIMIMAGES/pi3_$INDF.png
  $CONVERT -size 854x480 xc:black \
           -page +$FSTATICX1+$FSTATICY1 $TEMPIMAGES/iim1_1.png \
           -page +$FSTATICX2+$FSTATICY2 $TEMPIMAGES/iim2_1.png \
           -page +$FSTATICX3+$FSTATICY3 $TEMPIMAGES/iim3_1.png \
           -page +$CXD4+$CYD4 $TEMPIMAGES/iim4_$CI.png \
           -page +$FSTATICX5+$FSTATICY5 $TEMPIMAGES/iim5_1.png \
           -page +$FSTATICX6+$FSTATICY6 $TEMPIMAGES/iim6_1.png \
           -page +$FSTATICX7+$FSTATICY7 $TEMPIMAGES/iim7_1.png \
           -page +$FSTATICX8+$FSTATICY8 $TEMPIMAGES/iim8_1.png \
           -flatten $ANIMIMAGES/pi4_$INDF.png
  $CONVERT -size 854x480 xc:black \
           -page +$FSTATICX1+$FSTATICY1 $TEMPIMAGES/iim1_1.png \
           -page +$FSTATICX2+$FSTATICY2 $TEMPIMAGES/iim2_1.png \
           -page +$FSTATICX3+$FSTATICY3 $TEMPIMAGES/iim3_1.png \
           -page +$FSTATICX4+$FSTATICY4 $TEMPIMAGES/iim4_1.png \
           -page +$CXD5+$CYD5 $TEMPIMAGES/iim5_$CI.png \
           -page +$FSTATICX6+$FSTATICY6 $TEMPIMAGES/iim6_1.png \
           -page +$FSTATICX7+$FSTATICY7 $TEMPIMAGES/iim7_1.png \
           -page +$FSTATICX8+$FSTATICY8 $TEMPIMAGES/iim8_1.png \
           -flatten $ANIMIMAGES/pi5_$INDF.png
  $CONVERT -size 854x480 xc:black \
           -page +$FSTATICX1+$FSTATICY1 $TEMPIMAGES/iim1_1.png \
           -page +$FSTATICX2+$FSTATICY2 $TEMPIMAGES/iim2_1.png \
           -page +$FSTATICX3+$FSTATICY3 $TEMPIMAGES/iim3_1.png \
           -page +$FSTATICX4+$FSTATICY4 $TEMPIMAGES/iim4_1.png \
           -page +$FSTATICX5+$FSTATICY5 $TEMPIMAGES/iim5_1.png \
           -page +$CXD6+$CYD6 $TEMPIMAGES/iim6_$CI.png \
           -page +$FSTATICX7+$FSTATICY7 $TEMPIMAGES/iim7_1.png \
           -page +$FSTATICX8+$FSTATICY8 $TEMPIMAGES/iim8_1.png \
           -flatten $ANIMIMAGES/pi6_$INDF.png
  $CONVERT -size 854x480 xc:black \
           -page +$FSTATICX1+$FSTATICY1 $TEMPIMAGES/iim1_1.png \
           -page +$FSTATICX2+$FSTATICY2 $TEMPIMAGES/iim2_1.png \
           -page +$FSTATICX3+$FSTATICY3 $TEMPIMAGES/iim3_1.png \
           -page +$FSTATICX4+$FSTATICY4 $TEMPIMAGES/iim4_1.png \
           -page +$FSTATICX5+$FSTATICY5 $TEMPIMAGES/iim5_1.png \
           -page +$FSTATICX6+$FSTATICY6 $TEMPIMAGES/iim6_1.png \
           -page +$CXD7+$CYD7 $TEMPIMAGES/iim7_$CI.png \
           -page +$FSTATICX8+$FSTATICY8 $TEMPIMAGES/iim8_1.png \
           -flatten $ANIMIMAGES/pi7_$INDF.png
  $CONVERT -size 854x480 xc:black \
           -page +$FSTATICX1+$FSTATICY1 $TEMPIMAGES/iim1_1.png \
           -page +$FSTATICX2+$FSTATICY2 $TEMPIMAGES/iim2_1.png \
           -page +$FSTATICX3+$FSTATICY3 $TEMPIMAGES/iim3_1.png \
           -page +$FSTATICX4+$FSTATICY4 $TEMPIMAGES/iim4_1.png \
           -page +$FSTATICX5+$FSTATICY5 $TEMPIMAGES/iim5_1.png \
           -page +$FSTATICX6+$FSTATICY6 $TEMPIMAGES/iim6_1.png \
           -page +$FSTATICX7+$FSTATICY7 $TEMPIMAGES/iim7_1.png \
           -page +$CXD8+$CYD8 $TEMPIMAGES/iim8_$CI.png \
           -flatten $ANIMIMAGES/pi8_$INDF.png
done
let "ANIM_BP_COUNT=CI"


## move 1st icon to top
echo
echo "Creating icon #1 movement..."
H_INTERVAL=1
V_INTERVAL=1
H_ACCEL=1
V_ACCEL=0.5
let "Y1=YPLACE1-200"
let "Y2=YPLACE1-200"
let "Y3=YPLACE2-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=8
let "X1=XDYN1-200"
let "X2=XDYN2-200"
let "X3=XDYN3-200"
let "X4=XDYN4-200"
let "X5=XDYN5-200"
let "X6=XDYN6-200"
let "X7=XDYN7-200"
let "X8=XDYN8-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  Y3=$(calculate $Y3-$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  if [ $Y3 -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y1 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5+$Y3 $ICONIMAGE_5 \
             -page +$X6+$Y3 $ICONIMAGE_6 \
             -page +$X7+$Y3 $ICONIMAGE_7 \
             -page +$X8+$Y3 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui1_$INDF.png
  else
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y1 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5$Y3 $ICONIMAGE_5 \
             -page +$X6$Y3 $ICONIMAGE_6 \
             -page +$X7$Y3 $ICONIMAGE_7 \
             -page +$X8$Y3 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui1_$INDF.png
  fi
done

XINT=$X1
while [ $XINT -gt 5 ]; do
  V_INTERVAL=$(calculate $V_INTERVAL+$V_ACCEL)
  X1=$(calculate $X1-$V_INTERVAL)
  XINT=$(round $X1)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  let "FRAMENUMB+=1"
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB, (X1=$X1)] "
  if [ $XINT -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y1 $ICONIMAGE_1 \
             -layers flatten $ANIMIMAGES/mui1_$INDF.png
  fi
done
ANIM_M1_COUNT=$FRAMENUM


## move 2nd icon to top
echo
echo "Creating icon #2 movement..."
H_INTERVAL=1
V_INTERVAL=2
H_ACCEL=1
V_ACCEL=1
let "Y1=YPLACE1-200"
let "Y2=YPLACE1-200"
let "Y3=YPLACE2-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=14
let "X1=XDYN1-200"
let "X2=XDYN2-200"
let "X3=XDYN3-200"
let "X4=XDYN4-200"
let "X5=XDYN5-200"
let "X6=XDYN6-200"
let "X7=XDYN7-200"
let "X8=XDYN8-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  Y3=$(calculate $Y3-$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  if [ $Y3 -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y1 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5+$Y3 $ICONIMAGE_5 \
             -page +$X6+$Y3 $ICONIMAGE_6 \
             -page +$X7+$Y3 $ICONIMAGE_7 \
             -page +$X8+$Y3 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui2_$INDF.png
  else
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y1 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5$Y3 $ICONIMAGE_5 \
             -page +$X6$Y3 $ICONIMAGE_6 \
             -page +$X7$Y3 $ICONIMAGE_7 \
             -page +$X8$Y3 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui2_$INDF.png
  fi
done

XINT=$X2
while [ $XINT -gt 5 ]; do
  V_INTERVAL=$(calculate $V_INTERVAL+$V_ACCEL)
  X2=$(calculate $X2-$V_INTERVAL)
  XINT=$(round $X2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB, (X2=$X2)] "
  if [ $XINT -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X2+$Y1 $ICONIMAGE_2 \
             -layers flatten $ANIMIMAGES/mui2_$INDF.png
  fi
done
ANIM_M2_COUNT=$FRAMENUM


## move 3rd icon to top
echo
echo "Creating icon #3 movement..."
H_INTERVAL=1
V_INTERVAL=2
H_ACCEL=1
V_ACCEL=1.5
let "Y1=YPLACE1-200"
let "Y2=YPLACE1-200"
let "Y3=YPLACE2-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=16
let "X1=XDYN1-200"
let "X2=XDYN2-200"
let "X3=XDYN3-200"
let "X4=XDYN4-200"
let "X5=XDYN5-200"
let "X6=XDYN6-200"
let "X7=XDYN7-200"
let "X8=XDYN8-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  Y3=$(calculate $Y3-$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  if [ $Y3 -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y1 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5+$Y3 $ICONIMAGE_5 \
             -page +$X6+$Y3 $ICONIMAGE_6 \
             -page +$X7+$Y3 $ICONIMAGE_7 \
             -page +$X8+$Y3 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui3_$INDF.png
  else
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y1 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5$Y3 $ICONIMAGE_5 \
             -page +$X6$Y3 $ICONIMAGE_6 \
             -page +$X7$Y3 $ICONIMAGE_7 \
             -page +$X8$Y3 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui3_$INDF.png
  fi
done

XINT=$X3
while [ $XINT -gt 5 ]; do
  V_INTERVAL=$(calculate $V_INTERVAL+$V_ACCEL)
  X3=$(calculate $X3-$V_INTERVAL)
  XINT=$(round $X3)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB, (X3=$X3)] "
  if [ $XINT -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X3+$Y1 $ICONIMAGE_3 \
             -layers flatten $ANIMIMAGES/mui3_$INDF.png
  fi
done
ANIM_M3_COUNT=$FRAMENUM


## move 4rd icon to top
echo
echo "Creating icon #4 movement..."
H_INTERVAL=1
V_INTERVAL=2
H_ACCEL=1
V_ACCEL=1.8
let "Y1=YPLACE1-200"
let "Y2=YPLACE1-200"
let "Y3=YPLACE2-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=21
let "X1=XDYN1-200"
let "X2=XDYN2-200"
let "X3=XDYN3-200"
let "X4=XDYN4-200"
let "X5=XDYN5-200"
let "X6=XDYN6-200"
let "X7=XDYN7-200"
let "X8=XDYN8-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  Y3=$(calculate $Y3-$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  if [ $Y3 -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y1 $ICONIMAGE_4 \
             -page +$X5+$Y3 $ICONIMAGE_5 \
             -page +$X6+$Y3 $ICONIMAGE_6 \
             -page +$X7+$Y3 $ICONIMAGE_7 \
             -page +$X8+$Y3 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui4_$INDF.png
  else
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y1 $ICONIMAGE_4 \
             -page +$X5$Y3 $ICONIMAGE_5 \
             -page +$X6$Y3 $ICONIMAGE_6 \
             -page +$X7$Y3 $ICONIMAGE_7 \
             -page +$X8$Y3 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui4_$INDF.png
  fi
done

XINT=$X4
while [ $XINT -gt 5 ]; do
  V_INTERVAL=$(calculate $V_INTERVAL+$V_ACCEL)
  X4=$(calculate $X4-$V_INTERVAL)
  XINT=$(round $X4)
  let "FRAMENUM+=1"
  INDP=$INDF
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB, (X4=$X4)] "
  if [ $XINT -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X4+$Y1 $ICONIMAGE_4 \
             -layers flatten $ANIMIMAGES/mui4_$INDF.png
  fi
done
ANIM_M4_COUNT=$FRAMENUM

## The fbm panel is embedded to the backupmenu screen, so fix that now

$CONVERT -size 854x480 xc:black \
         -page +0+0 $ANIMIMAGES/mui4_$INDP.png \
         -page +220+40 $IBASE/fbm.png \
         -layers flatten $ANIMIMAGES/mui4_$INDF.png


## move 5th icon to top
echo
echo "Creating icon #5 movement..."
H_INTERVAL=1
V_INTERVAL=1
H_ACCEL=1
V_ACCEL=0.5
let "Y1=YPLACE1-200"
let "Y2=YPLACE1-200"
let "Y3=YPLACE2-200"
let "Y4=YPLACE2-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=8
let "X1=XDYN1-200"
let "X2=XDYN2-200"
let "X3=XDYN3-200"
let "X4=XDYN4-200"
let "X5=XDYN5-200"
let "X6=XDYN6-200"
let "X7=XDYN7-200"
let "X8=XDYN8-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  Y4=$(calculate $Y4-$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  if [ $Y4 -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5+$Y3 $ICONIMAGE_5 \
             -page +$X6+$Y4 $ICONIMAGE_6 \
             -page +$X7+$Y4 $ICONIMAGE_7 \
             -page +$X8+$Y4 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui5_$INDF.png
  else
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5+$Y3 $ICONIMAGE_5 \
             -page +$X6$Y4 $ICONIMAGE_6 \
             -page +$X7$Y4 $ICONIMAGE_7 \
             -page +$X8$Y4 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui5_$INDF.png
  fi
done

XINT=$X5
while [ $XINT -gt 5 ]; do
  V_INTERVAL=$(calculate $V_INTERVAL+$V_ACCEL)
  X5=$(calculate $X5-$V_INTERVAL)
  XINT=$(round $X5)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  let "FRAMENUMB+=1"
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB, (X5=$X5)] "
  if [ $XINT -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X5+$Y3 $ICONIMAGE_5 \
             -layers flatten $ANIMIMAGES/mui5_$INDF.png
  fi
done
ANIM_M5_COUNT=$FRAMENUM


## move 6th icon to top
echo
echo "Creating icon #6 movement..."
H_INTERVAL=1
V_INTERVAL=2
H_ACCEL=1
V_ACCEL=1
let "Y1=YPLACE1-200"
let "Y2=YPLACE1-200"
let "Y3=YPLACE2-200"
let "Y4=YPLACE2-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=14
let "X1=XDYN1-200"
let "X2=XDYN2-200"
let "X3=XDYN3-200"
let "X4=XDYN4-200"
let "X5=XDYN5-200"
let "X6=XDYN6-200"
let "X7=XDYN7-200"
let "X8=XDYN8-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  Y4=$(calculate $Y4-$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  if [ $Y4 -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5+$Y4 $ICONIMAGE_5 \
             -page +$X6+$Y3 $ICONIMAGE_6 \
             -page +$X7+$Y4 $ICONIMAGE_7 \
             -page +$X8+$Y4 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui6_$INDF.png
  else
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5$Y4 $ICONIMAGE_5 \
             -page +$X6+$Y3 $ICONIMAGE_6 \
             -page +$X7$Y4 $ICONIMAGE_7 \
             -page +$X8$Y4 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui6_$INDF.png
  fi
done

XINT=$X6
while [ $XINT -gt 5 ]; do
  V_INTERVAL=$(calculate $V_INTERVAL+$V_ACCEL)
  X6=$(calculate $X6-$V_INTERVAL)
  XINT=$(round $X6)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB, (X6=$X6)] "
  if [ $XINT -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X6+$Y3 $ICONIMAGE_6 \
             -layers flatten $ANIMIMAGES/mui6_$INDF.png
  fi
done
ANIM_M6_COUNT=$FRAMENUM


## move 7th icon to top
echo
echo "Creating icon #7 movement..."
H_INTERVAL=1
V_INTERVAL=2
H_ACCEL=1
V_ACCEL=1.5
let "Y1=YPLACE1-200"
let "Y2=YPLACE1-200"
let "Y3=YPLACE2-200"
let "Y4=YPLACE2-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=16
let "X1=XDYN1-200"
let "X2=XDYN2-200"
let "X3=XDYN3-200"
let "X4=XDYN4-200"
let "X5=XDYN5-200"
let "X6=XDYN6-200"
let "X7=XDYN7-200"
let "X8=XDYN8-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  Y4=$(calculate $Y4-$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  if [ $Y4 -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5+$Y4 $ICONIMAGE_5 \
             -page +$X6+$Y4 $ICONIMAGE_6 \
             -page +$X7+$Y3 $ICONIMAGE_7 \
             -page +$X8+$Y4 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui7_$INDF.png
  else
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5$Y4 $ICONIMAGE_5 \
             -page +$X6$Y4 $ICONIMAGE_6 \
             -page +$X7+$Y3 $ICONIMAGE_7 \
             -page +$X8$Y4 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui7_$INDF.png
  fi
done

XINT=$X7
while [ $XINT -gt 5 ]; do
  V_INTERVAL=$(calculate $V_INTERVAL+$V_ACCEL)
  X7=$(calculate $X7-$V_INTERVAL)
  XINT=$(round $X7)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB, (X7=$X7)] "
  if [ $XINT -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X7+$Y3 $ICONIMAGE_7 \
             -layers flatten $ANIMIMAGES/mui7_$INDF.png
  fi
done
ANIM_M7_COUNT=$FRAMENUM


## move 8th icon to top
echo
echo "Creating icon #8 movement..."
H_INTERVAL=1
V_INTERVAL=2
H_ACCEL=1
V_ACCEL=1.8
let "Y1=YPLACE1-200"
let "Y2=YPLACE1-200"
let "Y3=YPLACE2-200"
let "Y4=YPLACE2-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=21
let "X1=XDYN1-200"
let "X2=XDYN2-200"
let "X3=XDYN3-200"
let "X4=XDYN4-200"
let "X5=XDYN5-200"
let "X6=XDYN6-200"
let "X7=XDYN7-200"
let "X8=XDYN8-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  Y4=$(calculate $Y4-$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  if [ $Y4 -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5+$Y4 $ICONIMAGE_5 \
             -page +$X6+$Y4 $ICONIMAGE_6 \
             -page +$X7+$Y4 $ICONIMAGE_7 \
             -page +$X8+$Y3 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui8_$INDF.png
  else
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X1+$Y2 $ICONIMAGE_1 \
             -page +$X2+$Y2 $ICONIMAGE_2 \
             -page +$X3+$Y2 $ICONIMAGE_3 \
             -page +$X4+$Y2 $ICONIMAGE_4 \
             -page +$X5$Y4 $ICONIMAGE_5 \
             -page +$X6$Y4 $ICONIMAGE_6 \
             -page +$X7$Y4 $ICONIMAGE_7 \
             -page +$X8+$Y3 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui8_$INDF.png
  fi
done

XINT=$X8
while [ $XINT -gt 5 ]; do
  V_INTERVAL=$(calculate $V_INTERVAL+$V_ACCEL)
  X8=$(calculate $X8-$V_INTERVAL)
  XINT=$(round $X8)
  let "FRAMENUM+=1"
  INDP=$INDF
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB, (X8=$X8)] "
  if [ $XINT -gt 0 ]; then
    $CONVERT -size 854x480 xc:black \
             -page +0+0 $TEMPIMAGES/bom_$INDB.png \
             -page +$X8+$Y3 $ICONIMAGE_8 \
             -layers flatten $ANIMIMAGES/mui8_$INDF.png
  fi
done
ANIM_M8_COUNT=$FRAMENUM

## The owner panel is embedded to the info screen

$CONVERT -size 854x480 xc:black \
         -page +0+0 $ANIMIMAGES/mui8_$INDP.png \
         -page +220+40 $OWNERPANEL \
         -layers flatten $ANIMIMAGES/mui8_$INDF.png


## for debug, see the mpeg sequences in vlc/mplayer
if [ "$GENERATE_VIDEOS" == "1" ]; then
  echo
  echo "Creating test movies..."
  avconv -i $ANIMIMAGES/mui1_%02d.png $VIDEOS/movie1.mpeg
  avconv -i $ANIMIMAGES/mui2_%02d.png $VIDEOS/movie2.mpeg
  avconv -i $ANIMIMAGES/mui3_%02d.png $VIDEOS/movie3.mpeg
  avconv -i $ANIMIMAGES/mui4_%02d.png $VIDEOS/movie4.mpeg
  avconv -i $ANIMIMAGES/mui5_%02d.png $VIDEOS/movie5.mpeg
  avconv -i $ANIMIMAGES/mui6_%02d.png $VIDEOS/movie6.mpeg
  avconv -i $ANIMIMAGES/mui7_%02d.png $VIDEOS/movie7.mpeg
  avconv -i $ANIMIMAGES/mui8_%02d.png $VIDEOS/movie8.mpeg
  avconv -i $ANIMIMAGES/fx_%02d.png $VIDEOS/fmovie.mpeg

  ## all button press sequences together
  cp  $ANIMIMAGES/topmenu.png $TEMPIMAGES/pp_00.png
  cp  $ANIMIMAGES/topmenu.png $TEMPIMAGES/pp_53.png
  CI=0
  CJ=0
  while [ $CI -lt 37 ]; do
    let "CI+=1"
    INDF=$(printindex $CI)

    if [ $CI -ge 1 -a $CI -le 4 ]; then
      let "CJ+=1"
      IND=$(printindex $CJ)
      cp $ANIMIMAGES/pd_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
    if [ $CI -ge 5 -a $CI -le 7 ]; then
      let "CJ-=1"
      IND=$(printindex $CJ)
      cp $ANIMIMAGES/pd_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
    if [ $CI -eq 7 ]; then
      CJ=0
    fi

    if [ $CI -ge 8 -a $CI -le 11 ]; then
      let "CJ+=1"
      IND=$(printindex $CJ)
      cp $ANIMIMAGES/ph_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
    if [ $CI -ge 12 -a $CI -le 14 ]; then
      let "CJ-=1"
      IND=$(printindex $CJ)
      cp $ANIMIMAGES/ph_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
    if [ $CI -eq 14 ]; then
      CJ=0
    fi
  
    if [ $CI -ge 15 -a $CI -le 18 ]; then
      let "CJ+=1"
      IND=$(printindex $CJ)
      cp $ANIMIMAGES/pn_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
    if [ $CI -ge 19 -a $CI -le 21 ]; then
      let "CJ-=1"
      IND=$(printindex $CJ)
      cp $ANIMIMAGES/pn_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
    if [ $CI -eq 21 ]; then
      CJ=0
    fi

    if [ $CI -ge 22 -a $CI -le 25 ]; then
      let "CJ+=1"
      IND=$(printindex $CJ)
      cp $ANIMIMAGES/pb_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
    if [ $CI -ge 26 -a $CI -le 28 ]; then
      let "CJ-=1"
      IND=$(printindex $CJ)
      cp $ANIMIMAGES/pb_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
    if [ $CI -eq 28 ]; then
      let "CJ=0"
    fi

    if [ $CI -ge 29 -a $CI -le 32 ]; then
      let "CJ+=1"
      IND=$(printindex $CJ)
      cp $ANIMIMAGES/pi_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
    if [ $CI -ge 33 -a $CI -le 35 ]; then
      let "CJ-=1"
      IND=$(printindex $CJ)
      cp $ANIMIMAGES/pi_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
  done

  avconv -i $TEMPIMAGES/pp_%02d.png $VIDEOS/pmovie.mpeg

  cat $VIDEOS/fmovie.mpeg $VIDEOS/pmovie.mpeg $VIDEOS/movie1.mpeg $VIDEOS/movie2.mpeg $VIDEOS/movie3.mpeg $VIDEOS/movie4.mpeg $VIDEOS/movie5.mpeg $VIDEOS/movie6.mpeg $VIDEOS/movie7.mpeg $VIDEOS/movie8.mpeg > $VIDEOS/all.mpeg
fi


## create the configuration file for animation sequences
echo "#Animation sequence constants" > $CTRLFILE
echo "ANIM_BB_COUNT=$ANIM_BB_COUNT" >> $CTRLFILE
echo "ANIM_FX_COUNT=$ANIM_FX_COUNT" >> $CTRLFILE
echo "ANIM_BP_COUNT=$ANIM_BP_COUNT" >> $CTRLFILE
echo "ANIM_M1_COUNT=$ANIM_M1_COUNT" >> $CTRLFILE
echo "ANIM_M2_COUNT=$ANIM_M2_COUNT" >> $CTRLFILE
echo "ANIM_M3_COUNT=$ANIM_M3_COUNT" >> $CTRLFILE
echo "ANIM_M4_COUNT=$ANIM_M4_COUNT" >> $CTRLFILE
echo "ANIM_M5_COUNT=$ANIM_M5_COUNT" >> $CTRLFILE
echo "ANIM_M6_COUNT=$ANIM_M6_COUNT" >> $CTRLFILE
echo "ANIM_M7_COUNT=$ANIM_M7_COUNT" >> $CTRLFILE
echo "ANIM_M8_COUNT=$ANIM_M8_COUNT" >> $CTRLFILE


## tar up the animation package
echo
echo "creating install package..."
cd $FINIMAGES
$TAR -cvf animatronics.tar . > /dev/null 2>&1
cd ..
mv $FINIMAGES/animatronics.tar .

echo
echo "All Done!"
exit 0;
