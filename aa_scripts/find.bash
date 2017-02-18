#!/bin/bash
#
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
#
#   author  : Jeong Han Lee
#   email   : jeonghan.lee@gmail.com
#   date    : Friday, February 17 15:12:30 CET 2017
#   version : 0.0.1


declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"
declare -gr SC_IOCUSER="$(whoami)"


set -a
. ${SC_TOP}/../env.conf
set +a


. ${SC_TOP}/../functions



function ls_archappl() { 


    for service in ${tomcat_services[@]}; do
	echo "In ${ARCHAPPL_TOP}/${service}"
	ls "${ARCHAPPL_TOP}/${service}/webapps/${service}/WEB-INF/classes/" 
	echo ""
    done

}

function find_in_logs() {

    local object=$1;

    for service in ${tomcat_services[@]}; do
	echo "In ${ARCHAPPL_TOP}/${service}"
	grep -r ${object} "${ARCHAPPL_TOP}/${service}/logs/arch.log"
	echo ""
    done
}


function clear_stroage() {
    
    rm -rf ${ARCHAPPL_STORAGE_TOP}/{sts,mts,lts}/ArchiverStore/* ;

}


function clear_log() {
    for service in ${tomcat_services[@]}; do
	rm -rf ${ARCHAPPL_TOP}/${service}/logs/arch.log
    done
}

case "$1" in
    ls)
	ls_archappl
	;;
    properties)
	find_in_logs "${SITE_PROPERTIES_FILE}"
	;;
    policies)
	find_in_logs "${SITE_POLICIES_FILE}"
	;;
    error)
	find_in_logs "ERROR"
	;;
    info)
	find_in_logs "INFO"
	;;
    debug)
	find_in_logs "DEBUG"
	;;
    clean)
	checkIfRoot
	clear_stroage
	clear_log
	;;
    *)
	echo "Usage: $0 {properties|policies|info|debug|error}"
	exit 2
esac

