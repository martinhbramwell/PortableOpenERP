#!/bin/bash
#
if [[  -z "${OERPUSR_WORK}"  ||  -z "${OERPUSR}"  ]]
then
#
echo "Usage :  ./ipoerpUpdateOpenErpSourceCode.sh"
echo "With required variables :"
echo " - OERPUSR_WORK : ${OERPUSR_WORK}"
echo " - OERPUSR : ${OERPUSR}"
exit
fi
#
echo "Stepping into ${OERPUSR_WORK}"
cd ${OERPUSR_WORK}
#
echo "Preparing Openerp \"server\" directory"
whoami
pwd
ls -la server
ls -la server/venv
cp -R source/openobject-server/* server
#
pushd server
echo "Preparing Openerp \"server/addons\" directory"
cp -R ../source/openobject-addons openerp/tmpX
mv openerp/addons/* openerp/tmpX
rm -fr openerp/addons
mv openerp/tmpX openerp/addons
echo "Preparing Openerp \"server/addons/web\" directory"
cp -R ../source/openerp-web/addons/* openerp/addons/
#
popd
echo "Stepped out to $(pwd)"
echo "Setting permissions"
ls -la .
whoami
chown -R openerp:${OERPUSR} server
chmod -R g+w server
ls -l server
#



