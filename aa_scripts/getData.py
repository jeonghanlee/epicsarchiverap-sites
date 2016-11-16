#!/usr/bin/python2.7
# coding=utf-8 
#
#  Copyright (c) Jeong Han Lee
#
#  This getData.py is free software: you can redistribute
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
#
# Shell   : getData.py
# Author  : Jeong Han Lee
# email   : jeonghan.lee@gmail.com
# Date    : Tuesday, January  5 10:46:51 CET 2016
# Version : 0.3.0
#
#   * I intend to develop this script in order to extact or get data from
#     Archiver Appliance Service, which is running on an Ethernet accessiable
#     server. This script creates a file per a PV. In one example,
#     
#    # Filename    : /tmp/pi2_dht11_tem.txt
#    # PV name     : PI2:DHT11:TEM
#    # From        : 2014-12-15T19:15:02.200201
#    # To          : 2014-12-22T19:15:02.200201
#    # queryString : ?pv=mean_300(PI2:DHT11:TEM)&from=2014-12-15T19%3A15%3A02.200201%2B09%3A00&to=2014-12-22T19%3A15%3A02.200201%2B09%3A00
#    # hostname    : kaffee
#    # host IP     : 10.1.4.24
#    # 
#    # time, val, nanos, status, severity
#    2014-12-19T11:07:30, 22.4814814815, 0, 0, 0 
#    2014-12-19T11:12:30, 22.45, 0, 0, 0 
#    2014-12-19T11:17:30, 21.6279069767, 0, 0, 0 
#    2014-12-19T11:22:30, 21.4333333333, 0, 0, 0 
#    2014-12-19T11:27:30, 21.4936708861, 0, 0, 0 
#    2014-12-19T11:32:30, 21.4791666667, 0, 0, 0 
#
#     By default, time is the mean over 5 mins.
#
#
#  *******************************************************************************************************
#    Created files are located in /tmp/ and copy them in to $HOME/pvs by default.
#    If the target directory doesn't exist, it will create it. 
#    So from 0.3.0, one should use -t /var/www/data if one wants to use a *static* web site by using
#    SIMILE Timeplot. See http://www.simile-widgets.org/timeplot/
#  *******************************************************************************************************
#
#
#  - 0.0.0  Friday, December 19 10:18:02 KST 2014
#           Created.
#  - 0.1.1  Monday, December 22 19:19:27 KST 2014
#           Real Working Script...
#  - 0.2.0  Monday, March 30 09:36:52 KST 2015, jhlee
#           - Export the selected PV lists based on the input PV list (as input file)
#           - Clean up some lines in code, such as the argument default values, unused variables, 
#  - 0.3.0 Tuesday, January  5 11:18:13 CET 2016, jhlee
#           - introduce src and target location of the extracted file,
#  - 0.4.0 
#    An example in cronjob (crontab -e) in every 5 mins
#
#  
#    AA ip   : 10.0.5.23
#    Target  : /var/www/data
#    Days    : 7
#    PV list : test_pv_list
#    Mean    : 5 mins average data (300 secs)        
#
#*/5 *  * * * export DISPLAY=:0.0 && /usr/bin/python /home/jhlee/scripts_for_epics/archiver.appliance.python/getData.py -i 10.0.5.23 -t /var/www/data/ -d 7 -f test_pv_list -m 300 >/dev/null 2>&1


import os
import sys
import argparse 
import socket
import shutil
# import numpy as np
#from chaco.shell import *

import urllib
import urllib2
import json
from datetime import timedelta, datetime, date


# Theses ports should be the same as appliances.xml
# e.g. /opt/archappl/appliances.xml
#     <mgmt_url>http://10.4.3.86:17665/mgmt/bpl</mgmt_url>
#     <data_retrieval_url>http://10.4.3.86:17668/retrieval</data_retrieval_url>

mgmt_port="17665"
retrieval_port="17668"

# epoch_secs : 
# This is the Java epoch seconds of the EPICS record processing timestamp. 
# The times are in UTC; so any conversion to local time needs to happen at the client. 

