#!/bin/bash
#
# Define the name of the OpenERP site user
export SITEUSER=""
#
# Define the host name and domain to be used for this machine
export NEWHOSTNAME=""
export NEWHOSTDOMAIN=""
#
# Define the identifiers OpenERP will use to connect to postgres
export PSQLUSRPWD=""
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
export PSQLUSR="psql_${SITEUSER}"
export PSQLUSR_HOME="/srv/${SITENAME}/${POSTGRESUSR}"
#
# Define the initial database for OpenERP
export PSQLUSRTBSP="${SITENAME}"
export PSQLUSRDB="${SITENAME}_db"
#
# Define the identifiers OpenERP will use within the OS
export OERPUSR="oerp_${SITEUSER}"
export OERPUSR_WORK="/srv/${SITENAME}/${OPENERPUSR}"
export OERPUSR_HOME="${OERPUSR_WORK}/home"
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

