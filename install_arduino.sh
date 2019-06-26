#!/usr/bin/env bash

wget -qO - https://www.arduino.cc/download_handler.php | grep linux64 \
| head -1 | cut -d \" -f 4 | cut -d = -f 2 \
| xargs -I {} printf "https://downloads.arduino.cc{}" | xargs wget

mkdir -p /home/$USER/.local/share/icons/hicolor/

tar xvf *.tar.xz -C ~/Apps
rm *.tar.xz

cd ~/Apps
cd arduino*

./install.sh

sudo adduser $USER dialout

echo "Done installing Arduino"
# Done installing Arduino