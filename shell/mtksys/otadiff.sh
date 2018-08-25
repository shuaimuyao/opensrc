#!/bin/bash

OTADIFFTOOL=build/tools/releasetools/ota_from_target_files
ANDROID_SRC=../src
PATHMID=`pwd`
PATHOTADIFF=../ota_df
SIGNAPK=out/host/linux-x86/framework/signapk.jar
SCATFILE=out/target/product/tdc1602/ota_scatter.txt
UPDATEP=uptmp
MIDUPDATE=midupdate
OEMFILE=customer
OEMPATH=oemfile
MIDUPZIP=update_m.zip
SECZIP=update_sec.zip
READLINE=out/readline
SCRIPTF=uptmp/midupdate/META-INF/com/google/android/updater-script

BINQXCHMD='assert(run_program("/sbin/busybox","chmod","755","YWBINFPATH"));'
YUWEICG='assert(run_program("/sbin/busybox","dd","if=/system/data/yuwei.img","of=/dev/block/platform/mtk-msdc.0/by-name/yuwei"));'
OEMSTR='package_extract_dir("customer", "/system");'
APPMDCG='assert(run_program("/sbin/busybox","chmod","-R","755","/system/priv-app/YW_CommLibMain"));'
ADDSYNC='assert(run_program("/sbin/busybox","sync"));'
ADDSLEEP='assert(run_program("/sbin/busybox","sleep","5"));'

if [ $# -ne 3 ];then
    echo "usage:"
    echo "$0 ac/cf/xsj oldver newver"
    echo "oldver is full_tdc1602-target_files-170810-20-12e.zip newver is full_tdc1602-target_files-170818-20-130.zip for example"
    exit 2
fi

if [ ! -d $OEMPATH/$1/$OEMFILE ];then
    echo "error $OEMPATH/$1/$OEMFILE file not exist"
    exit 5
fi

case $1 in
    ac|AC )
    nmstr=update_ac_OLDVER_NEWVER_57701_CHKSUM.zip
    VERSIONSTR=pdc1601_user_TIMESTR_57701_2.0_SFVER
    ;;
    cf|CF )
    nmstr=update_cf_OLDVER_NEWVER_57702_CHKSUM.zip
    VERSIONSTR=pdc1601_user_TIMESTR_57702_2.0_SFVER
    ;;
    xsj|XSJ )
    nmstr=update_xsj_OLDVER_NEWVER_57704_CHKSUM.zip
    VERSIONSTR=pdc1601_user_TIMESTR_57704_2.0_SFVER
    ;;
    yc|YC )
    nmstr=update_yc_OLDVER_NEWVER_57705_CHKSUM.zip
    VERSIONSTR=pdc1601_user_TIMESTR_57705_2.0_SFVER
    ;;
    ykx|YKX )
    nmstr=update_ykx_OLDVER_NEWVER_57703_CHKSUM.zip
    VERSIONSTR=pdc1601_user_TIMESTR_57703_2.0_SFVER
    ;;
    qdhx|QDHX )
    nmstr=update_qdhx_OLDVER_NEWVER_57710_CHKSUM.zip
    VERSIONSTR=pdc1601_user_TIMESTR_57710_2.0_SFVER
    ;;
    dhkj|DHKJ )
    nmstr=update_dhkj_OLDVER_NEWVER_57715_CHKSUM.zip
    VERSIONSTR=pdc1601_user_TIMESTR_57715_2.0_SFVER
    ;;
    dhkj_rc|DHKJ_RC )
    nmstr=update_dhkj_OLDVER_NEWVER_57717_CHKSUM.zip
    VERSIONSTR=pdc1601_user_TIMESTR_57717_2.0_SFVER
    ;;
    nj-zxwx )
    nmstr=update_dhkj_OLDVER_NEWVER_57719_CHKSUM.zip
    VERSIONSTR=pdc1601_user_TIMESTR_57719_2.0_SFVER
    ;;
    * )
        echo "no this oem targe $1"
        exit 7
    ;;
esac

if [ ! -d $ANDROID_SRC ];then
    echo "android src not exit"
    exit 1
fi

if [ ! -e $UPDATEP ]
then
    mkdir -p $UPDATEP
else
    rm -rf $UPDATEP
    mkdir -p $UPDATEP
fi

