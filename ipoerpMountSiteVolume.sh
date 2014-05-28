#!/bin/bash
#
FLAGTAG="THE-AREA-BELOW-IS-RESERVED-FOR-PATCHING"
ODOOBASE=""
#
function validate_parms()
{
  if [[ -z ${HOMEDEVICE}  ]]
  then
  #
    echo "No target volume \"${HOMEDEVICE}\" specified so none can be mounted.  Installation terminated."
    exit
  fi
  #
  if [[ -z ${LBL_OPENERP}  || -z ${LBL_POSTGRES}  || -z ${FLAGTAG}  || -z ${DEVICELABEL} ]]
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
}
#
function process_vars()
{
 source ${1}/UpStartVars.sh
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
  echo "${SCREWY}"
  echo "Getting environment variables from attached OpenERP device."
  echo "-----------------------------------------------------------"
  SITEBASE="/srv/${SITE_NAME}"
  export OERPUSR_WORK="${SITEBASE}/${OPENERPUSR}"
  export OERPUSR_HOME="${OERPUSR_WORK}/home"
  export PSQLUSR_HOME="${SITEBASE}/${POSTGRESUSR}"
 fi
}
#
function validate_attached_volume()
{
  echo ""
  echo "Validating newly attached OpenERP site volume: \"${HOMEDEVICE}\""
  echo "---------------------------------------------------------"
  export LIM=$(ls -l ${HOMEDEVICE}* | grep -c ${HOMEDEVICE})
  export FOUND=1
  #
  export DEV_OPENERP=-1
  export DEV_POSTGRES=-1
  #
  echo "Checking ${LIM} instances of ${HOMEDEVICE}"
  #
  for (( IDX = 1 ; IDX < ${LIM}; IDX++ ))
  do
    LABEL=$(e2label ${HOMEDEVICE}${IDX})
    echo "Checking for filesystem label ${LABEL} (${IDX}/${LIM})"
    [[ ${LABEL} == *"${LBL_OPENERP}"* ]] && DEV_OPENERP=${IDX} && FOUND=$(expr ${FOUND} + 1)
    [[ ${LABEL} == *"${LBL_POSTGRES}"* ]] && DEV_POSTGRES=${IDX} && FOUND=$(expr ${FOUND} + 1)
  done
  #
  (( ${FOUND} == ${LIM} )) && return 0
  return 1
}
#
function validate_volume_content()
{
  echo "Mounting OpenERP at temporary location"
  echo "======================================"
  TEMP_DIR="/tmp/odoo"
  TEMP_DIR_ORIG=${TEMP_DIR}
  mkdir -p ${TEMP_DIR}
  umount ${TEMP_DIR} > /dev/null 2>&1 || :
  mount ${HOMEDEVICE}${DEV_OPENERP} ${TEMP_DIR}
  echo ""
  echo "Checking for obligatory components"
  echo "=================================="
  #
  ls -la ${TEMP_DIR}
  if (( $? > 0 ))
  then
    echo "Mount failed.  Quitting . . . "
    exit
  fi
  #
  export SITEBASE="null"
  export OERPUSR_HOME="null"
  export PSQLUSR_HOME="null"

  if [[ ! -f "${TEMP_DIR}/UpStartVars.sh" ]]
  then
    umount ${TEMP_DIR}/ > /dev/null 2>&1 || :
    echo "No valid OpenERP configuration was detected.  Is there a known archive, \"${SITE_ARCHIVE}\"?"
    #
    if [[ ! -f "${SITE_ARCHIVE}" ]]
    then
      echo "${SITE_ARCHIVE} not found.  Don't understand this volume.  Quitting . . ."
      exit
    fi
    #
    if [[ -f "${TEMP_DIR}/site_tkd/openerp/UpStartVars.sh" && -f "${TEMP_DIR}/site_tkd/postgres/backups/site_tkd_db.gz"   ]]
    then
      echo "Seems we did that already"
    else
      echo ""
      echo "Decompressing \"${SITE_ARCHIVE}\" to temporary location."
      echo "========================================================"
      exit
      tar jxf ${SITE_ARCHIVE} --skip-old-files --directory=${TEMP_DIR}  > /dev/null
    fi
    pushd ${TEMP_DIR}/*/openerp
    if [[ $? -ne 0 ]]
    then
      echo "${SITE_ARCHIVE} had no \"openerp\" directory.  Nothing more can be done.  Quitting . . ."
      exit
    fi
    TEMP_DIR=$(pwd)
    echo "Temp dir is now ${TEMP_DIR}"
    #
  fi
  #

  if [[ ! -f "${TEMP_DIR}/UpStartVars.sh" ]]
  then
     echo "Required file \"\" was not found. Don't understand this volume.  Quitting . . ."
     exit
  fi
  echo "Found the variables file for the site.  Processing . . ."
  echo "~~~ ${PSQLUSR_HOME}"
  process_vars ${TEMP_DIR}
  echo "~~~ ${PSQLUSR_HOME}"
  #
  [[ "${TEMP_DIR}" == "${TEMP_DIR_ORIG}" ]]  &&  umount ${TEMP_DIR}/ > /dev/null 2>&1 || :
  return 0
}
#
function prepare_users_dirs()
{
  #
  echo "Creating dummy directories: \"${OERPUSR_WORK}\" and \"${PSQLUSR_HOME}\"."
  mkdir -p ${OERPUSR_WORK}
  mkdir -p ${PSQLUSR_HOME}
  #
  if [[  1 -gt $(getent passwd ${PSQL_USER} | grep -c "^${PSQL_USER}")  ]]
  then
   echo "Creating user \"${PSQL_USER}\""
   useradd -d ${PSQLUSR_HOME} ${PSQL_USER}
   usermod -a -G ${POSTGRESUSR} ${PSQL_USER}
  else
   echo "User \"${PSQL_USER}\" exists."
  fi
  #
  mkdir -p /opt/${OPENERPUSR}
  if [[  1 -gt $(getent passwd ${OPENERPUSR} | grep -c "^${OPENERPUSR}")  ]]
  then
   echo "Creating user \"${OPENERPUSR}\""
   useradd -d /opt/${OPENERPUSR} ${OPENERPUSR}
  else
   echo "User \"${OPENERPUSR}\" exists."
  fi
  #
  if [[  1 -gt $(getent passwd ${SITE_USER} | grep -c "^${SITE_USER}")  ]]
  then
   echo "Creating user \"${SITE_USER}\" "
   useradd -d ${OERPUSR_HOME} ${SITE_USER}
   usermod -a -G ${OPENERPUSR} ${SITE_USER}
  else
   echo "User \"${SITE_USER}\" exists."
  fi
}
#
#
function patch_fstab()
{
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
      if [[  $(cat /etc/fstab | grep ${SITE_NAME} | grep -c ${DEVICELABEL}) -lt "1" ]]
      then
          echo "Detected previous patching of \"/etc/fstab\". "
          echo " * * DEVICE MOUNTING CANNOT PROCEED * * "
          echo "    Delete the line:  ##### ${FLAGTAG} ##### , from \"/etc/fstab\"and try again."
          exit 1
      else
          echo "\"/etc/fstab\" was patched previously with \"# Server Site :: ${SITE_NAME}  -- Hypervisor Volume Name <[ ${DEVICELABEL} ]>\". "
          echo " * * Assuming it's correct.  Continuing . . . * * "
      fi
  fi
  #
}
#
#
function situate_files()
{
  if [[ ! -f "/srv/${SITE_NAME}/openerp/UpStartVars.sh" ]]
  then
    echo "System not found on attached device.  Check for decompressed archive."
    if [[ -f "${TEMP_DIR}/UpStartVars.sh" ]]
    then
       echo "Moving system files from temp dir to device."
       mv ${TEMP_DIR}/../${OPENERPUSR}/* /srv/${SITE_NAME}/${OPENERPUSR}
       mv ${TEMP_DIR}/../${POSTGRESUSR}/* /srv/${SITE_NAME}/${POSTGRESUSR}
    else
       echo "Decompressed archive not found.  Check for compressed archive."
       echo "    FIX ME :  We should not be here.  "
       exit 1
    fi
  fi
}
#
#
function correct_ownerships()
{
  #
  if [[ -f "/tmp/ODOOPASSFLAG" ]]
  then
    echo "Assuming ownership issues were resolved on previous pass."
  else
    echo "Correcting file and directory ownership.  ${GROUP_IDS} ${OERPUSR_WORK} ${PSQLUSR_HOME}"
    source ${OERPUSR_WORK}/UpStartVars.sh
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
    touch /tmp/ODOOPASSFLAG
  fi
  #
}
#
#
#
export SITE_NAME=""
export TEMP_DIR=""
export TEMP_DIR_ORIG=""
#
validate_parms
validate_attached_volume
if [[ $? -gt 0 ]]
then
  echo "Expected, but did not find, two filesystem labels \"${LBL_OPENERP}\" and \"${LBL_POSTGRES}\" on device \"${HOMEDEVICE}\""
  echo "Will not risk altering this disk."
  exit
fi
#
echo "Found expected filesystem labels: \"${LBL_OPENERP}\" on \"${HOMEDEVICE}${DEV_OPENERP}\" and \"${LBL_POSTGRES}\" on \"${HOMEDEVICE}${DEV_POSTGRES}\"."
echo ""
validate_volume_content
prepare_users_dirs
patch_fstab
#
echo ""
echo "Reloading /etc/fstab."
echo "====================."
mount -a
#
situate_files
correct_ownerships
#

