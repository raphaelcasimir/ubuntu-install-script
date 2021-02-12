#!/usr/bin/env bash
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings panel-main-menu "['<Alt>F1']" # delete super + s
gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot-clip "['<Super>s']"

