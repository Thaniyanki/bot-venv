#!/usr/bin/env bash
set -e

echo "[INFO] Starting bot setup..."
BASE_DIR="$HOME/bot"
VENV_DIR="$BASE_DIR/venv"
REPORT_FILE="$VENV_DIR/report number"
PHONE_NUMBER="9940585709"

# --- 1️⃣ Detect OS and architecture ---
OS=$(uname -s)
ARCH=$(uname -m)
echo "[INFO] Detected OS: $OS | Arch: $ARCH"

# --- 2️⃣ Clean previous installs if exist ---
if [ -d "$BASE_DIR" ]; then
  echo "[INFO] Removing old bot folder..."
  rm -rf "$BASE_DIR"
fi

# --- 3️⃣ Recreate folder structure ---
mkdir -p "$VENV_DIR"
echo "$PHONE_NUMBER" > "$REPORT_FILE"

echo "[OK] Folder structure ready:"
echo "  $BASE_DIR"
echo "  $VENV_DIR"
echo "  $REPORT_FILE (contains: $PHONE_NUMBER)"

# --- 4️⃣ Update system safely ---
echo "[INFO] Updating package lists..."
sudo apt-get update -y || true
sudo apt-get install -y python3 python3-venv python3-pip git curl wget unzip || true

# --- 5️⃣ Create or repair virtual environment ---
if [ ! -f "$VENV_DIR/bin/activate" ]; then
  echo "[INFO] Creating new Python virtual environment..."
  python3 -m venv "$VENV_DIR"
else
  echo "[INFO] Virtual environment already exists. Skipping creation."
fi

# --- 6️⃣ Activate and upgrade pip ---
source "$VENV_DIR/bin/activate"
python -m pip install --upgrade pip setuptools wheel

# --- 7️⃣ Install core dependencies inside venv ---
echo "[INFO] Installing Python dependencies inside virtual environment..."
pip install \
  firebase_admin \
  gspread \
  selenium \
  google-auth \
  google-auth-oauthlib \
  google-cloud-storage \
  google-cloud-firestore \
  psutil \
  pyautogui \
  python3-xlib \
  requests \
  Pillow

# --- 8️⃣ Chromium handling ---
echo "[INFO] Checking Chromium availability..."
if ! command -v chromium-browser >/dev/null 2>&1; then
  echo "[WARN] Chromium not found. Installing fallback..."
  sudo apt-get install -y chromium chromium-driver || \
  sudo apt-get install -y chromium-browser chromium-chromedriver || \
  echo "[WARN] Could not install Chromium automatically — please install manually later."
fi

# --- 9️⃣ Final info ---
echo "[✅ SETUP COMPLETE]"
echo "Folders:"
echo "  $BASE_DIR"
echo "  $VENV_DIR"
echo "  $REPORT_FILE (contains: $PHONE_NUMBER)"
echo "Python installed in: $(which python)"
echo "Python version: $(python --version)"
echo "------------------------------------------------------------"
echo "[INFO] To activate: source $VENV_DIR/bin/activate"
