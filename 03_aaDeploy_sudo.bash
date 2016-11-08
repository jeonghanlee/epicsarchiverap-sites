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


function ini_func() { sleep 1; printf "\n>>>> You are entering in  : %s\n" "${1}"; }
function end_func() { sleep 1; printf "\n<<<< You are leaving from : %s\n" "${1}"; }

function checkstr() {
    if [ -z "$1" ]; then
	printf "%s : input variable is not defined \n" "${FUNCNAME[*]}"
	exit 1;
    fi
}


. ${SC_TOP}/setEnvAA.bash

declare -gr SUDO_CMD="sudo";

# For not CentOS users
# One should check that jar and java should be in PATH
#
function deploy_war_release() {

    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    local target=${1};
    local deploy_dir=${2};
    local warsrc_dir=${3};
    
    printf "%s %18s is deploying...\n" "-->" "new ${target} war"

    pushd ${deploy_dir}/${target}/webapps;
    ${SUDO_CMD} rm -rf ${target}*;
    ${SUDO_CMD} cp ${warsrc_dir}/${target}.war .;
    ${SUDO_CMD} mkdir ${target};
    ${SUDO_CMD} cd ${target};
    ${SUDO_CMD} jar xf ../${target}.war;
    popd;
    
    end_func ${func_name};
}

${SUDO_CMD} -v

if [[ ! -f ${SC_TOP}/mgmt.war ]]; then
    printf "You need to call 01_aaBuild.bash and 02_aaSetup.bash first.\n";
    printf "The folder %s does not seem to have a mgmt.war.\n" "${SC_TOp}";
    exit 1
fi

tomcat_services=("mgmt" "engine" "etl" "retrieval");

printf "Deploying a new release from %s onto %s\n" "${SC_TOP}" "${ARCHAPPL_TOP}";

for service in ${tomcat_services[@]}; do
    deploy_war_release ${service} "${ARCHAPPL_TOP}" "${SC_TOP}";
done


# Post installation steps for changing look and feel etc.
site_specific_dir="${SC_TOP}/site_specific_content"

##
## Change template for web sites
if [[ -f ${site_specific_dir}/template_changes.html ]]; then
    printf "\nModifying static contents for the site specific information\n";
    ${SUDO_CMD} java -cp ${ARCHAPPL_TOP}/mgmt/webapps/mgmt/WEB-INF/classes \
		org.epics.archiverappliance.mgmt.bpl.SyncStaticContentHeadersFooters \
		${site_specific_dir}/template_changes.html \
		${ARCHAPPL_TOP}/mgmt/webapps/mgmt/ui
    printf "\n";
fi


##
## Copy site specific images
if [[ -d ${site_specific_dir}/img ]]; then
    printf "\nCopying site specific images recursively from %s onto %s\n" "${SC_TOP}" "${ARCHAPPL_TOP}";
    ${SUDO_CMD} cp -R ${site_specific_dir}/img/* ${ARCHAPPL_TOP}/mgmt/webapps/mgmt/ui/comm/img/ ;
    printf "\n"
fi


##
## Copy site specific main.css file
if [[ -d ${site_specific_dir}/css ]]; then
    printf "\nCopying site specific CSS files from %s onto %s\n" "${SC_TOP}" "${ARCHAPPL_TOP}";
    for service in ${tomcat_services[@]}; do
	printf "%s %26s is deploying...\n" "-->" "new main.css in ${service}"
	${SUDO_CMD} cp -R ${site_specific_dir}/css/main.css ${ARCHAPPL_TOP}/${service}/webapps/${service}/ui/comm/css/ ;
    done
    printf "\n";
fi

printf "Done deploying a new release from %s onto %s\n" "${SC_TOP}" "${ARCHAPPL_TOP}";

exit;
