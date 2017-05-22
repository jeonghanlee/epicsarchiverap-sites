Useful Commands Collection 
============================

* Get the archived data

```
curl -s "http://10.0.4.22:17668/retrieval/data/getData.json?pv=sileeHost:calcExample1"
```

* Get the archived data with the meta data 

```
curl -s "http://10.0.4.22:17668/retrieval/data/getData.json?pv=sileeHost:calcExample1&fetchLatestMetadata=true"
```

* Get the meta data only for the archived data

```
curl -s "http://10.0.4.22:17668/retrieval/data/getData.json?pv=sileeHost:calcExample1&fetchLatestMetadata=true" | head -3

```
