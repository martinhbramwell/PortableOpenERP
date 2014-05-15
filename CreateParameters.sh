#!/bin/bash
#
# Define the name of the OpenERP site
export SITENAME="site_y"
export SITEUSER="user_y"
#
# Define the host name and domain to be used for this machine
export NEWHOSTNAME=""
export NEWHOSTDOMAIN=""
#
# Define the identifiers OpenERP will use to connect to postgres
export PSQLUSRPWD=""
export PSQLUSR="psql_${SITEUSER}"
export PSQLUSR_HOME="/srv/${SITENAME}/postgres"
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
# iRedmail version
export IREDMAILPKG="iRedMail-0.8.7"
#
