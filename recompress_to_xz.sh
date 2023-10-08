#! /bin/bash

# KNOWN BUGS:
# - Does not delete partial destination file on failure

# Fail entire pipe if any element fails
set -o pipefail

RECOMPRESS_DELETE=f
RECOMPRESS_PARALLEL=f

if [ "$1" != "" ]; then
    for PARAM in "$@"; do
        BASENAME=""
        case $PARAM in
            *.lzop)
                ORIG_FILE=$PARAM
                BASENAME=`basename "$ORIG_FILE" .lzop`
                function decomp_func() {
                    lzop -d
                }
                ;;
            *.gz)
                ORIG_FILE=$PARAM
                BASENAME=`basename "$ORIG_FILE" .gz`
                function decomp_func() {
                    gzip -d
                }
                ;;
            *.bz2)
                ORIG_FILE=$PARAM
                BASENAME=`basename "$ORIG_FILE" .bz2`
                function decomp_func() {
                    bzip2 -d
                }
                ;;
            --delete)
                RECOMPRESS_DELETE=t
                ;;
            -p)
                RECOMPRESS_PARALLEL=t
                ;;
            *)
                echo Unknown file type: $ORIG_FILE
                BASENAME=""
                function decomp_func() {
                    echo ""
                }
                exit 1
                ;;
        esac

        if [ -n "$BASENAME" ]; then

            FILE_SUFFIX=xz
            function comp_decomp_func() {
                xz -d
            }
            if [ $RECOMPRESS_PARALLEL = t ]; then
                function comp_func() {
                    nice -n 10 pxz 
                }
            else
                function comp_func()  {
                    nice -n 10 xz
                }
            fi

            DEST_FILE="$(dirname $ORIG_FILE)/${BASENAME}.${FILE_SUFFIX}"
            echo "Recompressing $ORIG_FILE to $DEST_FILE"
            if pv "$ORIG_FILE" | decomp_func | comp_func > "$DEST_FILE"; then
                ls -la "$ORIG_FILE" "$DEST_FILE"
                echo "Checking correctness ..."
                # md5sum is sufficient (and faster than more secure hashes) because we try to catch data errors, not malicious changes
                echo "$ORIG_FILE"
                ORIG_FILE_HASH=`pv "$ORIG_FILE" | decomp_func | md5sum`
                echo "$DEST_FILE"
                DEST_FILE_HASH=`pv "$DEST_FILE" | comp_decomp_func | md5sum`

                if [ "$ORIG_FILE_HASH" == "$DEST_FILE_HASH" ]; then
                    echo "Files decompress to identical content (hash: $ORIG_FILE_HASH)"
                    if [ "$RECOMPRESS_DELETE" == "t" ]; then
                        echo "Deleting $ORIG_FILE"
                        rm $ORIG_FILE
                    else
                        echo "Not deleting $ORIG_FILE, because --delete flag was not specified"
                    fi
                else
                   echo "Decompressed file contents differ: orig file hash: $ORIG_FILE_HASH, recompressed file hash: $DEST_FILE_HASH"
                fi
            else
                echo Failed to recompress $ORIG_FILE to $DEST_FILE
            fi
        fi
    done
else
    echo "Usage: $0 [ -p | --delete ] file-name.{lzop|gz|bz2} ..."
    echo ""
    echo "Recompresses the input file to .xz format and checks if the MD5 hashes match."
    echo "Intented for larger files on potentially unreliable media (such as backups on USB drives)."
    echo "Intented to process entire directory at once - output file name is the same as input file,"
    echo "but with .xz suffix. Shows progress for each file with pv."
    echo ""
    echo "Options:"
    echo " -p        Use parallel compression (pxz)"
    echo " --delete  Delete the source file after successful recompression"
    exit 127
fi

