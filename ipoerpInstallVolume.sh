#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
function mount_prepared_volume()  ##  Archive restoring only
{
 source $DEFDIR/ipoerpMountSiteVolume.sh
 echo "Back from ipoerpMountSiteVolume.sh"
 export RSLT="Mounted existing volume"
}
#
#
function prepare_empty_volume()
{
 source $DEFDIR/ipoerpInitializeDevice.sh
 echo "Back from ipoerpInitializeDevice.sh"
 export RSLT="Prepared empty volume"
}
#
#
function permanent_mount()
{
 source $DEFDIR/ipoerpPermanentMount.sh
 echo "Back from ipoerpPermanentMount.sh"
 export RSLT="Mounted prepared volume"
}
#
#
function validate_volume()
{
 source $DEFDIR/ipoerpValidateVolume.sh
 echo "Back from ipoerpValidateVolume.sh"
 export RSLT="Validated prepared volume."
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
  export EMPTY_FILESYSTEM_ON_VOLUME="no"
  if [[ ${NUMBER_OF_HOMEDEVICE_PARTITIONS} -eq 1   ]]
  then
     echo "Empty device enountered.  Will install on it."
     prepare_empty_volume
  elif [[ ${NUMBER_OF_HOMEDEVICE_PARTITIONS} -eq 3   ]]
  then
     echo "Prepared device found.  Investigating contents."
     validate_volume
  else
     echo "Device not as expected.  Quitting...."
     exit
  fi
  #
  if [[ "${EMPTY_FILESYSTEM_ON_VOLUME}" == "yes"  ]]
  then
    permanent_mount
    echo "Mounted filesystem with /etc/fstab/."
  elif [[ -f ${OERPUSR_WORK}/UpStartVars.sh  ]]
  then
    echo "Where do we go now?"
    exit
    mount_prepared_volume
    exit
  else
    echo "Assuming an install process was interrupted.  Continuing . . . "
  fi
  echo $RSLT
  #
fi

