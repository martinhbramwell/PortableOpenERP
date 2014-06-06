#!/bin/bash
#
# if [[ -z ${KKK}  ||  -z ${SITENAME}}  ||  -z ${POSTGRESUSR}  ||  -z ${OPENERPUSR} ]]
if [[                  -z ${SITENAME}}  ||  -z ${POSTGRESUSR}  ||  -z ${OPENERPUSR} ]]
then
 #
 echo "Usage :  ./ipoerpInstallNewVolume.sh  "
 echo "With required variables :"
 echo " - SITENAME : ${SITENAME}"
 echo " - POSTGRESUSR : ${POSTGRESUSR}"
 echo " - OPENERPUSR : ${OPENERPUSR}"
 # echo " -  : ${}"
 exit
fi
#
declare NUMBER_OF_HOMEDEVICE_PARTITIONS=$(ls -l ${HOMEDEVICE}* | grep -c "${HOMEDEVICE}")
if  [[  $(cat /etc/fstab | grep -c ${SITENAME}) -gt 0  ]]
then
 #
 echo "Found a previous installation.  Skipping volume installation step."
 #
elif [[  ${NUMBER_OF_HOMEDEVICE_PARTITIONS} -ne 1 ]]
then
 #
 echo "${HOMEDEVICE} does NOT seem to be an empty volume."
 exit 1
else
 echo "Make a gpt volume"
 echo "================="
 parted -s ${HOMEDEVICE} mklabel gpt
 #
 echo "Create first partition"
 echo "======================"
 parted -s -a optimal ${HOMEDEVICE} mkpart primary ext4 0% 25%
 #
 echo "Show freespace"
 echo "=============="
 parted -s ${HOMEDEVICE} unit s p free > RESULT.TXT
 export RST=$(cat RESULT.TXT |awk '/Free/{i++}i==2' | sed -e 's/^ *//' -e 's/ *$//')
 rm -f RESULT.TXT
 export BOTLIM=$(echo ${RST} | awk '{print $1;}')
 export TOPLIM=$(echo ${RST} | awk '{print $2;}')
 echo "Will make partition from ${BOTLIM} to ${TOPLIM}"
 #
 echo "Create second partition"
 echo "======================="
 parted -s -a optimal ${HOMEDEVICE} mkpart primary ext4 ${BOTLIM} ${TOPLIM}
 #
 echo "Show freespace"
 echo "=============="
 parted -s ${HOMEDEVICE} unit s p free
 #
 echo "Initialize filesystem #1 (for OpenERP)"
 echo "======================================"
 mkfs --type ext4 -L ${LBL_OPENERP} ${HOMEDEVICE}1
 #
 echo "Initialize filesystem #2 (for PostgreSQL)"
 echo "========================================="
 mkfs --type ext4 -L ${LBL_POSTGRES} ${HOMEDEVICE}2
 #
 echo "Show freespace"
 echo "=============="
 parted ${HOMEDEVICE} unit s p free
 #
 echo "Universal IDs created"
 echo "====================="
 blkid ${HOMEDEVICE}*
 #
fi
###########      Go on to ipoerpPermanentMount.sh

