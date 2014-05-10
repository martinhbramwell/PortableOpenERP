#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
#
# Load environment variables
source $DEFDIR/Parameters.sh
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
echo "04) Prepare users and directories"
source $DEFDIR/ipoerpPrepareUsersAndDirectories.sh
#
echo "05) Generate OpenERP server configuration file"
source $DEFDIR/ipoerpMakeOerpServerConfigFile.sh
#
echo "06) Prepare PostgreSQL User and Tablespace"
su postgres -c "source $DEFDIR/ipoerpPreparePgUserAndTablespace.sh"
#
echo "07) Update OpenERP source code."
su ${OERPUSR} -c "source $DEFDIR/ipoerpUpdateOpenErpSourceCode.sh"
#
echo "08) Patch OpenERP Launcher"
su ${OERPUSR} -c "source $DEFDIR/ipoerpPatchOpenErpLauncher.sh"
#
echo "09) Pip install to virtual environment"
su ${OERPUSR} -c "source $DEFDIR/ipoerpPipInstallToVEnv.sh"
#
echo "10) Make the UPStart script"
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
echo "11) Install new volume"
source $DEFDIR/ipoerpInstallNewVolume.sh
#
echo "Partial run complete!"
#
fi
