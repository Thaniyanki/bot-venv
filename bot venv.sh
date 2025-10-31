#!/bin/bash
set -e

echo "[INFO] Starting bot setup..."

# ---------------------------------------------------------------------------
# 0️⃣ Detect current directory issues
if ! cd ~ >/dev/null 2>&1; then
  echo "[WARN] Unable to access home directory; using /tmp"
  cd /tmp
fi

# ---------------------------------------------------------------------------
# 1️⃣ Detect system info
OS=$(uname -s)
ARCH=$(uname -m)
echo "[INFO] Detected OS: $OS | Arch: $ARCH"

# ---------------------------------------------------------------------------
# 2️⃣ Remove existing bot folder if any
echo "[INFO] Cleaning old bot folder..."
rm -rf ~/bot

# ---------------------------------------------------------------------------
# 3️⃣ Create folder structure
mkdir -p ~/bot/venv
mkdir -p ~/bot/"report number (contains: 9940585709)"
echo "[OK] Folder structure ready."

# ---------------------------------------------------------------------------
# 4️⃣ Update system safely
sudo apt-get update -y >/dev/null 2>&1
sudo apt-get upgrade -y >/dev/null 2>&1 || true

# ---------------------------------------------------------------------------
# 5️⃣ Core dependencies
echo "[INFO] Installing base dependencies..."
sudo apt-get install -y python3 python3-venv python3-pip unzip wget curl git libnss3 libgdk-pixbuf2.0-0 libxss1 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxkbcommon0 >/dev/null 2>&1

# ---------------------------------------------------------------------------
# 6️⃣ Universal Chromium installer
install_chromium() {
  echo "[INFO] Installing Chromium..."

  if command -v chromium-browser >/dev/null 2>&1; then
    echo "[OK] Chromium-browser found."
  elif command -v chromium >/dev/null 2>&1; then
    echo "[OK] Chromium found."
  else
    echo "[INFO] Searching for available Chromium packages..."
    if apt-cache show chromium-browser >/dev/null 2>&1; then
      sudo apt-get install -y chromium-browser >/dev/null 2>&1
    elif apt-cache show chromium >/dev/null 2>&1; then
      sudo apt-get install -y chromium >/dev/null 2>&1
    elif command -v snap >/dev/null 2>&1; then
      sudo snap install chromium >/dev/null 2>&1
    else
      echo "[ERROR] Chromium not available via apt or snap."
      return 1
    fi
  fi

  # --- Chromedriver setup ---
  echo "[INFO] Installing Chromedriver..."
  DRIVER_PATH="/usr/local/bin/chromedriver"
  if [ ! -f "$DRIVER_PATH" ]; then
    DRIVER_VERSION=$(curl -sSL https://chromedriver.storage.googleapis.com/LATEST_RELEASE)
    wget -q "https://chromedriver.storage.googleapis.com/${DRIVER_VERSION}/chromedriver_linux32.zip" -O /tmp/chromedriver.zip
    unzip -qo /tmp/chromedriver.zip -d /usr/local/bin/
    chmod +x /usr/local/bin/chromedriver
    rm /tmp/chromedriver.zip
  fi

  echo "[OK] Chromium + Chromedriver installed."
}

install_chromium

# ---------------------------------------------------------------------------
# 7️⃣ Python virtual environment setup
echo "[INFO] Creating Python venv..."
python3 -m venv ~/bot/venv
source ~/bot/venv/bin/activate
pip install --upgrade pip >/dev/null 2>&1

# ---------------------------------------------------------------------------
# 8️⃣ Install essential Python packages
echo "[INFO] Installing Python packages..."
pip install selenium==4.25.0 psutil requests >/dev/null 2>&1

# ---------------------------------------------------------------------------
# 9️⃣ Final info
echo "[✅ SETUP COMPLETE]"
echo "Folders:"
echo "  ~/bot"
echo "  ~/bot/venv"
echo "  ~/bot/report number (contains: 9940585709)"
echo "Python packages installed inside: ~/bot/venv"
echo "[INFO] To activate: source ~/bot/venv/bin/activate"
