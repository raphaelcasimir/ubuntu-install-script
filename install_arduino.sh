#!/usr/bin/env bash

function getTxz(){
	curl -sL https://api.github.com/repos/$1/releases/latest \
	| grep -E ".*\.tar\.xz\"" | grep "browser_download_url" \
	| cut -d : -f 2,3 \
	| tr -d \" \
	| wget -i -
	tar xvf *.tar.xz -C ~/Apps
	rm *.tar.xz
}

# Build and install Arduino
getTxz "arduino/Arduino"

cd ~/Apps

cd Arduino*

cd build

ant dist

mkdir -p /home/$USER/.local/share/icons/hicolor/

cd linux/work/

sudo ./install.sh

sudo adduser $USER dialout

echo "Done installing Arduino"
# Done installing Arduino