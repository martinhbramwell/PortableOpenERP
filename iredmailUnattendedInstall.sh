#!/usr/bin/expect
set IREDINSTALLERS [lrange $argv 0 0]
puts "${IREDINSTALLERS}/iRedMail"
#
set timeout 600
spawn ${IREDINSTALLERS}/iRedMail.sh
match_max 100000
expect "*?se it for mail server setting*"
send -- "y\r"
expect "*iptables, with SSHD port*"
send -- "y\r"
expect "*?estart firewall now*"
send -- "y\r"
send -- "\r"
expect eof
exit

