# Example to run the getData.py script


# A Cronjob

*  AA ip   : 10.0.5.23
*  Target  : /var/www/data
*  Days    : 7
*  PV list : aaa_pv_list
*   Mean    : 5 mins average data (300 secs)
```
*/5 *  * * * export DISPLAY=:0.0 && /usr/bin/python /home/jhlee/epics_env/archiver.appliance.python/getData.py -i 10.0.5.23 -t /var/www/data/ -f munji_pv_list -m 300 >/dev/null 2>&1
```

# a normal user

* AA ip    : 10.0.5.23
* Target   : default $HOME/pvs
* Days     : 30
* PV list  : test_pv_list
* mean     : no mean - raw archived data
* verbose  : want to see any progress while running this script

```
jhlee@debian01:~$ python scripts_for_epics/archiver.appliance.python/getData.py -i  10.0.5.23 -d 30 -f test_pv_list -v
```

*   Mean    : 1 min average data (60 secs)
```
jhlee@debian01:~$ python scripts_for_epics/archiver.appliance.python/getData.py -i  10.0.5.23 -d 30 -f test_pv_list -v -m 60
```
