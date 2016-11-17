# Example to run the getData.py script


# A Cronjob
* -i : ip address :  10.4.3.86
* -d : days to monitor from now" : 1
* -t : target output file dir : /var/www/data
```
*/5 *  * * * export DISPLAY=:0.0 && /usr/bin/python /home/aauser/epicsarchiverap-sites/aa_scripts/getData.py -i 10.4.3.86 -d 1 -t /var/www/data/ -f ics_pv_list  >/dev/null 2>&1
```

# a normal user

* -i : ip address :  10.4.3.86
* -d : days to monitor from now" : 1
* -s : raw output file dir (src) - intermediate stage : /tmp
* -t : target output file dir : $PWD
* -m : no mean (secs)  - raw archived data : 
* -v : verbose  : want to see any progress while running this script
* -p : pattern  : getAllPVs options : "?pv=aauser:*&limit=100"
## 

* Get all PVs from 10.4.3.86, and save them in pv dir

```
$ python getData.py -i 10.4.3.86 -t ./pvs

$ ls pvs
aauser_ai1.txt  aauser_ai3.txt         aauser_aiexample2.txt  aauser_aiexample.txt    aauser_calc1.txt  aauser_calc3.txt         aauser_calcexample2.txt  aauser_calcexample.txt
aauser_ai2.txt  aauser_aiexample1.txt  aauser_aiexample3.txt  aauser_asubexample.txt  aauser_calc2.txt  aauser_calcexample1.txt  aauser_calcexample3.txt

$ head -n 20  pvs/aauser_calc1.txt 
# 
# Filename    : /tmp/aauser_calc1.txt
# PV name     : aauser:calc1
# From        : 2016-11-16T12:26:00.037991
# To          : 2016-11-17T12:26:00.037991
# queryString : ?pv=aauser:calc1&from=2016-11-16T12%3A26%3A00.037991%2B09%3A00&to=2016-11-17T12%3A26%3A00.037991%2B09%3A00
# hostname    : archiver02
# host IP     : 10.4.3.86
# 
# time, val, nanos, status, severity    
2016-11-16T04:25:59, 8.0, 750274004, 3, 2 
2016-11-16T04:26:00, 9.0, 750281404, 3, 2 
2016-11-16T04:26:01, 0.0, 750282395, 5, 2 
2016-11-16T04:26:02, 1.0, 750284686, 5, 2 
2016-11-16T04:26:03, 2.0, 750280592, 5, 2 
2016-11-16T04:26:04, 3.0, 750289207, 6, 1 
2016-11-16T04:26:05, 4.0, 750278684, 6, 1 
2016-11-16T04:26:06, 5.0, 750281975, 0, 0 
2016-11-16T04:26:07, 6.0, 750281163, 4, 1 
2016-11-16T04:26:08, 7.0, 750285106, 4, 1 

$ wc -l pvs/aauser_calc1.txt 
86411 pvs/aauser_calc1.txt

```


* Get defined PVs in test_ioc_pv_list from 10.4.3.86 with 2 days ago and 1min mean and verbose in pvs dir


```
$ cat test_ioc_pv_list
aauser:aSubExample
aauser:aiExample
aauser:aiExample1
aauser:aiExample2
aauser:aiExample3
aauser:calcExample
aauser:calcExample1
aauser:calcExample2
aauser:calcExample3
aauser:subExample
aauser:ai2
aauser:calc2
aauser:calc3
aauser:ai3
aauser:ai1
aauser:calc1
```

