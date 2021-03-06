#!/bin/bash
#
#  Copyright (c) 2016 - Present Jeong Han Lee
#  Copyright (c) 2016 - Present European Spallation Source ERIC
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
# Date   : Saturday, April  1 22:45:45 CEST 2017
# version : 0.2.3
#
declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"

. ${SC_TOP}/functions

declare -gr SUDO_CMD="sudo";


# The following explaination doesn't work properly. So, I commented out
#
# No way to keep the sudo permission without injecting an user ALL permission
# in /etc/sudoers.d/ in CentOS.
# However, after all setup is done, I would like to delete the injected permission.
# Unfornately, in CentOS, that directory permission is 750. So, it should be the
# sudo permission again, which will prompt sudo password again after the whole
# procedure is done.
# In Debian 8 (Jessie), that directory permission is 755. So, in sudo_start
# I changed it 755, and will use the permission 755 after that.
# Saturday, December 31 00:21:44 CET 2016, jhlee

# So, _USER_NAME sudo permission has -1 timestamp_timeout. Then the user's time stamp will
# not expire until the system is rebooted. This can be used to allow users to create or
# delete their own time stamps via “sudo -v” and “sudo -k” respectively.
# Saturday, December 31 14:27:14 CET 2016, jhlee

function sudo_start() {

    # disable lock-screen
    gsettings set org.gnome.desktop.lockdown disable-lock-screen true

    #    local user_sudoer="${_USER_NAME} ALL=(ALL) NOPASSWD: ALL"
    #    ${SUDO_CMD} chmod 755 /etc/sudoers.d;
    #    /etc/sudoers.d/arch should not be replaced with a variable
    #    echo "${user_sudoer}" | ${SUDO_CMD} sh -c 'EDITOR="tee" visudo -f /etc/sudoers.d/arch'

    local timeout_sudoer="Defaults:${_USER_NAME} timestamp_timeout=-1"
    echo "${timeout_sudoer}" | ${SUDO_CMD} sh -c 'EDITOR="tee" visudo -f /etc/sudoers.d/arch'

    
    # create ${_USER_NANE}'s time stamps of sudo. 
    ${SUDO_CMD} -v;

    __cleanup&
}


function sudo_end () {
    # enable lock-screen
    gsettings set org.gnome.desktop.lockdown disable-lock-screen false;

    # an user can delete that file
    #rm -f /etc/sudoers.d/arch;

    # delete ${_USER_NANE}'s time stamps of sudo.
    ${SUDO_CMD} -K;
    exit
}

# https://en.wikipedia.org/wiki/Unix_signal

# 1  : SIGHUP
# 2  : SIGINT
# 9  : SIGKILL
# 15 : SIGTERM
#

# If the following signals are, enable lock-screen and delete the injected sudo permission
#
trap sudo_end EXIT SIGINT SIGTERM


function __cleanup() {
    while [ true ]; do
	sleep 30;
	kill -0 "$$" || sudo_end;
    done 2>/dev/null
}

# Specific : preparation
#
# 1.0.1 Wednesday, November  9 09:56:52 CET 2016
#
# Require Global variable
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
    __checkstr ${SUDO_CMD}; __checkstr ${1};

    printf "Enable and Start the following service(s) : %s\n" "${1}";
    
    ${SUDO_CMD} systemctl enable ${1}.service;
    ${SUDO_CMD} systemctl start ${1}.service;

    __end_func ${func_name};
}

function __system_ctl_stop_disable(){
    
    local func_name=${FUNCNAME[*]};  __ini_func ${func_name};

    printf "Stop and Disable the following service(s) : %s\n" "${1}";

    ${SUDO_CMD} systemctl stop ${1}.service;
    ${SUDO_CMD} systemctl disable ${1}.service;

    __end_func ${func_name};
}



function mariadb_setup() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    
    # MariaDB Secure Installation without MariaDB root password
    # the same as mysql_secure_installation, but skip to setup
    # the root password in the script. The reference of the sql commands
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

    printf "Create the Database %s if not exists...\n" "${DB_NAME}";

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
    
    ${SUDO_CMD} cp -v  target/${MARIADB_CONNECTORJ_JAR} ${TOMCAT_LIB}
    
    # Symbolic link should be created early
    # ln -sf ${TOMCAT_HOME}/${MARIADB_CONNECTORJ_JAR} ${TOMCAT_LIB}/${MARIADB_CONNECTORJ_JAR}
    #"cp -v target/${MARIADB_CONNECTORJ_JAR} ${TOMCAT_HOME}"
    
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
    package_list+="java-1.8.0-openjdk java-1.8.0-openjdk-devel ant";
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

    

    # ${SUDO_CMD} usermod -a -G ${tomcat_group} ${_USER_NAME};
    # ${SUDO_CMD} ln -sf ${TOMCAT_HOME}/${MARIADB_CONNECTORJ_JAR} ${TOMCAT_LIB}/${MARIADB_CONNECTORJ_JAR}
    
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


# To understand firewalld service in CentOS is painful. And ESS has the clear rule in the control network.
# Thus, I stop and disable firewalld now. 
# Saturday, April  1 22:42:55 CEST 2017, jhlee


function disable_firewalld() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

     __system_ctl_stop_disable "firewalld"
    
    __end_func ${func_name};
}


function disable_selinux() {
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    __end_func ${func_name};
}

#
#
#

checkIfArchappl;

declare EPICS_LOG=${SC_TOP}/epics.log;

. ${SC_TOP}/setEnvAA.bash

sudo_start;

# root
preparation;

# root
packages_preparation_for_archappl;

disable_firewalld;

# an user
printf "EPICS Base installation is ongoing in background process\n";
printf "The installation log is %s\n" "${EPICS_LOG}";

( epics_setup&>${EPICS_LOG})&
epics_proc=$!
nice xterm -title "EPICS Installation Status" -geometry 140x15+0+0  -e "nice watch -n 2 tail -n 10 ${EPICS_LOG}"&


mariadb_setup;

disable_virbro0;


printf "\nMariaDB Setup is done. And the option %s is selected \n" "$1";
printf "Before going further, we should wait for EPICS Base installation\n";
printf "The log file is shown in %s\n" "${EPICS_LOG}" ;

wait "$epics_proc"

if [ -z "$1" ]; then
    printf "%s : No option is selected. Exiting ... \n"
    exit;
fi

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
	printf "Not support yet.\n";
	;;
esac

exit


