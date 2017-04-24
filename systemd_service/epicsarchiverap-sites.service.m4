[Unit]
SourcePath=SOURCE_PATH/aaService.bash
Description=ESS EPICS Archiver Appliance
After=network.target

[Service]
ExecStart=SOURCE_PATH/aaService.bash start
Type=forking

[Install]
WantedBy=multi-user.target
Alias=epicsarchiverap-sites.service
