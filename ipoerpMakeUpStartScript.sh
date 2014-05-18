#!/bin/bash
#
if [[ -z ${SITENAME} || -z ${POSTGRESUSR} || -z ${OPENERPUSR} || -z ${PSQLUSR} || -z ${OERPUSR} || -z ${ACCESS_PORT} || -z ${OERPUSR_WORK} ]]
then
#
echo "Usage :  ./ipoerpMakeUpStartScript.sh  "
echo "With required variables :"
echo " -     SITENAME : ${SITENAME}"
echo " - POSTGRESUSR  : ${POSTGRESUSR}"
echo " -  OPENERPUSR  : ${OPENERPUSR}"
echo " -      OERPUSR : ${OERPUSR}"
echo " -      PSQLUSR : ${PSQLUSR}"
echo " -  ACCESS_PORT : ${ACCESS_PORT}"
echo " - OERPUSR_WORK : ${OERPUSR_WORK}"
exit 0
#
fi
#
export SCRIPTNAME="odoo-${SITENAME}"
#
#
export SCRIPTFILE="UpStart.sh"
export SCRIPTFILEVARS="UpStartVars.sh"
echo "Creating ${OERPUSR_WORK}/${SCRIPTFILE}"
rm -f ${OERPUSR_WORK}/${SCRIPTFILE}
# .  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
cat <<UPSTARTSCR> ${OERPUSR_WORK}/${SCRIPTFILE}
# Upstart script for this Odoo application
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
source \${DEFDIR}/${SCRIPTFILEVARS}.sh
#
echo "[\$(date --rfc-3339=seconds)] \$(whoami) starting \${ODOO_HOME}/\${ODOO_EXEC} -c \${ODOO_BASE}/\${ODOO_CONF}" >> /var/log/upstart/\${UPSTART_JOB}.log
exec su \${SITE_USER} -s /bin/sh -c '\${ODOO_HOME}/\${ODOO_EXEC} -c \${ODOO_BASE}/\${ODOO_CONF}'
#
UPSTARTSCR
# :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :
#
#
echo "Creating ${OERPUSR_WORK}/${SCRIPTFILEVARS}"
rm -f ${OERPUSR_WORK}/${SCRIPTFILEVARS}
# .  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
cat <<UPSTARTSCRVARS> ${OERPUSR_WORK}/${SCRIPTFILEVARS}
# Variables required by Upstart script and for remounting site in a new machine
#
export SITE_USER=${OERPUSR}
export SITE_NAME=${SITENAME}
export ODOO_BASE=${OERPUSR_WORK}
export UPSTART_JOB=${SCRIPTNAME}
#
export ODOO_EXEC=openerp-server
export ODOO_CONF=openerp-server.conf
#
export ODOO_HOME=\${ODOO_BASE}/server
#
#  Not needed here but required when moving this site to a new machine.
declare -A GROUP_IDS=(
[$(getent passwd ${POSTGRESUSR} | cut -f 4 -d:)]=${POSTGRESUSR}
[$(getent passwd ${OPENERPUSR} | cut -f 4 -d:)]=${OPENERPUSR}
[$(getent passwd ${PSQLUSR} | cut -f 4 -d:)]=${PSQLUSR}
[$(getent passwd ${OERPUSR} | cut -f 4 -d:)]=${OERPUSR}
)

declare -A USERS_IDS=(
[$(getent passwd ${POSTGRESUSR} | cut -f 3 -d:)]=${POSTGRESUSR}
[$(getent passwd ${OPENERPUSR} | cut -f 3 -d:)]=${OPENERPUSR}
[$(getent passwd ${PSQLUSR} | cut -f 3 -d:)]=${PSQLUSR}
[$(getent passwd ${OERPUSR} | cut -f 3 -d:)]=${OERPUSR}
)
#
UPSTARTSCRVARS
# :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :
echo "Fixing permissions on ${OERPUSR_WORK}/${SCRIPTFILE} and ${OERPUSR_WORK}/${SCRIPTFILEVARS}"
chmod 755 ${OERPUSR_WORK}/${SCRIPTFILE}
chmod 755 ${OERPUSR_WORK}/${SCRIPTFILEVARS}
#
#
#
echo "Creating /etc/init/${SCRIPTNAME}.conf"
rm -f /etc/init/${SCRIPTNAME}.conf
# .  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
cat <<UPSTART> /etc/init/${SCRIPTNAME}.conf
respawn
respawn limit 1 5

start on runlevel [2345]
stop on runlevel [!2345]

env EXEC_PATH="${OERPUSR_WORK}/${SCRIPTFILE}"

exec su -s /bin/bash -c \${EXEC_PATH}
UPSTART
# :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :
#
echo "Creating /etc/default/iptables.patch"
rm -f /etc/default/iptables.patch
# .  .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .
cat <<PATCHEOF> /etc/default/iptables.patch
--- /etc/default/iptables       2014-05-09 13:29:26.779041999 -0400
+++ /etc/default/iX     2014-05-09 13:09:42.635041999 -0400
@@ -35,6 +35,9 @@
 # Loop device.
 -A INPUT -i lo -j ACCEPT

+# OpenERP XMLRPC
+-A INPUT -p tcp -m tcp --dport ${ACCESS_PORT} -j ACCEPT
+
 # http, https
 -A INPUT -p tcp --dport 80 -j ACCEPT
 -A INPUT -p tcp --dport 443 -j ACCEPT

PATCHEOF
# :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :  :
#
patch -u /etc/default/iptables /etc/default/iptables.patch
rm -f /etc/default/iptables.patch
#
cat /etc/default/iptables
#
echo "Trying upstart : ${SCRIPTNAME}"
stop ${SCRIPTNAME}
start ${SCRIPTNAME}
#
service iptables restart
ifdown eth0 && ifup eth0
