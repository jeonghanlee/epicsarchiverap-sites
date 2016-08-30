You are in epicsarchiverap-sites, and do clone the main repository

```

aauser@ics-tag348 epicsarchiverap-sites]$ git clone https://github.com/slacmshankar/epicsarchiverap
Cloning into 'epicsarchiverap'...
remote: Counting objects: 5047, done.
remote: Total 5047 (delta 0), reused 0 (delta 0), pack-reused 5047
Receiving objects: 100% (5047/5047), 56.28 MiB | 11.18 MiB/s, done.
Resolving deltas: 100% (2508/2508), done.
[aauser@ics-tag348 epicsarchiverap-sites]$ cd epicsarchiverap/

[aauser@ics-tag348 epicsarchiverap]$ git tag -l
v0.0.1_SNAPSHOT_03-November-2015
v0.0.1_SNAPSHOT_10-Sep-2015
v0.0.1_SNAPSHOT_12-May-2016
v0.0.1_SNAPSHOT_22-June-2016
v0.0.1_SNAPSHOT_23-Sep-2015
v0.0.1_SNAPSHOT_26-January-2016
v0.0.1_SNAPSHOT_29-July-2015
v0.0.1_SNAPSHOT_30-March-2016


[aauser@ics-tag348 epicsarchiverap]$  git checkout tags/v0.0.1_SNAPSHOT_22-June-2016
Note: checking out 'tags/v0.0.1_SNAPSHOT_22-June-2016'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b new_branch_name

HEAD is now at cb5e83b... getAllPVs without the pv argument should include aliases

```

I added already epicsarchiverap in .gitignore, so git status returns nothing.


```
[aauser@ics-tag348 epicsarchiverap-sites]$ git status
# On branch master
nothing to commit, working directory clean
```


[root@ics-tag348 epicsarchiverap-sites]# yum install ant


[aauser@ics-tag348 epicsarchiverap]$ pwd
/home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap

[aauser@ics-tag348 epicsarchiverap]$ export TOMCAT_HOME=/usr/share/tomcat

[aauser@ics-tag348 epicsarchiverap]$ ant

Buildfile: /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/build.xml
     [echo] Building the archiver appliance for the site tests

clean:

compile:
    [mkdir] Created dir: /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/bin
    [javac] Compiling 560 source files to /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/bin

stage:
    [mkdir] Created dir: /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/stage
     [copy] Copying 33 files to /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/stage/org/epics/archiverappliance/staticcontent
     [copy] Copying 2 files to /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/stage/org/epics/archiverappliance/retrieval/staticcontent
      [zip] Warning: skipping zip archive /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/stage/org/epics/archiverappliance/retrieval/staticcontent/viewer.zip because no files were included.
     [copy] Copying 12 files to /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/stage/org/epics/archiverappliance/mgmt/staticcontent

sitespecificbuild:

retrieval_war:
     [copy] Copying 3 files to /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/bin
      [war] Building war: /home/aauser/gitsrc/epicsarchiverap-sites/retrieval.war

engine_war:
      [war] Building war: /home/aauser/gitsrc/epicsarchiverap-sites/engine.war

etl_war:
      [war] Building war: /home/aauser/gitsrc/epicsarchiverap-sites/etl.war

javadoc:
    [mkdir] Created dir: /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/docs/api
  [javadoc] Generating Javadoc

.....................
.....................
.....................



  [javadoc] Building index for all the packages and classes...
  [javadoc] Building index for all classes...
  [javadoc] Generating /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/docs/api/help-doc.html...
  [javadoc] 60 errors
  [javadoc] 100 warnings
     [copy] Copying 1 file to /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/docs
     [copy] Copying 1 file to /home/aauser/gitsrc/epicsarchiverap-sites/epicsarchiverap/docs

mgmt_war:
      [war] Building war: /home/aauser/gitsrc/epicsarchiverap-sites/mgmt.war

generate_release_notes:

wars:
      [tar] Building tar: /home/aauser/gitsrc/epicsarchiverap-sites/archappl_v0.0.1_SNAPSHOT_24-August-2016T16-57-58.tar.gz

BUILD SUCCESSFUL
Total time: 33 seconds



