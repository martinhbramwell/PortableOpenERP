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
if [  1 -eq 1  ]
then
	mkdir -p source
        echo "Stepping into ${OERPUSR_WORK}/source"
	pushd source
	if [ -d openobject-server ]
	then
                echo "Stepping into ${OERPUSR_WORK}/source/openobject-server"
		pushd openobject-server
		bzr update
		echo "Done server."
		popd
		echo "Stepped out to $(pwd)"
	else
		echo "Checking out lp:openobject-server"
		bzr checkout --lightweight lp:openobject-server
	fi
	#
	if [ -d openobject-addons ]
	then
		pushd openobject-addons
		bzr update
		echo "Done addons."
		popd
		echo "Stepped out to $(pwd)"
		#
	else
		echo "Checking out lp:openobject-addons"
		bzr checkout --lightweight lp:openobject-addons
	fi
	#
	if [ -d openerp-web ]
	then
		pushd openerp-web
		bzr update
		echo "Done web."
		popd
		echo "Stepped out to $(pwd)"
	else
		echo "Checking out lp:openerp-web"
		bzr checkout --lightweight lp:openerp-web
	fi
	#
	popd
	echo "Stepped out to $(pwd)"
fi
#
echo "Preparing Openerp \"server\" directory"
rm -fr server/*
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
# ls -l openerp/addons/base
# ls -l openerp/addons/web_api
# ls -l openerp/addons/website_mail
popd
echo "Stepped out to $(pwd)"
echo "Setting permissions"
chown -R openerp:${OERPUSR} server
#


