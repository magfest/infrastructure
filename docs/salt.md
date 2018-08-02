# Some helpful SaltStack Commands

#### Install Digital Ocean's monitoring tools
```
salt -C '*reggie*' cmd.run 'curl -sSL https://agent.digitalocean.com/install.sh | sh'
```

#### Update APT Packages
```
salt -C '*reggie*' cmd.run 'export DEBIAN_FRONTEND=noninteractive; export DEBIAN_PRIORITY=critical; apt-get -qy update; apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade; apt-get -qy autoclean'
```
