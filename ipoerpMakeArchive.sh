#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
# if [[  -z ${OOO} || -z ${SITENAME} || -z ${DATABASE_ARCHIVE}  || -z ${PSQLUSRTBSP}  || -z ${PSQLUSRDB}  || -z ${PSQLUSR_HOME}  ]]
if [[                 -z ${SITENAME} || -z ${DATABASE_ARCHIVE}  || -z ${PSQLUSRTBSP}  || -z ${PSQLUSRDB}  || -z ${PSQLUSR_HOME}  ]]
then
#
echo "Usage :  ./ipoerpMakeArchive.sh"
echo "With required variables :"
echo " -         SITENAME : ${SITENAME}"
echo " - DATABASE_ARCHIVE : ${DATABASE_ARCHIVE}"
echo " -        PSQLUSRDB : ${PSQLUSRDB}"
echo " -      PSQLUSR : ${PSQLUSR}"
echo " - PSQLUSR_HOME : ${PSQLUSR_HOME}"
echo " -  PSQLUSRTBSP : ${PSQLUSRTBSP}"
exit 0
fi

su postgres -c "pg_dump ${PSQLUSRDB} | gzip -c > ${DATABASE_ARCHIVE}"
#
tar jcvf ${SITE_ARCHIVE} /srv/${SITENAME}
#

