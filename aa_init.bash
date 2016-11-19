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
# email  : han.lee@esss.se
# Date   : Monday, November  7 13:10:41 CET 2016
# version : 0.1.3
#
# 
# Generic : Global variables - read-only
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"


# Generic : Redefine pushd and popd to reduce their output messages
# 
function pushd() { builtin pushd "$@" > /dev/null; }
function popd()  { builtin popd  "$@" > /dev/null; }

function ini_func() { sleep 1; printf "\n>>>> You are entering in  : %s\n" "${1}"; }
function end_func() { sleep 1; printf "\n<<<< You are leaving from : %s\n" "${1}"; }

function checkstr() {
    if [ -z "$1" ]; then
	printf "%s : input variable is not defined \n" "${FUNCNAME[*]}"
	exit 1;
    fi
}


declare -gr SUDO_CMD="sudo";
declare -g SUDO_PID="";

# Generic : git_clone
# 1.0.2 Monday, Monday, November  7 15:53:13 CET 2016
#
# Required Global Variable
# - SC_LOGDATE      : Input

function git_clone() {
    
    local func_name=${FUNCNAME[*]}; ini_func ${func_name};
    
    local git_src_dir=$1;
    local git_src_url=$2;
    local git_src_name=$3;
    local tag_name=$4;
    
    checkstr ${SC_LOGDATE};
    
    if [[ ! -d ${git_src_dir} ]]; then
	printf "No git source repository in the expected location %s\n" "${git_src_dir}";
    else
	printf "Old git source repository in the expected location %s\b" "${git_src_dir}";
	printf "The old one is renamed to %s_%s\n" "${git_src_dir}" "${SC_LOGDATE}";
	mv  ${git_src_dir} ${git_src_dir}_${SC_LOGDATE}
    fi
    
    # Always fresh cloning ..... in order to workaround any local 
    # modification in the repository, which was cloned before. 
    #
    if [ -z "$tag_name" ]; then
	git clone "${git_src_url}/${git_src_name}" "${git_src_dir}";
    else
	git clone -b "${tag_name}" --single-branch --depth 1 "${git_src_url}/${git_src_name}" "${git_src_dir}";
    fi

    end_func ${func_name};
}


# Specific : preparation
#
# 1.0.1 Wednesday, November  9 09:56:52 CET 2016
#
# - allow this script to execute yum, and remove PakageKit
#
function preparation() {
    
    local func_name=${FUNCNAME[*]};  ini_func ${func_name};
    checkstr ${SUDO_CMD};

    ${SUDO_CMD} systemctl stop packagekit
    ${SUDO_CMD} systemctl disable packagekit
    
    declare -r yum_pid="/var/run/yum.pid"

    # Somehow, yum is running due to PackageKit, so if so, kill it
    #
    if [[ -e ${yum_pid} ]]; then
	${SUDO_CMD} kill -9 $(cat ${yum_pid})
	if [ $? -ne 0 ]; then
	    printf "Remove the orphan yum pid\n";
	    ${SUDO_CMD} rm -rf ${yum_pid}
	fi
    fi
        
    # Remove PackageKit
    #
    ${SUDO_CMD} yum -y remove PackageKit ;
    
    # Install epel-release, git, and tree
    #
    ${SUDO_CMD} yum -y install epel-release git tree;	
	
    end_func ${func_name};
}

${SUDO_CMD} -v

preparation; 

git_src_name="epicsarchiverap-sites";
git_src_url="https://github.com/jeonghanlee";
git_src_dir=${SC_TOP}/${git_src_name};

git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" ; 

printf "\nPlease go %s\n" "${git_src_dir}";
printf "Do bash the following scripts in order\n";
printf "$ bash 00_preAA.bash\n";
printf "$ bash 01_aaBuild.bash\n";
printf "# bash 02_aaSetup.bash\n";
printf "# bash 03_aaDeploy.bash\n";
printf "\n";
printf "# bash aaService.bash start/stop/status\n";

# Remove some directories in ${HOME}
printf "Remove Music, Pictures, Public, Templates, and Videos directories in ${HOME}.... \n";
rm -rf ${HOME}/{Music,Pictures,Public,Templates,Videos};



exit;
