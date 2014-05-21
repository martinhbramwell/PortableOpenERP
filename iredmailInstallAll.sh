#!/bin/bash
#
if [[  $(ps aux | grep -c vmail) -lt 1 ]]
then
    echo "Assuming iRedMail is not installed.  Installing . . . "
    #
    if [[ -z ${PSQLUSRPWD} || -z ${NEWHOSTDOMAIN} || -z ${IREDMAILPKG} || -z ${INSTALLERS}  ]]
    then
        #
        echo "Usage :  ./iredmailInstallAll.sh"
        echo "With required variables :"
        echo " - PSQLUSRPWD : ${PSQLUSRPWD}"
        echo " - NEWHOSTDOMAIN : ${NEWNEWHOSTDOMAINHOSTDOMAIN}"
        echo " - INSTALLERS : ${INSTALLERS}"
        echo " - IREDMAILPKG : ${IREDMAILPKG}"
        # echo " -  : $"
        exit 0
        #
    fi
    #
    genpasswd() {
        local ii=$1
        [ "$ii" == "" ] && ii=16
        tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${ii} | xargs
    }
    #
    export IREDMAIL="https://bitbucket.org/zhb/iredmail/downloads"
    export IREDMAILTAR="${IREDMAILPKG}.tar.bz2"
    #
    echo "Entering ${INSTALLERS}"
    pushd ${INSTALLERS}
    if [[ ! -d ${IREDMAILPKG} ]]; then
        if [[ ! -f ${IREDMAILTAR} ]]; then
            echo "Obtaining iRedMail installers from ${IREDMAIL}/${IREDMAILTAR}"
            wget $IREDMAIL/${IREDMAILTAR}
        fi
        echo "untar"
        tar jxvf ${IREDMAILTAR}
    else
        echo "Have directory"
    fi
    rm -f iRedMail
    ln -s ${IREDMAILPKG} iRedMail
    #
    echo "Entering ${INSTALLERS}/iRedMail"
    pushd iRedMail
    #
    echo " Configure PostgreSQL to 9.3"
    sed -i.bak "s|export PGSQL_VERSION='9.1'|export PGSQL_VERSION='9.3'|g" conf/postgresql
    #
    export FIRST_USER_PASSWD_PLAIN=${PSQLUSRPWD}
    export FIRST_USER_PASSWD=${PSQLUSRPWD}
    #
    export DOMAIN_ADMIN_PASSWD_PLAIN=${PSQLUSRPWD}
    export DOMAIN_ADMIN_PASSWD=${PSQLUSRPWD}
    #
    export SITE_ADMIN_PASSWD=${PSQLUSRPWD}
    #
    #   Generate config file in iRedMail directory
    echo "Generating a config file in directory"
    pwd
    #
cat >./config <<CONFIGFILE
export VMAIL_USER_HOME_DIR='/var/vmail'
export STORAGE_BASE_DIR='/var/vmail'
export STORAGE_MAILBOX_DIR='/var/vmail/vmail1'
export SIEVE_DIR='/var/vmail/sieve'
export BACKUP_DIR='/var/vmail/backup'
export BACKUP_SCRIPT_OPENLDAP='/var/vmail/backup/backup_openldap.sh'
export BACKUP_SCRIPT_MYSQL='/var/vmail/backup/backup_mysql.sh'
export BACKUP_SCRIPT_PGSQL='/var/vmail/backup/backup_pgsql.sh'
export BACKEND_ORIG='PGSQL'
export BACKEND='PGSQL'
export VMAIL_DB_BIND_PASSWD='$(genpasswd)'
export VMAIL_DB_ADMIN_PASSWD='$(genpasswd)'
export LDAP_BINDPW='$(genpasswd)'
export LDAP_ADMIN_PW='$(genpasswd)'
export PGSQL_ROOT_PASSWD='${PSQLUSRPWD}'
export PGSQL_ROOT_USER='postgres'
export SQL_SERVER='127.0.0.1'
export SQL_SERVER_PORT='5432'
export FIRST_DOMAIN='${NEWHOSTDOMAIN}'
export DOMAIN_ADMIN_NAME='postmaster'
export SITE_ADMIN_NAME='postmaster@${NEWHOSTDOMAIN}'
export DOMAIN_ADMIN_PASSWD_PLAIN='${DOMAIN_ADMIN_PASSWD_PLAIN}'
export DOMAIN_ADMIN_PASSWD='${DOMAIN_ADMIN_PASSWD}'
export SITE_ADMIN_PASSWD='${SITE_ADMIN_PASSWD}'
export FIRST_USER='postmaster'
export FIRST_USER_PASSWD='${FIRST_USER_PASSWD}'
export FIRST_USER_PASSWD_PLAIN='${FIRST_USER_PASSWD_PLAIN}'
export ENABLE_DKIM='YES'
export USE_IREDADMIN='YES'
export USE_WEBMAIL='YES'
export USE_RCM='YES'
export REQUIRE_PHP='YES'
export USE_PHPPGADMIN='YES'
export USE_AWSTATS='YES'
export USE_FAIL2BAN='YES'
export AMAVISD_DB_PASSWD='$(genpasswd)'
export CLUEBRINGER_DB_PASSWD='$(genpasswd)'
export IREDADMIN_DB_PASSWD='$(genpasswd)'
export RCM_DB_PASSWD='$(genpasswd)'
#EOF
CONFIGFILE
    #
    echo "Make iRedMail installer executable."
    chmod a+x iRedMail.sh
    #
    $DEFDIR/iredmailUnattendedInstall.sh $(pwd)
    #
else
    echo "Assuming iRedMail is already installed.  Skipping . . . "
fi
#
