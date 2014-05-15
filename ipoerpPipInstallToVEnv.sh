#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
if [[ -z ${OERPUSR_WORK}  ]]
then
 #
 echo "Usage :  ./ipoerpPipInstallToVEnv.sh"
 echo "With required variables :"
 echo " - OERPUSR_WORK : ${OERPUSR_WORK}"
 exit 0
 #
fi
#
if [[  1 -eq 1  ]]
then
 #
 VENV_PATH=${OERPUSR_WORK}/server
 cd $VENV_PATH
 pwd
 if [[  -d  "$VENV_PATH/venv/bin" ]]
 then
  echo "Found pre-existing virtual environment under $VENV_PATH"
 else
  virtualenv venv --system-site-packages
  echo "Put venv in $VENV_PATH"
 fi
 #
 export VIRTUAL_ENV="${VENV_PATH}/venv";
 source ${VIRTUAL_ENV}/bin/activate
 export WHCH=$(which pip)
 if [[ !  "${WHCH}" == "${VIRTUAL_ENV}/bin/pip"  ]]
 then
   echo "Should be \"${VIRTUAL_ENV}/bin/pip\"."
   echo "Is        \"${WHCH}\"."
   exit
 else
   echo "Using pip from \"${WHCH}\"."
 fi
 #
 pip install Babel
 #
 pip install docutils
 pip install feedparser
 pip install jinja2
 # pip install matplotlib
 pip install mock
 pip install mako
 pip install paramiko
 # pip install pdftools
 pip install pillow
 pip install psutil
 pip install psycopg2
 pip install pydot
 pip install PyOpenSSL
 pip install pyparsing
 pip install python-ldap
 pip install python-openid
 pip install python-webdav
 pip install pytz
 pip install pyyaml
 pip install reportlab
 pip install setuptools
 pip install simplejson
 pip install unittest2
 pip install vobject
 pip install vatnumber
 pip install werkzeug
 pip install xlwt
 #
 pip install lxml
 #
else
 #
 echo "Virtualenv installations disabled."
 #
 #
fi


