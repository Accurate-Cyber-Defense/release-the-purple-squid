#!/bin/bash

# SQUIDBOT V5 - Universal Installation Script
# Supports: Ubuntu/Debian, CentOS/RHEL, Fedora, Arch Linux, macOS

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Version
VERSION="5.0.0"

# Configuration
INSTALL_DIR="/opt/squidbot"
DATA_DIR="/var/lib/squidbot"
LOG_DIR="/var/log/squidbot"
CONFIG_DIR="/etc/squidbot"
PYTHON_VERSION="3.11"

# Banner
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🐙 SQUIDBOT V5 INSTALLER                              ║
║                   Ultimate Cybersecurity Command & Control Server            ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            OS=$ID
            VERSION_ID=$VERSION_ID
        elif [[ -f /etc/debian_version ]]; then
            OS="debian"
        elif [[ -f /etc/redhat-release ]]; then
            OS="rhel"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
    echo -e "${GREEN}✓ Detected OS: $OS${NC}"
}

# Check root privileges
check_root() {
    if [[ $EUID -ne 0 ]] && [[ "$OS" != "macos" ]]; then
        echo -e "${RED}❌ This script must be run as root!${NC}"
        echo -e "${YELLOW}Try: sudo $0${NC}"
        exit 1
    fi
}

# Install dependencies based on OS
install_dependencies() {
    echo -e "${GREEN}📦 Installing system dependencies...${NC}"
    
    case $OS in
        ubuntu|debian)
            apt-get update
            apt-get install -y \
                python3 python3-pip python3-dev python3-venv \
                git curl wget netcat-openbsd nmap \
                build-essential libssl-dev libffi-dev \
                tcpdump dsniff macchanger hping3 \
                arp-scan ettercap dnschef \
                whois bind9-dnsutils \
                sqlite3 redis-server postgresql \
                libpcap-dev libnetfilter-queue-dev \
                tor proxychains4 \
                chromium-browser firefox \
                openssh-server \
                jq tree htop iotop
            ;;
        centos|rhel|fedora)
            if [[ "$OS" == "fedora" ]]; then
                dnf install -y \
                    python3 python3-pip python3-devel \
                    git curl wget nmap netcat \
                    gcc openssl-devel libffi-devel \
                    tcpdump dsniff macchanger hping3 \
                    arp-scan ettercap dnschef \
                    whois bind-utils \
                    sqlite redis postgresql \
                    libpcap-devel \
                    tor proxychains-ng \
                    chromium firefox \
                    openssh-server \
                    jq tree htop iotop
            else
                yum install -y epel-release
                yum install -y \
                    python3 python3-pip python3-devel \
                    git curl wget nmap-ncat nmap \
                    gcc openssl-devel libffi-devel \
                    tcpdump dsniff macchanger hping3 \
                    arp-scan ettercap dnschef \
                    whois bind-utils \
                    sqlite redis postgresql \
                    libpcap-devel \
                    tor proxychains-ng \
                    chromium firefox \
                    openssh-server \
                    jq tree htop iotop
            fi
            ;;
        arch)
            pacman -Sy --noconfirm \
                python python-pip python-virtualenv \
                git curl wget nmap gnu-netcat \
                gcc openssl libffi \
                tcpdump dsniff macchanger hping \
                arp-scan ettercap dnschef \
                whois bind-tools \
                sqlite redis postgresql \
                libpcap \
                tor proxychains-ng \
                chromium firefox \
                openssh \
                jq tree htop iotop
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                echo -e "${YELLOW}Installing Homebrew...${NC}"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install \
                python@3.11 git curl wget nmap netcat \
                openssl tcpdump dsniff macchanger \
                arp-scan ettercap dnschef \
                whois bind sqlite redis postgresql \
                libpcap tor proxychains-ng \
                chromium firefox \
                jq tree htop iotop
            ;;
        *)
            echo -e "${RED}❌ Unsupported OS: $OS${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✓ System dependencies installed${NC}"
}

