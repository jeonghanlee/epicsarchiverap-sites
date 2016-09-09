Pilot Project for a site-specific (ESS) EPICS Archiver Appliance Deployment
=================

# Purpose

* To develop a way to deploy a site-specific Archiver Appliance (archappl)
* To build the workflow to deploy the site-specific archappl 

# Goal

* This environment should work with any branches and any tags with git clone from https://github.com/slacmshankar/epicsarchiverap
* This environment should work with any releases tar.gz files from https://github.com/slacmshankar/epicsarchiverap/releases
* This environment should change local version of archappl easily.
* This environment should provide an engineering manual for a site specific archappl deployment.

# Requirements

* JAVA JDK 8
* TOMCAT
* MySQL or MariaDB
* Apache Common Daemon
* Storage Directories {sts,mts,lts}
* EPICS Base 
* git
* ant

# License

* All works done by the original Archiver Appliance follows its original Licenses. Please check them in
https://github.com/slacmshankar/epicsarchiverap/blob/master/NOTICE
* Makefile, to build any documents, follows its original License also. Please check it in  http://www.bouncingchairs.net/oss
* In addition, The works in this repository can be distributed under the GPL-2 license.

# Things to know

## aaBuild.bash 
* allow an user to select a master or one of git tags 
* TOMCAT_HOME : hard-coded and /usr/share/tomcat of the CentOS 7 package, should be replaced with your own environment
* archappl_version : ${archappl_build_ver}_H_${archappl_git_hashver}_B_${archappl_build_date}
* archappl_git_hashver : git rev-parse --short HEAD (in order to track the main git repository)
* archappl_build_ver   : master or selected tag (in order to track an user's selection)
* acrchapp_build_date  : date (in order to track when it is compiled)
* BUILDS_ALL_TIME : use it as a container of ${archappl_version}

## aaSetup.bash
* This approach is only valid for the single appliance installation.
* TOMCAT_HOME : hard-coded and /usr/share/tomcat of the CentOS 7 package, should be replaced with your own environment
* JAVA_HOME : one should define it within the system-wide environment. 
* TARGET_DIR : the current archappl directory, and it is a symlink. It is always /opt/archappl 
* DEPLOY_DIR : the physical director of TARGET_DIR, e.g., /opt/archappl-2016-09-01-1336CEST
* AA_DRIVER_CLASSNAME : hard-coded. It should be changed properly according to MariaDB or MySQL
* AA_URL :  hard-coded. It should be changed properly according to MariaDB or MySQL
* MySQL password is the default one. One should use the different one, and should match ones SQL configuration.
* The original deployMultipleTomcats.py script is used for the actual deployment.   

## deployRelease.bash
* JAVA_HOME : one should define it within the system-wide environment.
* TOMCAT_HOME : hard-coded and /usr/share/tomcat of the CentOS 7 package, should be replaced with your own environment
* DEPLOY_DIR : /opt/archappl 


## aaService.bash
* EPICS Base is configured properly, in order to access  the JCA .so files. 
* JAVA_HOME : one should define it within the system-wide environment. 
* JAVA_HEAPSIZE : should be adjusted according to the target system, which one wants to install archappl.
* JAVA_MAXMETASPACE :  should be adjusted according to the target system.
* TOMCAT_HOME : hard-coded and /usr/share/tomcat for the CentOS 7, should be replaced with your own environment
* CLASS_PATH :  hard-coded and /usr/share/java forthe CentOS 7, it should be matched with the PATH where apache-commons-daemon.jar should be. (needed to check this path with Debain 8)

# Commands

* Only Command List
```
aauser@:~$ git clone https://github.com/jeonghanlee/epicsarchiverap-sites.git
aauser@:~$ cd epicsarchiverap-sites/
aauser@:~/epicsarchiverap-sites (master)$ bash aaBuild.bash 
 0: git src                             master
 1: git src   v0.0.1_SNAPSHOT_03-November-2015
 2: git src        v0.0.1_SNAPSHOT_10-Sep-2015
 3: git src        v0.0.1_SNAPSHOT_12-May-2016
 4: git src       v0.0.1_SNAPSHOT_22-June-2016
 5: git src        v0.0.1_SNAPSHOT_23-Sep-2015
 6: git src    v0.0.1_SNAPSHOT_26-January-2016
 7: git src       v0.0.1_SNAPSHOT_29-July-2015
 8: git src      v0.0.1_SNAPSHOT_30-March-2016
Select master or one of tags which can be built: 0
aauser@:~/epicsarchiverap-sites (master)$ sudo su
[sudo] password for aauser: 
[root@ epicsarchiverap-sites]# bash aaSetup.bash 
[root@ epicsarchiverap-sites]# bash deployRelease.sh $PWD
[root@ epicsarchiverap-sites]# bash aaService.bash start
[root@ epicsarchiverap-sites]# bash aaService.bash stop
```
![Connection Example](aa_site_specific.png)

* Almost Full List
```
aauser@:~$ git clone https://github.com/jeonghanlee/epicsarchiverap-sites.git
Cloning into 'epicsarchiverap-sites'...
remote: Counting objects: 182, done.
remote: Compressing objects: 100% (12/12), done.
remote: Total 182 (delta 1), reused 0 (delta 0), pack-reused 170
Receiving objects: 100% (182/182), 464.26 KiB | 705.00 KiB/s, done.
Resolving deltas: 100% (83/83), done.
aauser@:~$ cd epicsarchiverap-sites/
aauser@:~/epicsarchiverap-sites (master)$ bash aaBuild.bash 
No Archappl source repository in the expected location
Cloning into 'epicsarchiverap'...
remote: Counting objects: 5107, done.
remote: Compressing objects: 100% (40/40), done.
remote: Total 5107 (delta 14), reused 0 (delta 0), pack-reused 5057
Receiving objects: 100% (5107/5107), 56.31 MiB | 6.51 MiB/s, done.
Resolving deltas: 100% (2527/2527), done.
 0: git src                             master
 1: git src   v0.0.1_SNAPSHOT_03-November-2015
 2: git src        v0.0.1_SNAPSHOT_10-Sep-2015
 3: git src        v0.0.1_SNAPSHOT_12-May-2016
 4: git src       v0.0.1_SNAPSHOT_22-June-2016
 5: git src        v0.0.1_SNAPSHOT_23-Sep-2015
 6: git src    v0.0.1_SNAPSHOT_26-January-2016
 7: git src       v0.0.1_SNAPSHOT_29-July-2015
 8: git src      v0.0.1_SNAPSHOT_30-March-2016
Select master or one of tags which can be built: 0
master

master_H_3b5b300_B_2016-09-02-1709CEST
Buildfile: /home/aauser/epicsarchiverap-sites/epicsarchiverap/build.xml
     [echo] Building the archiver appliance for the site tests

clean:
.......................

generate_release_notes:

wars:
      [tar] Building tar: /home/aauser/epicsarchiverap-sites/archappl_v0.0.1_master_H_3b5b300_B_2016-09-02-1709CEST.tar.gz

BUILD SUCCESSFUL
Total time: 30 seconds



aauser@:~/epicsarchiverap-sites (master)$ sudo su
[sudo] password for aauser: 
[root@ epicsarchiverap-sites]# 
[root@ epicsarchiverap-sites]# bash aaSetup.bash 

->

-->
Put log4j.properties in /usr/share/tomcat/lib

--->
Put appliances.xml in /opt/archappl-2016-09-02-1725CEST

---->
 Deploy multiple tomcats into /opt/archappl-2016-09-02-1725CEST
Calling /home/aauser/epicsarchiverap-sites/aa_scripts/deployMultipleTomcats.py /opt/archappl-2016-09-02-1725CEST
Using
	tomcat installation at /usr/share/tomcat 
	to generate deployments for appliance appliance0 
	using configuration info from /opt/archappl-2016-09-02-1725CEST/appliances.xml 
	into folder /opt/archappl-2016-09-02-1725CEST
The start/stop port is the standard Tomcat start/stop port. Changing it to something else random - 16000
The stop/start ports for the new instance will being at  16001
Generating tomcat folder for  mgmt  in location /opt/archappl-2016-09-02-1725CEST/mgmt
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.
Generating tomcat folder for  engine  in location /opt/archappl-2016-09-02-1725CEST/engine
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.
Generating tomcat folder for  etl  in location /opt/archappl-2016-09-02-1725CEST/etl
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.
Generating tomcat folder for  retrieval  in location /opt/archappl-2016-09-02-1725CEST/retrieval
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.

----->
Put context.xml in to /opt/archappl-2016-09-02-1725CEST/mgmt/conf/
------|

[root@ epicsarchiverap-sites]# bash deployRelease.sh $PWD
Deploying a new release from /home/aauser/epicsarchiverap-sites onto /opt/archappl

Replacing old war files with new war files
-->       new mgmt war is deploying...
-->     new engine war is deploying...
-->        new etl war is deploying...
-->  new retrieval war is deploying...

Modifying static contents for the site specific information
Changing headers and footers for /opt/archappl/mgmt/webapps/mgmt/ui/appliance.html
Changing headers and footers for /opt/archappl/mgmt/webapps/mgmt/ui/cacompare.html
Changing headers and footers for /opt/archappl/mgmt/webapps/mgmt/ui/index.html
Changing headers and footers for /opt/archappl/mgmt/webapps/mgmt/ui/integration.html
Changing headers and footers for /opt/archappl/mgmt/webapps/mgmt/ui/metrics.html
Changing headers and footers for /opt/archappl/mgmt/webapps/mgmt/ui/pvdetails.html
Changing headers and footers for /opt/archappl/mgmt/webapps/mgmt/ui/redirect.html
Changing headers and footers for /opt/archappl/mgmt/webapps/mgmt/ui/reports.html
Changing headers and footers for /opt/archappl/mgmt/webapps/mgmt/ui/storage.html


Copying site specific images recursively from /home/aauser/epicsarchiverap-sites onto /opt/archappl


Copying site specific CSS files from /home/aauser/epicsarchiverap-sites onto /opt/archappl
-->       new main.css in mgmt is deploying...
-->     new main.css in engine is deploying...
-->        new main.css in etl is deploying...
-->  new main.css in retrieval is deploying...

Done deploying a new release from /home/aauser/epicsarchiverap-sites onto /opt/archappl


[root@ epicsarchiverap-sites]# bash aaService.bash start

> Starting TOMCAT at /opt/archappl/mgmt
Using 64 bit versions of libraries


> Starting TOMCAT at /opt/archappl/engine
Using 64 bit versions of libraries


> Starting TOMCAT at /opt/archappl/etl
Using 64 bit versions of libraries


> Starting TOMCAT at /opt/archappl/retrieval
Using 64 bit versions of libraries

-- Status outputs 
-- http://localhost:17665/mgmt/ui/index.html is the web address.
-- /opt/archappl/mgmt/logs/catalina.err may help you.
-- If eight numbers are printed below, the jsvc processes are running
11117 11116 11110 11109 11106 11105 11102 11101
--

[root@ epicsarchiverap-sites]# bash aaService.bash stop
< Stopping Tomcat at /opt/archappl/engine

< Stopping Tomcat at /opt/archappl/retrieval

< Stopping Tomcat at /opt/archappl/etl

< Stopping Tomcat at /opt/archappl/mgmt

-- Status outputs 
-- http://localhost:17665/mgmt/ui/index.html is the web address.
-- /opt/archappl/mgmt/logs/catalina.err may help you.
-- If eight numbers are printed below, the jsvc processes are running
--
[root@ epicsarchiverap-sites]# 



```

# Acknowledgement
A special word of thanks goes to Murali Shankar who develops the Archiver Appliance and answers my stupid questions again and again and again.
