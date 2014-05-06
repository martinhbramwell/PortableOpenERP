#!/bin/bash
#
DEFDIR=${0%/*}  #  Default directory of caller; maintains script portability.
#
if [[ -z $OERPUSR_HOME  ]]
then
#
echo "Usage :  ./ipoerpPipInstallToVEnv.sh"
echo "With required variables :"
echo " - OERPUSR_HOME : $OERPUSR_HOME"
exit 0
#
fi
#
if [[  1 -eq 1  ]]
then
#
VENV_PATH=$OERPUSR_HOME/server
pushd $VENV_PATH
pwd
if [[  -d  "$VENV_PATH/venv" ]]
then
echo "Found pre-existing virtual environment under $VENV_PATH"
else
virtualenv venv --system-site-packages
echo "Put venv in $VENV_PATH"
fi
#
export VIRTUAL_ENV="$VENV_PATH/venv"
export PATH="$VIRTUAL_ENV/bin:$PATH"
unset PYTHON_HOME
echo "Using pip from $(which pip)"
#
#
pip install Babel
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
popd
#
else
#
echo "Virtualenv installations disabled."
#
#
fi


