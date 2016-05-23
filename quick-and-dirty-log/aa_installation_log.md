# Requirements

## JAVA 8

* download JDK from the following site

http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html



### Using java-package

```bash
root@-# aptitude install java\-package
```

```bash
jhlee@:~$ make-jpkg jdk-8u92-linux-x64.tar.gz
```

```
root@-# dpkg -i oracle-java8-jdk\_8u92\_amd64.deb
root@-# update-java-alternatives -l
root@-# update-java-alternatives -s jdk-8-oracle-x64
```

### Manually

* extract them in /opt/ directory

```
root@ip4-111:/opt# tar xvzf jdk-8u77-linux-x64.tar.gz
root@ip4-111:/opt# cd jdk1.8.0_77/
root@ip4-111:/opt/jdk1.8.0_77#
```

* system should have the open jdk and jar in order to replace their existent service with the Oracle java. Sometime one needs to install "jar"

```
root@ip4-111:/home/jhlee# aptitude install fastjar
```

* change the Open Java to Oracle Java. But it is not necessary step if we want to use JAVA_HOME in the startup script later.

```
root@ip4-111:/opt/jdk1.8.0_77/bin# update-alternatives --install /usr/bin/java  java /opt/jdk1.8.0_77/bin/java 1041
root@ip4-111:/opt/jdk1.8.0_77/bin# update-alternatives --install /usr/bin/jar  jar /opt/jdk1.8.0_77/bin/jar 1041
```

## MySQL

### MySQL server and its configuration

* MySQL administrative "root" user, use ICS-Services MySQL root password defined at https://ess-ics.atlassian.net/wiki/display/DE/Passwords

  Its password is  *******************

* install MySQL provided by the standard Debian package and set the MySQL root password (NB:this is not the password of your system)

```
root@ip4-111:/home/jhlee# aptitude install mysql-server
root@ip4-111:/home/jhlee# mysqladmin -u root password
 *******************
```

* create DB and User
The following command is used to create DB, and User, and grant all to User.
```
mysql -u root -p -e "CREATE DATABASE _db_name_;  GRANT ALL PRIVILEGES ON _db_name_.* TO '_db_user_name_'@'localhost' IDENTIFIED BY '_db_user_name_pw_';
```
The actual command which I used (NB: this is the test environment, so we use the same DB name, User name, and its password).
```
root@ip4-111:/home/jhlee# mysql -u root -p -e "CREATE DATABASE archappl; GRANT ALL PRIVILEGES ON archappl.* TO 'archappl'@'localhost' IDENTIFIED BY 'archappl'"
Enter password:
```
Check whether the command, which I used, works or not
```
root@ip4-111:/home/jhlee# mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 39
Server version: 5.5.47-0+deb8u1 (Debian)

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| archappl           |
| mysql              |
| performance_schema |
+--------------------+
4 rows in set (0.00 sec)

mysql>  select User, Host, Password from mysql.user;
+------------------+-----------+-------------------------------------------+
| User             | Host      | Password                                  |
+------------------+-----------+-------------------------------------------+
| root             | localhost | *7C2973139458FCEBB71E89E8DD5E196D2472AFE2 |
| root             | 127.0.0.1 |                                           |
| root             | ::1       |                                           |
| debian-sys-maint | localhost | *5B4C0E450CE42436F5A8383752989A985CCFEA7B |
| archappl         | localhost | *ECD434ACB728FD721CDCF3E08C2C35149E54B64A |
+------------------+-----------+-------------------------------------------+
5 rows in set (0.00 sec)

mysql> use archappl
Database changed
mysql> show tables;
Empty set (0.00 sec)
```


### MySQL Connector/J

* download the mysql-connector-java-5 in the following link
  https://downloads.mysql.com/archives/c-j/
  Recommendation is 5.1.21
  or the recent one is http://dev.mysql.com/downloads/connector/j/

* But I am using 5.1.38 instead of 5.1.21
* Please remember, the download file is "tar.gz" file. One should extract them, and put them in a directory.
* We should select a "jar" file. For example, mysql-connector-java-5.1.38-bin.jar
* I put them into a source directory :
  ${HOME}/apps_foe_aa/aa_src


# Configuration for Archiver Appliance

## Prepare the target directory, where one wants to put arcihver appliance itself.

* Create archiver_appliance dir in /opt/
```
root@ip4-111:/opt# mkdir archiver_appliance
```

