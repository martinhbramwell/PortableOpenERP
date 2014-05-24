#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
# Load environment variables
source $DEFDIR/CreateParameters.sh
source $DEFDIR/MountParameters.sh
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
if [[  -z ${PARTIAL_BUILD}  ]]
then
 #
 echo "A) Fulfill all aptitude dependencis"
 source $DEFDIR/ipoerpAptDependencies.sh
 #
 echo "B) Set hostname"
 source $DEFDIR/iredmailSetHostName.sh
 #
 echo "C) Install all of iRedMail"
 source $DEFDIR/iredmailInstallAll.sh
 #
 echo "D) Install new volume"
 source $DEFDIR/ipoerpInstallNewVolume.sh
 #
 echo "E) Prepare users and directories"
 source $DEFDIR/ipoerpPrepareUsersAndDirectories.sh
 #
 echo "F) Generate OpenERP server configuration file"
 source $DEFDIR/ipoerpMakeOerpServerConfigFile.sh
 #
 echo "G) Prepare PostgreSQL User and Tablespace"
 su postgres -c "source $DEFDIR/ipoerpPreparePgUserAndTablespace.sh"
 #
 echo "H) Update OpenERP source code."
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
 echo "Finished! A reboot is not required, but might be a good idea."
 echo "The first time a page is accessed, some files are not found.  A refresh is required, one time only, to get them."
 echo "Visit http://${NEWHOSTNAME}.${NEWHOSTDOMAIN}:${ACCESS_PORT}/"
 echo "Login  : admin:${PSQLUSRPWD}"
 #
else
 #
 echo "Starting partial execution!"
 #
 echo "Partial run ended!"
 #
fi
