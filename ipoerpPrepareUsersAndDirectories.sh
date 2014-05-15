#!/bin/bash
#
if [[ -z ${PSQLUSR} || -z ${PSQLUSR_HOME}  || -z ${OERPUSR}  || -z ${OERPUSR_HOME}  || -z ${OERPUSR_WORK}  ]]
then
#
echo "Usage :  ./ipoerpPrepareUsersAndDirectories.sh  "
echo "With required variables :"
echo " - PSQLUSR : ${PSQLUSR}"
echo " - PSQLUSR_HOME : ${PSQLUSR_HOME}"
echo " - OERPUSR : ${OERPUSR}"
echo " - OERPUSR_WORK : ${OERPUSR_WORK}"
echo " - OERPUSR_HOME : ${OERPUSR_HOME}"
exit 0
#
fi
#
mkdir -p ${PSQLUSR_HOME}/data
mkdir -p ${PSQLUSR_HOME}/backups
touch ${PSQLUSR_HOME}/.psql_history
#
if [[  1 -gt $(getent passwd | grep -c "^${PSQLUSR}")  ]]
then
 useradd -d ${PSQLUSR_HOME} ${PSQLUSR}
 usermod -a -G postgres ${PSQLUSR}
fi
#
chown -R postgres:${PSQLUSR} ${PSQLUSR_HOME}
chmod -R 770 ${PSQLUSR_HOME}
#
mkdir -p /opt/openerp
touch /opt/openerp/.bzr.log
chown -R openerp:openerp /opt/openerp
[[  1 -gt $(getent passwd | grep -c "^openerp") ]] && useradd -d /opt/openerp openerp
#
if [[  1 -gt $(getent passwd | grep -c "^${OERPUSR}")  ]]
then
 useradd -d ${OERPUSR_HOME} ${OERPUSR}
 usermod -a -G openerp ${OERPUSR}
fi
#
mkdir -p                       ${OERPUSR_WORK}/source/
chown -R    openerp:openerp    ${OERPUSR_WORK}
#
mkdir -p                       ${OERPUSR_WORK}/server
rm   -fr                       ${OERPUSR_WORK}/server/*
mkdir -p                       ${OERPUSR_WORK}/server/venv
rm   -fr                       ${OERPUSR_WORK}/server/venv/*
chown -R    openerp:${OERPUSR} ${OERPUSR_WORK}/server
chmod -R                   g+w ${OERPUSR_WORK}/server
mkdir -p                       ${OERPUSR_WORK}/log
chown -R    openerp:${OERPUSR} ${OERPUSR_WORK}/log
#
mkdir -p                       ${OERPUSR_HOME}/.local
chown -R ${OERPUSR}:${OERPUSR} ${OERPUSR_HOME}


