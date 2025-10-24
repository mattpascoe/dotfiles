This directory will contain shell scripts to perform setup relative to the definition in the profile
The goal is to compartmentalize each part of the setup process.

The first line of the script should be a bash shebang.
The second line should be a short comment used as a description of the tool or profile.

The file name would be something like brave-browser.sh so if prompting you later
the prompt would read "Install brave-browser -- # The Brave web browser (N/y)?".

When you say yes, it will source the script.  You would then install packages
or do more complex install and setup as needed.

The $ID variable should contain the OS type as determined by setup.sh from
/etc/os-release.

A role would generally define multiple profile scripts together to execute
a complete setup.

Any files that are named with a leading dot or underscore will not be
listed automatically selection lists but can be referenced directly.
