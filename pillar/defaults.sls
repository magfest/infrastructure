{%- set master_domain = 'magfest.net' -%}

master:
  domain: {{ master_domain }}
  address: saltmaster.{{ master_domain }}

freeipa:
  realm: 'magfest.org'
  hostname: 'ipa-01.{{ master_domain }}'
  ui_domain: 'directory.{{ master_domain }}'

mine_functions:
  external_ip:
    - mine_function: network.interface_ip
    - eth0
  internal_ip:
    - mine_function: network.interface_ip
    - eth1

ufw:
  enabled: True

  applications:
    OpenSSH:
      limit: True
