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
