# ubuntu-install-script

_Personal install script for Ubuntu-based systems from my GitLab._

Tested working on Pop!OS 19.04. Should work or be a good start for anyone wanting to make an install script.

I did not separate the add-repository update and apt install steps because I want to be able to copy-paste the install of a single software easily into a terminal. However doing only a single apt update for all added repositories would shorten the install process a lot.

Be careful at the end I install some of my own tools you probably do not want them.

Do not forget to reboot your system at the end.
