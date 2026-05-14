#!/bin/bash
# rename ethernet back to eth0...
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
	sudo cp -v "$dst" "$dst.orig"
	sudo cp -v "$src" "$dst"
	if [ "$dst" = /etc/default/grub ]; then
		set -x
		sudo update-grub
		echo "WARNING: you must restart system so network interface will be renamed"
		set +x
	fi
	if [ "$dst" = /etc/netplan/00-installer-config.yaml ]; then
		set -x
		sudo netplan generate
		echo "WARNING: you must restart system so network interface will be renamed"
		set +x
	fi
}

tmp=`mktemp`
trap "rm -f -- $tmp" EXIT

# 1st add "net.ifnames=0" to GRUB:
# TODO: do not match substrings
f=/etc/default/grub
grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=".*net.ifnames=0.*"' $f || {
	sed 's/^\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 net.ifnames=0"/' $f > $tmp
	diff -u $f $tmp || confirm_overwrite $tmp $f
}

declare -a devs
devs=( $(ip -br link show up | awk '$2 == "UP" { print $1}' | tr '\n' ' ') )
[ -n "$devs" ] || errx "Unable to get active network devices"
ndevs=${#devs[@]}
[[ $ndevs =~ ^[0-9]+$ ]] || errx "Got invalid number of network devices '$ndevs'"
echo "INFO: Found ${#devs[@]} active device(s): '${devs[@]}'"
[ $ndevs -gt 0 ] || errx "No active network device found"
# devices surrounded by spaces (for word search)
sp_devs=" ${devs[@]} "
# expected target devices
declare -a tdevs
n=0
sed_expr=''
for i in "${devs[@]}"; do
	[ -z "$sed_expr" ] || sed_expr+=";"
	sed_expr+="s/\\b$i\\b/eth$n/"
	tdevs[$n]="eth$n"
	(( n = n + 1 ))
done
echo "INFO: Expected ${#tdevs[@]} target device(s): '${tdevs[@]}'"
echo "DEBUG: sed expr: '$sed_expr'"	
f=/etc/netplan/00-installer-config.yaml
sudo sed "$sed_expr" $f  > $tmp
sudo diff -u $f $tmp || confirm_overwrite $tmp $f

for i in "${tdevs[@]}"; do
	grep -q "$i" /etc/issue || echo "IP $i: \\4{$i}" | sudo tee -a /etc/issue
done

exit 0
