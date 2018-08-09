{%- import_yaml 'defaults.sls' as defaults -%}
{%- set private_ip = salt['network.interface_ip'](salt['grains.get']('private_interface', 'eth1')) -%}

data:
  path: /srv/data


master:
  address: 127.0.0.1
  ssh_keys: {}


minion:
  id: mcp
  master: 127.0.0.1
  startup_states: highstate


jenkins:
  user: 'jenkins'
  group: 'jenkins'
  domain: 'jenkins.{{ defaults.master.domain }}'


redis:
  hostname: 'redis'


magbot:
  deploy_log_domain: 'mcp.{{ defaults.master.domain }}'
  webserver_domain: 'magbot.{{ defaults.master.domain }}'
  admins:
    - '@Dac'
    - '@debra'
    - '@dom'
    - '@eli'
    - '@nickthenewbie'
    - '@robruana'
  core_plugins:
    - 'ACLs'
    - 'Backup'
    # - 'CommandNotFoundFilter'  # Displays 'Command "COMMAND" not found.'
    - 'Health'
    - 'Help'
    - 'Plugins'
    - 'TextCmds'
    - 'Utils'
    - 'VersionChecker'
    # - 'Webserver'  # Disabled for now


traefik:
  letsencrypt_enabled: True
  caServer: ''  # Leave empty for production server
  cert_names: ['ipa-01.{{ defaults.master.domain }}']
  domain: '{{ defaults.master.domain }}'
  ui_domain: 'traefik.{{ defaults.master.domain }}'
  subdomains: ['directory', 'errbot', 'magbot', 'mcp', 'jenkins', 'traefik']


ssh:
  password_authentication: False
  permit_root_login: False


ufw:
  enabled: True

  settings:
    ipv6: False

  sysctl:
    forwarding: 1
    ipv6_autoconf: 0

  applications:
    OpenSSH:
      limit: True
    Saltmaster:
      enabled: True
      to_addr: {{ private_ip }}

  services:
    http:
      protocol: tcp
    https:
      protocol: tcp
    88: # kerberos
      protocol: any
    464: # kpasswd
      protocol: any
    389: # ldap
      protocol: tcp
    636: # ldapssl
      protocol: tcp
    7389: # freeipa_replica
      protocol: tcp
    "9443:9445": # freeipa_replica_config
      protocol: tcp

    '*':
      deny: True
      protocol: any
      from_addr: {{ defaults.ip_blacklist }}
