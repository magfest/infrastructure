# Some helpful SaltStack Commands

#### Run an Arbitrary Command
```
salt -C 'G@roles:reggie' cmd.run 'ls -la /var/logs/reggie'
```

#### Update APT Packages
```
salt -C 'G@roles:reggie' cmd.run 'export DEBIAN_FRONTEND=noninteractive; export DEBIAN_PRIORITY=critical; apt-get -qy update; apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade; apt-get -qy autoclean'
```

#### Reggie Maintenance Mode

To put production Reggie into maintenance mode:
```
salt -C 'G@roles:reggie and G@roles:web and G@env:prod' state.sls reggie_deploy.web pillar='{"reggie": {"maintenance": True}}'
```

And to undo maintenance mode:
```
salt -C 'G@roles:reggie and G@roles:web and G@env:prod' state.sls reggie_deploy.web
```

#### Bootstrap an Existing VM
1. Enable private networking for the target VM by following [these instructions](https://www.digitalocean.com/docs/networking/private-networking/how-to/enable/)
2. Update `/etc/salt/roster` on `mcp` to include the target VM you want to bootstrap
    a. `/etc/salt/roster` is managed by salt in the [salt_cloud.manager](https://github.com/magfest/infrastructure/blob/master/magfest_state/salt_cloud/manager.sls) state
    b. Update `salt_cloud.manager` and run the following command on `mcp`:
```
salt mcp state.sls salt_cloud.manager
```
3. Run the following command on `mcp` to install salt on the target VM:
```
salt-ssh existing.vm.magfest.org state.sls salt_minion.bootstrap
```
3. Run the following command on `mcp` to accept the target VM's salt key:
```
salt-key -a existing.vm.magfest.org
```
