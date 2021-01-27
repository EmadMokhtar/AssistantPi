#!/bin/bash
echo ""
echo "Starting Authorization with Google Assistant API..."
echo "######################################################################################################"
echo "-- Go visit and follow"
echo "https://developers.google.com/assistant/sdk/prototype/getting-started-pi-python/config-dev-project-and-account"
echo "-- get your OAuth Credentials-JSON file ready --"
echo "-- and rename/move it to "
echo "/home/pi/Downloads/client_secret.json --"
echo "-- or supply the full path to your file. --"
echo ""

read -r -p "Is your client secret file in the default place (/home/pi/Downloads/client_secret.json) ? [Y/n] " use_default_path

echo "-- You can start this step manually if it fails by typing   sudo bash /opt/AlexaPi/src/scripts/auth_assistant.sh"
echo ""

case $use_default_path in
    [Nn] )
		read -r -p "Please enter the full path to your client_secret.json (including the filename): " path

		sudo /usr/bin/python -m googlesamples.assistant.auth_helpers --client-secrets "$path" --credentials /etc/opt/AlexaPi/assistant_credentials.json
    ;;
    * )
		sudo /usr/bin/python -m googlesamples.assistant.auth_helpers --client-secrets /home/pi/Downloads/client_secret.json --credentials /etc/opt/AlexaPi/assistant_credentials.json
	;;
esac
