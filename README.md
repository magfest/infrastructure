# MAGFest IT Infrastructure

## Creating a salt-master control server

1. Create a new server using the most recent Ubuntu image on https://digitalocean.com
2. SSH to the new server
3. As root/sudo run:
```
curl -L https://github.com/magfest/infrastructure/raw/master/bootstrap.sh | sh
```
4. **Optional** Enter your GitHub credentials when prompted. If you skip this, or do not have access to https://github.com/magfest/infrastructure-secrets, your salt-master server will not be able to automatically provision new Digital Ocean servers
