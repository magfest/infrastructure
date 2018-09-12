# Some helpful SaltStack Commands

#### Targeting Minions
All Reggie servers have the `roles:reggie` grain. All staging servers have
a `env:staging` grain. Likewise, production servers have a `env:prod` grain.
Each Reggie server is also tagged with the `event_name` and `event_year`
grains. Using combinations of `roles`, `env`, `event_name`, and `event_year`,
we can target various minions.

#### Deploying Reggie
Production Super 2019:
```
salt -C 'G@roles:reggie and G@env:prod and G@event_name:super and G@event_year:2019' state.apply
```

Staging Super 2019:
```
salt -C 'G@roles:reggie and G@env:staging and G@event_name:super and G@event_year:2019' state.apply
```

These are essentially the exact commands that MAGBot runs during a deploy.
MAGBot will also ensure the relevant repositories are up-to-date before
issuing the `state.apply`:
```
cd /srv/infrastructure
git pull
salt-run fileserver.update
```

#### Asynchronous Commands
Some commands may take a long time to run. In that case, you may optionally
pass the `--async` flag, and check for results later using the following command:
```
salt-run salt-run --out highstate jobs.lookup_jid 20180000000000000000
```

A helpful alias has been installed for root on MCP for looking up salt jobs:
```
alias salt-job='salt-run --out highstate jobs.lookup_jid'
```

#### Provision Cloud Servers

Assuming cloud maps and cloud profiles have been set up properly in the
[salt.cloud](https://github.com/magfest/infrastructure/tree/master/magfest_state/salt/cloud/README.md)
state:
```
salt-cloud -P -m /etc/salt/cloud.maps.d/reggie-prod.map
```

Destroy cloud servers:
```
salt-cloud -d prod-web-03.reggie.magfest.org prod-web-04.reggie.magfest.org
```

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

_Note: many of our salt states assume the OS is Ubuntu 16.04 or later._

1. Make sure the target VM is in the same region as the Salt Master (mcp.magfest.net is in NYC1)
2. Enable private networking for the target VM by following [these instructions](https://www.digitalocean.com/docs/networking/private-networking/how-to/enable/)
3. Update `/etc/salt/roster` on `mcp` to include the target VM you want to bootstrap

    a. `/etc/salt/roster` is managed by salt in the [salt.cloud.manager](https://github.com/magfest/infrastructure/blob/master/magfest_state/salt/cloud/manager.sls) state
    b. Update `salt.cloud.manager` and run the following command on `mcp`:
```
salt mcp.magfest.net state.sls salt.cloud.manager
```
4. Run the following command on `mcp` to install salt on the target VM:
```
salt-ssh existing.vm.magfest.org state.sls salt.minion.bootstrap
```
5. Run the following command on `mcp` to accept the target VM's salt key:
```
salt-key -a existing.vm.magfest.org
```
