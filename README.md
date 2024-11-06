# Yabridge Installation Script for Linux

This repository contains a script that automates the installation of Yabridge on Linux systems. Yabridge allows you to use Windows VST plugins with your favorite Linux audio production tools. This script will ensure that Wine Staging, Git, and Yabridge are installed and properly configured on your system, including adding default plugin directories to Yabridge.

## Features
- Automatically checks if Wine Staging and Git are installed, and installs them if they are missing.
- Downloads and installs the latest version of Yabridge from GitHub releases.
- Adds Yabridge to your system's PATH.
- Configures default plugin directories to work with Yabridgectl.

## Prerequisites
- A Linux distribution based on Debian, Ubuntu, Arch, Fedora, or openSUSE.
- `curl` and `wget` must be installed.

## Supported Distributions
The script currently supports:
- Debian/Ubuntu and derivatives (e.g., Linux Mint, PopOS)
- Arch Linux and Manjaro
- Fedora
- openSUSE

If your distribution is not listed here, manual installation of Yabridge might be required.

## Installation

1. Clone this repository:
    ```sh
    git clone <repository-url>
    cd <repository-directory>
    ```

2. Make the script executable:
    ```sh
    chmod +x yabridgeinstaller.sh
    ```

3. Run the script:
    ```sh
    ./yabridgeinstaller.sh
    ```

The script will guide you through the installation process, prompting you to install required dependencies and configure Yabridge.

## Script Overview

1. **Check if Wine Staging is Installed**
   - The script checks if Wine Staging is installed on your system. If Wine is installed but not the Staging version, you will have the option to replace it.

2. **Install Dependencies**
   - Required dependencies like Git are installed if not already present.

3. **Download and Install Yabridge**
   - The script fetches the latest version of Yabridge from its GitHub releases page.
   - Extracts the downloaded files and installs them in the appropriate directory.

4. **Add Yabridge to System PATH**
   - Adds Yabridge to your `.bashrc` file to make `yabridgectl` easily accessible.

5. **Configure Yabridge Plugin Directories**
   - Default plugin directories are created if they do not exist.
   - Plugin directories are added to Yabridgectl.
   - Finally, the script runs `yabridgectl sync` to ensure plugins are properly configured.

## Usage
After installation, you can manage your Windows VST plugins by running:
```sh
yabridgectl sync
```

This command will synchronize your plugin directories so that your DAW can use the Windows plugins installed in Wine.

## Troubleshooting
- If you encounter any issues during installation, ensure you have `curl` and `wget` installed.
- For missing dependencies, refer to the error messages and install them manually if needed.
- Ensure that you have an active internet connection, as the script relies on downloading from GitHub.

## License
This script is open source and available under the MIT License. Feel free to modify it as needed to suit your system and requirements.

## Credits
This script was created by [Martín Oviedo] at NDA Web and inspired by the need to make VST plugins work seamlessly on Linux audio production environments.

