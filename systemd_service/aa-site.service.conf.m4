define(`AA_SYSTEMD_UNIT',`

[Unit]
SourcePath=$1/aaService.bash
Description=Site-Specific - ESS - EPICS Archier Appliance
Documentation=https://jeonghanlee.github.io/epicsarchiverap-sites/
After=network.target

[Service]
ExecStart=$1/aaService.bash start
ExecStop=$1/aaService.bash stop
Restart=$1/aaService.bash restart
Type=forking

[Install]
WantedBy=multi-user.target
Alias=epicsarchiverap-sites.service

')
