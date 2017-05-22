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
# Date   : Saturday, December 31 17:39:22 CET 2016
# version : 0.9.4
#

# http://www.gnu.org/software/bash/manual/bashref.html#Bash-Builtins

# 
# PREFIX : SC_, so declare -p can show them in a place
# 
# Generic : Global variables - read-only
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"


set -a
. ${SC_TOP}/env.conf
set +a


. ${SC_TOP}/functions



#
# Specific only for this script : Global variables - read-only
#
declare -g ARCHAPPL_VERSION=""

function set_archappl_version() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local git_src_name=${AA_GIT_NAME};
    local git_src_dir=${SC_TOP}/${git_src_name};

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
    
    # Remove prefix, v0.0.1_, because it will be added again due to build.xml 
    # 
    local prefix="v0.0.1_"

    local develop="$1";

    pushd $git_src_dir;

    archappl_build_ver=${SC_SELECTED_GIT_SRC#$prefix}
    archappl_build_date=${SC_LOGDATE}
    archappl_git_hashver="$(git rev-parse --short HEAD)"
    
    ARCHAPPL_VERSION="${archappl_build_ver}_H${archappl_git_hashver}_B${archappl_build_date}_T${develop}"

    popd;

    __end_func ${func_name};

}


function archappl_setup() {
    
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local git_src_url=${AA_GIT_URL};
    local git_src_name=${AA_GIT_NAME};
    local git_src_dir=${SC_TOP}/${git_src_name};
    
    git_clone  "${git_src_dir}" "${git_src_url}" "${git_src_name}";

    pushd $git_src_dir;
    git_selection
    popd;

    __end_func ${func_name};
    
}


function archappl_build() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local git_src_name=${AA_GIT_NAME};
    local git_src_dir=${SC_TOP}/${git_src_name};

    printf "\n>>>"
    printf "\n>>> Now, we are going to build the archappl with the following version name:\n"
    printf "\n>>> %s\n" "${ARCHAPPL_VERSION}"
    printf "\n>>>"
    # BUILDS_ALL_TIME is defined in build.xml in ${ARCHAPPL}
    #

    export BUILDS_ALL_TIME=${ARCHAPPL_VERSION}

    pushd $git_src_dir;
    ant $1;
    popd;

    __end_func ${func_name};

}


# Nothing defined, the normal procedure is started
if [ -z "$1" ]; then

    archappl_setup
    set_archappl_version
    archappl_build

else
# Something else...
    case "$1" in
	loc)
	    set_archappl_version "$1"
	    archappl_build "clean"
	    archappl_build
	    ;;
	*)
	    printf "Not support yet.\n";
    esac
fi

exit;

