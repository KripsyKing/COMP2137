#!/bin/bash

# getting hostname
echo "Hostname: $(hostname)"

# getting interal IP (first listed)
echo "IP Address: $(hostname -I | awk '{print $1}')"

# getting gatway
echo "Gateway: $(ip route | grep default | awk '{print $3}')"


