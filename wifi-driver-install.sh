#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Check if the system is Kali Linux
if [[ "$(lsb_release -is)" != "Kali" || "$(lsb_release -rs)" != "2023.3" ]]; then
    echo "Warning: This script is only tested for Kali Linux version 2023.3."
    while true; do
        read -p "You are running $(lsb_release -ds). Do you want to continue? (y/n) " -n 1 -r
        echo    # move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            break
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            exit 1
        else
            echo "Invalid input. Please enter 'y' or 'n'."
        fi
    done
fi

# Check if apt-get and dpkg are installed
for cmd in apt-get dpkg; do
    command -v $cmd >/dev/null 2>&1 || { echo "$cmd is required but it's not installed.  Aborting." >&2; exit 1; }
done

# Define cleanup procedure
cleanup() {
    echo "Cleaning up..."
    rm -f broadcom-sta-dkms_6.30.223.271-23_all.deb
}

# Trap script termination
trap cleanup EXIT

# Update system and install necessary packages
echo "Updating system..."
apt-get update && apt-get upgrade -y || { echo "Failed to update system"; exit 1; }

echo "Installing necessary packages..."
apt-get install linux-headers-$(uname -r) -y || { echo "Failed to install necessary packages"; exit 1; }


# List of mirror sites to try
sites=("http.us.debian.org/debian" "ftp.debian.org/debian" "ftp.ca.debian.org/debian" "ftp.mx.debian.org/debian"
"ftp.br.debian.org/debian" "ftp.cl.debian.org/debian" "download.unesp.br/linux/debian" "sft.if.usp.br/debian" "debian.torredehanoi.org/debian"
"ftp.cn.debian.org/debian" "ftp.jp.debian.org/debian" "ftp.kr.debian.org/debian" "ftp.hk.debian.org/debian" "ftp.tw.debian.org/debian"
"debian.mirror.ac.za/debian"
"ftp.de.debian.org/debian" "ftp.at.debian.org/debian" "ftp.bg.debian.org/debian" "ftp.ch.debian.org/debian" "ftp.cz.debian.org/debian"
"ftp.dk.debian.org/debian" "ftp.ee.debian.org/debian" "ftp.es.debian.org/debian" "ftp.fi.debian.org/debian" "ftp.fr.debian.org/debian"
"ftp.hr.debian.org/debian" "ftp.hu.debian.org/debian" "ftp.ie.debian.org/debian" "ftp.is.debian.org/debian" "ftp.it.debian.org/debian"
"ftp.lt.debian.org/debian" "ftp.nl.debian.org/debian" "ftp.no.debian.org/debian" "ftp.pl.debian.org/debian" "ftp.ro.debian.org/debian"
"ftp.ru.debian.org/debian" "ftp.se.debian.org/debian" "ftp.si.debian.org/debian" "ftp.tr.debian.org/debian" "ftp.uk.debian.org/debian"
"ftp.au.debian.org/debian" "ftp.wa.au.debian.org/debian" "ftp.nz.debian.org/debian")

# Download and install Broadcom STA wireless driver
for site in "${sites[@]}"; do
    echo "Attempting to download Broadcom STA wireless driver from $site..."
    if wget -q --spider "$site/pool/non-free/b/broadcom-sta/broadcom-sta-dkms_6.30.223.271-23_all.deb"; then
        wget "$site/pool/non-free/b/broadcom-sta/broadcom-sta-dkms_6.30.223.271-23_all.deb"
        if [ $? -ne 0 ]; then
            echo "Failed to download Broadcom STA wireless driver from $site"
            continue
        fi
        echo "Download successful from $site. Installing Broadcom STA wireless driver..."
        dpkg -i broadcom-sta-dkms_6.30.223.271-23_all.deb
        if [ $? -ne 0 ]; then
            echo "Failed to install Broadcom STA wireless driver"
            continue
        fi
        break
    else
        echo "Failed to download from $site. Trying next site..."
    fi
done

# Check if the installation was successful
if dpkg -s broadcom-sta-dkms &> /dev/null; then
    echo "Broadcom STA wireless driver installed successfully."

    # Unload conflicting drivers
    echo "Unloading conflicting drivers..."
    modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
    if [ $? -ne 0 ]; then
        echo "Failed to unload conflicting drivers"
        exit 1
    fi

    # Load the wl module
    echo "Loading wl module..."
    modprobe wl
    if [ $? -ne 0 ]; then
        echo "Failed to load wl module"
        exit 1
    fi

    # Create or edit the /etc/rc.local file to allow it to load the wl module on boot
    echo "Creating or editing /etc/rc.local file to start WiFi on boot..."
    echo -e '#!/bin/bash\nmodprobe -r b44 b43 b43legacy ssb brcmsmac bcma\nmodprobe -rf wl\nmodprobe -vv wl' > /etc/rc.local
    if [ $? -ne 0 ]; then
        echo "Failed to create or edit /etc/rc.local file"
        exit 1
    fi

    # Make the /etc/rc.local file executable
    chmod +x /etc/rc.local
    if [ $? -ne 0 ]; then
        echo "Failed to make /etc/rc.local file executable"
        exit 1
    fi

else
    echo "Failed to install Broadcom STA wireless driver. Trying alternative method..."

    # Install firmware-b43-installer
    apt-get install firmware-b43-installer -y || { echo "Failed to install firmware-b43-installer"; exit 1; }
    if [ $? -ne 0 ]; then
        echo "Failed to install firmware-b43-installer"
        exit 1
    fi

    if dpkg -s firmware-b43-installer &> /dev/null; then
        echo "firmware-b43-installer installed successfully."
    else
        echo "Failed to install firmware-b43-installer"
        exit 1
    fi
fi

# Cleanup
echo "Cleaning up..."
rm -f broadcom-sta-dkms_6.30.223.271-23_all.deb || { echo "Failed to remove file"; exit 1; }

# Reboot the system
while true; do
    read -p "The script has finished. Do you want to reboot now? (y/n) " -n 1 -r
    echo    # move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Rebooting now..."
        reboot
        break
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Please reboot the system manually to apply the changes."
        break
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done
