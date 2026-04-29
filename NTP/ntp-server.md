# NTP - A How To Guide by Hexnub

## NTP Server ntpd

## How to create and configure an NTP server
1. On Ubuntu update your local repo and upgrade if you wish.
```bash
sudo apt update && sudo apt upgrade -y
```
2. Install the ntpd daemon which will serve as both ntp server and client.
```bash
sudo apt install ntp
```
3. Configuring the ntp configuration file
open the file with your favorite text editor. I use vim
```bash
sudo vim /etc/ntpsec/ntp.conf
```
the ntp.conf file contain pre-configured server pools, however it would be best to use local pool for less latency, visit the ntp pool project website for details.
```
https://www.ntppool.org/zone/us
```
replace the pool entries with your local pool
```
server 0.us.pool.ntp.org
server 1.us.pool.ntp.org
server 2.us.pool.ntp.org
server 3.us.pool.ntp.org
```
if you already have a server with a lower Stratum number (higher tier ntp) and wish to sync this server with this local ntp add the ip address and or hostname of your ntp server to this file replacing the pool information.
```
server ntp.domaincontroller.com prefer
server 10.10.1.3
```
restart the ntp service for the changes to take effect. 
```bash
sudo systemctl restart ntp
```
check your ntp sources
```bash
ntpq -p
```
Note: restart the ntp daemon after making any changes to the ntp.conf file
```bash
sudo systemctl restart ntp
```

## Setting the time zone with timedatectl
List available timezones
```bash
timedatectl list-timezones
```
Set timezone
```bash
sudo timedatectl set-timezone America/Los_Angeles
```
Verify timezone
```bash
timedatectl
```

## NTP Client timesyncd.service
1. Enable NTP with timedatectl
This tells systemd to use systemd-timesynd for time synchronization:
```bash
sudo timedatectl set-ntp true
```
2. Configure NTP servers in /etc/systemd/timesyncd.conf
```bash
sudo vim /etc/systemd/timesyncd.conf
```
Uncomment and set your preferred NTP server,
For example:
[Time]
NTP=10.1.1.2
FallbackNTP=0.pool.ntp.org

3. Restart the service
```bash
sudo systemctl restart systemd-timesyncd
```
4. Check the sync status
```bash
timedatectl status
```
or more detailed:
```bash
timedatectl show-timesync --all
```
You should see:
NTP service: active
NTP synchronized: yes


## Troubleshooting Tips
### Probe to see which NTP service is running
Only one of these should ideally be managing NTP. 
```bash
systemctl status systemd-timesyncd
systemctl status cronyd
systemctl status ntpd
```
If you're using chronyd, or ntpd, systemd-timesyncd can be disabled
### Check if NTP port is blocked
These commands hang or return unreachable servers
```bash
sudo ntpq -p     # for ntpd
chronyc sources   # for chronyd
```
### Allow NTP through the server's firewall
```bash
sudo ufw allow 123/udp
sudo ufw status
```
### Disable ntpd or chronyd if installed
Idealy, only one NTP client should be active.
```bash
sudo systemctl disable --now ntp
sudo systemctl disable --now chronyd
```
## NTP Client Configuration on Windows DC
1. Find which DC holds the PDC role (Primary Domain Controller)
```powershell
netdom /query fsmo
```
2. Find your local pool for less latency.
```
https://www.ntppool.org/zone/us
```

```powershell
w32tm /query /computer: "0.us.pool.ntp.org 1.us.pool.ntp.org 2.us.pool.ntp.org 3.us.pool.ntp.org" /syncfromflags:manual /update
```
3. Check your configuration, restart time service and query pool
```powershell
W32tm /query /computer:localhost /configuration
```
```powershell
net stop w32time && net start w32time
```
```powershell
W32tm /query /source
```
