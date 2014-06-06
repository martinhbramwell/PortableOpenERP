#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
# Load environment variables
source $DEFDIR/MountParameters.sh
# source $DEFDIR/CreateParameters.sh
#
ls -l ${HOMEDEVICE} 2> /dev/null
if [[  $? -gt 0  ]]
then
   echo "
Did not detect ${HOMEDEVICE}.   Quitting . . .
"
   exit 2
fi
#
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
#
export DATABASE_EXISTS="unknown"
if [[  -z ${PARTIAL_BUILD}  ]]
then
#
 #
echo "Commented out >>>"
: <<'COMMENTEDBLOCK_1'
COMMENTEDBLOCK_1
echo "End commented section. <<<"
 echo "A) Fulfill all aptitude dependencis"
 source $DEFDIR/ipoerpAptDependencies.sh
 #
# echo "B) Set hostname"
# source $DEFDIR/iredmailSetHostName.sh
 #
 echo "B) Install all of iRedMail"
 source $DEFDIR/iredmailInstallAll.sh
 #
 echo "C) Install new or Mount existing volume."
 source $DEFDIR/ipoerpInstallVolume.sh
 #
 echo "D) Get further working parameters, either from user or from previous installation. (Archive : \"${SITE_ARCHIVE}\"?)"
 source /tmp/UpStartVars.sh 2> /dev/null
 if [[ "$?" -lt "1" ]]
 then
   echo "We are mounting a previous system. Got parameters from UpStartVars.sh"
 elif [[ -f "${SITE_ARCHIVE}"  ]]
 then
   echo "We have an archive \"${SITE_ARCHIVE}\" from which to regenerate a system."
   echo "Decompressing archive . . ."
   tar jxf ${SITE_ARCHIVE} -C /
   mv ${SITE_ARCHIVE} ${SITE_ARCHIVE}.done
   echo "Moving /srv/${SITENAME}/openerp/${SITENAME}_db.gz ${DATABASE_ARCHIVE}"
   ls -l /srv/${SITENAME}/openerp/${SITENAME}_db.gz
   mkdir -p /srv/${SITENAME}/postgres/backups
   mv /srv/${SITENAME}/openerp/${SITENAME}_db.gz ${DATABASE_ARCHIVE}
   RESTORED_FROM_ARCHIVE="yes"
   echo "Get further working parameters from previous installation."
   USV=/srv/${SITENAME}/openerp/UpStartVars.sh
   source ${USV} 2> /dev/null
   if [[ "$?" -gt "0" ]]
   then
     echo "Unable to read ${USV}"
   fi
   echo "We are restoring a previous system from an archive. Got parameters from its UpStartVars.sh"
 else
   echo "We are NOT mounting a previous system. Get user supplied parameters"
   source $DEFDIR/CreateParameters.sh
 fi
 #
 # echo "D) Mount filesystem."
 # source $DEFDIR/ipoerpPermanentMount.sh
 # echo "! -- ${SITENAME}"
 #
 echo "E) Prepare users and directories"
 source $DEFDIR/ipoerpPrepareUsersAndDirectories.sh
 #
 echo "F) Generate OpenERP server configuration file"
 source $DEFDIR/ipoerpMakeOerpServerConfigFile.sh
 #
 echo "G) Create or restore database"
 source $DEFDIR/ipoerpPrepareDatabase.sh
 #
# echo "G) Prepare PostgreSQL User and Tablespace"
# su postgres -c "source $DEFDIR/ipoerpPreparePgUserAndTablespace.sh"
# #
 echo "H) Update OpenERP source code."
  read -p "Press [Enter] to continue..."
 su openerp -c "source $DEFDIR/ipoerpUpdateOpenErpSourceCode.sh"
 #
 echo "I) Situate OpenERP source code."
 source $DEFDIR/ipoerpSituateOpenErpSourceCode.sh
 #
 echo "J) Pip install to virtual environment"
 su ${OERPUSR} -c "source $DEFDIR/ipoerpPipInstallToVEnv.sh"
 #
 echo "K) Patch OpenERP Launcher"
 su ${OERPUSR} -c "source $DEFDIR/ipoerpPatchOpenErpLauncher.sh"
 #
 echo "L) Make the UpStart script"
 source $DEFDIR/ipoerpMakeUpStartScript.sh
 #
 echo "M) Make the UpStart \"conf\" file."
 source $DEFDIR/ipoerpMakeUpstartConf.sh
 #
 echo "N) Patch IPTables and refresh firewall."
 source $DEFDIR/ipoerpPatchIPTables.sh
 #
 if [[ ${RESTORED_FROM_ARCHIVE} == "no" ]]
 then
   echo "O) Make a transferable archive."
   source $DEFDIR/ipoerpMakeArchive.sh
 fi
 #
 echo "               -----------------------   "
 echo "Finished! A reboot is not required, but might be a good idea."
 echo "The first time a page is accessed, some files are not found.  A refresh is required, one time only, to get them."
 echo "Visit http://${NEWHOSTNAME}.${NEWHOSTDOMAIN}:${ACCESS_PORT}/"
 echo "Login  : admin:${PSQLUSRPWD}"
#
 #
###
echo "Commented out >>>"
: <<'COMMENTEDBLOCK_2'
COMMENTEDBLOCK_2
echo "End commented section. <<<"
 #
else
 #
 echo "Starting partial execution!"
 #
 echo "Partial run ended!"
 #
fi
