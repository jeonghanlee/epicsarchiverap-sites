#!/bin/bash

# The function is defined in the following article
# http://pempek.net/articles/2013/07/08/bash-sh-as-template-engine/
render_template() 
{
    eval "echo \"$(cat $1)\""
}


if [[ -z ${JAVA_HOME} ]]
then
    echo "Please set JAVA_HOME to point to a 1.8 JDK"
    exit 1
fi

export PATH=${JAVA_HOME}/bin:${PATH}

if [[ -z ${TOMCAT_HOME} ]]
then
    echo "Please set TOMCAT_HOME to point to a proper PATH"
    exit 1
fi

# CENTOS, TOMCAT_HOME is /usr/share/tomcat
# 

#
# Variable with Prefix AA_ are used in appliances.template
# and context.template
#
AA_SCRIPTNAME=`basename $0`
AA_LOGDATE=`date +%Y.%m.%d.%H:%M`

SCRIPTS_DIR=`dirname $0`
AA_SCRIPTS_PATH=`cd ${SCRIPTS_DIR} && pwd`
AA_HOSTNAME=`hostname -f`
AA_USERNAME=`whoami`


DEPLOY_DIR=/opt/archappl

 
TEMPLATE_DIR=${AA_SCRIPTS_PATH}/template

##
# The following two PATHs for only testing purpose, 
# they override PATHS in order to create appliances.xml and context.xml
# in the SCRIPTS_DIR. So they should comment out after testing.  
# 
# DEPLOY_DIR=${SCRIPTS_DIR}
# TOMCAT_HOME=${SCRIPTS_DIR}


mv ${TEMPLATE_DIR}/log4j.properties ${TOMCAT_HOME}/lib/



#
# This approach is only valid for the single appliance installation.
# If one wants to install multiple appliances, appliances.xml should
# has the different structures. 
#
AA_MYIDENTITY="appliances0"

ARCHAPPL_APPLIANCES=${DEPLOY_DIR}/appliances.xml
ARCHAPPL_MYIDENTITY=${AA_MYIDENTITY}

render_template ${TEMPLATE_DIR}/appliances.template > ${ARCHAPPL_APPLIANCES}

echo "Calling ${SCRIPTS_DIR}/aa_scripts/deployMultipleTomcats.py ${DEPLOY_DIR}"
${SCRIPTS_DIR}/aa_scripts/deployMultipleTomcats.py ${DEPLOY_DIR}

TOMCAT_CONTEXTCONTAINER=${DEPLOY_DIR}/mgmt/conf/context.xml

# Do we need to deploy the same context.xml file into
# {mgmt,etl,retrieval,engine}/conf/?
# In single_machine_install.sh, this was done only in {mgmt} directory with  addMysqlConnPool.py,
# But in FRIB puppet/minifest/init.pp, four directories should have the same one. 
# need to contact ...
# 2016-08-30, Jeong Han Lee
#

AA_MYSQL_DB="archappl"
AA_MYSQL_USERNAME="archappl"
AA_MYSQL_PASSWORD="archappl"


render_template ${TEMPLATE_DIR}/contex.template > ${TOMCAT_CONTEXTCONTAINER}
