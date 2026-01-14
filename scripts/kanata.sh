#!/usr/bin/env bash
# Installs Karabiner DriverKit, Kanata, and sets up LaunchDaemons (no disk logging)

set -euo pipefail

setup_kanata() {
	# Color variables
	MAGENTA='\033[35m'
	GREEN='\033[32m'
	RESET='\033[0m'
	ARROW="${MAGENTA}==>${RESET}"

	KANATA_CONFIG="${HOME}/.config/kanata/config.kbd"
	KANATA_PORT=10000
	PLIST_DIR="/Library/LaunchDaemons"

	# 1. Fetch & install latest Karabiner DriverKit pkg
	if [ ! -d "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice" ]; then
		echo "Fetching latest Karabiner DriverKit pkg URL..."
		DRIVERKIT_PKG_URL=$(
			curl -s "https://api.github.com/repos/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/latest" |
				jq -r '.assets[] | select(.name|endswith(".pkg")) | .browser_download_url'
		)
		echo "Downloading DriverKit from: $DRIVERKIT_PKG_URL"
		curl -L -o /tmp/karabiner-driverkit.pkg "$DRIVERKIT_PKG_URL"
		echo "Installing DriverKit..."
		sudo installer -pkg /tmp/karabiner-driverkit.pkg -target /
		rm -f /tmp/karabiner-driverkit.pkg
	else
		echo -e "${GREEN}✓${RESET} Karabiner DriverKit already installed. Skipping."
	fi

	# 2. Install Kanata via Homebrew if not present
	brew list kanata >/dev/null 2>&1 || brew install kanata

	KANATA_BIN=$(command -v kanata)

	# 3. Write plist files
	sudo tee "${PLIST_DIR}/com.example.kanata.plist" >/dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.example.kanata</string>
  <key>ProgramArguments</key><array>
    <string>${KANATA_BIN}</string>
    <string>-c</string><string>${KANATA_CONFIG}</string>
    <string>--port</string><string>${KANATA_PORT}</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict></plist>
EOF
	sudo chown root:wheel "${PLIST_DIR}/com.example.kanata.plist"
	sudo chmod 644 "${PLIST_DIR}/com.example.kanata.plist"

	sudo tee "${PLIST_DIR}/com.example.karabiner-vhiddaemon.plist" >/dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.example.karabiner-vhiddaemon</string>
  <key>ProgramArguments</key><array>
    <string>/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict></plist>
EOF
	sudo chown root:wheel "${PLIST_DIR}/com.example.karabiner-vhiddaemon.plist"
	sudo chmod 644 "${PLIST_DIR}/com.example.karabiner-vhiddaemon.plist"

	sudo tee "${PLIST_DIR}/com.example.karabiner-vhidmanager.plist" >/dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.example.karabiner-vhidmanager</string>
  <key>ProgramArguments</key><array>
    <string>/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager</string>
    <string>activate</string>
  </array>
  <key>RunAtLoad</key><true/>
</dict></plist>
EOF

	sudo chown root:wheel "${PLIST_DIR}/com.example.karabiner-vhidmanager.plist"
	sudo chmod 644 "${PLIST_DIR}/com.example.karabiner-vhidmanager.plist"

	# 4. Bootstrap and enable services
	echo "Setting up kanata daemon"
	# Unload if already exists
	sudo launchctl bootout system/com.example.kanata 2>/dev/null || true
	sudo launchctl bootstrap system "${PLIST_DIR}/com.example.kanata.plist"
	sudo launchctl enable system/com.example.kanata

	echo "Setting up karabiner daemons"
	# Unload if already exists
	sudo launchctl bootout system/com.example.karabiner-vhiddaemon 2>/dev/null || true
	sudo launchctl bootstrap system "${PLIST_DIR}/com.example.karabiner-vhiddaemon.plist"
	sudo launchctl enable system/com.example.karabiner-vhiddaemon

	sudo launchctl bootout system/com.example.karabiner-vhidmanager 2>/dev/null || true
	sudo launchctl bootstrap system "${PLIST_DIR}/com.example.karabiner-vhidmanager.plist"
	sudo launchctl enable system/com.example.karabiner-vhidmanager

	# 5. Activate system extension and prompt for permissions
	echo -e "${ARROW} Activating Karabiner system extension..."
	"/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate &
	sleep 2

	echo -e "${ARROW} Opening System Settings to approve the Karabiner driver extension."
	echo -e "Please approve the ${MAGENTA}Karabiner-DriverKit-VirtualHIDDevice${RESET} extension."
	read -rp "Press Enter to open System Extensions..."
	open "x-apple.systempreferences:com.apple.Settings.Extensions"
	echo
	read -rp "Press Enter once you're done..."
	echo

	echo -e "${ARROW} Opening Accessibility settings."
	echo -e "Please add Kanata: Click '+', press Shift+Command+G, enter ${MAGENTA}/opt/homebrew/bin${RESET}, and select kanata."
	read -rp "Press Enter to open Accessibility settings..."
	open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
	echo
	read -rp "Press Enter once you're done..."
	echo

	echo -e "${ARROW} Opening Input Monitoring settings."
	echo -e "Please add Kanata using the same steps as Accessibility."
	read -rp "Press Enter to open Input Monitoring settings..."
	open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
	echo
	read -rp "Press Enter once you're done..."
	echo

	echo -e "${GREEN}✓${RESET} Kanata and Karabiner services are now installed and enabled."
	echo -e "${ARROW} Kanata should now be working. If not, restart it with:"
	echo -e "  ${MAGENTA}sudo launchctl kickstart -k system/com.example.kanata${RESET}"
}

setup_kanata
