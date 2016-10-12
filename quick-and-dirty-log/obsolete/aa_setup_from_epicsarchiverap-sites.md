jhlee@kaffee:~/programming$ git clone https://github.com/jeonghanlee/epicsarchiverap-sites.git
Cloning into 'epicsarchiverap-sites'...
remote: Counting objects: 72, done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 72 (delta 0), reused 0 (delta 0), pack-reused 66
Unpacking objects: 100% (72/72), done.
Checking connectivity... done.

jhlee@kaffee:~/programming$ cd epicsarchiverap-sites
jhlee@kaffee:~/programming/epicsarchiverap-sites (master)$ git submodule init
Submodule 'epicsarchiverap' (https://github.com/slacmshankar/epicsarchiverap) registered for path 'epicsarchiverap'

jhlee@kaffee:~/programming/epicsarchiverap-sites (master)$ git submodule update
Cloning into 'epicsarchiverap'...
remote: Counting objects: 4890, done.
remote: Total 4890 (delta 0), reused 0 (delta 0), pack-reused 4890
Receiving objects: 100% (4890/4890), 55.34 MiB | 4.82 MiB/s, done.
Resolving deltas: 100% (2426/2426), done.
Checking connectivity... done.
Submodule path 'epicsarchiverap': checked out '73be345fff49a85f29978873f96f085b3923262c'


jhlee@kaffee:~/programming/epicsarchiverap-sites (master)$ cd epicsarchiverap/
jhlee@kaffee:~/programming/epicsarchiverap-sites/epicsarchiverap ((v0.0.1_SNAPSHOT_12-May-2016))$ 

jhlee@kaffee:~/programming/epicsarchiverap-sites/epicsarchiverap ((v0.0.1_SNAPSHOT_12-May-2016))$ export TOMCAT_HOME=/usr/share/tomcat7
jhlee@kaffee:~/programming/epicsarchiverap-sites/epicsarchiverap ((v0.0.1_SNAPSHOT_12-May-2016))$ ant
Buildfile: /home/jhlee/programming/epicsarchiverap-sites/epicsarchiverap/build.xml
     [echo] Building the archiver appliance for the site tests

clean:
   [delete] Deleting directory /home/jhlee/programming/epicsarchiverap-sites/epicsarchiverap/bin

compile:
    [mkdir] Created dir: /home/jhlee/programming/epicsarchiverap-sites/epicsarchiverap/bin
    [javac] Compiling 558 source files to /home/jhlee/programming/epicsarchiverap-sites/epicsarchiverap/bin

stage:
    [mkdir] Created dir: /home/jhlee/programming/epicsarchiverap-sites/epicsarchiverap/stage
     [copy] Copying 33 files to /home/jhlee/programming/epicsarchiverap-sites/epicsarchiverap/stage/org/epics/archiverappliance/staticcontent
     [copy] Copying 2 files to /home/jhlee/programming/epicsarchiverap-sites/epicsarchiverap/stage/org/epics/archiverappliance/retrieval/staticcontent
      [zip] Warning: skipping zip archive /home/jhlee/programming/epicsarchiverap-sites/epicsarchiverap/stage/org/epics/archiverappliance/retrieval/staticcontent/viewer.zip because no files were included.
     [copy] Copying 12 files to /home/jhlee/programming/epicsarchiverap-sites/epicsarchiverap/stage/org/epics/archiverappliance/mgmt/staticcontent

sitespecificbuild:

retrieval_war:
     [copy] Copying 3 files to /home/jhlee/programming/epicsarchiverap-sites/epicsarchiverap/bin
      [war] Building war: /home/jhlee/programming/epicsarchiverap-sites/retrieval.war

engine_war:
      [war] Building war: /home/jhlee/programming/epicsarchiverap-sites/engine.war

etl_war:
      [war] Building war: /home/jhlee/programming/epicsarchiverap-sites/etl.war



BUILD SUCCESSFUL
Total time: 41 seconds



jhlee@kaffee:~/programming/epicsarchiverap-sites (master)$ mkdir aa_install_src
jhlee@kaffee:~/programming/epicsarchiverap-sites (master)$ mv archappl_v0.0.1_SNAPSHOT_23-May-2016T23-55-21.tar.gz aa_install_src/
jhlee@kaffee:~/programming/epicsarchiverap-sites (master)$ cd aa_install_src/
jhlee@kaffee:~/programming/epicsarchiverap-sites/aa_install_src (master)$ tar xvzf archappl_v0.0.1_SNAPSHOT_23-May-2016T23-55-21.tar.gz 
quickstart.sh
Apache_2.0_License.txt
LICENSE
NOTICE
RELEASE_NOTES
install_scripts/addMysqlConnPool.py
install_scripts/deployMultipleTomcats.py
install_scripts/sampleStartup.sh
install_scripts/single_machine_install.sh
sample_site_specific_content/template_changes.html
sample_site_specific_content/img/accelutils.png
install_scripts/archappl_mysql.sql
engine.war
etl.war
mgmt.war
retrieval.war


