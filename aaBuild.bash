#!/bin/bash
#
# 
# Shell  : aaBuild.bash
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.9.2 for CentOS 7.2
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


# Generic : Global variables for git_clone, git_selection, and others
# 
declare -g SC_SELECTED_GIT_SRC=""
declare -g SC_GIT_SRC_DIR=""
declare -g SC_GIT_SRC_NAME=""
declare -g SC_GIT_SRC_URL=""


# Generic : git_clone
#
#
function git_clone() {

    SC_GIT_SRC_DIR=${SC_TOP}/${SC_GIT_SRC_NAME}
    
    if [[ ! -d ${SC_GIT_SRC_DIR} ]]; then
	echo "No git source repository in the expected location ${SC_GIT_SRC_DIR}"
    else
	echo "Old git source repository in the expected location ${SC_GIT_SRC_DIR}"
	echo "The old one is renamed to ${SC_GIT_SRC_DIR}_${SC_LOGDATE}"
	mv  ${SC_GIT_SRC_DIR} ${SC_GIT_SRC_DIR}_${SC_LOGDATE}
    fi
    
    # Alwasy fresh cloning ..... in order to workaround any local 
    # modification in the repository, which was cloned before. 
    #
    git clone ${SC_GIT_SRC_URL}/${SC_GIT_SRC_NAME}

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

#
#
SC_GIT_SRC_NAME="epicsarchiverap"
SC_GIT_SRC_URL="https://github.com/slacmshankar"

#
#
git_clone

#
#
pushd ${SC_GIT_SRC_DIR}
#
#
git_selection

set_archappl_verion


# BUILDS_ALL_TIME is defined in build.xml in ${ARCHAPPL}
#
export BUILDS_ALL_TIME=${ARCHAPPL_VERSION}

# Should be changed according to a system
#
export TOMCAT_HOME=/usr/share/tomcat

printf "\n>>>"
printf "\n>>> Now, we are going to build the archappl with the following version name:\n"
printf "\n>>> %s\n" "${ARCHAPPL_VERSION}"
printf "\n>>>"

# build

ant

popd
