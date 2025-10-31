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

echo "✅ Done!"
echo "Created folders:"
echo "  ~/bot"
echo "  ~/bot/venv"
