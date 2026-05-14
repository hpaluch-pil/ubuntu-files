# Ubuntu customization scripts

Here is set of my scripts that I use on fresh Ubuntu installation to customize
it to my needs.

> WARNING! Use on your own risk!

Note this project is cloned from my personal Debian script set from
https://github.com/hpaluch/debian-files

List of scripts:

* [02-use-eth0.sh](02-use-eth0.sh) - renames (un)predictable network interfaces
  to good old `ethX`. WARNING! So far tested with single interface only!  **This
  script should be run by experienced users only!** It may kill
  your access to target machine!
* [05-install-vim.sh](05-install-vim.sh) installs Vim sets it as default editor
  and set dark background
* [10-fix-console-font.sh](10-fix-console-font.sh) fixes local console font
  to be thick (default is extremely skinny)
* [15-install-cli-pkgs.sh](15-install-cli-pkgs.sh) installs my favorite CLI
  packages
