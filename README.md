# Dotfiles

A way to keep track of my common dotfile settings.
These days I'm primarily on Mac but this is intended to work on linux as well.

# Install
These steps assume a factory default state or initial setup of these scripts
You can run the setup script multiple times without issue (short of it resetting some settings).
It will attempt to upgrade and set the settings as defined in this repo.

If you are not me and you are crazy, you can run one of the following to get started.
```
curl -fsSL https://raw.githubusercontent.com/mattpascoe/dotfiles/master/setup.sh | bash
curl -fsSL demo.opennetadmin.com/dotsetup.sh | bash
wget https://raw.githubusercontent.com/mattpascoe/dotfiles/master/setup.sh -O- | bash
wget demo.opennetadmin.com/dotsetup.sh -O- | bash
```

or

```
git clone https://github.com/mattpascoe/dotfiles.git ~/dotfiles
~/dotfiles/setup.sh
```

On a basic Arch install you first need to run:
```
pacman -Syu wget sudo
```

When `setup.sh` is run, it will determine the Platform and Role of the system through
various means. It will then apply configuration in the following order:
* The `Platform` definition. Basically the basic OS specific configuration
* The `COMMON.sh` profile
* Then anything defined by the selected `Role`.

# Platform
A Platform is simply just the high level OS environment type.  Linux or Mac or Windows for example.
This is determined by uname -s and other attributes within /etc/os-release for example.

Not much is done here usually. It just makes sure certain low level things are done like pacakge management setup.

# Roles and Profiles
In a similar way to the puppet roles and profiles pattern I have structured things similarly.

A role is like a profile. It allows you to with a single definition, combine multiple
other profile scripts together to complete a setup.
If you do not specify a role, the DEFAULT role will be used. This default role
will just run through all the profiles asking if you want to apply them.

Typically a role is going to be a specific set of profiles to accoplish a specific
setup. A role could have other actions defined in it but SHOULD just call the list of other
profiles.

Once a role is selected on the box, that role will be stored in `~/.dotfile_role`
and used for subsequent runs. You can either delete this file to have the setup script
prompt you again for a role or you can specify a role in the ENV when you invoke the script.
`ROLE=role_name ./setup.sh` for example.

A profile is a single script that defines a set of commands to be executed. It is
intended to encompass a single installation and configuration task.

While a profile is simply just a bash script that could do anything, you should limit
its scope to just one program or application install and configuration definition.

## MISC MAC info
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
* set capslock to escape.. stupid thing is hard to add using .macos/defaults

## MAC Apps to install

* istatmenus - https://bjango.com/mac/istatmenus/ (replaces itsycal)
* maccy - maccy.app good clipboard
* postman - https://www.getpostman.com/downloads
* GPGtools - https://gpgtools.org
* BetterSnapTool - https://folivora.ai
* lulu - firewall system

# Unraid support
The setup script will try and detect if it is being run on an unraid box.
It expects that you have a share called 'local' that will be used to store
files used by the local root user.

This local share is likely going to be hidden and not actually on the network.

It is also assumed that you have the NerdTools plugin installed and that the
fzf, zsh packages have been installed.

Unraid will run from /boot/config so if there are any changes to vimrc, zshrc or
shell-common, you will need to run `setup.sh` again.

# Hyprland
It looks cool. Tiling is nice. So far its too new to be common. I'm going to
let it go for awhile and check later.  Right now Gnome is common, simple and predictable.
For my needs I'm not trying to get fancy anyway. I just use Kanata to jump between apps
on a single window in mostly full screen. Then if I really want to fall back to a window
Gnome will just be there and I dont have to fight things. But Gnome, stop with your angst
as well!

# NIX
I'm exploring it. TBD how it fits in here.

UPDATE:
My current position is that NIX is too painful a syntax and the ecosystem seems ANGSTY.
I do like it as a package manager instead of brew. For now I'll stick to JUST packages.

I've decided to go back to brew and ditch NIX. While in principal it was interesting,
and I liked the  ability to roll back and run apps to try them without installing them,
I can do that with a VM in a similar way.  For my needs that will work fine.

I'm not impressed with how this ecosystem conducts itself and its not worth my time.



# Ideas to find a home for
Interesting zsh 'global' alias option

     alias -g H='| head'  # git log H will show only the first 10 lines of the log

Also I have a "tools" method for shell functions. look at shell-common and the __tools* functions.

I may look at https://www.chezmoi.io/ as an alternative to this dotfiles repo and setup.sh.  I do like I can just use my script anywhere tho.
