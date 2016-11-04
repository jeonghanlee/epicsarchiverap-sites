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
# Shell  : aaService.bash
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.9.0 CentOS 7.2
#
# We assume that we inherit the EPICS environment variables from something that calls this script
# However, if this is a init.d startup script, this is not going to be the case and we'll need to add them here.
# This includes setting up the LD_LIBRARY_PATH to include the JCA .so file.
#
# EPICS BASE is installed in the local directory
# 

source /home/aauser/epics/3.15.4/setEpicsEnv.sh

# 
# PREFIX : SC_, so declare -p can show them in a place
# 
# Generic : Global vaiables - readonly
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"

. ${SC_TOP}/setEnvAA.bash

# Set up the root folder of the individual Tomcat instances.
export ARCHAPPL_DEPLOY_DIR=${ARCHAPPL_TOP}

# Set appliance.xml and the identity of this appliance
export ARCHAPPL_APPLIANCES=${ARCHAPPL_DEPLOY_DIR}/appliances.xml
export ARCHAPPL_MYIDENTITY="appliance0"

# If you have your own policies file, please change this line.
# export ARCHAPPL_POLICIES=/nfs/epics/archiver/production_policies.py


# It might be better to assign the proper directory, while the installating CentOS.
# Anyway, /home has the most of space, so I created
# Make tmpfs for the short term storage by editing /etc/fstab file.
#  For 10G file size add this line: 
# tmpfs    /srv/sts 		tmpfs 	defaults,size=10g 0 0 
export ARCHAPPL_STORAGE_TOP=/home
#
# Set the location of short term and long term stores; this is necessary only if your policy demands it
export ARCHAPPL_SHORT_TERM_FOLDER=/srv/sts/ArchiverStore
export ARCHAPPL_MEDIUM_TERM_FOLDER=${ARCHAPPL_STORAGE_TOP}/arch/mts/ArchiverStore
export ARCHAPPL_LONG_TERM_FOLDER=${ARCHAPPL_STORAGE_TOP}/arch/lts/ArchiverStore



if [[ ! -d ${TOMCAT_HOME} ]]
then
    echo "Unable to determine the source of the tomcat distribution"
    exit 1
fi

if [[ ! -f ${ARCHAPPL_APPLIANCES} ]]
then
    echo "Unable to find appliances.xml at ${ARCHAPPL_APPLIANCES}"
    exit 1
fi

# Enable core dumps in case the JVM fails
ulimit -c unlimited


# Generic : Redefine pushd and popd to reduce their output messages
# 
function pushd() { builtin pushd "$@" > /dev/null; }
function popd()  { builtin popd  "$@" > /dev/null; }


function startTomcatAtLocation() {
    
    if [ -z "$1" ]; then echo "startTomcatAtLocation called without any arguments"; exit 1; fi
    echo ""

    export CATALINA_HOME=$TOMCAT_HOME
    export CATALINA_BASE=$1
    
    echo "> Starting TOMCAT at ${CATALINA_BASE}"
    
    ARCH=`uname -m`
    if [[ $ARCH == 'x86_64' || $ARCH == 'amd64' ]]
    then
	echo "Using 64 bit versions of libraries"
	export LD_LIBRARY_PATH=${CATALINA_BASE}/webapps/engine/WEB-INF/lib/native/linux-x86_64:${CATALINA_HOME}/lib:${LD_LIBRARY_PATH}
    else
	echo "Using 32 bit versions of libraries"
	export LD_LIBRARY_PATH=${CATALINA_BASE}/webapps/engine/WEB-INF/lib/native/linux-x86:${CATALINA_HOME}/lib:${LD_LIBRARY_PATH}
    fi
  
    pushd ${CATALINA_BASE}/logs
    #    ${CATALINA_HOME}/bin/jsvc \
    # JSVC re-exec requires execution with an absolute or relative path
    /bin/jsvc \
        -server \
        -cp ${CLASS_PATH}/apache-commons-daemon.jar:${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar \
        ${JAVA_OPTS} \
        -Dcatalina.base=${CATALINA_BASE} \
        -Dcatalina.home=${CATALINA_HOME} \
        -cwd ${CATALINA_BASE}/logs \
        -outfile ${CATALINA_BASE}/logs/catalina.out \
        -errfile ${CATALINA_BASE}/logs/catalina.err \
        -pidfile ${CATALINA_BASE}/pid \
        org.apache.catalina.startup.Bootstrap start
     popd
     echo ""
}

function stopTomcatAtLocation() {
    
    if [ -z "$1" ]; then echo "stopTomcatAtLocation called without any arguments"; exit 1; fi
    
    export CATALINA_HOME=$TOMCAT_HOME
    export CATALINA_BASE=$1

    echo "< Stopping Tomcat at ${CATALINA_BASE}"

    pushd ${CATALINA_BASE}/logs
    #   ${CATALINA_HOME}/bin/jsvc \
    /bin/jsvc \
	-server \
        -cp ${CLASS_PATH}/apache-commons-daemon.jar:${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar \
	${JAVA_OPTS} \
	-Dcatalina.base=${CATALINA_BASE} \
	-Dcatalina.home=${CATALINA_HOME} \
	-cwd ${CATALINA_BASE}/logs \
	-outfile ${CATALINA_BASE}/logs/catalina.out \
	-errfile ${CATALINA_BASE}/logs/catalina.err \
	-pidfile ${CATALINA_BASE}/pid \
	-stop \
	org.apache.catalina.startup.Bootstrap 
    popd
    echo ""
}

# Service order is matter, don't change them
tomcat_services=("mgmt" "engine" "etl" "retrieval")

HOSTNAME=`hostname --all-fqdn`
AA_HOSTNAME=$(tr -d ' ' <<< ${HOSTNAME})

function status() {
    echo "-- Status outputs " 
    echo "-- http://${AA_HOSTNAME}:17665/mgmt/ui/index.html is the web address.";
    echo "-- ${ARCHAPPL_DEPLOY_DIR}/mgmt/logs/catalina.err may help you.";
    echo "-- If eight numbers are printed below, the jsvc processes are running";
    pidof jsvc.exec;
    echo "--";
}

function stop() {

    # Stopping order is matter! 

    stopTomcatAtLocation "${ARCHAPPL_DEPLOY_DIR}/engine";
    stopTomcatAtLocation "${ARCHAPPL_DEPLOY_DIR}/retrieval";
    stopTomcatAtLocation "${ARCHAPPL_DEPLOY_DIR}/etl";
    stopTomcatAtLocation "${ARCHAPPL_DEPLOY_DIR}/mgmt";
  
    status;
}

function start() { 

    for service in ${tomcat_services[@]}; do
	startTomcatAtLocation "${ARCHAPPL_DEPLOY_DIR}/${service}";
    done

#   startTomcatAtLocation "${ARCHAPPL_DEPLOY_DIR}/mgmt";
#   startTomcatAtLocation "${ARCHAPPL_DEPLOY_DIR}/engine";
#   startTomcatAtLocation "${ARCHAPPL_DEPLOY_DIR}/etl";
#   startTomcatAtLocation "${ARCHAPPL_DEPLOY_DIR}/retrieval";
    
    status;
}


# See how we were called.
case "$1" in
    start)
	start
	;;
    stop)
	stop
	;;
    restart)
	stop
	start
	;;
    *)
	echo $"Usage: $0 {start|stop|restart}"
	exit 2
esac


