#!/bin/sh
YWLOGBACK=/mnt/sdcard2/logback
YWLOGPATH=/mnt/sdcard2/ywlog

ANDLOGPATH=/mnt/sdcard2/ywlog/android
KERLOGPATH=/mnt/sdcard2/ywlog/kernel
MALOGPATH=/mnt/sdcard2/ywlog/ma

if [ ! -d $YWLOGPATH ]
then
    mkdir -p $YWLOGPATH
    chmod 775 $YWLOGPATH
fi
checktf(){
    line=`df | grep "/storage/sdcard1"|busybox wc -l`
    if [ $line -gt 0 ];then
	return 0
    else
        return 1
    fi
}

# tffree tfused
getspace(){
    space=0
    if [ $1 = "tffree" ];then
        FREESTR=`df | grep "/storage/sdcard1" | busybox awk '{print $4}'`
    else
    	FREESTR=`df | grep "/storage/sdcard1" | busybox awk '{print $3}'`
    fi
    lenstr=${#FREESTR}
    potunit=$((lenstr-1))
    unit=${FREESTR:$potunit:1}
    spstr=${FREESTR%.*}
    if [ $unit = "G" ];then
	space=$(($spstr*1000))
    elif [ $unit = "M" ];then
	space=$spstr
    else
	space=0
    fi
    echo "$space"
    return $space
}

getlogsize(){
    logbacksz=0
    logandsz=0
    if [ -d $YWLOGBACK ];then
        logbacksz=`du -sm $YWLOGBACK | busybox awk '{print $1}' `
    fi
    if [ -d $YWLOGPATH ];then
	logandsz=`du -sm $YWLOGPATH | busybox awk '{print $1}'`
    fi
    logallsz=$(($logbacksz+$logandsz))
    echo "$logallsz"
    return $logallsz
}

delmalog(){
    if [ -d $MALOGPATH ];then
        malogsz=`du -sm $MALOGPATH | busybox awk '{print $1}'`
        if [ $malogsz -gt 2000 ];then
	    delfile=$MALOGPATH/`busybox ls -rt $MALOGPATH | grep -v "uid*" | busybox head -1`
            rm $delfile
        fi
    fi
}

delfile(){
    if [ -d $YWLOGBACK ];then
	span=`du -sm $YWLOGBACK | busybox awk '{print $1}'`
        if [ span -gt 10 ];then
           delpath=$YWLOGBACK/`ls $YWLOGBACK | busybox awk 'NR==1{print}'`
	   if [ `du -sm $delpath | busybox awk '{print $1}'` -gt 10 ];then
		if [ -d $delpath/android ];then
		if [ `du -sm $delpath/android | busybox awk '{print $1}'` -gt 0 ];then
		    delfile=$delpath/android/`busybox ls -rt $delpath/android | busybox head -1`
                    rm -rf $delfile
		fi
		fi
		if [ -d $delpath/kernel ];then
		if [ `du -sm $deland/kernel | busybox awk '{print $1}'` -gt 0 ];then
		    delfile=$delpath/kernel/`busybox ls -rt $delpath/kernel | busybox head -1`
                    rm -rf $delfile
		fi
		fi
	   else
		rm rf $delpath
   	   fi
        else
	   rm -rf $YWLOGBACK
	fi
    else
	if [ -d $ANDLOGPATH ];then
           andlognum=`ls $ANDLOGPATH | busybox wc -l`
	   if [ $andlognum -gt 10 ];then
	       delfile=$ANDLOGPATH/`busybox ls -rt $ANDLOGPATH | busybox head -1`
               rm $delfile
           fi
	fi
	if [ -d $KERLOGPATH ];then
	   kerlognum=`ls $KERLOGPATH | busybox wc -l`
           if [ $kerlognum -gt 10 ];then
		kerfile=$KERLOGPATH/`busybox ls -rt $KERLOGPATH | busybox head -1`
                rm $kerfile
           fi
	fi
    fi
    delmalog
}

while [ : ]
do
    checktf
    if [ $? -eq 1 ];then
	echo "no tf card in t4"
        sleep 20
        continue
    fi
    tffreesz=`getspace tffree`
    if [ $tffreesz -gt 8000 ];then
        sleep 20
        continue
    fi
    logsz=`getlogsize`
    if [ $logsz -gt 5 ];then
	delfile
    fi
    sleep 5
done











