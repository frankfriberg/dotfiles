#!/usr/bin/env bash
# Configures the macOS Dock with preferred applications
#
# CUSTOMIZATION:
# - The order of apps in this script = the order in your Dock (left to right)
# - To add an app: [ -d "/Applications/YourApp.app" ] && dockutil --add "/Applications/YourApp.app" --no-restart
# - To remove an app: Delete or comment out its line
# - To reorder: Move lines up or down
# - System apps: /System/Applications/AppName.app
# - Regular apps: /Applications/AppName.app

setup_dock() {
	GREEN='\033[32m'
	YELLOW='\033[33m'
	RESET='\033[0m'

	echo -e "${YELLOW}Configuring Dock applications...${RESET}"

	dockutil --remove all --no-restart 2>/dev/null || true

	[ -d "/Applications/Spark.app" ] && dockutil --add "/Applications/Spark.app" --no-restart
	[ -d "/Applications/Arc.app" ] && dockutil --add "/Applications/Arc.app" --no-restart
	[ -d "/Applications/Ghostty.app" ] && dockutil --add "/Applications/Ghostty.app" --no-restart
	[ -d "/Applications/Telegram.app" ] && dockutil --add "/Applications/Telegram.app" --no-restart
	[ -d "/Applications/Notion.app" ] && dockutil --add "/Applications/Notion.app" --no-restart
	[ -d "/Applications/Linear.app" ] && dockutil --add "/Applications/Linear.app" --no-restart
	[ -d "/Applications/Spotify.app" ] && dockutil --add "/Applications/Spotify.app" --no-restart
	[ -d "/Applications/Brain.fm.app" ] && dockutil --add "/Applications/Brain.fm.app" --no-restart
	[ -d "/Applications/Slack.app" ] && dockutil --add "/Applications/Slack.app" --no-restart

	dockutil --add "~/Downloads" --section "others" --view grid --display folder --sort dateadded --no-restart 2>/dev/null || true

	killall Dock

	echo -e "${GREEN}✓ Dock configuration complete!${RESET}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	setup_dock
fi