def convertDate(epoch_secs):
    _date = datetime.fromtimestamp(epoch_secs)
    return _date.isoformat()


def setMGMTurl(url):
    return url + ":" + mgmt_port + "/mgmt/bpl/"

def print_data_info(element):
    #  {u'nanos': 887037220, u'status': 0, u'secs': 1418979266, u'severity': 0, u'val': 24.0}
    print element.nanos
    return 

def setJsonRetUrl(url):
    return url + ":" + retrieval_port + "/retrieval/data/getData.json"

def setRawRetUrl(url):
    return url + ":" + retrieval_port + "/retrieval/data/getData.raw"



def getSelectedPVs(url, args):

    pv_list = []
    #
    #   Want to use "list" because pv_list, which is "return values from AA" is list
    #    
    if args.file :
        script_path    = os.path.dirname(os.path.realpath(__file__))
        input_filename = script_path + "/" + args.file
        lines          = [line.strip() for line in open(input_filename)]
    else:
        # no input filter file exists, set all PVs
        lines = ['*']

    if args.verbose:
        print "getSelectedPVs function "
        print "url, args      :", url, args
        print "script_path    :", script_path
        print "input_filename :", input_filename
        print "type, lines    :", type(lines), lines
        print "pattern        :", args.pattern
        

    url_src = url + "getAllPVs" + args.pattern

    if args.verbose : print "GetAllPV url : ", url_src

    resp    = urllib2.urlopen(url_src)
    patternMatchingPVs = json.load(resp)

    pv_list.extend(patternMatchingPVs)
   
    # filter file has * or no filter file,
    # return all PVs with "pattern"
    if '*' in lines:
        if args.verbose: print pv_list
        return pv_list
    # if the filter file has some selected PVs,
    # return only the matched "selected PV" from all PVs with "pattern"
    else:
        selectedPVs=set(pv_list).intersection(set(lines))
        if args.verbose: print selectedPVs
        return selectedPVs





