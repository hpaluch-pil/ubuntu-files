#!/bin/bash
# install hypervisor specific VM packages
set -euo pipefail

# simulate BSD Error & Exit function
errx () {
	echo "ERROR: $*" >&2
	exit 1
}
info() { echo "INFO: $*"; }

# it is messy to detect proper hypervisor - using virt-what
which virt-what > /dev/null 2> /dev/null || sudo apt-get install virt-what

# associative array key=hypervisor value=guest_package
declare -A pkgs=( [kvm]="qemu-guest-agent" [vmware]="open-vm-tools" )
# print pkgs array:
#declare -p pkgs

hv=`sudo virt-what`
info "Detected hypervisor: '$hv'"
if [ -n "$hv" ]; then
	p="${pkgs[$hv]:-}"
	[ -n "$p" ] || errx "Detected unsupported hypervisor '$hv'. Supported are: ${!pkgs[*]}"
	info "Installing '$p' for hypervisor '$hv'"
	sudo apt-get install "$p"
	unset pkgs[$hv]
else
	info "No hypervisor detected - uninstalling all guest packages: ${pkgs[*]}"
fi
info "Uninstalling non '$hv' guest packages: ${pkgs[*]}"
sudo apt-get purge "${pkgs[@]}"
sudo apt-get autoremove --purge

exit 0
