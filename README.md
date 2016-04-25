EPICS Archiver Appliance Site Specific Test Environment
=================

# Purpose

* To develop a way to build a site-specific build Archiver Appliance in order to sync or maintain easily with the main repository. 

* Due to lack of my knowledge and some warnings from experts, I am using the simplest model of using submodules which is found in https://git-scm.com/book/en/v2/Git-Tools-Submodules


> The simplest model of using submodules in a project would be if you were simply consuming a subproject and wanted to get updates from it from time to time but were not actually modifying anything in your checkout.

  So I DO NOT change any sub modules in this branch (work), DO NOT commit my local changes to the original repositories. 



# Commands


## Clone

* Command set 1
```
git clone -b workhttps://github.com/jeonghanlee/epicsarchiverap-sites.git
cd epicsarchiverap-sites/
git submodule init
git submodule update
```

* Command set 2
```
git clone --recursive  https://github.com/jeonghanlee/epicsarchiverap-sites.git
```

# add a submodule

* add it into 

```
git submodule add https://github.com/slacmshankar/epicsarchiverap epicsarchiverap
```

* modify .gitmodule
```
[submodule "epicsarchiverap"]
        path = epicsarchiverap
        url = https://github.com/slacmshankar/epicsarchiverap
        branch = master
        ignore = dirty
```

* push it to the working branch
