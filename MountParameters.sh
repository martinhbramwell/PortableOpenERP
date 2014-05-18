#!/bin/bash
#
# Choose to skip the normal command sequence
export PARTIAL_BUILD=""  #  Non-blank means yes
#
# System device on which to install site  ** NOTHING WILL REMAIN OF ANY PRIOR CONTENT **
export HOMEDEVICE="" # eg, "/dev/vdb"
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
# The hypervisor label used for this device, if such is required.
export DEVICELABEL="TempSourceDrv" # eg, "Volume 4775"
#

