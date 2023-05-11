# Project Thunderhead
A Simple and Comprehesive Systems-managing solution

Core Functions
- [x] Performance
- [-] Availablity
- [x] Backups
- [x] Auditing
- [-] Alerting
- [x] Enforcement

### Oculus

Captures the output of multiple performance commands. Compresses the results. Rolls logs over every 14 days.

List of Commands:
- who
- last
- ip a
- ping -c 8.8.8.8
- arp
- netstat
- zpool status
- lsblk
- cat /proc/meminfo
- free -h
- nvidia-smi

### Freezer

Backs up and compresses the persistent data used by the Docker containers. Will require a brief outage to complete the backup.
Script will temporarily STOP/START only the active containers. Ensuring inactive containers are not booted with the active ones. Rolls logs over every 14 days.

### Permission Check

Sets the permissions of a directory. By default, chmod == 777 and owner+group == root.
Running the script requires providing a directory path as an argument.
```bash
Ex: bash prem_check.sh /path/to/dir
```
## Version History

### Version 1.5
+ [+] Added Perm_chk.sh for permissions enforcement.

### Version 1.4
+ Added Freezer_MC.sh for multi-core compression. pigz instead of gzip.
   + Currently there are no passable parameters for pigz, but will be added soon. Because of this, pigz will consume all available CPU resources. Use at your own risk!

### Version 1.3
+ Updated Freezer.sh & Oculus.sh:
    + [+] Changed from TAR archive to TAR.GZ compression. 
    (Should have been this from the begining 😉)

### Version 1.2
+ Updated Oculus.sh:
    + [-] Removed top, iotop, and tcpdump captures to reduce size of logs.
    + [+] Added nvidia-smi dump to the capture.

### Version 1.1
+ [+] Added Freezer.sh for backing-up active docker containers.

### Version 1.0
Initial Release
+ [+] Added Oculus.sh for post-mortem performance monitoring
