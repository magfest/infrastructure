# MAGFest IT Infrastructure

## Creating a salt-master control server

Creating a salt-master control server should only need to be done rarely—ideally just once. The salt-master control server is the central piece of MAGFest's IT infrastructure used to provision and manage all of our other servers.

1. Create a new droplet on https://digitalocean.com
  * Ubuntu 16.04.4 x64
  * **Optional**: Add a block storage volume (this will need to be mounted on `/var/data`)
  * Select "Private Networking" and "Monitoring"
  * Add the following SSH Keys: "Saltmaster", "Rob Ruana", and "DomMCP"
2. SSH to the new server
3. As root/sudo run:
```
curl -L https://github.com/magfest/infrastructure/raw/master/bootstrap.sh | sh
```
4. Enter your GitHub credentials when prompted. If you skip this, or do not have access to https://github.com/magfest/infrastructure-secret, the new salt-master server will not be able to automatically provision new Digital Ocean servers
