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
export SCRIPTNAME="oerp-${SITENAME}"
rm -f ${OERPUSR_WORK}/${SCRIPTFILE}
echo "Creating ${OERPUSR_WORK}/${SCRIPTFILE}"
cat <<WRITTEN> ${OERPUSR_WORK}/${SCRIPTFILE}
#!/bin/bash

### BEGIN INIT INFO
# Provides:             openerp-server
# Required-Start:       \$remote_fs \$syslog
# Required-Stop:        \$remote_fs \$syslog
# Should-Start:         \$network
# Should-Stop:          \$network
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    Enterprise Resource Management software
# Description:          Open ERP is a complete ERP and CRM software.
### END INIT INFO

PATH=/bin:/sbin:/usr/bin

# The derived name for this upstart script
NAME=${SCRIPTNAME}

# The derived user's names under which this site will execute
USER=${OERPUSR}
PSQLUSER=${PSQLUSR}

# The derived name for this site's location
SITE_DIR_NAME=${SITENAME}
#

# The derived description upstart will use for this process
DESC=server_openerp_\${SITE_NAME}

# The derived location for this site's installation files
BASE_DIR=/srv/\${SITE_DIR_NAME}/openerp

# The derived location for this site's configuration files
CONFIGFILE=\${BASE_DIR}/openerp-server.conf

# The derived location for this site's executables
DAEMON=\${BASE_DIR}/server/openerp-server

# The name of the active database for this site
DB_NAME=\${SITE_DIR_NAME}_db

# Additional options that are passed to the Daemon.
# DAEMON_OPTS="-c \$CONFIGFILE --db-filter=\$DB_NAME"
DAEMON_OPTS="-c \$CONFIGFILE"

# Linux process identifier file name (pidfile)
PIDFILE=/var/run/\$NAME.pid

[ -x \$DAEMON ] || exit 0
[ -f \$CONFIGFILE ] || exit 0

checkpid() {
    [ -f \$PIDFILE ] || return 1
    pid=\`cat \$PIDFILE\`
    [ -d /proc/\$pid ] && return 0
    return 1
}

BACKGROUND=" --background"
# BACKGROUND=""

case "\${1}" in
        start)
                echo -n "Starting \${DESC}: "

                start-stop-daemon --start --quiet --pidfile \${PIDFILE} \\
                        --chuid \${USER} \${BACKGROUND} --make-pidfile \\
                        --exec \${DAEMON} -- \${DAEMON_OPTS}

                echo "\${NAME}."
                ;;

        stop)
                echo -n "Stopping \${DESC}: "

                start-stop-daemon --stop --quiet --pidfile \${PIDFILE} \\
                        --oknodo

                echo "\${NAME}."
                ;;

        restart|force-reload)
                echo -n "Restarting \${DESC}: "

                start-stop-daemon --stop --quiet --pidfile \${PIDFILE} \\
                        --oknodo

                sleep 1

                start-stop-daemon --start --quiet --pidfile \${PIDFILE} \\
                        --chuid \${USER} --background --make-pidfile \\
                        --exec \${DAEMON} -- \${DAEMON_OPTS}

                echo "\${NAME}."
                ;;

        *)
                N=${OERPUSR_WORK}/\${NAME}
                echo "Usage: \${NAME} {start|stop|restart|force-reload}" >&2
                exit 1
                ;;
esac

exit 0
WRITTEN
chmod 755 ${OERPUSR_WORK}/${SCRIPTFILE}
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
rm -f /etc/init.d/${SCRIPTNAME}
echo "ln -s ${OERPUSR_WORK}/${SCRIPTFILE} /etc/init.d/${SCRIPTNAME}"
ln -s ${OERPUSR_WORK}/${SCRIPTFILE} /etc/init.d/${SCRIPTNAME}
service ${SCRIPTNAME} restart
service iptables restart
ifdown eth0 && ifup eth0
