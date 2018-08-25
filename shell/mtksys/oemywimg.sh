#!/bin/bash

MTCMD=mount
FSTP=ext4
MTTP=loop
MTPATH=sys
APPSETDIR=appset
OEMIMG=yuwei.img
SYSTEMOEMDIR=../sys
IFRMCLA=yes

if [ `id -u` -ne 0 ];then
    echo "must sudo exec"
    exit 1
fi

if [ $# -ne 1 ];then
    echo "usage:"
    echo "$0 version dirofcopyto"
    echo "$0 ac/bz/xsj"
fi

if [ ! -e "$OEMIMG" -o ! -d "$1" ];then
    echo "must yuwei.img and $1 in this dir"
    exit 3
fi

if [ -d "$MTPATH" ];then
    rm -rf $MTPATH
    mkdir -p $MTPATH
else
    mkdir -p $MTPATH
fi

$MTCMD -t $FSTP -o $MTTP $OEMIMG $MTPATH

FILECP=`find $1 -type f`
for ywfile in $FILECP
do
    rmfile=${ywfile/$1/$MTPATH}
    if [ -f "$rmfile" ];then
         rm $rmfile
    fi
done

cp -adr $1/* $MTPATH/
if [ $? -ne 0 ];then
    echo "fatal:fail in create yuwei image"
    exit 11
else
    chmod 0755 $MTPATH/bin/mdk_core
    chmod 0755 $MTPATH/script/*.sh
fi

if [ x$IFRMCLA = "xyes" ];then
find $MTPATH/ -name "*.cla" -exec rm {} \;
fi

umount $MTPATH
if [ -e "$OEMIMG" -a -d "$SYSTEMOEMDIR/$1/data" ];then 
    cp -f $OEMIMG $SYSTEMOEMDIR/$1/data/
fi
rm -rf $MTPATH



















