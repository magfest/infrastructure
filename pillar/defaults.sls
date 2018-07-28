{%- set internal_interface = 'eth0' if salt['grains.get']('is_vagrant') else 'eth1' -%}
{%- set mcp_ip = salt['network.interface_ip'](internal_interface) -%}

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
    external_ip:
      - mine_function: network.interface_ip
      - eth0
    internal_ip:
      - mine_function: network.interface_ip
      - {{ internal_interface }}


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
