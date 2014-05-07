#!/bin/bash
#
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
export IREDMAIL="https://bitbucket.org/zhb/iredmail/downloads/iRedMail-0.8.6.tar.bz2"
echo "Obtaining iRedMail installers from ${IREDMAIL}"

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
