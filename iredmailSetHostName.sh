#!/bin/bash
#
if [[ -z ${NEWHOSTNAME} || -z ${NEWHOSTDOMAIN}  ]]
then
    #
    echo "Usage :  ./iredmailSetHostName.sh"
    echo "With required variables :"
    echo " - NEWHOSTNAME : ${NEWHOSTNAME}"
    echo " - NEWHOSTDOMAIN : ${NEWNEWHOSTDOMAINHOSTDOMAIN}"
    # echo " -  : $"
    exit 0
    #
fi
#
export HOSTNAMEOK=$(grep -c "^${NEWHOSTNAME}$" /etc/hostname)
export DOMAINOK=$(grep -c "${NEWHOSTNAME}\.${NEWHOSTDOMAIN}" /etc/hosts)
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
    service hostname restart 2> errout.txt  1> sout.txt
    export ERROUT=$(cat errout.txt)
    export SOUT=$(cat sout.txt)
    #
    if [ ! "${ERROUT}" == "stop: Unknown instance: " ]
    then
        printf "Unusual result restarting the hostname service:\n - Standard Error ... \"${ERROUT}\"\n"
        exit
    fi
    #
    if [ ! "${SOUT}" == "hostname stop/waiting" ]
    then
        printf "Unusual result restarting the hostname service:\n - Standard output ... \"${SOUT}\"\n"
        exit
    fi
    rm -f errout.txt
    rm -f sout.txt
    #
    echo "Restarting networking now."
    ifdown eth0 && ifup eth0
    printf "Hostname is now . . . "
    hostname -f
    #
else
    echo "Hostname and hosts already match"
fi

