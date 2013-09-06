#!/bin/sh

IMAGEBASE="/boot/menu/animation"
source /boot/menu/ctrl_animation.rc


## helper to enumerate sequences correctly
printindex()
{
  if [ $1 -lt 10 ]; then
    echo "0$1"
  else
    echo "$1"
  fi
}


## fade in
FRAMENUM=0
LASTFRAME=$ANIM_FX_COUNT
while [ $FRAMENUM -lt $LASTFRAME ] ; do
  let "FRAMENUM+=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/fx_$INDEX.png
done
sleep 1


## bounce nitdroid
FRAMENUM=0
LASTFRAME=$ANIM_BP_COUNT
while [ $FRAMENUM -lt $LASTFRAME ] ; do
  let "FRAMENUM+=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/pd_$INDEX.png
done
let "FRAMENUM-=1"
while [ $FRAMENUM -gt 1 ] ; do
  let "FRAMENUM-=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/pd_$INDEX.png
done
sleep 1


## nitdroid moving
FRAMENUM=0
LASTFRAME=$ANIM_MD_COUNT
while [ $FRAMENUM -lt $LASTFRAME ] ; do
  let "FRAMENUM+=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/md_$INDEX.png
done
sleep 1
while [ $FRAMENUM -gt 1 ] ; do
  let "FRAMENUM-=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/md_$INDEX.png
done
sleep 1


## bounce harmattan
FRAMENUM=0
LASTFRAME=$ANIM_BP_COUNT
while [ $FRAMENUM -lt $LASTFRAME ] ; do
  let "FRAMENUM+=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/ph_$INDEX.png
done
let "FRAMENUM-=1"
while [ $FRAMENUM -gt 1 ] ; do
  let "FRAMENUM-=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/ph_$INDEX.png
done
sleep 1


## harmattan moving
FRAMENUM=0
LASTFRAME=$ANIM_MH_COUNT
while [ $FRAMENUM -lt $LASTFRAME ] ; do
  let "FRAMENUM+=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/mh_$INDEX.png
done
sleep 1
while [ $FRAMENUM -gt 1 ] ; do
  let "FRAMENUM-=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/mh_$INDEX.png
done
sleep 1


## bounce nemo
FRAMENUM=0
LASTFRAME=$ANIM_BP_COUNT
while [ $FRAMENUM -lt $LASTFRAME ] ; do
  let "FRAMENUM+=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/pn_$INDEX.png
done
let "FRAMENUM-=1"
while [ $FRAMENUM -gt 1 ] ; do
  let "FRAMENUM-=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/pn_$INDEX.png
done
sleep 1


## nemo moving
FRAMENUM=0
LASTFRAME=$ANIM_MN_COUNT
while [ $FRAMENUM -lt $LASTFRAME ] ; do
  let "FRAMENUM+=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/mn_$INDEX.png
done
sleep 1
while [ $FRAMENUM -gt 1 ] ; do
  let "FRAMENUM-=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/mn_$INDEX.png
done
sleep 1


## bounce info
FRAMENUM=0
LASTFRAME=$ANIM_BP_COUNT
while [ $FRAMENUM -lt $LASTFRAME ] ; do
  let "FRAMENUM+=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/pi_$INDEX.png
done
let "FRAMENUM-=1"
while [ $FRAMENUM -gt 1 ] ; do
  let "FRAMENUM-=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/pi_$INDEX.png
done
sleep 1


## info moving
FRAMENUM=0
LASTFRAME=$ANIM_MI_COUNT
while [ $FRAMENUM -lt $LASTFRAME ] ; do
  let "FRAMENUM+=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/mi_$INDEX.png
done
sleep 1
while [ $FRAMENUM -gt 1 ] ; do
  let "FRAMENUM-=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/mi_$INDEX.png
done
sleep 1


# fade out
FRAMENUM=$ANIM_FX_COUNT
while [ $FRAMENUM -gt 1 ] ; do
  let "FRAMENUM-=1"
  INDEX=$(printindex $FRAMENUM)
  /usr/bin/show_png $IMAGEBASE/fx_$INDEX.png
done
sleep 1
