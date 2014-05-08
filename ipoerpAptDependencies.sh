#!/bin/bash
#
apt-get install aptitude
#
aptitude -y install python ghostscript graphviz libfreetype6-dev python-pdftools
aptitude -y install libldap2-dev libjpeg-dev libsasl2-dev libpq-dev libxml2 git curl
aptitude -y install libxslt1-dev libxml2-dev lptools poppler-utils python-pip expect
aptitude -y install postgresql-client python-dateutil bzr gcc make mc python-dev wget
aptitude -y install python-imaging python-pychart python-libxslt1 python-matplotlib
aptitude -y install antiword python-reportlab-accel python-zsi zlib1g-dev zip libffi-dev
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


