#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO="Onix-AI/doppler-1password-plugin"
INSTALL_DIR="$HOME/.config/op/plugins/local"
BINARY_NAME="doppler"

echo -e "${GREEN}Installing Doppler 1Password Plugin${NC}"
echo

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
    darwin) OS="darwin" ;;
    linux) OS="linux" ;;
    mingw*|msys*|cygwin*) OS="windows" ;;
    *)
        echo -e "${RED}Unsupported operating system: $OS${NC}"
        exit 1
        ;;
esac

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *)
        echo -e "${RED}Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

echo "Detected platform: $OS-$ARCH"

# Get latest release
echo "Fetching latest release..."
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_RELEASE" ]; then
    echo -e "${RED}Failed to fetch latest release${NC}"
    exit 1
fi

echo "Latest version: $LATEST_RELEASE"

# Construct download URL
if [ "$OS" = "windows" ]; then
    BINARY_FILE="$BINARY_NAME-$OS-$ARCH.exe"
else
    BINARY_FILE="$BINARY_NAME-$OS-$ARCH"
fi

DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_RELEASE/$BINARY_FILE"

echo "Downloading from: $DOWNLOAD_URL"

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download binary
TEMP_FILE=$(mktemp)
if ! curl -fSL "$DOWNLOAD_URL" -o "$TEMP_FILE"; then
    echo -e "${RED}Failed to download binary${NC}"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Install binary
if [ "$OS" = "windows" ]; then
    mv "$TEMP_FILE" "$INSTALL_DIR/$BINARY_NAME.exe"
    chmod +x "$INSTALL_DIR/$BINARY_NAME.exe"
else
    mv "$TEMP_FILE" "$INSTALL_DIR/$BINARY_NAME"
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
fi

echo -e "${GREEN}✓ Binary installed to $INSTALL_DIR/$BINARY_NAME${NC}"

# Check if 1Password CLI is installed
if ! command -v op &> /dev/null; then
    echo -e "${YELLOW}Warning: 1Password CLI (op) not found${NC}"
    echo "Please install it from: https://developer.1password.com/docs/cli/get-started/"
    exit 1
fi

# Run plugin init
echo
echo "Initializing plugin..."
echo -e "${YELLOW}You will be prompted to configure how credentials are used.${NC}"
echo

if op plugin init doppler; then
    echo
    echo -e "${GREEN}✓ Installation complete!${NC}"
    echo
    echo "Next steps:"
    echo "1. Generate a Doppler Personal Token at:"
    echo "   https://dashboard.doppler.com/workplace/<workplace-id>/tokens/personal"
    echo
    echo "2. Run any doppler command, e.g.:"
    echo "   doppler me"
    echo
    echo "3. When prompted, paste your Personal Token (format: dp.pt.xxxxx...)"
    echo "   It will be saved securely in your 1Password vault."
else
    echo -e "${RED}Failed to initialize plugin${NC}"
    echo "You can manually run: op plugin init doppler"
    exit 1
fi