# Install Python packages
install_python_packages() {
    echo -e "${GREEN}🐍 Installing Python packages...${NC}"
    
    # Upgrade pip
    python3 -m pip install --upgrade pip
    
    # Install requirements
    if [[ -f "requirements.txt" ]]; then
        python3 -m pip install -r requirements.txt
    else
        python3 -m pip install \
            requests aiohttp click colorama pyyaml python-dotenv \
            scapy paramiko python-nmap dnspython netifaces \
            discord.py telethon slack-sdk python-telegram-bot \
            sqlalchemy psycopg2-binary redis aioredis \
            flask flask-socketio flask-cors flask-login eventlet \
            numpy pandas matplotlib seaborn scipy scikit-learn \
            reportlab jinja2 weasyprint markdown \
            beautifulsoup4 lxml selenium qrcode pyshorteners \
            shodan python-whois \
            tqdm rich questionary inquirer \
            psutil humanize pygments tabulate termcolor \
            prometheus-client loguru elasticsearch \
            pytest pytest-asyncio pytest-cov \
            black flake8 mypy pre-commit \
            passlib bcrypt argon2-cffi \
            pytesseract easyocr Pillow opencv-python \
            geopy geoip2 maxminddb \
            twilio plivo \
            tensorflow keras xgboost lightgbm
    fi
    
    echo -e "${GREEN}✓ Python packages installed${NC}"
}

# Create directories
create_directories() {
    echo -e "${GREEN}📁 Creating directories...${NC}"
    
    mkdir -p $INSTALL_DIR
    mkdir -p $DATA_DIR
    mkdir -p $LOG_DIR
    mkdir -p $CONFIG_DIR
    mkdir -p $DATA_DIR/{phishing,credentials,ssh_keys,traffic_logs}
    mkdir -p $REPORT_DIR/{scans,graphics}
    
    echo -e "${GREEN}✓ Directories created${NC}"
}

# Copy files
copy_files() {
    echo -e "${GREEN}📋 Copying files...${NC}"
    
    # Copy main script
    cp squidbot.py $INSTALL_DIR/
    chmod +x $INSTALL_DIR/squidbot.py
    
    # Copy configuration
    if [[ ! -f "$CONFIG_DIR/config.json" ]]; then
        cat > $CONFIG_DIR/config.json << EOF
{
    "version": "$VERSION",
    "install_path": "$INSTALL_DIR",
    "data_path": "$DATA_DIR",
    "log_path": "$LOG_DIR",
    "discord_token": "",
    "telegram_api_id": "",
    "telegram_api_hash": "",
    "telegram_bot_token": "",
    "slack_token": "",
    "slack_channel": "general",
    "web_port": 8080,
    "ssl_enabled": false,
    "ssl_cert": "",
    "ssl_key": ""
}
EOF
    fi
    
    # Create systemd service
    cat > /etc/systemd/system/squidbot.service << EOF
[Unit]
Description=SQUIDBOT V5 Cybersecurity Platform
After=network.target redis.service postgresql.service
Wants=redis.service postgresql.service

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
Environment="PYTHONUNBUFFERED=1"
ExecStart=/usr/bin/python3 $INSTALL_DIR/squidbot.py
Restart=always
RestartSec=10
StandardOutput=append:$LOG_DIR/squidbot.log
StandardError=append:$LOG_DIR/squidbot.error.log

[Install]
WantedBy=multi-user.target
EOF
    
    # Create logrotate config
    cat > /etc/logrotate.d/squidbot << EOF
$LOG_DIR/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
    sharedscripts
    postrotate
        systemctl restart squidbot > /dev/null 2>&1 || true
    endscript
}
EOF
    
    echo -e "${GREEN}✓ Files copied${NC}"
}

# Setup firewall
setup_firewall() {
    echo -e "${GREEN}🔥 Configuring firewall...${NC}"
    
    if command -v ufw &> /dev/null; then
        ufw allow 8080/tcp
        ufw allow 5000/tcp
        ufw allow 8000/tcp
        ufw allow 8081/tcp
        ufw allow 8082/tcp
        ufw allow 8083/tcp
        ufw allow 22/tcp
        echo -e "${GREEN}✓ UFW rules added${NC}"
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-port=8080/tcp
        firewall-cmd --permanent --add-port=5000/tcp
        firewall-cmd --permanent --add-port=8000/tcp
        firewall-cmd --permanent --add-port=8081/tcp
        firewall-cmd --permanent --add-port=8082/tcp
        firewall-cmd --permanent --add-port=8083/tcp
        firewall-cmd --permanent --add-port=22/tcp
        firewall-cmd --reload
        echo -e "${GREEN}✓ FirewallD rules added${NC}"
    else
        echo -e "${YELLOW}⚠️ No firewall detected, skipping${NC}"
    fi
}

