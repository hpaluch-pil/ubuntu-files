#!/bin/bash
# install vim and set it as default editor
set -xeuo pipefail
[ -f /var/lib/dpkg/info/vim.list ] || sudo apt-get install -y vim
editor_target=$(readlink /etc/alternatives/editor)
echo "INFO: Current editor target '$editor_target'"
[ "$editor_target" = "/usr/bin/vim.basic" ] || {
	echo "Setting default editor to vim.basic"
	sudo update-alternatives --set editor /usr/bin/vim.basic
}

[ -f /etc/vim/vimrc.local ] || {
	echo "Creating /etc/vim/vimrc.local with dark background"
	cat <<'EOF' | sudo tee /etc/vim/vimrc.local
" /etc/vim/vimrc.local
" set dark background
set background=dark
EOF
}

exit 0
