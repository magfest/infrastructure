{%- set data_path = '/srv/volumes/data' -%}

master_address: 127.0.0.1
minion_id: salt-master
data_path: {{ data_path }}
domain: magfest.net


ufw:
  enabled:
    True

  services:
    http:
      protocol: tcp
    https:
      protocol: tcp

  applications:
    OpenSSH:
      enabled: True
    Saltmaster:
      enabled: True
