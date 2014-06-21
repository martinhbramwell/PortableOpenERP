#!/bin/bash
#
# if [[  -z ${OOO} || -z ${SITENAME} || -z ${PSQLUSR} || -z ${PSQLUSRPWD}  || -z ${PSQLUSRTBSP}  || -z ${PSQLUSRDB}  || -z ${PSQLUSR_HOME}  ]]
if [[                 -z ${SITENAME} || -z ${PSQLUSR} || -z ${PSQLUSRPWD}  || -z ${PSQLUSRTBSP}  || -z ${PSQLUSRDB}  || -z ${PSQLUSR_HOME}  ]]
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
fi
#
#
function drop_fs_tablespace()
{
  echo "Dropping tablespace \"${PSQLUSRTBSP}\" from device filesystem path \"${TABLESPACE_DIRECTORY}\"."
  mkdir -p ${DATA_DIRECTORY_PATH}
  rm -fr ${TABLESPACE_DIRECTORY}
  return $?
}
export -f drop_fs_tablespace
#
#
function drop_pg_tablespace()
{
  echo "Dropping tablespace \"${PSQLUSRTBSP}\" from Postgres..."
  psql -c "DROP TABLESPACE ${PSQLUSRTBSP};"
}
export -f drop_pg_tablespace
#
#
function create_tablespace()
{
  echo "Creating tablespace \"${PSQLUSRTBSP}\" in \"${DATA_DIRECTORY_PATH}\"..."
  psql -c "CREATE TABLESPACE ${PSQLUSRTBSP} LOCATION '${DATA_DIRECTORY_PATH}';"
}
export -f create_tablespace
#
#
function detect_pg_spc_database()
{
  DB_CHECK=$( \
    psql -qtc  \
    "SELECT d.oid FROM pg_database d \
     LEFT JOIN pg_catalog.pg_tablespace t ON t.oid = d.dattablespace \
    WHERE datistemplate = false \
      AND spcname ='${PSQLUSRTBSP}' \
      AND datname ='${PSQLUSRDB}' \
    ;" | tr -d ' ')

echo "SELECT d.oid FROM pg_database d LEFT JOIN pg_catalog.pg_tablespace t ON t.oid = d.dattablespace WHERE datistemplate = false AND spcname ='${PSQLUSRTBSP}' AND datname ='${PSQLUSRDB}';"


  echo "Database OID = ${DB_CHECK}"
  [[ "XX" == "X${DB_CHECK}X" ]]  &&  return ${UNEXPECTED_DATA}
  echo "Database in expected tablespace."
}
export -f detect_pg_spc_database
#
#
function database_empty()
{
  echo "Is database empty?"
  TABLE_COUNT=$(psql -qtc \
    "SELECT count(table_name) FROM information_schema.tables \
     WHERE table_schema = 'public';" ${PSQLUSRDB})
  [[ $? -gt 0 ]]  &&   return ${UNEXPECTED_DATA}
  [[ ${TABLE_COUNT} -lt 1 ]]  &&  DATABASE_EMPTY="yes"
  echo "Database ${PSQLUSRDB} has ${TABLE_COUNT} tables."

}
export -f database_empty
#
#
function restore_archive()
{
  echo "Restoring archive \"${DATABASE_ARCHIVE}\" if possible."
  DBOID=$(psql -qtc "SELECT oid FROM pg_database WHERE datname = '${PSQLUSRDB}';")
  if [[ "XX" == "X${DBOID}X" ]]
  then
    echo "Creating DB \"${PSQLUSRDB}\" in ${PSQLUSRTBSP} [$(whoami)]"
    psql -qtc "CREATE DATABASE ${PSQLUSRDB} TABLESPACE ${PSQLUSRTBSP};"
    echo "Passing \"${PSQLUSRDB}\" to user ${PSQLUSR}"
    psql -qtc "ALTER DATABASE ${PSQLUSRDB} OWNER TO ${PSQLUSR};"
  fi
  #
  if [[ -f ${DATABASE_ARCHIVE} ]]
  then
    gunzip -c ${DATABASE_ARCHIVE} | psql ${PSQLUSRDB} > /tmp/restore.log
    RSLT=$?
    [[ ${RSLT} -gt 0 ]]  &&   return ${UNEXPECTED_DATA}
    echo  "No errors reported by restore process."
  else
    echo "No such archive file"
    return ${UNEXPECTED_DATA}
  fi
}
export -f restore_archive
#
#
function create_user()
{
  USR=${1}
  #
  echo "Preparing access for : ${USR}"
  #
  if [[  6 -gt $(grep -o "${USR}" /etc/postgresql/9.3/main/pg_hba.conf | wc -l) ]]
  then
    echo "Appending to pg_hba.conf"
    cat << EOF >> /etc/postgresql/9.3/main/pg_hba.conf
local   ${USR}          ${USR}                             md5
local   ${USR}          ${USR}                             peer
local   ${PSQLUSRDB}            ${USR}                            md5
local   ${PSQLUSRDB}            ${USR}                             peer
EOF
    #
  else
    echo "Expected pg_hba.conf settings seem to have been made already."
  fi
  #
  if [[ $(psql ${USR} -c "" >/dev/null 2>&1 ; echo $?) -gt 0 ]]
  then
    echo "Give PostgreSQL user ${USR} a personal database."
    psql -c "CREATE DATABASE ${USR};"
  else
    echo "Found ${USR} database exists already."
  fi
  #
  if [[ 1 -gt $(psql -c "\du" | grep -c ${USR} )  ]]
  then
    echo "Create user ${USR}."
    psql -c "CREATE USER ${USR} WITH CREATEDB ENCRYPTED PASSWORD '${PSQLUSRPWD}';"
  else
    echo "User ${USR} already present."
  fi
  #
}
export -f create_user
#
#
function user_exists()
{
  echo "Check for user \"${1}\""
  USER_COUNT=$(psql -qtc \
    "SELECT count(rolname) FROM pg_roles \
     WHERE rolname = '${1}';")
  [[ $? -gt 0 ]]  &&   return ${UNEXPECTED_DATA}
  [[ ${USER_COUNT} -eq 1 ]]  &&  USER_EXISTS="yes"
  echo "USER ${1} known? ${USER_EXISTS}"
}
export -f user_exists
#
#
function detect_fs_tablespace()
{
  echo "Detecting FS tablespace : ${TABLESPACE_DIRECTORY}"
  #
  pushd ${TABLESPACE_DIRECTORY} > /dev/null 2>&1
  if [[ $? -eq 0  ]]
  then
    TABLESPACE_DATABASES=(*)
    popd > /dev/null
    TABLESPACE_DATABASES_COUNT=${#TABLESPACE_DATABASES[@]}
  else
    TABLESPACE_DATABASES_COUNT=0
  fi
  #
  # echo "Count is  - - ${TABLESPACE_DATABASES_COUNT}"
  #
  if [[ ${TABLESPACE_DATABASES_COUNT} -lt 1  ]]
  then
    echo "No such tablespace on device."
  elif [[ ${TABLESPACE_DATABASES_COUNT} -gt 1  ]]
  then
    echo "Detected ${TABLESPACE_DATABASES_COUNT} tablespaces. Fail."
    return ${UNEXPECTED_DATA}
  else
    TABLESPACE_DETECTED="yes"
    echo "Detected one tablespace"
  fi
}
export -f detect_fs_tablespace
#
function detect_pg_tablespace()
{
  TBL_SPC_CNT=$( \
    psql -qtc \
    "SELECT COUNT(oid) FROM pg_catalog.pg_tablespace \
    WHERE spcname='${PSQLUSRTBSP}';" | tr -d ' ')
  echo "Count of tablespaces named \"${PSQLUSRTBSP}\": ${TBL_SPC_CNT}"
  if [[  ${TBL_SPC_CNT} -eq 1  ]]
  then
    TBL_SPC_CNT=$( \
      psql -qtc \
      "SELECT COUNT(oid) \
       FROM pg_catalog.pg_tablespace \
      WHERE spcname='${PSQLUSRTBSP}' \
        AND pg_tablespace_location(oid) = '${DATA_DIRECTORY_PATH}' \
       ;" | tr -d ' ')
    echo "Count of tablespaces named \"${PSQLUSRTBSP}\" pointing to \"${DATA_DIRECTORY_PATH}\": ${TBL_SPC_CNT}"
    [[  ${TBL_SPC_CNT} -ne 1  ]] &&  return ${UNEXPECTED_DATA}
    TABLESPACE_RECOGNIZED="yes"
  fi
}
export -f detect_pg_tablespace
#
#
function detect_pg_tablespace_location()
{
  TBL_SPC=$( \
    psql -qtc \
    "SELECT oid \
     FROM pg_catalog.pg_tablespace \
    WHERE spcname='${PSQLUSRTBSP}' \
      AND pg_tablespace_location(oid) = '${1}' \
     ;" | tr -d ' ')
}
export -f detect_pg_tablespace_location
#
#
function detect_pg_database()
{
  echo "Detecting PG database : \"${PSQLUSRDB}\""
  DBOID=$(psql -qtc \
    "SELECT oid FROM pg_database \
     WHERE datname = '${PSQLUSRDB}';" \
    | tr -d ' ')
  echo " ?? ${DBOID} "
  [[ ! "XX" == "X${DBOID}X" ]]  &&  DATABASE_DETECTED="yes"
}
export -f detect_pg_database
#
#
function database_status()
{
  declare TABLESPACE_RECOGNIZED="no"
  declare DATABASE_DETECTED="no"
  declare USER_EXISTS="no"
  #
  declare DATABASE_ARCHIVE="/srv/${SITENAME}/postgres/backups/${PSQLUSRDB}.gz"
  declare DATA_DIRECTORY_PATH="/srv/${SITENAME}/postgres/data"
  declare TABLESPACE_DIRECTORY="${DATA_DIRECTORY_PATH}/PG_*/"
  #
  echo "Investigate tablespace and database. ${SITENAME}"
  detect_pg_database
  #
  if [[  ${DATABASE_DETECTED} == "yes"  ]]
  then
    echo "Postgres has database \"${PSQLUSRDB}\"?   YES.  Does postgres recognize tablespace \"${PSQLUSRTBSP}\"?"
    detect_pg_tablespace
    if [[  ${TABLESPACE_RECOGNIZED} == "yes"  ]]
    then
      detect_pg_spc_database ; RSLT=$?
      [[ ${RSLT} == ${UNEXPECTED_DATA} ]] && return ${UNEXPECTED_DATA}
      detect_fs_tablespace ; RSLT=$?
      if [[  ${TABLESPACE_DETECTED} == "yes"  ]]
      then
        echo "Expected tablespace found."
        database_empty
        if [[  ${DATABASE_EMPTY} == "yes"  ]]
        then
          echo "Database is empty.  Users exist?"
          user_exists ${PSQLUSR}
          if [[  ${USER_EXISTS} == "no"  ]]
          then
            echo "Required user \"${PSQLUSR}\" not found.  Create."
            exit
          fi
          echo "Have database owner.  Restore from archive?"
          if [[ -f ${DATABASE_ARCHIVE} ]]
          then
            restore_archive
          fi
        else
          echo "Database is NOT empty.  Assume it is an Odoo database.  Do nothing?"
          return ${DO_NOTHING}
        fi
      else
        echo "Expected tablespace path missing.  Quitting . . "
        return ${UNEXPECTED_DATA}
      fi
      exit
    else
      echo "Found database \"${PSQLUSRDB}\", but not in tablespace \"${PSQLUSRTBSP}\".    Quitting . . . "
      exit
    fi
    return ${DO_NOTHING}
    #
  else
    echo "Postgres has database \"${PSQLUSRDB}\"?   No.  Does postgres recognize tablespace \"${PSQLUSRTBSP}\"?"
    detect_pg_tablespace
    if [[  ${TABLESPACE_RECOGNIZED} == "yes"  ]]
    then
      echo "Postgres has tablespace."
      detect_fs_tablespace
      [[ $? == ${UNEXPECTED_DATA} ]] && return ${UNEXPECTED_DATA}
      if [[ ! ${TABLESPACE_DETECTED} == "yes"  ]]
      then
        echo ". . . but filesystem tablespace is missing.   Dropping Postgres tablespace"
        drop_pg_tablespace
        echo "Tablespace dropped.  Creating new tablespace"
        create_tablespace
      fi
    else
      echo "Filesystem tablespace \"${PSQLUSRTBSP}\" exists as \"${TABLESPACE_DIRECTORY}\", but Postgres does not have it.  Deleting and recreating."
      # echo "  * * * THIS WAS COMMENTED OUT WHY? * * * "
      drop_fs_tablespace
      echo "Postgres has no such tablespace. Creating new tablespace ${PSQLUSRDB}."
      create_tablespace
    fi
    #
    echo "Got a filesystem tablespace. Users exist?"
    user_exists ${PSQLUSR}
    if [[  ${USER_EXISTS} == "no"  ]]
    then
      echo "Required user \"${PSQLUSR}\" not found.  Create."
      create_user  ${PSQLUSR}
    fi
    echo "Have database owner.  Restore from archive ${DATABASE_ARCHIVE}?"
    if [[ -f ${DATABASE_ARCHIVE} ]]
    then
      echo "restoring."
      restore_archive
    else
      echo "no."
    fi
  fi
  #
}
pushd /tmp
export -f database_status
#

echo "Preparing database."
su postgres -c "database_status"
echo "Database prepared."
popd
