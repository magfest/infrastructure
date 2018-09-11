{%- import_yaml 'defaults.sls' as defaults -%}
{%- set private_ip = salt['grains.get']('ip4_interfaces')[salt['grains.get']('private_interface', 'eth1')][0] %}

ufw:
  sysctl:
    forwarding: 1

  services:
    http:
      protocol: tcp
      comment: Public HTTP

    https:
      protocol: tcp
      comment: Public HTTPS

    9200:
      to_addr: {{ private_ip }}
      comment: Private Filebeat/Logstash

    '*':
      deny: True
      protocol: any
      from_addr: {{ defaults.ip_blacklist }}
