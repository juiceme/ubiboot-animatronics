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
DROIDIMAGE="$IBASE/nitdroid_200x200.png"
INFOIMAGE="$IBASE/info_200x200.png"
HARMIMAGE="$IBASE/meego_200x200.png"
NEMOIMAGE="$IBASE/nemo_200x200.png"
OWNERPANEL="$IBASE/ownerpanel.png"
TEMPIMAGES="./temp"
FINIMAGES="./menu"
ANIMIMAGES="./menu/animation"
GENERATE_VIDEOS=0
VIDEOS="./debug"
CTRLFILE="$FINIMAGES/ctrl_animation.rc"

if [ ! -z "$1" ]; then
  if [ "$1" == "--help" ]; then
    echo
    echo "create_animations.sh ver. 0.1"
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
      exit 1
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
  $CONVERT -resize $YSx$XS $DROIDIMAGE $TEMPIMAGES/dim_$CI.png
  $CONVERT -resize $YSx$XS $HARMIMAGE $TEMPIMAGES/him_$CI.png
  $CONVERT -resize $YSx$XS $NEMOIMAGE $TEMPIMAGES/nim_$CI.png
  $CONVERT -resize $YSx$XS $INFOIMAGE $TEMPIMAGES/iim_$CI.png
done

let "ANIM_FX_COUNT=CI+1"
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/dim_$ANIM_FX_COUNT.png
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/him_$ANIM_FX_COUNT.png
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/nim_$ANIM_FX_COUNT.png
$CONVERT -size 854x480 xc:black -flatten $TEMPIMAGES/iim_$ANIM_FX_COUNT.png

YPLACE=450 # all icons are directly on top of each other
XSTART=260 # the topmost icon
XSTEP=180  # x-spacing between icons
X1D=$XSTART
Y1D=$YPLACE
X1M=$(calculate $X1D+$XSTEP)
Y1M=$YPLACE
X1N=$(calculate $X1M+$XSTEP)
Y1N=$YPLACE
X1I=$(calculate $X1N+$XSTEP)
Y1I=$YPLACE
DX=200
DY=200
CI=0
NI=$ANIM_FX_COUNT
echo
while [ $CI -lt $ANIM_FX_COUNT ]; do
  let "CI+=1"
  let "DX-=3"
  let "DY=DX"
  CXD=$(calculate $X1D-$DX)
  CYD=$(calculate $Y1D-$DY)
  CXM=$(calculate $X1M-$DX)
  CYM=$(calculate $Y1M-$DY)
  CXN=$(calculate $X1N-$DX)
  CYN=$(calculate $Y1N-$DY)
  CXI=$(calculate $X1I-$DX)
  CYI=$(calculate $Y1I-$DY)
  let "NI-=1"
  INDF=$(printindex $NI)
  echo -n "[$CI] "
  $CONVERT -size 854x480 xc:black \
           -page +$CXD+$CYD $TEMPIMAGES/dim_$CI.png \
           -page +$CXM+$CYM $TEMPIMAGES/him_$CI.png \
           -page +$CXN+$CYN $TEMPIMAGES/nim_$CI.png \
           -page +$CXI+$CYI $TEMPIMAGES/iim_$CI.png \
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
YPLACE=450 # all icons are directly on top of each other
XSTART=260 # the topmost icon
XSTEP=180  # x-spacing between icons
X1D=$XSTART
Y1D=$YPLACE
X1M=$(calculate $X1D+$XSTEP)
Y1M=$YPLACE
X1N=$(calculate $X1M+$XSTEP)
Y1N=$YPLACE
X1I=$(calculate $X1N+$XSTEP)
Y1I=$YPLACE
DX=200
DY=200
FXD=$(calculate $X1D-$DX+3)
FYD=$(calculate $Y1D-$DY+3)
FXM=$(calculate $X1M-$DX+3)
FYM=$(calculate $Y1M-$DY+3)
FXN=$(calculate $X1N-$DX+3)
FYN=$(calculate $Y1N-$DY+3)
FXI=$(calculate $X1I-$DX+3)
FYI=$(calculate $Y1I-$DY+3)

