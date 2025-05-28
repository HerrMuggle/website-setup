#!/bin/bash

# setup_website.sh
# Unified Web Server Installation & Website Deployment Script

echo "---------------------------------------------"
echo "  Web Server Installation & Deployment Script"
echo "---------------------------------------------"

# OS Detection
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$ID
    Detected_OS=$PRETTY_NAME
else
    echo "❌ Unable to detect operating system. Exiting."
    exit 1
fi

case "$OS_NAME" in
    ubuntu|debian)
        PACKAGE_MANAGER="apt"
        APACHE_SERVICE="apache2"
        APACHE_PKG="apache2"
        PHP_PKG="php"
        WEB_ROOT="/var/www/html"
        ;;
    almalinux|centos|rhel)
        PACKAGE_MANAGER="dnf"
        APACHE_SERVICE="httpd"
        APACHE_PKG="httpd"
        PHP_PKG="php"
        WEB_ROOT="/var/www/html"
        ;;
    sles|suse|opensuse-leap)
        PACKAGE_MANAGER="zypper"
        APACHE_SERVICE="apache2"
        APACHE_PKG="apache2"
        PHP_PKG="php7"
        WEB_ROOT="/srv/www/htdocs"
        ;;
    *)
        echo "❌ Unsupported OS: $OS_NAME"
        echo "This script supports Ubuntu, Debian, AlmaLinux, and openSUSE Leap."
        exit 1
        ;;
esac

echo "✅ Detected OS: $Detected_OS"
echo "Apache Service: $APACHE_SERVICE"
echo "Web Root: $WEB_ROOT"

# Function: Check if a package is installed
is_installed() {
    case "$PACKAGE_MANAGER" in
        apt)
            dpkg -l | grep -q "$1"
            ;;
        dnf|yum)
            rpm -q "$1" &>/dev/null
            ;;
        zypper)
            rpm -q "$1" &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Ensure unzip is installed
if ! command -v unzip &>/dev/null; then
    echo "📦 Installing unzip..."
    case "$PACKAGE_MANAGER" in
        apt)
            apt update && apt install -y unzip
            ;;
        dnf)
            dnf install -y unzip
            ;;
        zypper)
            zypper install -y unzip
            ;;
    esac
    if ! command -v unzip &>/dev/null; then
        echo "❌ unzip installation failed. Exiting."
        exit 1
    fi
else
    echo "✅ unzip is already installed."
fi

# Install Apache if not already installed
if ! is_installed "$APACHE_PKG"; then
    echo "📦 Installing Apache..."
    case "$PACKAGE_MANAGER" in
        apt)
            apt update && apt install -y "$APACHE_PKG"
            ;;
        dnf)
            dnf install -y "$APACHE_PKG"
            ;;
        zypper)
            zypper install -y "$APACHE_PKG"
            ;;
    esac
else
    echo "✅ Apache is already installed."
fi

# Install PHP if not already installed
if ! is_installed "$PHP_PKG"; then
    echo "📦 Installing PHP..."
    case "$PACKAGE_MANAGER" in
        apt)
            apt install -y "$PHP_PKG"
            ;;
        dnf)
            dnf install -y "$PHP_PKG"
            ;;
        zypper)
            zypper install -y "$PHP_PKG"
            ;;
    esac
else
    echo "✅ PHP is already installed."
fi

# Prompt for Website Template
read -p "Enter the URL of your website template ZIP file (or press Enter to use default): " TEMPLATE_URL
DEFAULT_TEMPLATE_URL="https://bootstrapmade.com/content/templatefiles/Visible/Visible.zip"
TEMPLATE_URL=${TEMPLATE_URL:-$DEFAULT_TEMPLATE_URL}

# Create temporary working directory
TEMP_DIR="/tmp/webfiles"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1

# Download template
echo "🌐 Downloading website template..."
wget -q "$TEMPLATE_URL" -O template.zip
if [ $? -ne 0 ]; then
    echo "❌ Failed to download template. Exiting."
    exit 1
fi

# Unzip template
echo "📂 Extracting template..."
unzip -q template.zip
if [ $? -ne 0 ]; then
    echo "❌ Failed to unzip template. Exiting."
    exit 1
fi

# Determine extracted directory
EXTRACTED_DIR=$(find . -mindepth 1 -maxdepth 1 -type d | head -n 1)
if [[ -z "$EXTRACTED_DIR" || ! -d "$EXTRACTED_DIR" ]]; then
    echo "❌ Extracted directory not found. Exiting."
    exit 1
fi

# Remove any default index files
rm -f "$WEB_ROOT/index.html" "$WEB_ROOT/index.nginx-debian.html"

# Deploy new site content
echo "🚚 Deploying files to $WEB_ROOT..."
cp -r "$EXTRACTED_DIR"/* "$WEB_ROOT/"

# Additional Apache configuration for some distros
if [[ "$OS_NAME" == "sles" || "$OS_NAME" == "opensuse-leap" ]]; then
    if ! grep -q "^ServerName localhost" /etc/apache2/httpd.conf; then
        echo "ServerName localhost" >> /etc/apache2/httpd.conf
    fi
fi

# Enable and start Apache
echo "🚀 Starting Apache service..."
systemctl enable "$APACHE_SERVICE"
systemctl start "$APACHE_SERVICE"

# Verify Apache is running
if ! systemctl is-active --quiet "$APACHE_SERVICE"; then
    echo "❌ Apache failed to start. Check logs with: journalctl -xe"
    exit 1
fi

# Firewall adjustments for RHEL-based and SUSE
if [[ "$OS_NAME" == "almalinux" || "$OS_NAME" == "centos" || "$OS_NAME" == "rhel" || "$OS_NAME" == "opensuse-leap" || "$OS_NAME" == "sles" ]]; then
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
fi

# Cleanup
rm -rf "$TEMP_DIR"

# Success
echo "✅ Website deployed successfully!"
echo "📁 Deployed to: $WEB_ROOT"
echo "🌐 Access it via http://localhost or your server IP"
