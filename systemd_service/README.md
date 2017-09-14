Due to unknown reasons, systemd service for archappl is installed inproperly. In this case, one MUST disable SELINUX in /etc/selinux/config by
```
SELINUX=disabled
```

After this, the system MUST be rebooted. One can check its status via

```
$ sudo sestatus
sudo] password for aauser: 
SELinux status:                 disabled
```