# Enable IP forwarding
enable_ip_forwarding() {
    echo -e "${GREEN}🌐 Enabling IP forwarding...${NC}"
    
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
    sysctl -p
    
    echo -e "${GREEN}✓ IP forwarding enabled${NC}"
}

# Start services
start_services() {
    echo -e "${GREEN}🚀 Starting services...${NC}"
    
    # Start and enable systemd service
    systemctl daemon-reload
    systemctl enable squidbot.service
    systemctl start squidbot.service
    
    # Start Redis if available
    if command -v redis-server &> /dev/null; then
        systemctl enable redis 2>/dev/null || systemctl enable redis-server 2>/dev/null || true
        systemctl start redis 2>/dev/null || systemctl start redis-server 2>/dev/null || true
    fi
    
    # Start PostgreSQL if available
    if command -v postgresql &> /dev/null; then
        systemctl enable postgresql 2>/dev/null || true
        systemctl start postgresql 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Services started${NC}"
}

# Create bash completion
create_bash_completion() {
    echo -e "${GREEN}📝 Creating bash completion...${NC}"
    
    cat > /etc/bash_completion.d/squidbot << 'EOF'
_squidbot_completion() {
    local cur prev words cword
    _init_completion || return
    
    local commands="help status scan nmap ping traceroute dig whois \
                   spoof_ip spoof_mac arp_spoof dns_spoof stop_spoof \
                   icmp_flood syn_flood udp_flood http_flood stop_flood \
                   generate_phishing phishing_start phishing_stop \
                   ssh_connect ssh_exec curl wget nc history threats \
                   exit clear"
    
    COMPREPLY=($(compgen -W "$commands" -- "$cur"))
}
complete -F _squidbot_completion squidbot
EOF
    
    echo -e "${GREEN}✓ Bash completion created${NC}"
}

# Print completion message
print_completion() {
    echo -e "\n${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ SQUIDBOT V5 INSTALLATION COMPLETE!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${CYAN}📍 Installation Details:${NC}"
    echo -e "  • Install Directory: ${YELLOW}$INSTALL_DIR${NC}"
    echo -e "  • Data Directory: ${YELLOW}$DATA_DIR${NC}"
    echo -e "  • Config Directory: ${YELLOW}$CONFIG_DIR${NC}"
    echo -e "  • Log Directory: ${YELLOW}$LOG_DIR${NC}\n"
    
    echo -e "${CYAN}🚀 Getting Started:${NC}"
    echo -e "  • Start SQUIDBOT: ${YELLOW}systemctl start squidbot${NC}"
    echo -e "  • Stop SQUIDBOT: ${YELLOW}systemctl stop squidbot${NC}"
    echo -e "  • Status: ${YELLOW}systemctl status squidbot${NC}"
    echo -e "  • View logs: ${YELLOW}tail -f $LOG_DIR/squidbot.log${NC}\n"
    
    echo -e "${CYAN}🎯 Quick Commands:${NC}"
    echo -e "  • Run interactively: ${YELLOW}python3 $INSTALL_DIR/squidbot.py${NC}"
    echo -e "  • Web interface: ${YELLOW}http://localhost:8080${NC}"
    echo -e "  • Help menu: ${YELLOW}help${NC} in interactive mode\n"
    
    echo -e "${CYAN}📚 Documentation:${NC}"
    echo -e "  • GitHub: ${YELLOW}https://github.com/squidbot/squidbot${NC}"
    echo -e "  • Wiki: ${YELLOW}https://wiki.squidbot.local${NC}\n"
    
    echo -e "${YELLOW}⚠️  Important:${NC}"
    echo -e "  • Configure bot tokens in ${YELLOW}$CONFIG_DIR/config.json${NC}"
    echo -e "  • Run with ${YELLOW}sudo${NC} for full network capabilities"
    echo -e "  • Use ${YELLOW}--help${NC} for command documentation\n"
    
    echo -e "${GREEN}🐙 Thank you for installing SQUIDBOT V5!${NC}\n"
}

# Main installation
main() {
    detect_os
    check_root
    install_dependencies
    install_python_packages
    create_directories
    copy_files
    setup_firewall
    enable_ip_forwarding
    start_services
    create_bash_completion
    print_completion
}

# Run main function
main "$@"