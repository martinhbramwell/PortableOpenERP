#!/bin/bash
#
if [[ -z $PSQLUSR || -z $PSQLUSR_HOME  || -z $OERPUSR  || -z $OERPUSR_HOME  ]]
then
#
echo "Usage :  ./ipoerpPrepareUsersAndDirectories.sh  "
echo "With required variables :"
echo " - PSQLUSR : $PSQLUSR"
echo " - PSQLUSR_HOME : $PSQLUSR_HOME"
echo " - OERPUSR : $OERPUSR"
echo " - OERPUSR_HOME : $OERPUSR_HOME"
exit 0
#
fi
#
mkdir -p $PSQLUSR_HOME/data
mkdir -p $PSQLUSR_HOME/backups
touch $PSQLUSR_HOME/.psql_history
#
if [[  1 -gt $(getent passwd | grep -c $PSQLUSR)  ]]
then
useradd -d $PSQLUSR_HOME $PSQLUSR
usermod -a -G postgres $PSQLUSR
fi
#
chown -R postgres:$PSQLUSR $PSQLUSR_HOME
chmod -R 770 $PSQLUSR_HOME
#
[[  1 -gt $(getent passwd | grep -c $OERPUSR) ]] && useradd -d $OERPUSR_HOME $OERPUSR
#
mkdir -p $OERPUSR_HOME/source/
mkdir -p $OERPUSR_HOME/server/
mkdir -p $OERPUSR_HOME/log
mkdir -p $OERPUSR_HOME/.local
touch $OERPUSR_HOME/.bzr.log
chown -R oerp_user_z:oerp_user_z $OERPUSR_HOME/source
chown -R oerp_user_z:oerp_user_z $OERPUSR_HOME/server
chown -R oerp_user_z:oerp_user_z $OERPUSR_HOME/log
chown -R oerp_user_z:oerp_user_z $OERPUSR_HOME/.bzr.log
chown -R oerp_user_z:oerp_user_z $OERPUSR_HOME/.local