```
$ python getData.py -i 10.4.3.86 -t ./pvs -d 2 -f test_pv_list -m 60

$ head -n 20  pvs/aauser_calc1.txt 
# 
# Filename    : /tmp/aauser_calc1.txt
# PV name     : aauser:calc1
# From        : 2016-11-15T12:27:30.463180
# To          : 2016-11-17T12:27:30.463180
# queryString : ?pv=mean_60(aauser:calc1)&from=2016-11-15T12%3A27%3A30.463180%2B09%3A00&to=2016-11-17T12%3A27%3A30.463180%2B09%3A00
# hostname    : archiver02
# host IP     : 10.4.3.86
# 
# time, val, nanos, status, severity    
2016-11-15T04:27:30, 4.61290322581, 0, 0, 2 
2016-11-15T04:28:30, 4.5, 0, 0, 2 
2016-11-15T04:29:30, 4.5, 0, 0, 2 
2016-11-15T04:30:30, 4.5, 0, 0, 2 
2016-11-15T04:31:30, 4.5, 0, 0, 2 
2016-11-15T04:32:30, 4.5, 0, 0, 2 
2016-11-15T04:33:30, 4.5, 0, 0, 2 
2016-11-15T04:34:30, 4.5, 0, 0, 2 
2016-11-15T04:35:30, 4.5, 0, 0, 2 
2016-11-15T04:36:30, 4.5, 0, 0, 2 

$ wc -l pvs/aauser_calc1.txt 
2891 pvs/aauser_calc1.txt


```

* Get pvs from 10.4.3.86
** Get All PVs from Archiver Appliance  (can be limited by -p "?limit=100") 
** Check whether PV has the pattern "*calc*" (?pv=*calc*)
** Return the matched PVs
** 7 day ago data from now
** extracted ascii files are in pvs directory
** the combined pattern should be "?pv=*calc*&limit=100"".

```
$ python getData.py -i 10.4.3.86 -t ./pvs -d 7 -p "?pv=*calc*"
$ ls pvs/
aauser_calc1.txt  aauser_calc2.txt  aauser_calc3.txt  aauser_calcexample1.txt  aauser_calcexample2.txt  aauser_calcexample3.txt  aauser_calcexample.txt


$ ls pvs/
aauser_calc1.txt  aauser_calc2.txt  aauser_calc3.txt  aauser_calcexample1.txt  aauser_calcexample2.txt  aauser_calcexample3.txt  aauser_calcexample.txt

$ head -n 20  pvs/aauser_calc1.txt 
# 
# Filename    : /tmp/aauser_calc1.txt
# PV name     : aauser:calc1
# From        : 2016-11-10T12:22:29.353747
# To          : 2016-11-17T12:22:29.353747
# queryString : ?pv=aauser:calc1&from=2016-11-10T12%3A22%3A29.353747%2B09%3A00&to=2016-11-17T12%3A22%3A29.353747%2B09%3A00
# hostname    : archiver02
# host IP     : 10.4.3.86
# 
# time, val, nanos, status, severity    
2016-11-10T11:28:34, 1.0, 394066777, 5, 2 
2016-11-10T11:28:35, 2.0, 394033344, 5, 2 
2016-11-10T11:28:36, 3.0, 394061172, 6, 1 
2016-11-10T11:28:37, 4.0, 394015823, 6, 1 
2016-11-10T11:28:38, 5.0, 394030039, 0, 0 
2016-11-10T11:28:39, 6.0, 394059135, 4, 1 
2016-11-10T11:28:40, 7.0, 394049587, 4, 1 
2016-11-10T11:28:41, 8.0, 394016341, 3, 2 
2016-11-10T11:28:42, 9.0, 394051704, 3, 2 
2016-11-10T11:28:43, 0.0, 394022244, 5, 2 

$ wc -l pvs/aauser_calc1.txt 
579024 pvs/aauser_calc1.txt

```


* Get pvs from 10.4.3.86 with 1 days ago and verbose in pvs dir
** Get All PVs defined in test_ioc_pv_list from Archiver Appliance 
** Check whether PV has the pattern "*calc?"
** Return the matched PVs
** 1 day ago data from now
** extracted ascii files are in pvs directory
** verbose output

