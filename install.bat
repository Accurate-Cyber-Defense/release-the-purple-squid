@echo off
title SQUIDBOT V5 Installer for Windows
color 0A

echo ================================================
echo     🐙 SQUIDBOT V5 Windows Installer
echo     Ultimate Cybersecurity Platform
echo ================================================
echo.

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run as Administrator!
    pause
    exit /b 1
)

:: Set variables
set INSTALL_DIR=%PROGRAMFILES%\SquidBot
set DATA_DIR=%APPDATA%\SquidBot
set LOG_DIR=%TEMP%\SquidBotLogs

echo [INFO] Installing SQUIDBOT V5...

:: Create directories
echo [INFO] Creating directories...
mkdir "%INSTALL_DIR%" 2>nul
mkdir "%DATA_DIR%" 2>nul
mkdir "%DATA_DIR%\phishing" 2>nul
mkdir "%DATA_DIR%\credentials" 2>nul
mkdir "%DATA_DIR%\ssh_keys" 2>nul
mkdir "%DATA_DIR%\traffic_logs" 2>nul
mkdir "%LOG_DIR%" 2>nul

:: Check Python installation
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Python not found! Please install Python 3.11+
    echo Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)

:: Install Python packages
echo [INFO] Installing Python packages...
python -m pip install --upgrade pip
python -m pip install requests aiohttp click colorama pyyaml
python -m pip install scapy paramiko python-nmap dnspython
python -m pip install discord.py telethon slack-sdk
python -m pip install flask flask-socketio flask-cors
python -m pip install numpy pandas matplotlib seaborn
python -m pip install reportlab beautifulsoup4 lxml selenium
python -m pip install qrcode pyshorteners shodan
python -m pip install psutil pycryptodome

:: Copy files
echo [INFO] Copying files...
copy squidbot.py "%INSTALL_DIR%\" >nul

:: Create configuration file
echo [INFO] Creating configuration...
(
echo {
echo     "version": "5.0.0",
echo     "install_path": "%INSTALL_DIR:\=\\%",
echo     "data_path": "%DATA_DIR:\=\\%",
echo     "log_path": "%LOG_DIR:\=\\%",
echo     "discord_token": "",
echo     "telegram_api_id": "",
echo     "telegram_api_hash": "",
echo     "telegram_bot_token": "",
echo     "slack_token": "",
echo     "web_port": 8080
echo }
) > "%DATA_DIR%\config.json"

:: Create startup script
echo [INFO] Creating startup script...
(
echo @echo off
echo cd /d "%INSTALL_DIR%"
echo python squidbot.py
echo pause
) > "%INSTALL_DIR%\start_squidbot.bat"

:: Create shortcut
echo [INFO] Creating desktop shortcut...
powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%USERPROFILE%\Desktop\SquidBot.lnk'); $SC.TargetPath = '%INSTALL_DIR%\start_squidbot.bat'; $SC.Save()"

:: Add to PATH
echo [INFO] Adding to PATH...
setx PATH "%PATH%;%INSTALL_DIR%" /M >nul

:: Create firewall rules
echo [INFO] Configuring firewall...
netsh advfirewall firewall add rule name="SquidBot HTTP" dir=in action=allow protocol=TCP localport=8080 >nul
netsh advfirewall firewall add rule name="SquidBot WebSocket" dir=in action=allow protocol=TCP localport=5000 >nul

echo.
echo ================================================
echo        ✅ INSTALLATION COMPLETE!
echo ================================================
echo.
echo Installation Directory: %INSTALL_DIR%
echo Data Directory: %DATA_DIR%
echo.
echo To start SQUIDBOT:
echo   1. Run: %INSTALL_DIR%\start_squidbot.bat
echo   2. Or use Desktop shortcut
echo.
echo Web Interface: http://localhost:8080
echo.
echo Configure bot tokens in: %DATA_DIR%\config.json
echo.
pause