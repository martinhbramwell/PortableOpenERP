#!/bin/bash
#
if [[  -z ${SITENAME} || -z ${PSQLUSR} || -z ${PSQLUSRPWD}  || -z ${PSQLUSRTBSP}  || -z ${PSQLUSRDB}  || -z ${PSQLUSR_HOME}  ]]
then
#
echo "Usage :  ./ipoerpPreparePgUserAndTablespace.sh"
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
echo "Preparing access for : ${PSQLUSR}"
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
else
  echo "Expected pg_hba.conf settings seem to have been made already."
fi
#
cd ~
#
if [[ $(psql ${PSQLUSR} -c "" >/dev/null 2>&1 ; echo $?) -gt 0 ]]
then
  echo "Give PostgreSQL user ${PSQLUSR} a personal database."
  psql -c "CREATE DATABASE ${PSQLUSR};"
else
  echo "Found ${PSQLUSR} database exists already."
fi
#
if [[ 1 -gt $(psql -c "\du" | grep -c ${PSQLUSR} )  ]]
then
  echo "Create user ${PSQLUSR}."
  psql -c "CREATE USER ${PSQLUSR} WITH CREATEDB ENCRYPTED PASSWORD '${PSQLUSRPWD}';"
else
  echo "User ${PSQLUSR} already present."
fi
#
if [[ -z $(psql -qtc "SELECT oid FROM pg_catalog.pg_tablespace WHERE spcname='${PSQLUSRTBSP}';" | tr -d ' ') ]]
then
  echo "Create tablespace ${PSQLUSRTBSP}."
  psql -c "CREATE TABLESPACE ${PSQLUSRTBSP} LOCATION '${PSQLUSR_HOME}/data';"
  psql -c "GRANT ALL ON TABLESPACE ${PSQLUSRTBSP} to ${PSQLUSR};"
else
  echo "Tablespace ${PSQLUSRTBSP} already defined."
fi
#

if [[ 1 == 0  ]]   #  If we create our main database now, OpenERP can't create it.
then
  if [[ $(psql ${PSQLUSRDB} -c "" >/dev/null 2>&1 ; echo $?) -gt 0 ]]
  then
    echo "Create database ${PSQLUSRDB}.($(whoami))"
    psql -c "CREATE DATABASE ${PSQLUSRDB} TABLESPACE ${PSQLUSRTBSP};"
  else
    echo "Database ${PSQLUSRDB} already exists."
  fi
fi



