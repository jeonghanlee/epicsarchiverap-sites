A Site-Specific (ESS) EPICS Archiver Appliance Deployment
=================


# Requirements

* CentOS 7.2 1511
* CentOS 7.3 1611
* CentOS 7.4 1709

# License

* All works done by the original Archiver Appliance follows its original Licenses. Please check them in
https://github.com/slacmshankar/epicsarchiverap/blob/master/NOTICE
* Makefile, to build any documents, follows its original License also. Please check it in  http://www.bouncingchairs.net/oss
* In addition, The works in this repository can be distributed under the GPL-2 license.

# Archiver Appliance Setup on CentOS 7

With the following commands, one can setup an Archiver Appliance quite easily on CentOS 7
```
$ curl -L https://git.io/vXSN6 -o aa_init.bash
$ bash aa_init.bash 
$ cd epicsarchiverap-sites/
$ bash 00_preAA.bash all
```
One should reboot the system. 
```
$ bash 01_aaBuild.bash 
$ bash 02_aaSetup.bash 
$ bash 03_aaDeploy.bash
$ bash systemd_service/archappl_systemd_setup.bash 
```

The following systemd services for the archappl.service are ready to use. 
```
$ sudo systemctl start  archappl
$ sudo systemctl stop   archappl
$ sudo systemctl status archappl
```

# Local Update or Development

After the archiver appliance is configured, in the case when one would like to modify any source codes in the epicsarchiverap, one can also install this local modified epicsarchiverap with the following commands : 
``` 
$ bash 01_aaBuild.bash loc
$ bash 03_aaDeploy.bash 
```
The 01_aaBuild.bash with the **loc** will compile the modified codes in the epicsarchiverep. The version number which one installs via the local modification is defined with the loc suffix, e.g., ```archappl_v0.0.1__H92a3f40_B2017May22-1248-05CEST_Tloc```.


# Deployment Full Commands List

