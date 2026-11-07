# Install-Store-LTSC

A fully automated, one-click batch script to install the Microsoft Store and essential dependencies (including WinGet) on Windows 10 and Windows 11. Specifically designed for LTSC (Long-Term Servicing Channel) and IoT editions where the Store is absent by default.

## 🚀 Features

* **Auto-Elevation:** Automatically requests Administrator privileges if not run as Admin.
* **Service Configuration:** Checks and enables required background services (Windows Update, AppXSvc, ClipSVC, BITS).
* **Official Dependencies:** Fetches the latest official VCLibs and WinGet (DesktopAppInstaller) packages directly from Microsoft servers.
* **Native Store Deployment:** Uses the native `wsreset -i` command to pull the latest legitimate Microsoft Store package directly from Microsoft Update.
* **Live Monitoring:** Features a live PowerShell progress monitor that detects when the Store is successfully installed and automatically launches it.
* **Clean Up:** Removes all temporary downloaded files once the installation is complete.

## 📋 Prerequisites

* Windows 10 or Windows 11 (Ideally LTSC/IoT editions).
* An active internet connection.

## 🛠️ Usage

1. Download the script file from this repository: `install Microsoft Store LTSC-IoT LTSC.bat`
2. Double-click the file to run it. 
   *(Alternatively, right-click and select "Run as administrator").*
3. A command prompt window will open and display the progress.
4. Wait for the script to download dependencies, trigger the Store installation, and monitor the progress.
5. Once successfully installed, the Microsoft Store will launch automatically!

## ⚠️ Disclaimer

This script fetches official packages directly from Microsoft endpoints and uses native Windows commands. However, modifying core Windows features on LTSC editions is done at your own risk. This project is not affiliated with Microsoft.

## 📝 License

This project is open-source and available under the MIT License.
