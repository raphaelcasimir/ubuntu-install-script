#!/usr/bin/env bash
# This is intended to run only on a freshly installed system. This will meet my needs but probably not yours.

# Licence: Do What the Fuck You Want to Public License.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ "$EUID" -eq 0 ]
then
	echo "Please do not this run as root"
	exit 0
fi

# Will be using that a lot
function apty(){
	sudo apt install -y "$@"
	read
}

function getApp(){
	curl -sL https://api.github.com/repos/$1/releases/latest \
	| grep -E ".*\.AppImage\"" | grep "browser_download_url" | grep $2: \
	| cut -d : -f 2,3 \
	| tr -d \" \
	| wget -i -
}

function getTxz(){
	curl -sL https://api.github.com/repos/$1/releases/latest \
	| grep -E ".*\.tar\.xz\"" | grep "browser_download_url" \
	| cut -d : -f 2,3 \
	| tr -d \" \
	| wget -i -
	tar xvf *.tar.xz -C ~/Apps
}

function getDeb(){
	# $1 is app name for debug purposes, $2 is deb URL
	wget -q --show-progress -O $1.deb $2
	apty ./$1.deb && rm ./$1.deb
}

# For Docker
sudo apt-get update
apty \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Doesn't work on Mint, see my Mint Docker install script
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   bionic \
   stable"

sudo apt-get update
sudo apt-get upgrade -y

sudo groupadd docker
sudo usermod -aG docker $USER

apty docker-ce docker-ce-cli containerd.io

echo "Done installing Docker"
# End Docker

# Essential apps
apty wget curl git screen gimp vlc octave htop python3-pip spyder3 ncdu zenmap default-jre default-jdk ant build-essential exfat-fuse exfat-utils
pip3 install matplotlib
pip3 install numpy

git config credential.helper store

# Task manager that allows you to easily kill apps by selecting them on the screen
apty xfce4-taskmanager

# GeoGebra
getDeb geogebra6 "http://www.geogebra.org/download/deb.php?arch=amd64&ver=6"

# Steam
getDeb steam-latest "https://steamcdn-a.akamaihd.net/client/installer/steam.deb"

# Brave browser
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
source /etc/os-release
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/brave-browser-release-${UBUNTU_CODENAME}.list
sudo apt update
apty brave-keyring brave-browser

# Virtualbox
wget -q -O- http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc | sudo apt-key add -
sudo add-apt-repository "deb https://download.virtualbox.org/virtualbox/debian disco contrib"
sudo apt update
apty virtualbox

# Sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
apty apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt-get update
sudo apt-get install sublime-merge sublime-text
echo "Done installing sublime-apps"
# End Sublime

# KiKad
sudo add-apt-repository --yes ppa:js-reynaud/kicad-5.1
sudo apt update
apty --install-suggests kicad
# End KiCad

mkdir ~/Projects ~/Apps

getApp "prusa3d/Slic3r"
getApp "Ultimaker/Cura"
getApp "balena-io/etcher" "x64"

mv *.AppImage ~/Apps

chmod +x ~/Apps/*.AppImage
echo "Done installing AppImages"

cd $DIR

./install_arduino.sh
./add_bookmarks.sh

# Installing personal tools
cd ~/Projects

git clone https://github.com/raphaelcasimir/raphsh.git
git clone https://github.com/raphaelcasimir/elder-scrolling.git

cd raphsh

./raphsh.sh

cd ../elder-scrolling

./install_mouse_scroll.sh

# Need to log in and out, may as well reboot
read -p "Do you want to reboot now?" rboot

if [ $rboot -eq "y" ]
then
	sudo reboot
else
	echo "You will at least need to log in and out."
fi

echo -e "\nYour PC is ready to rock."
