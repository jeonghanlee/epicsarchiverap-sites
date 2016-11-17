#!/usr/bin/env python
import urllib2
import json


allPVs = json.load(urllib2.urlopen("http://10.4.3.86:17665/mgmt/bpl/getAllPVs"))
aa_info= json.load(urllib2.urlopen("http://10.4.3.86:17665/mgmt/bpl/getApplianceInfo"))
version_info = json.load(urllib2.urlopen("http://10.4.3.86:17665/mgmt/bpl/getVersions"))

print aa_info
print ""
print version_info

for pv in allPVs:
    print pv
