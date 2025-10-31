# 🤖 bot-venv – Universal Raspberry Pi Setup Script

This repository contains a fully automated, future-proof setup script for creating a clean Python virtual environment (`venv`) on any Raspberry Pi running Raspberry Pi OS (Lite or Desktop).

---

## 🧩 What This Script Does

When you run the single command below, it will automatically:

1. Remove any existing `bot` or `Bot` folder in your Pi home directory.
2. Recreate a new folder structure:
   ```
   ~/bot
   ├── venv/
   └── venv/report number
   ```
3. Install all required system packages.
4. Create and configure a Python 3 virtual environment.
5. Install essential Python dependencies inside the venv.
6. Create a plain text file named `report number` inside `venv` containing your number:
   ```
   9940585709
   ```
7. Display activation instructions.

---

## ⚙️ Installation (One-Line Command)

Just run this command on your Raspberry Pi terminal:

```bash
curl -sSL https://raw.githubusercontent.com/Thaniyanki/bot-venv/main/bot%20venv.sh | bash
```

---

## 🐍 Activate the Virtual Environment

After installation, activate your bot environment:

```bash
source ~/bot/venv/bin/activate
```

You’ll see `(venv)` appear before your username — meaning the environment is active.

---

## 🧰 Preinstalled Python Packages

The following key libraries are automatically installed **inside the virtual environment**:

- `firebase_admin`
- `gspread`
- `selenium`
- `google-auth`
- `google-auth-oauthlib`
- `google-cloud-storage`
- `google-cloud-firestore`
- `psutil`
- `pyautogui`
- `python3-xlib`
- `requests`
- `Pillow`

---

## 🌐 Chromium Support

The script attempts to install Chromium and Chromedriver automatically.
If not found, you can manually install them using:

```bash
sudo apt-get install chromium chromium-driver -y
```

---

## 🧾 Example Output

```
[✅ SETUP COMPLETE]
Folders:
  /home/executor/bot
  /home/executor/bot/venv
  /home/executor/bot/venv/report number (contains: 9940585709)
Python installed in: /home/executor/bot/venv/bin/python
Python version: Python 3.13.5
------------------------------------------------------------
[INFO] To activate: source /home/executor/bot/venv/bin/activate
```

---

## 🧠 Notes

- Compatible with both **32-bit** and **64-bit** Raspberry Pi OS.
- Works even after future OS upgrades.
- Safe re-run — old folders will be automatically cleaned before setup.

---

## 🪪 Author

**Thaniyanki**  
📍 Raspberry Pi Automation Project  
GitHub: [Thaniyanki](https://github.com/Thaniyanki)
