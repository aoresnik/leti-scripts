#! /bin/bash

MY_PATH=`realpath $0 | xargs dirname`
cd $MY_PATH

export RAID_OK=true

for RAID_ARRAY in /dev/md?*; do
    if /sbin/mdadm -D -t --brief $RAID_ARRAY; then
        echo RAID OK
    else
        echo RAID NOT OK
	RAID_OK=false
    fi
done

if [ "$RAID_OK" != "true" ]; then
    ./raid_error_beep.sh
fi
