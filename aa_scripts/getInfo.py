#!/usr/bin/env python
#
#  Copyright (c) 2016 Jeong Han Lee
#  Copyright (c) 2016 European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : Thursday, February 16 16:14:15 CET 2017
# version : 0.0.1
#

import urllib2
import json

# https://slacmshankar.github.io/epicsarchiver_docs/api/org/epics/archiverappliance/mgmt/bpl/package-summary.html


ip="10.0.4.22"
url="http://" + ip
url_mgmt = url + ":17665/mgmt/bpl"

info_list = []



#info_list.append(url_mgmt + "/getAllPVs")
info_list.append(url_mgmt + "/getVersions")
info_list.append(url_mgmt + "/getApplianceInfo")
info_list.append(url_mgmt + "/getAggregatedApplianceInfo")


for info_one in info_list:
    print info_one
    print json.load(urllib2.urlopen(info_one))
    print "\n"

