#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
# Define the host name and domain to be used for this machine
export NEWHOSTNAME="mtt"
export NEWHOSTDOMAIN=""
#
# Define the identifiers OpenERP will use to connect to postgres
export PSQLUSR="psql_user_z"
export PSQLUSR_HOME="/srv/site_z/postgres"
export PSQLUSRPWD=""
#
# Define the initial database for OpenERP
export PSQLUSRTBSP="site_z"
export PSQLUSRDB="site_z_db"
#
# Define the identifiers OpenERP will use within the OS
export OERPUSR="oerp_user_z"
export OERPUSR_HOME="/srv/site_z/openerp"
#
# Specify OpenERP XMLRPC port #
export ACCESS_PORT=8019
#
if [[  1 -eq 0  ]]
then
#
source $DEFDIR/ipoerpAptDependencies.sh
#
#
source $DEFDIR/ipoerpPrepareUsersAndDirectories.sh
source $DEFDIR/ipoerpMakeOerpServerConfigFile.sh
su postgres -c "source $DEFDIR/ipoerpPreparePgUserAndTablespace.sh"
su oerp_user_z -c "source $DEFDIR/ipoerpUpdateOpenErpSourceCode.sh"
su oerp_user_z -c "source $DEFDIR/ipoerpPatchOpenErpLauncher.sh"
su oerp_user_z -c "source $DEFDIR/ipoerpPipInstallToVEnv.sh"
source $DEFDIR/ipoerpMakeUpStartScript.sh
#
else
#
source $DEFDIR/iredmailSetHostName.sh
source $DEFDIR/iredmailInstallAll.sh
#
fi
exit 0