```
aauser@: $ curl -L https://git.io/vXSN6 -o aa_init.bash

aauser@: $ bash aa_init.bash 

aauser@: $ cd epicsarchiverap-sites/

aauser@: epicsarchiverap-sites (master)$ bash 00_preAA.bash all

aauser@: epicsarchiverap-sites (master)$ bash 01_aaBuild.bash 
 0: git src                             master
 1: git src       v0.0.1_SNAPSHOT_22-June-2017
 2: git src       v0.0.1_SNAPSHOT_10-June-2017
 3: git src        v0.0.1_SNAPSHOT_12-Oct-2016
 4: git src       v0.0.1_SNAPSHOT_20-Sept-2016
 5: git src       v0.0.1_SNAPSHOT_22-June-2016
 6: git src        v0.0.1_SNAPSHOT_12-May-2016
 7: git src      v0.0.1_SNAPSHOT_30-March-2016
 8: git src    v0.0.1_SNAPSHOT_26-January-2016
 9: git src   v0.0.1_SNAPSHOT_03-November-2015
10: git src        v0.0.1_SNAPSHOT_23-Sep-2015
11: git src        v0.0.1_SNAPSHOT_10-Sep-2015
12: git src       v0.0.1_SNAPSHOT_29-July-2015
Select master or one of tags which can be built, followed by [ENTER]:

aauser@: epicsarchiverap-sites (master)$ bash 02_aaSetup.bash 

aauser@: epicsarchiverap-sites (master)$ bash 03_aaDeploy.bash

aauser@: epicsarchiverap-sites (master)$ bash systemd_service/archappl_systemd_setup.bash 

aauser@: epicsarchiverap-sites (master)$ sudo systemctl start archappl

aauser@: epicsarchiverap-sites (master)$ sudo systemctl status archappl
● archappl.service - Site-Specific EPICS Archier Appliance
   Loaded: loaded (/home/aauser/epicsarchiverap-sites/systemd_service/../aaService.bash; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2017-09-13 10:49:56 CEST; 4min 41s ago
     Docs: https://jeonghanlee.github.io/epicsarchiverap-sites/
  Process: 11676 ExecStop=/bin/bash -c /home/aauser/epicsarchiverap-sites/systemd_service/..//aaService.bash stop (code=exited, status=0/SUCCESS)
  Process: 13966 ExecStart=/bin/bash -c /home/aauser/epicsarchiverap-sites/systemd_service/..//aaService.bash start (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/archappl.service
           ├─13989 jsvc.exec -server -user tomcat -cp /usr/share/java/apache-commons-daemon.jar:/usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar -XX:MaxMetaspaceSize=256M -XX:...
           ├─13991 jsvc.exec -server -user tomcat -cp /usr/share/java/apache-commons-daemon.jar:/usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar -XX:MaxMetaspaceSize=256M -XX:...
           ├─13997 jsvc.exec -server -user tomcat -cp /usr/share/java/apache-commons-daemon.jar:/usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar -XX:MaxMetaspaceSize=256M -XX:...
           ├─13998 jsvc.exec -server -user tomcat -cp /usr/share/java/apache-commons-daemon.jar:/usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar -XX:MaxMetaspaceSize=256M -XX:...
           ├─14016 jsvc.exec -server -user tomcat -cp /usr/share/java/apache-commons-daemon.jar:/usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar -XX:MaxMetaspaceSize=256M -XX:...
           ├─14017 jsvc.exec -server -user tomcat -cp /usr/share/java/apache-commons-daemon.jar:/usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar -XX:MaxMetaspaceSize=256M -XX:...
           ├─14028 jsvc.exec -server -user tomcat -cp /usr/share/java/apache-commons-daemon.jar:/usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar -XX:MaxMetaspaceSize=256M -XX:...
           └─14032 jsvc.exec -server -user tomcat -cp /usr/share/java/apache-commons-daemon.jar:/usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar -XX:MaxMetaspaceSize=256M -XX:...

Sep 13 10:49:56 icslab-archappl01 bash[13966]: > Web url
Sep 13 10:49:56 icslab-archappl01 bash[13966]: http://icslab-archappl01:17665/mgmt/ui/index.html
Sep 13 10:49:56 icslab-archappl01 bash[13966]: OR
Sep 13 10:49:56 icslab-archappl01 bash[13966]: http://10.4.8.15:17665/mgmt/ui/index.html
Sep 13 10:49:56 icslab-archappl01 bash[13966]: > Log
Sep 13 10:49:56 icslab-archappl01 bash[13966]: /opt/archappl/mgmt/logs/mgmt_catalina.err may help you.
Sep 13 10:49:56 icslab-archappl01 bash[13966]: tail -f /opt/archappl/mgmt/logs/mgmt_catalina.err
Sep 13 10:49:56 icslab-archappl01 bash[13966]: > jsvc pid :If eight numbers are printed below, the jsvc processes are running
Sep 13 10:49:56 icslab-archappl01 bash[13966]: 14032 14028 14017 14016 13998 13997 13991 13989
Sep 13 10:49:56 icslab-archappl01 systemd[1]: Started Site-Specific EPICS Archier Appliance.

aauser@icslab-archappl01: epicsarchiverap-sites (master)$ sudo systemctl stop archappl
● archappl.service - Site-Specific EPICS Archier Appliance
   Loaded: loaded (/home/aauser/epicsarchiverap-sites/systemd_service/../aaService.bash; enabled; vendor preset: disabled)
   Active: inactive (dead) since Wed 2017-09-13 10:55:17 CEST; 4s ago
     Docs: https://jeonghanlee.github.io/epicsarchiverap-sites/
  Process: 15965 ExecStop=/bin/bash -c /home/aauser/epicsarchiverap-sites/systemd_service/..//aaService.bash stop (code=exited, status=0/SUCCESS)
  Process: 13966 ExecStart=/bin/bash -c /home/aauser/epicsarchiverap-sites/systemd_service/..//aaService.bash start (code=exited, status=0/SUCCESS)

Sep 13 10:55:17 icslab-archappl01 bash[15965]: >>>> Status outputs
Sep 13 10:55:17 icslab-archappl01 bash[15965]: > Web url
Sep 13 10:55:17 icslab-archappl01 bash[15965]: http://icslab-archappl01:17665/mgmt/ui/index.html
Sep 13 10:55:17 icslab-archappl01 bash[15965]: OR
Sep 13 10:55:17 icslab-archappl01 bash[15965]: http://10.4.8.15:17665/mgmt/ui/index.html
Sep 13 10:55:17 icslab-archappl01 bash[15965]: > Log
Sep 13 10:55:17 icslab-archappl01 bash[15965]: /opt/archappl/mgmt/logs/mgmt_catalina.err may help you.
Sep 13 10:55:17 icslab-archappl01 bash[15965]: tail -f /opt/archappl/mgmt/logs/mgmt_catalina.err
Sep 13 10:55:17 icslab-archappl01 bash[15965]: > jsvc pid :If eight numbers are printed below, the jsvc processes are running
Sep 13 10:55:17 icslab-archappl01 systemd[1]: Stopped Site-Specific EPICS Archier Appliance.


``` 

--

![Connection Example](aa_site_specific.png)


# Alternative way to setup a site-specific (ESS) EPICS Archiver Appliance with Ansible
Since July, 2017, ESS provide a way to setup the Archiver Appliance with Ansible. If one wants to use the ansible to setup the Archiver Appliance, please visit at  https://bitbucket.org/europeanspallationsource/ics-ans-archappl for further information. Please contact directly the repository owner if one has any questions on it. 


# Acknowledgement
A special word of thanks goes to Murali Shankar who develops the Archiver Appliance and answers my stupid questions again and again and again.
