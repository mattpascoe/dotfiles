# Dotfiles

A way to keep track of my common dotfile settings.
These days I'm primarily on Mac but this is intended to work on linux as well.

# Install
These steps assume a factory default state or initial setup of these scripts

* Open terminal
* git clone https://github.com/mattpascoe/dotfiles.git
* ~/dotfiles/setup.sh

You should be able to run the setup.sh script multiple times without issue at any time.

## MISC MAC info
Started using the .macos file or similar from https://github.com/mathiasbynens/dotfiles

Simply run the .macos file to enable its settings

The following is a list of 'crap I do' to a new mac, maybe one day this is a set of 'default' plist settings.

* enable internet accounts
	* iCloud - contacts, cal, reminder, safari, keychain, fmm
	* google - contacts, cal, notes
	* exchange? mail, contacts, cal, reminder, notes
* general setting
	* allow handoff.. decide per instance
* copy .ssh dir from previous box (to get keys, config is in this repo)
  * rsync -avh "10.1.1.206:.ssh" ~/
* copy .gnupg dir from previous box
  * rsync -avh "10.1.1.206:.gnupg" ~/
* rsync /data from a previous box (remove the n option as needed)
  * sudo rsync -avzn mdp@10.1.1.206:/data/ /data
  * do it several times to ensure all is copied, I noticed some files didnt move????
* rsync Virtualbox systems (not really using vagrant much these days)
  * rsync -avh "10.1.1.206:.vagrant.d" ~/
  * rsync -avh "10.1.1.206:VirtualBox\ VMS" ~/
  * in virtualbox do a machine->add of each vm.
  * more info here: https://stackoverflow.com/questions/20679054/how-to-export-a-vagrant-virtual-machine-to-transfer-it
* set capslock to escape.. stupid thing is hard to add using .macos/defaults
* If in dual monitor mode, set big one as default by dragging menubar over

## iTerm2

I have a file called `com.googlecode.iterm2.plist` in this repo. This is the iterm preferences file.
Just set iterm to load preferences from folder. Usually I set `/Users/$USER/dotfiles` as my location

Periodically save the preferences (or check the box) to this file and check it into Git.


## MAC Apps to install

* iterm2 - https://www.iterm2.com/downloads.html
* xcode - app store.. just type 'git' from CLI
* istatmenus - https://bjango.com/mac/istatmenus/ (replaces itsycal)
* maccy - maccy.app good clipboard
* postman - https://www.getpostman.com/downloads
* GPGtools - https://gpgtools.org
* BetterSnapTool - https://folivora.ai
* 1password X - browser exension.. just start with this https://chrome.google.com/webstore/detail/1password-x-%E2%80%93-password-ma/aeblfdkhhhdcdjpifhhbdiojplfjncoa
* lulu - firewall system


Brewit:
brew install iterm2 maccy
brew install virtualbox vagrant
brew install postman
brew install istat-menus
brew install 1password
brew install lulu

OLD APPS
* itsycal - https://www.mowglii.com/itsycal/
* GitUp - http://gitup.co/

# Unraid support
The setup script will try and detect if it is being run on an unraid box.
It expects that you have a share called 'local' that will be used to store
files used by the local root user.

This local share is likely going to be hidden and not actually on the network.

It is also assumed that you have the NerdTools plugin installed and that the
fzf, zsh packages have been installed.

Unraid will run from /boot/config so if there are any changes to vimrc, zshrc or
shell-common, you will need to run `setup.sh` again.

# NIX
I'm exploring it. TBD how it fits in here.

One objective is to make configuration files as portable as possible. This means to
systems of any type. Things that do not run NIX as well as multiple OS types with potentially
limited scope.  This is why for now I'm sticking with the setup.sh script.

Maybe NIX can simply layer into this process.

My current position is that NIX is too painful a syntax and the ecosystem seems angsty.
I do like it as a package manager instead of brew. For now I'll stick to JUST packages.
I may look at https://www.chezmoi.io/ as an alternative to this dotfiles repo and setup.sh.  I do like I can just use my script anywhere tho.

# Ideas to find a home for
Interesting zsh 'global' alias option

     alias -g H='| head'  # git log H will show only the first 10 lines of the log

Also I have a "tools" method for shell functions. look at shell-common and the __tools* functions.
