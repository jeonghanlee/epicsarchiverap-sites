jhlee@ip4-111:~$ git clone https://github.com/jeonghanlee/epicsarchiverap.git

jhlee@ip4-111:~$ cd epicsarchiverap/

jhlee@ip4-111:~/epicsarchiverap (essdev)$ git checkout tags/v0.0.1_SNAPSHOT_30-March-2016 -b  essdev
Switched to a new branch 'essdev'


jhlee@ip4-111:~/epicsarchiverap/src/sitespecific (essdev)$ scp -r slacdev/ essdev


There are three variables setup

ARCHAPPL_SITEID
TOMCAT_HOME
BUILDS_ALL_TIME


jhlee@ip4-111:~$ mkdir github_aa
jhlee@ip4-111:~$ cd github_aa/
jhlee@ip4-111:~/github_aa$ git clone https://github.com/jeonghanlee/epicsarchiverap.git

jhlee@ip4-111:~/github_aa/epicsarchiverap (master)$ git checkout essdev
Branch essdev set up to track remote branch essdev from origin.
Switched to a new branch 'essdev'
jhlee@ip4-111:~/github_aa/epicsarchiverap (essdev)$ git st
On branch essdev
Your branch is up-to-date with 'origin/essdev'.
nothing to commit, working directory clean


jhlee@ip4-111:~/github_aa/epicsarchiverap (essdev)$ export ARCHAPPL_SITEID=essdev
jhlee@ip4-111:~/github_aa/epicsarchiverap (essdev)$ export TOMCAT_HOME=/home/jhlee/archiver_appliance/apache-tomcat-7.0.68
jhlee@ip4-111:~/github_aa/epicsarchiverap (essdev)$ ant
Buildfile: /home/jhlee/github_aa/epicsarchiverap/build.xml
     [echo] Building the archiver appliance for the site essdev

clean:
   [delete] Deleting directory /home/jhlee/github_aa/epicsarchiverap/bin

compile:
    [mkdir] Created dir: /home/jhlee/github_aa/epicsarchiverap/bin
    [javac] Compiling 556 source files to /home/jhlee/github_aa/epicsarchiverap/bin

stage:
    [mkdir] Created dir: /home/jhlee/github_aa/epicsarchiverap/stage
     [copy] Copying 33 files to /home/jhlee/github_aa/epicsarchiverap/stage/org/epics/archiverappliance/staticcontent
     [copy] Copying 2 files to /home/jhlee/github_aa/epicsarchiverap/stage/org/epics/archiverappliance/retrieval/staticcontent
      [zip] Warning: skipping zip archive /home/jhlee/github_aa/epicsarchiverap/stage/org/epics/archiverappliance/retrieval/staticcontent/viewer.zip because no files were included.
     [copy] Copying 12 files to /home/jhlee/github_aa/epicsarchiverap/stage/org/epics/archiverappliance/mgmt/staticcontent

sitespecificbuild:
     [echo] Calling site specific build for site essdev

echo:
     [echo] From within the site specific build for essdev. Staging folder is /home/jhlee/github_aa/epicsarchiverap/stage

......................

  [javadoc] 100 warnings
     [copy] Copying 1 file to /home/jhlee/github_aa/epicsarchiverap/docs
     [copy] Copying 1 file to /home/jhlee/github_aa/epicsarchiverap/docs

mgmt_war:
      [war] Building war: /home/jhlee/github_aa/mgmt.war

generate_release_notes:

wars:
      [tar] Building tar: /home/jhlee/github_aa/archappl_v0.0.1_SNAPSHOT_22-April-2016T15-39-45.tar.gz

BUILD SUCCESSFUL
Total time: 1 minute 0 seconds



so, the parent directory has the tar.gz file,
extract them into a test dir, 

jhlee@ip4-111:~/github_aa/test$ ls
Apache_2.0_License.txt                                  engine.war  install_scripts  mgmt.war  quickstart.sh  retrieval.war
archappl_v0.0.1_SNAPSHOT_22-April-2016T15-39-45.tar.gz  etl.war     LICENSE          NOTICE    RELEASE_NOTES  sample_site_specific_content


so stop AA 

root@ip4-111:/opt/archiver_appliance# bash archiverapplianceservice.sh stop

deploy them