def main():

    #   https://docs.python.org/2/howto/argparse.html
    parser = argparse.ArgumentParser()

    parser.add_argument("-i", "--ip",      help="Archiver Appliance IP address", default="10.4.3.86")
    parser.add_argument("-p", "--pattern", help="?pv=xxx&limit=nnn",  default ="")
    # "?pv=*calc*"
    # -p "?limit=100"
    parser.add_argument("-v", "--verbose", help="output verbosity",              action="store_true")
    parser.add_argument("-d", "--days",    help="days to monitor from now", type=float, default=1.0)
    parser.add_argument("-f", "--file",    help="filename which has selected PV list",  default="test_pv_list")
    parser.add_argument("-s", "--src",     help="source location of generated data file", default="/tmp/")
    parser.add_argument("-t", "--target",  help="target location of data file", default= os.environ['PWD'] )
    parser.add_argument("-m", "--mean",    help="data average during secs", default="")
    
    args = parser.parse_args()


    url = "http://" + args.ip

    if args.verbose:
        print ""
        print ">>>" 
        print ">>> Default URL and Pattern are used as follows:"
        print ">>>  URL :" + url
        print ">>>  Pattern : " + args.pattern
        print ">>>  Source  : " + args.src
        print ">>>  Target  : " + args.target
        print ">>>"

    matchingPVs = []
    matchingPVs = getSelectedPVs(setMGMTurl(url), args)
    
        
    if matchingPVs:

        _now  = datetime.now()
        _from = _now - timedelta(days=args.days)

        _from_iso_string = _from.isoformat()
        _now_iso_string  = _now.isoformat()
        
        fromString       = urllib.urlencode( {'from' : _from_iso_string} ) 
        toString         = urllib.urlencode( {'to'   : _now_iso_string } )

        #   userString = urllib.urlencode( {'userreduced' : "true"} )
        
        #    _from        = datetime(2014,12,19,17,40,00,00)
        #    _from_string = _from.strftime("%Y-%m-%dT%H:%M:%S")
        #    _now_string  = _now.strftime ("%Y-%m-%dT%H:%M:%S")
        #    "From" and "To" have the iso time format at  http://epicsarchiverap.sourceforge.net/userguide.html
        #    Python datetime has the isoformat at https://docs.python.org/2/library/datetime.html
        #    Monday, December 22 13:42:51 KST 2014, jhlee
        

        
        #   Still don't understand what the following Strings means,
        #   get the structure form archiveViewer, and simply add only 
        #   magicString to queryString  
        #  
        #   Monday, December 22 10:40:19 KST 2014, jhlee
        #
        magicString = "%2B09%3A00"
        # http://en.wikipedia.org/wiki/Percent-encoding
        # %2B : "+"
        # %3A : ":"
        # userString  = "&usereduced=true"
        # cahowString = "&ca_how=0"
        # cacountString = "&ca_count=1907"
        
        suffixString = magicString
        # suffixString = magicString# + userString + cahowString + cacountString
        
        if args.verbose:
            print "fromString : ",  fromString
            print "toString   : ",  toString
            print ""
            
        hostname = socket.gethostname() 
        hostip   = socket.gethostbyname(hostname)

        if args.verbose:
            print "hostname : ", hostname
            print "hostip   : ", hostip
            
        report_filename = ""
        dest_directory = args.target + "/"
    
        if not os.path.exists(dest_directory):
            os.makedirs(dest_directory)

            
        mean_sstring = ""
        mean_estring = ""
        
        if args.mean:
            mean_sstring += 'mean_' + args.mean + '('
            mean_estring += ')'
            
        for pv in sorted(matchingPVs):
            
            if args.verbose:
                print pv
                
                
            report_filename = args.src + pv.replace(":", "_").lower() + ".txt"
            queryString = '?pv='
            queryString += mean_sstring 
            queryString += pv
            queryString += mean_estring
            queryString += '&'
            queryString += fromString 
            queryString += magicString
            queryString += '&'
            queryString += toString 
            queryString += suffixString

            if args.verbose:
                print "queryString : ",  queryString
                print "url : ", url

            src_url=setJsonRetUrl(url) + queryString

            if args.verbose:
                print src_url

            dataresp = urllib2.urlopen(src_url)
            data     = json.load(dataresp)
            

   
                 
            if data :

                if args.verbose:  print "Total Data Size " , len(data[0]['data'])

                try :
                    file = open(report_filename, "w")
                    file.write("# \n")
                    file.write("# Filename    : " + report_filename  + "\n")
                    file.write("# PV name     : " + pv               + "\n")
                    file.write("# From        : " + _from_iso_string + "\n")
                    file.write("# To          : " + _now_iso_string  + "\n")
                    file.write("# queryString : " + queryString      + "\n")
                    file.write("# hostname    : " + hostname         + "\n")
                    file.write("# host IP     : " + hostip           + "\n")
                    file.write("# \n")
                    file.write("# time, val, nanos, status, severity    \n")
                    
                    dataList = []
                    
                    for el in data[0]['data']:
                        #         #        if args.verbose:
                        #         #            print "%s, %s, %s, %s, %s " % (convertDate(el['secs']), el['val'], el['nanos'], el['status'], el['severity'])
                        dataList.append("%s, %s, %s, %s, %s \n" % (convertDate(el['secs']), el['val'], el['nanos'], el['status'], el['severity']))
                        
                    s = ''.join(dataList)
                        
                    file.write(s)
                    file.close()

                    try :
                        shutil.copy (report_filename, dest_directory)
                    except shutil.Error as e:
                        print('Error: %s' % e)
                        # eg. source or destination doesn't exist
                    except IOError as e:
                        print('Error: %s' % e.strerror)

                except IOError, (errno, strerror):
                    print "I/O error(%s): %s" % (errno, strerror)

            else:
                if args.verbose:  print "data no", pv

    sys.exit()

if __name__ == '__main__': main()

