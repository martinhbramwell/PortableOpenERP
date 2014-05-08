#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
# Define the host name and domain to be used for this machine
export NEWHOSTNAME=""
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
# Installers directory
export INSTALLERS=~/installers
#
if [[  1 -eq 0  ]]
then
#
#
echo "01) Fulfill all apt-get dependencis"
source $DEFDIR/ipoerpAptDependencies.sh
echo "02) Set hostname"
source $DEFDIR/iredmailSetHostName.sh
echo "03) Install all of iRedMail"
source $DEFDIR/iredmailInstallAll.sh
echo "04) Prepare users and directories"
source $DEFDIR/ipoerpPrepareUsersAndDirectories.sh
echo "05) Generate OpenERP server configuration file"
source $DEFDIR/ipoerpMakeOerpServerConfigFile.sh
echo "06) Prepare PostgreSQL User and Tablespace"
su postgres -c "source $DEFDIR/ipoerpPreparePgUserAndTablespace.sh"
echo "07) Update OpenERP source code."
su oerp_user_z -c "source $DEFDIR/ipoerpUpdateOpenErpSourceCode.sh"
echo "08) Patch OpenERP Launcher"
su oerp_user_z -c "source $DEFDIR/ipoerpPatchOpenErpLauncher.sh"
echo "09) Pip install to virtual environment"
su oerp_user_z -c "source $DEFDIR/ipoerpPipInstallToVEnv.sh"
echo "10) Make the UPStart script"
source $DEFDIR/ipoerpMakeUpStartScript.sh
#
else
#
echo "Done it!"
#
fi


