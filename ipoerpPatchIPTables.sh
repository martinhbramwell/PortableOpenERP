#!/bin/bash
#
if [[ -z ${ACCESS_PORT} ]]
then
#
echo "Usage :  ./ipoerpMakeUpStartScript.sh  "
echo "With required variables :"
echo " -  ACCESS_PORT : ${ACCESS_PORT}"
exit 0
#
fi
#
export SCRIPTNAME="odoo-${SITENAME}"
#
declare ALREADYPATCHED=$(cat /etc/default/iptables | grep -c "\-A INPUT.*dport ${ACCESS_PORT}.*ACCEPT")
#
if [[ 0 -lt ${ALREADYPATCHED} ]]
then
  echo "Port for OpenERP is already set to beopened."
else
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
  echo "Patching /etc/default/iptables"
  patch -u /etc/default/iptables /etc/default/iptables.patch
  echo "Deleting patch."
  rm -f /etc/default/iptables.patch
  #
  # cat /etc/default/iptables
#
fi
#
echo "Trying upstart : ${SCRIPTNAME}"
stop ${SCRIPTNAME}
start ${SCRIPTNAME}
#
service iptables restart
ifdown eth0 && ifup eth0
