require ADURL,2.2.0
#require ADURL,develop
require busy,1.7.0
require sequencer,2.1.21
require sscan,1339922
require calc,3.7.1
require autosave,5.9.0

epicsEnvSet("IOC",		"iocURLTest")
epicsEnvSet("TOP",		".")
epicsEnvSet("PREFIX", "URL1:")
epicsEnvSet("ADURL",		"/home/iocuser/e3/e3-ADURL/ADURL")
#epicsEnvSet("ADPLUGINCALIB",	"/home/iocuser/e3/e3-ADPluginCalib/ADPluginCalib")
#epicsEnvSet("AREA_DETECTOR",	"/home/utgard/epics_env/epics-modules/areaDetector")
#epicsEnvSet("EPICS_BASE",	"/home/utgard/epics_env/epics-base")
#epicsEnvSet("EPICS_MODULES",	"/home/utgard/epics_env/epics-modules")
#epicsEnvSet("ASYN",		"/home/utgard/epics_env/epics-modules/asyn")
  epicsEnvSet("ADSUPPORT",	"/home/iocuser/e3/e3-ADSupport/ADSupport")
  epicsEnvSet("ADCORE",		"/home/iocuser/e3/e3-ADCore/ADCore")
  epicsEnvSet("AUTOSAVE",	"/home/iocuser/e3/e3-autosave/autosave")
  epicsEnvSet("AUTOSAVE_DIR",	"$(TOP)/autosave")
# epicsEnvSet("BUSY",		"/home/utgard/epics_env/epics-modules/busy")
  epicsEnvSet("CALC",		"/home/iocuser/e3/e3-calc")
# epicsEnvSet("SNCSEQ",		"/home/utgard/epics_env/epics-modules/seq")
# epicsEnvSet("SSCAN",		"/home/utgard/epics_env/epics-modules/sscan")

epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","64000000")

### The port name for the detector
epicsEnvSet("PORT",   "URL1")
### Queue size
epicsEnvSet("QSIZE",  "5")   
### The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "2048")
### The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "1556")
### The maximum number of time series points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
### The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
### The search path for database files
# epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")
### Define NELEMENTS 
epicsEnvSet("NELEMENTS", "12582912")

# Create a URL driver
# URLDriverConfig(const char *portName, int maxBuffers, size_t maxMemory,
#                 int priority, int stackSize)
URLDriverConfig("$(PORT)", 0, 0)
dbLoadRecords("URLDriver.db","P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")

asynSetTraceIOMask($(PORT), 0, 2)
#asynSetTraceMask($(PORT), 0, 0xFF)
#asynSetTraceFile($(PORT), 0, "asynTrace.out")
#asynSetTraceInfoMask($(PORT), 0, 0xf)

### Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, $(PORT), 0, 0)
### Use this line for 8-bit data only
#dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int8,FTVL=CHAR,NELEMENTS=$(NELEMENTS)")
### Use this line for 8-bit or 16-bit data
dbLoadRecords("NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=$(NELEMENTS)")

### Load all other plugins using commonPlugins.cmd

#NDCalibConfigure("CALIB1", $(QSIZE), 0, "$(PORT)", 0, 0, 0, 0)
#dbLoadRecords("$(ADPLUGINCALIB)/calibApp/Db/NDCalib.db", "P=$(PREFIX),R=Calib1:,PORT=CALIB1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT)")

< $(ADCORE)/../cmds/commonPlugins.cmd

#############################################################################################
## autosave/restore machinery
#save_restoreSet_Debug(0)
#save_restoreSet_IncompleteSetsOk(1)
#save_restoreSet_DatedBackupFiles(1)
# 
system("mkdir -p --mode=0755 $(AUTOSAVE_DIR)/$(IOC)")
set_savefile_path("$(AUTOSAVE_DIR)/$(IOC)","")
#set_requestfile_path("$(ADPOINTGREY)/autosave","/req")
# 
# set_pass0_restoreFile("info_positions.sav")
#set_pass0_restoreFile("info_settings.sav")
#set_pass1_restoreFile("info_settings.sav")
# 
iocInit()
#
## more autosave/restore machinery
#cd autosave/req
#makeAutosaveFiles()
#cd ../..
#create_monitor_set("info_positions.req", 5 , "")
#create_monitor_set("info_settings.req", 15 , "")
set_requestfile_path("$(ADURL)/iocs/urlIOC/iocBoot/iocURLDriver", "")
set_requestfile_path("$(ADURL)/urlApp/Db", "")
set_requestfile_path("$(ADCORE)/../cmds", "")
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")


