#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
function mount_prepared_volume()
{
 source $DEFDIR/ipoerpMountSiteVolume.sh
 echo "Back from ipoerpMountSiteVolume.sh"
 export RSLT="Mounted existing volume"
}
#
#
function prepare_empty_volume()
{
 source $DEFDIR/ipoerpInstallSiteVolume.sh
 echo "Back from ipoerpInstallSiteVolume.sh"
 export RSLT="Prepared empty volume"
}
#
#
if [[ -z ${HOMEDEVICE}  ]]
then
 #
 echo "No target volume specified so none will be created.  Installation will go to root '/' volume"
 #
else
 #
 declare NUMBER_OF_HOMEDEVICE_PARTITIONS=$(ls -l ${HOMEDEVICE}* | grep -c "${HOMEDEVICE}")
# declare NUMBER_OF_HOMEDEVICE_PARTITIONS=3
 if [[
          ${NUMBER_OF_HOMEDEVICE_PARTITIONS} -lt 1
       || ${NUMBER_OF_HOMEDEVICE_PARTITIONS} -eq 2
       || ${NUMBER_OF_HOMEDEVICE_PARTITIONS} -gt 3
    ]]
 then
    echo "Device not as expected.  Quitting...."
    exit
 fi
 #
# if [[  -z ${OOO}  || -z ${LBL_OPENERP}  || -z ${LBL_POSTGRES}  || -z ${FLAGTAG}  || -z ${DEVICELABEL} ]]
 if [[                 -z ${LBL_OPENERP}  || -z ${LBL_POSTGRES}  || -z ${FLAGTAG}  || -z ${DEVICELABEL} ]]
 then
  #
  echo "Usage :  ./ipoerpInstallNewVolume.sh  "
  echo "With required variables :"
  echo " - LBL_OPENERP : ${LBL_OPENERP}"
  echo " - LBL_POSTGRES : ${LBL_POSTGRES}"
  echo " - FLAGTAG : ${FLAGTAG}"
  echo " - DEVICELABEL : ${DEVICELABEL}"
  # echo " -  : ${}"
  exit
 fi
 #
 if [[ ${NUMBER_OF_HOMEDEVICE_PARTITIONS} -eq 1   ]]
 then
    echo "Empty device enountered.  Will install on it."
    prepare_empty_volume
 elif [[ ${NUMBER_OF_HOMEDEVICE_PARTITIONS} -eq 3   ]]
 then
    echo "Prepared device found.  Investigating contents."
    mount_prepared_volume
 else
    echo "Device not as expected.  Quitting...."
    exit
 fi
 echo $RSLT
 #
fi

