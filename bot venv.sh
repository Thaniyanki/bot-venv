#!/usr/bin/env bash
set -e

echo "[INFO] Starting bot setup..."

BASE_DIR="$HOME/bot"
VENV_DIR="$BASE_DIR/venv"
REPORT_FILE="$BASE_DIR/report number"
KEY_URL="https://raw.githubusercontent.com/Thaniyanki/bot-venv/main/database%20access%20key.zip"
PHONE_NUMBER="9940585709"

# --- Detect OS and Architecture ---
OS=$(uname -s)
ARCH=$(uname -m)
echo "[INFO] Detected OS: $OS | Arch: $ARCH"

# --- Clean Previous Installations ---
if [ -d "$BASE_DIR" ]; then
  echo "[INFO] Removing old bot folder..."
  rm -rf "$BASE_DIR"
fi

# --- Recreate Folder Structure ---
mkdir -p "$VENV_DIR"
echo "$PHONE_NUMBER" > "$REPORT_FILE"
echo "[OK] Folder structure ready:"
echo "  $BASE_DIR"
echo "  $REPORT_FILE (contains: $PHONE_NUMBER)"
echo "  $VENV_DIR"

# --- Install Core Dependencies ---
echo "[INFO] Installing base dependencies..."
sudo apt-get update -y || true
sudo apt-get install -y python3 python3-venv python3-pip git curl unzip || true

# --- Create Virtual Environment ---
echo "[INFO] Creating Python virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
python -m pip install --upgrade pip setuptools wheel

# --- Install Required Python Packages ---
echo "[INFO] Installing Python dependencies..."
pip install firebase_admin gspread selenium google-auth google-auth-oauthlib \
    google-cloud-storage google-cloud-firestore psutil pyautogui python3-xlib requests Pillow

# --- Download and Extract Firebase Key ---
echo "[INFO] Downloading database access key..."
cd "$VENV_DIR"
curl -L -o "database access key.zip" "$KEY_URL"
unzip -o "database access key.zip" && rm "database access key.zip"

# --- Verify key extraction ---
if [ -f "$VENV_DIR/database access key.json" ]; then
  echo "[OK] Firebase key extracted to: $VENV_DIR/database access key.json"
else
  echo "[ERROR] Firebase key not found after extraction!"
fi

# --- Chromium Check (optional) ---
echo "[INFO] Checking Chromium availability..."
if ! command -v chromium-browser >/dev/null 2>&1; then
  echo "[WARN] Chromium not found. Trying to install..."
  sudo apt-get install -y chromium chromium-driver || \
  sudo apt-get install -y chromium-browser chromium-chromedriver || \
  echo "[WARN] Could not install Chromium automatically."
fi

# --- Final Summary ---
echo
echo "[✅ SETUP COMPLETE]"
echo "Folders:"
echo "  $BASE_DIR"
echo "  $REPORT_FILE (contains: $PHONE_NUMBER)"
echo "  $VENV_DIR"
echo "Python version: $(python --version)"
echo "------------------------------------------------------------"
echo "[INFO] To activate: source $VENV_DIR/bin/activate"
