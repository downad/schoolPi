# schoolPi
Make the Raspberry Pi usable in School an Home as a "take your computer with you"

# Idee
I want to make this small Raspberry Pi usable in school. Every student has its own Pi and does his work on it - at home and at school.
The school provides for the studens only screen, keyboard and Mouse (if necessary).

# Setting 
In this setting every student gets "his" own Raspberry Pi for use at school and home.
The school must have enougth screen, keyboard, power and LAN.
Is the raspberry pi in the schoolnet, the /home/STUDENT will be saved on the server (tar.gz, crypted), the rpi gets his commands for update, softwareinstallation and more.
 

# HowTo (short version)
Use the raspbian-Image (https://www.raspberrypi.org/downloads/raspbian/) on the Pi.
Mount the image and write an file named ssh in /boot so you can use the remote ssh.
Write the .iso to an SDCard, umount the SDCard and put it into an Raspberry Pi.
Start the Pi - login an make your specification in raspi-config
on every RPi:
*expand filesystem - YES 
*Internation Options
**Chance Local  
***de_DE ISO-8859-1                                                   │ 
***de_DE.UTF-8 UTF-8                                              ▒   │ 
***de_DE@euro ISO-8859-1			5
**Chance Timezone Europe Berlin
**Chance Wi-Fi Country ->DE
**Chance Keyboard Layout generic 105-key (intl) PC (geht nicht?)
***german
****German - German (eliminate dead keys).
****ALT-GR default
Land Germany, Time GMT+1, Tastatur DE UFT8,
*Advanced Options	
**memory split default 64MByte 
*finish
 
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo rpi-update

---
clone the github and copy all files into an local webserver 
make the file prepare_RaspberryPiMasterServer.sh executable
chmod +x prepare_RaspberryPiMasterServer.sh
./prepare_RaspberryPiMasterServer.sh
this script makes a gpg - key 
copy the public key as RaspberryPiMasterServerKey.gpg in the folder prepare of the webserver.
 


scp the preparescript [prepair_RaspberryPi_user.sh] so the Raspberry Pi
make it executable
sudo chmod +x prepare_RaspberryPi_user.sh
and start it.
sudo ./prepair_RaspberryPi_user.sh

This script ask you some questions
IP of the webserver - called RaspberryPiMasterServer [RMS]
does the webserver uses a .htacess with login and password?



# technics at school
The school infrastructur:
* WLAN 
* LAN
* a small Server
	* for the backup the student /home
  * for the management of the Raspberry Pi	
  
## Version
* 0.1 start of the project
* 0.2 
