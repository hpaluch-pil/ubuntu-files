#!/bin/bash
# install ma favorite packages (vim is installed with 05-install-vim.sh)
set -xeuo pipefail
sudo apt-get install tmux mc jq curl git-lfs man-db manpages-dev sysstat \
	rsync
# mask problematic stuff
sudo systemctl mask dpkg-db-backup.timer man-db.timer apt-daily-upgrade.timer \
	apt-daily.timer e2scrub_all.timer fstrim.timer
exit 0
