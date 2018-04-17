{%- set master_domain = 'magfest.net' -%}

data_path: /srv/volumes/data
master_address: saltmaster.{{ master_domain }}
master_domain: {{ master_domain }}


mine_functions:
  external_ip:
    - mine_function: network.interface_ip
    - eth0
  internal_ip:
    - mine_function: network.interface_ip
    - eth1


ufw:
  enabled:
    True
  applications:
    OpenSSH:
      enabled: True
