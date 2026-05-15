# 📡 WiFi-Pass Reveal

A lightweight, transparent, and efficient PowerShell script designed to help you recover forgotten WiFi passwords saved on your Windows system. 

Unlike "crackers," **WiFi-Pass Reveal** focuses on transparency; it simply fetches and formats the credentials already stored in your system's WLAN profiles.

## 🚀 How to Use
1. Download the files or clone the repository.
2. Run `Run.bat` as Administrator (recommended) to see all passwords.
3. Alternatively, right-click `WifiPass.ps1` and select **"Run with PowerShell"**.
4. (Optional) If you get a policy error, run this in your terminal:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File WifiPass.ps1
   ```

## 🛠️ Tech Stack

* **Language:** PowerShell
* **Command Base:** Windows Netsh (Network Shell)
* **Launcher:** Windows Batch (.bat)

## ⚠️ Disclaimer

This tool is for educational and personal recovery purposes only. Only use it to access information on devices you own or have explicit permission to audit.
