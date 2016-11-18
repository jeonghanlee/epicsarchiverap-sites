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
# Date   : 
# version : 0.2.2-rc2
#
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

function __ini_func() { printf "\n>>>> You are entering in  : %s\n" "${1}"; }
function __end_func() { printf "\n<<<< You are leaving from : %s\n" "${1}"; }

function __checkstr() {
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
    
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    
    local git_src_dir=$1;
    local git_src_url=$2;
    local git_src_name=$3;
    local tag_name=$4;
    
    __checkstr ${SC_LOGDATE};
    
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

    __end_func ${func_name};
}



declare -gr SUDO_CMD="sudo";
declare -g SUDO_PID="";


function sudo_start() {
   ${SUDO_CMD} -v;
   ( while [ true ]; do
     	  ${SUDO_CMD} -n /bin/true;
     	  sleep 60;
     	  kill -0 "$$" || exit;
     done 2>/dev/null
   )&
}


# Specific : preparation
#
# 1.0.1 Wednesday, November  9 09:56:52 CET 2016
#
# Require Global vairable
# - SUDO_CMD :  input
# - 
# - allow this script to execute yum, and remove PakageKit
#
function preparation() {
    
    local func_name=${FUNCNAME[*]};  __ini_func ${func_name};
    __checkstr ${SUDO_CMD};

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
    declare -a package_list=();

    # ntp
    package_list+="epel-release git tree"
    package_list+=" ";
    package_list+="screen xterm xorg-x11-fonts-misc";
    package_list+=" ";
    
    ${SUDO_CMD} yum -y install ${package_list};
	
    __end_func ${func_name};
}


#
# Enable and Start an input Service
# 
# Even if the service is active (running), it is OK to run "enable and start" again. 
# systemctl can accept many services with one command

function __system_ctl_enable_start(){
    
    local func_name=${FUNCNAME[*]};  __ini_func ${func_name};
    __checkstr ${SUDO_CMD}; checkstr ${1};

    printf "Enable and Start the following service(s) : %s\n" "${1}";
    
    ${SUDO_CMD} systemctl enable ${1}.service;
    ${SUDO_CMD} systemctl start ${1}.service;

    __end_func ${func_name};
}



function mariadb_setup() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

 
    # MariaDB Secure Installation without MariaDB root password
    # the same as mysql_secure_installation, but skip to setup
    # the root password in the script. The referece of the sql commands
    # is https://goo.gl/DnyijD
 
 
    printf "Setup mysql_secure_installation...\n";
    
    # UPDATE mysql.user SET Password=PASSWORD('$passwd') WHERE User='root';
    
    mysql -u root <<EOF
-- DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

    printf "Creat the Database %s if not exists...\n" "${DB_NAME}";

    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME}; GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER_NAME}'@'localhost' IDENTIFIED BY '${DB_USER_PWD}';
EOF
    
#    local jar_client_name="mariadb-java-client";
#    local mariadb_connectorj_jar="${jar_client_name}-${DB_JAVACLIENT_VER}.jar";
    
    # local maven_jar_url="http://central.maven.org/maven2/org/mariadb/jdbc";
    # # http://central.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/1.5.4/mariadb-java-client-1.5.4.jar
    
    # ${SUDO_CMD} wget -c -P ${TOMCAT_HOME}/lib ${maven_jar_url}/${jar_client_name}/${DB_JAVACLIENT_VER}/${mariadb_connectorj_jar};
    
    printf "Cloning the mariadb-connector-j... \n".
    
    local git_src_url="https://github.com/MariaDB/";
    local git_src_name="mariadb-connector-j";
    local git_src_dir=${SC_TOP}/${git_src_name};

    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${DB_JAVACLIENT_VER}" ; 

    pushd $git_src_dir;
    printf "Compiling mariadb-connector-j ... \n";
    # Skip javadoc and source jar files to save time...
    mvn -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -Dmaven.source.skip=true package;

    printf "Moving the java client to %s/lib\n\n\n" "${TOMCAT_LIB}"
	
    #    ${SUDO_CMD} cp -v  target/${MARIADB_CONNECTORJ_JAR} ${TOMCAT_LIB}
    # Symbolic link should be created early
    # ln -sf ${TOMCAT_HOME}/${MARIADB_CONNECTORJ_JAR} ${TOMCAT_LIB}/${MARIADB_CONNECTORJ_JAR}
    cp -v target/${MARIADB_CONNECTORJ_JAR} ${TOMCAT_HOME}
    popd;
    
    __end_func ${func_name};
}



function epics_setup(){

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local git_src_url="https://github.com/epics-base/";
    local git_src_name="epics-base";
    local git_src_dir=${EPICS_BASE};
    
    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${EPICS_BASE_VER}";

    pushd $git_src_dir;
    printf "Compiling EPICS base %s ... \n" "${EPICS_BASE_VER}";
    nice make
    popd;
    
    __end_func ${func_name};
}


