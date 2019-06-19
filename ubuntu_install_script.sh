#!/usr/bin/env bash
# This is intended to run only on a freshly installed system. This will meet my needs but probably not yours.

# Licence: Do What the Fuck You Want to Public License.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ "$EUID" -eq 0 ]
then
	echo "Please do not this run as root"
	exit 0
fi

# Prepare filesystem
./prepare_filesystem.sh

# Will be using that a lot
function apty(){
	sudo apt-get install -y "$@"
}

function getApp(){
	curl -sL https://api.github.com/repos/$1/releases/latest \
	| grep -E ".*\.AppImage\"" | grep "browser_download_url" | grep ":.*$2" \
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

# Essential Apps
apty wget curl git screen gparted gimp vlc octave htop python3-pip spyder3 ncdu zenmap default-jre default-jdk ant build-essential exfat-fuse exfat-utils solaar audacity simplescreenrecorder
pip3 install matplotlib
pip3 install numpy

git config credential.helper store

# OBS
sudo add-apt-repository ppa:obsproject/obs-studio
sudo apt update
sudo apt install obs-studio

# Spotify
## 1. Add the Spotify repository signing keys to be able to verify downloaded packages
sudo apt-key adv -y --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90

## 2. Add the Spotify repository
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list

## 3. Update list of available packages
sudo apt-get update

## 4. Install Spotify
sudo apt-get install -y spotify-client

# Task manager that allows you to easily kill Apps by selecting them on the screen
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
echo "Done installing sublime-Apps"
# End Sublime

# KiKad
sudo add-apt-repository --yes ppa:js-reynaud/kicad-5.1
sudo apt update
apty --install-suggests kicad
# End KiCad

getApp "prusa3d/Slic3r"
getApp "Ultimaker/Cura"
getApp "balena-io/etcher" "x64"

# Get latest kdenlive
latest_kdenlive_version=$(wget -qO - https://files.kde.org/kdenlive/release/ | grep x86_64.appimage | tail -1 | cut -d \" -f 4)
wget $(printf https://files.kde.org/kdenlive/release/$latest_kdenlive_version)

# Correct flatulous extension naming schemes
for i in *.appimage; do mv $i $(basename $i appimage)AppImage; done

mv *.AppImage ~/Apps

chmod +x ~/Apps/*.AppImage
echo "Done installing AppImages"

# Launching subscripts
cd $DIR

./install_arduino.sh
./add_bookmarks.sh
./set_launcher_favorites.sh
./gnome-theming.sh
./set_keyboard_shortcuts.sh

# Install Gnome extensions
## Install impatience
./gnome_extensions.sh --install --extension-id 277 --version latest

## Install gsconnect (to connect you phone to your android through WiFi)
./gnome_extensions.sh --install --extension-id 1319

# Set default animation speed to 0.5
sed -i 's/0.75/0.5/' ~/.local/share/gnome-shell/extensions/impatience@gfxmonk.net


# Installing personal tools
cd ~/Projects

git clone https://github.com/raphaelcasimir/raphsh.git
git clone https://github.com/raphaelcasimir/elder-scrolling.git

cd raphsh

./raphsh.sh

cd ../elder-scrolling

./install_mouse_scroll.sh

# Cleaning up
mv $DIR ~/Projects
rm -r ~/Desktop/*

# Need to log in and out, may as well reboot
read -p "Do you want to reboot now?" rboot

if [ $rboot -eq "y" ]
then
	sudo reboot
else
	echo "You will at least need to log in and out."
fi

echo -e "\nYour PC is ready to rock."
