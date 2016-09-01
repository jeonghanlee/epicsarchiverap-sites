#!/bin/bash
#
# Shell  : deployRelease.bash
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.9.0 CentOS 7.2
#
# This is the customzied deployRelease.sh for Han Lee 
# in order to test the ESS customized Archiver Appliance service
# 
# Requirement:
# New (old) mgmt.war, engine.war, etl.war, and retrieval.war should be ready in this directory (.../epicsarchiverap-sites)
# 
# 1) Download the tar.gz version, and extract them, and put four files into the directory
# 2) git clone https://github.com/slacmshankar/epicsarchiverap/ in the directory, and compile them by oneself. So the files
#    can be located in the directory.
# 
# 
# This script should be used in the following two scenarios:
# 1) after the initial setup for the Archiver Appliance
# 2) when one wants to upgrade (downgrade) new (old) release of the Archiver Appliance from the community or elsewhere
# 
# 
# Example to execute this script as follows:
#
# [root@ics-tag348 epicsarchiverap-sites]# pwd
# /home/aauser/gitsrc/epicsarchiverap-sites
# [root@ics-tag348 epicsarchiverap-sites]# bash deployRelease.sh 
# You need to call deployRelease.sh with the folder containing the mgmt and other war files.
# 1) [root@ics-tag348 epicsarchiverap-sites]# bash deployRelease.sh $PWD
# 2) [root@ics-tag348 *anywhere           *]# bash /home/aauser/gitsrc/epicsarchiverap-sites/deployRelease.sh /home/aauser/gitsrc/epicsarchiverap-sites/

#
# Redefine pushd and popd to reduce their output messages
#
pushd() { builtin pushd "$@" > /dev/null; }
popd()  { builtin popd  "$@" > /dev/null; }


# pushd ${DEPLOY_DIR}/mgmt/webapps      && rm -rf mgmt*;      cp ${WARSRC_DIR}/mgmt.war .;      mkdir mgmt; cd mgmt;         jar xf ../mgmt.war; popd; 
# pushd ${DEPLOY_DIR}/engine/webapps    && rm -rf engine*;    cp ${WARSRC_DIR}/engine.war .;    mkdir engine; cd engine;       jar xf ../engine.war; popd; 
# pushd ${DEPLOY_DIR}/etl/webapps       && rm -rf etl*;       cp ${WARSRC_DIR}/etl.war .;       mkdir etl; cd etl;             jar xf ../etl.war; popd; 
# pushd ${DEPLOY_DIR}/retrieval/webapps && rm -rf retrieval*; cp ${WARSRC_DIR}/retrieval.war .; mkdir retrieval; cd retrieval; jar xf ../retrieval.war; popd;

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


if [[ $# -eq 0 ]]
then
    echo "You need to call deployRelease.sh with the folder containing the mgmt and other war files."
    exit 1
fi

WARSRC_DIR=${1}

if [[ ! -f ${WARSRC_DIR}/mgmt.war ]]
then
    echo "You need to call deployRelease.sh with the folder containing the mgmt and other war files. \
          The folder ${WARSRC_DIR} does not seem to have a mgmt.war."
    exit 1
fi

# JAVA Environment is defined by the System.
# If not, please set them properly.

# export JAVA_HOME=/opt/jdk1.8.0_77/
# export PATH=${JAVA_HOME}/bin:${PATH}

export TOMCAT_HOME=/usr/share/tomcat
export DEPLOY_DIR=/opt/archappl
export CATALINA_HOME=${TOMCAT_HOME}

tomcat_services=("mgmt" "engine" "etl" "retrieval")


echo "Deploying a new release from ${WARSRC_DIR} onto ${DEPLOY_DIR}"



echo ""
echo "Replacing old war files with new war files"
for service in ${tomcat_services[@]}; do
    deploy_war_release ${service} "${DEPLOY_DIR}" "${WARSRC_DIR}"
done

# Post installation steps for changing look and feel etc.

SITE_SPECIFIC_DIR="${WARSRC_DIR}/site_specific_content"

## Change template for web sites

if [[ -f ${SITE_SPECIFIC_DIR}/template_changes.html ]]
then
    echo ""
    echo "Modifying static contents for the site specific information"
    java -cp ${DEPLOY_DIR}/mgmt/webapps/mgmt/WEB-INF/classes \
	 org.epics.archiverappliance.mgmt.bpl.SyncStaticContentHeadersFooters \
	 ${SITE_SPECIFIC_DIR}/template_changes.html \
	 ${DEPLOY_DIR}/mgmt/webapps/mgmt/ui
    echo ""
fi

## Copy site specific images

if [[ -d ${SITE_SPECIFIC_DIR}/img ]]
then
    echo ""
    echo "Copying site specific images recursively from ${WARSRC_DIR} onto ${DEPLOY_DIR}";
    cp -R ${SITE_SPECIFIC_DIR}/img/* ${DEPLOY_DIR}/mgmt/webapps/mgmt/ui/comm/img/ ;
    echo ""
fi

## Copy site specific main.css file
 
if [[ -d ${SITE_SPECIFIC_DIR}/css ]]
then
    echo ""
    echo "Copying site specific CSS files from ${WARSRC_DIR} onto ${DEPLOY_DIR}";
    for service in ${tomcat_services[@]}; do
	printf "%s %26s is deploying...\n" "-->" "new main.css in ${service}"
	cp -R ${SITE_SPECIFIC_DIR}/css/main.css ${DEPLOY_DIR}/${service}/webapps/${service}/ui/comm/css/ ;
    done
    echo ""
   
fi


echo "Done deploying a new release from ${WARSRC_DIR} onto ${DEPLOY_DIR}"
