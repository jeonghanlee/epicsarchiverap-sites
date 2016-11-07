#!/bin/bash
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
# version : 0.1.0 

declare -gr THIS_SCRIPT="$(realpath "$0")"
declare -gr THIS_TOP="$(dirname "$THIS_SCRIPT")"

# preAA.bash, aaBuild.bash, aaService.bash
#
export TOMCAT_HOME=/usr/share/tomcat

# We assume that we inherit the EPICS environment variables 
# This includes setting up the LD_LIBRARY_PATH to include the JCA .so file.
# EPICS BASE is installed in the local directory

export EPICS_BASE_VER="R3.15.4";
export EPICS_BASE=${HOME}/epics/${EPICS_BASE_VER}
export EPICS_HOST_ARCH=linux-x86_64

# LD_LIBRARY_PATH should have the EPICS and Tomcat libs 
export LD_LIBRARY_PATH=${TOMCAT_HOME}/lib:${EPICS_BASE}/lib/${EPICS_HOST_ARCH}:${LD_LIBRARY_PATH}


export AA_GIT_URL="https://github.com/slacmshankar";
export AA_GIT_NAME="epicsarchiverap";
export AA_GIT_DIR=${THIS_TOP}/${AA_GIT_NAME};

# aaSetup, aaService
export AA_TARGET_TOP=/opt
export ARCHAPPL_TOP=${AA_TARGET_TOP}/archappl

#
# This approach is only valid for the single appliance installation.
# If one wants to install multiple appliances, appliances.xml should
# has the different structures. 
#
export AACHAPPL_SINGLE_IDENTITY="appliance0"

# The following variables are defined in archappl.
# Do not change other names
export ARCHAPPL_APPLIANCES=${ARCHAPPL_TOP}/appliances.xml
export ARCHAPPL_MYIDENTITY=${AACHAPPL_SINGLE_IDENTITY}



# Hostname is not reiable to use it in the appliances.xml, so force to get the running
# IP, and use it into... need to change them by other demands

declare hostname_cmd="$(hostname)"
export  _HOST_NAME="$(tr -d ' ' <<< $hostname_cmd )"
export  _HOST_IP="$(ping -n  -c 1 ${_HOST_NAME} | awk 'BEGIN {FS="[=]|[ ]"} NR==2 {print $4}' | cut -d: -f1)";
export  _USER_NAME="$(whoami)"



# Archiever Appliance User and Password for DB
# One should change the the default AA user password properly. 
export DB_USER_NAME="archappl";
export DB_USER_PWD="archappl";
export DB_NAME="archappl";

export DB_JAVACLIENT_VER="1.5.4";
export DB_CLASSNAME="org.mariadb.jdbc.Driver"
export DB_AA_URL="mariadb"

# For MySQL, 
#export DB_CLASSNAME="com.mysql.jdbc.Driver"
#export DB_AA_URL="mysql"




#
# Set Path for apache-commons-daemon.jar, because I use the CentOS packages 
# apache-commons-daemon.x86_64 and apache-commons-daemon-jsvc.x86_64
# Somehow jsvc doesn't know where apache-commons-daemon.jar. So the clear PATH
# should be defined.
#

export CLASS_PATH=/usr/share/java


#
# The original options are
# 
# export JAVA_OPTS="-XX:MaxPermSize=128M -XX:+UseG1GC -Xmx4G -Xms4G -ea"
#
#  -XX:MaxPermSize=size  This option was deprecated in JDK 8, 
#   and superseded by the -XX:MaxMetaspaceSize option.
#

# The physical memory  :  64G, so I use 8G instead of 4G, since we don't have any other application on the server.
# Set MaxMetaspaceSize : 256M, so it reduces the GC execution to compare with the original option.
# 
export JAVA_HEAPSIZE="4G"
export JAVA_MAXMETASPACE="256M"
export JAVA_OPTS="-XX:MaxMetaspaceSize=${JAVA_MAXMETASPACE} -XX:+UseG1GC -Xms${JAVA_HEAPSIZE} -Xmx${JAVA_HEAPSIZE} -ea"



# It might be better to assign the proper directory, while the installating CentOS.
# Anyway, /home has the most of space, so I created
# Make tmpfs for the short term storage by editing /etc/fstab file.
#  For 10G file size add this line: 
# tmpfs    /srv/sts 		tmpfs 	defaults,size=10g 0 0 
# preAA.bash 
# aaService.bash

declare ARCHAPPL_STORAGE_TOP=/home/arch
#
# Set the location of short term and long term stores; this is necessary only if your policy demands it
export ARCHAPPL_SHORT_TERM_FOLDER=${ARCHAPPL_STORAGE_TOP}/sts/ArchiverStore
export ARCHAPPL_MEDIUM_TERM_FOLDER=${ARCHAPPL_STORAGE_TOP}/mts/ArchiverStore
export ARCHAPPL_LONG_TERM_FOLDER=${ARCHAPPL_STORAGE_TOP}/lts/ArchiverStore

