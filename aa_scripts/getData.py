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
# Date    : Thursday, November 24 12:19:25 CET 2016
# Version : 0.4.3
#
#  - 0.0.0  Friday, December 19 10:18:02 KST 2014
#           Created.
#  - 0.1.1  Monday, December 22 19:19:27 KST 2014
#           Real Working Script...
#  - 0.2.0  Monday, March 30 09:36:52 KST 2015, jhlee
#           - Export the selected PV lists based on the input PV list (as input file)
#           - Clean up some lines in code, such as the argument default values, unused variables, 
#  - 0.3.0  Tuesday, January  5 11:18:13 CET 2016, jhlee
#           - introduce src and target location of the extracted file,
#  - 0.4.0  Thursday, November 17 12:30:40 CET 2016
#           - clean up and fix the pattern
#  - 0.4.1  Wednesday, November 23 13:50:36 CET 2016,
#           - fix the hard-coded local time according to UTC
#           - add "archived" the entire target directory in target path
#           - remove the intermediate path
#  - 0.4.2  Thursday, November 24 12:17:39 CET 2016
#           - use ftime as the directory and zip file names
#           - add the remove function in valid with zip option.  
#  - 0.4.3 Friday, November 25 09:34:01 CET 2016
#           - add import errno
#  
#    An example in cronjob (crontab -e) in every 5 mins
#
#  
#    AA ip   : 10.4.3.86
#    Target  : /var/www/data
#    Days    : 1
#    PV list : test_ioc_pv_list
#    Mean    : no

# */5 *  * * * export DISPLAY=:0.0 && /usr/bin/python /home/aauser/epicsarchiverap-sites/aa_scripts/getData.py -i 10.4.3.86 -d 1 -t /var/www/data/ -f ics_pv_list -z  >/dev/null 2>&1

# Get date from Archiver Appliance to put them in ${HOME}/Archappl_ipaddress/CURRENT_TIME
# Compress that directory and put them in ${HOME}/Archappl_ipaddress/
# /usr/bin/python /home/aauser/epicsarchiverap-sites/aa_scripts/getData.py -i 10.0.4.22 -d 1  -t ${HOME} -z -f test_ioc_pv_list
# /usr/bin/python /home/aauser/epicsarchiverap-sites/aa_scripts/getData.py -i 10.0.4.22 -d 1  -f test_ioc_pv_list -t ${HOME} -z
# /usr/bin/python /home/aauser/epicsarchiverap-sites/aa_scripts/getData.py -i 10.0.4.22 -d 1  -f test_ioc_pv_list -t ${HOME} -z -rm




import os
import sys
import argparse 
import socket
import shutil
import errno

import urllib
import urllib2
import json

from datetime import timedelta, datetime, time, date, tzinfo
from shutil import make_archive

# Theses ports should be the same as appliances.xml
# e.g. /opt/archappl/appliances.xml
#     <mgmt_url>http://10.4.3.86:17665/mgmt/bpl</mgmt_url>
#     <data_retrieval_url>http://10.4.3.86:17668/retrieval</data_retrieval_url>

mgmt_port="17665"
retrieval_port="17668"


# Time difference should has two digits

def pri(n):
    return "%02d" % n

# epoch_secs : 
# This is the Java epoch seconds of the EPICS record processing timestamp. 
# The times are in UTC; so any conversion to local time needs to happen at the client. 

def convertDate(epoch_secs):
    _date = datetime.fromtimestamp(epoch_secs)
    return _date.isoformat()


def print_data_info(element):
    #  {u'nanos': 887037220, u'status': 0, u'secs': 1418979266, u'severity': 0, u'val': 24.0}
    print element.nanos
    return 


def setMGMTurl(url):
    return url + ":" + mgmt_port + "/mgmt/bpl/"

def setJsonRetUrl(url):
    return url + ":" + retrieval_port + "/retrieval/data/getData.json"

def setRawRetUrl(url):
    return url + ":" + retrieval_port + "/retrieval/data/getData.raw"


def getSelectedPVs(url, args):

    script_path    = os.path.dirname(os.path.realpath(__file__))
    pv_list = []
    script_path    = os.path.dirname(os.path.realpath(__file__))  

    #
    #   Want to use "list" because pv_list, which is "return values from AA" is list
    #    
    if args.file :
        input_filename = script_path + "/" + args.file
        lines          = [line.strip() for line in open(input_filename)]
    else:
        # no input filter file exists, set all PVs
        input_filename =""
        lines = ['*']


    url_src = url + "getAllPVs" + args.pattern

    if args.verbose : 
        print "getSelectedPVs function "
        print "url, args      :", url, args
        print "script_path    :", script_path
        if args.file : 
            print "input_filename :", input_filename
            print "type, lines    :", type(lines), lines
        if args.pattern: 
            print "pattern        :", args.pattern

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

def remove_folder(path):
    # check if folder exists
    if os.path.exists(path):
         # remove if exists
         shutil.rmtree(path)





