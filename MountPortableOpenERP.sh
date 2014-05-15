
#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
#
# Load environment variables
source $DEFDIR/MountParameters.sh
#
if [[  -z ${PARTIAL_BUILD}  ]]
then
#
echo "Get create phase parameters"
source $DEFDIR/CreateParameters.sh
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
exit
#
echo "Finished! A reboot is not required, but might be a good idea."
echo "Visit http://${NEWHOSTNAME}.${NEWHOSTDOMAIN}:${ACCESS_PORT}/"
echo "Login  : admin:${PSQLUSRPWD}"
#
else
#
echo "Starting partial execution!"
#
echo "04) Install new volume"
source $DEFDIR/ipoerpMountSiteVolume.sh
#
echo "Partial run ended!"
#
fi
