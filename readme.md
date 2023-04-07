# Project Thunderhead
A Simple and Comprehesive Systems-managing solution

Core Functions
- [x] Performance
- [ ] Availablity
- [x] Backups
- [x] Auditing
- [ ] Alerting

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
- top -bn5
- iotop -obn5
- tcpdump -c 40
- cat /proc/meminfo
- free -h



### Freezer

Backs up and compresses the current state of **active** docker containers. Will require a brief outage to complete the backup.
Rolls logs over every 14 days.

## Version History

### Version 1.1
+ Added Freezer.sh for backing-up active docker containers.

### Version 1.0
Initial Release
+ Added Oculus.sh for post-mortem performance monitoring
