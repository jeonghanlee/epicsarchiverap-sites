#!/bin/bash
#
#  Copyright (c) 2016 - Present Jeong Han Lee
#  Copyright (c) 2016 - Present European Spallation Source ERIC
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
# Date   : Thursday, February 16 15:03:29 CET 2017
# version : 0.9.8-rc0
#
# 
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"

. ${SC_TOP}/functions

declare -gr SUDO_CMD="sudo";
declare -g SUDO_PID="";

declare -g  WARSRC_DIR=${SC_TOP};

function deploy_war_release() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local target=${1};
    local deploy_dir=${2};
    local warsrc_dir=${3};
    
    printf "%s %18s is deploying...\n" "-->" "new ${target} war"

    pushd ${deploy_dir}/${target}/webapps;
    ${SUDO_CMD} rm -rf ${target}*;
    ${SUDO_CMD} mkdir ${target};
    ${SUDO_CMD} unzip -q ${warsrc_dir}/${target}.war -d ${target};

    popd;
 
    __end_func ${func_name};
}


${SUDO_CMD} -v

. ${SC_TOP}/setEnvAA.bash


checkIfArchappl

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

##
## Copy site specific default_policies.py file
if [[ -f ${site_specific_dir}/default_policies.py  ]]; then
    echo ""
    echo "Copying the default site specific polices file onto ${ARCHAPPL_TOP}";
    ${SUDO_CMD} cp -R ${site_specific_dir}/default_policies.py ${ARCHAPPL_POLICIES} ;
    echo ""
    
fi

##
## Copy site specific default archappl.properties file
if [[ -f ${site_specific_dir}/default_archappl.properties  ]]; then
    echo ""
    echo "Copying the default site specific default archappl.properties file onto ${ARCHAPPL_TOP}";
    ${SUDO_CMD} cp -R ${site_specific_dir}/default_archappl.properties ${ARCHAPPL_PROPERTIES_FILENAME} ;
    echo ""
    
fi



echo "Done deploying a new release from ${WARSRC_DIR} onto ${ARCHAPPL_TOP}"


##
##
## Change owner and its group recursively in the archappl directory
## The symbolic link stays as root.root
##
${SUDO_CMD} chown -R ${TOMCAT_USER}.${TOMCAT_GROUP} ${ARCHAPPL_TOP}
${SUDO_CMD} chown -R ${TOMCAT_USER}.${TOMCAT_GROUP} ${ARCHAPPL_STORAGE_TOP}

${SUDO_CMD} -k;

exit