def main():

    #   https://docs.python.org/2/howto/argparse.html
    parser = argparse.ArgumentParser()

    parser.add_argument("-i", "--ip",      help="Archiver Appliance IP address", default="10.4.3.86")
    parser.add_argument("-p", "--pattern", help="?pv=xxx&limit=nnn",  default ="")
    # "?pv=*calc*"
    # -p "?limit=100"
    parser.add_argument("-v", "--verbose",  help="output verbosity",              action="store_true")
    parser.add_argument("-d", "--days",     help="days to monitor from now", type=float, default=1.0)
    parser.add_argument("-f", "--file",     help="filename which has selected PV list",  default="")
    #    parser.add_argument("-im", "--intermediate",  help="put the files in the intermediate dir first", default="")
    # parser.add_argument("-t", "--target",   help="target location of data file", default=os.environ['HOME'] )
    parser.add_argument("-m", "--mean",     help="data average during secs", default="")
    parser.add_argument("-z", "--zip",      help="output files are zippped", action="store_true")
    parser.add_argument("-rm", "--remove",   help="delete the target directory after creating a zip", action="store_true")
    parser.add_argument("-t", "--targetpath", help="put the files in a directory directly", default=os.environ['HOME'] )
    
    args = parser.parse_args()


    url = "http://" + args.ip

    if args.verbose:
        print ""
        print ">>>" 
        print ">>> Default URL and Pattern are used as follows:"
        print ">>>  URL :" + url
        print ">>>  Pattern : " + args.pattern
#        print ">>>  Source  : " + args.intermediate
        print ">>>  Target  : " + args.targetpath
        print ">>>"


    matchingPVs = []
    matchingPVs = getSelectedPVs(setMGMTurl(url), args)
    
        
    if matchingPVs:

        # Python datetime has the isoformat at https://docs.python.org/2/library/datetime.html
        _now     = datetime.now()
        _utc_now = datetime.utcnow()
     

        _delta   =  _now - _utc_now
        
        _delta_hh,_delta_mm = divmod((_delta.days * 24*60*60 + _delta.seconds + 30) // 60, 60)

        _from = _now - timedelta(days=args.days)

        _from_iso_string = _from.isoformat()
        _now_iso_string  = _now.isoformat()
        _now_ftime_string = _now.strftime("%Y%m%e-%H%M%S");

        fromString       = urllib.urlencode( {'from' : _from_iso_string} ) 
        toString         = urllib.urlencode( {'to'   : _now_iso_string } )
       
        # http://en.wikipedia.org/wiki/Percent-encoding
        # %2B : "+"
        # %3A : ":"
        tzString = "%2B"
        tzString += pri(_delta_hh)
        tzString += "%3A"
        tzString += pri(_delta_mm)
      
        # userString  = "&usereduced=true"
        # cahowString = "&ca_how=0"
        # cacountString = "&ca_count=1907"
        

        # Add the Time difference between UTC and the local time
        suffixString = tzString
        # suffixString = magicString# + userString + cahowString + cacountString
        
        fromString += suffixString
        toString   += suffixString

        if args.verbose:
            print "fromString : ",  fromString
            print "toString   : ",  toString
            print ""
            
        hostname = socket.gethostname() 
        hostip   = socket.gethostbyname(hostname)

        if args.verbose:
            print "hostname : ", hostname
            print "hostip   : ", hostip
            
           
        mean_sstring = ""
        mean_estring = ""
        
        if args.mean:
            mean_sstring += 'mean_' + args.mean + '('
            mean_estring += ')'
            

#        if args.intermediate:
#            intermediate_directory = args.intermediate + "/";
        if args.targetpath.startswith('/') : 
            target_path = args.targetpath + "/";
        else:
            print "\nAbsolute TARGET PATH is needed";
            sys.exit()

        target_path += "Archappl_" + args.ip + "/";
        
        target_path_per_each_call = target_path + _now_ftime_string + "/";
    
        if not os.path.exists(target_path_per_each_call):
            try:
                os.makedirs(target_path_per_each_call)

            except OSError as exc:
                if exc.errno != errno.EEXIST:
                    raise exc
                pass

                    
        for pv in sorted(matchingPVs):
           
            if args.verbose:
                print pv
    
            report_filename = pv.replace(":", "_").lower() + ".txt"
            queryString = '?pv='
            queryString += mean_sstring 
            queryString += pv
            queryString += mean_estring
            queryString += '&'
            queryString += fromString 
            queryString += '&'
            queryString += toString 


            src_url=setJsonRetUrl(url) + queryString


            if args.verbose:
                print "queryString : ",  queryString
                print "url         : ", url
                print "source url  : ", src_url


            dataresp = urllib2.urlopen(src_url)
            data     = json.load(dataresp)
            
            if data :
    
                if args.verbose:  print "Total Data Size " , len(data[0]['data'])

                try :
#                    if args.intermediate:
#                        
 #                       file = open(intermediate_directory + report_filename, "w");
 #                   else :
                    file = open(target_path_per_each_call  + report_filename, "w")

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
 
                    # if args.intermediate:
                    #     try :
                        #     shutil.copy (intermediate_directory + report_filename, target_path_per_each_call)
        
                        # except shutil.Error as e:
                        #     print('Error: %s' % e)
                        #     # eg. source or destination doesn't exist
                        # except IOError as e:
                        #     print('Error: %s' % e.strerror)

                
                except IOError, (errno, strerror):
                    print "I/O error(%s): %s" % (errno, strerror)



            else:
                if args.verbose:  print "data no", pv

        if args.zip:
               
            base_name = _now_ftime_string 
            base_dir  = target_path_per_each_call
            root_dir  = target_path
            if args.verbose:
                print "Base name : ", base_name
                print "Base dir  : ", base_dir
                print "root dir  : ", root_dir

            try : 
                os.chdir(root_dir)
                shutil.make_archive(base_name, 'zip', target_path_per_each_call)
                if args.remove:
                    try : 
                        remove_folder(target_path_per_each_call)
                    except OSError as e: 
                        if e.errno != errno.ENOENT: 
                            raise 

            except shutil.Error as e:
                print('Error: %s' % e)
            except IOError as e:
                print('Error: %s' % e.strerror)


    sys.exit()

if __name__ == '__main__': main()

