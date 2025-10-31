#!/usr/bin/env bash
set -e

echo "[INFO] Starting bot setup..."

# Ensure we are in HOME
cd ~

BOT_DIR="$HOME/bot"
VENV_DIR="$BOT_DIR/venv"
REPORT_FILE="$BOT_DIR/report number"

echo "[INFO] Detected OS: $(uname -s) | Arch: $(uname -m)"

# Clean old folders safely
if [ -d "$BOT_DIR" ]; then
  echo "[INFO] Cleaning old bot folder..."
  rm -rf "$BOT_DIR"
fi

# Create new structure
mkdir -p "$VENV_DIR"
mkdir -p "$REPORT_FILE"
echo "9940585709" > "$REPORT_FILE/number.txt"

echo "[OK] Folder structure ready."

# Update system and install dependencies
echo "[INFO] Installing base dependencies..."
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip python3-venv wget unzip git build-essential pkg-config python3-dev libffi-dev libssl-dev libjpeg-dev zlib1g-dev libopenjp2-7-dev libtiff5-dev libfreetype-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev libx11-dev libxext-dev libxss1 libasound2t64 libgdk-pixbuf-xlib-2.0-0 || true

# Fallback Chromium setup
echo "[INFO] Installing Chromium browser (fallback-safe)..."
sudo apt-get install -y chromium chromium-driver || sudo apt-get install -y chromium-browser chromium-chromedriver || true

# Create and activate Python virtual environment
echo "[INFO] Creating Python venv..."
python3 -m venv "$VENV_DIR"

source "$VENV_DIR/bin/activate"

# Upgrade pip and install Python libraries
echo "[INFO] Installing Python packages inside venv..."
pip install --upgrade pip setuptools wheel
pip install firebase_admin gspread selenium psutil pyautogui pillow httpx google-cloud-storage google-cloud-firestore requests

deactivate

echo "[✅ SETUP COMPLETE]"
echo "Folders:"
echo "  $BOT_DIR"
echo "  $VENV_DIR"
echo "  $REPORT_FILE (contains: 9940585709)"
echo "Python packages installed inside: $VENV_DIR"
echo "[INFO] To activate: source $VENV_DIR/bin/activate"
echo "------------------------------------------------------------"
