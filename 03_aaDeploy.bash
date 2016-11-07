#!/bin/bash
#
#  Copyright (c) 2016 Jeong Han Lee
#  Copyright (c) 2016 European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# Shell  : 03_aaDeploy.bash
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.9.3 CentOS 7.2
#
# 

# Example to execute this script as follows:
#
# [root@]# bash 03_aaDeploy.bash
# or
# [root@]# bash /home/aauser/gitsrc/epicsarchiverap-sites/03_aaDeploy.bash
# 
# Generic : Global vaiables - readonly
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"


# Generic : Redefine pushd and popd to reduce their output messages
# 
function pushd() { builtin pushd "$@" > /dev/null; }
function popd()  { builtin popd  "$@" > /dev/null; }

. ${SC_TOP}/setEnvAA.bash

declare -g WARSRC_DIR=${SC_TOP};

# For not CentOS users
# One should check that jar and java should be in PATH
#
function deploy_war_release() {

    local target=${1}
    local deploy_dir=${2}
    local warsrc_dir=${3}
    printf "%s %18s is deploying...\n" "-->" "new ${target} war"
    pushd ${deploy_dir}/${target}/webapps && rm -rf ${target}*;
    cp ${warsrc_dir}/${target}.war .;
    mkdir ${target}; cd ${target};
    jar xf ../${target}.war; 
    popd; 
}



if [[ ! -f ${WARSRC_DIR}/mgmt.war ]]
then
    printf "You need to call 01_aaBuild.bash and 02_aaSetup.bash first.\n The folder ${WARSRC_DIR} does not seem to have a mgmt.war.\n"
    exit 1
fi


tomcat_services=("mgmt" "engine" "etl" "retrieval")

echo "Deploying a new release from ${WARSRC_DIR} onto ${ARCHAPPL_TOP}"

echo ""
echo "Replacing old war files with new war files"
for service in ${tomcat_services[@]}; do
    deploy_war_release ${service} "${ARCHAPPL_TOP}" "${WARSRC_DIR}";
done


# Post installation steps for changing look and feel etc.
SITE_SPECIFIC_DIR="${SC_TOP}/site_specific_content"

##
## Change template for web sites

if [[ -f ${SITE_SPECIFIC_DIR}/template_changes.html ]]
then
    echo ""
    echo "Modifying static contents for the site specific information"
    java -cp ${ARCHAPPL_TOP}/mgmt/webapps/mgmt/WEB-INF/classes \
	 org.epics.archiverappliance.mgmt.bpl.SyncStaticContentHeadersFooters \
	 ${SITE_SPECIFIC_DIR}/template_changes.html \
	 ${ARCHAPPL_TOP}/mgmt/webapps/mgmt/ui
    echo ""
fi

##
## Copy site specific images
if [[ -d ${SITE_SPECIFIC_DIR}/img ]]
then
    echo ""
    echo "Copying site specific images recursively from ${WARSRC_DIR} onto ${ARCHAPPL_TOP}";
    cp -R ${SITE_SPECIFIC_DIR}/img/* ${ARCHAPPL_TOP}/mgmt/webapps/mgmt/ui/comm/img/ ;
    echo ""
fi

##
## Copy site specific main.css file
if [[ -d ${SITE_SPECIFIC_DIR}/css ]]
then
    echo ""
    echo "Copying site specific CSS files from ${WARSRC_DIR} onto ${ARCHAPPL_TOP}";
    for service in ${tomcat_services[@]}; do
	printf "%s %26s is deploying...\n" "-->" "new main.css in ${service}"
	cp -R ${SITE_SPECIFIC_DIR}/css/main.css ${ARCHAPPL_TOP}/${service}/webapps/${service}/ui/comm/css/ ;
    done
    echo ""
   
fi

echo "Done deploying a new release from ${WARSRC_DIR} onto ${ARCHAPPL_TOP}"
