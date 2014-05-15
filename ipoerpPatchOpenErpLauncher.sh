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
if [[  ! -f "${OERPUSR_WORK}/server/venv/bin/python"  ]]
then
echo "No file  \"\" has been created."
exit
else
#
echo "Stepping into ${OERPUSR_WORK}"
cd ${OERPUSR_WORK}/server
sed -i.bak "s|env python|env ${OERPUSR_WORK}/server/venv/bin/python|g" openerp-server
#
fi
#

