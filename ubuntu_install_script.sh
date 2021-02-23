#!/usr/bin/env bash
# This is intended to run only on a freshly installed system. This will meet my needs but probably not yours.

# Licence: Do What the Fuck You Want to Public License.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ "$EUID" -eq 0 ]
then
	echo "Please do not run this with sudo"
	exit 0
fi

# Prepare filesystem
./prepare_filesystem.sh

# Will be using that a lot
function apty(){
for pkg in "$@"
do
	sudo apt-get -my install $pkg
done
}

function getApp(){
	curl -sL https://api.github.com/repos/$1/releases/latest \
	| grep -E ".*\.AppImage\"" | grep "browser_download_url" | grep ":.*$2" \
	| cut -d : -f 2,3 \
	| tr -d \" \
	| wget -i -
}

function getGithubDeb(){
	curl -sL https://api.github.com/repos/$1/releases/latest \
	| grep -E ".*\.deb\"" | grep "browser_download_url" | grep ":.*$2" \
	| cut -d : -f 2,3 \
	| tr -d \" \
	| wget -i -
	sudo gdebi -n *.deb && rm *.deb
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
	sudo gdebi -n *.deb && rm *.deb
}

# Get on the Deutsch repos
apty gawk
sudo gawk -i inplace '{gsub(/us/,"de") ; print}' /etc/apt/sources.list

#Add kstars repo
sudo apt-add-repository ppa:mutlaqja/ppa

sudo apt-get update

# Essential Apps
apty qtqr gdebi-core mpv indi-full kstars-bleeding openscad cheese gnome-tweaks wget dos2unix curl git screen gparted gimp vlc octave htop python3-pip spyder3 ncdu default-jre default-jdk ant build-essential exfat-fuse exfat-utils solaar audacity simplescreenrecorder xclip
sudo pip3 install matplotlib numpy
sudo pip3 install --upgrade youtube_dl

# For Docker
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

git config --global credential.helper store

# OBS
sudo add-apt-repository ppa:obsproject/obs-studio -y
sudo apt update
apty obs-studio

# Spotify
## 1. Add the Spotify repository signing keys to be able to verify downloaded packages
sudo apt-key adv -y --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90

## 2. Add the Spotify repository
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

## 3. Update list of available packages
sudo apt-get update

## 4. Install Spotify
sudo apt-get install -y spotify-client

# Task manager that allows you to easily kill Apps by selecting them on the screen
apty xfce4-taskmanager

getGithubDeb bitwarden/desktop

# GeoGebra
getDeb geogebra6 "http://www.geogebra.org/download/deb.php?arch=amd64&ver=6"
getDeb steam-latest "https://steamcdn-a.akamaihd.net/client/installer/steam.deb"
getDeb slack-desktop-4.7.0-amd64 "https://downloads.slack-edge.com/linux_releases/slack-desktop-4.12.2-amd64.deb" # Shitty

# SmartGit
# getDeb smartgit-20_1_3 "https://www.syntevo.com/downloads/smartgit/smartgit-20_1_3.deb"

# Brave browser
sudo apt install apt-transport-https curl

curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -

echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update

sudo apt install -y brave-browser

# Virtualbox
#wget -q -O- http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc | sudo apt-key add -
#sudo add-apt-repository "deb https://download.virtualbox.org/virtualbox/debian disco contrib"
#sudo apt update
#apty virtualbox

# Sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
apty apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt-get update
sudo apt-get install sublime-text
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

# Set default animation speed to 0.6
sed -i 's/0.75/0.6/' ~/.local/share/gnome-shell/extensions/impatience@gfxmonk.net

# Nautilus
## Sort files by type
gsettings set org.gnome.nautilus.preferences default-sort-order "type"
## Single click to open documents
gsettings set org.gnome.nautilus.preferences click-policy 'single'

# Clock format
gsettings set org.gnome.desktop.interface clock-format '24h'

# Battery settings
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1200

gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false

#gsettings set org.gnome.desktop.screensaver lock-delay 600


# Sound settings
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# Workspaces settings
gsettings set org.gnome.mutter workspaces-only-on-primary false

# Keyboard layout
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'us+alt-intl')]"

# Touchpad 'natural scolling'
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

# Installing personal tools
cd ~/Projects

git clone https://github.com/raphaelcasimir/raphsh.git
git clone https://github.com/raphaelcasimir/elder-scrolling.git

cd raphsh

./raphsh.sh

cd ../elder-scrolling

read -p "Do you want to install elder-scrolling? (y/n): " choice

if [ "$choice" == "y" ]
then
	./install_mouse_scroll.sh
fi

# Cleaning up
mv $DIR ~/Projects
rm -r ~/Desktop/*

# Need to log in and out, may as well reboot
read -p "Do you want to reboot now? (y/n): " rboot

if [ $rboot == "y" ]
then
	sudo reboot
else
	echo "You will at least need to log in and out."
fi

echo -e "\nYour PC is ready to rock."

