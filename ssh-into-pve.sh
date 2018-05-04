#!/usr/bin/env bash
set -e

PVE_DOMAIN="${PVE_DOMAIN:-vanguard.vashonsd.org}"

PVE_HOSTS=(pve1 pve2 pve3)

function list_of_containers() {
    for i in "${PVE_HOSTS[@]}"; do
        ssh $i.$PVE_DOMAIN "pct list | tail -n +2" &
    done
}

function containers_host() {
    join <(ssh ${PVE_HOSTS[0]}.$PVE_DOMAIN "ha-manager status | grep 'ct:' | awk -F'[ :(),]' '{print \$3 \" \" \$5}' | sort" &) \
        <(list_of_containers | awk '{print $1 " " $3}' | sort &)
}

case $1 in
list)
    echo "Only running containers in HA manager, no KVM VM's"
    containers_host
;;
help)
cat <<-EOF
	[list | <vmid> | <vm-name>]
	Only works on running containers in HA manager, no KVM VM's"
	set PVE_DOMAIN to change the domain
EOF
;;
''|*[0-9]*)
    container_host=$(containers_host | grep -Ew "$1$")
    echo "Entering $(echo $container_host | awk '{ print $3 " (" $1 ") on " $2 }')"
    ssh -tt $(echo $container_host | awk '{ print $2 }').$PVE_DOMAIN "pct enter $1"
;;
*)
    container_host=$(containers_host | grep -Ew "$1$")
    echo "Entering $(echo $container_host | awk '{ print $3 " (" $1 ") on " $2 }')"
    ssh -tt $(echo $container_host | awk '{ print $2 }').$PVE_DOMAIN "pct enter $(echo $container_host | awk '{ print $1 }')"
;;
esac

