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
export SITENAME=""
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
 echo "OpenERP configuration detected"
 export UPSTARTR=$(cat /tmp/odoo/UpStart.sh | sed -n -e "s/^export UPSTART_JOB=//p")
 export SITENAME=$(cat /tmp/odoo/UpStart.sh | sed -n -e "s/^export SITE_NAME=//p")
 export USERNAME=$(cat /tmp/odoo/UpStart.sh | sed -n -e "s/^export SITE_USER=//p")
 export PUSRNAME=$(cat /tmp/odoo/UpStart.sh | sed -n -e "s/^export PSQL_USER=//p")
 if [[ -z ${UPSTARTR} || -z ${SITENAME} || -z ${USERNAME} || -z ${PUSRNAME} ]]
 then
  echo "Missing one or both of :"
  echo " - UPSTARTR : ${UPSTARTR}"
  echo " - SITENAME : ${SITENAME}"
  echo " - USERNAME : ${USERNAME}"
  echo " - PUSRNAME : ${PUSRNAME}"
  umount /tmp/odoo/ > /dev/null 2>&1 || :
  exit
 else
  export SITEBASE="/srv/${SITENAME}"
  export OERPUSR_WORK="${SITEBASE}/${OPENERPUSR}"
  export OERPUSR_HOME="${OERPUSR_WORK}/home"
  export PSQLUSR_HOME="/${SITEBASE}/${POSTGRESUSR}"
  echo "OpenERP site \"${SITENAME}\" will now be mounted for users \"${USERNAME}\" and \"${PUSRNAME}\".  Upstart job name : \"${UPSTARTR}\"."
  echo "Mount points \"${OERPUSR_WORK}\" and \"${PSQLUSR_HOME}\" ."
  mkdir -p ${OERPUSR_WORK}
  mkdir -p ${PSQLUSR_HOME}
  #
  if [[  1 -gt $(getent passwd | grep -c "^${PUSRNAME}")  ]]
  then
   echo "Creating \"${PUSRNAME}\""
   useradd -d ${PSQLUSR_HOME} ${PUSRNAME}
   usermod -a -G ${POSTGRESUSR} ${PUSRNAME}
  fi
  #
  mkdir -p /opt/${OPENERPUSR}
  if [[  1 -gt $(getent passwd | grep -c "^${OPENERPUSR}")  ]]
  then
   echo "Creating user \"${OPENERPUSR}\""
   useradd -d /opt/${OPENERPUSR} ${OPENERPUSR}
  fi
  #
  if [[  1 -gt $(getent passwd | grep -c "^${USERNAME}")  ]]
  then
   echo "Creating user \"${USERNAME}\" "
   useradd -d ${OERPUSR_HOME} ${USERNAME}
   usermod -a -G ${OPENERPUSR} ${USERNAME}
  fi
  #
 fi
#
fi
#
umount /tmp/odoo/ > /dev/null 2>&1 || :
#
if [[ -z $(grep "${FLAGTAG}" /etc/fstab)   ]]
then
    echo "Prepare /etc/fstab for patching"
    echo "==============================="
    echo "##### ${FLAGTAG} #####" >> /etc/fstab
else
    echo "Detected previous patching of \"/etc/fstab\". "
    echo " * * DEVICE MOUNTING CANNOT PROCEED * * "
    echo "    Delete the line:  ##### ${FLAGTAG} ##### , from \"/etc/fstab\"and try again."
    exit 1
fi
#
echo "Append new volume descriptions to /etc/fstab"
echo "============================================"
#
cat <<EOFSTAB>> /etc/fstab
#
# Server Site :: ${SITENAME}  -- Hypervisor Volume Name <[ ${DEVICELABEL} ]>
# - Filesystem for OpenERP : ${SITENAME}
UUID=$(blkid -s UUID -o value ${HOMEDEVICE}${DEV_OPENERP}) ${OERPUSR_WORK}  ext4 defaults 0 2
# - Filesystem for PostgreSQL : ${SITENAME}
UUID=$(blkid -s UUID -o value ${HOMEDEVICE}${DEV_POSTGRES}) ${PSQLUSR_HOME} ext4 defaults 0 2
#
EOFSTAB
#
# tail -n 15 /etc/fstab
mount -a
#
#  THIS IS PROBABLY PURE CRAP AND WILL ALMOST CERTAINLY BE DELETED
if [[  0 -eq 1  ]]
then
 touch ${OERPUSR_HOME}/.bzr.log
 chown       ${OPENERPUSR}:${USERNAME} ${OERPUSR_HOME}
 chmod -R 770 ${PSQLUSR_HOME}
 chmod -R 770 ${OERPUSR_HOME}
 find ${PSQLUSR_HOME} -type d -print0 | xargs -0 chmod 750
 find ${PSQLUSR_HOME} -type f -print0 | xargs -0 chmod 640
 find ${OERPUSR_HOME} -type d -print0 | xargs -0 chmod 750
 find ${OERPUSR_HOME} -type f -print0 | xargs -0 chmod 640
 #
 chown -R    ${OPENERPUSR}:${USERNAME}  ${OERPUSR_HOME}/source
 chmod -R    750                  ${OERPUSR_HOME}/source
 chown       ${OPENERPUSR}:${USERNAME}  ${OERPUSR_HOME}/.bzr.log
 chmod -R    640                  ${OERPUSR_HOME}/.bzr.log
 #
 chown       ${OPENERPUSR}:${USERNAME}  ${OERPUSR_HOME}/openerp-server.conf
 chmod       550                  ${OERPUSR_HOME}/openerp-server.conf
 echo "chown -R ${USERNAME}:${USERNAME} ${OERPUSR_HOME}/server"
 chown -R ${USERNAME}:${USERNAME} ${OERPUSR_HOME}/server
 chmod       770                  ${OERPUSR_HOME}/server/openerp-server
 chown -R ${USERNAME}:${USERNAME} ${OERPUSR_HOME}/log
 chown -R ${USERNAME}:${USERNAME} ${OERPUSR_HOME}/.local
 #
 chown       ${OPENERPUSR}:${USERNAME}  ${OERPUSR_HOME}/upstart.sh
 chmod -R    550                  ${OERPUSR_HOME}/upstart.sh
 #
fi
#
#
if [[  0 -eq 1  ]]
then
  #
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
 #
fi
#
echo "Remounted /etc/fstab"
exit
rm -f /etc/init.d/${UPSTARTR}
ln -s ${OERPUSR_WORK}/upstart.sh /etc/init.d/${UPSTARTR}
#
service ${UPSTARTR} start
#
fi
#
fi
#
fi



