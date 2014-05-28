#!/bin/bash
#
# Choose to skip the normal command sequence
export PARTIAL_BUILD=""  #  Non-blank means yes
#
# System device on which to install site  ** NOTHING WILL REMAIN OF ANY PRIOR CONTENT **
export HOMEDEVICE="" # eg, "/dev/sdb"
#
# Specify OpenERP XMLRPC port #
export ACCESS_PORT=8029
#
#  System introspection flags. Written by volume creation process and exacted by mounting process.
export LBL_OPENERP="OpenERP"
export LBL_POSTGRES="PostgreSQL"
export FLAGTAG="THE-AREA-BELOW-IS-RESERVED-FOR-PATCHING"
#
# Generic names
export POSTGRESUSR="postgres"
export OPENERPUSR="openerp"
#
# Database backup archive
export SITE_ARCHIVE=""  # eg, "/srv/site_tkd.tar.bz2"
export DATABASE_ARCHIVE=""  # eg, "/srv/site_tkd/postgres/backups/site_tkd_db.gz"
#
# The hypervisor label used for this device, if such is required.
export DEVICELABEL="" # eg, "Volume 4775"
#

