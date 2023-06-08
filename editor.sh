#!/bin/bash

# Ask for the URL
echo "Please enter the URL you want to block:"
read url

# Extract domain name for the comment
domain=$(echo $url | awk -F[/:] '{print $4}')

# Ask for a comment
echo "Please enter a comment for this URL:"
read comment

# Define the hosts file path
hosts_file="/etc/hosts"

# Check if domain already exists in hosts file
if grep -q "$domain" "$hosts_file"; then
    echo "Domain already exists in the hosts file."
else
    # Add a comment line before adding the URL
    echo -e "\n# $comment" | sudo tee -a "$hosts_file"

    # Add the domain to the hosts file
    echo "127.0.0.1 $domain" | sudo tee -a "$hosts_file"

    echo "Domain has been added to the hosts file."
fi

# Flush DNS cache
if ps aux | grep -q '[n]scd'; then
    echo "Flushing nscd cache"
    sudo /etc/init.d/nscd restart
elif ps aux | grep -q '[d]nsmasq'; then
    echo "Flushing dnsmasq cache"
    sudo /etc/init.d/dnsmasq restart
else
    echo "Flushing NetworkManager cache"
    sudo systemctl restart NetworkManager
fi