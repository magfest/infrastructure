{%- import_yaml 'ip_blacklist.yaml' as ip_blacklist -%}
{%- set mcp_ip = salt['network.interface_ip'](salt['grains.get']('private_interface', 'eth1')) -%}

ip_blacklist: {{ ip_blacklist.ip_blacklist }}

master:
  domain: magfest.net
  address: {{ mcp_ip }}


minion:
  master: {{ mcp_ip }}

  log_file: file:///dev/log
  log_level: info

  use_superseded:
    - module.run

  mine_functions:
    public_ip:
      - mine_function: network.interface_ip
      - eth0
    private_ip:
      - mine_function: network.interface_ip
      - {{ salt['grains.get']('private_interface', 'eth1') }}


freeipa:
  realm: 'magfest.org'
  hostname: 'ipa-01.magfest.net'
  ui_domain: 'directory.magfest.net'


ssh:
  password_authentication: False
  permit_root_login: False


ufw:
  enabled: True

  settings:
    ipv6: False

  sysctl:
    ipv6_autoconf: 0

  applications:
    OpenSSH:
      limit: True
