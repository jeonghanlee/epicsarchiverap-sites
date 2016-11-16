#import numpy as np
#from chaco.shell import *
import urllib2
import json
#

#req = urllib2.urlopen("http://10.4.3.86:17668/retrieval/data/getData.json?pv=aauser%3Aai1")
#req = urllib2.urlopen("http://10.4.3.86:17665/mgmt/bpl/getAllPVs?limit=2&pv=*calc1*")
req = urllib2.urlopen("http://10.4.3.86:17665/mgmt/bpl/getAllPVs")
data = json.load(req)

#secs = [x['secs'] for x in data[0]['data']]
#vals = [x['val'] for x in data[0]['data']]

print data
#plot(secs, vals, "r-")
#xscale('time')
#show()