pushd $ANDROID_SRC
if [ ! -e $SCATFILE ];then
    cp -adr ../ota_df/out/* out/
fi
. build/envsetup.sh >/dev/null 2>&1
lunch >/dev/null 2>&1 <<TAKETYPE
full_br6735_66t_l1-eng
TAKETYPE
$OTADIFFTOOL -v -i $PATHOTADIFF/$2 $PATHOTADIFF/$3 $PATHOTADIFF/$UPDATEP/update.zip
popd

if [ ! -e $UPDATEP/update.zip ];then
    echo "error update.zip not exist"
    rm -rf $UPDATEP
    exit 1
fi

if [ ! -e $UPDATEP/$MIDUPDATE ];then
    mkdir -p $UPDATEP/$MIDUPDATE
else
    rm -rf $UPDATEP/$MIDUPDATE
    mkdir -p $UPDATEP/$MIDUPDATE
fi
unzip $UPDATEP/update.zip -d $UPDATEP/$MIDUPDATE

if [ ! -e "$SCRIPTF" ]
then
    echo "file $SCRIPTF not exist"
    rm -rf $UPDATEP
    exit 2
fi

delapplychk(){
    if [ $# -ne 1 ];then
	 echo "must one arg in $0"
         return 3
    fi
    sed -i "/apply_patch_check.*$1/d" $SCRIPTF
}

delapplypkg(){
    declare -i startl
    declare -i endl
    if [ $# -ne 1 ];then
	 echo "must one arg in $0"
         return 3
    fi
    linedp=`cat $SCRIPTF | grep -nE "apply_patch[^_].*$1|package_extract_file.*$1" | awk -F ":" '{print $1}'`
    linedpn=`cat $SCRIPTF | grep -nE "apply_patch[^_].*$1|package_extract_file.*$1" | awk -F ":" '{print $1}' | wc -l`
    if [ $(($linedpn%2)) -ne 0 ];then
        echo "error mode match $1"
        exit 3
    fi
    if [ $linedpn -eq 2 ];then
	echo "one patch used $1"
	startl=`echo $linedp | awk '{print $1}'`
    	endl=`echo $linedp | awk '{print $2}'`
    	if [ $(($endl-$startl)) -gt 5 ];then
        	echo "some error delete patch $1 when delete apply patch line num bigger then 4"
        	exit 5
    	fi
    	sed -i "${startl},${endl}d" $SCRIPTF
    elif [ $linedpn -eq 4 ];then
        echo "two patch used $1"
	startl=`echo $linedp | awk '{print $1}'`
    	endl=`echo $linedp | awk '{print $2}'`
    	if [ $(($endl-$startl)) -gt 5 ];then
        	echo "some error delete patch $1 when delete apply patch line num bigger then 4"
        	exit 5
    	fi
    	sed -i "${startl},${endl}d" $SCRIPTF

	delapplypkg $1
    elif [ $linedpn -eq 0 ];then
        echo "no patch apply in this script $1"
    else
        cat $SCRIPTF | grep -nE "apply_patch[^_].*$1|package_extract_file.*$1"
        echo "some error in apply patch $1,because more than two patch used $linedpn"
	exit 4
    fi
}

delsetmeta(){
    sed -i "/set_metadata/d" $SCRIPTF
}
delfpprop(){
    sed -i '/ro.build.fingerprint/d' $SCRIPTF
}
addcustorm(){
    sed -i "/Patching remaining system files/a$OEMSTR" $SCRIPTF
}

addywimg(){
    sed -i "/package_extract_dir.*customer/a$YUWEICG" $SCRIPTF
}

addapkcg(){
    sed -i "/package_extract_dir.*customer/a$APPMDCG" $SCRIPTF
}

addsync(){
    sed -i "/unmount.*system/i$ADDSYNC" $SCRIPTF
}

addsleep(){
    sed -i "/unmount.*system/i$ADDSLEEP" $SCRIPTF
}

addcustflag(){
    sed -i "/busybox.*sync/r$READLINE" $SCRIPTF
}

addmodechg(){
    if [ $# -ne 1 ];then
	 echo "must one arg in $0"
         return 3
    fi
    addstr=${BINQXCHMD/YWBINFPATH/$1}
    #innum=`cat $SCRIPTF | grep -n "Patching remaining system files" | awk -F ":" '{print $1}'`
    sed -i "/package_extract_dir.*customer/a$addstr" $SCRIPTF
}

cp -adr $OEMPATH/$1/$OEMFILE $UPDATEP/$MIDUPDATE

OLDVERSTRM=${2##*-}
OLDVERSTR=${OLDVERSTRM%%.*}
NEWVERSTRM=${3##*-}
NEWVERSTR=${NEWVERSTRM%%.*}
nmps=${nmstr/OLDVER/$OLDVERSTR}
nmpt=${nmps/NEWVER/$NEWVERSTR}

T4PTIME=`echo $3 | awk -F "-" '{print $3}'`
MIDVERS=`echo $3 | awk -F "-" '{print $5}'`
VERNOTDOT=${MIDVERS%.*}
VERDOT=${VERNOTDOT:0:1}\.${VERNOTDOT:1:1}\.${VERNOTDOT:2}
MVERSTR=${VERSIONSTR/TIMESTR/$T4PTIME}
T4VERSIONSTR=${MVERSTR/SFVER/$VERDOT}
lentmstr=${#T4PTIME}
lenverstr=${#VERDOT}
if [ $lentmstr -ne 6 ];then
    echo "name of $3 is error type"
    exit 8
fi
if [ $lenverstr -ne 5 ];then
    echo "name of $3 is error type"
    exit 8
fi
#add build.prop
PROPTMP=/tmp/newtdcver
mkdir -p $PROPTMP
unzip $3 -d $PROPTMP
cp $PROPTMP/SYSTEM/build.prop $UPDATEP/$MIDUPDATE/$OEMFILE/
rm -rf $PROPTMP
t4time=`date -R`
sed -i "s/ro.build.date=.*/ro.build.date=$t4time/" $UPDATEP/$MIDUPDATE/$OEMFILE/build.prop
sed -i "s/ro.mediatek.version.release=.*/ro.mediatek.version.release=$T4VERSIONSTR/" $UPDATEP/$MIDUPDATE/$OEMFILE/build.prop

