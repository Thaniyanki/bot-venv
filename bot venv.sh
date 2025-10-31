#!/usr/bin/env bash
# bot venv.sh
# Universal, future-proof Raspberry Pi "bot" venv installer
# - Creates ~/bot/venv and ~/bot/"report number"
# - Installs system packages as needed
# - Creates venv at ~/bot/venv and installs Python deps inside venv
# - Attempts to install Chromium + chromedriver with multiple fallbacks
# Author: Thaniyanki
set -euo pipefail

# ---- Configuration ----
BOT_DIR="$HOME/bot"
VENV_DIR="$BOT_DIR/venv"
REPORT_FILE="$BOT_DIR/report number"
REPORT_NUMBER="9940585709"

PYTHON_PKGS=( firebase-admin selenium gspread oauth2client python-dateutil Pillow urllib3 psutil pyautogui pyperclip )

# System packages commonly needed for building Python extensions / Pillow
SYS_PKGS_COMMON=( python3 python3-pip python3-venv wget unzip iputils-ping xclip git )
SYS_PKGS_BUILD=( build-essential pkg-config python3-dev libffi-dev libssl-dev )
SYS_PKGS_IMG=( libjpeg-dev zlib1g-dev libopenjp2-7-dev libtiff5-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev libx11-dev libxext-dev libxss1 libasound2 libgdk-pixbuf2.0-0 )

# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

log() { printf "%b\n" "${CYAN}[INFO]${RESET} $*"; }
warn() { printf "%b\n" "${YELLOW}[WARN]${RESET} $*"; }
err() { printf "%b\n" "${RED}[ERROR]${RESET} $*"; }
ok()  { printf "%b\n" "${GREEN}[OK]${RESET} $*"; }

# ---- Helpers ----
run_apt_install() {
  local pkgs=("$@")
  if [ "${#pkgs[@]}" -eq 0 ]; then return; fi
  log "Installing APT packages: ${pkgs[*]}"
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -y
  sudo apt-get install -y "${pkgs[@]}"
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

detect_arch() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64) echo "x86_64" ;;
    aarch64|arm64) echo "aarch64" ;;
    armv7l|armhf) echo "armv7l" ;;
    *) echo "$arch" ;;
  esac
}

# ---- Start ----
log "Starting universal bot venv setup..."

# 1) Remove existing bot folders (~/bot and ~/Bot) if present
if [ -d "$BOT_DIR" ] || [ -d "$HOME/Bot" ]; then
  warn "Existing bot folder(s) found. Removing:"
  [ -d "$BOT_DIR" ] && printf "  - %s\n" "$BOT_DIR"
  [ -d "$HOME/Bot" ] && printf "  - %s\n" "$HOME/Bot"
  # Remove without prompt (user requested permanent delete earlier)
  sudo rm -rf "$BOT_DIR" "$HOME/Bot"
  ok "Old bot folders deleted."
fi

# 2) Create folder structure
log "Creating folder structure at $BOT_DIR"
mkdir -p "$VENV_DIR"
printf "%s\n" "$REPORT_NUMBER" > "$REPORT_FILE"
ok "Created:"
printf "  %s\n  %s\n  %s (contains: %s)\n" "$BOT_DIR" "$VENV_DIR" "$REPORT_FILE" "$REPORT_NUMBER"

# 3) Install system dependencies (only what's necessary)
log "Installing system dependencies (common, build & image libs). This may ask for sudo password."
# Combine arrays and install
run_apt_install "${SYS_PKGS_COMMON[@]}" "${SYS_PKGS_BUILD[@]}" "${SYS_PKGS_IMG[@]}"

# 4) Chromium + chromedriver installation
log "Preparing Chromium + Chromedriver installation (best-effort, multi-path)."

# Prefer distro packages when available
if apt-cache policy chromium | grep -q 'Candidate:' || apt-cache policy chromium-browser | grep -q 'Candidate:'; then
  # try installing chromium and driver via apt
  if apt-cache policy chromium | grep -q 'Candidate:'; then
    run_apt_install chromium
  elif apt-cache policy chromium-browser | grep -q 'Candidate:'; then
    run_apt_install chromium-browser
  fi
  # try driver packages - different distros use different names
  if apt-cache policy chromium-driver | grep -q 'Candidate:'; then
    run_apt_install chromium-driver
  elif apt-cache policy chromium-chromedriver | grep -q 'Candidate:'; then
    run_apt_install chromium-chromedriver
  fi
