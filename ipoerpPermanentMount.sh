#!/bin/bash
#
# if [[ -z ${KKK}  ||  -z ${SITENAME}}  ||  -z ${POSTGRESUSR}  ||  -z ${OPENERPUSR}  ||  -z ${FLAGTAG}  ||  -z ${DEVICELABEL}  ||  -z ${HOMEDEVICE} ]]
if [[                  -z ${SITENAME}}  ||  -z ${POSTGRESUSR}  ||  -z ${OPENERPUSR}  ||  -z ${FLAGTAG}  ||  -z ${DEVICELABEL}  ||  -z ${HOMEDEVICE} ]]
then
 #
 echo "Usage :  ./ipoerpInstallNewVolume.sh  "
 echo "With required variables :"
 echo " - SITENAME : ${SITENAME}"
 echo " - POSTGRESUSR : ${POSTGRESUSR}"
 echo " - OPENERPUSR : ${OPENERPUSR}"
 echo " - FLAGTAG : ${FLAGTAG}"
 echo " - DEVICELABEL : ${DEVICELABEL}"
 echo " - HOMEDEVICE : ${HOMEDEVICE}"
 # echo " -  : ${}"
 exit
fi
#
 #
 echo "Prepare places in the root file system"
 echo "======================================="
  #
 mkdir -p /srv/$SITENAME/${OPENERPUSR}
 mkdir -p /srv/$SITENAME/${POSTGRESUSR}
 #
 tree -L 2 /srv/$SITENAME
 #
 if [[ -z $(grep "${FLAGTAG}" /etc/fstab)   ]]
 then
     echo "Prepare /etc/fstab for patching"
     echo "==============================="
     echo "##### ${FLAGTAG} #####" >> /etc/fstab
 else
     echo "Delete previous patching, if any."
     echo "================================="
     # awk -v VAR=${FLAGTAG} '{print} $0 ~ VAR {exit}' /etc/fstab > /etc/fstab
     awk -v VAR=${FLAGTAG} '{print} $0 ~ VAR {exit}' /etc/fstab > fstab_new
     mv fstab_new /etc/fstab
 fi
 #
 echo "Append new volume descriptions to /etc/fstab"
 echo "============================================"
cat <<EOFSTAB>> /etc/fstab
#
# Server Site :: ${SITENAME}  -- Hypervisor Volume Name <[ ${DEVICELABEL} ]>
# - Filesystem for OpenERP : ${SITENAME}
UUID=$(blkid -s UUID -o value ${HOMEDEVICE}1) /srv/${SITENAME}/${OPENERPUSR}  ext4 defaults 0 2
# - Filesystem for PostgreSQL : ${SITENAME}
UUID=$(blkid -s UUID -o value ${HOMEDEVICE}2) /srv/${SITENAME}/${POSTGRESUSR} ext4 defaults 0 2
#
EOFSTAB
#
#
echo "Reprocess /etc/fstab"
echo "===================="
mount -a
#
tree -L 2 /srv/$SITENAME
#
