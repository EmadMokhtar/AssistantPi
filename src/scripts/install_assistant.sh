#!/bin/bash
echo ""
echo "Starting Assistant SDK Installation..."
echo "######################################################################################################"
echo "-- You can start this step manually if it fails by typing   sudo bash /opt/AlexaPi/src/scripts/install_assistant.sh"
echo ""
# Prequisiteries
echo "## Installing dependencies..."
apt-get install python3 python3-dev python3-venv -y
apt-get install portaudio19-dev libffi-dev libssl-dev -y
apt-get install vlc-bin -y

# Setup Virtual Environment
echo "## Setting up Virtual Environment"
sudo python3 -m venv /opt/AlexaPi/env
if [ ! -d "/opt/AlexaPi/env" ]; then
	echo ""
	echo "-- Creating Python virtual environment for Assistant SDK failed. Please run this manually:"
	echo "sudo python3 -m venv /opt/AlexaPi/env"
	echo "-- Check if folder  /opt/AlexaPi/env  has been created"
	echo "-- and restart the installer with  sudo bash /opt/AlexaPi/src/scripts/install_assistant.sh"
	echo ""
	echo "Exiting..."
	exit
fi


# Will enter here if Directory exists

# Sync system time to prevent problems while installing pip
sudo systemctl stop ntp
sudo ntpd -gq
sudo systemctl start ntp
# Install pip
/opt/AlexaPi/env/bin/pip install pip setuptools --upgrade

# Install forked Assistant SDK
echo "## Installing forked Assistant SDK"
cd /opt/AlexaPi/src
sudo rm -rf assistant-sdk-python
sudo git clone https://github.com/xtools-at/assistant-sdk-python.git
cd /opt/AlexaPi/src/assistant-sdk-python
/opt/AlexaPi/env/bin/python -m pip install --upgrade -e ".[samples]"
/opt/AlexaPi/env/bin/pip install tenacity
/opt/AlexaPi/env/bin/python -m pip install -I urllib3==1.21.1

echo "## Copying default sound config from /opt/AlexaPi/src/assistant.asound.conf to /var/lib/AlexaPi and /home/pi"
echo "See here for more information: https://developers.google.com/assistant/sdk/prototype/getting-started-pi-python/configure-audio"
# Put default sound config in place
sudo cp /opt/AlexaPi/src/assistant.asound.conf /home/pi/.asoundrc
sudo cp /opt/AlexaPi/src/assistant.asound.conf /var/lib/AlexaPi/.asoundrc

# Set up AlexaPi Pulseaudio support
sudo mkdir -p /var/lib/AlexaPi/.config/pulse
sudo cp /etc/pulse/client.conf /var/lib/AlexaPi/.config/pulse/
sudo sed -i 's/autospawn = yes/autospawn = no/gi' /var/lib/AlexaPi/.config/pulse/client.conf
## Prevent choppy Pulseaudio output
## see https://dbader.org/blog/crackle-free-audio-on-the-raspberry-pi-with-mpd-and-pulseaudio
sudo sed -i 's/load-module module-udev-detect tsched=0/load-module module-udev-detect/gi' /etc/pulse/default.pa
sudo sed -i 's/load-module module-udev-detect/load-module module-udev-detect tsched=0/gi' /etc/pulse/default.pa
## Set up system-wide Pulseaudio
sudo adduser pulse audio
sudo adduser pi pulse-access
sudo adduser alexapi pulse-access
sudo chown -R alexapi:alexapi /var/lib/AlexaPi/
## Prevent Error caused by Paulseaudio looking in /var/run
sudo ln -s /home/pi/.config/pulse /var/run/pulse
## Enable new Pulseaudio service
sudo cp /opt/AlexaPi/src/pulseaudio.service /etc/systemd/system/pulseaudio.service
sudo systemctl enable pulseaudio.service

echo ""
echo "## Auhentication with Google API"
echo "You can start this step manually by typing   sudo bash /opt/AlexaPi/src/scripts/auth_assistant.sh"
read -r -p "Start Authentication with Google API now? [Y/n]: " start_auth
case $start_auth in
	[Nn] )
	;;
	* )
		sudo bash /opt/AlexaPi/src/scripts/auth_assistant.sh
	;;
esac
echo ""
echo "-- Installation successful, please reboot your Pi now:  sudo reboot now"