function packages_preparation_for_archappl(){
    
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    __checkstr ${SUDO_CMD};

    declare -a package_list=();

    # ntp
    package_list+="ntp"
    package_list+=" ";

    # Basic package list 
    package_list+="emacs telnet";
    package_list+=" ";

    # JAVA
    package_list+="java-1.8.0-openjdk java-1.8.0-openjdk-devel";
    package_list+=" ";
    # MariaDB
    package_list+="mariadb-server mariadb-libs maven"
    package_list+=" ";
    # Tomcat
    package_list+="tomcat tomcat-webapps tomcat-admin-webapps apache-commons-daemon-jsvc tomcat-jsvc tomcat-lib unzip"
    package_list+=" ";
        
    # EPICS Base
    package_list+="readline-devel libXt-devel libXp-devel libXmu-devel libXpm-devel lesstif-devel gcc-c++ ncurses-devel perl-devel";
    package_list+=" ";
    package_list+="net-snmp net-snmp-utils net-snmp-devel darcs libxml2-devel libpng12-devel netcdf-devel hdf5-devel lbzip2-utils libusb-devel python-devel";
    
    ${SUDO_CMD} yum -y install ${package_list};
  
    # Even if the service is active (running), it is OK to run "enable and start" again. 
    # systemctl can accept many services with one command

    __system_ctl_enable_start "ntpd mariadb tomcat"

    __reload_user_group;
    
    ${SUDO_CMD} ln -sf ${TOMCAT_HOME}/${MARIADB_CONNECTORJ_JAR} ${TOMCAT_LIB}/${MARIADB_CONNECTORJ_JAR}
    
    __end_func ${func_name};
}

function __reload_user_group() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    __checkstr ${SUDO_CMD};

    local tomcat_group="tomcat";
    local current_primary_group=$(id -gn)
    local temp_primary_group="";

    ${SUDO_CMD} usermod -a -G ${tomcat_group} ${_USER_NAME};
    
    newgrp ${tomcat_group};

    temp_primary_group=$(id -gn);

    if test "${temp_primary_group}" != "${tomcat_group}"; then
	printf "Changing group is wrong, exit...\n"
	exit;
    done

    newgrp ${current_primary_group};

    printf "The user %s is in the %s group without logout.\n" "${_USER_NAME}" "${temp_primary_group}"
    
    __end_func ${func_name};
}

function replace_gnome_with_mate() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    __checkstr ${SUDO_CMD};
    
    ${SUDO_CMD} yum -y install lightdm
    ${SUDO_CMD} yum -y groupinstall "MATE Desktop"

    ${SUDO_CMD} systemctl disable gdm.service
    ${SUDO_CMD} systemctl enable lightdm.service

    __end_func ${func_name}
}

function prepare_storage() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    __checkstr ${SUDO_CMD};
    
    printf "Make STS/MTS/LTS dirs at ARCHAPPL_STORAGE_TOP as %s\n\n---\n" "${ARCHAPPL_STORAGE_TOP}";

    ${SUDO_CMD} mkdir -p {${ARCHAPPL_SHORT_TERM_FOLDER},${ARCHAPPL_MEDIUM_TERM_FOLDER},${ARCHAPPL_LONG_TERM_FOLDER}};

    tree  -L 2 ${ARCHAPPL_STORAGE_TOP};

    __end_func ${func_name};
}

function disable_virbro0() {
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    __checkstr ${SUDO_CMD};
    
    # Do we need virbr0?
    # Default I would like to remove it
    # The virbr0, or "Virtual Bridge 0" interface is used for NAT (Network Address Translation). 
    ${SUDO_CMD} ifconfig virbr0 down 
    ${SUDO_CMD} brctl delbr virbr0

    __end_func ${func_name};
}

    

function firewall_setup_for_ca() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    __end_func ${func_name};
}



#
#
#

declare EPICS_LOG=${SC_TOP}/epics.log;

#sudo_start;

( while [ true ]; do
      ${SUDO_CMD} -n /bin/true;
      sleep 60;
      kill -0 "$$" || exit;
  done 2>/dev/null
)&

. ${SC_TOP}/setEnvAA.bash

# root
preparation;
prepare_storage;

# root
packages_preparation_for_archappl;

# an user
printf "EPICS Base installation is ongoing in background process\n";
printf "The installation log is %s\n" "${EPICS_LOG}";
( epics_setup&>${EPICS_LOG})&
epics_proc=$!

nice xterm -title "EPICS Installation Status" -geometry 140x15+0+0  -e "nice watch -n 2 tail -n 10 ${EPICS_LOG}"&

mariadb_setup

disable_virbro0

printf "\nMariaDB Setup is done, However, \n";
printf "EPICS Base installation are ongoing in background process\n";
printf "The installation log is %s\n" "${SC_TOP}/epics.log" ;

wait "$epics_proc"

case "$1" in
    mate)
	printf "Mate and lightdm are selected\n";
	replace_gnome_with_mate;
	;;
    update)
	printf "yum update is selected\n";
	${SUDO_CMD} yum -y update;
	;;
    all)
	printf "Mate,lightdm are yum update are selected.\n"; 
	replace_gnome_with_mate;
	${SUDO_CMD} yum -y update;
	;;
    *)
	;;
esac

exit


