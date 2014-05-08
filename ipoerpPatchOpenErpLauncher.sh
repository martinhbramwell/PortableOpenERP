#!/bin/bash
#
if [[  -z "$OERPUSR_HOME"  ]]
then
echo "Usage :  ./ipoerpPatchOpenErpLauncher.sh"
echo "With required variables :"
echo " - OERPUSR_HOME : $OERPUSR_HOME"
exit
fi
#
echo "Stepping into $OERPUSR_HOME"
cd $OERPUSR_HOME/server
#
sed -i.bak "s|env python|env $OERPUSR_HOME/server/venv/bin/python|g" openerp-server
#

