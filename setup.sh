#!/bin/bash

# Quick setup script for SQUIDBOT V5
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🐙 SQUIDBOT V5 Quick Setup${NC}"
echo "============================"

# Make scripts executable
chmod +x install.sh
chmod +x squidbot.py

# Run installation
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo -e "${YELLOW}Running Windows installation...${NC}"
    install.bat
else
    echo -e "${YELLOW}Running Linux/macOS installation...${NC}"
    sudo ./install.sh
fi

echo -e "${GREEN}✅ Setup complete!${NC}"
echo -e "Run ${YELLOW}python3 squidbot.py${NC} to start"