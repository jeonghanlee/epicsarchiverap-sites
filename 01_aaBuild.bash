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
# 
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.9.3
#

# http://www.gnu.org/software/bash/manual/bashref.html#Bash-Builtins



# 
# PREFIX : SC_, so declare -p can show them in a place
# 
# Generic : Global vaiables - readonly
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"


# Generic : Redefine pushd and popd to reduce their output messages
# 
function pushd() { builtin pushd "$@" > /dev/null; }
function popd()  { builtin popd  "$@" > /dev/null; }

function ini_func() { sleep 1; printf "\n>>>> You are entering in : %s\n" "${1}"; }
function end_func() { sleep 1; printf "\n<<<< You are leaving from %s\n"  "${1}"; }

function checkstr() {
    if [ -z "$1" ]; then
	printf "%s : input variable is not defined \n" "${FUNCNAME[*]}"
	exit 1;
    fi
}

# Generic : git_clone
# 1.0.3 Tuesday, November  8 18:13:44 CET 2016
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
	printf "Old git source repository in the expected location %s\n" "${git_src_dir}";
	printf "The old one is renamed to %s_%s\n" "${git_src_dir}" "${SC_LOGDATE}";
	mv  ${git_src_dir} ${git_src_dir}_${SC_LOGDATE}
    fi
    
    # Alwasy fresh cloning ..... in order to workaround any local 
    # modification in the repository, which was cloned before. 
    #
    # we need the recursive option in order to build a web based viewer for Archappl
    if [ -z "$tag_name" ]; then
	git clone --recursive "${git_src_url}/${git_src_name}" "${git_src_dir}";
    else
	git clone --recursive -b "${tag_name}" --single-branch --depth 1 "${git_src_url}/${git_src_name}" "${git_src_dir}";
    fi

    end_func ${func_name};
}


# Generic : git_selection
# - requirement : Global vairable : SC_SELECTED_GIT_SRC 
#
function git_selection() {

    local git_ckoutcmd=""
    local checked_git_src=""
    declare -i index=0
    declare -i master_index=0
    declare -i list_size=0
    declare -i selected_one=0
    declare -a git_src_list=()


    git_src_list+=("master")
    git_src_list+=($(git tag -l | sort -n))
    
    for tag in "${git_src_list[@]}"
    do
	printf "%2s: git src %34s\n" "$index" "$tag"
	let "index = $index + 1"
    done
    
    echo -n "Select master or one of tags which can be built, followed by [ENTER]:"

    # don't wait for 3 characters 
    # read -e -n 2 line
    read -e line
   
    # convert a string to an integer?
    # do I need this? 
    # selected_one=${line/.*}

    selected_one=${line}

    let "list_size = ${#git_src_list[@]} - 1"
    
    if [[ "$selected_one" -gt "$list_size" ]]; then
	printf "\n>>> Please select one number smaller than %s\n" "${list_size}"
	exit 1;
    fi
    if [[ "$selected_one" -lt 0 ]]; then
	printf "\n>>> Please select one number larger than 0\n" 
	exit 1;
    fi

    SC_SELECTED_GIT_SRC="$(tr -d ' ' <<< ${git_src_list[line]})"
    
    printf "\n>>> Selected %34s --- \n" "${SC_SELECTED_GIT_SRC}"
 
    echo ""
    if [ "$selected_one" -ne "$master_index" ]; then
	git_ckoutcmd="git checkout tags/${SC_SELECTED_GIT_SRC}"
	$git_ckoutcmd
	checked_git_src="$(git describe --exact-match --tags)"
	checked_git_src="$(tr -d ' ' <<< ${checked_git_src})"
	
	printf "\n>>> Selected : %s --- \n>>> Checkout : %s --- \n" "${SC_SELECTED_GIT_SRC}" "${checked_git_src}"
	
	if [ "${SC_SELECTED_GIT_SRC}" != "${checked_git_src}" ]; then
	    echo "Something is not right, please check your git reposiotry"
	    exit 1
	fi
    else
	git_ckoutcmd="git checkout ${SC_SELECTED_GIT_SRC}"
	$git_ckoutcmd
    fi

}

#
# Specific only for this script : Global vairables - readonly
#
declare -g ARCHAPPL_VERSION=""

function set_archappl_verion() {

    # master > master
    # tags   > selected tag
    #
    local archappl_build_ver=""
    
    # when it will be built
    #
    local archappl_build_date=""
    
    # Self Evidence
    #
    local archappl_git_hashver=""
    
    # Remove previx, v0.0.1_, because it will be added again due to build.xml 
    # 
    local prefix="v0.0.1_"

    archappl_build_ver=${SC_SELECTED_GIT_SRC#$prefix}
    archappl_build_date=${SC_LOGDATE}
    archappl_git_hashver="$(git rev-parse --short HEAD)"
    
    ARCHAPPL_VERSION="${archappl_build_ver}_H${archappl_git_hashver}_B${archappl_build_date}"
}


function archappl_setup() {
    
    local func_name=${FUNCNAME[*]}; ini_func ${func_name};

    local git_src_url=${AA_GIT_URL};
    local git_src_name=${AA_GIT_NAME};
    local git_src_dir=${SC_TOP}/${git_src_name};
    
    git_clone  "${git_src_dir}" "${git_src_url}" "${git_src_name}";

    pushd $git_src_dir;

    git_selection

    set_archappl_verion
    
    printf "\n>>>"
    printf "\n>>> Now, we are going to build the archappl with the following version name:\n"
    printf "\n>>> %s\n" "${ARCHAPPL_VERSION}"
    printf "\n>>>"
    # BUILDS_ALL_TIME is defined in build.xml in ${ARCHAPPL}
    #
    export BUILDS_ALL_TIME=${ARCHAPPL_VERSION}
    ant;
    popd;

    end_func ${func_name};
    
}


. ${SC_TOP}/setEnvAA.bash


archappl_setup 

