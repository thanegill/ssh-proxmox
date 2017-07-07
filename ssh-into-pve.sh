#!/usr/bin/env bash
set -e

PVE_DOMAIN="${PVE_DOMAIN:-vanguard.vashonsd.org}"

function list_of_containers() {
    for i in $(seq 1 3); do
        ssh pve$i.$PVE_DOMAIN "pct list | tail -n +2" &
    done
}

function containers_host() {
    join <(ssh pve1.$PVE_DOMAIN "ha-manager status | grep 'ct:' | awk -F'[ :(),]' '{print \$3 \" \" \$5}' | sort" &) \
        <(list_of_containers | awk '{print $1 " " $3}' | sort &)
}

case $1 in
list)
    echo "Only Running Containers, no KVM VM's"
    containers_host
;;
help)
cat <<-EOF
	[list | <vmid> | <vm-name>]
	Only works on running containers, no KVM VM's"
	set PVE_DOMAIN to change the domain
EOF
;;
''|*[0-9]*)
    echo "Entering $(containers_host | grep $1 | awk '{ print $3 " (" $1 ") on " $2 }')"
    ssh -tt $(containers_host | grep $1 | awk '{ print $2 }').$PVE_DOMAIN "pct enter $1"
;;
*)
    echo "Entering $(containers_host | grep $1 | awk '{ print $3 " (" $1 ") on " $2 }')"
    ssh -tt $(containers_host | grep $1 | awk '{ print $2 }').$PVE_DOMAIN "pct enter $(containers_host | grep $1 | awk '{ print $1 }')"
;;
esac