## Download the "binary" file "tar.gz" and extract them into a source directory
* Download link :  https://github.com/slacmshankar/epicsarchiverap/releases/
* A source directory : ${HOME}/apps_foe_aa/aa_src
```
jhlee@ip4-111:~/apps_for_aa$ wget -c https://github.com/slacmshankar/epicsarchiverap/releases/download/v0.0.1_SNAPSHOT_30-March-2016/archappl_v0.0.1_SNAPSHOT_30-March-2016T10-02-12.tar.gz
jhlee@ip4-111:~/apps_for_aa$ mkdir aa_src
jhlee@ip4-111:~/apps_for_aa$ mv archappl_v0.0.1_SNAPSHOT_30-March-2016T10-02-12.tar.gz aa_src/
jhlee@ip4-111:~/apps_for_aa$ cd aa_src/
jhlee@ip4-111:~/apps_for_aa/aa_src$ ls
archappl_v0.0.1_SNAPSHOT_30-March-2016T10-02-12.tar.gz
jhlee@ip4-111:~/apps_for_aa/aa_src$ tar xvzf archappl_v0.0.1_SNAPSHOT_30-March-2016T10-02-12.tar.gz
```
* check the structure of AA "binary" sources
```
root@ip4-111:/home/jhlee/apps_for_aa# tree -L 2
.
├── aa_src
│   ├── Apache_2.0_License.txt
│   ├── archappl_v0.0.1_SNAPSHOT_30-March-2016T10-02-12.tar.gz
│   ├── engine.war
│   ├── etl.war
│   ├── install_scripts
│   ├── LICENSE
│   ├── mgmt.war
│   ├── NOTICE
│   ├── quickstart.sh
│   ├── RELEASE_NOTES
│   ├── retrieval.war
│   └── sample_site_specific_content
├── binary_files
│   ├── apache-tomcat-7.0.67.tar.gz
│   ├── apache-tomcat-7.0.68.tar.gz
│   ├── archappl_v0.0.1_SNAPSHOT_30-March-2016T10-02-12.tar.gz
│   ├── mysql-connector-java-5.1.21.tar.gz
│   └── mysql-connector-java-5.1.38.tar.gz
└── mysql-connector-java-5.1.38
    ├── build.xml
    ├── CHANGES
    ├── COPYING
    ├── docs
    ├── mysql-connector-java-5.1.38-bin.jar
    ├── README
    ├── README.txt
    └── src
```


# Install the Archiver Appliance by using the installation script for a single machine.

* Set JAVA_HOME
```
root@ip4-111:/home/jhlee/apps_for_aa/aa_src# export JAVA_HOME=/opt/jdk1.8.0_77/
```
* run single_machine_install.sh
I removed unimportant messages from the actual log.

