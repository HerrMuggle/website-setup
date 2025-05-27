# Website Setup Script

This Bash script (`setup_website.sh`) automates the setup of a web server and deploys a professional placeholder website. It supports several major Linux distributions and handles their specific setup steps.

## Supported Distributions

- **Ubuntu**
- **Debian**
- **AlmaLinux**
- **openSUSE Leap**

## Features

- Installs Apache and PHP.
- Deploys a custom placeholder website (`Bean Haven Coffee`).
- Enables and configures systemd services.
- Adds necessary firewall rules.
- Handles distribution-specific settings like web root locations and Apache configuration.

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/HerrMuggle/website-setup.git
   cd website-setup

2. Make the script executable:
   ```bash
   chmod +X setup_website.sh

3. Run the script:
   ```bash
   ./setup_website.sh
