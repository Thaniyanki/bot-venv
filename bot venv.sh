#!/bin/bash
set -e
echo "[INFO] Starting universal bot venv setup..."

BOT_DIR="$HOME/bot"
VENV_DIR="$BOT_DIR/venv"
REPORT_FILE="$BOT_DIR/report number"
NUMBER="9940585709"

# ---------- Cleanup ----------
echo "[WARN] Checking for existing bot folders..."
find "$HOME" -maxdepth 1 -type d \( -iname "bot" -o -iname "Bot" \) -exec rm -rf {} +
echo "[OK] Old bot folders deleted."

# ---------- Folder Structure ----------
echo "[INFO] Creating folder structure at $BOT_DIR"
mkdir -p "$VENV_DIR"
echo "$NUMBER" > "$REPORT_FILE"
echo "[OK] Created:"
echo "  $BOT_DIR"
echo "  $VENV_DIR"
echo "  $REPORT_FILE (contains: $NUMBER)"

# ---------- OS Info ----------
OS=$(grep -E '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
VERSION=$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
ARCH=$(uname -m)
echo "[INFO] Detected OS: $OS $VERSION ($ARCH)"

# ---------- Update ----------
echo "[INFO] Updating system package list..."
sudo apt-get update -y

# ---------- Core Packages ----------
echo "[INFO] Installing essential system packages..."
sudo apt-get install -y --no-install-recommends \
  python3 python3-pip python3-venv wget curl unzip git iputils-ping xclip \
  build-essential pkg-config python3-dev libffi-dev libssl-dev \
  zlib1g-dev libjpeg-dev libopenjp2-7-dev libtiff5-dev libfreetype6-dev \
  liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev libx11-dev libxext-dev libxss1 || true

# ---------- Self-Healing Library Fixer ----------
declare -A REPLACEMENTS=(
  ["libasound2"]="libasound2t64"
  ["libgdk-pixbuf2.0-0"]="libgdk-pixbuf-xlib-2.0-0"
)

for pkg in "${!REPLACEMENTS[@]}"; do
  if ! apt-cache show "$pkg" >/dev/null 2>&1; then
    alt="${REPLACEMENTS[$pkg]}"
    echo "[WARN] $pkg not found, replacing with $alt"
    sudo apt-get install -y "$alt" || true
  else
    sudo apt-get install -y "$pkg" || true
  fi
done

# ---------- Chromium ----------
echo "[INFO] Installing Chromium browser and driver..."
if command -v chromium-browser >/dev/null 2>&1 || command -v chromium >/dev/null 2>&1; then
  echo "[OK] Chromium already installed."
else
  if apt-cache show chromium-browser >/dev/null 2>&1; then
    sudo apt-get install -y chromium-browser chromium-chromedriver || true
  elif apt-cache show chromium >/dev/null 2>&1; then
    sudo apt-get install -y chromium chromium-driver || true
  else
    echo "[WARN] Falling back to Snap Chromium install..."
    sudo apt-get install -y snapd || true
    sudo snap install chromium || echo "[WARN] Chromium Snap install skipped."
  fi
fi

# ---------- Virtual Environment ----------
echo "[INFO] Creating Python virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# ---------- Python Dependencies ----------
echo "[INFO] Installing Python dependencies..."
pip install --upgrade pip wheel setuptools
pip install firebase-admin selenium gspread oauth2client python-dateutil Pillow urllib3 psutil pyautogui pyperclip

deactivate

# ---------- Summary ----------
echo "------------------------------------------------------------"
echo "[✅ SETUP COMPLETE]"
echo "Folders:"
echo "  $BOT_DIR"
echo "  $VENV_DIR"
echo "  $REPORT_FILE (contains: $NUMBER)"
echo "Python packages installed inside: $VENV_DIR"
echo "[INFO] To activate: source $VENV_DIR/bin/activate"
echo "------------------------------------------------------------"
