{%- set data_path = '/srv/volumes/data' -%}

master_address: 127.0.0.1
minion_id: salt-master
data_path: {{ data_path }}

ufw:
  enabled:
    True

  applications:
    OpenSSH:
      enabled: True
    Saltmaster:
      enabled: True

  services:
    http:
      protocol: tcp
    https:
      protocol: tcp
    53:
      protocol: any
    88:
      protocol: any
    123:
      protocol: udp
    389:
      protocol: tcp
    464:
      protocol: any
    636:
      protocol: tcp
    7389:
      protocol: tcp
    "9443:9445":
      protocol: tcp

  sysctl:
    forwarding: 1
