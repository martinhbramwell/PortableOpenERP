#!/bin/bash
#
# Define the name of the OpenERP site
export SITENAME="site_mtt"
export SITEUSER="user_mtt"
#
# Choose to skip the normal command sequence
export PARTIAL_BUILD=""  #  Non-blank means yes
#
# System device on which to install site  ** NOTHING WILL REMAIN OF ANY PRIOR CONTENT **
export HOMEDEVICE="/dev/vdb" # eg, "/dev/sdb"
#
# Specify OpenERP XMLRPC port #
export ACCESS_PORT=8029
#
# Generic names
export POSTGRESUSR="postgres"
export OPENERPUSR="openerp"
#
# Identifiers for Odoo's database user.
export PSQLUSR="psql_${SITEUSER}"
export PSQLUSR_HOME="/srv/${SITENAME}/${POSTGRESUSR}"
#
# Define the identifiers OpenERP will use within the OS
export OERPUSR="oerp_${SITEUSER}"
export OERPUSR_WORK="/srv/${SITENAME}/${OPENERPUSR}"
export OERPUSR_HOME="${OERPUSR_WORK}/home"
#
#  System introspection flags. Written by volume creation process and exacted by mounting process.
export LBL_OPENERP="OpenERP"
export LBL_POSTGRES="PostgreSQL"
export FLAGTAG="THE-AREA-BELOW-IS-RESERVED-FOR-PATCHING"
#
# Database backup archive
export SITE_ARCHIVE="/srv/site_mtt.tar.bz2"
#               eg, "/srv/site_tkd.tar.bz2"
export DATABASE_ARCHIVE="/srv/site_mtt/postgres/backups/site_mtt_db.gz"
#               eg,     "/srv/site_tkd/postgres/backups/site_tkd_db.gz"
#
export TRANSPORTED_DB_ARCHIVE="${OERPUSR_WORK}/${PSQLUSRDB}.gz"
export UPSTARTVARS_LOCATION="${OERPUSR_WORK}/UpStartVars.sh"
export DATABASE_BACKUPS_DIR="${PSQLUSR_HOME}/backups"
#
# The hypervisor label used for this device, if such is required.
export DEVICELABEL="NewStartTgtDrv" # eg, "Volume 4775"
#

