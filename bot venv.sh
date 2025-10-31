#!/bin/bash
set -e

echo "🚀 Starting Raspberry Pi Bot Environment Setup..."

# Define directories
BOT_DIR="/home/$USER/bot"
VENV_DIR="$BOT_DIR/venv"
REPORT_FILE="$BOT_DIR/report number"

echo "🧹 Cleaning old bot folders if any..."
if [ -d "$BOT_DIR" ] || [ -d "/home/$USER/Bot" ]; then
    sudo rm -rf "$BOT_DIR" "/home/$USER/Bot"
    echo "🗑️ Old bot folders deleted."
fi

echo "📁 Creating folder structure..."
mkdir -p "$VENV_DIR"
echo "9940585709" > "$REPORT_FILE"

echo "✅ Folder structure created:"
echo "  ~/bot"
echo "  ~/bot/venv"
echo "  ~/bot/report number (contains: 9940585709)"

echo "🔄 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing required system packages..."
sudo apt install -y python3-pip python3-venv wget iputils-ping xclip chromium chromium-driver

echo "🐍 Creating Python virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "⬆️ Upgrading pip..."
pip install --upgrade pip

echo "📦 Installing Python dependencies inside venv..."
pip install firebase-admin selenium gspread oauth2client python-dateutil Pillow urllib3 psutil pyautogui pyperclip

echo "✅ Setup complete!"
echo "📂 Bot folder ready at: $BOT_DIR"
echo "➡ To activate your environment, run:"
echo "   source ~/bot/venv/bin/activate"
echo "➡ To deactivate, run:"
echo "   deactivate"
