The data that the Archiver Appliance holds
=================

# Motivation
The Archiver Appliance (Archappl) collects the PV value, and its time stamp. It is the self-evidence. But I couldn't answer if we ask ourselves in the following question: Are they any other data which Archappl could archive? And I've got the same or similar questions from many others. Of course, we should know what kind of data we are collecting through the Archappl. So, here is the first trial to answer this question. 


# Archiving Data per a Process Variable (PV)
The actual data are saving in the archiver appliance may use many variables defined in PVTypeInfo. One can look at its java source in ./src/main/org/epics/archiverappliance/config/PVTypeInfo.java. Some data are transferred MetaInfo.java to PVTypeInfo within PVTypeInfo class. Please see in ./src/main/org/epics/archiverappliance/config/MetaInfo.java if one would like to see MetaInfo itself.  

Note that [RDB] represents that the variable is recorded in MySQL or Maria Database and [EPICSR] does the variable comes from the EPICS Record field. 

```
Data Type               Variable               : Comments
>>
>>
String                  pvName                 : [RDB] the name of PV 
>>
ArchDBRTypes            DBRType                : [RDB] The DBRType of the PV
                                                 Enum ArchDBRTypes
												 >>> DBR_SCALAR_BYTE
												 >>> DBR_SCALAR_DOUBLE 
												 >>> DBR_SCALAR_ENUM 
											     >>> DBR_SCALAR_FLOAT 
												 >>> DBR_SCALAR_INT 
												 >>> DBR_SCALAR_SHORT 
												 >>> DBR_SCALAR_STRING 
												 >>> DBR_V4_GENERIC_BYTES 
												 >>> DBR_WAVEFORM_BYTE 
												 >>> DBR_WAVEFORM_DOUBLE 
												 >>> DBR_WAVEFORM_ENUM 
												 >>> DBR_WAVEFORM_FLOAT 
												 >>> DBR_WAVEFORM_INT 
												 >>> DBR_WAVEFORM_SHORT 
												 >>> DBR_WAVEFORM_STRING
>>												 
boolean                 isScalar               : [RDB as scalar] Is this a scalar? True, if elementCount = 1
>>
int                     elementCount           : [RDB][EPICSR] .NELM
>>
String                  applianceIdentity      : [RDB] Which appliance owns this PV
	                                             Within <identity> </identity> in appliances.xml file
>>
String                  hostName               : [RDB] IOC where this PV came from last time.
>>
>> Info from the dbr_ctrl structures
double                  lowerAlarmLimit        : [RDB][EPICSR] .LOLO 
double                  lowerCtrlLimit         : [RDB][EPICSR] .DRVL
double                  lowerDisplayLimit      : [RDB][EPICSR] .LOPR
double                  lowerWarningLimit      : [RDB][EPICSR] .LOW
double                  upperAlarmLimit        : [RDB][EPICSR] .HIHI
double                  upperCtrlLimit         : [RDB][EPICSR] .DRVH
double                  upperDisplayLimit      : [RDB][EPICSR] .HOPR
double                  upperWarningLimit      : [RDB][EPICSR] .HIGH
double                  precision              : [RDB][EPICSR] .PREC
double                  units                  : [RDB][EPICSR] .EGU
>>
>> 
float                   computedEventRate      : [RDB] event count / second 
                                                 The sampled event rate in events per second.
>>
float                   computedStorageRate    : [RDB] bytes / second 
												 The sampled storage in bytes per seconds.
>>
int                     computedBytesPerEvent  : [RDB] computedStorageRate / computedEventRate
>>
float                   userSpecifiedEventRate : [RDB] TBD
>>
Timestamp               creationTime           : [RDB] TBD
>>
Timestamp               modificationTime       : [RDB] TBD
>>
boolean                 paused                 : [RDB] TBD
>>
float                   samplingPeriod         : [RDB] samplingPeriod, should be defined in policies.py
                                                 samplingPeriod's unit is [bytes / event count], so it is related with the computedBytesPerEvent
>>
SamplingMethod          samplingMethod         : [RDB] samplingMethod, should be defined in policies.py
                                                 enum SamplingMethod { SCAN, MONITOR, DONT_ARCHIVE }
>>
String                  policyName             : [RDB] policyName, should be defined in policies.py
>>
String[]                dataStores             : [RDB] dataStores, should be defined in policies.py 
                                                 An array of StoragePlugin URL's that can be parsed by StoragePluginURLParser.
                                                 These form the stages of data storage for the PV. For example, STS, MTS, and LTS. 
>>
HashMap<String, String> extraFields            : [RDB][EPICSR] .ADEL, .MDEL, .SCAN, .NAME, .RTYP
>>
String[]                archiveFields          : [RDB] should be defined in policies.py according to RTYP
												 A optional array of fields that will be archived as part of archiving the .VAL field for this PV
>>
boolean                 usePVAccess            : [RDB] If PV has the V4\_PREFIX = "pva://", it is True (See PVNames.java)
>>
String                  controllingPV          : [??] controlPV, should be defined in policies.py
                                                 Another PV that can be used to conditionally archive the PV.
boolean                 useDBEProperties       : [??] DBE\_PROPERTY, this event will be triggered by the IOC whenever the properties (extended attributes) of the channel change
```

## EPICS Record Field Data
```
* .NAME : EPICS Record Name
* .ADEL : EPICS monitor parameters - Archive Deadband used by archiver monitors
* .MDEL : EPICS monitor parameters - Monitor Deadband used for all other types of monitors
* .SCAN : EPICS record common field 
* .RTYP : EPICS record psudo field - Record type name
* .LOLO : lower alarm limit
* .DRVL : lower control limit
* .LOPR : lower display limit
* .LOW  : lower warning limit
* .HIHI : upper alarm limit
* .DRVH : upper control limit
* .HOPR : upper display limit
* .HIGH : upper warning limit
* .PREC : precision
* .EGU  : unit
* .NELM : element count of the PV's value, are defined in aaoRecord, aaiRecord, subArrayRecord, histogramRecord, waveformRecord

```




# Contact
* author   : Jeong Han Lee
* email    : han.lee@esss.se
* revision : v0.1

