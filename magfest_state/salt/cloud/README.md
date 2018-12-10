# Salt Cloud Server Creation

All new Reggie servers should be created using the `salt-cloud` command.
For a general guide to using `salt-cloud` to create Digital Ocean servers,
please refer to Digital Ocean's [excellent tutorial](https://www.digitalocean.com/community/tutorials/saltstack-infrastructure-configuring-salt-cloud-to-spin-up-digitalocean-resources).

> **SIDE NOTE**: This whole process is a little janky, and could be rethought.
> A lot of this process is formulaic and could easily be automated – perhaps
> built into [magbot](https://github.com/magfest/magbot). Alternatively, we
> may want to consider using a different provisioning technology, like
> Terraform. Considering that we only spin up new servers a handful of times
> per year, it's not a pressing concern.

There are a few steps to configuring new Reggie servers:


### 0. Prerequisites

In order to provision new Reggie servers using `salt-cloud`, you'll need SSH
access to mcp.magfest.net. Follow the instructions in the top-level
[README](/README.md) for getting SSH access to mcp.magfest.net.

If you're going to be using a new domain, then at some point you'll need to
log into our DNS provider (for MAGFest this is DNSMadeEasy) and create a new
A record for the subdomain.  You should probably do this before creating the
server, but in theory you can do it later and just do another deploy on the
server afterwards.  The only real consequence is that the server won't have
a valid LetsEncrypt cert until the first deploy after we have DNS working.

### 1. Create a Cloud Profile

Create an appropriately named file in the
[cloud.profiles.d](/magfest_state/salt/cloud/files/cloud.profiles.d)
directory. Something like `reggie-ENV-EVENT_NAME-EVENT_YEAR-profiles.conf`.

For production MAGStock 2019, `reggie-prod-stock-2019-profiles.conf`:
```
base-reggie-prod-stock-2019:
  provider: digitalocean
  image: ubuntu-18-04-x64
  location: nyc1  # Location must be nyc1 to share private network with Salt Master
  private_networking: True  # private_networking required to communicate with Salt Master
  tags:  # Tags applied to the droplets in Digital Ocean
    - reggie  # "reggie" tag not required, just a convenience
    - production  # "production" tag automatically enrolls the droplet in performance alerts
  minion:
    grains:  # The three required grains that are shared be every server
      env: prod  # Valid values: prod, staging, dev, load
      event_name: super  # Valid values: super, labs, stock, west
      event_year: 2019  # Valid value: any integer year

reggie-prod-stock-2019-single:
  extends: base-reggie-prod-stock-2019
  size: s-2vcpu-2gb
  minion:
    grains:
      roles:  # "roles" grains must be declared on each profile, cannot be extended from base profile
        - reggie  # Each server MUST have "reggie" role
        - db  # List of all roles this server plays – monolithic servers should have ALL roles
        - files  # Valid values: db, files, loadbalancer, queue, scheduler, sessions, web, worker
        - loadbalancer
        - queue
        - scheduler
        - sessions
        - web
        - worker
```


### 2. Create a Cloud Map

Create an appropriately named file in the
[cloud.maps.d](/magfest_state/salt/cloud/files/cloud.maps.d)
directory. Something like `reggie-ENV-EVENT_NAME-EVENT_YEAR.map`.

For production MAGStock 2019, `reggie-prod-stock-2019.map`:
```
reggie-prod-stock-2019-single:
  - magstock9.reggie.magfest.org
```


### 3. Apply Changes to MCP

So far, we've only made changes to the infrastructure repository,
mcp.magfest.net is still unaware of those changes. If you've already
SSH'd to mcp.magfest.net, you can apply the changes with the following
commands:
```
cd /srv/infrastructure
git pull
salt mcp.magfest.net state.sls salt.cloud.manager
```

You can also apply the changes to MCP using magbot on Slack:
```
! update mcp
```

These commands copy the new files you just created to the appropriate
locations on mcp.magfest.net:

- /etc/salt/cloud.profiles.d/reggie-prod-stock-2019-profiles.conf
- /etc/salt/cloud.maps.d/reggie-prod-stock-2019.map


### 4. Provision the Servers

From the command line on mcp.magfest.net:
```
sudo salt-cloud -P -m /etc/salt/cloud.maps.d/reggie-prod-stock-2019.map
```

This will tell you that the VMs don't exist yet:

> No minions matched the target. No command was sent, no jid was assigned. The following virtual machines are set to be created: (YOUR MACHINE NAMES GO HERE)

You will be asked if you want to create the machine(s) you specified - you should say yes.

This will take awhile to complete. Once the server has been created, it will
check-in to the Salt Master to complete it's configuration. This process
happens in the background, so there's no real way to tell what is happening,
or when it's finished. There are a couple of ways you can get results:

* Find the `highstate` job in the Salt Master web UI at https://salt.magfest.net.
  See the [Salt Master README](/magfest_state/salt/master/README.md) for details
  on getting access to the Salt Master web UI.
* Find the JID by attempting to run another `highstate` job on the command line:
  ```
  salt -C 'G@roles:reggie and G@env:prod and G@event_name:stock and G@event_year:2019' state.apply
  ```

  The command will inevitably fail with an error message saying something like
  "another highstate job is already running with JID 201800000000000000". You
  can then use that JID on the command line:
  ```
  salt-run --out highstate jobs.lookup_jid 201800000000000000
  ```

> **SIDE NOTE**: The configuration process that happens after a server is
> created is initiated by events in the [salt reactor](/magfest_state/salt/reactor)
> and ultimately controlled by [salt orchestration](/magfest_state/salt/orchestration).


### 5. Verify Configuration

The deployment command may need to be run several times before all errors
are resolved, especially for larger distributed deployments. This is mostly
due to vagaries in the order servers come online, and how long they
take to configure themselves.

If there are any errors after the initial provisioning, try running the
deployment command again:
```
salt -C 'G@roles:reggie and G@env:prod and G@event_name:stock and G@event_year:2019' state.apply
```


### 6. Add private data

By default, all of our "sensitive" config settings like passwords and API
keys use the default values defined in the reggie salt states.  This means
that the passwords are mostly just "reggie".  This is fine for our staging
servers, since those should never contain sensitive data.

When deploying a production server, we'll need to configure values such as
passwords and API tokens in a place that doesn't get saved to Github.  Such
data is saved under the /srv/data/secret/infrastructure directory, which
has the exact same directory structure as this "infrastructure" repository.
You can edit those files by hand to set secure values for such options.



# Importance of `roles` Salt Grains

Almost all of our salt targeting is done using the following salt grains:
`env`, `event_name`, `event_year`, `roles`.  MAGBot relies on the existence
of these grains for it's deployments.

For example:
```
env: prod          # String, valid values: prod, staging, dev, load
event_name: stock  # String, valid values: super, labs, stock, west
event_year: 2019   # Int, valid value: any integer year
roles:             # List, valid values:
  - reggie         # Each Reggie server MUST have "reggie" role
  - db
  - files
  - loadbalancer
  - queue
  - scheduler
  - sessions
  - web
  - worker
```
