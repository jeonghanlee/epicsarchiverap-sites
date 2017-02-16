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
#   date    : Thursday, February 16 15:43:27 CET 2017
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



# Service order is matter, don't change them
tomcat_services=("mgmt" "engine" "etl" "retrieval")

function ls_archappl() { 


    for service in ${tomcat_services[@]}; do
	echo "In ${ARCHAPPL_TOP}/${service}"
	ls "${ARCHAPPL_TOP}/${service}/webapps/${service}/WEB-INF/classes/" 
	echo ""
    done

}


function find_properties() {
    for service in ${tomcat_services[@]}; do
	echo "In ${ARCHAPPL_TOP}/${service}"
	grep -r archappl.properties "${ARCHAPPL_TOP}/${service}/logs/arch.log"
	echo ""
    done
}


function find_policies() {
    for service in ${tomcat_services[@]}; do
	echo "In ${ARCHAPPL_TOP}/${service}"
	grep -r $SITE_POLICIES_FILE "${ARCHAPPL_TOP}/${service}/logs/arch.log"
#	grep -r "policies" "${ARCHAPPL_TOP}/${service}/logs"
	echo ""
    done
}



case "$1" in
    ls)
	ls_archappl
	;;
    properties)
	find_properties
	;;
    policies)
	find_policies
	;;
    *)
	echo "Usage: $0 {ls|properties|policies}"
	exit 2
esac

