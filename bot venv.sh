#!/bin/bash
set -e

echo "[INFO] Starting bot setup..."

# --- Always go to home safely (prevents getcwd errors) ---
cd ~ || exit 1

BOT_DIR="$HOME/bot"
REPORT_FILE="$BOT_DIR/report number"

# --- Remove any old bot folder safely ---
if [ -d "$BOT_DIR" ]; then
  echo "[INFO] Removing existing bot folder..."
  rm -rf "$BOT_DIR"
fi

# --- Create structure ---
mkdir -p "$BOT_DIR/venv"
echo "9940585709" > "$REPORT_FILE"
echo "[INFO] Folder structure ready."

# --- Detect OS / Architecture ---
OS_NAME=$(uname -s)
ARCH=$(uname -m)
echo "[INFO] Detected OS: $OS_NAME | Arch: $ARCH"

# --- Update package list ---
sudo apt-get update -y -qq

# --- Install system dependencies ---
sudo apt-get install -y -qq \
  python3 python3-pip python3-venv wget unzip iputils-ping xclip git \
  build-essential pkg-config python3-dev libffi-dev libssl-dev \
  libjpeg-dev zlib1g-dev libopenjp2-7-dev libtiff5-dev libfreetype6-dev \
  liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev libx11-dev libxext-dev \
  libxss1 libasound2t64 libgdk-pixbuf-xlib-2.0-0 || true

# --- Chromium installation (auto-detect version) ---
if apt-cache show chromium >/dev/null 2>&1; then
  sudo apt-get install -y -qq chromium chromium-driver
elif apt-cache show chromium-browser >/dev/null 2>&1; then
  sudo apt-get install -y -qq chromium-browser chromium-chromedriver
else
  echo "[WARN] Chromium not found in current repos."
fi

# --- Setup Python venv ---
python3 -m venv "$BOT_DIR/venv"
source "$BOT_DIR/venv/bin/activate"

# --- Upgrade pip and install all Python deps ---
pip install -q --upgrade pip
pip install -q firebase-admin selenium gspread oauth2client \
  python-dateutil Pillow urllib3 psutil pyautogui pyperclip

deactivate

echo "[✅ SETUP COMPLETE]"
echo "Folders:"
echo "  $BOT_DIR"
echo "  $BOT_DIR/venv"
echo "  $REPORT_FILE (contains: 9940585709)"
echo "Python packages installed inside: $BOT_DIR/venv"
echo "[INFO] To activate: source $BOT_DIR/venv/bin/activate"
