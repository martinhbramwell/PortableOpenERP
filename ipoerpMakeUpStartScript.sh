#!/bin/bash
#
if [[ -z ${SITENAME} || -z ${PSQLUSR} || -z ${OERPUSR} || -z ${ACCESS_PORT} || -z ${OERPUSR_WORK} ]]
then
#
echo "Usage :  ./ipoerpMakeUpStartScript.sh  "
echo "With required variables :"
echo " -     SITENAME : ${SITENAME}"
echo " -      OERPUSR : ${OERPUSR}"
echo " -      PSQLUSR : ${PSQLUSR}"
echo " -  ACCESS_PORT : ${ACCESS_PORT}"
echo " - OERPUSR_WORK : ${OERPUSR_WORK}"
exit 0
#
fi
#
export SCRIPTFILE="UpStart.sh"
export SCRIPTNAME="odoo-${SITENAME}"
rm -f ${OERPUSR_WORK}/${SCRIPTFILE}
echo "Creating ${OERPUSR_WORK}/${SCRIPTFILE}"
cat <<WRITTEN> ${OERPUSR_WORK}/${SCRIPTFILE}
# Upstart script for this Odoo application
#
export SITE_USER=${OERPUSR}
export ODOO_BASE=${OERPUSR_WORK}
export UPSTART_JOB=${SCRIPTNAME}
#
export ODOO_EXEC=openerp-server
export ODOO_CONF=openerp-server.conf
#
export ODOO_HOME=\${ODOO_BASE}/server
#
echo "[\$(date --rfc-3339=seconds)] \$(whoami) starting \${ODOO_HOME}/\${ODOO_EXEC} -c \${ODOO_BASE}/\${ODOO_CONF}" >> /var/log/upstart/\${UPSTART_JOB}.log
exec su \${SITE_USER} -s /bin/sh -c '\${ODOO_HOME}/\${ODOO_EXEC} -c \${ODOO_BASE}/\${ODOO_CONF}'
WRITTEN
echo "Fixing permission on ${OERPUSR_WORK}/${SCRIPTFILE}"
chmod 755 ${OERPUSR_WORK}/${SCRIPTFILE}


cat <<UPSTART> /etc/init/${SCRIPTNAME}.conf
respawn
respawn limit 1 5

start on runlevel [2345]
stop on runlevel [!2345]

env EXEC_PATH="${OERPUSR_WORK}/${SCRIPTFILE}"

exec su -s /bin/bash -c \${EXEC_PATH}
UPSTART

#
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
#
patch -u /etc/default/iptables /etc/default/iptables.patch
#
cat /etc/default/iptables
#
echo "Trying upstart : ${SCRIPTNAME}"
stop ${SCRIPTNAME}
start ${SCRIPTNAME}
#
service iptables restart
ifdown eth0 && ifup eth0
