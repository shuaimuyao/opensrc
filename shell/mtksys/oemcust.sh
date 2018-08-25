#!/bin/bash
#create by shuaifei 20170704
TORAWCMD=simg2img
TODOWNCMD=img2simg
TOSDATCMD=img2sdat.py
TMP=sys
SHPATH=`pwd`
#TARGET=custom
SYSPACK=system.img
RAWPACK=system_raw.img
OEMPACK=system_custom.tar.gz
OEMIMG=systemoem.img
OTAPCKPATH=ota_package
SDATPATH=dstdat
LOGOPATH=bootlogo
#: ${ANDROIDRDIR="${ANDROID_BUILD_TOP-/home/shuaifei/work/package_t4mtk_160725/src}"}
: ${ANDROIDRDIR="${ANDROID_BUILD_TOP-../src}"}
SYSRMFILE=removefile
YWIMGPATH=../yuweifs
YWNEEDUP=no
TOKEN=761db61df6a0b4e701fbc262cf89be13cb50ea86

if [ `id -u` -ne 0 ]
then
	echo "must sudo exec!"
	exit 1
fi

if [ $# -ne 4 ]
then
    echo "usage:"
    echo "$0 ac/cf version date TOKEN"
    echo "version is 1.2.d for example, 170731 for date example"
    exit 1
fi

if [ $4 != $TOKEN ];then
    echo "user onekeyoem.sh shell"
    exit 9
fi

if [ $1 = "ac" -o $1 = "cf" -o $1 = "ykx" -o $1 = "yc" -o \
$1 = "xsj" -o $1 = "bz" -o $1 = "original" -o $1 = "mntk" \
-o $1 = "qdhx" -o $1 = "f8" -o $1 == "gb" -o $1 = "cf905" -o \
$1 = "szb" -o $1 = "sd" -o $1 = "czbdx" -o $1 = "dhkj" -o $1 = "sh_ydxx" -o $1 = "dhkj_rc" -o $1 = "wh-sfkj" \
-o $1 = "nj-zxwx" ]
then
    if [ $1 = "ac" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57701_2.0_SFVER
    elif [ $1 = "cf" -o $1 = "cf905" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57702_2.0_SFVER
    elif [ $1 = "ykx" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57703_2.0_SFVER
    elif [ $1 = "xsj" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57704_2.0_SFVER
    elif [ $1 = "bz" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57706_2.0_SFVER
    elif [ $1 = "original" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57707_2.0_SFVER
    elif [ $1 = "sd" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57708_2.0_SFVER
    elif [ $1 = "mntk" ];then
	CFVERSIONSTR=pdc1601_user_TIMESTR_57709_2.0_SFVER
    elif [ $1 = "qdhx" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57710_2.0_SFVER
    elif [ $1 = "f8" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57711_2.0_SFVER
    elif [ $1 = "gb" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57712_2.0_SFVER
    elif [ $1 = "szb" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57713_2.0_SFVER
    elif [ $1 = "czbdx" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57714_2.0_SFVER
    elif [ $1 = "dhkj" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57715_2.0_SFVER
    elif [ $1 = "sh_ydxx" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57716_2.0_SFVER
    elif [ $1 = "dhkj_rc" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57717_2.0_SFVER
     elif [ $1 = "wh-sfkj" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57718_2.0_SFVER
    elif [ $1 = "nj-zxwx" ];then
        CFVERSIONSTR=pdc1601_user_TIMESTR_57719_2.0_SFVER
    else
        CFVERSIONSTR=pdc1601_user_TIMESTR_57705_2.0_SFVER
    fi
    MIDVERSIONSTR=${CFVERSIONSTR/SFVER/$2}
    T4VERSIONSTR=${MIDVERSIONSTR/TIMESTR/$3}
else
    echo "must ac or cf for ancai and chengfang"
    exit 2
fi
if [ -e $1/data/yuwei.img -a -d $YWIMGPATH/$1 ];then
    fileinywfs=`find $YWIMGPATH/$1 -type f`
    for maf in $fileinywfs
    do
        if [ $maf -nt $1/data/yuwei.img ];then
            YWNEEDUP=yes
            break
        fi
    done
fi
if [ $YWNEEDUP = "yes" ];then
    pushd $YWIMGPATH
        ./oemywimg.sh $1
    popd
fi

if [ ! -e $SYSPACK ]
then 
	echo "file not exist"
	exit 2
fi

if [ ! -d $1 ]
then
	echo "not custom file!"
	exit 3
fi

if [ -e $TMP ]
then
	rm -rf $TMP
	mkdir -p $TMP
else
	mkdir -p $TMP
fi

if [ -e $SDATPATH ]
then
	rm -rf $SDATPATH
	mkdir -p $SDATPATH
else
	mkdir -p $SDATPATH
fi

./$TORAWCMD $SYSPACK $RAWPACK
mount -t ext4 -o loop $RAWPACK $TMP
#chmod 0755 $TMP/bin/*
if [ "$SYSRMFILE" ]
then
        #rm -rf $TMP/priv-app/Dialer/*
	#echo "rm dialer file in $TMP/priv-app/Dialer/"
        if [ $1 = "ac" -o $1 = "xsj" -o $1 = "bz" -o $1 = "ykx" -o $1 = "original" -o $1 = "qdhx" -o $1 = "wh-sfkj" -o \
           $1 = "f8" -o $1 == "gb" -o $1 = "szb" -o $1 = "sd" -o $1 = "dhkj" -o $1 = "sh_ydxx" -o $1 = "dhkj_rc" -o $1 = "nj-zxwx" ];then
            rm $TMP/bin/epu_helper
			rm -rf $TMP/media/audio/notifications/
			#rm $TMP/media/audio/notifications/pixiedust.ogg
			#rm $TMP/media/audio/notifications/OnTheHunt.ogg
			#rm $TMP/media/audio/notifications/Merope.ogg
        fi
		
		if [ $1 = "ac" -o $1 = "xsj" -o $1 = "bz" ];then
            rm -rf $TMP/priv-app/Dialer/
        fi
		
		#if [ $1 = "cf905" ];then
		#	rm -rf $TMP/app/YW_XfyNote
		#	rm -rf $TMP/priv-app/Dialer/
        #fi
		
		if [ $1 = "cf"  ];then
			rm -rf $TMP/app/YW_XfyNote
			rm -rf $TMP/media/audio/notifications/
			rm -rf $TMP/priv-app/Dialer/
        fi
		
		if [ $1 = "czbdx" ];then
			rm -rf $TMP/app/YW_XfyNote
			rm -rf $TMP/media/audio/notifications/
        fi
		
		if [ $1 = "original" ];then
			rm -rf $TMP/priv-app/Dialer/
        fi
		
		if [ $1 = "gb" ];then
			rm -rf $TMP/priv-app/Dialer/
        fi
fi

if [ -d $1 ]
then
	cp -adr $1/* $TMP/
else
	#tar -xf $OEMPACK
	#cp -adr $1/* $TMP/
	echo "must package for $1"
        exit 4
fi

if [ "$T4VERSIONSTR" ]
then
    t4time=`date -R`
    sed -i "s/ro.build.date=.*/ro.build.date=$t4time/" $TMP/build.prop
    sed -i "s/ro.mediatek.version.release=.*/ro.mediatek.version.release=$T4VERSIONSTR/" $TMP/build.prop
fi
chmod 0755 $TMP/bin/*
sync
umount $TMP
rm -rf $TMP
./$TODOWNCMD $RAWPACK $OEMIMG
rm -rf $RAWPACK
rm -rf $SYSPACK
mv $OEMIMG $SYSPACK
./$TOSDATCMD $SYSPACK $SDATPATH 2
if [ ! -d $ANDROIDRDIR ]
then
	echo "not exec setupenv.sh"
	exit 3
fi

pushd $ANDROIDRDIR
if [ ! -d $OTAPCKPATH ]
then 
	mkdir -p $OTAPCKPATH
fi
zipnum=`find $SHPATH -name "*.zip" -type f | grep "pdc1601_userota" | wc -l`
if [ $zipnum -ne 1 ]
then 
	echo "must ota zip file copy to this path or only one zip file in this path"
	exit 4
fi
unzip `find $SHPATH -name "*.zip" -type f | grep "pdc1601_userota"` -d $OTAPCKPATH
cp -adr $SHPATH/$SDATPATH/* $OTAPCKPATH/
if [ -e $SHPATH/$1/data/yuwei.img ];then
   # echo "copy yuwei.img to $$OTAPCKPATH/"
    cp $SHPATH/$1/data/yuwei.img $OTAPCKPATH/
fi
if [ -e $SHPATH/updater-script ];then
    cp -f $SHPATH/updater-script $OTAPCKPATH/META-INF/com/google/android/
fi
if [ -e $SHPATH/$LOGOPATH/$1/logo.bin ];then
    cp -f $SHPATH/$LOGOPATH/$1/logo.bin $OTAPCKPATH/
fi
pushd $OTAPCKPATH
zip update.zip * -r
popd

java -Xmx2048m -jar out/host/linux-x86/framework/signapk.jar -w build/target/product/security/testkey.x509.pem build/target/product/security/testkey.pk8  $OTAPCKPATH/update.zip $OTAPCKPATH/update_zip
mv $OTAPCKPATH/update_zip $SHPATH/update_$1_$2_$3.zip
sync
rm -rf $OTAPCKPATH
popd
rm -rf $SDATPATH

echo "done"


