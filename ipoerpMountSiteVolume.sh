#!/bin/bash
#
FLAGTAG="THE-AREA-BELOW-IS-RESERVED-FOR-PATCHING"
#
if [[ -z ${HOMEDEVICE}  ]]
then
#
echo "No target volume specified so none can be mounted.  Installation terminated."
#
else
#
if [[  -z ${LBL_OPENERP}  || -z ${LBL_POSTGRES}  || -z ${FLAGTAG}  || -z ${DEVICELABEL} ]]
then
#
echo "Usage :  ./ipoerpInstallNewVolume.sh  "
echo "With required variables :"
echo " - LBL_OPENERP : ${LBL_OPENERP}"
echo " - LBL_POSTGRES : ${LBL_POSTGRES}"
echo " - FLAGTAG : ${FLAGTAG}"
echo " - DEVICELABEL : ${DEVICELABEL}"
# echo " -  : ${}"
else
#
export SITE_NAME=""
#
echo "Validating newly attached OpenERP site volume"
export LIM=$(ls -l ${HOMEDEVICE}* | grep -c ${HOMEDEVICE})
export FOUND=1
#
export DEV_OPENERP=-1
export DEV_POSTGRES=-1
#
for (( IDX = 1 ; IDX < ${LIM}; IDX++ ))
do
 LABEL=$(e2label ${HOMEDEVICE}${IDX})
 [[ ${LABEL} == *"${LBL_OPENERP}"* ]] && DEV_OPENERP=${IDX} && FOUND=$(expr ${FOUND} + 1)
 [[ ${LABEL} == *"${LBL_POSTGRES}"* ]] && DEV_POSTGRES=${IDX} && FOUND=$(expr ${FOUND} + 1)
done
#
if ! (( ${FOUND} == ${LIM} )); then
echo "Expected, but did not find, two filesystem labels \"${LBL_OPENERP}\" and \"${LBL_POSTGRES}\" on device \"${HOMEDEVICE}\""
else
echo "Found expected filesystem labels: \"${LBL_OPENERP}\" on \"${HOMEDEVICE}${DEV_OPENERP}\" and \"${LBL_POSTGRES}\" on \"${HOMEDEVICE}${DEV_POSTGRES}\"."
echo ""
echo "Mounting OpenERP at temporary location"
echo "======================================"
mkdir -p /tmp/odoo
umount /tmp/odoo/ > /dev/null 2>&1 || :
mount ${HOMEDEVICE}${DEV_OPENERP} /tmp/odoo
echo ""
echo "Checking for obligatory components"
echo "=================================="
#
if [[ "1" -ne $(ls -l /tmp/odoo/openerp-server.conf | grep -c openerp-server.conf) ]]
then
 echo "No valid OpenERP configuration was detected"
 umount /tmp/odoo/ > /dev/null 2>&1 || :
 exit
else
 echo "OpenERP configuration detected.  Loading it's variables"
 source /tmp/odoo/UpStartVars.sh
 if [[ -z ${UPSTART_JOB} || -z ${SITE_NAME} || -z ${SITE_USER} || -z ${PSQL_USER} ]]
 then
  echo "Missing one or both of :"
  echo " - UPSTART_JOB : ${UPSTART_JOB}"
  echo " - SITE_NAME : ${SITE_NAME}"
  echo " - SITE_USER : ${SITE_USER}"
  echo " - PSQL_USER : ${PSQL_USER}"
  umount /tmp/odoo/ > /dev/null 2>&1 || :
  exit
 else
  export SITEBASE="/srv/${SITE_NAME}"
  export OERPUSR_WORK="${SITEBASE}/${OPENERPUSR}"
  export OERPUSR_HOME="${OERPUSR_WORK}/home"
  export PSQLUSR_HOME="${SITEBASE}/${POSTGRESUSR}"
  echo "OpenERP site \"${SITE_NAME}\" will now be mounted for users \"${SITE_USER}\" and \"${PSQL_USER}\".  Upstart job name : \"${UPSTART_JOB}\"."
  echo "Mount points \"${OERPUSR_WORK}\" and \"${PSQLUSR_HOME}\" ."
  #
  mkdir -p ${OERPUSR_WORK}
  mkdir -p ${PSQLUSR_HOME}
  #
  if [[  1 -gt $(getent passwd ${PSQL_USER} | grep -c "^${PSQL_USER}")  ]]
  then
   echo "Creating user \"${PSQL_USER}\""
   useradd -d ${PSQLUSR_HOME} ${PSQL_USER}
   usermod -a -G ${POSTGRESUSR} ${PSQL_USER}
  fi
  #
  mkdir -p /opt/${OPENERPUSR}
  if [[  1 -gt $(getent passwd ${OPENERPUSR} | grep -c "^${OPENERPUSR}")  ]]
  then
   echo "Creating user \"${OPENERPUSR}\""
   useradd -d /opt/${OPENERPUSR} ${OPENERPUSR}
  fi
  #
  if [[  1 -gt $(getent passwd ${SITE_USER} | grep -c "^${SITE_USER}")  ]]
  then
   echo "Creating user \"${SITE_USER}\" "
   useradd -d ${OERPUSR_HOME} ${SITE_USER}
   usermod -a -G ${OPENERPUSR} ${SITE_USER}
  fi
  #
 fi
