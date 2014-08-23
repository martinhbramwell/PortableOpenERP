#!/bin/bash
#
# if [[ -z ${OOO}  ||  -z ${OERPUSR_WORK}  ||  -z ${OERPUSR_HOME}  || -z ${PSQLUSR} || -z ${PSQLUSRPWD}  || -z ${ACCESS_PORT}  ]]
if [[                  -z ${OERPUSR_WORK}  ||  -z ${OERPUSR_HOME}  || -z ${PSQLUSR} || -z ${PSQLUSRPWD}  || -z ${ACCESS_PORT}  ]]
then
#
echo "Usage :  ./ipoerpMakeOerpServerConfigFile.sh"
echo "With required variables :"
echo " - OERPUSR_HOME : ${OERPUSR_HOME}"
echo " - PSQLUSR : ${PSQLUSR}"
echo " - PSQLUSRPWD : ${PSQLUSRPWD}"
echo " - ACCESS_PORT : ${ACCESS_PORT}"
echo " - OERPUSR_WORK : ${OERPUSR_WORK}"
exit 0
#
fi
#

cat <<WRITTEN > ${OERPUSR_WORK}/openerp-server.conf
[options]
; the host address at which connections must arrive
db_host = 127.0.0.1

; the port on which connections must arrive
xmlrpc_port = ${ACCESS_PORT}

; the password that allows database operations:
admin_passwd = ${PSQLUSRPWD}

; the port on which PostgreSQL awaits connections
db_port = 5432

; the PostgreSQL user and password authorized to access the database
db_user = ${PSQLUSR}
db_password = ${PSQLUSRPWD}

; where modules can be found
; addons_path = ${OERPUSR_WORK}/server/openerp/addons,${OERPUSR_WORK}/server/openerp/addons/web
addons_path = ${OERPUSR_WORK}/server/addons

; log settings
logfile = ${OERPUSR_WORK}/log/site_openerp.log
log_level = error

; special handling required for running behind a front-end server
proxy_mode = True
WRITTEN

