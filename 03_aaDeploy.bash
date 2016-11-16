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
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.9.4
#
# 
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"


# Generic : Redefine pushd and popd to reduce their output messages
# 
function pushd() { builtin pushd "$@" > /dev/null; }
function popd()  { builtin popd  "$@" > /dev/null; }

function ini_func() { sleep 1; printf "\n>>>> You are entering in  : %s\n" "${1}"; }
function end_func() { sleep 1; printf "\n<<<< You are leaving from : %s\n" "${1}"; }

function checkstr() {
    if [ -z "$1" ]; then
	printf "%s : input variable is not defined \n" "${FUNCNAME[*]}"
	exit 1;
    fi
}


declare -gr SUDO_CMD="sudo";
declare -g SUDO_PID="";


function sudo_start() {
    ${SUDO_CMD} -v
    ( while [ true ]; do
	  ${SUDO_CMD} -n /bin/true;
	  sleep 60;
	  kill -0 "$$" || exit;
      done 2>/dev/null
    )&
}


declare -g  WARSRC_DIR=${SC_TOP};

function deploy_war_release() {

    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    local target=${1};
    local deploy_dir=${2};
    local warsrc_dir=${3};
    
    printf "%s %18s is deploying...\n" "-->" "new ${target} war"

    pushd ${deploy_dir}/${target}/webapps;
    ${SUDO_CMD} rm -rf ${target}*;
    ${SUDO_CMD} mkdir ${target};
    ${SUDO_CMD} unzip -q ${warsrc_dir}/${target}.war -d ${target};
    popd;
    
    end_func ${func_name};
}


sudo_start;

. ${SC_TOP}/setEnvAA.bash

if [[ ! -f ${WARSRC_DIR}/mgmt.war ]]; then
    printf "The folder ${WARSRC_DIR} does not seem to have a mgmt.war.\n"
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
site_specific_dir="${SC_TOP}/site_specific_content"

##
## Change template for web sites

if [[ -f ${site_specific_dir}/template_changes.html ]]; then
    echo ""
    echo "Modifying static contents for the site specific information"
    ${SUDO_CMD} -E java -cp ${ARCHAPPL_TOP}/mgmt/webapps/mgmt/WEB-INF/classes \
	org.epics.archiverappliance.mgmt.bpl.SyncStaticContentHeadersFooters \
	${site_specific_dir}/template_changes.html \
	${ARCHAPPL_TOP}/mgmt/webapps/mgmt/ui
    echo ""
fi

##
## Copy site specific images
if [[ -d ${site_specific_dir}/img ]]; then
    echo ""
    echo "Copying site specific images recursively from ${WARSRC_DIR} onto ${ARCHAPPL_TOP}";
    ${SUDO_CMD} cp -R ${site_specific_dir}/img/* ${ARCHAPPL_TOP}/mgmt/webapps/mgmt/ui/comm/img/ ;
    echo ""
fi

##
## Copy site specific main.css file
if [[ -d ${site_specific_dir}/css ]]; then
    echo ""
    echo "Copying site specific CSS files from ${WARSRC_DIR} onto ${ARCHAPPL_TOP}";
    for service in ${tomcat_services[@]}; do
	printf "%s %26s is deploying...\n" "-->" "new main.css in ${service}"
	${SUDO_CMD} cp -R ${site_specific_dir}/css/main.css ${ARCHAPPL_TOP}/${service}/webapps/${service}/ui/comm/css/ ;
    done
    echo ""
    
fi

echo "Done deploying a new release from ${WARSRC_DIR} onto ${ARCHAPPL_TOP}"



exit



