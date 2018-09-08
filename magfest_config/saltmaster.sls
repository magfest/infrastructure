{%- import_yaml 'defaults.sls' as defaults -%}
{%- set private_ip = salt['network.interface_ip'](salt['grains.get']('private_interface', 'eth1')) -%}

data:
  path: /srv/data


master:
  address: 127.0.0.1
  ssh_keys: {}


minion:
  master: 127.0.0.1
  startup_states: highstate


jenkins:
  user: 'jenkins'
  group: 'jenkins'
  domain: '{{ defaults.master.host_prefix }}jenkins.{{ defaults.master.domain }}'


redis:
  hostname: 'redis'


magbot:
  deploy_log_domain: '{{ defaults.master.host_prefix }}mcp.{{ defaults.master.domain }}'
  webserver_domain: '{{ defaults.master.host_prefix }}magbot.{{ defaults.master.domain }}'
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
    - 'Health'
    - 'Help'
    - 'Plugins'
    - 'TextCmds'
    - 'Utils'
    - 'VersionChecker'
  port: 9999
  jira_url: https://jira.magfest.net
  jira_ignoreusers: jira
  ssh_host: {{ salt['network.interface_ip'](salt['grains.get']('public_interface', 'eth0')) }}
  salt_api_url: https://{{ defaults.master.host_prefix }}salt.{{ defaults.master.domain }}


traefik:
  letsencrypt_enabled: True
  caServer: ''  # Leave empty for production server
  cert_names: ['{{ defaults.master.host_prefix }}ipa-01.{{ defaults.master.domain }}']
  domain: '{{ defaults.master.domain }}'
  ui_domainname: '{{ defaults.master.host_prefix }}traefik.{{ defaults.master.domain }}'
  subdomains: {% for subdomain in ['directory', 'errbot', 'jenkins', 'magbot', 'mcp', 'salt', 'traefik'] %}
    - {{ defaults.master.host_prefix }}{{ subdomain }}
  {% endfor %}


ssh:
  password_authentication: False
  permit_root_login: True


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
      to_addr: any
      comment: Public SSH

    Saltmaster:
      enabled: True
      to_addr: {{ private_ip }}
      comment: Private Saltmaster

  services:
    http:
      protocol: tcp
      comment: Public HTTP
    https:
      protocol: tcp
      comment: Public HTTPS
    88:
      protocol: any
      comment: Kerberos
    464:
      protocol: any
      comment: Kerberos kpasswd
    389:
      protocol: tcp
      comment: LDAP
    636:
      protocol: tcp
      comment: LDAP SSL
    7389:
      protocol: tcp
      to_addr: {{ private_ip }}
      comment: FreeIPA Replica
    "9443:9445":
      protocol: tcp
      to_addr: {{ private_ip }}
      comment: FreeIPA Replica Config
    8000:
      protocol: tcp
      to_addr: {{ private_ip }}
      comment: Private Salt API

    '*':
      deny: True
      protocol: any
      from_addr: {{ defaults.ip_blacklist }}
