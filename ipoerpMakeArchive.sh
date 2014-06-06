#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
# if [[  -z ${OOO} || -z ${SITENAME} || -z ${DATABASE_ARCHIVE}  || -z ${PSQLUSRDB}  ||  -z  ${SITE_ARCHIVE}  ]]
if [[                 -z ${SITENAME} || -z ${DATABASE_ARCHIVE}  || -z ${PSQLUSRDB}  ||  -z  ${SITE_ARCHIVE}  ]]
then
#
echo "Usage :  ./ipoerpMakeArchive.sh"
echo "With required variables :"
echo " -         SITENAME : ${SITENAME}"
echo " - DATABASE_ARCHIVE : ${DATABASE_ARCHIVE}"
echo " -        PSQLUSRDB : ${PSQLUSRDB}"
echo " -     SITE_ARCHIVE : ${SITE_ARCHIVE}"
exit 0
fi

pushd /tmp
if [[  $(su postgres -c "psql -l | grep -c '^ ${PSQLUSRDB}\b'") -gt 0 ]]
then
  su postgres -c "pg_dump ${PSQLUSRDB} | gzip -c > ${DATABASE_ARCHIVE}"
  #
  cp ${DATABASE_ARCHIVE} /srv/${SITENAME}/openerp/${PSQLUSRDB}.gz
  tar jcf ${SITE_ARCHIVE} /srv/${SITENAME}/openerp
else
  echo "No database, so not worth making the archive."
fi
popd
#

