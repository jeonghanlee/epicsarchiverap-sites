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
# version : 0.9.1 CentOS 7.2
#
# 
# PREFIX : SC_, so declare -p can show them in a place
# 
# Generic : Global vaiables - readonly
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"

# Enable core dumps in case the JVM fails
ulimit -c unlimited

# Generic : Redefine pushd and popd to reduce their output messages
# 
function pushd() { builtin pushd "$@" > /dev/null; }
function popd()  { builtin popd  "$@" > /dev/null; }



. ${SC_TOP}/setEnvAA.bash


# If you have your own policies file, please change this line.
# export ARCHAPPL_POLICIES=/nfs/epics/archiver/production_policies.py


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


function startTomcatAtLocation() {

    if [ $# -eq 0 ]; then
	printf "startTomcatAtLocation called without any arguments\n";
	exit 1;
    fi

    local  SERVICE_TOP=$1;
    local  SERVICE_NAME=$2;

    export CATALINA_HOME=$TOMCAT_HOME
    export CATALINA_BASE=${SERVICE_TOP}/${SERVICE_NAME};
    # Something is not right in LD_LIBRARY_PATH, should check them later. 
    #
    echo ">> Starting TOMCAT at ${CATALINA_BASE}"
    # 

    echo $LD_LIBRARY_PATH

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
        -outfile ${CATALINA_BASE}/logs/${SERVICE_NAME}_catalina.out \
        -errfile ${CATALINA_BASE}/logs/${SERVICE_NAME}_catalina.err \
        -pidfile ${CATALINA_BASE}/pid \
        org.apache.catalina.startup.Bootstrap start
     popd
     echo ""
}

function stopTomcatAtLocation() {

    if [ $# -eq 0 ]; then
	printf "stopTomcatAtLocation called without any arguments\n";
	exit 1;
    fi
    
    local  SERVICE_TOP=$1;
    local  SERVICE_NAME=$2;

    export CATALINA_HOME=$TOMCAT_HOME
    export CATALINA_BASE=${SERVICE_TOP}/${SERVICE_NAME};

    echo "<< Stopping Tomcat at ${CATALINA_BASE}"

    pushd ${CATALINA_BASE}/logs
    #   ${CATALINA_HOME}/bin/jsvc \
    /bin/jsvc \
	-server \
        -cp ${CLASS_PATH}/apache-commons-daemon.jar:${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar \
	${JAVA_OPTS} \
	-Dcatalina.base=${CATALINA_BASE} \
	-Dcatalina.home=${CATALINA_HOME} \
	-cwd ${CATALINA_BASE}/logs \
	-outfile ${CATALINA_BASE}/logs/${SERVICE_NAME}_catalina.out \
	-errfile ${CATALINA_BASE}/logs/${SERVICE_NAME}_catalina.err \
	-pidfile ${CATALINA_BASE}/pid \
	-stop \
	org.apache.catalina.startup.Bootstrap 
    popd
    echo ""
}

# Service order is matter, don't change them
tomcat_services=("mgmt" "engine" "etl" "retrieval")

function status() {

    echo "-- Status outputs " 
    echo "-- http://${_HOST_NAME}:17665/mgmt/ui/index.html is the web address.";
    echo "-- OR";
    echo "-- http://${_HOST_IP}:17665/mgmt/ui/index.html is the web address.";
    echo "-- ${ARCHAPPL_TOP}/mgmt/logs/mgmt_catalina.err may help you.";
    echo "-- If eight numbers are printed below, the jsvc processes are running";
    pidof jsvc.exec;
    echo "--";
}

function stop() {

    # Stopping order is matter! 

    stopTomcatAtLocation "${ARCHAPPL_TOP}" "engine";
    stopTomcatAtLocation "${ARCHAPPL_TOP}" "retrieval";
    stopTomcatAtLocation "${ARCHAPPL_TOP}" "etl";
    stopTomcatAtLocation "${ARCHAPPL_TOP}" "mgmt";
  
    status;
}

function start() { 

    for service in ${tomcat_services[@]}; do
	startTomcatAtLocation "${ARCHAPPL_TOP}" "${service}";
    done

#   startTomcatAtLocation "${ARCHAPPL_TOP}/mgmt";
#   startTomcatAtLocation "${ARCHAPPL_TOP}/engine";
#   startTomcatAtLocation "${ARCHAPPL_TOP}/etl";
#   startTomcatAtLocation "${ARCHAPPL_TOP}/retrieval";
    
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


