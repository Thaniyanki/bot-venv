#!/usr/bin/env bash
set -e

echo "[INFO] Starting bot setup..."

# Detect current directory (even if it has spaces)
BASE_DIR="$PWD"
VENV_DIR="$BASE_DIR/venv"
REPORT_FILE="$VENV_DIR/report number"
KEY_URL="https://raw.githubusercontent.com/Thaniyanki/bot-venv/main/database%20access%20key.zip"
PHONE_NUMBER="9940585709"

OS=$(uname -s)
ARCH=$(uname -m)
echo "[INFO] Detected OS: $OS | Arch: $ARCH"

# If venv already exists, delete it
if [ -d "$VENV_DIR" ]; then
  echo "[INFO] Old virtual environment found, deleting..."
  rm -rf "$VENV_DIR"
fi

# Create fresh venv directory
mkdir -p "$VENV_DIR"
echo "[OK] Folder structure ready:"
echo "  $VENV_DIR"

# Install base dependencies
echo "[INFO] Installing base dependencies..."
sudo apt-get update -y || true
sudo apt-get install -y python3 python3-venv python3-pip git curl unzip || true

# Create venv
echo "[INFO] Creating Python virtual environment..."
python3 -m venv "$VENV_DIR"

# Activate
source "$VENV_DIR/bin/activate"
python -m pip install --upgrade pip setuptools wheel

# Install Python libraries
echo "[INFO] Installing Python packages..."
pip install firebase_admin gspread selenium google-auth google-auth-oauthlib \
    google-cloud-storage google-cloud-firestore psutil pyautogui python3-xlib requests Pillow

# Create phone number file
echo "$PHONE_NUMBER" > "$REPORT_FILE"
echo "[OK] Created phone number file: '$REPORT_FILE'"

# Download Firebase access key
echo "[INFO] Downloading Firebase key..."
cd "$VENV_DIR"
curl -L -o "database access key.zip" "$KEY_URL"
unzip -o "database access key.zip" && rm "database access key.zip"

# Check if key extracted successfully
if [ -f "$VENV_DIR/database access key.json" ]; then
  echo "[OK] Firebase key extracted."
else
  echo "[ERROR] Firebase key missing!"
fi

echo
echo "✅ SETUP COMPLETE!"
echo "📁 Folder: $VENV_DIR"
echo "📄 Files inside venv:"
echo "   - database access key.json"
echo "   - report number (contains: $PHONE_NUMBER)"
echo
echo "🐍 Python version: $(python --version)"
echo "------------------------------------------------------------"
echo "[INFO] To activate your environment, run:"
echo "source \"$VENV_DIR/bin/activate\""
echo
