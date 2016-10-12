jhlee@ip4-111:~/github$ git clone --recursive https://github.com/jeonghanlee/epicsarchiverap-sites.git
Cloning into 'epicsarchiverap-sites'...
remote: Counting objects: 11, done.
remote: Compressing objects: 100% (9/9), done.
remote: Total 11 (delta 1), reused 11 (delta 1), pack-reused 0
Unpacking objects: 100% (11/11), done.
Checking connectivity... done.
Submodule 'epicsarchiverap' (https://github.com/slacmshankar/epicsarchiverap) registered for path 'epicsarchiverap'
Cloning into 'epicsarchiverap'...
remote: Counting objects: 4759, done.
remote: Total 4759 (delta 0), reused 0 (delta 0), pack-reused 4759
Receiving objects: 100% (4759/4759), 53.65 MiB | 8.05 MiB/s, done.
Resolving deltas: 100% (2349/2349), done.
Checking connectivity... done.
Submodule path 'epicsarchiverap': checked out '3c724a0d7493ac1a5f871a956719507034547653'
Submodule 'epicsarchiverap_viewer' (https://github.com/slacmshankar/epicsarchiverap_viewer.git) registered for path 'epicsarchiverap_viewer'
Cloning into 'epicsarchiverap_viewer'...
remote: Counting objects: 85, done.
remote: Total 85 (delta 0), reused 0 (delta 0), pack-reused 85
Unpacking objects: 100% (85/85), done.
Checking connectivity... done.
Submodule path 'epicsarchiverap/epicsarchiverap_viewer': checked out '351f092086cce39b4c2781cecf7975f0d25c3949'


jhlee@ip4-111:~/github/epicsarchiverap-sites (master)$ cd epicsarchiverap/

jhlee@ip4-111:~/github/epicsarchiverap-sites/epicsarchiverap ((3c724a0...))$ ls
Apache_2.0_License.txt  documentcloud_license.txt  jca_license.txt     jython_license.txt  log4j.properties        printtimes.sh         run.sh             validate.sh
build.xml               epicsarchiverap_viewer     jmatio_license.txt  lib                 log4j.properties.debug  protobuf_license.txt  src
docs                    GNU_GPL_license.txt        jquery_license.txt  LICENSE             NOTICE                  README.md             validateAndFix.sh
jhlee@ip4-111:~/github/epicsarchiverap-sites/epicsarchiverap ((3c724a0...))$ export TOMCAT_HOME=/home/jhlee/archiver_appliance/apache-tomcat-7.0.68
jhlee@ip4-111:~/github/epicsarchiverap-sites/epicsarchiverap ((3c724a0...))$ ant


...............
  [javadoc] 100 warnings
     [copy] Copying 1 file to /home/jhlee/github/epicsarchiverap-sites/epicsarchiverap/docs
     [copy] Copying 1 file to /home/jhlee/github/epicsarchiverap-sites/epicsarchiverap/docs

mgmt_war:
      [war] Building war: /home/jhlee/github/epicsarchiverap-sites/mgmt.war

generate_release_notes:

wars:
      [tar] Building tar: /home/jhlee/github/epicsarchiverap-sites/archappl_v0.0.1_SNAPSHOT_25-April-2016T11-39-13.tar.gz

BUILD SUCCESSFUL
Total time: 55 seconds



jhlee@ip4-111:~/github/epicsarchiverap-sites/epicsarchiverap ((3c724a0...))$ cd ..
jhlee@ip4-111:~/github/epicsarchiverap-sites (master)$ tree -L 
tree: Missing argument to -L option.
jhlee@ip4-111:~/github/epicsarchiverap-sites (master)$ tree -L 1
.
├── [jhlee    131M]  archappl_v0.0.1_SNAPSHOT_25-April-2016T11-39-13.tar.gz
├── [jhlee     33M]  engine.war
├── [jhlee    4.0K]  epicsarchiverap
├── [jhlee     31M]  etl.war
├── [jhlee     37M]  mgmt.war
├── [jhlee    1.4K]  README.md
├── [jhlee     31M]  retrieval.war
└── [jhlee    4.0K]  site_specific_content

2 directories, 6 files
jhlee@ip4-111:~/github/epicsarchiverap-sites (master)$ 



root@ip4-111:/opt/archiver_appliance# bash deployRelease.sh /home/jhlee/github/epicsarchiverap-sites

Remove deployRelease.sh, and move them into epicsarchiverap-sites

root@ip4-111:/opt/archiver_appliance# bash /home/jhlee/github/epicsarchiverap-sites/deployRelease.sh /home/jhlee/github/epicsarchiverap-sites/
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



root@ip4-111:/opt/archiver_appliance# ln -s /home/jhlee/github/epicsarchiverap-sites/appliances.xml appliances.xml
root@ip4-111:/opt/archiver_appliance# ln -s /home/jhlee/github/epicsarchiverap-sites/archiverapplianceservice.sh archiverapplianceservice.sh
root@ip4-111:/opt/archiver_appliance# ln -s /home/jhlee/github/epicsarchiverap-sites/deployRelease.sh deployRelease.sh


t@ip4-111:/opt/archiver_appliance# ln -s /home/jhlee/github/epicsarchiverap-sites/deployRelease.sh deployRelease.sh
root@ip4-111:/opt/archiver_appliance# bash deployRelease.sh /home/jhlee/github/epicsarchiverap-sites/
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




