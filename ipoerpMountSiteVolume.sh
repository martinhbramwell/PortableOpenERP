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
mkdir -p /tmp/oerp
umount /tmp/oerp/ > /dev/null 2>&1 || :
mount ${HOMEDEVICE}${DEV_OPENERP} /tmp/oerp
echo ""
echo "Checking for obligatory components"
echo "=================================="
#
if [[ "1" -ne $(ls -l /tmp/oerp/openerp-server.conf | grep -c openerp-server.conf) ]]
then
 echo "No valid OpenERP configuration was detected"
 umount /tmp/oerp/ > /dev/null 2>&1 || :
 exit
else
 echo "OpenERP configuration detected"
 export UPSTARTR=$(cat /tmp/oerp/upstart.sh | sed -n -e "s/^NAME=//p")
 export SITENAME=$(cat /tmp/oerp/upstart.sh | sed -n -e "s/^.*SITE_DIR_NAME=//p")
 export USERNAME=$(cat /tmp/oerp/upstart.sh | sed -n -e "s/^USER=//p")
 export PUSRNAME=$(cat /tmp/oerp/upstart.sh | sed -n -e "s/^.*PSQLUSER=//p")
 if [[ -z ${UPSTARTR} || -z ${SITENAME} || -z ${USERNAME} || -z ${PUSRNAME} ]]
 then
  echo "Missing one or both of :"
  echo " - UPSTARTR : ${UPSTARTR}"
  echo " - SITENAME : ${SITENAME}"
  echo " - USERNAME : ${USERNAME}"
  echo " - PUSRNAME : ${PUSRNAME}"
  umount /tmp/oerp/ > /dev/null 2>&1 || :
  exit
 else
  export OERPUSR_WORK="/srv/${SITENAME}/openerp"
  export OERPUSR_HOME="${OERPUSR_WORK}/home"
  export PSQLUSR_HOME="/srv/${SITENAME}/postgres"
  echo "OpenERP site \"${SITENAME}\" will now be mounted for users \"${USERNAME}\" and \"${PUSRNAME}\""
  mkdir -p ${OERPUSR_HOME}
  mkdir -p ${PSQLUSR_HOME}
  #
  if [[  1 -gt $(getent passwd | grep -c ${PUSRNAME})  ]]
  then
   echo "Creating \"${PUSRNAME}\""
   useradd -d ${PSQLUSR_HOME} ${PUSRNAME}
   usermod -a -G postgres ${PUSRNAME}
  fi
  #
  if [[  1 -gt $(getent passwd | grep -c openerp)  ]]
  then
   echo "Creating user \"openerp\"""
   useradd -d /home/openerp openerp
  fi
  #
  if [[  1 -gt $(getent passwd | grep -c ${USERNAME})  ]]
  then
   echo "Creating user \"${USERNAME}\"""
   useradd -d ${OERPUSR_HOME} ${USERNAME}
   usermod -a -G openerp ${USERNAME}
  fi
  echo "Setting file and directory permissions"
  #
  chown -R postgres:${PUSRNAME} ${PSQLUSR_HOME}
  chmod -R 770 ${PSQLUSR_HOME}
  #
  chown -R openerp:${USERNAME} ${OERPUSR_WORK}
  chown -R ${USERNAME}:${USERNAME} ${OERPUSR_HOME}
  chmod -R 770 ${OERPUSR_HOME}
  #
 fi
#
fi
#
umount /tmp/oerp/ > /dev/null 2>&1 || :
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
#n
#
if [[  0 -eq 1  ]]
then
 touch ${OERPUSR_HOME}/.bzr.log
 chown       openerp:${USERNAME} ${OERPUSR_HOME}
 chmod -R 770 ${PSQLUSR_HOME}
 chmod -R 770 ${OERPUSR_HOME}
 find ${PSQLUSR_HOME} -type d -print0 | xargs -0 chmod 750
 find ${PSQLUSR_HOME} -type f -print0 | xargs -0 chmod 640
 find ${OERPUSR_HOME} -type d -print0 | xargs -0 chmod 750
 find ${OERPUSR_HOME} -type f -print0 | xargs -0 chmod 640
 #
 chown -R    openerp:${USERNAME}  ${OERPUSR_HOME}/source
 chmod -R    750                  ${OERPUSR_HOME}/source
 chown       openerp:${USERNAME}  ${OERPUSR_HOME}/.bzr.log
 chmod -R    640                  ${OERPUSR_HOME}/.bzr.log
 #
 chown       openerp:${USERNAME}  ${OERPUSR_HOME}/openerp-server.conf
 chmod       550                  ${OERPUSR_HOME}/openerp-server.conf
 echo "chown -R ${USERNAME}:${USERNAME} ${OERPUSR_HOME}/server"
 chown -R ${USERNAME}:${USERNAME} ${OERPUSR_HOME}/server
 chmod       770                  ${OERPUSR_HOME}/server/openerp-server
 chown -R ${USERNAME}:${USERNAME} ${OERPUSR_HOME}/log
 chown -R ${USERNAME}:${USERNAME} ${OERPUSR_HOME}/.local
 #
 chown       openerp:${USERNAME}  ${OERPUSR_HOME}/upstart.sh
 chmod -R    550                  ${OERPUSR_HOME}/upstart.sh
 #
fi
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



