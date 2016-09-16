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
# Shell  : prior_aa.bash
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : 
# version : 0.1.0 
#
#  http://www.gnu.org/software/bash/manual/bashref.html#Bash-Builtins
#

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


function ini_func() { printf "\n>>>> You are entering in : %s\n" "${1}"; }
function end_func() { printf "<<<< You are leaving from %s\n" "${1}"; }

function checkstr() {
    if [ -z "$1" ]; then
	printf "%s : input variable is not defined \n" "${FUNCNAME[*]}"
	exit 1;
    fi
}

# Generic : Global variables for git_clone, git_selection, and others
# 
declare -g SC_SELECTED_GIT_SRC=""
declare -g SC_GIT_SRC_DIR=""
declare -g SC_GIT_SRC_NAME=""
declare -g SC_GIT_SRC_URL=""


# Generic : git_clone
#
# Required Global Variable
# - SC_GIT_SRC_DIR  : Input
# - SC_LOGDATE      : Input
# - SC_GIT_SRC_URL  : Input
# - SC_GIT_SRC_NAME : Input
# 
function git_clone() {

    local func_name=${FUNCNAME[*]}
    ini_func ${func_name}

    checkstr ${SC_LOGDATE}
    checkstr ${SC_GIT_SRC_URL}
    checkstr ${SC_GIT_SRC_NAME}
    
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

    end_func ${func_name}
}

# Generic : git_selection
#
# Require Global vairable
# - SC_SELECTED_GIT_SRC  : Output
#
function git_selection() {

    local func_name=${FUNCNAME[*]}
    ini_func ${func_name}
    
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
    end_func ${func_name}
 
}


#
# Specific only for this script : Global vairables - readonly
#
declare -gr SUDO_CMD="sudo"



# Specific : preparation
#
# Require Global vairable
# - SUDO_CMD :  input
# - 
# - allow this script to execute yum, and remove PakageKit
#
function preparation() {
    
    local func_name=${FUNCNAME[*]}
    ini_func ${func_name}

    checkstr ${SUDO_CMD}
    
    declare -r yum_pid="/var/run/yum.pid"

    # Somehow, yum is running due to PackageKit, so if so, kill it
    #
    if [[ -e ${yum_pid} ]]; then
	${SUDO_CMD} kill -9 $(cat ${yum_pid})
    fi	
    
    # Remove PackageKit
    #
    ${SUDO_CMD} yum -y remove PackageKit 

    end_func ${func_name}
}


#
# Enable and Start an input Service
# 
function system_ctl(){

    checkstr ${SUDO_CMD};
    checkstr ${1};
    ${SUDO_CMD} systemctl enable ${1}.service;
    ${SUDO_CMD} systemctl start ${1}.service;
    
}


function mariadb_setup() {

#    pass=${1};
    local func_name=${FUNCNAME[*]};
    ini_func ${func_name};
    
    mysql -u root <<EOF
-- UPDATE mysql.user SET Password=PASSWORD('$pass') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF
    end_func ${func_name}
    
}



#
# Prerequisite Packages
# * JAVA 1.8.0
# * MariaDB, Maven
# * TOMCAT
#

function yum_packages(){
    
    local func_name=${FUNCNAME[*]};
    ini_func ${func_name};
	
    checkstr ${SUDO_CMD};
    declare -a package_list=();
    package_list+="git emacs tree screen";
    package_list+=" ";
    package_list+="java-1.8.0-openjdk java-1.8.0-openjdk-devel";
    package_list+=" ";
    package_list+="mariadb-server mariadb-libs maven"
    package_list+=" ";
    package_list+="tomcat tomcat-webapps tomcat-admin-webapps apache-commons-daemon-jsvc tomcat-jsvc"
    
 
    echo  $package_list

    ${SUDO_CMD} yum -y install $package_list

    system_ctl "mariadb"
    system_ctl "tomcat"

    mariadb_setup;
 
    end_func ${func_name}
}





function yum_extra() {

    local func_name=${FUNCNAME[*]};
    ini_func ${func_name};
	
    checkstr ${SUDO_CMD};
    declare -a package_list=();

    package_list+="epel-release";
    package_list+=" ";
    package_list+="lightdm";

    echo  $package_list;

    ${SUDO_CMD} yum -y install $package_list
    ${SUDO_CMD} yum -y groupinstall "MATE Desktop"

    ${SUDO_CMD} systemctl disable gdm.service
    ${SUDO_CMD} systemctl enable lightdm.service
#    ${SUOD_CMD} systemctl isolate graphical.target

    ${SUDO_CMD} yum -y update
 
    end_func ${func_name}
}

${SUDO_CMD} -v

while [ true ];
do
    ${SUDO_CMD} -n /bin/true;
    sleep 60;
    kill -0 "$$" || exit;
done 2>/dev/null &


preparation

yum_packages;

yum_extra;


#
#
SC_GIT_SRC_NAME="mariadb-connector-j";
SC_GIT_SRC_URL="https://github.com/MariaDB/";
SC_GIT_SRC_DIR=${SC_TOP}/${SC_GIT_SRC_NAME};
#

#
git_clone
#
#
pushd ${SC_GIT_SRC_DIR}
# 
# 
git_selection
# 
# 
ini_func "Compiling mariadb-connector-j"
mvn -Dmaven.test.skip=true package
end_func "Compiling mariadb-connector-j"
# end_func "Ansible Playbook"
# 
#
popd
# #
# #
# yum_extra
# #
exit

