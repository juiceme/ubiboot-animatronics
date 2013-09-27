#!/bin/sh

assert_integer() {
    [ -n "$1" -a $1 -eq $1 ] && return 0
    echo "ASSERT: Value of $2 ('$1') not an integer!"
    return 1
}

get_partinfo() {
    # Init all variables
    BLOCK_SIZE=""
    HARM_PART_NUM=""
    HARM_PART_START=""
    HARM_PART_END=""
    HARM_PART_SIZE=""
    ALTOS_PART_NUM=""
    ALTOS_PART_START=""
    ALTOS_PART_END=""
    ALTOS_PART_SIZE=""

    # Print partition info and use sed to remove units after numbers
    eval $(parted -s -m $1 unit s print | sed s'/\([0-9][0-9]*\)s/\1/g' | \
    awk -F: '
    {
        if ( NR == 2 ) {
            print "BLOCK_SIZE="$4
        }
        if ( NR > 2) {
            if ( $5 == "fat32" ) {
                print "HARM_PART_NUM="$1
                print "HARM_PART_START="$2
                print "HARM_PART_END="$3
                print "HARM_PART_SIZE="$4
            }
            if ( $1 == 4 ) {
                print "ALTOS_PART_NUM="$1
                print "ALTOS_PART_START="$2
                print "ALTOS_PART_END="$3
                print "ALTOS_PART_SIZE="$4
            }
        }
    }
    ')
    if [ $? != 0 ]; then
        echo "FATAL: reading partition information failed!"
        return 1
    fi

    # Calculate other values
    BLOCKS_PER_MEG=$((1024*1024/$BLOCK_SIZE))

    # Sanity check for values
    assert_integer "$BLOCK_SIZE" "BLOCK_SIZE" || return 1
    assert_integer "$HARM_PART_NUM" "HARM_PART_NUM"|| return 1
    assert_integer "$HARM_PART_START" "HARM_PART_START" || return 1
    assert_integer "$HARM_PART_END" "HARM_PART_END" || return 1
    assert_integer "$HARM_PART_SIZE" "HARM_PART_SIZE" || return 1
    assert_integer "$BLOCKS_PER_MEG" "BLOCKS_PER_MEG" || return 1
    if [ -n "$ALTOS_PART_NUM" ]; then
        assert_integer "$ALTOS_PART_NUM" "ALTOS_PART_NUM" || return 1
        assert_integer "$ALTOS_PART_START" "ALTOS_PART_NUM" || return 1
        assert_integer "$ALTOS_PART_END" "ALTOS_PART_NUM" || return 1
        assert_integer "$ALTOS_PART_SIZE" "ALTOS_PART_SIZE" || return 1
    fi
}

umount_if_mounted() {
    mount | grep -w -q $1
    if [ $? -eq 0 ]; then
        umount $1
        if [ $? -ne 0 ]; then
            echo "ERROR: Unmounting '$1' failed!"
            return 1
        fi
    fi
    return 0
}

create_altos_part() {
    if [ -b $1 ]; then
        ### Get info
        BLK_DEV=$1
        get_partinfo $BLK_DEV || return 1
        if [ -n "$ALTOS_PART_NUM" ]; then
            echo "ERROR: Alt_OS partition already exists!"
            return 1
        fi

        NEWPART_SIZE=$((4000*$BLOCKS_PER_MEG))  # size of the partition to-be-created
        HARM_PART_NEWEND=$(($HARM_PART_END-$NEWPART_SIZE))
        HARM_PART_DEV="$BLK_DEV"p"$HARM_PART_NUM"

        ### Unmount Harmattan user partition
        umount_if_mounted $HARM_PART_DEV || return 1

        ### Check free space in Harmattan user part
        TMP_MOUNT=$(mktemp -d)
        mount -o ro $HARM_PART_DEV $TMP_MOUNT || {
            echo "ERROR: mount failed, cannot check free space"
            return 1
        }
        HARM_FREE_SPACE=`df -B $BLOCK_SIZE $HARM_PART_DEV | awk -F ' ' '{ if (NR == 2) {print $4} }'`
        umount $TMP_MOUNT || echo "WARNING: umount failed, but continuing as RO mount..."

        ### Calculate and check partition sizes and limits
        MIN_HARM_FREE_SPACE=$(($NEWPART_SIZE+500*$BLOCKS_PER_MEG))  # require 500 Megs empty space
        MIN_HARM_PART_SIZE=$(($NEWPART_SIZE+3000*$BLOCKS_PER_MEG))  # require 3000 Megs after re-partition
        if [ $HARM_PART_SIZE -gt $MIN_HARM_PART_SIZE -a $HARM_FREE_SPACE -gt $MIN_HARM_FREE_SPACE ]; then
            ### Re-size
            parted -s -m $BLK_DEV unit s resize $HARM_PART_NUM $HARM_PART_START $HARM_PART_NEWEND || {
                echo "FATAL: resizing of Harmattan User partition failed!"
                return 2
            }

            ### Create new Alt_OS partition
            # note: HARM_PART_END is now the "OLDEND"
            parted -s -m $BLK_DEV unit s mkpart primary $(($HARM_PART_NEWEND+1)) $HARM_PART_END || {
                echo "FATAL: creation of Alt_OS partition failed!"
                return 2
            }

            ### Create filesystem for Alt_OS
            get_partinfo $BLK_DEV || {
                echo "FATAL: could not re-read partition information"
                return 2
            }
            assert_integer $ALTOS_PART_NUM "ALTOS_PART_NUM" || {
                echo "FATAL: unable to find number of the Alt_OS partition! Very strange, this shouldn't happen..."
                return 2
            }
            mkfs.ext4 -L 'Alt_OS' $BLK_DEV"p"$ALTOS_PART_NUM || {
                echo "FATAL: creation of filesystem on Alt_OS partition failed!"
                return 2
            }
        else
            echo "ERROR: Limits for Harmattan User partition could not be satisfied!"
            echo "       Part size: $HARM_PART_SIZE  Required min part size: $MIN_HARM_PART_SIZE"
            echo "       Free space: $HARM_FREE_SPACE  Required min free space: $MIN_HARM_FREE_SPACE"
            return 1
        fi
    else
        echo "ERROR: dev node ($1) doesn't exist!"
        return 1
    fi

    return 0
}

delete_altos_part() {
    if [ -b $1 ]; then
        ### Get info
        BLK_DEV=$1
        get_partinfo $BLK_DEV || return 1
        if [ -z "$ALTOS_PART_NUM" ]; then
            echo "ERROR: $ALTOS_PART_NUMth (Alt_OS) partition does not exist!"
            return 1
        fi
        ALTOS_PART_DEV="$BLK_DEV"p"$ALTOS_PART_NUM"

        ### Unmount
        umount_if_mounted $ALTOS_PART_DEV || return 1

        ### Remove the "Alt_OS" partition
        parted -s -m $BLK_DEV rm $ALTOS_PART_NUM || {
            echo "FATAL: removal of Alt_OS partition failed!"
            return 2
        }

        ### Resize the Harmattan partition
        parted -s -m $BLK_DEV unit s resize $HARM_PART_NUM $HARM_PART_START $ALTOS_PART_END || {
            echo "FATAL: resizing of Harmattan User partition failed!"
            return 2
        }
        echo "Removal of Alt_OS partition completed successfully!"
    else
        echo "ERROR: dev node ($1) doesn't exist!"
        return 1
    fi
    return 0
}

print_vars() {
    # Init all variables
    echo "BLOCK_SIZE=$BLOCK_SIZE"
    echo "HARM_PART_NUM=$HARM_PART_NUM"
    echo "HARM_PART_START=$HARM_PART_START"
    echo "HARM_PART_END=$HARM_PART_END"
    echo "HARM_PART_SIZE=$HARM_PART_SIZE"
    echo "ALTOS_PART_NUM=$ALTOS_PART_NUM"
    echo "ALTOS_PART_START=$ALTOS_PART_START"
    echo "ALTOS_PART_END=$ALTOS_PART_END"
    echo "ALTOS_PART_SIZE=$ALTOS_PART_SIZE"
    echo "BLOCKS_PER_MEG=$BLOCKS_PER_MEG"
}

print_usage() {
cat << EOF
usage: $PROG COMMAND DEVICE

Automatically re-partition device for AlternateOS.

COMMANDS:
   create   create partition for AlternateOS
   delete   delete AlternateOS partition
   check    check if the AlternateOS partition is present
   print    print partition information
   help     print this help
EOF
}

if [ "$1" == "help" ]; then
    print_usage
    exit 0
fi

if [ $# -lt 2 ]; then
    print_usage
    exit 1
fi

case "$1" in
    create)
        create_altos_part "$2" || exit $?
        ;;
    delete)
        delete_altos_part "$2" || exit $?
        ;;
    check)
        get_partinfo "$2"  || exit $?
        # Check that the partition number is an integer
        [ -n "$ALTOS_PART_NUM" -a $ALTOS_PART_NUM -eq $ALTOS_PART_NUM ] || exit 1
        ;;
    print)
        get_partinfo "$2"  || exit $?
        print_vars
        ;;
    *)
        print_usage
        exit 1
esac

exit 0
