
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
 echo "A) Fulfill all aptitude dependencis"
 source $DEFDIR/ipoerpAptDependencies.sh
 #
 echo "B) Set hostname"
 source $DEFDIR/iredmailSetHostName.sh
 #
 echo "C) Install all of iRedMail"
 source $DEFDIR/iredmailInstallAll.sh
 #
 #
 echo "D) Install new volume"
 source $DEFDIR/ipoerpMountSiteVolume.sh
#
#
echo "Finished! A reboot is not required, but might be a good idea."
echo "Visit http://${NEWHOSTNAME}.${NEWHOSTDOMAIN}:${ACCESS_PORT}/"
echo "Login  : admin:${PSQLUSRPWD}"
#
else
#
 echo "Starting partial execution!"
 #
 echo "E) Prepare PostgreSQL User and Tablespace"
 su postgres -c "source $DEFDIR/ipoerpRecreatePgUserAndTablespace.sh"
exit #
 echo "F) Patch IPTables"
 source $DEFDIR/ipoerpPatchIPTables.sh
 #
 echo "Partial run ended!"
#
fi
