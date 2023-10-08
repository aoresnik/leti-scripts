#! /bin/bash

# KNOWN BUGS:
# - Java-centric: skips target dirs, should skip by .gitignore

if BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD); then
    BACKUP_FILE=~/$(pwd | xargs basename)-$(date +%Y%m%d-%H%M)-${BRANCH_NAME}.tar.xz
    echo Backing up the working copy  to: ${BACKUP_FILE}
    tar cJvf ${BACKUP_FILE} --exclude "./*/target/*" .
fi
