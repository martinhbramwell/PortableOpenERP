#!/bin/bash
#
if [[  -z ${PSQLUSR} || -z ${PSQLUSR_HOME}  || -z ${OERPUSR}  || -z ${OERPUSR_HOME}  || -z ${OERPUSR_WORK}  ]]
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
else
 echo "User ${PSQLUSR} already exists"
fi
#
chown -R postgres:${PSQLUSR} ${PSQLUSR_HOME}
find ${PSQLUSR_HOME} -type d -exec chmod 770 {} +
find ${PSQLUSR_HOME} -type f -exec chmod 660 {} +
#
mkdir -p /opt/openerp
[[  1 -gt $(getent passwd | grep -c "^openerp") ]] && useradd -d /opt/openerp openerp
touch /opt/openerp/.bzr.log
chown -R openerp:openerp /opt/openerp
#
if [[  1 -gt $(getent passwd | grep -c "^${OERPUSR}")  ]]
then
 useradd -d ${OERPUSR_HOME} ${OERPUSR}
 usermod -a -G openerp ${OERPUSR}
else
 echo "User ${OERPUSR} already exists"
fi
#
mkdir -p                       ${OERPUSR_WORK}/source/
chown       openerp:openerp    ${OERPUSR_WORK}
#
mkdir -p                       ${OERPUSR_WORK}/server
if [[ ! -f ${OERPUSR_WORK}/server/openerp/__init__.py  ]]
then
  rm   -fr                       ${OERPUSR_WORK}/server/*
else
  echo "Odoo executables seem to be present already."
fi
#
mkdir -p                       ${OERPUSR_WORK}/server/venv
if [[ ! -f ${OERPUSR_WORK}/server/venv/bin/activate  ]]
then
  rm   -fr                       ${OERPUSR_WORK}/server/venv/*
else
  echo "Virtual execution environment seems to be present already."
fi
#
echo "Correcting permissions on ${OERPUSR_WORK}/server"
chown -R    openerp:${OERPUSR} ${OERPUSR_WORK}/server
chmod -R                   g+w ${OERPUSR_WORK}/server
#
echo "Correcting ownership on ${OERPUSR_WORK}/log"
mkdir -p                       ${OERPUSR_WORK}/log
chown -R    openerp:${OERPUSR} ${OERPUSR_WORK}/log
#
echo "Correcting ownership on ${OERPUSR_HOME}/.local"
mkdir -p                       ${OERPUSR_HOME}/.local
chown -R ${OERPUSR}:${OERPUSR} ${OERPUSR_HOME}
#
echo "Correcting permissions on /srv/${SITENAME}"
chmod 755 /srv/${SITENAME}


