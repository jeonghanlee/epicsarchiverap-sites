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
# email  : jeonghan.lee@gmail.com
# Date   : 
# version : 0.0.1
#


declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_DATE="$(date +%Y%m%d-%H%M)"


set -a
. ${SC_TOP}/env.conf
set +a

. ${SC_TOP}/functions


declare -a pv_dir=()

function ts() {
	local pv=$2
	local stroage=$1
	pv2dir $pv;
	# assume PV has AA:BB
	# length of array is  ${#array[@]}
	echo ""
	ls --almost-all -o -g  --human-readable --time-style=iso -v  $stroage/"${pv_dir[0]}"/"${pv_dir[1]}"*
	echo ""
}

function pv2dir() {

	local pv=$1
	IFS=':'; 
	pv_dir=($pv); 
	unset IFS;
}



pv=$2

# if there is no $2, show all files in all directories in sts/mts/lts

case "$1" in
    sts)
    	ts ${ARCHAPPL_SHORT_TERM_FOLDER} $pv
	;;
    mts)
	ts ${ARCHAPPL_MEDIUM_TERM_FOLDER} $pv 
	;;
    lts)
	lts  ${ARCHAPPL_LONG_TERM_FOLDER} $pv
	;;
    *)

	echo "">&2
	echo " Usage: $0 <arg1>  <arg2> ">&2 
	echo ""
        echo "          <arg1>   : info">&2 
	echo ""
	echo "           sts     : roage ">&2
	echo "           mts     : Medium Term Stroage ">&2
	echo "           lts     : Long   Term Stroage ">&2
	echo "">&2
	echo "          <arg2>   : optional      ">&2
	echo "          pv       : select one pv ">&2
	echo "">&2
	echo "">&2 	
	exit 0
esac



