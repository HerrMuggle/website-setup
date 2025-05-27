#!/bin/bash

# Supported distributions
SUPPORTED="Ubuntu Debian AlmaLinux openSUSE Leap"

unsupported_os() {
    echo "⚠ Unsupported OS: $1"
    echo "This script supports: Ubuntu, Debian, AlmaLinux, openSUSE Leap."
    echo "Exiting gracefully."
    exit 0
}

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$(echo "$NAME" | awk '{print $1}')
else
    unsupported_os "Unknown"
fi

echo "Detected OS: $DISTRO"

# Install Apache, PHP and handle configuration based on distro
case "$DISTRO" in
    Ubuntu)
        sudo apt update
        sudo apt install -y apache2 php
        sudo systemctl enable apache2
        sudo systemctl start apache2
        if ! grep -q "DirectoryIndex index.html" /etc/apache2/sites-available/000-default.conf; then
            sudo sed -i '/<VirtualHost \*:80>/a \    DirectoryIndex index.html' /etc/apache2/sites-available/000-default.conf
            sudo systemctl reload apache2
        fi
        HTML_DIR="/var/www/html"
        ;;

    Debian)
        sudo apt update
        sudo apt install -y apache2 php
        sudo systemctl enable apache2
        sudo systemctl start apache2
        HTML_DIR="/var/www/html"
        ;;

    AlmaLinux)
        sudo dnf install -y httpd php
        sudo mkdir -p /var/www/html
        sudo systemctl enable httpd
        sudo systemctl start httpd
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --reload
        HTML_DIR="/var/www/html"
        ;;

    openSUSE)
        sudo zypper refresh
        sudo zypper install -y apache2 php7
        sudo mkdir -p /srv/www/htdocs
        sudo cp -r /var/www/html/* /srv/www/htdocs/ 2>/dev/null || true
        if ! grep -q "^ServerName localhost" /etc/apache2/httpd.conf; then
            echo "ServerName localhost" | sudo tee -a /etc/apache2/httpd.conf > /dev/null
        fi
        sudo systemctl enable apache2
        sudo systemctl start apache2
        sudo systemctl restart apache2
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --permanent --add-service=https
        sudo firewall-cmd --reload
        sudo systemctl reload apache2
        HTML_DIR="/srv/www/htdocs"
        ;;

    *)
        unsupported_os "$DISTRO"
        ;;
esac

# Deploy placeholder website
sudo bash -c "cat > $HTML_DIR/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bean Haven Coffee</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f6f1e7; color: #4e342e; text-align: center; padding: 50px; }
        h1 { font-size: 3em; }
        p { font-size: 1.2em; }
        footer { margin-top: 30px; font-size: 0.9em; color: #888; }
    </style>
</head>
<body>
    <h1>Welcome to Bean Haven</h1>
    <p>Your daily dose of fresh brews and cozy vibes.</p>
    <p>We're under construction, but the coffee's already brewing!</p>
    <footer>© 2025 Bean Haven Coffee</footer>
</body>
</html>
EOF

echo "✅ Web server installed and Bean Haven site deployed at http://localhost"
