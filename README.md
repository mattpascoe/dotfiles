dotfiles
--------

A way to keep track of my common dotfile settings.. patterned of of bpd808s stuff
Mostly useful on macs but should work on linux boxes as well

iTerm2
------

I have a file called `com.googlecode.iterm2.plist` in this repo. This is the iterm preferences file.
Just set iterm to load preferences from folder. Usually I set `/Users/$USERS/dotfiles` as my location

Periodically save the preferences (or check the box) to this file and check it into Git.


MISC MAC
--------
start using the .macos file or similar from https://github.com/mathiasbynens/dotfiles

The following is a list of 'crap I do' to a new mac, maybe one day this is a set of 'default' plist settings.

* enable internet accounts
	* iCloud - contacts, cal, reminder, safari, keychain, fmm
	* google - contacts, cal, notes
	* exchange? mail, contacts, cal, reminder, notes
* general
	* allow handoff.. decide per instance
* copy .ssh dir from previous box
* copy .gnupg dir from previous box
* rsync /data from a previous box (remove the n option as needed)
  * sudo rsync -avzn mdp@10.100.13.10:/data/ /data
  * do it several times to ensure all is copied, I noticed some files didnt move????
* rsync Virtualbox systems
  * rsync -avh "10.100.13.10:.vagrant.d" ~/
  * rsync -avh "10.100.13.10:VirtualBox\ VMS" ~/
  * in virtualbox do a machine->add of each vm.
  * more info here: https://stackoverflow.com/questions/20679054/how-to-export-a-vagrant-virtual-machine-to-transfer-it
* set capslock to escape.. stupid thing is hard to add using .macos/defaults
* in dual monitor mode, set big one as default by dragging menubar over


Apps to install
---------------

* virtualbox - https://www.virtualbox.org/wiki/Downloads
* vagrant - https://www.vagrantup.com/downloads.html
* xcode - app store
* itsycal - https://www.mowglii.com/itsycal/
* clipy - https://github.com/Clipy/Clipy/releases/download/1.1.3/Clipy_1.1.3.dmg
* postman - https://www.getpostman.com
* atom - https://atom.io
* GPGtools - https://gpgtools.org
* iterm2 - https://www.iterm2.com/downloads.html
* keepassx
* GitUp

MISC

