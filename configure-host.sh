#!/bin/bash

# Ignore TERM, HUP and INT signals
trap '' TERM HUP INT

# Check if the first argument is verbose
VERBOSE="no"
if [ "$1" == "-verbose" ]; then
    VERBOSE="yes"
    shift # Move to the next argument so we can process the rest
fi

# Loop through the remaining arguments
while [ "$1" != "" ]; do
    
    if [ "$1" == "-name" ]; then
        DESIRED_NAME="$2"
        CURRENT_NAME=$(hostname)
        
        if [ "$CURRENT_NAME" != "$DESIRED_NAME" ]; then
            # Apply the name change
            hostnamectl set-hostname "$DESIRED_NAME"
            sed -i "s/$CURRENT_NAME/$DESIRED_NAME/g" /etc/hosts
            sed -i "s/$CURRENT_NAME/$DESIRED_NAME/g" /etc/hostname
            
            logger "Changed hostname from $CURRENT_NAME to $DESIRED_NAME"
            if [ "$VERBOSE" == "yes" ]; then 
                echo "Changed hostname from $CURRENT_NAME to $DESIRED_NAME"
            fi
        else
            if [ "$VERBOSE" == "yes" ]; then 
                echo "Hostname is already set to $DESIRED_NAME"
            fi
        fi
        shift 2 # Move past the flag and the value
        
    elif [ "$1" == "-ip" ]; then
        DESIRED_IP="$2"
        # hostname -I gets all IPs, awk grabs just the first one
        CURRENT_IP=$(hostname -I | awk '{print $1}')
        
        if [ "$CURRENT_IP" != "$DESIRED_IP" ]; then
            sed -i "s/$CURRENT_IP/$DESIRED_IP/g" /etc/netplan/*.yaml
            netplan apply
            sed -i "s/$CURRENT_IP/$DESIRED_IP/g" /etc/hosts
            
            logger "Changed IP from $CURRENT_IP to $DESIRED_IP"
            if [ "$VERBOSE" == "yes" ]; then 
                echo "Changed IP from $CURRENT_IP to $DESIRED_IP"
            fi
        else
            if [ "$VERBOSE" == "yes" ]; then 
                echo "IP is already set to $DESIRED_IP"
            fi
        fi
        shift 2
        
    elif [ "$1" == "-hostentry" ]; then
        DESIRED_NAME="$2"
        DESIRED_IP="$3"
        
        # Check if the name already exists in the hosts file
        if grep -q "$DESIRED_NAME" /etc/hosts; then
            CURRENT_ENTRY_IP=$(grep "$DESIRED_NAME" /etc/hosts | awk '{print $1}')
            
            if [ "$CURRENT_ENTRY_IP" != "$DESIRED_IP" ]; then
                # Delete the old entry and append the new one
                sed -i "/$DESIRED_NAME/d" /etc/hosts
                echo "$DESIRED_IP $DESIRED_NAME" >> /etc/hosts
                
                logger "Updated $DESIRED_NAME to IP $DESIRED_IP in /etc/hosts"
                if [ "$VERBOSE" == "yes" ]; then 
                    echo "Updated $DESIRED_NAME to IP $DESIRED_IP in /etc/hosts"
                fi
            else
                if [ "$VERBOSE" == "yes" ]; then 
                    echo "Host entry for $DESIRED_NAME is already correct"
                fi
            fi
        else
            # Entry doesn't exist, just append it
            echo "$DESIRED_IP $DESIRED_NAME" >> /etc/hosts
            
            logger "Added $DESIRED_NAME with IP $DESIRED_IP to /etc/hosts"
            if [ "$VERBOSE" == "yes" ]; then 
                echo "Added $DESIRED_NAME with IP $DESIRED_IP to /etc/hosts"
            fi
        fi
        shift 3 # Move past the flag, the name, and the IP
        
    else
        # If we hit an unknown argument, just skip it
        shift
    fi
done
