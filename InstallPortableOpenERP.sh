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
 echo "01) Fulfill all aptitude dependencis"
 source $DEFDIR/ipoerpAptDependencies.sh
 #
 echo "02) Set hostname"
 source $DEFDIR/iredmailSetHostName.sh
 #
 echo "03) Install all of iRedMail"
 source $DEFDIR/iredmailInstallAll.sh
 #
 echo "04) Install new volume"
 source $DEFDIR/ipoerpInstallNewVolume.sh
 #
 echo "05) Prepare users and directories"
 ls -l /opt/opener*
 source $DEFDIR/ipoerpPrepareUsersAndDirectories.sh
 #
 echo "06) Generate OpenERP server configuration file"
 ls -l /opt/opener*
 source $DEFDIR/ipoerpMakeOerpServerConfigFile.sh
 #
 echo "07) Prepare PostgreSQL User and Tablespace"
 ls -l /opt/opener*
 su postgres -c "source $DEFDIR/ipoerpPreparePgUserAndTablespace.sh"
 #
 echo "08) Update OpenERP source code."
# chown -R openerp:openerp /opt/openerp
# chmod -R 660 /opt/openerp
 ls -l /opt/opener*
 su openerp -c "source $DEFDIR/ipoerpUpdateOpenErpSourceCode.sh"
 #
 echo "09) Situate OpenERP source code."
 source $DEFDIR/ipoerpSituateOpenErpSourceCode.sh
 #
 echo "10) Pip install to virtual environment"
 su ${OERPUSR} -c "source $DEFDIR/ipoerpPipInstallToVEnv.sh"
 #
 echo "11) Patch OpenERP Launcher"
 su ${OERPUSR} -c "source $DEFDIR/ipoerpPatchOpenErpLauncher.sh"
 #
 echo "12) Make the UPStart script"
 source $DEFDIR/ipoerpMakeUpStartScript.sh
 #
 echo "Finished! A reboot is not required, but might be a good idea."
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
