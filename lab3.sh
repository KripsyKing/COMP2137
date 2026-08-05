#!/bin/bash
# This script runs the configure-host.sh script from the current directory to modify 2 servers and update the local /etc/hosts file

VERBOSE=""
# Check if -verbose was passed to lab3.sh
if [[ " $* " =~ " -verbose " ]] || [ "$1" == "-verbose" ]; then
    VERBOSE="-verbose"
fi

# Function to execute a command and catch any errors
run_cmd() {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "[ERROR] Command failed with status $status: $*" >&2
    fi
    return $status
}

# 1. Deploy and configure server1-mgmt (loghost)
run_cmd scp configure-host.sh remoteadmin@server1-mgmt:/root
run_cmd ssh remoteadmin@server1-mgmt -- /root/configure-host.sh $VERBOSE -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4

# 2. Deploy and configure server2-mgmt (webhost)
run_cmd scp configure-host.sh remoteadmin@server2-mgmt:/root
run_cmd ssh remoteadmin@server2-mgmt -- /root/configure-host.sh $VERBOSE -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3

# 3. Update the local desktop Linux VM hosts file
sudo ./configure-host.sh $VERBOSE -hostentry loghost 192.168.16.3
sudo ./configure-host.sh $VERBOSE -hostentry webhost 192.168.16.4
