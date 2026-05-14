#!/bin/bash
# Debloat Ubuntu (very hard task!)
# WARNING! For experienced users only! It may bork your network access to target machine!
set -euo pipefail
errx () {
	echo "ERROR: $*" >&2
	exit 1
}

confirm_overwrite (){
	src="$1"
	dst="$2"
	[ -f "$src" ] || errx "Source file '$src' does not exist"
	[ -f "$dst" ] || errx "Destination file '$dst' does not exist"
	echo -n "Overwrite $dst [y/N]? "
	read ans
	case "$ans" in
		y|yes) : ;;
		*) return ;;
	esac
	# OK overwrite (cp is safer in case of abort)
	# no backup - issues: sudo cp -v "$dst" "$dst.orig"
	sudo cp -v "$src" "$dst"
	[ ! "$dst" = /etc/systemd/resolved.conf ] || sudo systemctl restart systemd-resolved
}

tmp=`mktemp`
trap "rm -f -- $tmp" EXIT

# Disable MOTD module that runs lot of bloat on every user login (it is not motd at all!)
for f in `grep -l '^session.* pam_motd\.so' /etc/pam.d/*`; do
	[ -f "$f" ] || errx "Internal error: $f is not file"
	sed '/^session.* pam_motd\.so/s/^/#/' $f > $tmp
	diff -u $f $tmp || confirm_overwrite $tmp $f
done

# Disable useless systemd-resolved
f=/etc/systemd/resolved.conf
sed 's/^\(#\?\)\(LLMNR\|DNSStubListener\)=.*/\2=no/' $f > $tmp
diff -u $f $tmp || confirm_overwrite $tmp $f

set -x
# remove bloated packages:
# FIXME: do not remove cloud'*' if cloud-init is used
sudo apt-get purge fwupd fwupd-signed needrestart apport'*' cloud'*' \
       	pollinate unattended-upgrades xfsprogs bcache-tools packagekit polkitd
# Delete these only when GUI is not active
[ -n "${DISPLAY:-}" ] || sudo apt-get purge snapd
sudo apt-get autoremove --purge
sudo systemctl mask motd-news.timer update-notifier-download.timer \
	systemd-tmpfiles-clean.timer xfs_scrub_all.timer update-notifier-motd.timer \
       	apt-daily-upgrade.timer apt-daily.timer dpkg-db-backup.timer \
	e2scrub_all.timer fstrim.timer man-db.timer
exit 0
