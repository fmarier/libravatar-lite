#!/bin/bash
#
# This script needs a lot of external tools (see below)
#
# Copyright (C) 2010, 2012, 2013  Francois Marier <francois@libravatar.org>
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

if [ "z$1" = "z" -o "z$2" = "z" -o "z$3" = "z" ] ; then
    echo "Usage: $0 <original_image> <email_address> <output_extension>"
    echo "       (e.g. $0 me.jpg francois@libravatar.org jpg)"
    exit 1;
fi

ORIG_IMAGE=$1
MD5_HASH=`echo -n "$2" | md5sum | cut -f1 -d" "`
SHA256_HASH=`echo -n "$2" | sha256sum | cut -f1 -d" "`
EXTENSION=$3

DEST_DIR="avatar"

for s in {1..512} ; do
    mkdir -p $DEST_DIR/${s}
    DEST_FILE="$DEST_DIR/${s}/${MD5_HASH}"

    if [ "$EXTENSION" = "png" ] ; then
        convert $ORIG_IMAGE -resize ${s}x${s} ${DEST_FILE}.${EXTENSION}
        pngcrush -q -rem gAMA -rem alla -rem text ${DEST_FILE}.${EXTENSION} ${DEST_FILE}
        rm -f ${DEST_FILE}.${EXTENSION}
        optipng -o9 -q $DEST_FILE
        advpng -z -4 -q $DEST_FILE
    elif [ "$EXTENSION" = "jpg" ] ; then
        convert $ORIG_IMAGE -resize ${s}x${s} ${DEST_FILE}.${EXTENSION}
        mv ${DEST_FILE}.${EXTENSION} $DEST_FILE
        jpegoptim -q -p --strip-all $DEST_FILE
    fi

    # create a hardlink for the second hash
    rm -f $DEST_DIR/${s}/${SHA256_HASH}
    ln ${DEST_FILE} $DEST_DIR/${s}/${SHA256_HASH}
done
