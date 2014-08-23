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
#
function fixSSHcredentials()
{
  pushd ~/.ssh/ > /dev/null
  if [[ -f id_rsa ]]
  then
    if [[ ! -f known_hosts ]]
    then
      touch known_hosts
    fi
    echo "Fixing SSH credentials for Git in directory :  $(pwd)."
    KEY1=$(cat known_hosts  | grep -c "xpLUXwqfqtfrT/4v+CH6WinAues")
    if [[ ${KEY1} -lt 1 ]]
    then
      echo "|1|xpLUXwqfqtfrT/4v+CH6WinAues=|MuZRTU4SWBp+gLKqh/Vb9nxo8tA= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="  | cat >> known_hosts
    fi
  else
    echo "You must place an id_rsa file at $(pwd)."
    exit
  fi
  popd > /dev/null
}
export -f fixSSHcredentials
#
cd ~
fixSSHcredentials
#
echo "Stepping into ${OERPUSR_WORK}"
cd ${OERPUSR_WORK}
#
if [  1 -eq 1  ]
then
	mkdir -p source
  echo "Stepping into ${OERPUSR_WORK}/source"
	pushd source  > /dev/null
	if [[ -d odoo/.git ]]
	then
	  pushd odoo  > /dev/null
    echo "Updating odoo"
	  git pull
	  popd > /dev/null
	else 
	  if [[ 1 == 0 ]]
	  then
      echo "Cloning from GitHub into $(pwd)."
      git clone git@github.com:odoo/odoo.git
    else
      echo "Faking cloning from local copy."
      cp -r /srv/odoo_source_backup ./odoo
    fi
  fi
	#
	popd > /dev/null
	# echo "Stepped out to $(pwd)"
fi
#

