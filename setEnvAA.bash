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

export TOMCAT_HOME=/usr/share/tomcat
export CATALINA_HOME=${TOMCAT_HOME}


# preAA.bash, aaBuild.bash
#
export EPICS_BASE=${HOME}/epics/3.15.4/base
export EPICS_HOST_ARCH=linux-x86_64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${EPICS_BASE}/lib/${EPICS_HOST_ARCH}


export AA_TARGET_TOP=/opt
export ARCHAPPL_TOP=${AA_TARGET_TOP}/archappl

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
