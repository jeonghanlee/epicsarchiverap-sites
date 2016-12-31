# Example to run the getData.py script


# A Cronjob
* -i : ip address :  10.4.3.86
* -d : days to monitor from now" : 1
* -t : target output file dir : /var/www/data
```
*/5 *  * * * export DISPLAY=:0.0 && /usr/bin/python /home/aauser/epicsarchiverap-sites/aa_scripts/getData.py -i 10.4.3.86 -d 1 -t /var/www/data/ -f ics_pv_list  >/dev/null 2>&1
```

# a normal user

* -i : ip address :  10.0.4.22
* -d : days to monitor from now" : 1
* -t : target output file dir : $PWD
* -m : no mean (secs)  - raw archived data : 
* -v : verbose  : want to see any progress while running this script
* -p : pattern  : getAllPVs options : "?pv=aauser:*&limit=100"
## 

* Get all PVs , and save them in pvs dir

```
$/usr/bin/python /home/aauser/epicsarchiverap-sites/aa_scripts/getData.py -i 10.0.4.22 -d 1  -t ${HOME}/pvs 

$ /tree -L 2 pvs/
pvs/
└── [aauser     39]  Archappl_10.0.4.22
    └── [aauser   8.0K]  2016-11-23T14:30:11.614285

2 directories, 0 files

$ ls  pvs/Archappl_10.0.4.22/2016-11-23T14\:30\:11.614285/
aauser_ai1.txt                     ics-evg_evtclk-pll-bandwidth-rb.txt  ics-evg_mxc5-polarity-rb.txt           ics-evg_sfp0-speed-link-i.txt    ics-evg_trigevt5-evtcode-rb.txt   ics-evr_sfp0-bitrate-upper-i.txt
aauser_ai2.txt                     ics-evg_evtclk-pll-sts.txt           ics-evg_mxc5-status-rb.txt             ics-evg_sfp0-status-i.txt        ics-evg_trigevt6-enable-rb.txt    ics-evr_sfp0-date-manu-i.txt
aauser_ai3.txt                     ics-evg_evtclk-rfdiv-rb.txt          ics-evg_mxc6-frequency-rb.txt          ics-evg_sfp0-t-i.txt             ics-evg_trigevt6-evtcode-rb.txt   ics-evr_sfp0-linklength-50fiber-i.txt
aauser_aiexample1.txt              ics-evg_evtclk-rffreq-rb.txt         ics-evg_mxc6-polarity-rb.txt           ics-evg_sfp0-vendor-i.txt        ics-evg_trigevt7-enable-rb.txt    ics-evr_sfp0-linklength-62fiber-i.txt
aauser_aiexample2.txt              ics-evg_evtclk-source-rb.txt         ics-evg_mxc6-status-rb.txt             ics-evg_softevt-enable-rb.txt    ics-evg_trigevt7-evtcode-rb.txt   ics-evr_sfp0-linklength-9fiber-i.txt
aauser_aiexample3.txt              ics-evg_mxc0-frequency-rb.txt        ics-evg_mxc7-frequency-rb.txt          ics-evg_softevt-evtcode-rb.txt   ics-evr_cg-sts.txt                ics-evr_sfp0-linklength-copper-i.txt
aauser_aiexample.txt               ics-evg_mxc0-polarity-rb.txt         ics-evg_mxc7-polarity-rb.txt           ics-evg_softseqenable-rb.txt     ics-evr_cnt-fifoevt-i.txt         ics-evr_sfp0-part-i.txt
aauser_asubexample.txt             ics-evg_mxc0-status-rb.txt           ics-evg_mxc7-status-rb.txt             ics-evg_softseqmask-rb.txt       ics-evr_cnt-fifoloop-i.txt        ics-evr_sfp0-powervcc-i.txt
aauser_calc1.txt                   ics-evg_mxc1-frequency-rb.txt        ics-evg_sfp0-bitrate-lower-i.txt       ics-evg_synctimestamp-cmd.txt    ics-evr_cnt-hwoflw-i.txt          ics-evr_sfp0-pwr-rx-i.txt
aauser_calc2.txt                   ics-evg_mxc1-polarity-rb.txt         ics-evg_sfp0-bitrate-upper-i.txt       ics-evg_timestamp-rb.txt         ics-evr_cnt-irq-i.txt             ics-evr_sfp0-pwr-tx-i.txt
aauser_calc3.txt                   ics-evg_mxc1-status-rb.txt           ics-evg_sfp0-date-manu-i.txt           ics-evg_trigevt0-enable-rb.txt   ics-evr_cnt-linktimo-i.txt        ics-evr_sfp0-rev-i.txt
aauser_calcexample1.txt            ics-evg_mxc2-frequency-rb.txt        ics-evg_sfp0-linklength-50fiber-i.txt  ics-evg_trigevt0-evtcode-rb.txt  ics-evr_cnt-rxerr-i.txt           ics-evr_sfp0-serial-i.txt
aauser_calcexample2.txt            ics-evg_mxc2-polarity-rb.txt         ics-evg_sfp0-linklength-62fiber-i.txt  ics-evg_trigevt1-enable-rb.txt   ics-evr_cnt-swoflw-i.txt          ics-evr_sfp0-speed-link-i.txt
aauser_calcexample3.txt            ics-evg_mxc2-status-rb.txt           ics-evg_sfp0-linklength-9fiber-i.txt   ics-evg_trigevt1-evtcode-rb.txt  ics-evr_event-14-cnt-i.txt        ics-evr_sfp0-status-i.txt
aauser_calcexample.txt             ics-evg_mxc3-frequency-rb.txt        ics-evg_sfp0-linklength-copper-i.txt   ics-evg_trigevt2-enable-rb.txt   ics-evr_hwtype-i.txt              ics-evr_sfp0-t-i.txt
aauser_compressexample.txt         ics-evg_mxc3-polarity-rb.txt         ics-evg_sfp0-part-i.txt                ics-evg_trigevt2-evtcode-rb.txt  ics-evr_link-clk-i.txt            ics-evr_sfp0-vendor-i.txt
aauser_subexample.txt              ics-evg_mxc3-status-rb.txt           ics-evg_sfp0-powervcc-i.txt            ics-evg_trigevt3-enable-rb.txt   ics-evr_link-clkperiod-i.txt      ics-evr_time-clock-i.txt
aauser_xxxexample.txt              ics-evg_mxc4-frequency-rb.txt        ics-evg_sfp0-pwr-rx-i.txt              ics-evg_trigevt3-evtcode-rb.txt  ics-evr_link-clk-sp.txt           ics-evr_time-div-i.txt
ics-evg_dbusstatus-rb.txt          ics-evg_mxc4-polarity-rb.txt         ics-evg_sfp0-pwr-tx-i.txt              ics-evg_trigevt4-enable-rb.txt   ics-evr_link-sts.txt              ics-evr_time-i.txt
ics-evg_evtclk-fracsynfreq-rb.txt  ics-evg_mxc4-status-rb.txt           ics-evg_sfp0-rev-i.txt                 ics-evg_trigevt4-evtcode-rb.txt  ics-evr_pos-i.txt                 ics-evr_time-src-sel.txt
ics-evg_evtclk-frequency-rb.txt    ics-evg_mxc5-frequency-rb.txt        ics-evg_sfp0-serial-i.txt              ics-evg_trigevt5-enable-rb.txt   ics-evr_sfp0-bitrate-lower-i.txt  ics-evr_time-valid-sts.txt

$ lhead -n 20 pvs/Archappl_10.0.4.22/2016-11-23T14\:30\:11.614285/aauser_calc1.txt 
# 
# Filename    : aauser_calc1.txt
# PV name     : aauser:calc1
# From        : 2016-11-22T14:30:11.614285
# To          : 2016-11-23T14:30:11.614285
# queryString : ?pv=aauser:calc1&from=2016-11-22T14%3A30%3A11.614285%2B01%3A00&to=2016-11-23T14%3A30%3A11.614285%2B01%3A00
# hostname    : ics-archappl01
# host IP     : 10.0.4.22
# 
# time, val, nanos, status, severity    
2016-11-22T14:30:11, 5.0, 373390132, 0, 0 
2016-11-22T14:30:12, 6.0, 373420748, 4, 1 
2016-11-22T14:30:13, 7.0, 373386625, 4, 1 
2016-11-22T14:30:14, 8.0, 373400133, 3, 2 
2016-11-22T14:30:15, 9.0, 373362140, 3, 2 
2016-11-22T14:30:16, 0.0, 373350756, 5, 2 
2016-11-22T14:30:17, 1.0, 373386525, 5, 2 
2016-11-22T14:30:18, 2.0, 373447182, 5, 2 
2016-11-22T14:30:19, 3.0, 373395814, 6, 1 
2016-11-22T14:30:20, 4.0, 373353181, 6, 1 



$ wc -l pvs/Archappl_10.0.4.22/2016-11-23T14\:30\:11.614285/aauser_calc1.txt 
86411 pvs/Archappl_10.0.4.22/2016-11-23T14:30:11.614285/aauser_calc1.txt

```


