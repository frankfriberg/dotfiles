#!/bin/bash

# Get the path of the "kanata" executable
KANATA_BIN=$(which kanata)

# Get the current user
CURRENT_USER=$(whoami)

# Define the plist file path
PLIST_FILE="./io.dreamsofcode.kanata.plist"

# Define the config path based on the current user
KANATA_CONFIG="/Users/$CURRENT_USER/.config/kanata/kanata.kbd"

# Update the plist file with the correct paths
sed -i.bak "
s|{kanata_bin}|$KANATA_BIN|;
s|{kanata_config}|$KANATA_CONFIG|;
" "$PLIST_FILE"

sudo cp ./io.dreamsofcode.kanata.plist /Library/LaunchDaemons/
sudo launchctl load /Library/LaunchDaemons/io.dreamsofcode.kanata.plist
sudo launchctl start io.dreamsofcode.kanata

echo "Kanata daemon added"
