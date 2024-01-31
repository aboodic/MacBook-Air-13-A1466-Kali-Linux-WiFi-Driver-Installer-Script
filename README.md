# MacBook-Air-13-A1466-Kali-Linux-WiFi-Driver-Installer-Script
Welcome to the repository dedicated to simplifying the process of installing WiFi drivers on the Apple MacBook Air 13" model A1466 with Kali Linux. This script is tailored for users who are running Kali Linux on their MacBook and are facing challenges in setting up the WiFi drivers. This was based on this thread on Stackoverflow and various other pieces of internet research. https://askubuntu.com/questions/55868/installing-broadcom-wireless-drivers?page=2&tab=scoredesc#tab-top

## Description
The script first checks if it is being run as root and if the system is Kali Linux version 2023.3. It then updates the system and installs necessary packages. The script attempts to download the Broadcom STA wireless driver from a list of mirror sites. If the download is successful, it installs the driver and unloads any conflicting drivers. It then loads the wl module and modifies the /etc/rc.local file to load the wl module on boot. If the installation of the Broadcom STA wireless driver fails, it attempts to install the firmware-b43-installer package as an alternative.

## Broadcom STA Wireless Driver Installation Script
This script automates the process of installing the Broadcom STA wireless driver on a MacBook Air running Kali Linux version 2023.3. It was created based on the research and testing done by morph13nd from x.com.


## Credits
This script is based on the information and research done by morph13nd. Morph13nd spent approximately 6 hours testing different methods and configurations to get the Broadcom STA wireless driver working on a MacBook Air running Kali Linux version 2023.3. This script would not have been possible without their hard work and dedication.

## Usage
To use this script, download it and run it as root:

The script will prompt you to reboot after it finishes. You can choose to reboot immediately or manually reboot later.

## Disclaimer
This script is only tested on a MacBook Air running Kali Linux version 2023.3. Use it at your own risk. Always backup your data before making system changes.
