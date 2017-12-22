#!/bin/bash

if dpkg -l xxxx &> /dev/null; then
    echo "xxxx already installed"
    exit
fi

echo "Starting xxxx installation script..."

mkdir -p /etc/xxxx

### Installations
echo ">>>>> apt-get Update"
apt-get update

echo ">>>>> Installing coreutils"
apt-get install coreutils

echo ">>>>> Installing ping if needed."
apt-get -y install inetutils-ping

echo ">>>>> Installing wget if needed."
apt-get -y install wget

echo ">>>>> Installing apt-transport-https"
apt-get -y install apt-transport-https

### Wait for WAN

echo ">>>>> Waiting for network (WAN) access."
while ! ping -c 1 -W 1 google.com > /dev/null; do
	echo ">>>>> Network not up, interface might be down...."
	sleep 1
done

### GET Config Xml
echo ">>>>> Getting config xml."
wget -O /etc/xxxx/setupconfig.xml "https://xxxx.xxxx.com/SetupConfig.ashx?setupId=xxxx&setupKey= "

### GET Public Key
echo ">>>>> Getting Public.key for xxxx."
wget -O- "https://downloads.xxxx.com/downloads/xxxx/public.key" | apt-key add -
while [[ $? > 0 ]]; do
	echo ">>>>> Cant get Public Key, retry...."
	sleep 5
	wget -O- "https://downloads.xxxx.com/downloads/xxxx/public.key" | apt-key add -
done
echo ">>>>> The command for public.key ran succesfuly, continuing with script."
echo "deb https://downloads.xxxx.com/downloads/3cxpbx/ /" | tee /etc/apt/sources.list.d/xxxx.list
echo ">>>>> Updating repos."

apt-key update

### Apt-Get Update
while true
	do
	error=0
		while IFS= read -r line
		do
		if [[ $line == *"Err http://downloads.xxxx.com"* ]] 
		then
			error=1
			echo ">>>>> Error Code: $line"
			echo ">>>>> The command failed, retry to update repos."
		fi
		done <<< "$(apt-get update)"

	if [ $error -eq 0 ]
	then
		break
	fi
        echo ">>>>> Error Code: $?"
        echo ">>>>> The Error Code Detected, retry to update repos."
	sleep 5

done
echo ">>>>> The command for repos update ran succesfuly, continuing with script."



####Install xxxx
echo ">>>>> Installing xxxx."
apt-get -y install xxxx
while [[ $? > 0 ]]; do
        echo ">>>>> Cant install xxxx xxxx, retry...."
        sleep 5
	apt-get -y install xxxx
done
echo ">>>>> xxxx Installed"

sudo touch /etc/  xxxx/ installed

wget --post-file=/var/log/cloud-init-output.log "https://r="Content-Type: text/plain"
wget --post-file=/var/lib/xxxx/Data/Logs/ ConfigTool.log "https:/ header="Content-Type: text/plain"
 Less
