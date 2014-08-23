#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.

if [[ $(whoami) != "root" ]]
then
  echo "You should execute as root from root's home directory";
  exit;
elif [[ $(pwd) != "/root" ]]
then
  echo "You should execute from root's home directory";
  exit;
fi


#
# Load environment variables
source $DEFDIR/MountParameters.sh
#
#  Ensure we have the specified attached drive/device
ls -l ${HOMEDEVICE} 2> /dev/null
if [[  $? -gt 0  ]]
then
   echo "
Did not detect ${HOMEDEVICE}.   Quitting . . .
"
   exit 2
fi
#
#
#  Ensure we have sufficient memory
export MEM=$(free | awk '/^Mem:/{print $2}')
if (( ${MEM} < 1000000   ))
then
   echo "
Low memory : ${MEM}kB.    Quitting . . .
"
   exit 1
fi
#
declare RESTORED_FROM_ARCHIVE="no"
declare STEP_THROUGH="no"
#
#
##
###
echo "1 >>>"
: <<'COMMENTEDBLOCK_1'
COMMENTEDBLOCK_1
echo "<<< 1"
###
##
#
echo "A) Fulfill all aptitude dependencis"
source $DEFDIR/ipoerpAptDependencies.sh
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "B) Install all of iRedMail"
source $DEFDIR/iredmailInstallAll.sh
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "C) Install new or Mount existing volume."
source $DEFDIR/ipoerpInstallVolume.sh
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "D) Get further working parameters, either from user or from previous installation. (Archive : \"${SITE_ARCHIVE}\"?)"
source /tmp/UpStartVars.sh 2> /dev/null
if [[ "$?" -lt "1" ]]
then
  echo "We are mounting a previous system. Got parameters from UpStartVars.sh"
elif [[ -f "${SITE_ARCHIVE}"  ]]
then
  echo "We have an archive \"${SITE_ARCHIVE}\" from which to regenerate a system."
  source $DEFDIR/ipoerpUnpackArchive.sh
  echo "We are restoring a previous system from an archive. Got parameters from its UpStartVars.sh"
else
  echo "We are NOT mounting a previous system. Get user supplied parameters"
  source $DEFDIR/CreateParameters.sh
fi
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "E) Prepare users and directories"
source $DEFDIR/ipoerpPrepareUsersAndDirectories.sh
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "F) Generate OpenERP server configuration file"
source $DEFDIR/ipoerpMakeOerpServerConfigFile.sh
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "G) Create or restore database"
source $DEFDIR/ipoerpPrepareDatabase.sh
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "H) Update OpenERP source code."
su openerp -c "source $DEFDIR/ipoerpUpdateOpenErpSourceCode.sh"
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "I) Situate OpenERP source code."
source $DEFDIR/ipoerpSituateOpenErpSourceCode.sh
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "J) Pip install to virtual environment"
su ${OERPUSR} -c "source $DEFDIR/ipoerpPipInstallToVEnv.sh"
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "K) Patch OpenERP Launcher"
su ${OERPUSR} -c "source $DEFDIR/ipoerpPatchOpenErpLauncher.sh"
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "L) Make the UpStart script"
source $DEFDIR/ipoerpMakeUpStartScript.sh
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "M) Make the UpStart \"conf\" file."
source $DEFDIR/ipoerpMakeUpstartConf.sh
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
echo "N) Patch IPTables and refresh firewall."
source $DEFDIR/ipoerpPatchIPTables.sh
[[ ${STEP_THROUGH} == "yes" ]] && read -p "Press [Enter] to continue..."
#
if [[ ${RESTORED_FROM_ARCHIVE} == "no" ]]
then
echo "O) Make a transferable archive."
source $DEFDIR/ipoerpMakeArchive.sh
fi
#
echo "               -----------------------   "
echo "Finished! A reboot is not required, but might be a good idea."
echo "Occasionally, when Odoo is accessed for the very first time, some files are not found.  If so, a deep page refresh <ctrl-r>, one time only, may be enough to get them."
echo "Visit http://${NEWHOSTNAME}.${NEWHOSTDOMAIN}:${ACCESS_PORT}/"
echo "Parameters you specified : "
echo "   Password for Database Management : ${PSQLUSRPWD}"
echo "              Name of main database : ${PSQLUSRDB}
"
echo "Useful commands if things go wrong :"
echo "   cat /etc/init/${SCRIPTNAME}.conf"
echo "   cat ${OERPUSR_WORK}/${SCRIPTFILE}"
echo "   tail -fn 100 /var/log/upstart/${UPSTART_JOB}.log"
echo ""

#
#
##
###
echo "2 >>>"
: <<'COMMENTEDBLOCK_2'
COMMENTEDBLOCK_2
echo "<<< 2"
###
##
#

