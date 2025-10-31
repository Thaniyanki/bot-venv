#!/bin/bash
set -e

echo "[INFO] Starting bot setup..."

# --- Safe working dir ---
cd ~ || exit 1

BOT_DIR="$HOME/bot"
REPORT_FILE="$BOT_DIR/report number"

# --- Remove any old folder safely ---
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

# --- Update packages quietly ---
sudo apt-get update -y -qq

# --- Install core dependencies ---
sudo apt-get install -y -qq \
  python3 python3-pip python3-venv wget unzip iputils-ping xclip git \
  build-essential pkg-config python3-dev libffi-dev libssl-dev \
  libjpeg-dev zlib1g-dev libopenjp2-7-dev libtiff5-dev libfreetype6-dev \
  liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev libx11-dev libxext-dev \
  libxss1 libasound2t64 libgdk-pixbuf-xlib-2.0-0 || true

# --- Chromium logic (future proof) ---
if apt-cache show chromium-browser >/dev/null 2>&1; then
  sudo apt-get install -y -qq chromium-browser chromium-chromedriver
elif apt-cache show chromium >/dev/null 2>&1; then
  sudo apt-get install -y -qq chromium chromium-driver
else
  echo "[WARN] Chromium package not found on this OS."
fi

# --- Create & activate venv ---
python3 -m venv "$BOT_DIR/venv"
source "$BOT_DIR/venv/bin/activate"

# --- Install Python packages ---
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