* Get defined PVs in test_ioc_pv_list with 2 days ago and 1min mean and verbose in pvs dir


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
$ /usr/bin/python /home/aauser/epicsarchiverap-sites/aa_scripts/getData.py -i 10.0.4.22 -d 2  -f test_ioc_pv_list  -t ${HOME}/pvs  -m 60
$ tree -L 2 pvs/
pvs/
└── [aauser     72]  Archappl_10.0.4.22
    ├── [aauser   8.0K]  2016-11-23T14:30:11.614285
    └── [aauser   4.0K]  2016-11-23T14:33:40.249434


~$ head -n 20 pvs/Archappl_10.0.4.22/2016-11-23T14\:33\:40.249434/aauser_calc1.txt 
# 
# Filename    : aauser_calc1.txt
# PV name     : aauser:calc1
# From        : 2016-11-21T14:33:40.249434
# To          : 2016-11-23T14:33:40.249434
# queryString : ?pv=mean_60(aauser:calc1)&from=2016-11-21T14%3A33%3A40.249434%2B01%3A00&to=2016-11-23T14%3A33%3A40.249434%2B01%3A00
# hostname    : ics-archappl01
# host IP     : 10.0.4.22
# 
# time, val, nanos, status, severity    
2016-11-21T14:33:30, 4.42857142857, 0, 0, 2 
2016-11-21T14:34:30, 4.5, 0, 0, 2 
2016-11-21T14:35:30, 4.5, 0, 0, 2 
2016-11-21T14:36:30, 4.5, 0, 0, 2 
2016-11-21T14:37:30, 4.5, 0, 0, 2 
2016-11-21T14:38:30, 4.5, 0, 0, 2 
2016-11-21T14:39:30, 4.5, 0, 0, 2 
2016-11-21T14:40:30, 4.5, 0, 0, 2 
2016-11-21T14:41:30, 4.5, 0, 0, 2 
2016-11-21T14:42:30, 4.5, 0, 0, 2 