#
fi
#
umount /tmp/odoo/ > /dev/null 2>&1 || :
#
export FIRST_PASS="yes"
if [[ -z $(grep "${FLAGTAG}" /etc/fstab)   ]]
then
    echo "Prepare /etc/fstab for patching"
    echo "==============================="
    echo "##### ${FLAGTAG} #####" >> /etc/fstab
    #
    echo "Append new volume descriptions to /etc/fstab"
    echo "============================================"
    #
    cat <<EOFSTAB>> /etc/fstab
#
# Server Site :: ${SITE_NAME}  -- Hypervisor Volume Name <[ ${DEVICELABEL} ]>
# - Filesystem for OpenERP : ${SITE_NAME}
UUID=$(blkid -s UUID -o value ${HOMEDEVICE}${DEV_OPENERP}) ${OERPUSR_WORK}  ext4 defaults 0 2
# - Filesystem for PostgreSQL : ${SITE_NAME}
UUID=$(blkid -s UUID -o value ${HOMEDEVICE}${DEV_POSTGRES}) ${PSQLUSR_HOME} ext4 defaults 0 2
#
EOFSTAB
    #
    #
else
    if [[  $(cat fstab | grep site_mtt | grep -c PorpDrive) -lt "1" ]]
    then
        echo "Detected previous patching of \"/etc/fstab\". "
        echo " * * DEVICE MOUNTING CANNOT PROCEED * * "
        echo "    Delete the line:  ##### ${FLAGTAG} ##### , from \"/etc/fstab\"and try again."
        exit 1
    else
        echo "\"/etc/fstab\" was pateched previously with \"# Server Site :: ${SITE_NAME}  -- Hypervisor Volume Name <[ ${DEVICELABEL} ]>\". "
        echo " * * Assuming its correct.  Continuing . . . * * "
        export FIRST_PASS="no"
    fi
fi
#
# tail -n 15 /etc/fstab
mount -a
#
source ${OERPUSR_WORK}/UpStartVars.sh
#
if [[ "${FIRST_PASS}" -eq "yes" ]]
then
    echo "Correcting file and directory ownership"
    for grp in "${!GROUP_IDS[@]}"
    do
      echo "GID: ${grp}; Group: ${GROUP_IDS[${grp}]};"
      find ${SITEBASE} -gid ${grp}  -exec chgrp ${GROUP_IDS[${grp}]} {} \;
    done
    #
    #
    for usr in "${!USERS_IDS[@]}"
    do
      echo "UID: ${usr}; User: ${USERS_IDS[${usr}]};"
      find ${SITEBASE} -uid ${usr}  -exec chown ${USERS_IDS[${usr}]} {} \;
    done
else
    echo "Assuming ownership issues were resolved on previous pass."
fi
#
echo "Remounted /etc/fstab"
#
start ${UPSTART_JOB}
#
fi
#
fi
#
fi



