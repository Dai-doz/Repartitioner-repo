#!/sbin/sh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Originally taken from universal repartitioner for the 7870 and @Astrako, V1.0, thanks to him
# Written by @Dai_doz
# Modified for Universal 850
# Hola Astrako, si ves esto quiero pedir mil disculpas por robar tu trabajo, pero estoy manteniendo los creditos, incluso en el post
# New partitions size in Mb. These values are the recommended.if you want more just change the number 1000=1gb
SUPERSIZE=12000
PRISMSIZE=10
OPTICSSIZE=10
CACHESIZE=6
OMRSIZE=3

SGDISK=/system/bin/sgdisk
DISK=/dev/block/mmcblk0

DISKCODE=`$SGDISK --print $DISK | grep super | awk '{printf $6}'`
SECSIZE=`$SGDISK --print $DISK | grep 'sector size' | awk '{printf $4}'`


function unmount() {
    # Mount all partitions to avoid sgdisk failure
    umount /system_root
    umount /vendor
    umount /product
    umount /odm
    umount /prism
    umount /optics
    umount /cache
    umount /omr
    umount /data
     
}

function delete() {
	# Delete partitions
	$SGDISK --delete=$1 $DISK
	
}

function calculate() {
	# Get SYSTEM partition number and delete it
	SYSPART=`$SGDISK --print $DISK | grep super | awk '{printf $1}'`
	delete $SYSPART

	# Get VENDOR partition number and delete it, if exists
	PRISMPART=`$SGDISK --print $DISK | grep prism | awk '{printf $1}'`
	delete $PRISMPART
	
	# Get OPTICS partition number and delete it
	OPTICSPART=`$SGDISK --print $DISK | grep optics | awk '{printf $1}'`
	delete $OPTICSPART
	
	# Get CACHE partition number and delete it
	CACHEPART=`$SGDISK --print $DISK | grep cache | awk '{printf $1}'`
	delete $CACHEPART
	
	# Get OMR partition number and delete it
	OMRPART=`$SGDISK --print $DISK | grep omr | awk '{printf $1}'`
	delete $OMRPART
	
	# Get CP_DEBUG partition number and delete it
	CPDEBUGPART=`$SGDISK --print $DISK | grep cp_debug | awk '{printf $1}'`
	delete $CPDEBUGPART
	
	# Get SPU partition number and delete it
	SPUPART=`$SGDISK --print $DISK | grep spu | awk '{printf $1}'`
	delete $SPUPART
	
	# Get USERDATA partition number and delete it
	DATAPART=`$SGDISK --print $DISK | grep userdata | awk '{printf $1}'`
	delete $DATAPART



}
	
function repart() {	
	# SYSTEM repartition
    $SGDISK --new=0:0:+${SUPERSIZE}Mib --typecode=0:$DISKCODE --change-name=0:super $DISK

	$SGDISK --new=0:0:+${PRISMSIZE}Mib --typecode=0:$DISKCODE --change-name=0:prism $DISK
	
	$SGDISK --new=0:0:+${OPTICSSIZE}Mib --typecode=0:$DISKCODE --change-name=0:optics $DISK
	
	$SGDISK --new=0:0:+${CACHESIZE}Mib --typecode=0:$DISKCODE --change-name=0:cache $DISK
	
	$SGDISK --new=0:0:+${OMRSIZE}Mib --typecode=0:$DISKCODE --change-name=0:omr $DISK
	
	#USERDATA repartition
	$SGDISK --new=0:0:0 --typecode=0:$DISKCODE --change-name=0:userdata $DISK
	

}

# main
unmount
calculate
repart
