# Website Setup Script

This Bash script (`setup_website.sh`) automates the setup of a web server and deploys a professional placeholder website. It supports several major Linux distributions and handles their specific setup steps.

## Supported Distributions

- **Ubuntu**
- **Debian**
- **AlmaLinux**
- **openSUSE Leap**

## Features

- Checks if Apache, PHP, and unzip are already installed before attempting to install them.
- Cleanly logs installed vs. newly installed packages.
- Maintains compatibility with Ubuntu, Debian, AlmaLinux, openSUSE Leap.
- Keeps error checks for Apache start, file copy, and unzip integrity.
- Removes unnecessary echo verbosity but keeps clear feedback for each action.

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/HerrMuggle/website-setup.git
   cd website-setup

2. Make the script executable:
   ```bash
   chmod +X setup_website.sh

3. Ensure you have sudo privileges:
   ```bash
   sudo ./setup_website.sh