$ wc -l pvs/Archappl_10.0.4.22/2016-11-23T14\:33\:40.249434/aauser_calc1.txt 
2891 pvs/Archappl_10.0.4.22/2016-11-23T14:33:40.249434/aauser_calc1.txt

```

** Get All PVs from Archiver Appliance  (can be limited by -p "?limit=100") 
** Check whether PV has the pattern "*calc*" (?pv=*calc*)
** Return the matched PVs
** 7 day ago data from now
** extracted ascii files are in pvs directory
** the combined pattern should be "?pv=*calc*&limit=100"".

```
aauser@ics-archappl01:~$ /usr/bin/python /home/aauser/epicsarchiverap-sites/aa_scripts/getData.py -i 10.0.4.22 -t ${HOME}/pvs -d 7 -p "?pv=*calc*"
aauser@ics-archappl01:~$ /tree -L 2 pvs/
pvs/
└── [aauser   4.0K]  Archappl_10.0.4.22
    ├── [aauser   8.0K]  2016-11-23T14:30:11.614285
    ├── [aauser   4.0K]  2016-11-23T14:33:40.249434
    ├── [aauser   4.0K]  2016-11-23T14:36:34.541761
    └── [aauser   4.0K]  2016-11-23T14:38:45.123049

5 directories, 0 files

$ ls pvs/Archappl_10.0.4.22/2016-11-23T14\:38\:45.123049/
aauser_calc1.txt  aauser_calc2.txt  aauser_calc3.txt  aauser_calcexample1.txt  aauser_calcexample2.txt  aauser_calcexample3.txt  aauser_calcexample.txt
aauser@ics-archappl01:~$ 

```




* Get selected PVs defined in test_ioc_pv_list , and save them in ${HOME}, and create zip for the target directory.

```
$ /usr/bin/python /home/aauser/epicsarchiverap-sites/aa_scripts/getData.py -i 10.0.4.22 -t ${HOME} -d 1  -z -f test_ioc_pv_list

$ tree -L 2 Archappl_10.0.4.22/
Archappl_10.0.4.22/
├── [aauser   4.0K]  2016-11-23T14:53:10.212812
│   ├── [aauser   3.5M]  aauser_ai1.txt
│   ├── [aauser   1.8M]  aauser_ai2.txt
│   ├── [aauser   726K]  aauser_ai3.txt
│   ├── [aauser   3.5M]  aauser_aiexample1.txt
│   ├── [aauser   1.8M]  aauser_aiexample2.txt
│   ├── [aauser   726K]  aauser_aiexample3.txt
│   ├── [aauser   3.5M]  aauser_aiexample.txt
│   ├── [aauser    434]  aauser_asubexample.txt
│   ├── [aauser   3.5M]  aauser_calc1.txt
│   ├── [aauser   1.8M]  aauser_calc2.txt
│   ├── [aauser   726K]  aauser_calc3.txt
│   ├── [aauser   3.5M]  aauser_calcexample1.txt
│   ├── [aauser   1.8M]  aauser_calcexample2.txt
│   ├── [aauser   726K]  aauser_calcexample3.txt
│   ├── [aauser   3.5M]  aauser_calcexample.txt
│   └── [aauser    390]  aauser_subexample.txt
└── [aauser   4.9M]  2016-11-23T14:53:10.212812.zip

1 directory, 17 files
```