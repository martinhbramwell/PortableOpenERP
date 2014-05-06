#!/bin/bash
#
# if [[ -z $HOSTNAME || -z $HOSTDOMAIN  || -z $PSQLUSRTBSP  || -z $PSQLUSRDB  || -z $PSQLUSR_HOME  ]]
if [[ -z ${NEWHOSTNAME} || -z ${NEWHOSTDOMAIN}  ]]
then
#
echo "Usage :  ./iredmailInstallAll.sh"
echo "With required variables :"
echo " - NEWHOSTNAME : ${NEWHOSTNAME}"
echo " - NEWHOSTDOMAIN : ${NEWNEWHOSTDOMAINHOSTDOMAIN}"
# echo " -  : $"
exit 0
#
fi
#
export HOSTNAMEOK=$(grep -c "^${NEWHOSTNAME}$" hostname)
export DOMAINOK=$(grep -c "${NEWHOSTNAME}\.${NEWHOSTDOMAIN}" hosts)
if [[ ${HOSTNAMEOK} -lt 1 || ${DOMAINOK} -lt 1 ]]
then
echo "Changing hostname. . . "
cat <<DONE> /etc/hostname
${NEWHOSTNAME}
DONE
echo "Changing hostnames in hosts . . . "
#
sed -i.bak "s|127\.0\.1\.1.*|127.0.1.1      ${NEWHOSTNAME}.${NEWHOSTDOMAIN} ${NEWHOSTNAME}|g" /etc/hosts
echo "Restarting hostname service ..."
export RESULT=$(service hostname restart)
ifdown eth0 && ifup eth0
else
echo "Hostname and hosts already match"
fi
#
exit
#
rm -f /etc/init.d/oerp-site_z
echo "Overwriting /etc/hostname"
cat <<WRITTEN> /etc/init.d/oerp-site_z

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
