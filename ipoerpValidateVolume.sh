#!/bin/bash
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
  if [[ -z ${LBL_OPENERP}  || -z ${LBL_POSTGRES} ]]
  then
    #
    echo "Usage :  ./ipoerpInstallNewVolume.sh  "
    echo "With required variables :"
    echo " - LBL_OPENERP : ${LBL_OPENERP}"
    echo " - LBL_POSTGRES : ${LBL_POSTGRES}"
    echo " - FLAGTAG : ${FLAGTAG}"
    # echo " -  : ${}"
    exit
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
function get_system_parameters_off_volume()
{
  TEMP_DIR="/tmp/odoo"
  TEMP_DIR_ORIG=${TEMP_DIR}
  echo "Mounting OpenERP at temporary location ${TEMP_DIR}"
  echo "================================================"
  mkdir -p ${TEMP_DIR}
  umount ${TEMP_DIR} > /dev/null 2>&1 || :
  mount ${HOMEDEVICE}${DEV_OPENERP} ${TEMP_DIR}
  echo ""
  rm -f /tmp/UpStartVars.sh
  cp ${TEMP_DIR}/UpStartVars.sh /tmp 2> /dev/null
  umount ${TEMP_DIR} > /dev/null 2>&1 || :
}
#
function XXXXXXvalidate_volume_content()
{
  echo "Checking for obligatory components"
  echo "=================================="
  #
exit
  FILES_COUNT=$(ls -la ${TEMP_DIR} | wc -l)
  if [[ ( $? > 0) || ${FILES_COUNT} -lt 1 ]]
  then
    echo "Mount failed.  Quitting . . . "
    exit
  fi
  #
  if [[ "${FILES_COUNT}" -lt "5" ]]
  then
    echo "There are no files; as if previous install was interrupted.  Continuing . . .  "
    EMPTY_FILESYSTEM_ON_VOLUME="yes"
    return 0
  else
    FILES_COUNT=$(tree -L 3 /srv/${SITENAME} | wc -l)
    PRIOR_INSTALL=$(ls -l /etc/init/*.conf | grep -c ${SITENAME})
    #
    echo "-- ${FILES_COUNT}"
    echo "-- ${PRIOR_INSTALL}"
    if [[ ${PRIOR_INSTALL} -gt "0" ]]
    then
      echo "Apparently a full prior installation for ${SITENAME} is already present and enabled. Quitting . . ."
      exit
    else
      if [[ "${FILES_COUNT}" -gt "40" ]]
      then
        echo "Apparently a prior installation for ${SITENAME} is present but not yet enabled."
        echo "Will complete the installation."
        exit
      elif [[ "${FILES_COUNT}" -lt "20" ]]
      then
        echo "Apparently a prior installation for ${SITENAME} is present but not yet enabled."
        echo "Will complete the installation."
        exit
      else
        echo "E"
      fi
    fi
    #
    exit
    #
    if [[ 1 == 0 ]]
    then
#      if [[ "${PRIOR_INSTALL}" -gt "0" ]]
#      if [[ -f "${TEMP_DIR}/UpStartVars.sh" ]]
      if [[ -f "${SITE_ARCHIVE}" ]]
      then
        echo "Where do we go now??"
        exit
      elif [[ "${FILES_COUNT}" -lt "17"  ]]
      then
        echo "There is only a file skeleton; as if previous install was interrupted.  Continuing . . .  "
        EMPTY_FILESYSTEM_ON_VOLUME="yes"
        return 0
      elif [[ "${FILES_COUNT}" -eq "19"  ]]
      then
        echo "There is a file skeleton; as if previous install was interrupted.  Continuing . . .  "
        EMPTY_FILESYSTEM_ON_VOLUME="yes"
        return 0
      elif [[ "${FILES_COUNT}" -eq "40"  ]]
      then
        echo "There is an partially installed system. Continuing . . .  "
        EMPTY_FILESYSTEM_ON_VOLUME="yes"
        return 0
      elif [[ "${FILES_COUNT}" -eq "42"  ]]
      then
        echo "There is an partially installed system. Continuing . . .  "
        EMPTY_FILESYSTEM_ON_VOLUME="yes"
        return 0
      fi
      export SITEBASE="null"
      export OERPUSR_HOME="null"
      export PSQLUSR_HOME="null"
#
      echo "What to do if ${FILES_COUNT} system files are found?????????????????????"
      exit
    fi
  fi
  #
}
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
echo "Found expected filesystem labels: \"${LBL_OPENERP}\" on \"${HOMEDEVICE}${DEV_OPENERP}\""\
      "and \"${LBL_POSTGRES}\" on \"${HOMEDEVICE}${DEV_POSTGRES}\"."
echo ""
#
get_system_parameters_off_volume
# validate_volume_content
echo "Leaving Validate Volume.  Instances of \"/tmp/UpStartVars.sh\"?   $(ls -l /tmp/UpStartVars.sh 2> /dev/null | wc -l) "

