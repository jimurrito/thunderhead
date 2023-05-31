# Project Thunderhead
A Simple and Comprehesive Systems-managing solution

Core Functions
- [x] Performance
- [ ] Availablity
- [x] Backups
- [x] Auditing
- [ ] Alerting
- [x] Enforcement

---

## Oculus

Captures the output of multiple performance commands. Compresses the results. Rolls logs over every 14 days.

List of Commands:
- who
- last
- ip a
- ping -c 8.8.8.8
- arp
- netstat
- lsblk
- cat /proc/meminfo
- free -h
- nvidia-smi
- zpool status
```bash
:$ bash oculus.bash -r [/path/to/dir] -R [Rollover Days] --ZFS --NVIDIA
```

---

## Freezer

Backs up and compresses the persistent data used by the Docker containers. Will require a brief outage to complete the backup.
Script will temporarily STOP/START only the active containers. Ensuring inactive containers are not booted with the active ones. Rolls logs over every 14 days. **Pigz available as a multi-core solution instead of gzip for compression.**
```bash
:$ bash freezer.bash -s [/container/data] -t [/target/dir] [--pigz]
```
### Hard Reset
In v2.0.3, -h/--hardreset was added to Freezer. This allows for custom run scripts to be ran when containers are restarted. When used, the script will delete all networks and containers (not prune) and then perform the backup. Once done, the run scripts and used to bring everying backup. [**Please refer to Refresh's section on Run Scripts for more info.**](https://github.com/jimurrito/thunderhead#run-scripts)

---

## Refresh
Destroys all resources in docker (containers, images, networks, etc), and rebuild from a defined set of build scripts. The purpose of this being to redeploy all containers with fresh, up-to-date images.
```bash
:$ bash refresh.bash -r [/runscripts] --CONFIRM
```
### Run scripts
The runscripts used by refresh/freezer must be within the following format to be used by the script(s) effectively.
```
~/dockerscripts/
  |-containers/
  |  |- container1.sh
  |  |- conatiner2.sh
  |  |- ...
  |
  |-networks/
     |- network1.sh
     |- network2.sh
```
```bash
# Run Script Examples
# container1.sh
docker run -p 80:80 repo/container1

# network1.sh
docker network create network1
```
```bash
# Example
:$ bash refresh.bash -r ~/dockerscripts --CONFIRM
```
> Network scripts are ran first, then conatiners. If you have any containers, that are used like a network (Ex: gluetun) please put that run script in the *network/* directory.

---

## ~~Permission Check~~ 
**Temporaily Deprecated** - *Lack of 'no-cobble' causes unintended modifications of compliant files. This breaks things like rollover that relies on last modified time. Script is not recommended to be ran until this is fixed in the next few updates. >2.0.0*

~~Sets the permissions of a directory. By default, chmod == 777 and owner+group == root.
Running the script requires providing a directory path as an argument.~~
```bash
:$ bash perm_chk.sh [/path/to/dir] [owner] [chmod#]
```

---

## Version History

### Version 2.0.3
+ [+] Added custom runscripts to Freezer, allowing for custom redeployment via hardreset.
+ Futher improved the prior bug-fix for oculus and freezer.

### Version 2.0.2 - *'Refresh + Bug fixes'*
+ [+] Added refresh.bash for cleaning docker, and maintaining up-to-date images
+ Fixed bugs on multiple scripts
  + [tar-bug] Updated to Oculus and Freeze to avoid exiting when tar produces verbose. Tar does not properly implement stderr vs stdout for errors and info logging respectively.
  + Updated logging to not prepend the service header for console logging. (Syslog/messages logging still shows the service header)

### Version 2.0.1 - *'Freezer Update'*
+ Merged freezer_MC and freezer using command-line arguments.
+ Updated Freezer.sh -> Freezer.bash
  + [+] Runtime Arguments
  + [+] Error propagation
  + [+] Console logging as well as to syslog/messages logs
  + [+] Ability to use pigz compression instead of gzip via arguments

### Version 2.0.0 - *'Electric Boogaloo'*
+ Updated Oculus.sh -> Oculus.bash
  + [+] Runtime Arguments
  + [+] Error propagation
  + [+] Console logging as well as to syslog/messages logs
+ Perm_chk.sh as been temporarily deprecated until compliant no-cobbling is added.

### Version 1.5.1
+ Updated Perm_chk.sh
    + [+] Added additional parameters that are now required for run time.
>**NOTE**:
*This is the begining of a major change to all scripts moving forward. All options will be moved from being hardcoded, to being runtime arguments.*

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
+ [+] Added Oculus.sh for point-in-time performance monitoring
