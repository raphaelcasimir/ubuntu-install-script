#!/usr/bin/env bash
mkdir temp
cd temp
wget https://github.com/timbertson/gnome-shell-impatience/archive/version-0.4.5.zip
unzip *
rm *.zip

# get extention uuid and prepare its path
ext_id=$(cat gnome-shell*/impatience/metadata.json | grep uuid | cut -d \" -f4)
ext_dir=~/.local/share/gnome-shell/extentions/$ext_id

# copying
mkdir -p $ext_dir
mv gnome-shell*/* $ext_dir

# cleaning up
cd ..
rm -r temp

# enable the extension
gnome-shell-extension-tool -e $ext_id

echo "Installed and enabled impatience gnome extension."
