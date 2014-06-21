#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
# Load environment variables
source $DEFDIR/MountParameters.sh
# source $DEFDIR/CreateParameters.sh
#
echo "Stop Odoo server."
stop odoo-${SITENAME}  2> /dev/null
#
echo "Unmount volumes."
umount ${HOMEDEVICE}1 2> /dev/null
umount ${HOMEDEVICE}2 2> /dev/null
umount /srv/${SITENAME}/openerp 2> /dev/null
umount /srv/${SITENAME}/postgres 2> /dev/null
#
if [[ -z $(grep "THE-AREA-BELOW-IS-RESERVED-FOR-PATCHING" /etc/fstab)   ]]
then
  echo "Clean already"
else
  echo "Delete previous patching, if any."
  # awk -v VAR=${FLAGTAG} '{print} $0 ~ VAR {exit}' /etc/fstab > /etc/fstab
  awk -v VAR=${FLAGTAG} '{print} $0 ~ VAR {exit}' /etc/fstab > fstab_new
  mv fstab_new /etc/fstab
fi
echo "Drop database and tablespace."
pushd /tmp  > /dev/null
su postgres -c "psql -c 'DROP DATABASE ${SITENAME}_db;'"  2> /dev/null
su postgres -c "psql -c 'DROP TABLESPACE ${SITENAME};'" 2> /dev/null
popd  > /dev/null
#
#
echo "Erase Odoo config files and directories."
rm -f /etc/init/odoo-${SITENAME}.conf
rm -fr /tmp/UpStart*
rm -fr /tmp/odoo/*
#
rm -fr /srv/${SITENAME}/*
rm -fr /srv/openerp
rm -fr /srv/postgres
#
echo "Erase volume partitions."
parted -s ${HOMEDEVICE} mklabel gpt
#

if [[  -f ${SITE_ARCHIVE}.done  ]]
then
  echo "Flag archive as unused."
  mv ${SITE_ARCHIVE}.done ${SITE_ARCHIVE}
fi


