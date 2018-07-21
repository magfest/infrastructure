{%- set mcp_ip = salt.saltutil.runner('mine.get', tgt='mcp', fun='internal_ip').values()|first -%}

master:
  domain: magfest.net
  address: {{ mcp_ip }}


freeipa:
  realm: 'magfest.org'
  hostname: 'ipa-01.magfest.net'
  ui_domain: 'directory.magfest.net'


mine_functions:
  external_ip:
    - mine_function: network.interface_ip
    - eth0
  internal_ip:
    - mine_function: network.interface_ip
    - {% if salt['grains.get']('is_vagrant') %}eth0{% else %}eth1{% endif %}


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