delsetmeta
delfpprop
custormf=`find $UPDATEP/$MIDUPDATE/$OEMFILE -type f`
patchf=`find $UPDATEP/$MIDUPDATE/patch/system -type f`
for ywf in $custormf
do
    filenm=`basename $ywf`
    retf=`echo $patchf | grep "$filenm"`
    if [ "$retf" ];then
        echo "$filenm"
        delapplychk $filenm
        delapplypkg $filenm
    fi
done
if [ $1 = "xsj" -o $1 = "dhkj" -o $1 = "dhkj_rc" ];then
    delapplychk Dialer.apk
    delapplychk Dialer.odex
    delapplypkg Dialer.apk
    delapplypkg Dialer.odex
fi
if [ $1 != "cf" ];then
    delapplychk epu_helper
    delapplypkg epu_helper
fi
addcustorm
if [ -d $UPDATEP/$MIDUPDATE/$OEMFILE/bin ]
then
    binf=`find $UPDATEP/$MIDUPDATE/$OEMFILE/bin -type f`
    for bf in $binf
    do
        bname=`basename $bf`
        addmodechg /system/bin/$bname
    done
fi

addywimg
addapkcg
addsync
addcustflag
addsync
addsleep
pushd $UPDATEP/$MIDUPDATE
    zip $MIDUPZIP * -r
popd

if [ -e $ANDROID_SRC/$MIDUPZIP ];then
    rm $ANDROID_SRC/$MIDUPZIP
fi

cp $UPDATEP/$MIDUPDATE/$MIDUPZIP $ANDROID_SRC/
pushd $ANDROID_SRC
    java -Xmx2048m -jar out/host/linux-x86/framework/signapk.jar -w build/target/product/security/testkey.x509.pem build/target/product/security/testkey.pk8  $MIDUPZIP $SECZIP
    mv $SECZIP $PATHMID/$SECZIP
    sync
    rm $MIDUPZIP $SECZIP
popd


checksumstr=`md5sum $SECZIP |awk '{print $1}'`
targnm=${nmpt/CHKSUM/$checksumstr}

if [ ! -e $SECZIP ];then
    echo "error sign for $SECZIP"
    exit 9
fi

mv $SECZIP $targnm
sync
rm -rf $UPDATEP

echo "done"
























