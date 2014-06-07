#!/bin/bash
#
if [[  -z "${SITE_ARCHIVE}"  || -z "${SITENAME}"  || -z "${DATABASE_ARCHIVE}"  ]]
then
  echo "Usage :  ./ipoerpPatchOpenErpLauncher.sh"
  echo "With required variables :"
  echo " - SITE_ARCHIVE : ${SITE_ARCHIVE}"
  echo " - SITENAME : ${SITENAME}"
  echo " - DATABASE_ARCHIVE : ${DATABASE_ARCHIVE}"
  exit
fi
#
echo "Decompressing archive . . ."
tar jxf ${SITE_ARCHIVE} -C /
mv ${SITE_ARCHIVE} ${SITE_ARCHIVE}.done
echo "Moving ${TRANSPORTED_DB_ARCHIVE} ${DATABASE_ARCHIVE}"
ls -l /srv/${SITENAME}/openerp/${SITENAME}_db.gz
mkdir -p ${DATABASE_BACKUPS_DIR}
mv ${TRANSPORTED_DB_ARCHIVE} ${DATABASE_ARCHIVE}
RESTORED_FROM_ARCHIVE="yes"
echo "Get further working parameters from previous installation."
source ${UPSTARTVARS_LOCATION} 2> /dev/null
if [[ "$?" -gt "0" ]]
then
  echo "Unable to read ${USV}"
fi
#
