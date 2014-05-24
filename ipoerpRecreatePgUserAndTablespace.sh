#!/bin/bash
#
if [[  -z ${SITENAME} || -z ${PSQLUSR} || -z ${PSQLUSRPWD}  || -z ${PSQLUSRTBSP}  || -z ${PSQLUSRDB}  || -z ${PSQLUSR_HOME}  ]]
then
#
echo "Usage :  ./ipoerpRecreatePgUserAndTablespace.sh"
echo "With required variables :"
echo " -     SITENAME : ${SITENAME}"
echo " -   PSQLUSRPWD : ${PSQLUSRPWD}"
echo " -      PSQLUSR : ${PSQLUSR}"
echo " - PSQLUSR_HOME : ${PSQLUSR_HOME}"
echo " -  PSQLUSRTBSP : ${PSQLUSRTBSP}"
echo " -    PSQLUSRDB : ${PSQLUSRDB}"
exit 0
#
fi
#
echo "Preparing access for : ${PSQLUSR} (pwd : '${PSQLUSRPWD}')"
#
if [[  6 -gt $(grep -o "${PSQLUSR}" /etc/postgresql/9.3/main/pg_hba.conf | wc -l) ]]
then
echo "Appending to pg_hba.conf"
cat << EOF >> /etc/postgresql/9.3/main/pg_hba.conf
local   ${PSQLUSR}          ${PSQLUSR}                             md5
local   ${PSQLUSR}          ${PSQLUSR}                             peer
local   ${PSQLUSRDB}            ${PSQLUSR}                            md5
local   ${PSQLUSRDB}            ${PSQLUSR}                             peer
EOF
fi
#
#
cd ~
declare TEMPDIR=${PSQLUSR_HOME}/temp
mkdir -p ${TEMPDIR}
#
[[ $(psql ${PSQLUSR} -c "" >/dev/null 2>&1 ; echo $?) -gt 0 ]] && \
     psql -c "CREATE DATABASE ${PSQLUSR};"
[[ 1 -gt $(psql -c "\du" | grep -c ${PSQLUSR} )  ]] && \
     psql -c "CREATE USER ${PSQLUSR} WITH CREATEDB ENCRYPTED PASSWORD '${PSQLUSRPWD}';"
#
if [[ -z $(psql -qtc "SELECT oid FROM pg_catalog.pg_tablespace WHERE spcname='${PSQLUSRTBSP}';" | tr -d ' ') ]]
then
    psql -c "CREATE TABLESPACE ${PSQLUSRTBSP} LOCATION '${TEMPDIR}';"
    psql -c "GRANT ALL ON TABLESPACE ${PSQLUSRTBSP} to ${PSQLUSR};"
fi
#
export TBL_SPC=$( psql -qtc "SELECT oid FROM pg_catalog.pg_tablespace WHERE spcname='${PSQLUSRTBSP}';" | tr -d ' ')
#
export DATA_DIR=$( psql -qtc "SELECT setting FROM pg_settings WHERE name = 'data_directory';")
echo $DATA_DIR/pg_tblspc/$TBL_SPC
ls -l $DATA_DIR/pg_tblspc/
echo " * * * FIXME :  NEED TO RECREATE TABLESPACE \"${PSQLUSRTBSP}\" IN \"${PSQLUSR_HOME}\"AND PLACE DATABASE \"${PSQLUSRDB}\" ON IT"
exit

[[ $(psql ${PSQLUSRDB} -c "" >/dev/null 2>&1 ; echo $?) -gt 0 ]] && \
    psql -c "CREATE DATABASE ${PSQLUSRDB} TABLESPACE ${PSQLUSRTBSP};"


