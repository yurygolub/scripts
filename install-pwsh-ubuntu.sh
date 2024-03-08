###################################
# Prerequisites

# Update the list of packages
sudo apt update

# Install pre-requisite packages.
sudo apt install wget apt-transport-https software-properties-common

# Get the version of Ubuntu
source /etc/os-release

# Download the Microsoft repository keys
wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb

# Register the Microsoft repository keys
sudo dpkg -i packages-microsoft-prod.deb

# Delete the Microsoft repository keys file
rm packages-microsoft-prod.deb

# Update the list of packages after we added packages.microsoft.com
sudo apt update

###################################
# Install PowerShell
sudo apt install powershell

# Start PowerShell
pwsh
