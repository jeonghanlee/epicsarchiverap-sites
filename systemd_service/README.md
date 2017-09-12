In oder to use the systemd service,

one should disable SELINUX first.

```
$ sudo sestatus 

SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      28
```

Change
SELINUX=disabled
in /etc/selinux/config

Reboot
```
$ sudo sestatus
sudo] password for aauser: 
SELinux status:                 disabled
```
