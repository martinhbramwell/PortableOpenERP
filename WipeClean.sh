#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
rm -f /etc/init/odoo-site_mtt.conf
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
#
rm -fr /srv/site_mtt
rm -fr /srv/postgres
parted -s /dev/vdb mklabel gpt

