#!/bin/bash
#
if [[ -z ${UPSTART_JOB} || -z ${OERPUSR_WORK}  ]]
then
#
echo "Usage :  ./ipoerpMakeUpstartConf.sh  "
echo "With required variables :"
echo " -  UPSTART_JOB : ${UPSTART_JOB}"
echo " - OERPUSR_WORK : ${OERPUSR_WORK}"
exit 0
#
fi
#
export SCRIPTNAME="odoo-${SITENAME}"
export SCRIPTFILE="UpStart.sh"
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
