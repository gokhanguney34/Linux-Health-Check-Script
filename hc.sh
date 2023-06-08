#!/bin/bash

echo "************************************"
echo "        System Health Status"
echo "************************************"

# Hostname
hostname=$(hostname)
echo "Hostname : $hostname"

# Operating System
os=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d "=" -f 2 | tr -d '"')
echo "Operating System : $os"

# Kernel Version
kernel=$(uname -r)
echo "Kernel Version : $kernel"

# System Architecture
architecture=$(uname -m)
echo "OS Architecture : $architecture"

# System Uptime
uptime=$(uptime -p)
echo "System Uptime : up by $uptime"

# Current System Date & Time
date=$(date)
echo "Current System Date & Time : $date"

echo
echo "Checking For Read-only File System[s]"
echo "-------------------------------------"

read_only=$(mount | awk '$4 ~ /ro/ {print $0}')
if [[ -z "$read_only" ]]; then
    echo "No read-only file system[s] found."
else
    echo "$read_only"
fi

echo

echo "Checking For Currently Mounted File System[s]"
echo "------------------------------------------"
mounted_filesystems=$(mount | grep '^/dev/' | awk '{print $1, "on", $3, "type", $5, $6}')
echo "$mounted_filesystems"
echo

echo "Checking For Disk Usage On Mounted File System[s]"
echo "-----------------------------------------------"
disk_usage=$(df -h | grep '^/dev/' | awk '{print $1, $6, $5}')
echo "Mounted File System[s] Utilization (Percentage Used):"
echo "--------------------------------------------------------------------------"
echo "$disk_usage" | while read -r line; do
    echo "$line     ------  OK/HEALTHY"
done
echo

echo "Checking For Zombie Processes"
echo "-------------------------------------"
zombies=$(ps aux | awk '{if ($8 == "Z") print $0}')
if [[ -n "$zombies" ]]; then
    echo "Zombie processes found on the system."
else
    echo "No zombie processes found on the system."
fi
echo

echo "Checking For INode Usage"
echo "------------------------------------------"
inode_usage=$(df -i | grep '^/dev/' | awk '{print $1, $6, $5}')
echo "INode Utilization (Percentage Used):"
echo "--------------------------------------------------------------------------"
echo "$inode_usage" | while read -r line; do
    echo "$line     ------  OK/HEALTHY"
done
echo

echo "Checking SWAP Details"
echo "-------------------------------------"
swap_total=$(free -m | awk '/^Swap:/ {print $2}')
swap_free=$(free -m | awk '/^Swap:/ {print $4}')
echo "Total Swap Memory in MiB : $swap_total, in GiB : $(bc <<< "scale=5; $swap_total/1024")"
echo "Swap Free Memory in MiB : $swap_free, in GiB : $(bc <<< "scale=5; $swap_free/1024")"
echo

echo "Checking For Processor Utilization"
echo "-------------------------------------"
processor_utilization=$(top -bn 1 | awk '/%Cpu/ {print $0}')
echo "Current Processor Utilization Summary :"
echo
echo "$processor_utilization"
echo

echo "Checking For Load Average"
echo "-------------------------------------"
load_average=$(uptime | awk -F 'load average:' '{print $2}')
echo "Current Load Average : $load_average"
echo

echo "Most Recent 3 Reboot Events"
echo "------------------------------------------"
last_reboots=$(last reboot | head -n 4 | awk '{print $1, $2, $3, $4, $5}')
echo "$last_reboots"
echo

echo "Most Recent 3 Shutdown Events"
echo "------------------------------------------"
last_shutdowns=$(last -x shutdown | head -n 4 | awk '{print $1, $2, $3, $4, $5}')
echo "$last_shutdowns"
echo

echo "Top 5 Memory Resource Hog Processes"
echo "------------------------------------------"
memory_hogs=$(ps -eo pid,%mem,%cpu,cmd --sort=-%mem | head -n 6)
echo "$memory_hogs"
echo

echo "Top 5 CPU Resource Hog Processes"
echo "------------------------------------------"
cpu_hogs=$(ps -eo pid,%mem,%cpu,cmd --sort=-%cpu | head -n 6)
echo "$cpu_hogs"
echo

echo "Running Services"
echo "------------------------------------------"
systemctl list-units --type service --state running
echo

echo "Listening Ports"
echo "------------------------------------------"
netstat -anltp | grep LISTEN
echo

echo "SSH Permit Root Login"
echo "------------------------------------------"
permit_root_login=$(grep "^PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}')
echo "PermitRootLogin : $permit_root_login"
echo

echo "CPU Count"
echo "------------------------------------------"
cpu_count=$(nproc)
echo "CPU Count : $cpu_count"
echo

echo "SELinux Status"
echo "------------------------------------------"
selinux_status=$(getenforce)
echo "SELinux Status : $selinux_status"
echo

echo "Firewall Status and Rules"
echo "------------------------------------------"
firewall_status=$(systemctl is-active firewalld)
if [[ $firewall_status == "active" ]]; then
    echo "Firewall Service : Running"
    echo "Firewall Rules:"
    firewall_rules=$(firewall-cmd --list-all)
    echo "$firewall_rules"
else
    echo "Firewall Service : Not Running"
fi
echo

echo "Ulimit Settings"
echo "------------------------------------------"
ulimit_settings=$(ulimit -a)
echo "$ulimit_settings"
echo

echo "ifconfig -a"
echo "------------------------------------------"
ifconfig -a
echo
