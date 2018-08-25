#!/bin/sh
setprop persist.sys.ywlog.kernel yes
YWLOGPATH=/mnt/sdcard2/ywlog/kernel
YWLOGBACK=/mnt/sdcard2/logback
LOGTYPE=kernellog
count=0
filepath=$YWLOGPATH/$LOGTYPE.txt
if [ ! -d $YWLOGPATH ]
then
    mkdir -p $YWLOGPATH
    chmod -R 666 $YWLOGPATH
    chmod 775 $YWLOGPATH
fi

while [ : ]
do
if [ `getprop "persist.sys.ywlog.kernel"` = "yes" ];then 
	if [ -e $filepath ];then
	filesize=`du -sm $filepath | busybox awk '{print $1}'`
	else
	filesize=0
	fi
	if [ $filesize -gt 10 -o $count -eq 0 ]
	then
    		if [ $count -eq 0 ];then
    		cat /proc/kmsg | grep -iE "error|fatal|tarce" > $filepath &
			chmod 666 $filepath
        	count=1
    		else
        	logpid=`busybox pidof cat`
        	if [ "$logpid" ];then
        	kill -9 $logpid
        	wait
        	busybox fuser -k $filepath
        	fi
        	TMPKLOGNM=$YWLOGPATH/$LOGTYPE`date "+%Y-%m-%d-%H-%M"`.log
    		mv $filepath $TMPKLOGNM
        	chmod 666 $TMPKLOGNM
        	cat /proc/kmsg | grep -iE "error|fatal|tarce" > $filepath &
    		fi
      else
     	logpid=`busybox pidof cat`
     	if [ "$logpid" ];then
        	sleep 10
    	else
        	cat /proc/kmsg | grep -iE "error|fatal|tarce" >> $filepath &
        	sleep 5
    	fi
     fi
else
	logpid=`busybox pidof cat`
     	if [ "$logpid" ];then
                if [ $count -eq 1 ];then
                    count=0
                fi
	    	kill -9 $logpid
        	wait
        	busybox fuser -k $filepath
        fi
        sleep 10     
fi
done




