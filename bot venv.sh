#!/bin/bash
# =============================================
# Raspberry Pi Bot Folder & Venv Creator
# Repo: https://github.com/Thaniyanki/bot-venv
# Author: Thaniyanki
# =============================================

set -e

echo "📁 Creating bot folder structure..."

# Create bot and venv folders
mkdir -p ~/bot/venv

# Create report number file with the specified number
echo "9940585709" > ~/bot/"report number"

echo "✅ Done!"
echo "Created folders and file:"
echo "  ~/bot"
echo "  ~/bot/venv"
echo "  ~/bot/report number (contains: 9940585709)"
