#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
# Define the name of the OpenERP site
export SITENAME="site_y"
export SITEUSER="user_y"
#
# Define the host name and domain to be used for this machine
export NEWHOSTNAME="mts"
export NEWHOSTDOMAIN="justtrade.net"
#
# Define the identifiers OpenERP will use to connect to postgres
export PSQLUSR="psql_${SITEUSER}"
export PSQLUSR_HOME="/srv/${SITENAME}/postgres"
export PSQLUSRPWD=";Mkjiu87"
#
# Define the initial database for OpenERP
export PSQLUSRTBSP="${SITENAME}"
export PSQLUSRDB="${SITENAME}_db"
#
# Define the identifiers OpenERP will use within the OS
export OERPUSR="oerp_${SITEUSER}"
export OERPUSR_HOME="/srv/${SITENAME}/openerp"
#
# Specify OpenERP XMLRPC port #
export ACCESS_PORT=8029
#
# Installers directory
export INSTALLERS=~/installers
#
if [[  1 -eq 0  ]]
then
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
su oerp_user_z -c "source $DEFDIR/ipoerpUpdateOpenErpSourceCode.sh"
#
echo "08) Patch OpenERP Launcher"
su oerp_user_z -c "source $DEFDIR/ipoerpPatchOpenErpLauncher.sh"
#
echo "09) Pip install to virtual environment"
su oerp_user_z -c "source $DEFDIR/ipoerpPipInstallToVEnv.sh"
#
echo "10) Make the UPStart script"
source $DEFDIR/ipoerpMakeUpStartScript.sh
#
echo "Finished! A reboot will be required."
echo "Give it 5 mins, then visit http://${NEWHOSTNAME}.${NEWHOSTDOMAIN}:${ACCESS_PORT}/"
#
else
#
echo "Starting partial execution!"
#
echo "01) Fulfill all apt-get dependencis"
source $DEFDIR/ipoerpAptDependencies.sh
#
echo "02) Set hostname"
source $DEFDIR/iredmailSetHostName.sh
#
echo "03) Install all of iRedMail"
source $DEFDIR/iredmailInstallAll.sh
#
echo "Partial run complete!"
#
fi
