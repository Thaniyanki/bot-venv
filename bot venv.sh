#!/bin/bash
# =============================================
# Raspberry Pi Bot Folder & Venv Creator
# Repo: https://github.com/Thaniyanki/bot-venv
# Author: Thaniyanki
# =============================================

set -e

echo "🧹 Checking for existing bot folders..."

# Delete any folder named bot or Bot in home directory
if [ -d ~/bot ]; then
    echo "⚠️ Found existing ~/bot — deleting..."
    rm -rf ~/bot
fi

if [ -d ~/Bot ]; then
    echo "⚠️ Found existing ~/Bot — deleting..."
    rm -rf ~/Bot
fi

echo "📁 Creating new bot folder structure..."

# Create fresh bot and venv folders
mkdir -p ~/bot/venv

# Create report number file
echo "9940585709" > ~/bot/"report number"

echo "✅ Setup complete!"
echo "Created:"
echo "  ~/bot"
echo "  ~/bot/venv"
echo "  ~/bot/report number (contains: 9940585709)"
