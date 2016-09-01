EPICS Archiver Appliance Site Specific Test Environment
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

# License

* All works done by the original Archiver Appliance follows its original Licenses. Please check them in
  https://github.com/slacmshankar/epicsarchiverap/blob/master/NOTICE
* In addition, The works in this repository can be distributed under the GPL-2 license.

# Things to know


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
[user@ ~]$ git clone https://github.com/jeonghanlee/epicsarchiverap-sites.git
[user@ ~]$ cd epicsarchiverap-sites/
[user@ epicsarchiverap-sites]$ git clone https://github.com/slacmshankar/epicsarchiverap
[user@ epicsarchiverap-sites]$ cd epicsarchiverap/
[user@ epicsarchiverap]$ export TOMCAT_HOME=/usr/share/tomcat
[user@ epicsarchiverap]$ ant
[user@ epicsarchiverap]$ cd ..
[user@ epicsarchiverap-sites]$ sudo su
[root@ epicsarchiverap-sites]# bash aaSetup.bash 
[root@ epicsarchiverap-sites]# bash deployRelease.sh $PWD
[root@ epicsarchiverap-sites]# bash aaService.bash start
[root@ epicsarchiverap-sites]# bash aaService.bash stop
```
![Connection Example](aa_site_specific.png)

* Almost Full List
```
[user@ ~]$ git clone https://github.com/jeonghanlee/epicsarchiverap-sites.git
Cloning into 'epicsarchiverap-sites'...
remote: Counting objects: 154, done.
remote: Compressing objects: 100% (59/59), done.
remote: Total 154 (delta 28), reused 0 (delta 0), pack-reused 95
Receiving objects: 100% (154/154), 396.00 KiB | 0 bytes/s, done.
Resolving deltas: 100% (65/65), done.

[user@ ~]$ cd epicsarchiverap-sites/
[user@ epicsarchiverap-sites]$ git clone https://github.com/slacmshankar/epicsarchiverap
Cloning into 'epicsarchiverap'...
remote: Counting objects: 5057, done.
remote: Total 5057 (delta 0), reused 0 (delta 0), pack-reused 5057
Receiving objects: 100% (5057/5057), 56.28 MiB | 12.57 MiB/s, done.
Resolving deltas: 100% (2513/2513), done.

[user@ epicsarchiverap-sites]$ cd epicsarchiverap/

[user@ epicsarchiverap]$ export TOMCAT_HOME=/usr/share/tomcat
[user@ epicsarchiverap]$ ant
.........................
.........................

mgmt_war:
      [war] Building war: /home/aauser/epicsarchiverap-sites/mgmt.war

generate_release_notes:

wars:
      [tar] Building tar: /home/aauser/epicsarchiverap-sites/archappl_v0.0.1_SNAPSHOT_01-September-2016T17-16-44.tar.gz

BUILD SUCCESSFUL
Total time: 32 seconds

[user@ epicsarchiverap]$ cd ..
[user@ epicsarchiverap-sites]$ ls
aa_scripts      archappl_v0.0.1_SNAPSHOT_01-September-2016T17-16-44.tar.gz  epicsarchiverap  mgmt.war             retrieval.war
aaService.bash  deployRelease.sh                                            etl.war          quick-and-dirty-log  site_specific_content
aaSetup.bash    engine.war                                                  LICENSE          README.md            template

[user@ epicsarchiverap-sites]$ sudo su
[sudo] password for user: 
[root@ epicsarchiverap-sites]# 

[root@ epicsarchiverap-sites]# bash aaSetup.bash 

->
/opt/archappl is a symlink to a directory, so removing it.

-->
Put log4j.properties in /usr/share/tomcat/lib

--->
Put appliances.xml in /opt/archappl-2016-09-01-1718CEST

---->
 Deploy multiple tomcats into /opt/archappl-2016-09-01-1718CEST
Calling ./aa_scripts/deployMultipleTomcats.py /opt/archappl-2016-09-01-1718CEST
Using
	tomcat installation at /usr/share/tomcat 
	to generate deployments for appliance appliance0 
	using configuration info from /opt/archappl-2016-09-01-1718CEST/appliances.xml 
	into folder /opt/archappl-2016-09-01-1718CEST
The start/stop port is the standard Tomcat start/stop port. Changing it to something else random - 16000
The stop/start ports for the new instance will being at  16001
Generating tomcat folder for  mgmt  in location /opt/archappl-2016-09-01-1718CEST/mgmt
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.
Generating tomcat folder for  engine  in location /opt/archappl-2016-09-01-1718CEST/engine
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.
Generating tomcat folder for  etl  in location /opt/archappl-2016-09-01-1718CEST/etl
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.
Generating tomcat folder for  retrieval  in location /opt/archappl-2016-09-01-1718CEST/retrieval
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.

----->
Put context.xml in to /opt/archappl-2016-09-01-1718CEST/mgmt/conf/
------|

[root@ epicsarchiverap-sites]# 
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

[root@ epicsarchiverap-sites]# 
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
15318 15315 15300 15297 15287 15286 15283 15282
--
[root@ics-tag348 epicsarchiverap-sites]# 
[root@ics-tag348 epicsarchiverap-sites]# bash aaService.bash stop
< Stopping Tomcat at /opt/archappl/engine

< Stopping Tomcat at /opt/archappl/retrieval

< Stopping Tomcat at /opt/archappl/etl

< Stopping Tomcat at /opt/archappl/mgmt

-- Status outputs 
-- http://localhost:17665/mgmt/ui/index.html is the web address.
-- /opt/archappl/mgmt/logs/catalina.err may help you.
-- If eight numbers are printed below, the jsvc processes are running
--
```