```
root@ip4-111:/home/jhlee/apps_for_aa/aa_src# bash install_scripts/single_machine_install.sh
This script runs thru a typical install scenario for a single machine
You can use this to create a standard multi-instance (one Tomcat for ear WAR) tomcat deployment in a multi machine cluster by setting the ARCHAPPL_APPLIANCES and the ARCHAPPL_MYIDENTITY
For installations in a cluster, please do create a valid appliances.xml and export ARCHAPPL_APPLIANCES and ARCHAPPL_MYIDENTITY
java version "1.8.0_77"
Pick a folder (preferably empty) where you'd like to create the Tomcat instances.

>>> See /home/jhlee/Documents/log/aa_installation_imgs/1.png

Setting DEPLOY_DIR to /opt/archiver_appliance
Where's the Tomcat distribution (tar.gz)?

>>> See /home/jhlee/Documents/log/aa_installation_imgs/2.png

/opt/archiver_appliance /home/jhlee/apps_for_aa/aa_src
/home/jhlee/apps_for_aa/aa_src
Setting TOMCAT_HOME to /opt/archiver_appliance/apache-tomcat-7.0.68
/opt/archiver_appliance/apache-tomcat-7.0.68/bin /home/jhlee/apps_for_aa/aa_src
/home/jhlee/apps_for_aa/aa_src
/opt/archiver_appliance/apache-tomcat-7.0.68/bin/commons-daemon-1.0.15-native-src/unix /home/jhlee/apps_for_aa/aa_src
*** Current host ***
checking build system type... x86_64-unknown-linux-gnu
checking host system type... x86_64-unknown-linux-gnu
checking cached host system type... ok
*** C-Language compilation tools ***
checking for gcc... gcc
checking for C compiler default output file name... a.out
checking whether the C compiler works... yes
checking whether we are cross compiling... no
checking for suffix of executables...
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ANSI C... none needed
checking for ranlib... ranlib
checking for strip... strip
*** Host support ***
checking C flags dependant on host system type... ok
*** Java compilation tools ***
checking for JDK os include directory...  linux
gcc flags added
checking how to run the C preprocessor... gcc -E
checking for egrep... grep -E
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking sys/capability.h usability... no
checking sys/capability.h presence... no
checking for sys/capability.h... no
configure: WARNING: cannot find headers for libcap
*** Writing output files ***
configure: creating ./config.status
config.status: creating Makefile
config.status: creating Makedefs
config.status: creating native/Makefile
*** All done ***
Now you can issue "make"
(cd native; make  all)
make[1]: Entering directory '/opt/archiver_appliance/apache-tomcat-7.0.68/bin/commons-daemon-1.0.15-native-src/unix/native'
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c jsvc-unix.c -o jsvc-unix.o
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c arguments.c -o arguments.o
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c debug.c -o debug.o
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c dso-dlfcn.c -o dso-dlfcn.o
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c dso-dyld.c -o dso-dyld.o
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c help.c -o help.o
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c home.c -o home.o
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c java.c -o java.o
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c location.c -o location.o
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c replace.c -o replace.o
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c locks.c -o locks.o
gcc -g -O2 -DOS_LINUX -DDSO_DLFCN -DCPU=\"amd64\" -Wall -Wstrict-prototypes   -I/opt/jdk1.8.0_77//include -I/opt/jdk1.8.0_77//include/linux -c signals.c -o signals.o
ar cr libservice.a arguments.o debug.o dso-dlfcn.o dso-dyld.o help.o home.o java.o location.o replace.o locks.o signals.o
ranlib libservice.a
gcc   jsvc-unix.o libservice.a -ldl -lpthread -o ../jsvc
make[1]: Leaving directory '/opt/archiver_appliance/apache-tomcat-7.0.68/bin/commons-daemon-1.0.15-native-src/unix/native'
/home/jhlee/apps_for_aa/aa_src
Where's the mysql client jar? - this is named something like mysql-connector-java-5.1.21-bin.jar.

>>> See /home/jhlee/Documents/log/aa_installation_imgs/3.png

Done copying the mysql client library to /opt/archiver_appliance/apache-tomcat-7.0.68/lib
I see you have not defined the ARCHAPPL_APPLIANCES environment variable. If we proceed, I'll automatically generate one in /opt/archiver_appliance. Should we proceed?

>>> See /home/jhlee/Documents/log/aa_installation_imgs/4.png
>>> Select Yes

Calling install_scripts/deployMultipleTomcats.py /opt/archiver_appliance
Using
        tomcat installation at /opt/archiver_appliance/apache-tomcat-7.0.68
        to generate deployments for appliance appliance0
        using configuration info from /opt/archiver_appliance/appliances.xml
        into folder /opt/archiver_appliance
The start/stop port is the standard Tomcat start/stop port. Changing it to something else random - 16000
The stop/start ports for the new instance will being at  16001
Generating tomcat folder for  mgmt  in location /opt/archiver_appliance/mgmt
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.
Generating tomcat folder for  engine  in location /opt/archiver_appliance/engine
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.
Generating tomcat folder for  etl  in location /opt/archiver_appliance/etl
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.
Generating tomcat folder for  retrieval  in location /opt/archiver_appliance/retrieval
Commenting connector with protocol  AJP/1.3 . If you do need this connector, you should un-comment this.
Please enter a MySQL Connection string to an existing database like so

>>> See /home/jhlee/Documents/log/aa_installation_imgs/5.png
>>> We use the default ones, so no change is necessary.

Setting MYSQL_CONNECTION_STRING to --user=archappl --password=archappl --database=archappl
information_schema
I do not see the PVTypeInfo table in --user=archappl --password=archappl --database=archappl? Should we go ahead and create the tables? This step will delete any old data that you have.

>>> See /home/jhlee/Documents/log/aa_installation_imgs/6.png
>>> YES

Creating tables in --user=archappl --password=archappl --database=archappl
PVTypeInfo
Setting TOMCAT_HOME to the mgmt webapp in /opt/archiver_appliance/mgmt
Setting TOMCAT_HOME to /opt/archiver_appliance/apache-tomcat-7.0.68
Calling deploy release with /opt/archiver_appliance/deployRelease.sh /home/jhlee/apps_for_aa/aa_src
Deploying a new release from /home/jhlee/apps_for_aa/aa_src onto /opt/archiver_appliance
/opt/archiver_appliance/mgmt/webapps /home/jhlee/apps_for_aa/aa_src
/home/jhlee/apps_for_aa/aa_src
/opt/archiver_appliance/engine/webapps /home/jhlee/apps_for_aa/aa_src
/home/jhlee/apps_for_aa/aa_src
/opt/archiver_appliance/etl/webapps /home/jhlee/apps_for_aa/aa_src
/home/jhlee/apps_for_aa/aa_src
/opt/archiver_appliance/retrieval/webapps /home/jhlee/apps_for_aa/aa_src
/home/jhlee/apps_for_aa/aa_src
Done deploying a new release from /home/jhlee/apps_for_aa/aa_src onto /opt/archiver_appliance
Do you have a site specific policies.py file?

>>> See /home/jhlee/Documents/log/aa_installation_imgs/7.png
>>> Currently, we don't have one, so NO


Done with the installation. Please use /opt/archiver_appliance/sampleStartup.sh to start and stop the appliance and /opt/archiver_appliance/deployRelease.sh to deploy a new release.

>>> See /home/jhlee/Documents/log/aa_installation_imgs/8.png
```

