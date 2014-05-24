#!/bin/bash
#
if [[  -z "${OERPUSR_WORK}"  ]]
then
echo "Usage :  ./ipoerpPatchOpenErpLauncher.sh"
echo "With required variables :"
echo " - OERPUSR_WORK : ${OERPUSR_WORK}"
exit
fi
#
declare VIRTUALPYTHON="${OERPUSR_WORK}/server/venv/bin/python"
if [[  ! -f "${VIRTUALPYTHON}"  ]]
then
echo "No file  \"${VIRTUALPYTHON}\" has been created."
exit
else
#
echo "Patching ${OERPUSR_WORK}/server/openerp-server with path to virtual python : ${VIRTUALPYTHON}"
pushd ${OERPUSR_WORK}/server
sed -i.bak "s|env python|env ${VIRTUALPYTHON}|g" openerp-server
popd
#
fi
#

