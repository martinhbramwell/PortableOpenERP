#!/bin/bash
#
rm -f /etc/init.d/oerp-site_z
echo "Creating /etc/init.d/oerp-site_z"
cat <<WRITTEN> /etc/init.d/oerp-site_z
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

# The name given to this site
SITE_NAME=z

# The derived name for this upstart script
NAME=oerp-site_\${SITE_NAME}

# The derived description upstart will use for this process
DESC=server_openerp_\${SITE_NAME}

# The derived location user name under which this site will execute
USER=oerp_user_\${SITE_NAME}

# The derived name for this site's location
SITE_DIR_NAME=site_\${SITE_NAME}

# The derived location for this site's configuration files
CONFIGFILE=/srv/\${SITE_DIR_NAME}/openerp-server.conf

# The derived location for this site's installation files
BASE_DIR=/srv/\${SITE_DIR_NAME}/openerp

# The derived location for this site's executables
DAEMON=\${BASE_DIR}/server/openerp-server

# The name of the active database for this site
DB_NAME=site_\${SITE_NAME}_db

# Additional options that are passed to the Daemon.
DAEMON_OPTS="-c \$CONFIGFILE --db-filter=\$DB_NAME"
# DAEMON_OPTS="-c \$CONFIGFILE"

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
                N=/etc/init.d/\${NAME}
                echo "Usage: \${NAME} {start|stop|restart|force-reload}" >&2
                exit 1
                ;;
esac

exit 0
WRITTEN
chmod 700 /etc/init.d/oerp-site_z
#
echo "Opening port for http access"
VAR=$(expect -c '
  spawn ufw enable
  expect "Command may disrupt existing ssh connections. Proceed with operation (y|n)?"
  send "y\n"
  expect eof
')
#
echo $VAR
#
ufw allow 8019
#
exit 0