# Check the Archiver Appliance Deploy Status

* Check your system in /opt/archiver_appliance
```
root@ip4-111:/opt/archiver_appliance# tree -L 2
.
├── apache-tomcat-7.0.68
│   ├── bin
│   ├── conf
│   ├── lib
│   ├── LICENSE
│   ├── logs
│   ├── NOTICE
│   ├── RELEASE-NOTES
│   ├── RUNNING.txt
│   ├── temp
│   ├── webapps
│   └── work
├── appliances.xml
├── deployRelease.sh
├── engine
│   ├── conf
│   ├── logs
│   ├── temp
│   ├── webapps
│   └── work
├── etl
│   ├── conf
│   ├── logs
│   ├── temp
│   ├── webapps
│   └── work
├── mgmt
│   ├── conf
│   ├── logs
│   ├── temp
│   ├── webapps
│   └── work
├── retrieval
│   ├── conf
│   ├── logs
│   ├── temp
│   ├── webapps
│   └── work
└── sampleStartup.sh
```

* Check the appliances.xml
```
 <appliances>
   <appliance>
     <identity>appliance0</identity>
     <cluster_inetport>ip4-111.esss.lu.se:16670</cluster_inetport>
     <mgmt_url>http://ip4-111.esss.lu.se:17665/mgmt/bpl</mgmt_url>
     <engine_url>http://ip4-111.esss.lu.se:17666/engine/bpl</engine_url>
     <etl_url>http://ip4-111.esss.lu.se:17667/etl/bpl</etl_url>
     <retrieval_url>http://localhost:17668/retrieval/bpl</retrieval_url>
     <data_retrieval_url>http://ip4-111.esss.lu.se:17668/retrieval</data_retrieval_url>
   </appliance>
 </appliances>
```
* Check MySQL DB

```
jhlee@ip4-111:~$ mysql -u archappl -h localhost -p archappl
Enter password:
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 45
Server version: 5.5.47-0+deb8u1 (Debian)

Copyright (c) 2000, 2015, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show tables;
+---------------------+
| Tables_in_archappl  |
+---------------------+
| ArchivePVRequests   |
| ExternalDataServers |
| PVAliases           |
| PVTypeInfo          |
+---------------------+
4 rows in set (0.00 sec)
```


# Prepare the storage in local directory
* in this configuration, {s,m,l}ts in the local ext4 file system.
```
root@ip4-111:/mnt/arch# mkdir -p {sts,mts,lts}/ArchiverStore
root@ip4-111:/mnt/arch# tree -L 2
.
├── lts
│   └── ArchiverStore
├── mts
│   └── ArchiverStore
└── sts
    └── ArchiverStore

6 directories, 0 files
```
# startup script

* edit the startup script to replace the EPICS environment, and stroages

```
root@ip4-111:/opt/archiver_appliance# scp sampleStartup.sh archiverapplianceservice.sh
```
Replace EPICS environment script
```
source /home/jhlee/epics/R3.14.12.5/setEpicsEnv.sh
```
Set Store Folders what one setup before
```
export ARCHAPPL_SHORT_TERM_FOLDER=/mnt/arch/sts/ArchiverStore
export ARCHAPPL_MEDIUM_TERM_FOLDER=/mnt/arch/mts/ArchiverStore
export ARCHAPPL_LONG_TERM_FOLDER=/mnt/arch/lts/ArchiverStore
```
# Start / stop

```
root@ip4-111:/opt/archiver_appliance# bash archiverapplianceservice.sh start
Starting tomcat at location /opt/archiver_appliance/mgmt
Using 64 bit versions of libraries
/opt/archiver_appliance/mgmt/logs /opt/archiver_appliance
/opt/archiver_appliance
Starting tomcat at location /opt/archiver_appliance/engine
Using 64 bit versions of libraries
/opt/archiver_appliance/engine/logs /opt/archiver_appliance
/opt/archiver_appliance
Starting tomcat at location /opt/archiver_appliance/etl
Using 64 bit versions of libraries
/opt/archiver_appliance/etl/logs /opt/archiver_appliance
/opt/archiver_appliance
Starting tomcat at location /opt/archiver_appliance/retrieval
Using 64 bit versions of libraries
/opt/archiver_appliance/retrieval/logs /opt/archiver_appliance
/opt/archiver_appliance
```
