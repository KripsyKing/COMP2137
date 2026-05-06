#!/bin/bash

# show CPU
echo "CPU Actiity"
uptime | awk -F'load average:' '{ print $2 }'

# show free memory
echo -e "\nFree Memory"
free -h | grep Mem | awk '{print "Available: " $7 " / Total: " $2}'

# show disk space
echo -e "\nFree Disk Space"
df -h / | awk 'NR==2 {print "Avilable: " $4 " / Total: " $2 " (Used: "$5")"}'
