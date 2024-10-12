#!/bin/bash

# Extract the IP and port from the URL
url="$1"
if [[ $url =~ telnet://([^:]+):([0-9]+) ]]; then
    ip="${BASH_REMATCH[1]}"
    port="${BASH_REMATCH[2]}"
else
    echo "Invalid URL format. Expected format: telnet://IP:PORT"
    exit 1
fi

# Open telnet in Alacritty
alacritty -e telnet "$ip" "$port"

