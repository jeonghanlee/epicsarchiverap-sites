TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS BELOW HERE

# xxxRecord.h will be created from xxxRecord.dbd
DBDINC += xxxRecord

# Install xxxSupport.dbd into <top>/dbd
DBD += xxxSupport.dbd

# Build an IOC support library
LIBRARY_IOC += myexampleSupport

# Compile and add the code to the support library
myexampleSupport_SRCS += xxxRecord.c
myexampleSupport_SRCS += devXxxSoft.c

# Link locally-provided code into the support library,
# rather than directly into the IOC application.
# This is required for Windows DLL builds.
myexampleSupport_SRCS += dbSubExample.c
myexampleSupport_SRCS += myexampleHello.c
myexampleSupport_SRCS += initTrace.c

myexampleSupport_LIBS += $(EPICS_BASE_IOC_LIBS)

# Build the IOC application
PROD_IOC = myexample

# myexample.dbd will be created and installed
DBD += myexample.dbd

# myexample.dbd will include these files:
myexample_DBD += base.dbd
myexample_DBD += xxxSupport.dbd
myexample_DBD += dbSubExample.dbd
myexample_DBD += myexampleHello.dbd
myexample_DBD += initTrace.dbd

# myexample_registerRecordDeviceDriver.cpp derives from myexample.dbd
myexample_SRCS += myexample_registerRecordDeviceDriver.cpp

# Build the main IOC entry point where needed
myexample_SRCS_DEFAULT += myexampleMain.cpp
myexample_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#myexample_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Link in the code from our support library
myexample_LIBS += myexampleSupport

# To build SNL programs, SNCSEQ must be defined
# in the <top>/configure/RELEASE file
ifneq ($(SNCSEQ),)
    # Build sncExample into myexampleSupport
    sncExample_SNCFLAGS += +r
    myexample_DBD += sncExample.dbd
    myexampleSupport_SRCS += sncExample.stt
    myexampleSupport_LIBS += seq pv
    myexample_LIBS += seq pv

    # Build sncProgram as a standalone program
    PROD_HOST += sncProgram
    sncProgram_SNCFLAGS += +m
    sncProgram_SRCS += sncProgram.st
    sncProgram_LIBS += seq pv
    sncProgram_LIBS += $(EPICS_BASE_HOST_LIBS)
endif

# Finally link IOC to the EPICS Base libraries
myexample_LIBS += $(EPICS_BASE_IOC_LIBS)

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD EXTRA GNUMAKE RULES BELOW HERE

