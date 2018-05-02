{%- from 'defaults.sls' import master_domain -%}
{%- import_yaml ip_blacklist.sls' as ip_blacklist -%}

data:
  path: /srv/data

master:
  address: 127.0.0.1
  firewall_blacklisted_ips: []
  ssh_keys: {}

minion:
  id: mcp

jenkins:
  domain: 'jenkins.{{ master_domain }}'

traefik:
  cert_names: ['ipa-01.{{ master_domain }}']
  domain: '{{ master_domain }}'
  ui_domain: 'traefik.{{ master_domain }}'
  subdomains: ['directory', 'errbot', 'hal', 'jenkins', 'traefik']

ufw:
  enabled:
    True

  applications:
    OpenSSH:
      limit: True
      enabled: True
    Saltmaster:
      enabled: True

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
    # 7389: # freeipa_replica
    #   protocol: tcp
    # "9443:9445": # freeipa_replica_config
    #   protocol: tcp

    '*':
      deny: True
      protocol: any
      from_addr: {{ ip_blacklist.ip_blacklist }}

  sysctl:
    forwarding: 1
