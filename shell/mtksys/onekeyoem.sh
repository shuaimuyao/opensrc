#!/bin/bash
SYSPACK=system.img
SHPATH=`pwd`
TOKEN=761db61df6a0b4e701fbc262cf89be13cb50ea86
LOCKFILE=/tmp/oemlock.lock
FDLOCK=7
if [ `id -u` -ne 0 ]
then
	echo "must sudo exec!"
	exit 1
fi

if [ $# -ne 1 ]
then
    echo "usage:"
    echo "$0 xxx(cf/xsj/...)"
    exit 1
fi

sysSrcFileNum=`ls $SHPATH | grep "system_tdc" | wc -l`
echo sysSrcFileNum:$sysSrcFileNum


if [ $sysSrcFileNum -ne 1 ];then 
	echo "system_tdc*.img must be only one."
	exit 1
fi

sysSrcFile=`ls $SHPATH | grep "system_tdc"`
sysSrcFileStrLen=`echo $sysSrcFile | wc -L`

echo sysSrcFile:$sysSrcFile

versionCode=${sysSrcFile:0-9:5}
echo versionCode:$versionCode

versionCodeDotNum=`echo $versionCode | grep -o \\\. | wc -l`

echo versionCodeDotNum:$versionCodeDotNum

if [ $versionCodeDotNum -ne 2 ];then
	echo "no src img file like system_tdc_8_31_1.3.1.img"
	exit 1
fi



dateAllName=`date "+%Y%m%d"`
dateName=${dateAllName:0-6}
echo dateName:$dateName

echo "begin copy "$sysSrcFile" to "$SYSPACK
#rm $SYSPACK
#cp $sysSrcFile $SYSPACK
#sleep 1

echo "begin oem..."
(
flock -xn 7
if [ $? -ne 0 ];then
    echo "somebody in compile,please wait a monment"
    exit 9
fi
rm $SYSPACK
cp $sysSrcFile $SYSPACK
sh ./oemcust.sh $1 $versionCode $dateName $TOKEN
)7>$LOCKFILE

echo "oem done, system.img was created, please use it."







