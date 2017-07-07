# SSH into Proxmox

Instead of opening up ssh on your DMZ use this script to ssh then enter the
container on a proxmox cluster.

Assumes that there are 3 nodes with DNS records of ``pve{1-3}.$PVE_DOMAIN``. Set
``$PVE_DOMAIN`` in your environment or in the shell.

Pull requests to make this more generic are more than welcome.

MIT Licence
