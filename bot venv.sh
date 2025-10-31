#!/bin/bash
set -e

echo "[INFO] Starting bot setup..."

# --- Detect user and home directory ---
USER_HOME="$HOME"
BOT_DIR="$USER_HOME/bot"
VENV_DIR="$BOT_DIR/venv"
REPORT_FILE="$BOT_DIR/report number"

# --- Clean old installations ---
if [ -d "$BOT_DIR" ]; then
  echo "[INFO] Removing existing bot folder..."
  rm -rf "$BOT_DIR"
fi

# --- Recreate structure ---
mkdir -p "$VENV_DIR"
echo "9940585709" > "$REPORT_FILE"

# --- Detect OS + architecture ---
OS=$(uname -s)
ARCH=$(uname -m)
echo "[INFO] Detected OS: $OS  |  Arch: $ARCH"

# --- Ensure core packages ---
sudo apt-get update -qq
sudo apt-get install -y -qq python3 python3-venv python3-pip curl wget unzip chromium-browser || \
sudo apt-get install -y -qq chromium

# --- Create virtual environment ---
python3 -m venv "$VENV_DIR"

# --- Activate venv and install dependencies ---
source "$VENV_DIR/bin/activate"
pip install --upgrade pip setuptools wheel >/dev/null 2>&1

# --- Install all Python dependencies (inside venv) ---
pip install \
  selenium \
  psutil \
  gspread \
  google-auth \
  google-auth-oauthlib \
  google-auth-httplib2 \
  google-api-python-client \
  google-cloud-storage \
  google-cloud-firestore \
  firebase_admin \
  pyautogui \
  requests >/dev/null 2>&1

# --- Detect Chromium version ---
CHROMIUM_PATH=$(command -v chromium-browser || command -v chromium)
if [ -z "$CHROMIUM_PATH" ]; then
  echo "[WARN] Chromium not found."
else
  CHROME_VERSION=$($CHROMIUM_PATH --version | grep -oE "[0-9]+(\.[0-9]+)+")
  echo "[INFO] Chromium version: $CHROME_VERSION"
fi

# --- Install matching ChromeDriver ---
CHROMEDRIVER_DIR="$VENV_DIR/bin"
CHROMEDRIVER_URL="https://storage.googleapis.com/chrome-for-testing-public"
MAJOR_VER=$(echo "$CHROME_VERSION" | cut -d. -f1)
DRIVER_JSON_URL="https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json"

if [ -n "$MAJOR_VER" ]; then
  DRIVER_VERSION=$(curl -s $DRIVER_JSON_URL | grep -A3 "\"$CHROME_VERSION\"" | grep "version" | head -1 | cut -d'"' -f4)
  if [ -n "$DRIVER_VERSION" ]; then
    DRIVER_DL="$CHROMEDRIVER_URL/$DRIVER_VERSION/linux64/chromedriver-linux64.zip"
    wget -q "$DRIVER_DL" -O /tmp/chromedriver.zip || true
    unzip -oq /tmp/chromedriver.zip -d /tmp/
    mv /tmp/chromedriver-linux64/chromedriver "$CHROMEDRIVER_DIR/"
    chmod +x "$CHROMEDRIVER_DIR/chromedriver"
    rm -rf /tmp/chromedriver*
    echo "[INFO] ChromeDriver installed inside venv."
  else
    echo "[WARN] Could not match ChromeDriver for version $CHROME_VERSION"
  fi
fi

deactivate

# --- Completion message ---
echo "[✅ SETUP COMPLETE]"
echo "Folders:"
echo "  $BOT_DIR"
echo "  $VENV_DIR"
echo "  $REPORT_FILE (contains: 9940585709)"
echo "Python packages installed inside: $VENV_DIR"
echo "[INFO] To activate: source $VENV_DIR/bin/activate"
echo "------------------------------------------------------------"
