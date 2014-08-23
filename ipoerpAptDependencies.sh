#!/bin/bash
#
aptProcess() {
    echo "Performing dependency collection"
    #
    #
    apt-get -y install aptitude
    #
    add-apt-repository -y ppa:ubuntu-clamav/ppa
    #
    apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade && apt-get -y clean && apt-get -y autoremove
    #
    aptitude -y install python ghostscript graphviz libfreetype6-dev python-pdftools tree \
        libldap2-dev libjpeg-dev libsasl2-dev libpq-dev libxml2 git curl \
        libxslt1-dev libxml2-dev lptools poppler-utils python-pip expect
    #
    aptitude -y install postgresql-client python-dateutil bzr gcc make mc python-dev wget \
        python-imaging python-pychart python-libxslt1 python-matplotlib xfsprogs \
        antiword python-reportlab-accel python-zsi python-decorator zlib1g-dev zip libffi-dev
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
    rm -fr ~/tmpxxxxxtmp
    touch /tmp/lastApt
}
#
if [[ -f /tmp/lastApt ]]
then
    if [[ $(find "/tmp/lastApt" -mmin +721) ]]
    then
        echo "Dependencies are stale."
        aptProcess
    else
        echo "Dependency collection completed already today."
    fi
else
    echo "Required dependencies not detected."
    aptProcess
fi

