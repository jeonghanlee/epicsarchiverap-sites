[aauser@localhost ~]$ wget -c https://raw.githubusercontent.com/jeonghanlee/epicsarchiverap-sites/develop/aa_init.bash

[aauser@localhost ~]$ bash aa_init.bash 

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for aauser: 
[aauser@localhost ~]$ cd epicsarchiverap-sites/
[aauser@localhost epicsarchiverap-sites]$ bash 00_preAA.bash 

aauser@localhost epicsarchiverap-sites]$ bash 01_aaBuild.bash 
<<<< You are leaving from git_clone
 0: git src                             master
 1: git src   v0.0.1_SNAPSHOT_03-November-2015
 2: git src        v0.0.1_SNAPSHOT_10-Sep-2015
 3: git src        v0.0.1_SNAPSHOT_12-May-2016
 4: git src        v0.0.1_SNAPSHOT_12-Oct-2016
 5: git src       v0.0.1_SNAPSHOT_20-Sept-2016
 6: git src       v0.0.1_SNAPSHOT_22-June-2016
 7: git src        v0.0.1_SNAPSHOT_23-Sep-2015
 8: git src    v0.0.1_SNAPSHOT_26-January-2016
 9: git src       v0.0.1_SNAPSHOT_29-July-2015
10: git src      v0.0.1_SNAPSHOT_30-March-2016
Select master or one of tags which can be built, followed by [ENTER]:0
Select master or one of tags which can be built, followed by [ENTER]:0

>>> Selected                             master --- 
[aauser@localhost epicsarchiverap-sites]$ sudo su

[root@localhost epicsarchiverap-sites]# bash 02_aaSetup.bash 
[root@localhost epicsarchiverap-sites]# bash 03_aaDeploy.bash 
[root@localhost epicsarchiverap-sites]# bash aaService.bash start
bash aaService.bash stop


