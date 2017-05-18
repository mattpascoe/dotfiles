dotfiles
--------

A way to keep track of my common dotfile settings.. patterned of of bpd808s stuff

TODO
----

  * create a shell script that will init the symlinks to the dot files.
  * probably lots more..

iTerm2
------

I have a file called `com.googlecode.iterm2.plist` in the root. This is the iterm preferences file.
Just set iterm to load preferences from folder. Usually I set `/data/code/dotfiles` as my location

Periodically save the preferences (or check the box) to this file and check it into Git.


MISC MAC
--------
start using the .macos file or similar from https://github.com/mathiasbynens/dotfiles

The following is a list of 'crap I do' to a new mac, maybe one day this is a set of 'default' plist settings.

* turn off siri
* touch bar, remove siri, add lock and play icons
* enable internet accounts
	* iCloud - contacts, cal, reminder, safari, keychain, fmm
	* google - contacts, cal, notes
	* exchange? mail, contacts, cal, reminder, notes
* accessibilty
	* zoom - use scroll gesture ^ control
	* mouse -> trackpad - enable dragging without lock
* general
	* allow handoff.. decide per instance
* screensaver
	* show with clock. use text saver
* Dock
	* on the smaller side.. 1/4 ish
	* magnify 1/3
	* right side of screen
	* auto hide


Apps to install

* virtualbox
* vagrant
* xcode
* itsycal
* clipy
* postman
* atom
* GPGtools
* iterm2
* keepassx

MISC

On El Capitan or newer, if you want your DNS resolver to work when you type something like 'ssh a212.boi' then run the following commands at a terminal:
  sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist AlwaysAppendSearchDomains -bool YES
  sudo launchctl unload /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
  sudo launchctl load /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist

