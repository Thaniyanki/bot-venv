#!/bin/bash
set -e

echo "[INFO] Starting bot setup..."

USER_HOME="$HOME"
BOT_DIR="$USER_HOME/bot"
VENV_DIR="$BOT_DIR/venv"
REPORT_FILE="$BOT_DIR/report number"

if [ -d "$BOT_DIR" ]; then
  echo "[INFO] Removing existing bot folder..."
  rm -rf "$BOT_DIR"
fi

mkdir -p "$VENV_DIR"
echo "9940585709" > "$REPORT_FILE"

OS=$(uname -s)
ARCH=$(uname -m)
echo "[INFO] Detected OS: $OS  |  Arch: $ARCH"

# Detect Raspberry Pi OS release name (bullseye/bookworm/trixie etc.)
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_RELEASE="$VERSION_CODENAME"
else
  OS_RELEASE="unknown"
fi
echo "[INFO] OS release: $OS_RELEASE"

echo "[INFO] Installing dependencies..."
sudo apt-get update -qq

# Base packages
sudo apt-get install -y -qq python3 python3-venv python3-pip curl wget unzip git build-essential pkg-config python3-dev libffi-dev libssl-dev libjpeg-dev zlib1g-dev libopenjp2-7-dev libtiff5-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev || true

# Chromium (detect right package name)
if apt-cache show chromium-browser >/dev/null 2>&1; then
  sudo apt-get install -y -qq chromium-browser || true
elif apt-cache show chromium >/dev/null 2>&1; then
  sudo apt-get install -y -qq chromium || true
elif apt-cache show chromium-common >/dev/null 2>&1; then
  sudo apt-get install -y -qq chromium-common || true
else
  echo "[WARN] Chromium package not found in repo."
fi

# GUI-less (headless) environment setup if needed
if ! command -v startx >/dev/null 2>&1; then
  sudo apt-get install -y -qq xvfb x11-utils libxss1 libnss3 || true
fi

# Create and activate venv
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
pip install --upgrade pip setuptools wheel >/dev/null 2>&1

# Python dependencies
pip install -q \
  selenium psutil gspread google-auth google-auth-oauthlib google-auth-httplib2 \
  google-api-python-client google-cloud-storage google-cloud-firestore firebase_admin \
  pyautogui requests

# Chromium path + version
CHROMIUM_PATH=$(command -v chromium-browser || command -v chromium || command -v chromium-common)
if [ -n "$CHROMIUM_PATH" ]; then
  CHROME_VERSION=$($CHROMIUM_PATH --version | grep -oE "[0-9]+(\.[0-9]+)+")
  echo "[INFO] Chromium version: $CHROME_VERSION"
else
  echo "[WARN] Chromium executable not found."
fi

# ChromeDriver auto install
CHROMEDRIVER_DIR="$VENV_DIR/bin"
mkdir -p "$CHROMEDRIVER_DIR"
if [ -n "$CHROME_VERSION" ]; then
  MAJOR_VER=$(echo "$CHROME_VERSION" | cut -d. -f1)
  DRIVER_JSON_URL="https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json"
  DRIVER_VERSION=$(curl -s $DRIVER_JSON_URL | grep -A3 "\"$CHROME_VERSION\"" | grep "version" | head -1 | cut -d'"' -f4)
  if [ -n "$DRIVER_VERSION" ]; then
    DRIVER_DL="https://storage.googleapis.com/chrome-for-testing-public/$DRIVER_VERSION/linux64/chromedriver-linux64.zip"
    wget -q "$DRIVER_DL" -O /tmp/chromedriver.zip || true
    unzip -oq /tmp/chromedriver.zip -d /tmp/
    mv /tmp/chromedriver-linux64/chromedriver "$CHROMEDRIVER_DIR/"
    chmod +x "$CHROMEDRIVER_DIR/chromedriver"
    rm -rf /tmp/chromedriver*
    echo "[INFO] ChromeDriver installed inside venv."
  else
    echo "[WARN] Could not find ChromeDriver for version $CHROME_VERSION"
  fi
fi

deactivate

echo "[✅ SETUP COMPLETE]"
echo "Folders:"
echo "  $BOT_DIR"
echo "  $VENV_DIR"
echo "  $REPORT_FILE (contains: 9940585709)"
echo "Python packages installed inside: $VENV_DIR"
echo "[INFO] To activate: source $VENV_DIR/bin/activate"
echo "------------------------------------------------------------"
