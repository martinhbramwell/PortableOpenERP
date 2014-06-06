#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
# if [[  -z ${OOO} || -z ${SITENAME} || -z ${DATABASE_ARCHIVE}  || -z ${PSQLUSRDB}  ]]
if [[                 -z ${SITENAME} || -z ${DATABASE_ARCHIVE}  || -z ${PSQLUSRDB}  ]]
then
#
echo "Usage :  ./ipoerpMakeArchive.sh"
echo "With required variables :"
echo " -         SITENAME : ${SITENAME}"
echo " - DATABASE_ARCHIVE : ${DATABASE_ARCHIVE}"
echo " -        PSQLUSRDB : ${PSQLUSRDB}"
exit 0
fi

su postgres -c "pg_dump ${PSQLUSRDB} | gzip -c > ${DATABASE_ARCHIVE}"
#
cp ${DATABASE_ARCHIVE} /srv/${SITENAME}/openerp/${PSQLUSRDB}.gz
tar jcf ${SITE_ARCHIVE} /srv/${SITENAME}/openerp
#

