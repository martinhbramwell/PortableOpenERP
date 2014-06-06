#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
# Load environment variables
source $DEFDIR/MountParameters.sh
# source $DEFDIR/CreateParameters.sh
#
stop odoo-${SITENAME}
#
umount /srv/${SITENAME}/openerp
umount /srv/${SITENAME}/postgres
#
rm -f /etc/init/odoo-${SITENAME}.conf
#
if [[ -z $(grep "THE-AREA-BELOW-IS-RESERVED-FOR-PATCHING" /etc/fstab)   ]]
then
  echo "Clean already"
  echo "==============================="
else
  echo "Delete previous patching, if any."
  echo "================================="
  # awk -v VAR=${FLAGTAG} '{print} $0 ~ VAR {exit}' /etc/fstab > /etc/fstab
  awk -v VAR=${FLAGTAG} '{print} $0 ~ VAR {exit}' /etc/fstab > fstab_new
  mv fstab_new /etc/fstab
fi
pushd /tmp
su postgres -c "psql -c 'DROP DATABASE ${SITENAME}_db;'"
su postgres -c "psql -c 'DROP TABLESPACE ${SITENAME};'"
popd
#
rm -fr /tmp/UpStart*
rm -fr /tmp/odoo/*
#
rm -fr /srv/${SITENAME}/*
rm -fr /srv/openerp
rm -fr /srv/postgres
parted -s ${HOMEDEVICE} mklabel gpt
#
if [[  -f ${SITE_ARCHIVE}.done  ]]
then
  mv ${SITE_ARCHIVE}.done ${SITE_ARCHIVE}
fi


