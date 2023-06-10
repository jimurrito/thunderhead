# Project Thunderhead
A Simple and Comprehesive Systems-management solution.

Core Functions
- [x] Performance
- [ ] Availablity
- [x] Backups
- [x] Auditing
- [ ] Alerting
- [x] ~~Enforcement~~
- [ ] Updates
- [ ] Proactive hardware testing
- [ ] Reactive mitigation and triaging

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
bash oculus.bash -r [/path/to/dir] -R [Rollover Days] --ZFS --NVIDIA
```

---

## Freezer

Backs up and compresses the persistent data used by the Docker containers. Will require a brief outage to complete the backup.
Script will temporarily PAUSE only active containers. Ensuring inactive containers are not restarted with the active ones. Rolls logs over every 14 days default. **Pigz available as a multi-core solution instead of gzip for compression.**
```bash
bash freezer.bash -s [/container/data] -t [/target/dir] [--pigz]
```
### Hard Reset
In v2.0.3, -h/--hardreset was added to Freezer. This allows for custom run scripts to be ran when containers are restarted. When used, the script will delete all networks and containers (not prune) and then perform the backup. Once done, the run scripts and used to bring everying backup. [**Please refer to Refresh's section on Run Scripts for more info.**](https://github.com/jimurrito/thunderhead#run-scripts)

### KVM Support (2.0.6+)
Using '-k' or '--kvm' with freezer offers support to backup KVM Virtual Machines. The primary process is the same, and most arguments work unaltered. 
>**NOTE:** '-H' or '--hardreset' is not supported, when using KVM Support.
---

## Refresh
Destroys all resources in docker (containers, images, networks, etc), and rebuild from a defined set of build scripts. The purpose of this being to redeploy all containers with fresh, up-to-date images.
```bash
bash refresh.bash -r [/runscripts] --CONFIRM
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
bash refresh.bash -r ~/dockerscripts --CONFIRM
```
> Network scripts are ran first, then conatiners. If you have any containers, that are used like a network (Ex: gluetun) please put that run script in the *network/* directory.

---

## VPN Check
*For the paranoid in all of us...*

This script will execute either wget or curl within a provided set of containers. These queries will pull back the current IP of both the host server and containers. If any container matches the Ip of the host, its killed.

As of 2.0.7, a custom URL can be provided with the -u/--url argument on the cli. **Warning:** The API umust provide the IP in the request body as text. html/json based resonses will fail to be parsed.

```bash
bash vpn_chk.bash container1 container2...
```
>**Note:**
> If the container has neither *wget* or *curl* available, the script will mark the IP Address as '*FAIL*', and ignore the container. It will not be stopped.

---

## Version History

### Version 2.0.7 - *'Clean-up + QoA'*
+ General Cleanup and minor refactoring.
  + Normalized code for all scripts.
  + Standardized help menus and logging.
  + Corrected typos and punctuation.
+ [-] Fully removed prem_chk.sh from the repo. Will be re-added when the script is fixed.
+ [+] Added optional verbose logging arguments to all scripts. Reduces default logging in syslog/messages logs.
+ [+] Added Custom Ip address URL to vpn_chk.bash.
  + With this feature, an alternative ip resolver can be used if needed.
+ [+] Added addtional core functions to the thunderhead project.

### Version 2.0.6.2 - *'VPN Check - code clean-up'*
+ Cleaned up code for vpn_chk.bash

### Version 2.0.6.1 - *'Freezer-fix'*
+ Fixed bug with the new pause method for the backup. Logic error caused paused containers to be started via *docker start* instead of *docker unpause*

### Version 2.0.6 - *'Freezer + KVM'*
+ [+] Added KVM support to Freezer.bash.
  + -k or --kvm can be used to opt for KVM usage instead of docker

### Version 2.0.5.1 - *'VPN Check - fix'*
+ Fixed bug in vpn_chk.bash, that caused the IP pulled from the containers to always be the FAIL placeholder.

### Version 2.0.5 - *'The Rusty-Shackleford update'*
+ [+] Added vpn_chk.bash. This will check the complaince of containers that should be on VPN.

### Version 2.0.4 - *'Freezer Update'*
+ [+] Freezer now pauses containers by default, instead of restarting them.
  + Restarts can now be done via -R or --reset if it's still needed.

### Version 2.0.3.1
+ Minor tweets to Freezer and Refresh

### Version 2.0.3
+ [+] Added custom runscripts to Freezer, allowing for custom redeployment via hardreset.
+ Futher improved the prior bug-fix for oculus and freezer.

### Version 2.0.2 - *'Refresh + Bug fixes'*
+ [+] Added refresh.bash for cleaning docker, and maintaining up-to-date images
+ Fixed bugs on multiple scripts
  + [tar-bug] Updated to Oculus and Freezer to avoid exiting when tar produces verbose. Tar does not properly implement stderr vs stdout for errors and info logging respectively.
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
