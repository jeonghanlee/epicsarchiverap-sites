define(`AA_SYSTEMD_UNIT',`
[Unit]
SourcePath=$1/aaService.bash
Description=Site-Specific EPICS Archier Appliance
Documentation=https://jeonghanlee.github.io/epicsarchiverap-sites/
After=network.target

[Service]
ExecStart=/bin/bash -c "$1/aaService.bash start"
ExecStop=/bin/bash -c "$1/aaService.bash stop"
Type=forking

[Install]
WantedBy=multi-user.target
Alias=epicsarchiverap-sites.service
')
