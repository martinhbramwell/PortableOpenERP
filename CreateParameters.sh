#!/bin/bash
#
# Define the name of the OpenERP site user
export SITEUSER="user_mtt"
#
# Define the host name and domain to be used for this machine
export NEWHOSTNAME="mtt"
export NEWHOSTDOMAIN="justtrade.net"
#
# Define the identifiers OpenERP will use to connect to postgres
export PSQLUSRPWD="okmmpl,,"
#
if [[ -z ${SITEUSER} || -z ${SITENAME} || -z ${POSTGRESUSR} || -z ${OPENERPUSR} ]]
then
#
echo "Usage :  ./ipoerpMakeUpStartScript.sh  "
echo "With required variables :"
echo " -     SITEUSER : ${SITEUSER}"
echo " -     SITENAME : ${SITENAME}"
echo " - POSTGRESUSR  : ${POSTGRESUSR}"
echo " -  OPENERPUSR  : ${OPENERPUSR}"
exit
#
fi
# Define the initial database for OpenERP
export PSQLUSRTBSP="${SITENAME}"
export PSQLUSRDB="${SITENAME}_db"
#
# Define Upstart Job Name
export UPSTART_JOB="odoo_${SITENAME}"
#
# Installers directory
export INSTALLERS=~/installers
#
# iRedmail version
export IREDMAILPKG="iRedMail-0.8.7"
#

