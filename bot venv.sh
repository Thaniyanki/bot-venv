#!/bin/bash
set -e
echo "[INFO] Starting universal bot venv setup..."

BOT_DIR="$HOME/bot"
VENV_DIR="$BOT_DIR/venv"
REPORT_FILE="$BOT_DIR/report number"
NUMBER="9940585709"

# ---------- Step 1: Cleanup ----------
echo "[WARN] Checking for existing bot folders..."
find "$HOME" -maxdepth 1 -type d \( -iname "bot" -o -iname "Bot" \) -exec rm -rf {} +
echo "[OK] Old bot folders deleted."

# ---------- Step 2: Folder structure ----------
echo "[INFO] Creating folder structure at $BOT_DIR"
mkdir -p "$VENV_DIR"
echo "$NUMBER" > "$REPORT_FILE"
echo "[OK] Created:"
echo "  $BOT_DIR"
echo "  $VENV_DIR"
echo "  $REPORT_FILE (contains: $NUMBER)"

# ---------- Step 3: OS Detection ----------
OS=$(grep -E '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
VERSION=$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
ARCH=$(uname -m)
echo "[INFO] Detected OS: $OS $VERSION ($ARCH)"

# ---------- Step 4: Update ----------
echo "[INFO] Updating system package list..."
sudo apt-get update -y

# ---------- Step 5: Core packages ----------
echo "[INFO] Installing essential system packages..."
sudo apt-get install -y --no-install-recommends \
  python3 python3-pip python3-venv wget curl unzip git iputils-ping xclip \
  build-essential pkg-config python3-dev libffi-dev libssl-dev \
  zlib1g-dev libjpeg-dev libopenjp2-7-dev libtiff5-dev libfreetype6-dev \
  liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev libx11-dev libxext-dev || true

# ---------- Step 6: Dynamic dependency correction ----------
declare -A PACKAGE_MAP=(
  ["libasound2"]="libasound2t64"
  ["libgdk-pixbuf2.0-0"]="libgdk-pixbuf-xlib-2.0-0"
)

for pkg in libasound2 libgdk-pixbuf2.0-0; do
  if ! apt-cache show "$pkg" >/dev/null 2>&1; then
    alt="${PACKAGE_MAP[$pkg]}"
    echo "[WARN] $pkg not found — using replacement: $alt"
    sudo apt-get install -y --no-install-recommends "$alt" || true
  else
    sudo apt-get install -y --no-install-recommends "$pkg" || true
  fi
done

# ---------- Step 7: Chromium setup ----------
echo "[INFO] Installing Chromium browser and driver..."
if ! command -v chromium-browser >/dev/null 2>&1 && ! command -v chromium >/dev/null 2>&1; then
  if apt-cache show chromium-browser >/dev/null 2>&1; then
    sudo apt-get install -y chromium-browser chromium-chromedriver
  elif apt-cache show chromium >/dev/null 2>&1; then
    sudo apt-get install -y chromium chromium-driver
  else
    echo "[WARN] Chromium packages unavailable. Trying Snap method..."
    sudo apt-get install -y snapd || true
    sudo snap install chromium || echo "[WARN] Chromium Snap install skipped."
  fi
else
  echo "[OK] Chromium already installed."
fi

# ---------- Step 8: Virtual Environment ----------
echo "[INFO] Creating Python virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# ---------- Step 9: Python dependencies ----------
echo "[INFO] Installing Python dependencies..."
pip install --upgrade pip wheel setuptools
pip install selenium psutil requests beautifulsoup4 pillow

deactivate

# ---------- Step 10: Summary ----------
echo "------------------------------------------------------------"
echo "[✅ SETUP COMPLETE]"
echo "Folders:"
echo "  $BOT_DIR"
echo "  $VENV_DIR"
echo "  $REPORT_FILE (contains: $NUMBER)"
echo "Python packages installed inside: $VENV_DIR"
echo "Chromium installed (or skipped if unavailable)"
echo "[INFO] Activate venv using: source $VENV_DIR/bin/activate"
echo "------------------------------------------------------------"
