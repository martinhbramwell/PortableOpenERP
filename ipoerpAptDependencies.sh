#!/bin/bash
#
apt-get -y install python ghostscript graphviz libfreetype6-dev python-pdftools
apt-get -y install libldap2-dev libjpeg-dev libsasl2-dev libpq-dev libxml2 git curl
apt-get -y install libxslt1-dev libxml2-dev lptools poppler-utils python-pip expect
apt-get -y install postgresql-client python-dateutil bzr gcc make mc python-dev wget
apt-get -y install python-imaging python-pychart python-libxslt1 python-matplotlib
apt-get -y install antiword python-reportlab-accel python-zsi zlib1g-dev zip libffi-dev
#
mkdir -p ~/tmpxxxxxtmp
pushd ~/tmpxxxxxtmp
#
curl -O http://python-distribute.org/distribute_setup.py
python distribute_setup.py
easy_install pip
#
pip install virtualenv
pip install virtualenvwrapper
#
popd
rm -fr tmpxxxxxtmp


