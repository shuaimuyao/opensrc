#!/bin/sh
setprop persist.sys.ywlog.enable yes
YWLOGPATH=/mnt/sdcard2/ywlog/android
SRCLOGPATH=/mnt/sdcard2/ywlog/kernel
YWLOGBACK=/mnt/sdcard2/logback
LOGTYPE=androidlog
count=0
filepath=$YWLOGPATH/$LOGTYPE.txt
LOGLEVEL=I

if [ ! -d $YWLOGPATH ]
then
    mkdir -p $YWLOGPATH
    chmod -R 666 $YWLOGPATH
    chmod 775 $YWLOGPATH
else
    path=$YWLOGBACK/back_`date "+%Y-%m-%d-%H-%M"`
    mkdir -p $path
    cp -rf $SRCLOGPATH $path
    cp -rf $YWLOGPATH $path
    rm $YWLOGPATH/*
    rm $SRCLOGPATH/*
fi

while [ : ]
do
if [ `getprop "persist.sys.ywlog.enable"` = "yes" ];then 
    LOGLEVEL=`getprop "persist.sys.ywlog.level"`
    if [ ! "$LOGLEVEL" ];then
        LOGLEVEL=I
    fi
    if [ -e $filepath ];then
    filesize=`du -sm $filepath | busybox awk '{print $1}'`
    else
    if [ count -eq 1 ];then
        mkdir -p $YWLOGPATH
        chmod -R 666 $YWLOGPATH
        chmod 775 $YWLOGPATH
        logcat -vtime -s "*:$LOGLEVEL" > $filepath &
    fi
    filesize=0
    fi
    if [ $filesize -gt 10 -o $count -eq 0 ]
    then
        if [ $count -eq 0 ];then
    	    logcat -vtime -s "*:$LOGLEVEL" > $filepath &
            chmod 666 $filepath
            count=1
        else
            logpid=`busybox pidof logcat`
            kill -9 $logpid
            wait
            busybox fuser -k $filepath
            wait
            LOGTMPNM=$YWLOGPATH/$LOGTYPE`date "+%Y-%m-%d-%H-%M"`.log
    	    mv $filepath $LOGTMPNM
            chmod 666 $LOGTMPNM
            logcat -vtime -s "*:$LOGLEVEL" > $filepath &
            chmod 666 $filepath
        fi
    fi
    sleep 20
else
    if [ $count -eq 1 ];then
        count=0
        logpid=`busybox pidof logcat`
        kill -9 $logpid
    	wait
    	busybox fuser -k $filepath
    	wait
    	mv $filepath $YWLOGPATH/$LOGTYPE`date "+%Y-%m-%d-%H-%M"`.log
    fi
    sleep 10
fi
done