fi

# If chromedriver missing, attempt to fetch Chrome-for-Testing matching binary
if ! command_exists chromedriver; then
  log "chromedriver not found via apt — attempting Chrome-for-Testing download fallback."
  # Map uname -m to archive name
  ARCH="$(detect_arch)"
  case "$ARCH" in
    x86_64) CFTR_ARCH="linux64" ;;
    aarch64) CFTR_ARCH="linux64" ;;   # most aarch64 systems can use linux64 build
    armv7l) CFTR_ARCH="linux32" ;;    # armv7l -> linux32 fallback frequently works
    *) CFTR_ARCH="linux64" ;;
  esac

  LATEST="$(curl -sS https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE || true)"
  if [ -z "$LATEST" ]; then
    warn "Could not fetch latest Chrome-for-Testing version. Skipping chromedriver download."
  else
    URL="https://storage.googleapis.com/chrome-for-testing-public/${LATEST}/${CFTR_ARCH}/chromedriver-${CFTR_ARCH}.zip"
    log "Downloading chromedriver from: $URL"
    TMPZIP="$(mktemp --suffix=-chromedriver.zip)"
    if curl -sS -f -L "$URL" -o "$TMPZIP"; then
      TMPDIR="$(mktemp -d)"
      unzip -o "$TMPZIP" -d "$TMPDIR" >/dev/null
      # put binary into /usr/local/bin
      if [ -f "$TMPDIR"/chromedriver ] || [ -f "$TMPDIR"/chromedriver.exe ]; then
        sudo mv "$TMPDIR"/chromedriver* /usr/local/bin/chromedriver
        sudo chmod +x /usr/local/bin/chromedriver
        ok "chromedriver installed to /usr/local/bin/chromedriver"
      else
        warn "Downloaded archive didn't contain chromedriver binary."
      fi
      rm -rf "$TMPDIR" "$TMPZIP"
    else
      warn "Failed to download chromedriver from $URL"
      rm -f "$TMPZIP" || true
    fi
  fi
fi

# 5) Create & activate virtualenv inside $VENV_DIR
log "Creating Python virtual environment at $VENV_DIR"
python3 -m venv "$VENV_DIR"
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

log "Upgrading pip/setuptools/wheel in venv"
python -m pip install --upgrade pip setuptools wheel

# 6) Install Python packages (inside venv) in one pip command
log "Installing Python packages inside venv: ${PYTHON_PKGS[*]}"
python -m pip install "${PYTHON_PKGS[@]}"

# 7) Minimal verification
log "Verifying main Python packages (attempting imports)..."
PYIMPORTS=(gspread firebase_admin selenium PIL psutil pyautogui)
for m in "${PYIMPORTS[@]}"; do
  if python - <<PYCODE
try:
    import ${m}
    print("OK")
except Exception as e:
    print("FAIL", repr(e))
PYCODE
  then
    : # the python snippet prints OK/FAIL already
  fi
done

log "Checking chromium & chromedriver versions (if available)"
if command_exists chromium; then chromium --version || true; fi
if command_exists chromium-browser; then chromium-browser --version || true; fi
if command_exists chromedriver; then chromedriver --version || true; fi

ok "All done. Bot environment is ready."

cat <<EOF

SUMMARY:
  - Bot folder:     $BOT_DIR
  - Virtualenv:     $VENV_DIR
  - Report file:    $REPORT_FILE (contains: $REPORT_NUMBER)
  - Activate venv:  source "$VENV_DIR/bin/activate"
  - Run bot:        python "WhatsApp birthday wisher.py" (place it in $BOT_DIR)

Notes:
  - All Python packages were installed inside the virtual environment (venv).
  - Only system-level packages (python3, apt packages, chromium if needed) were installed globally.
  - If chromedriver detection failed, see the warnings above and try manual installation for your architecture.

EOF
