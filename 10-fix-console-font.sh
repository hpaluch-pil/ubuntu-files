#!/bin/bash
# setup thick console font
set -euo pipefail
grep -q '^FONTFACE="VGA"' /etc/default/console-setup || {
	echo "Setting thick (VGA) console font..."
	sudo sed -i.orig -e 's/^\(FONTFACE=\).*/\1"VGA"/' /etc/default/console-setup
	# and apply new font to 1st local console
	[ ! -c /dev/tty1 ] || sudo bash -c "setupcon < /dev/tty1"
}
exit 0