CI=0
while [ $CI -lt 4 ]; do
  let "CI+=1"
  let "DX-=3"
  let "DY=DX"
  CXD=$(calculate $X1D-$DX)
  CYD=$(calculate $Y1D-$DY)
  CXM=$(calculate $X1M-$DX)
  CYM=$(calculate $Y1M-$DY)
  CXN=$(calculate $X1N-$DX)
  CYN=$(calculate $Y1N-$DY)
  CXI=$(calculate $X1I-$DX)
  CYI=$(calculate $Y1I-$DY)
  INDF=$(printindex $CI)
  echo -n "[$CI] "
  $CONVERT -size 854x480 xc:black \
           -page +$CXD+$CYD $TEMPIMAGES/dim_$CI.png \
           -page +$FXM+$FYM $TEMPIMAGES/him_1.png \
           -page +$FXN+$FYN $TEMPIMAGES/nim_1.png \
           -page +$FXI+$FYI $TEMPIMAGES/iim_1.png \
           -flatten $ANIMIMAGES/pd_$INDF.png
  $CONVERT -size 854x480 xc:black \
           -page +$FXD+$FYD $TEMPIMAGES/dim_1.png \
           -page +$CXM+$CYM $TEMPIMAGES/him_$CI.png \
           -page +$FXN+$FYN $TEMPIMAGES/nim_1.png \
           -page +$FXI+$FYI $TEMPIMAGES/iim_1.png \
           -flatten $ANIMIMAGES/ph_$INDF.png
  $CONVERT -size 854x480 xc:black \
           -page +$FXD+$FYD $TEMPIMAGES/dim_1.png \
           -page +$FXM+$FYM $TEMPIMAGES/him_1.png \
           -page +$CXN+$CYN $TEMPIMAGES/nim_$CI.png \
           -page +$FXI+$FYI $TEMPIMAGES/iim_1.png \
           -flatten $ANIMIMAGES/pn_$INDF.png
  $CONVERT -size 854x480 xc:black \
           -page +$FXD+$FYD $TEMPIMAGES/dim_1.png \
           -page +$FXM+$FYM $TEMPIMAGES/him_1.png \
           -page +$FXN+$FYN $TEMPIMAGES/nim_1.png \
           -page +$CXI+$CYI $TEMPIMAGES/iim_$CI.png \
           -flatten $ANIMIMAGES/pi_$INDF.png
done
let "ANIM_BP_COUNT=CI"


## move droid to top
echo
echo "Creating droid movement..."
H_INTERVAL=1
V_INTERVAL=1
H_ACCEL=1
V_ACCEL=0.5
let "Y1=YPLACE-200"
let "Y2=YPLACE-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=8
let "X1=X1D-200"
let "X2=X1M-200"
let "X3=X1N-200"
let "X4=X1I-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  $CONVERT -size 854x480 xc:black \
           -page +0+0 $TEMPIMAGES/bom_$INDB.png \
           -page +$X1+$Y1 $DROIDIMAGE \
           -page +$X2+$Y2 $HARMIMAGE \
           -page +$X3+$Y2 $NEMOIMAGE \
           -page +$X4+$Y2 $INFOIMAGE \
           -layers flatten $ANIMIMAGES/md_$INDF.png
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
             -page +$X1+$Y1 $DROIDIMAGE \
             -layers flatten $ANIMIMAGES/md_$INDF.png
  fi
done
ANIM_MD_COUNT=$FRAMENUM


## move meegoans to top
echo
echo "Creating harmattan movement..."
H_INTERVAL=1
V_INTERVAL=2
H_ACCEL=1
V_ACCEL=1
let "Y1=YPLACE-200"
let "Y2=YPLACE-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=14
let "X1=X1D-200"
let "X2=X1M-200"
let "X3=X1N-200"
let "X4=X1I-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  $CONVERT -size 854x480 xc:black \
           -page +0+0 $TEMPIMAGES/bom_$INDB.png \
           -page +$X1+$Y2 $DROIDIMAGE \
           -page +$X2+$Y1 $HARMIMAGE \
           -page +$X3+$Y2 $NEMOIMAGE \
           -page +$X4+$Y2 $INFOIMAGE \
           -layers flatten $ANIMIMAGES/mh_$INDF.png
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
             -page +$X2+$Y1 $HARMIMAGE \
             -layers flatten $ANIMIMAGES/mh_$INDF.png
  fi
done
ANIM_MH_COUNT=$FRAMENUM


## move nemologo to top
echo
echo "Creating nemo movement..."
H_INTERVAL=1
V_INTERVAL=2
H_ACCEL=1
V_ACCEL=1.5
let "Y1=YPLACE-200"
let "Y2=YPLACE-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=16
let "X1=X1D-200"
let "X2=X1M-200"
let "X3=X1N-200"
let "X4=X1I-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  $CONVERT -size 854x480 xc:black \
           -page +0+0 $TEMPIMAGES/bom_$INDB.png \
           -page +$X1+$Y2 $DROIDIMAGE \
           -page +$X2+$Y2 $HARMIMAGE \
           -page +$X3+$Y1 $NEMOIMAGE \
           -page +$X4+$Y2 $INFOIMAGE \
           -layers flatten $ANIMIMAGES/mn_$INDF.png
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
             -page +$X3+$Y1 $NEMOIMAGE \
             -layers flatten $ANIMIMAGES/mn_$INDF.png
  fi