```
$ python getData.py -i 10.4.3.86 -t ./pvs -d 1 -f test_pv_list -p "?pv=*calc?" -v

>>>
>>> Default URL and Pattern are used as follows:
>>>  URL :http://10.4.3.86
>>>  Pattern : ?pv=*calc?
>>>  Source  : /tmp/
>>>  Target  : ./pvs
>>>
getSelectedPVs function 
url, args      : http://10.4.3.86:17665/mgmt/bpl/ Namespace(days=1.0, file='test_pv_list', ip='10.4.3.86', mean='', pattern='?pv=*calc?', src='/tmp/', target='./pvs', verbose=True)
script_path    : /home/aauser/epicsarchiverap-sites/aa_scripts
input_filename : /home/aauser/epicsarchiverap-sites/aa_scripts/test_pv_list
type, lines    : <type 'list'> ['*']
pattern        : ?pv=*calc?
GetAllPV url :  http://10.4.3.86:17665/mgmt/bpl/getAllPVs?pv=*calc?
[u'aauser:calc2', u'aauser:calc3', u'aauser:calc1']
fromString :  from=2016-11-16T12%3A12%3A19.316284
toString   :  to=2016-11-17T12%3A12%3A19.316284

hostname :  archiver02
hostip   :  10.4.3.86
aauser:calc1
queryString :  ?pv=aauser:calc1&from=2016-11-16T12%3A12%3A19.316284%2B09%3A00&to=2016-11-17T12%3A12%3A19.316284%2B09%3A00
url :  http://10.4.3.86
http://10.4.3.86:17668/retrieval/data/getData.json?pv=aauser:calc1&from=2016-11-16T12%3A12%3A19.316284%2B09%3A00&to=2016-11-17T12%3A12%3A19.316284%2B09%3A00
Total Data Size  86401
aauser:calc2
queryString :  ?pv=aauser:calc2&from=2016-11-16T12%3A12%3A19.316284%2B09%3A00&to=2016-11-17T12%3A12%3A19.316284%2B09%3A00
url :  http://10.4.3.86
http://10.4.3.86:17668/retrieval/data/getData.json?pv=aauser:calc2&from=2016-11-16T12%3A12%3A19.316284%2B09%3A00&to=2016-11-17T12%3A12%3A19.316284%2B09%3A00
Total Data Size  43201
aauser:calc3
queryString :  ?pv=aauser:calc3&from=2016-11-16T12%3A12%3A19.316284%2B09%3A00&to=2016-11-17T12%3A12%3A19.316284%2B09%3A00
url :  http://10.4.3.86
http://10.4.3.86:17668/retrieval/data/getData.json?pv=aauser:calc3&from=2016-11-16T12%3A12%3A19.316284%2B09%3A00&to=2016-11-17T12%3A12%3A19.316284%2B09%3A00
Total Data Size  17281


$ ls pvs/
aauser_calc1.txt  aauser_calc2.txt  aauser_calc3.txt


$ head -n 20  pvs/aauser_calc1.txt 
# 
# Filename    : /tmp/aauser_calc1.txt
# PV name     : aauser:calc1
# From        : 2016-11-16T12:24:38.112538
# To          : 2016-11-17T12:24:38.112538
# queryString : ?pv=aauser:calc1&from=2016-11-16T12%3A24%3A38.112538%2B09%3A00&to=2016-11-17T12%3A24%3A38.112538%2B09%3A00
# hostname    : archiver02
# host IP     : 10.4.3.86
# 
# time, val, nanos, status, severity    
2016-11-16T04:24:37, 6.0, 750285652, 4, 1 
2016-11-16T04:24:38, 7.0, 750294893, 4, 1 
2016-11-16T04:24:39, 8.0, 750268976, 3, 2 
2016-11-16T04:24:40, 9.0, 750273671, 3, 2 
2016-11-16T04:24:41, 0.0, 750269828, 5, 2 
2016-11-16T04:24:42, 1.0, 750279944, 5, 2 
2016-11-16T04:24:43, 2.0, 750266095, 5, 2 
2016-11-16T04:24:44, 3.0, 750282152, 6, 1 
2016-11-16T04:24:45, 4.0, 750268139, 6, 1 
2016-11-16T04:24:46, 5.0, 750275814, 0, 0

$ wc -l pvs/aauser_calc1.txt 
86411 pvs/aauser_calc1.txt


```
