#!/bin/bash
#
# This is the customzied deployRelease.sh for Han Lee in order to
# test ESS customized Archiver Appliance service
# 
# Email : han.lee@esss.se
# bash /home/jhlee/github/epicsarchiverap-sites/deployRelease.sh /home/jhlee/github/epicsarchiverap-sites/
#
# Archiver Appliance (deployment directory)
# - /opt/archiver_appliance
#
# JAVA
# - /opt/jdk1.8.0_77/
#
# Tomcat
# - /opt/archiver_appliance/apache-tomcat-7.0.68
#
# This script deploys a new build onto the EPICS archiver appliance installation at /opt/archiver_appliance
# Call this script with the folder that contains the expanded tar.gz; that is, the folder that contains the various WAR files
#



export JAVA_HOME=/opt/jdk1.8.0_77/
export PATH=${JAVA_HOME}/bin:${PATH}

export TOMCAT_HOME=/opt/archiver_appliance/apache-tomcat-7.0.68
export CATALINA_HOME=/opt/archiver_appliance/apache-tomcat-7.0.68
export DEPLOY_DIR=/opt/archiver_appliance

if [[ $# -eq 0 ]]
then
    echo "You need to call deployRelease.sh with the folder containing the mgmt and other war files."
    exit 1
fi

WARSRC_DIR=${1}


if [[ ! -f ${WARSRC_DIR}/mgmt.war ]]
then
    echo "You need to call deployRelease.sh with the folder containing the mgmt and other war files. The folder ${WARSRC_DIR} does not seem to have a mgmt.war."
    exit 1
fi

echo "Deploying a new release from ${WARSRC_DIR} onto ${DEPLOY_DIR}"
pushd ${DEPLOY_DIR}/mgmt/webapps && rm -rf mgmt*; cp ${WARSRC_DIR}/mgmt.war .; mkdir mgmt; cd mgmt; jar xf ../mgmt.war; popd; 
pushd ${DEPLOY_DIR}/engine/webapps && rm -rf engine*; cp ${WARSRC_DIR}/engine.war .; mkdir engine; cd engine; jar xf ../engine.war; popd; 
pushd ${DEPLOY_DIR}/etl/webapps && rm -rf etl*; cp ${WARSRC_DIR}/etl.war .; mkdir etl; cd etl; jar xf ../etl.war; popd; 
pushd ${DEPLOY_DIR}/retrieval/webapps && rm -rf retrieval*; cp ${WARSRC_DIR}/retrieval.war .; mkdir retrieval; cd retrieval; jar xf ../retrieval.war; popd;
echo "Done deploying a new release from ${WARSRC_DIR} onto ${DEPLOY_DIR}"

# Post installation steps for changing look and feel etc.

SITE_SPECIFIC_DIR="${WARSRC_DIR}/site_specific_content"

if [[ -f ${SITE_SPECIFIC_DIR}/template_changes.html ]]
then
    echo "Modifying static content to cater to site specific information"
    java -cp ${DEPLOY_DIR}/mgmt/webapps/mgmt/WEB-INF/classes \
	 org.epics.archiverappliance.mgmt.bpl.SyncStaticContentHeadersFooters \
	 ${SITE_SPECIFIC_DIR}/template_changes.html \
	 ${DEPLOY_DIR}/mgmt/webapps/mgmt/ui
fi

if [[ -d ${SITE_SPECIFIC_DIR}/img ]]
then
    echo "Replacing site specific images"
    cp -R ${SITE_SPECIFIC_DIR}/img/* ${DEPLOY_DIR}/mgmt/webapps/mgmt/ui/comm/img/
fi


if [[ -d ${SITE_SPECIFIC_DIR}/css ]]
then
    echo "Copying site specific main CSS files into ${DEPLOY_DIR}"
    cp -R ${SITE_SPECIFIC_DIR}/css/main.css ${DEPLOY_DIR}/mgmt/webapps/mgmt/ui/comm/css/
    cp -R ${SITE_SPECIFIC_DIR}/css/main.css ${DEPLOY_DIR}/engine/webapps/engine/ui/comm/css/
    cp -R ${SITE_SPECIFIC_DIR}/css/main.css ${DEPLOY_DIR}/etl/webapps/etl/ui/comm/css/
    cp -R ${SITE_SPECIFIC_DIR}/css/main.css ${DEPLOY_DIR}/retrieval/webapps/retrieval/ui/comm/css/
    
fi


