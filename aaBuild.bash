#!/bin/bash
#
# 
# Shell  : aaBuild.bash
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.9.0 CentOS 7.2
#

# Generic : Reusable Variables
#
SCRIPT="$(realpath "$0")"
SCRIPTNAME="$(basename "$SCRIPT")"
TOP="$(dirname "$SCRIPT")"
LOGDATE="$(date +%F-%H%M%Z)"



# Specific : Global Variable for this script
# 
ARCHAPPL="epicsarchiverap"
ARCHAPPL_SRC=
SELECTED_GIT_SRC=""

# Generic : Redefine pushd and popd to reduce their output messages
# 
function pushd() { builtin pushd "$@" > /dev/null; }
function popd()  { builtin popd  "$@" > /dev/null; }



# Generic : git_selection
# - requirement : Global vairable : SELECTED_GIT_SRC 
#
function git_selection() {

    local git_ckoutcmd=""
    local checked_git_src=""
    local index=0
    local master_index=0
    local list_size=0
    local git_src_list=()

    git_src_list+=("master")
    git_src_list+=($(git tag -l | sort -n))
    
    for tag in "${git_src_list[@]}"
    do
	printf "%2s: git src %34s\n" "$index" "$tag"
	let "index = $index + 1"
    done
    
    echo -n "Select master or one of tags which can be built: "
    
    read -e line

 
    let "list_size = ${#git_src_list[@]} - 1"
    
    if [[ "$line" -gt "${list_size}" ]]; then
	printf "\n>>> Please select one number smaller than %s\n" "${list_size}"
	exit 1;
    fi
    if [[ "$line" -lt "0" ]]; then
	printf "\n>>> Please select one number larger than 0\n" 
	exit 1;
    fi

    SELECTED_GIT_SRC="$(tr -d ' ' <<< ${git_src_list[line]})"
    
    printf "\n>>> Selected %34s --- \n" "${SELECTED_GIT_SRC}"
 
    echo ""
    if [ "$line" -ne "$master_index" ]; then
	git_ckoutcmd="git checkout tags/${SELECTED_GIT_SRC}"
	$git_ckoutcmd
	checked_git_src="$(git describe --exact-match --tags)"
	checked_git_src="$(tr -d ' ' <<< ${checked_git_src})"
	
	printf "\n>>> Select   : %s --- \n>>> Checkout : %s --- \n" "${SELECTED_GIT_SRC}" "${checked_git_src}"
	
	if [ "${SELECTED_GIT_SRC}" != "${checked_git_src}" ]; then
	    echo "Something is not right, please check your git reposiotry"
	    exit 1
	fi
    else
	git_ckoutcmd="git checkout ${SELECTED_GIT_SRC}"
	$git_ckoutcmd
    fi

}

ARCHAPPL_SRC=${TOP}/${ARCHAPPL}

if [[ ! -d ${ARCHAPPL_SRC} ]]; then
    echo "No Archappl source repository in the expected location"
else
    echo "Old Archappl source repository in the expected location"
    echo "The old one is renamed to ${ARCHAPPL_SRC}_${LOGDATE}"
    mv  ${ARCHAPPL_SRC} ${ARCHAPPL_SRC}_${LOGDATE}
fi

# Alwasy fresh cloning ..... in order to workaround any local 
# modification in main repository 
#
git clone https://github.com/slacmshankar/${ARCHAPPL}


pushd ${ARCHAPPL_SRC}

# final version for tracking
#
archappl_version=""

# Self Evidence
#
archappl_git_hashver=""

# master > master
# tags   > selected tag
#
archappl_build_ver=""

# when it will be built
#
archappl_build_date=""

# Select one archappl version
#
git_selection

# Remove previx, v0.0.1_, because it will be added again due to build.xml 
# 
prefix="v0.0.1_"
archappl_build_ver=${SELECTED_GIT_SRC#$prefix}
archappl_build_date=${LOGDATE}
archappl_git_hashver=`git rev-parse --short HEAD`

archappl_version="${archappl_build_ver}_H_${archappl_git_hashver}_B_${archappl_build_date}"

# BUILDS_ALL_TIME is defined in build.xml in ${ARCHAPPL}
#
export BUILDS_ALL_TIME=${archappl_version}

# Should be changed according to a system
#
export TOMCAT_HOME=/usr/share/tomcat

printf "\n>>>"
printf "\n>>> Now, we are going to build the archappl with the following version name:\n"
printf "\n>>> %s\n" "${archappl_version}"
printf "\n>>>"

# build

ant

popd
