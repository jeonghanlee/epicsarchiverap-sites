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
# Date   : 
# version : 0.9.7
#
# 
ROOT_UID=0  
E_NOTROOT=101

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"

# Enable core dumps in case the JVM fails
ulimit -c unlimited



function startTomcatAtLocation() {

    if [ $# -eq 0 ]; then
	printf "startTomcatAtLocation called without any arguments\n";
	exit 1;
    fi

    local  SERVICE_TOP=$1;
    local  SERVICE_NAME=$2;
    
    export CATALINA_HOME=$TOMCAT_HOME
    export CATALINA_BASE=${SERVICE_TOP}/${SERVICE_NAME};


    
    echo ""
    echo ">> Starting TOMCAT at ${CATALINA_BASE}"

    pushd ${CATALINA_BASE}/logs

    #    ${CATALINA_HOME}/bin/jsvc \
    # JSVC re-exec requires execution with an absolute or relative path
    /bin/jsvc \
        -server \
	-user ${TOMCAT_USER} \
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

    # make sure, ${TOMCAT_USER} can write something in ${ARCHAPPL_STROAGE_TOP}
    chown -R ${TOMCAT_USER}.${TOMCAT_GROUP} ${ARCHAPPL_STORAGE_TOP}
    # make sure, ${TOMCAT_USER} can write something in ${CATALINA}/logs 
    chown -R ${TOMCAT_USER}.${TOMCAT_GROUP} ${CATALINA_BASE}/logs
    # An user with ${TOMCAT_CROUP} can stop the service in the following 
    # chown ${TOMCAT_USER}.${TOMCAT_GROUP} ${CATALINA_BASE}/pid
    chmod 640 ${CATALINA_BASE}/logs/${SERVICE_NAME}_catalina.out
    chmod 640 ${CATALINA_BASE}/logs/${SERVICE_NAME}_catalina.err

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
    
    echo ""
    echo "<< Stopping Tomcat at ${CATALINA_BASE}"
    pushd ${CATALINA_BASE}/logs
    /bin/jsvc \
	-stop \
	-pidfile ${CATALINA_BASE}/pid \
	org.apache.catalina.startup.Bootstrap 
    popd
    echo ""
}

# Service order is matter, don't change them
tomcat_services=("mgmt" "engine" "etl" "retrieval")


function status() {

    printf "\n>>>> EPICS Env outputs\n";
    printf "     EPICS_BASE %s\n" "${EPICS_BASE}";
    printf "     LD_LIBRARY_PATH %s\n" "${LD_LIBRARY_PATH}";
    printf "     EPICS_CA_ADDR_LIST %s\n" "${EPICS_CA_ADDR_LIST}";
    printf "\n";
    systemctl is-active firewalld >/dev/null 2>&1 && printf "\n\n>>>> FIREWALLD IS RUNNING!!!! \n"
    printf "\n>>>> Status outputs \n" ;
    printf "   > Web url \n";
    printf "     http://%s:17665/mgmt/ui/index.html\n" "${_HOST_NAME}";
    printf "                         OR\n";
    printf "     http://%s:17665/mgmt/ui/index.html\n" "${_HOST_IP}";
    printf "\n";
    printf "   > Log \n";
    printf "     %s/mgmt/logs/mgmt_catalina.err may help you.\n" "${ARCHAPPL_TOP}";
    printf "     tail -f %s/mgmt/logs/mgmt_catalina.err\n" "${ARCHAPPL_TOP}";
    printf "\n";
    printf "   > jsvc pid :If eight numbers are printed below, the jsvc processes are running\n";
    /sbin/pidof jsvc.exec;
    printf "\n";
 
}


function stroage_status() {

    local all=$1
    printf "\n>>>> Stroage Status at %s\n\n" "${SC_LOGDATE}";
    du --total --human-readable --time --${all} ${ARCHAPPL_STORAGE_TOP};
    printf "\n";

}


function stop() {

    checkIfRoot;

    # Stopping order is matter! 
    stopTomcatAtLocation "${ARCHAPPL_TOP}" "engine";
    stopTomcatAtLocation "${ARCHAPPL_TOP}" "retrieval";
    stopTomcatAtLocation "${ARCHAPPL_TOP}" "etl";
    stopTomcatAtLocation "${ARCHAPPL_TOP}" "mgmt";

    status;

}

function start() { 

    checkIfArchappl
    checkIfRoot;

    
    for service in ${tomcat_services[@]}; do
	startTomcatAtLocation "${ARCHAPPL_TOP}" "${service}";
    done

    status;
}



. ${SC_TOP}/functions
. ${SC_TOP}/setEnvAA.bash


if [[ ! -d ${TOMCAT_HOME} ]]; then
    echo "Unable to determine the source of the tomcat distribution"
    exit 1
fi

if [[ ! -f ${ARCHAPPL_APPLIANCES} ]]; then
    echo "Unable to find appliances.xml at ${ARCHAPPL_APPLIANCES}"
    exit 1
fi


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
    status)
	status
	;;
    stroage)
	case "$2" in
	    all) 
		stroage_status "$2"
		;;
	    *)
		stroage_status 
		;;
	esac
	;;
    *)
	echo "Usage: $0 {start|stop|restart|status|stroage}"
	exit 2
esac


