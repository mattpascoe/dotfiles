This directory will contain shell scripts to perform extra installs.
The goal is to compartmentalize each extra thing.

The first line of the script should be a bash shebang.
The second line should be a short comment used as a description of the tool.

The file name would be something like brave-browser.sh so it will prompt if
you want to "Install brave-browser -- # The Brave web browser (N/y)?".

When you say yes, it will source the script.  You would then install packages
or do more complex install and setup as needed.

The $ID variable should contain the OS type as determined by setup.sh from
/etc/os-release. You would need to test $MACHINE if it were a Mac.