root@ip4-111:/opt/archiver_appliance# bash deployRelease.sh /home/jhlee/github_aa/test/
Deploying a new release from /home/jhlee/github_aa/test/ onto /opt/archiver_appliance
/opt/archiver_appliance/mgmt/webapps /opt/archiver_appliance
/opt/archiver_appliance
/opt/archiver_appliance/engine/webapps /opt/archiver_appliance
/opt/archiver_appliance
/opt/archiver_appliance/etl/webapps /opt/archiver_appliance
/opt/archiver_appliance
/opt/archiver_appliance/retrieval/webapps /opt/archiver_appliance
/opt/archiver_appliance
Done deploying a new release from /home/jhlee/github_aa/test/ onto /opt/archiver_appliance
Modifying static content to cater to site specific information
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/integration.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/pvdetails.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/redirect.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/reports.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/storage.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/appliance.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/cacompare.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/index.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/metrics.html
Replacing site specific images


and start AA
root@ip4-111:/opt/archiver_appliance# bash  aaService.bash start


if we don't have site_specific_content, it is 

root@ip4-111:/opt/archiver_appliance# bash deployRelease.sh /home/jhlee/github_aa/test/
Deploying a new release from /home/jhlee/github_aa/test/ onto /opt/archiver_appliance
/opt/archiver_appliance/mgmt/webapps /opt/archiver_appliance
/opt/archiver_appliance
/opt/archiver_appliance/engine/webapps /opt/archiver_appliance
/opt/archiver_appliance
/opt/archiver_appliance/etl/webapps /opt/archiver_appliance
/opt/archiver_appliance
/opt/archiver_appliance/retrieval/webapps /opt/archiver_appliance
/opt/archiver_appliance
Done deploying a new release from /home/jhlee/github_aa/test/ onto /opt/archiver_appliance




root@ip4-111:/opt/archiver_appliance# ln -s /home/jhlee/github/epicsarchiverap-sites/appliances.xml appliances.xml
root@ip4-111:/opt/archiver_appliance# ln -s /home/jhlee/github/epicsarchiverap-sites/archiverapplianceservice.sh archiverapplianceservice.sh 
root@ip4-111:/opt/archiver_appliance# ln -s /home/jhlee/github/epicsarchiverap-sites/deployRelease.sh deployRelease.sh
root@ip4-111:/opt/archiver_appliance# 



root@ip4-111:/opt/archiver_appliance# bash aaService.bash stop
Stopping tomcat at location /opt/archiver_appliance/engine
/opt/archiver_appliance/engine/logs /opt/archiver_appliance
/opt/archiver_appliance
Stopping tomcat at location /opt/archiver_appliance/retrieval
/opt/archiver_appliance/retrieval/logs /opt/archiver_appliance
/opt/archiver_appliance
Stopping tomcat at location /opt/archiver_appliance/etl
/opt/archiver_appliance/etl/logs /opt/archiver_appliance
/opt/archiver_appliance
Stopping tomcat at location /opt/archiver_appliance/mgmt
/opt/archiver_appliance/mgmt/logs /opt/archiver_appliance
/opt/archiver_appliance




root@ip4-111:/opt/archiver_appliance# bash deployRelease.sh  /home/jhlee/github/epicsarchiverap-sites/
Deploying a new release from /home/jhlee/github/epicsarchiverap-sites/ onto /opt/archiver_appliance
/opt/archiver_appliance/mgmt/webapps /opt/archiver_appliance
/opt/archiver_appliance
/opt/archiver_appliance/engine/webapps /opt/archiver_appliance
/opt/archiver_appliance
/opt/archiver_appliance/etl/webapps /opt/archiver_appliance
/opt/archiver_appliance
/opt/archiver_appliance/retrieval/webapps /opt/archiver_appliance
/opt/archiver_appliance
Done deploying a new release from /home/jhlee/github/epicsarchiverap-sites/ onto /opt/archiver_appliance
Modifying static content to cater to site specific information
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/integration.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/pvdetails.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/redirect.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/reports.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/storage.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/appliance.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/cacompare.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/index.html
Changing headers and footers for /opt/archiver_appliance/mgmt/webapps/mgmt/ui/metrics.html
Replacing site specific images
Copying site specific CSS files into /opt/archiver_appliance





