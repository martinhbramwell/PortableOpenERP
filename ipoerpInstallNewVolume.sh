#!/bin/bash
#
if [[ -z ${HOMEDEVICE}  ]]
then
 #
 echo "No target volume specified so none will be created.  Installation will got to root '/' volume"
 #
else
 #
 LIST=$(ls -la ${HOMEDEVICE})
 if [[ 0 -ne $?   ]]
 then
    echo "$LIST"
    echo "Error while trying to prepare ${HOMEDEVICE}"
    exit
 fi
 if [[ -z ${SITENAME}}  || -z ${DEVICELABEL}  || -z ${LBL_OPENERP}  || -z ${LBL_POSTGRES}  || -z ${FLAGTAG}  ]]
 then
  #
  echo "Usage :  ./ipoerpInstallNewVolume.sh  "
  echo "With required variables :"
  echo " - SITENAME : ${SITENAME}"
  echo " - DEVICELABEL : ${DEVICELABEL}"
  echo " - LBL_OPENERP : ${LBL_OPENERP}"
  echo " - LBL_POSTGRES : ${LBL_POSTGRES}"
  echo " - FLAGTAG : ${FLAGTAG}"
  # echo " -  : ${}"
  #
 else
  #
  echo "Wiping volume '${HOMEDEVICE}' **TOTALLY** without further confirmation from you."
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
  echo "Prepare places in the root file system"
  echo "======================================="
  mkdir -p /srv/$SITENAME/openerp
  mkdir -p /srv/$SITENAME/postgres
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
UUID=$(blkid -s UUID -o value ${HOMEDEVICE}1) /srv/${SITENAME}/openerp  ext4 defaults 0 2
# - Filesystem for PostgreSQL : ${SITENAME}
UUID=$(blkid -s UUID -o value ${HOMEDEVICE}2) /srv/${SITENAME}/postgres ext4 defaults 0 2
#
EOFSTAB
  #
  echo "Reprocess /etc/fstab"
  echo "===================="
  mount -a
  #
  tree -L 2 /srv/$SITENAME
  #
 fi
 #
fi
#