done
ANIM_MN_COUNT=$FRAMENUM


## move infobutton to top
echo
echo "Creating info movement..."
H_INTERVAL=1
V_INTERVAL=2
H_ACCEL=1
V_ACCEL=1.8
let "Y1=YPLACE-200"
let "Y2=YPLACE-200"
let "YINT=Y2"
FRAMENUM=0
FRAMENUMB=0
BTSTART=21
let "X1=X1D-200"
let "X2=X1M-200"
let "X3=X1N-200"
let "X4=X1I-200"
while [ $YINT -lt 500 ]; do
  H_INTERVAL=$(calculate $H_INTERVAL+$H_ACCEL)
  Y2=$(calculate $Y2+$H_INTERVAL)
  YINT=$(round $Y2)
  let "FRAMENUM+=1"
  INDF=$(printindex $FRAMENUM)
  if [ $FRAMENUM -gt $BTSTART ]; then
    let "FRAMENUMB+=1"
  fi
  INDB=$(printindex $FRAMENUMB)
  echo -n "[$INDF, $FRAMENUMB] "
  $CONVERT -size 854x480 xc:black \
           -page +0+0 $TEMPIMAGES/bom_$INDB.png \
           -page +$X1+$Y2 $DROIDIMAGE \
           -page +$X2+$Y2 $HARMIMAGE \
           -page +$X3+$Y2 $NEMOIMAGE \
           -page +$X4+$Y1 $INFOIMAGE \
           -layers flatten $ANIMIMAGES/mi_$INDF.png
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
             -page +$X4+$Y1 $INFOIMAGE \
             -layers flatten $ANIMIMAGES/mi_$INDF.png
  fi
done
ANIM_MI_COUNT=$FRAMENUM


## The owner panel is embedded to the info screen

$CONVERT -size 854x480 xc:black \
         -page +0+0 $ANIMIMAGES/mi_$INDP.png \
         -page +220+40 $OWNERPANEL \
         -layers flatten $ANIMIMAGES/mi_$INDF.png


## for debug, see the mpeg sequences in vlc/mplayer
if [ "$GENERATE_VIDEOS" == "1" ]; then
  echo
  echo "Creating test movies..."
  avconv -i $ANIMIMAGES/md_%02d.png $VIDEOS/dmovie.mpeg
  avconv -i $ANIMIMAGES/mh_%02d.png $VIDEOS/hmovie.mpeg
  avconv -i $ANIMIMAGES/mn_%02d.png $VIDEOS/nmovie.mpeg
  avconv -i $ANIMIMAGES/mi_%02d.png $VIDEOS/imovie.mpeg
  avconv -i $ANIMIMAGES/fx_%02d.png $VIDEOS/fmovie.mpeg

  ## all button press sequences together
  cp  $ANIMIMAGES/topmenu.png $TEMPIMAGES/pp_00.png
  cp  $ANIMIMAGES/topmenu.png $TEMPIMAGES/pp_53.png
  CI=0
  CJ=0
  while [ $CI -lt 30 ]; do
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
      cp $ANIMIMAGES/pi_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
    if [ $CI -ge 26 -a $CI -le 28 ]; then
      let "CJ-=1"
      IND=$(printindex $CJ)
      cp $ANIMIMAGES/pi_$IND.png $TEMPIMAGES/pp_$INDF.png
    fi
  done

  avconv -i $TEMPIMAGES/pp_%02d.png $VIDEOS/pmovie.mpeg
fi


## create the configuration file for animation sequences
echo "#Animation sequence constants" > $CTRLFILE
echo "ANIM_BB_COUNT=$ANIM_BB_COUNT" >> $CTRLFILE
echo "ANIM_FX_COUNT=$ANIM_FX_COUNT" >> $CTRLFILE
echo "ANIM_BP_COUNT=$ANIM_BP_COUNT" >> $CTRLFILE
echo "ANIM_MD_COUNT=$ANIM_MD_COUNT" >> $CTRLFILE
echo "ANIM_MH_COUNT=$ANIM_MH_COUNT" >> $CTRLFILE
echo "ANIM_MN_COUNT=$ANIM_MN_COUNT" >> $CTRLFILE
echo "ANIM_MI_COUNT=$ANIM_MI_COUNT" >> $CTRLFILE


## tar up the animation package
echo
echo "creating install package..."
cd $FINIMAGES
tar -cvf animatronics.tar . > /dev/null 2>&1
cd ..
mv $FINIMAGES/animatronics.tar .

echo
echo "All Done!"
exit 0;
