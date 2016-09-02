#!/bin/bash
#
# 
# Shell  : aaBuild.bash
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.9.0 CentOS 7.2
#
SCRIPT=`realpath $0`
SCRIPTNAME=`basename $SCRIPT`
SCRIPTPATH=`dirname $SCRIPT`
LOGDATE=`date +%F-%H%M%Z`

ARCHAPPL_SRC=

# echo $SCRIPT
# echo $SCRIPTNAME
# echo $SCRIPTPATH

# # Redefine pushd and popd to reduce their output messages
# #
pushd() { builtin pushd "$@" > /dev/null; }
popd()  { builtin popd  "$@" > /dev/null; }


GIT_CKOUTCMD=""

ARCHAPPL_SRC=${SCRIPTPATH}/epicsarchiverap

if [[ ! -d ${ARCHAPPL_SRC} ]]
then
    echo "No Archappl source repository in the expected location"
    git clone https://github.com/slacmshankar/epicsarchiverap
fi

pushd ${ARCHAPPL_SRC}

archappl_version=""
# final version for tracking

archappl_git_hashver=""
# self evidence

archappl_build_ver=""
# master -> master
# tags   -> selected tag
 
archappl_build_date=""
# when it is built.


archappl_src_list=()

archappl_src_list+=("master")

archappl_src_list+=($(git tag -l | sort -n))

index=0
for tag in "${archappl_src_list[@]}"
do
    printf "%2s: git src %34s\n" "$index" "$tag"
    let "index = $index + 1"
done


echo -n "Select master or one of tags which can be built: "

read -e line

selected_git_src=${archappl_src_list[line]}
echo $selected_git_src
echo ""
if [ $line='0' ];
then
    GIT_CKOUTCMD="git checkout ${selected_git_src}"
else
    GIT_CKOUTCMD="git checkout tags/${selected_git_src}"
    checked_git_tag=`git describe --tags`
    archappl_
    if [ "$selected_git_src" != "$checked_git_tag" ]
    then
	echo $selected_git_src
	echo $checked_git_tag
	echo "Something is not right, please check your git reposiotry"
	exit 1
    fi    
fi

# Remove v0.0.1_ 

prefix="v0.0.1_"
archappl_build_ver=${selected_git_src#$prefix}
archappl_build_date=${LOGDATE}
archappl_git_hashver=`git rev-parse --short HEAD`

archappl_version="${archappl_build_ver}_H_${archappl_git_hashver}_B_${archappl_build_date}"
export BUILDS_ALL_TIME=${archappl_version}
export TOMCAT_HOME=/usr/share/tomcat

echo ${archappl_version}

ant

popd
