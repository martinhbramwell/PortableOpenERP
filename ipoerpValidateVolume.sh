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
  if [[ -z ${LBL_OPENERP}  || -z ${LBL_POSTGRES}  || -z ${DEVICELABEL} ]]
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
  TEMP_DIR="/tmp/odoo"
  TEMP_DIR_ORIG=${TEMP_DIR}
  echo "Mounting OpenERP at temporary location ${TEMP_DIR}"
  echo "================================================"
  mkdir -p ${TEMP_DIR}
  umount ${TEMP_DIR} > /dev/null 2>&1 || :
  mount ${HOMEDEVICE}${DEV_OPENERP} ${TEMP_DIR}
  echo ""
  echo "Checking for obligatory components"
  echo "=================================="
  #

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
    FILES_COUNT=$(tree -L 3 /srv/site_mtt/ | wc -l)
    if [[ "${FILES_COUNT}" -lt "17" ]]
    then
      echo "There is only a file skeleton; as if previous install was interrupted.  Continuing . . .  "
      EMPTY_FILESYSTEM_ON_VOLUME="yes"
      return 0
    fi
    export SITEBASE="null"
    export OERPUSR_HOME="null"
    export PSQLUSR_HOME="null"

    echo "What to do if ${FILES_COUNT} system files are found?????????????????????"
    exit
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
echo "Found expected filesystem labels: \"${LBL_OPENERP}\" on \"${HOMEDEVICE}${DEV_OPENERP}\" \
and \"${LBL_POSTGRES}\" on \"${HOMEDEVICE}${DEV_POSTGRES}\"."
echo ""
validate_volume_content
echo "Leaving Validate Volume"





echo "Commented out >>>>>>>>>>>>> Probably duplicate crap.  >>>>>>>>>>>>>>>>>>>"
: <<'COMMENTEDBLOCK_1'


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

COMMENTEDBLOCK_1
echo "End commented section. <<<"

